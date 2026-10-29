%%
clear all; close all; clc

runloc = 1;
doCrop = 1;

%% Load data

if runloc == 1 || runloc == 3    % Hubel, Nuke 
    dirBase = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home';
    analysisDir     = fullfile(dirBase,'sara','Analysis','Neuropixel','CrossOri','randDirFourPhase');
    load([analysisDir, '\CrossOri_randDirFourPhase_summary.mat'])
elseif runloc == 2    % Wiesel
    dirBase = '/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home';
    load('/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/sara/Analysis/Neuropixel/CrossOri/randDirFourPhase/CrossOri_randDirFourPhase_summary.mat')
else
    error('Location not valid. 1 == Hubel, 2 == Wiesel.')
end

% get index of vis resp, DS cells with RFs
    indCortex   = find(~isnan(layer_all));
    ind_sigRF   = sum(cells_sigRFbyTime_On_all,2)+sum(cells_sigRFbyTime_Off_all,2);
    listnc      = 1:size(cells_sigRFbyTime_On_all,1);
    indRF_pix   = listnc(ind_sigRF>0)';
    indRF_con   = find(bestTimePoint_all(:,2)>1);
    
    indRF_pix   = intersect(indRF_pix,indCortex);
    indRF_con   = intersect(indRF_con,indCortex);
    indRFint    = unique([indRF_pix; indRF_con]);
    idxInt      = intersect(indRF_pix, indRF_con);  % both mask and contrast method
    
    idxMask     = setdiff(indRF_pix, indRF_con); % mask method only
    idxCon      = setdiff(indRF_con,indRF_pix); % contrast method only
    
    ind         = intersect(resp_ind_dir_all, find(DSI_all>.5));

    ind_DS = intersect(find(DSI_all>0.25),find(gDSI_all>0.2));
        [DSIstruct_new] = getDSIstruct_new(avg_resp_dir_all);
        gratResp        = DSIstruct_new.resp;
        maxGratResp     = max(gratResp,[],2);
        minGratResp     = min(gratResp,[],2);
    ind_peakFRmin   = find(maxGratResp>1);
    ind_rangeFRmin  = find(maxGratResp > (abs(minGratResp)*2));
    ind_FR = intersect(ind_peakFRmin,ind_rangeFRmin);
    
    ind_mouseEphys = intersect(intersect(intersect(ind_DS,resp_ind_dir_all),ind_FR),find(~isnan(layer_all)));


% use visually responsive cells with DS > .5 and reliable RFs.
    cellsSelected = intersect(idxInt, ind_mouseEphys);

    omitCells   = [];
    cellsIdx    = setdiff(cellsSelected, omitCells);

%% get STAs for fitting

zscoreSTAs_all = [];

nSelected   = numel(cellsIdx);

for ic = 1:nSelected
    zscoreSTAs_all(ic,:,:) = avgImgZscore_all(cellsSelected(ic),bestTimePoint_all(cellsIdx(ic),1),:,:);
end

%% fitting
fprintf('Fitting models to data... \n')

if doCrop
    sideLength      = 29;
    STA_for_fitting_all = nan(sideLength, sideLength, nSelected); 
else
    STA_for_fitting_all = nan(xDim, yDim, nSelected); 
end

if doCrop
    STA_cropped     = nan(sideLength, sideLength, nSelected);
    for k = 1:nSelected
        data        = squeeze(zscoreSTAs_all(k, :, :));
        [el, az]    = getRFcenter(data);
        data_smth   = medfilt2(imgaussfilt(data, 1));
        [STA_cropped(:, :, k), xStart(k)] = cropRFtoCenter(az, el, data_smth, sideLength);
    end
    STA_for_fitting     = STA_cropped;
else
    % zscoreSTAs_all is (nChunks+1, nCells, xDim, yDim); reorder to
    % (xDim, yDim, nSelected) to match STA_for_fitting_all's shape
    STA_for_fitting = permute(squeeze(zscoreSTAs_all(:,:,:)), [2 3 1]);
end

STA_for_fitting_all(:,:,:) = STA_for_fitting;   

modelRegistry = [
    struct( ...
        'name','Noncon DoG', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNonConcentricEllipticalDoG(STA,'unnormalized',50), ...
        'k',10)
];

omitCells = [];

fitIdx = 1:nSelected;

results = runRFModelComparison( ...
    fitIdx, ...
    cellsIdx, ...
    STA_for_fitting, ...
    modelRegistry, ...
    omitCells, ...
    'pdf', ...
    'test_all_fit.pdf');

modelNames  = {results.modelRegistry.name};

dog_fits    = cat(3,results.models{1}{:});
dog_fits_all(:,:,:)    = cat(3,results.models{1}{:});


%% Uncrop fits to full stimulus size
fprintf('Uncropping fits... \n')

if doCrop
    for ic = 1:nSelected
        xs = xStart(ic);
        xe = xs + sideLength - 1;    % ending column (should be xs+28)
        data = dog_fits_all(:,:,ic);   % 29 x 29
        dog_corner = data(end,1);
        fullImg = dog_corner * ones(29, 52);   % Initialize full image with corner value
        fullImg(:, xs:xe) = data;   % Insert cropped data into correct location
        dog_fits_Uncropped(:,:,ic) = fullImg; 
    end
else
    % fits are already full-size
    dog_fits_Uncropped  = dog_fits_all;
end

%% omit bad STA cells

omitCells = [1441 1558 1753];

omitCells = [1441 1558 1753 1015 1438]; 
cellsIdx_final = setdiff(cellsIdx,omitCells);

save( ...
    fullfile( ...
        dirBase, ...
        'sara', ...
        'Analysis', ...
        'Neuropixel', ...
        'CrossOri', ...
        'randDirFourPhase', ...
        'mouse_RFs', ...
        'final_RFindices.mat'), ...
     'cellsIdx', ...
     'dog_fits_Uncropped',...
    'cellsIdx_final');

%% Plot STAs and fits
fprintf('Plotting STAs... \n')

% get pref dir
gratResps           = squeeze(avg_resp_dir_all(cellsIdx,:,1,1,1));
[maxDir, indDir]    = max(gratResps,[],2);
dirs                = 0:30:330;

% get aligned tuning curves
[avg_resp_grat, avg_resp_plaid, sem_resp_grat, sem_resp_plaid] = getAlignedGratPlaidTuning(avg_resp_dir_all);
x       = [-150:30:180];
x_rad   = deg2rad(x);

% for PCI fit
PCI = (Zp_all-Zc_all);
phase = [0 90 180 270];
phase_range = 0:1:359;

% get data, color lims
data_all                    =  zscoreSTAs_all;
maxSmth = max(max(max(max(abs(data_all)))));

% get colors
colors  = getColors;

% Print STA time point choices
pdfDir = fullfile(dirBase, 'sara', 'Analysis', 'Neuropixel','CrossOri','randDirFourPhase','mouse_RFs');
if ~exist(pdfDir, 'dir'); mkdir(pdfDir); end

pdfFile = fullfile(pdfDir, 'spatialRFs_zscored_DoGfits.pdf');
if isfile(pdfFile); delete(pdfFile); end

for ic = 1:length(cellsIdx)
    iCell = cellsIdx(ic);
    figure();
    if ismember(ic, omitCells)
        sgtitle(['cell ' num2str(iCell) ', ic = ' num2str(ic) '-- OMITTED'])
    else
        sgtitle(['cell ' num2str(iCell) ', ic = ' num2str(ic)])
    end
        data = medfilt2(imgaussfilt(squeeze(data_all(ic,:,:)),1));
        subplot(2,2,1)
            imagesc(data); hold on
            pbaspect([16 9 1])
            colormap(gray); box off; axis off
            clim([-5 5])
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            subtitle(['STA, pref dir ' num2str(dirs(indDir(ic))) '°'])
          subplot(2,2,2)
            imagesc(squeeze(dog_fits_Uncropped(:,:,ic))); hold on
            pbaspect([16 9 1])
            colormap(gray); box off; axis off
            clim([-5 5])
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            subtitle('DoG fit, uncropped')
    subplot(4,4,9)
        for im = 1:4
            polarplot([x_rad x_rad(1)], [avg_resp_plaid(iCell,:,im) avg_resp_plaid(iCell,1,im)],'Color', colors(im,:))
            hold on
        end
        polarplot([x_rad x_rad(1)], [avg_resp_grat(iCell,:) avg_resp_grat(iCell,1)],'k', 'LineWidth',2) 
    subplot(4,4,10)
        for im = 1:4
            scatter(Zc_all(im,iCell), Zp_all(im,iCell),8,colors(im,:),'filled')
            hold on
        end
        ylabel('Zp'); ylim([-4 8]);
        xlabel('Zc'); xlim([-4 8]);
        plotZcZpBorders; axis square; set(gca,'TickDir','out')
    subplot(4,4,11)
        scatter(phase,PCI(:,iCell),8,'filled'); hold on
        [b_hat_all(iCell,1), amp_hat_all(iCell,1), per_hat_all(iCell,1),pha_hat_all(iCell,1),sse_all(iCell,1),R_square_all(iCell,1)] = sinefit_PCI(deg2rad(phase),PCI(:,iCell));
        yfit_all(iCell,:,1) = b_hat_all(iCell,1)+amp_hat_all(iCell,1).*(sin(2*pi*deg2rad(phase_range)./per_hat_all(iCell,1) + 2.*pi/pha_hat_all(iCell,1)));
        plot(phase_range, yfit_all(iCell,:,1),'k:');
        ylabel('Zp-Zc'); xlabel('Mask phase'); ylim([-7 7])
        xlim([0 360]); xticks([0 180 360]); set(gca,'TickDir','out')
        text(0.05,0.9,sprintf('R^2 = %.2f',R_square_all(iCell,1)),'Units','normalized','FontSize',8)

    % Append current figure as a new page in the PDF
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);
    close(gcf)

end


%% Measuring RF characteristics

% DoG params
    % 1, 2      - Ac, As
    % 3, 4      - sigmaC, deltaSigma
    % 5         - tau
    % 6         - theta
    % 7, 8      - x0, y0
    % 9, 10     - dx, dy

dogFits_params = results.params{1};

% offset
    offsetMag   = nan(nSelected,1);
    offsetAngle = nan(nSelected,1);
    for i = 1:nSelected
        p = dogFits_params{i};
        if isempty(p)
            continue
        end
        dx = p(9);
        dy = p(10);
        offsetMag(i)   = sqrt(dx.^2 + dy.^2);
        offsetAngle(i) = atan2(dy, dx);  % radians, use rad2deg() if you want degrees
    end

 % aspect ratio   
    dog_AR = nan(nSelected,1);
    for i = 1:nSelected
        p = dogFits_params{i};
        if isempty(p)
            continue
        end
        dog_AR(i) = p(5);   % tau
    end

% size
    dog_sizeC = nan(nSelected,1);
    dog_sizeS = nan(nSelected,1);
    for i = 1:nSelected
        p = dogFits_params{i};
        if isempty(p), continue; end
        sigmaC      = p(3);
        deltaSigma  = p(4);
        sigmaS      = sigmaC + deltaSigma;
        tau         = p(5);
        sigma_x     = sigmaC;
        sigma_y     = sigmaC / tau;

        sigmaCenter(i) = sigma_x;
        sigmaSurround(i) = sigma_y;

        dog_sizeC(i) = sqrt(sigma_x * sigma_y); % center size
        dog_sizeS(i) = sigmaS / sqrt(tau); % surround size
    end

figure;
    subplot 121
        histogram(sigmaCenter*2,30);
        set(gca,'TickDir','out','Fontsize',8); box off
        ylabel('num cells')
        xlabel('vis degrees')
        subtitle('sigma center (visual degrees)')
    subplot 122
        histogram(sigmaCenter*2*2,30);
        set(gca,'TickDir','out','Fontsize',8); box off
        ylabel('num cells')
        xlabel('vis degrees')
        subtitle('2 * sigma center')


%% get pref dir with von mises fit

stimDirs = 0:30:330;
y_fits = zeros(360,size(avg_resp_dir_all,1));
dirs = deg2rad(0:1:359);
for ic = 1:size(avg_resp_dir_all,1)
    [b_hat_all(ic,1), k1_hat_all(ic,1), R1_hat_all(ic,1), R2_hat_all(ic,1), u1_hat_all(ic,1), u2_hat_all(ic,1), sse_all(ic,1),R_square_all(ic,1)] = miaovonmisesfit_dir(deg2rad(stimDirs),avg_resp_dir_all(ic,:,1,1,1));
    dir_yfit_all(:,ic) = b_hat_all(ic,1)+R1_hat_all(ic,1).*exp(k1_hat_all(ic,1).*(cos(dirs-u1_hat_all(ic,1))-1))+R2_hat_all(ic,1).*exp(k1_hat_all(ic,1).*(cos(dirs-u1_hat_all(ic,1))-1));
end

[~, prefDir_vm] = max(dir_yfit_all,[],1);
PO_vm      = mod(prefDir_vm, 180);   % preferred orientation

%%
data_DoG_all = permute(dog_fits_Uncropped,[3 1 2]);

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

Zc_avg = mean(Zc_all(:, cellsIdx_final),1);
Zp_avg = mean(Zp_all(:, cellsIdx_final),1);
Zc_max = max(Zc_all(:, cellsIdx_final),[],1);
Zp_max = max(Zp_all(:, cellsIdx_final),[],1);

baseline = b_all(cellsIdx_final)';
amplitude = amp_all(cellsIdx_final)';

indDoG = ~ismember(cellsIdx,omitCells);


stimDirs = 0:30:330;
y_fits = zeros(360,length(cellsToPlot));
dirs = deg2rad(0:1:359);
for ic = 1:length(cellsToPlot)
    iCell = exCells(ic);
    [b_hat_all(ic,1), k1_hat_all(ic,1), R1_hat_all(ic,1), R2_hat_all(ic,1), u1_hat_all(ic,1), u2_hat_all(ic,1), sse_all(ic,1),R_square_all(ic,1)] = miaovonmisesfit_dir(deg2rad(stimDirs),avg_resp_dir_all(iCell,:,1,1,1));
    dir_yfit_all(:,ic) = b_hat_all(ic,1)+R1_hat_all(ic,1).*exp(k1_hat_all(ic,1).*(cos(dirs-u1_hat_all(ic,1))-1))+R2_hat_all(ic,1).*exp(k1_hat_all(ic,1).*(cos(dirs-u1_hat_all(ic,1))-1));
end
[~, PO_vmfit] = max(dir_yfit_all,[],1);   % returns a 1-based index, so subtract 1 in next line to get degrees
PO_vm = mod(PO_vmfit - 1, 180);

[DSIstruct] = getDSIstruct_new(avg_resp_dir_all);
    gOSI_all = [DSIstruct.gOSI];
    gOSI_toplot = gOSI_all(cellsIdx_final);

dirs = 0:30:330;
ygrid       = ((1:29) - 15) * 2;   % 29 points, centered, spanning -28 to +28 deg
xgrid       = ((1:52) - 26.5) * 2; % 52 points, centered, spanning -51 to +51 deg
SF          = 0.05; % plaid grating's spatial frequency
beta        = 60; % half the angle between the two plaid components

pad   = [];                      % field is 4x bigger in each dimension

for ic = 1:size(data_all,1)
    prefDir     = dirs(indDir(ic));    % actual direction in degrees, 0-330
    RF          = medfilt2(imgaussfilt(squeeze(data_all(ic,:,:)),1));
    RF_dog      = squeeze(data_DoG_all(ic,:,:));
    PO(ic)      = mod(prefDir, 180);   % preferred orientation

    RFup     = interp2(xgrid, ygrid(:), RF, xq, yq(:), 'cubic');
    [PO_fftAll(ic), OSI_fftAll(ic), prefSF(ic)] = estimatePOfromFFT(RF, xgrid, ygrid, [], pad, []);
    [PO_fft(ic), OSI_fft(ic), ~] = estimatePOfromFFT(RF, xgrid, ygrid, SF, pad, []);
    phaseCoh(ic) = estimatePhaseCoherence(RF, xgrid, ygrid, PO_vm(ic), SF, beta);
    phaseCoh_fft(ic) = estimatePhaseCoherence(RF, xgrid, ygrid, PO_fft(ic), SF, beta);
    [PO_dog_fftAll(ic), OSI_dog_fftAll(ic), prefSF_dog(ic)] = estimatePOfromFFT(RF_dog, xgrid, ygrid);
    [PO_dog_fft(ic), OSI_dog_fft(ic), ~, dog_fft_tuning(ic,:)] = estimatePOfromFFT(RF_dog, xgrid, ygrid, SF);
    %print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', ['FFT_prefOri_cell' num2str(ic) '_pad' num2str(pad) '.pdf']), '-dpdf', '-bestfit')

    %if ic==3; stop; end;
end



figure;
movegui('center')
    subplot 231
        scatter(PO(indDoG),PO_fftAll(indDoG),10,'filled'); 
        refline(1); axis square; box off
        xlim([0 180]); ylim([0 180]); xticks(0:45:180); yticks(0:45:180)
        xlabel('pref ori, max')
        ylabel('pref ori, FFT of STA')
    subplot 232
        scatter(PO_vm(cellsIdx(indDoG)),PO_fftAll(indDoG),10,'filled'); 
        refline(1); axis square; box off
        xlim([0 180]); ylim([0 180]); xticks(0:45:180); yticks(0:45:180)
        xlabel('pref ori, von mises of spiking')
        ylabel('pref ori, FFT of STA')
        subtitle('FFT at pref SF')
    subplot 233
        scatter(PO_vm(cellsIdx(indDoG)),PO_fft(indDoG),10,'filled'); 
        refline(1); axis square; box off
        xlim([0 180]); ylim([0 180]); xticks(0:45:180); yticks(0:45:180)
        xlabel('pref ori, von mises of spiking')
        ylabel('pref ori, FFT of STA')
        subtitle('FFT at 0.05 SF')
    subplot 234
        scatter_reg(OSI_dog_fft(indDoG),gOSI_toplot,20)
        set(gca,'TickDir','out'); axis square; box off
        ylabel('Spiking gOSI')
        xlabel('STA gOSI (0.05)')
        xlim([0 1])
        ylim([0 1])
    subplot 235
        scatter_reg(OSI_dog_fft(indDoG),OSI_dog_fftAll(indDoG),20)
        set(gca,'TickDir','out'); axis square; box off
        ylabel('STA gOSI (pref)')
        xlabel('STA gOSI (0.05)')
        xlim([0 1])
        ylim([0 1])
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary_gOSISpikeVSTA.pdf'), '-dpdf', '-bestfit')
    
 figure; 
    scatter(PO_fftAll,PO_fft)
    refline(1)
    xlabel('pref ori at pref SF')
    ylabel('pref ori at 0.05 SF')
    set(gca,'FontSize',12)

%% plot FFT for example cells

exCells = [232 622 1855];
cellsToPlot = find(ismember(cellsIdx, exCells));  


figure
for k = 1:numel(cellsToPlot)
    ic = cellsToPlot(k);    
    RF = squeeze(data_all(ic,:,:));
    RF_dog = squeeze(data_DoG_all(ic,:,:));

    subplot(6,3,k)
        imagesc(RF_dog); colormap(gca, 'gray'); clim([-5 5]); pbaspect([16 9 1]); axis off; box off
    subplot(6,3,k+length(cellsToPlot))
        plotRF_FFT(RF_dog, xgrid, ygrid, 'SF', SF, 'prefOri', PO_dog_fft(ic), 'title', sprintf('cell %d', cellsIdx(ic))); colormap(gca, 'parula'); axis off; axis square
    subplot(6,3,k+(length(cellsToPlot)*2))
        imagesc(RF); colormap(gca, 'gray'); clim([-5 5]); pbaspect([16 9 1]); axis off; box off
    subplot(6,3,k+(length(cellsToPlot)*3))
        plotRF_FFT(RF, xgrid, ygrid, 'SF', SF, 'prefOri', PO_dog_fft(ic), 'title', sprintf('cell %d', cellsIdx(ic))); colormap(gca, 'parula'); axis off; axis square
    subplot(6,3,k+(length(cellsToPlot)*4))
        plot(1:360,dir_yfit_all(:,k)); hold on
        plot(stimDirs,avg_resp_dir_all(exCells(k),:,1,1,1)) 
        subtitle('blue - VM fit, orange - spk data')
        set(gca,'TickDir','out'); box off; axis square
    subplot(6,3,k+(length(cellsToPlot)*5))
        plot(1:180,dog_fft_tuning(ic,:))
        set(gca,'TickDir','out'); box off; axis square
        subtitle(['Pref ori spk ' num2str(PO_vm(cellsIdx(ic))) ', Pref ori fft ' num2str(PO_fftAll(ic))])
        xlim([0 400])
end

print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_exampleCells_STAffts.pdf'), '-dpdf', '-bestfit')

%% estimate plaid mod from FFT
% In a purely linear F1 model, the depth of modulation over a full 360° 
% phase sweep depends only on the balance of the two component amplitudes. 
% The max is A1+A2, the min is |A1−A2|, so depth is min/max. The phase 
% ∠G1−∠G2 only sets where the peak falls.
% 
% Unmodulated cells will mostly be cells where one component sits far down 
% the orientation or SF tuning curve (dominant component, little 
% interference) or cells weakly driven by both. Fig 4 and the printed table 
% separate these.

% Print STA time point choices
pdfDir = fullfile(dirBase, 'sara', 'Analysis', 'Neuropixel','CrossOri','randDirFourPhase','mouse_RFs');
if ~exist(pdfDir, 'dir'); mkdir(pdfDir); end

pdfFile = fullfile(pdfDir, 'spatialRFs_FFTanalysis_plaidModulation.pdf');
if isfile(pdfFile); delete(pdfFile); end

modDepth_all=[];
plaidAmp_all=[];
doPlot = 1;
for ic = 1:size(data_all,1)
    prefDir     = dirs(indDir(ic));    % actual direction in degrees, 0-330
    RF          = medfilt2(imgaussfilt(squeeze(data_all(ic,:,:)),1));
    RF_dog      = squeeze(data_DoG_all(ic,:,:));
    prefOri     = PO_vm(cellsIdx(ic));
    opts = struct('prefOri', prefOri);
    [peakPhase, A1, A2, dirs, Fsamp, AplaidPrefOri, S] = estimatePlaidModFromFFT(RF_dog, xgrid, ygrid, SF, [], [], [], doPlot, opts);
    modDepth_all(ic,:) = modDepth;
    plaidAmp_all(ic,:) = AplaidPrefOri;
    % sgtitle(['cell ' num2str(cellsIdx(ic))', cellsIdx(' num2str(ic) ')']);
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);
    close(gcf)
end


stimDirs = 0:30:330;
y_fits = zeros(360,length(cellsToPlot));
dirs = deg2rad(0:1:359);
for ic = 1:length(cellsToPlot)
    iCell = exCells(ic);
    [b_hat_all(ic,1), k1_hat_all(ic,1), R1_hat_all(ic,1), R2_hat_all(ic,1), u1_hat_all(ic,1), u2_hat_all(ic,1), sse_all(ic,1),R_square_all(ic,1)] = miaovonmisesfit_dir(deg2rad(stimDirs),avg_resp_dir_all(iCell,:,1,1,1));
    dir_yfit_all(:,ic) = b_hat_all(ic,1)+R1_hat_all(ic,1).*exp(k1_hat_all(ic,1).*(cos(dirs-u1_hat_all(ic,1))-1))+R2_hat_all(ic,1).*exp(k1_hat_all(ic,1).*(cos(dirs-u1_hat_all(ic,1))-1));
end



% Fit plaid amplitude as a function of phase
    phaseOffsets = [0 90 180 270];
    phaseRad = deg2rad(phaseOffsets);
    
    nCells = length(cellsIdx);
    phaseFine = deg2rad(0:1:359);
    
    plaidAmp_fit_all = nan(360, nCells);
    b_plaid_all  = nan(nCells,1);
    R_plaid_all  = nan(nCells,1);
    phi_plaid_all = nan(nCells,1);
    sse_plaid_all = nan(nCells,1);
    R2_plaid_all  = nan(nCells,1);
    
    for ic = 1:nCells
        iCell = ic;
        y = plaidAmp_all(iCell,:);
        % Fit a sinusoid: baseline + cosine modulation.
        X = [ones(numel(phaseRad),1), cos(phaseRad(:)), sin(phaseRad(:))];
        beta = X \ y(:);
        b_plaid_all(ic) = beta(1);
    
        % Amplitude and preferred phase of the fitted sinusoid.
        R_plaid_all(ic) = hypot(beta(2), beta(3));
        phi_plaid_all(ic) = mod(atan2(-beta(3), beta(2)), 2*pi);
    
        % Fitted curve.
        plaidAmp_fit_all(:,ic) = beta(1) + beta(2)*cos(phaseFine(:)) + beta(3)*sin(phaseFine(:));
    
        % Goodness of fit.
        yhat = X*beta;
        sse_plaid_all(ic) = sum((y(:)-yhat).^2);
        sst = sum((y(:)-mean(y)).^2);
        if sst > 0
            R2_plaid_all(ic) = 1 - sse_plaid_all(ic)/sst;
        end
    end



% Find preferred grating direction and extract plaid responses
    phaseOffsets = [0 90 180 270];
    phaseRad = deg2rad(phaseOffsets);
    
    nCells = size(avg_resp_dir_all, 1);
    nDirs  = size(avg_resp_dir_all, 2);
    
    % Dimension 4: 1 = grating, 2 = plaid
    % Dimension 5: 1 = mean,  2 = std
    gratingRespDir = squeeze(avg_resp_dir_all(:,:,1,1,1));
    
    % Peak grating direction for each cell
    [peakGratingResp, prefDirIdx] = max(gratingRespDir, [], 2);
    
    % Actual preferred direction in degrees
    stimDirs = 0:30:330;
    prefDirDeg = stimDirs(prefDirIdx);
    
    % Extract the four plaid phase responses at that preferred direction
    spk_plaidAmp_all = nan(nCells, 4);
    for ic = 1:nCells
        spk_plaidAmp_all(ic,:) = squeeze(avg_resp_dir_all(ic, prefDirIdx(ic), :, 2, 1));
    end
    
    % Normalize plaid responses by each cell's peak grating response
    spk_plaidAmp_norm_all = spk_plaidAmp_all ./ peakGratingResp;

    % Fit plaid amplitude as a function of phase
        phaseFine = deg2rad(0:1:359);
        plaidAmp_fit_spk = nan(360, nCells);
        b_plaid_spk      = nan(nCells,1);
        R_plaid_spk      = nan(nCells,1);
        phi_plaid_spk    = nan(nCells,1);
        sse_plaid_spk    = nan(nCells,1);
        R2_plaid_spk     = nan(nCells,1);
        
        X = [ones(4,1), cos(phaseRad(:)), sin(phaseRad(:))];
        
        for ic = 1:nCells
            y = spk_plaidAmp_norm_all(ic,:).';
            % Fit baseline + first-harmonic cosine modulation
            beta = X \ y;
            b_plaid_spk(ic)   = beta(1);
            R_plaid_spk(ic)   = hypot(beta(2), beta(3));
            phi_plaid_spk(ic) = mod(atan2(-beta(3), beta(2)), 2*pi);
            % Fitted curve over 0-359 degrees
            plaidAmp_fit_spk(:,ic) = beta(1) + beta(2)*cos(phaseFine(:)) + beta(3)*sin(phaseFine(:));
            % Goodness of fit
            yhat = X * beta;
            sse_plaid_spk(ic) = sum((y-yhat).^2);
            sst = sum((y-mean(y)).^2);
            if sst > 0
                R2_plaid_spk(ic) = 1 - sse_plaid_spk(ic)/sst;
            end
        end









stop

figure;
    subplot 221
        scatter_reg(amp_all(cellsIdx),R_plaid_all)
        axis square; set(gca,'TickDir','out','FontSize',8)
        xlabel('Zp-Zc amplitude')
        ylabel('mod in plaid amp (PO FFT)')
        subtitle('modulation amplitude')
    subplot 222
        scatter_reg(R_plaid_spk(cellsIdx),R_plaid_all)
        axis square; set(gca,'TickDir','out','FontSize',8)
        xlabel('mod in plaid spk amp (PO spk)')
        ylabel('mod in plaid amp (PO FFT)')
        subtitle('modulation amplitude')
    subplot 223
        scatter_reg(b_all(cellsIdx),b_plaid_all)
        axis square; set(gca,'TickDir','out','FontSize',8)
        xlabel('Zp-Zc baseline')
        ylabel('plaid amp baseline(PO FFT)')
        subtitle('baseline')
    subplot 224
        scatter_reg(b_plaid_spk(cellsIdx),b_plaid_all)
        axis square; set(gca,'TickDir','out','FontSize',8)
        xlabel('plaid spk amp baseline (PO spk)')
        ylabel('plaid amp baseline (PO FFT)')
        subtitle('baseline')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_linearAmplitude.pdf'), '-dpdf', '-bestfit')




%%

figure;
    subplot(3,3,1)
        scatter_reg(offsetMag(indDoG)',Zc_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('offset')
    subplot(3,3,2)
        scatter_reg(offsetMag(indDoG)',Zp_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('offset')
    subplot(3,3,3)
        scatter_reg(dog_AR(indDoG)',Zc_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('aspect ratio (tau)')
    subplot(3,3,4)
        scatter_reg(dog_AR(indDoG)',Zp_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('aspect ratio (tau)')
    subplot(3,3,5)
        scatter_reg(dog_sizeC(indDoG)',Zc_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('size center')
    subplot(3,3,6)
        scatter_reg(dog_sizeC(indDoG)',Zp_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('size center')
    subplot(3,3,7)
        scatter_reg(dog_sizeS(indDoG)',Zc_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('size surround')
    subplot(3,3,8)
        scatter_reg(dog_sizeS(indDoG)',Zp_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('size surround')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary1.pdf'), '-dpdf', '-bestfit')

figure;
    subplot(4,3,1)
        scatter_reg(offsetMag(indDoG)',Zc_max,12)
        set(gca,'TickDir','out'); box off
        ylabel('max Zc'); ylim([-1 7])
        xlabel('offset')
    subplot(4,3,2)
        scatter_reg(offsetMag(indDoG)',Zp_max,12)
        set(gca,'TickDir','out'); box off
        ylabel('max Zp'); ylim([-1 7])
        xlabel('offset')
    subplot(4,3,3)
        scatter_reg(dog_AR(indDoG)',Zc_max,12)
        set(gca,'TickDir','out'); box off
        ylabel('meamaxn Zc'); ylim([-1 7])
        xlabel('aspect ratio (tau)')
    subplot(4,3,4)
        scatter_reg(dog_AR(indDoG)',Zp_max,12)
        set(gca,'TickDir','out'); box off
        ylabel('max Zp'); ylim([-1 7])
        xlabel('aspect ratio (tau)')
    subplot(4,3,5)
        scatter_reg(dog_sizeC(indDoG)',Zc_max,12)
        set(gca,'TickDir','out'); box off
        ylabel('max Zc'); ylim([-1 7])
        xlabel('size center')
    subplot(4,3,6)
        scatter_reg(dog_sizeC(indDoG)',Zp_max,12)
        set(gca,'TickDir','out'); box off
        ylabel('max Zp'); ylim([-1 7])
        xlabel('size center')
    subplot(4,3,7)
        scatter_reg(dog_sizeS(indDoG)',Zc_max,12)
        set(gca,'TickDir','out'); box off
        ylabel('max Zc'); ylim([-1 7])
        xlabel('size surround')
    subplot(4,3,8)
        scatter_reg(dog_sizeS(indDoG)',Zp_max,12)
        set(gca,'TickDir','out'); box off
        ylabel('max Zp'); ylim([-1 7])
        xlabel('size surround')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary2.pdf'), '-dpdf', '-bestfit')

figure;
    subplot(3,3,1)
        scatter_reg(offsetMag(indDoG)',baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('offset')
    subplot(3,3,2)
        scatter_reg(offsetMag(indDoG)',amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('offset')
    subplot(3,3,3)
        scatter_reg(dog_AR(indDoG)',baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('aspect ratio (tau)')
    subplot(3,3,4)
        scatter_reg(dog_AR(indDoG)',amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude');
        xlabel('aspect ratio (tau)')
    subplot(3,3,5)
        scatter_reg(dog_sizeC(indDoG)',baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('size center')
    subplot(3,3,6)
        scatter_reg(dog_sizeC(indDoG)',amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('size center')
    subplot(3,3,7)
        scatter_reg(dog_sizeS(indDoG)',baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('size surround')
    subplot(3,3,8)
        scatter_reg(dog_sizeS(indDoG)',amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('size surround')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary3.pdf'), '-dpdf', '-bestfit')



% COLOR CODE by STA FFT OSI at 0.05 SF
figure;
    subplot(4,3,1)
        scatter_reg(offsetMag(indDoG)',Zc_avg,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('offset')
    subplot(4,3,2)
        scatter_reg(offsetMag(indDoG)',Zp_avg,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('offset')
    subplot(4,3,3)
        scatter_reg(dog_AR(indDoG)',Zc_avg,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('aspect ratio (tau)')
    subplot(4,3,4)
        scatter_reg(dog_AR(indDoG)',Zp_avg,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('aspect ratio (tau)')
    subplot(4,3,5)
        scatter_reg(dog_sizeC(indDoG)',Zc_avg,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('size center')
    subplot(4,3,6)
        scatter_reg(dog_sizeC(indDoG)',Zp_avg,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('size center')
    subplot(4,3,7)
        scatter_reg(dog_sizeS(indDoG)',Zc_avg,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('size surround')
    subplot(4,3,8)
        scatter_reg(dog_sizeS(indDoG)',Zp_avg,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('size surround')
sgtitle('color code by gOSI (STA FFT @ 0.05 SF)')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary1_colorOSI_fft.pdf'), '-dpdf', '-bestfit')

figure;
    subplot(4,3,1)
        scatter_reg(offsetMag(indDoG)',Zc_max,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('max Zc'); ylim([-1 7])
        xlabel('offset')
    subplot(4,3,2)
        scatter_reg(offsetMag(indDoG)',Zp_max,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('max Zp'); ylim([-1 7])
        xlabel('offset')
    subplot(4,3,3)
        scatter_reg(dog_AR(indDoG)',Zc_max,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('meamaxn Zc'); ylim([-1 7])
        xlabel('aspect ratio (tau)')
    subplot(4,3,4)
        scatter_reg(dog_AR(indDoG)',Zp_max,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('max Zp'); ylim([-1 7])
        xlabel('aspect ratio (tau)')
    subplot(4,3,5)
        scatter_reg(dog_sizeC(indDoG)',Zc_max,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('max Zc'); ylim([-1 7])
        xlabel('size center')
    subplot(4,3,6)
        scatter_reg(dog_sizeC(indDoG)',Zp_max,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('max Zp'); ylim([-1 7])
        xlabel('size center')
    subplot(4,3,7)
        scatter_reg(dog_sizeS(indDoG)',Zc_max,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('max Zc'); ylim([-1 7])
        xlabel('size surround')
    subplot(4,3,8)
        scatter_reg(dog_sizeS(indDoG)',Zp_max,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('max Zp'); ylim([-1 7])
        xlabel('size surround')
sgtitle('color code by gOSI (STA FFT @ 0.05 SF)')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary2_colorOSI_fft.pdf'), '-dpdf', '-bestfit')

figure;
    subplot(4,3,1)
        scatter_reg(offsetMag(indDoG)',baseline,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('offset')
    subplot(4,3,2)
        scatter_reg(offsetMag(indDoG)',amplitude,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('offset')
    subplot(4,3,3)
        scatter_reg(dog_AR(indDoG)',baseline,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('aspect ratio (tau)')
    subplot(4,3,4)
        scatter_reg(dog_AR(indDoG)',amplitude,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('amplitude');
        xlabel('aspect ratio (tau)')
    subplot(4,3,5)
        scatter_reg(dog_sizeC(indDoG)',baseline,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('size center')
    subplot(4,3,6)
        scatter_reg(dog_sizeC(indDoG)',amplitude,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('size center')
    subplot(4,3,7)
        scatter_reg(dog_sizeS(indDoG)',baseline,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('size surround')
    subplot(4,3,8)
        scatter_reg(dog_sizeS(indDoG)',amplitude,12,OSI_fft(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('size surround')
sgtitle('color code by gOSI (STA FFT @ 0.05 SF)')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary3_colorOSI_fft.pdf'), '-dpdf', '-bestfit')


% COLOR CODE by spiking OSI
figure;
    subplot(4,3,1)
        scatter_reg(offsetMag(indDoG)',Zc_avg,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('offset')
    subplot(4,3,2)
        scatter_reg(offsetMag(indDoG)',Zp_avg,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('offset')
    subplot(4,3,3)
        scatter_reg(dog_AR(indDoG)',Zc_avg,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('aspect ratio (tau)')
    subplot(4,3,4)
        scatter_reg(dog_AR(indDoG)',Zp_avg,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('aspect ratio (tau)')
    subplot(4,3,5)
        scatter_reg(dog_sizeC(indDoG)',Zc_avg,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('size center')
    subplot(4,3,6)
        scatter_reg(dog_sizeC(indDoG)',Zp_avg,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('size center')
    subplot(4,3,7)
        scatter_reg(dog_sizeS(indDoG)',Zc_avg,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('size surround')
    subplot(4,3,8)
        scatter_reg(dog_sizeS(indDoG)',Zp_avg,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('size surround')
sgtitle('color code by gOSI (spiking)')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary1_colorOSI.pdf'), '-dpdf', '-bestfit')

figure;
    subplot(4,3,1)
        scatter_reg(offsetMag(indDoG)',Zc_max,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('max Zc'); ylim([-1 7])
        xlabel('offset')
    subplot(4,3,2)
        scatter_reg(offsetMag(indDoG)',Zp_max,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('max Zp'); ylim([-1 7])
        xlabel('offset')
    subplot(4,3,3)
        scatter_reg(dog_AR(indDoG)',Zc_max,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('meamaxn Zc'); ylim([-1 7])
        xlabel('aspect ratio (tau)')
    subplot(4,3,4)
        scatter_reg(dog_AR(indDoG)',Zp_max,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('max Zp'); ylim([-1 7])
        xlabel('aspect ratio (tau)')
    subplot(4,3,5)
        scatter_reg(dog_sizeC(indDoG)',Zc_max,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('max Zc'); ylim([-1 7])
        xlabel('size center')
    subplot(4,3,6)
        scatter_reg(dog_sizeC(indDoG)',Zp_max,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('max Zp'); ylim([-1 7])
        xlabel('size center')
    subplot(4,3,7)
        scatter_reg(dog_sizeS(indDoG)',Zc_max,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('max Zc'); ylim([-1 7])
        xlabel('size surround')
    subplot(4,3,8)
        scatter_reg(dog_sizeS(indDoG)',Zp_max,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('max Zp'); ylim([-1 7])
        xlabel('size surround')
sgtitle('color code by gOSI (spiking)')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary2_colorOSI.pdf'), '-dpdf', '-bestfit')

figure;
    subplot(4,3,1)
        scatter_reg(offsetMag(indDoG)',baseline,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('offset')
    subplot(4,3,2)
        scatter_reg(offsetMag(indDoG)',amplitude,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('offset')
    subplot(4,3,3)
        scatter_reg(dog_AR(indDoG)',baseline,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('aspect ratio (tau)')
    subplot(4,3,4)
        scatter_reg(dog_AR(indDoG)',amplitude,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude');
        xlabel('aspect ratio (tau)')
    subplot(4,3,5)
        scatter_reg(dog_sizeC(indDoG)',baseline,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('size center')
    subplot(4,3,6)
        scatter_reg(dog_sizeC(indDoG)',amplitude,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('size center')
    subplot(4,3,7)
        scatter_reg(dog_sizeS(indDoG)',baseline,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('size surround')
    subplot(4,3,8)
        scatter_reg(dog_sizeS(indDoG)',amplitude,12,gOSI_toplot)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('size surround')
sgtitle('color code by gOSI (spiking)')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary3_colorOSI.pdf'), '-dpdf', '-bestfit')




%% STA FFT plots




figure;
    subplot(3,3,1)
        scatter_reg(phaseCoh(indDoG),baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('phaseCoh')
    subplot(3,3,2)
        scatter_reg(phaseCoh(indDoG),amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('phaseCoh')
    subplot(3,3,3)
        scatter_reg(phaseCoh_fft(indDoG),baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('phaseCoh POfft')
    subplot(3,3,4)
        scatter_reg(phaseCoh_fft(indDoG),amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('phaseCoh POfft')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary_phaseCoh.pdf'), '-dpdf', '-bestfit')

[pc_vals, pc_ind] = sort(phaseCoh_fft);









figure;
    subplot(4,3,1)
        scatter_reg(OSI_fftAll(indDoG),baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('gOSI fft (pref SF)')
    subplot(4,3,2)
        scatter_reg(OSI_fftAll(indDoG),amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('gOSI fft (pref SF)')
    subplot(4,3,3)
        scatter_reg(OSI_fftAll(indDoG),Zc_avg,12)
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zc avg'); 
        xlabel('gOSI fft (spiking)')
    subplot(4,3,4)
        scatter_reg(OSI_fftAll(indDoG),Zp_avg,12)
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zp avg'); 
        xlabel('gOSI fft (spiking)')
    subplot(4,3,5)
        scatter_reg(OSI_fftAll(indDoG),Zc_max,12)
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zc max'); 
        xlabel('gOSI fft (pref SF)')
    subplot(4,3,6)
        scatter_reg(OSI_fftAll(indDoG),Zp_max,12)
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zp max'); 
        xlabel('gOSI fft (pref SF)')

    subplot(4,3,7)
        scatter_reg(OSI_fft(indDoG),baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('gOSI fft (at SF 0.05)')
    subplot(4,3,8)
        scatter_reg(OSI_fft(indDoG),amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('gOSI fft (at SF 0.05)')
    subplot(4,3,9)
        scatter_reg(OSI_fft(indDoG),Zc_avg,12)
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zc avg'); 
        xlabel('gOSI fft (at SF 0.05)')
    subplot(4,3,10)
        scatter_reg(OSI_fft(indDoG),Zp_avg,12)
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zp avg'); 
        xlabel('gOSI fft (at SF 0.05)')
    subplot(4,3,11)
        scatter_reg(OSI_fft(indDoG),Zc_max,12)
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zc max'); 
        xlabel('gOSI fft (at SF 0.05)')
    subplot(4,3,12)
        scatter_reg(OSI_fft(indDoG),Zp_max,12)
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zp max'); 
        xlabel('gOSI fft (at SF 0.05)')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary4.pdf'), '-dpdf', '-bestfit')


figure;
    subplot(3,3,1)
        scatter_reg(gOSI_toplot,baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('gOSI (spiking)')
        xlim([0 1])
    subplot(3,3,2)
        scatter_reg(gOSI_toplot,amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('gOSI (spiking)')
        xlim([0 1])
    subplot(3,3,3)
        scatter_reg(gOSI_toplot,Zc_avg,12)
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zc avg'); 
        xlabel('gOSI (spiking)')
        xlim([0 1])
    subplot(3,3,4)
        scatter_reg(gOSI_toplot,Zp_avg,12)
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zp avg'); 
        xlabel('gOSI (spiking)')
        xlim([0 1])
    subplot(3,3,5)
        scatter_reg(gOSI_toplot,Zc_max,12)
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zc max'); 
        xlabel('gOSI (spiking)')
        xlim([0 1])
    subplot(3,3,6)
        scatter_reg(gOSI_toplot,Zp_max,12)
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zp max'); 
        xlabel('gOSI (spiking)')
        xlim([0 1])
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary5.pdf'), '-dpdf', '-bestfit')


figure;
    subplot(4,3,1)
        scatter_reg(OSI_fftAll(indDoG),baseline,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('gOSI fft (pref SF)')
    subplot(4,3,2)
        scatter_reg(OSI_fftAll(indDoG),amplitude,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('gOSI fft (pref SF)')
    subplot(4,3,3)
        scatter_reg(OSI_fftAll(indDoG),Zc_avg,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zc avg'); 
        xlabel('gOSI fft (pref SF)')
    subplot(4,3,4)
        scatter_reg(OSI_fftAll(indDoG),Zp_avg,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zp avg'); 
        xlabel('gOSI fft (pref SF)')
    subplot(4,3,5)
        scatter_reg(OSI_fftAll(indDoG),Zc_max,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zc max'); 
        xlabel('gOSI fft (pref SF)')
    subplot(4,3,6)
        scatter_reg(OSI_fftAll(indDoG),Zp_max,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zp max'); 
        xlabel('gOSI fft (pref SF)')

    subplot(4,3,7)
        scatter_reg(OSI_fft(indDoG),baseline,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('gOSI fft (at SF 0.05)')
    subplot(4,3,8)
        scatter_reg(OSI_fft(indDoG),amplitude,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('gOSI fft (at SF 0.05)')
    subplot(4,3,9)
        scatter_reg(OSI_fft(indDoG),Zc_avg,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zc avg'); 
        xlabel('gOSI fft (at SF 0.05)')
    subplot(4,3,10)
        scatter_reg(OSI_fft(indDoG),Zp_avg,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zp avg'); 
        xlabel('OSI fft (at SF 0.05)')
    subplot(4,3,11)
        scatter_reg(OSI_fft(indDoG),Zc_max,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zc max'); 
        xlabel('OSI fft (at SF 0.05)')
    subplot(4,3,12)
        scatter_reg(OSI_fft(indDoG),Zp_max,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zp max'); 
        xlabel('gOSI fft (at SF 0.05)')
sgtitle('color code by preferred SF (from FFT of STA)')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary4_colorPrefSF.pdf'), '-dpdf', '-bestfit')


figure;
    subplot(4,3,1)
        scatter_reg(gOSI_toplot,baseline,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('gOSI (spiking)')
    subplot(4,3,2)
        scatter_reg(gOSI_toplot,amplitude,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('gOSI (spiking)')
    subplot(4,3,3)
        scatter_reg(gOSI_toplot,Zc_avg,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zc avg'); 
        xlabel('gOSI (spiking)')
    subplot(4,3,4)
        scatter_reg(gOSI_toplot,Zp_avg,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zp avg'); 
        xlabel('gOSI (spiking)')
    subplot(4,3,5)
        scatter_reg(gOSI_toplot,Zc_max,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zc max'); 
        xlabel('gOSI (spiking)')
    subplot(4,3,6)
        scatter_reg(gOSI_toplot,Zp_max,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zp max'); 
        xlabel('gOSI (spiking)')
sgtitle('color code by preferred SF (from FFT of STA)')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary5_colorPrefSF.pdf'), '-dpdf', '-bestfit')


%% DoG Fit FFT



figure;
    subplot(3,3,1)
        scatter_reg(OSI_dog_fftAll(indDoG),baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('dog gOSI fft (pref SF)')
    subplot(3,3,2)
        scatter_reg(OSI_dog_fftAll(indDoG),amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('dog gOSI fft (pref SF)')
    subplot(3,3,3)
        scatter_reg(OSI_dog_fftAll(indDoG),Zc_avg,12)
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zc avg'); 
        xlabel('dog gOSI fft (pref SF)')
    subplot(3,3,4)
        scatter_reg(OSI_dog_fftAll(indDoG),Zp_avg,12)
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zp avg'); 
        xlabel('dog gOSI fft (pref SF)')
    subplot(3,3,5)
        scatter_reg(OSI_dog_fftAll(indDoG),Zc_max,12)
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zc max'); 
        xlabel('dog gOSI fft (pref SF)')
    subplot(3,3,6)
        scatter_reg(OSI_dog_fftAll(indDoG),Zp_max,12)
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zp max'); 
        xlabel('dog gOSI fft (pref SF)')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary7.pdf'), '-dpdf', '-bestfit')

figure;
    subplot(3,3,1)
        scatter_reg(OSI_dog_fft(indDoG),baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('dog gOSI fft (at SF 0.05)')
        xlim([0 1])
    subplot(3,3,2)
        scatter_reg(OSI_dog_fft(indDoG),amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('dog OSI fft (at SF 0.05)')
        xlim([0 1])
    subplot(3,3,3)
        scatter_reg(OSI_dog_fft(indDoG),Zc_avg,12)
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zc avg'); 
        xlabel('dog gOSI fft (at SF 0.05)')
        xlim([0 1])
    subplot(3,3,4)
        scatter_reg(OSI_dog_fft(indDoG),Zp_avg,12)
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zp avg'); 
        xlabel('dog gOSI fft (at SF 0.05)')
        xlim([0 1])
    subplot(3,3,5)
        scatter_reg(OSI_dog_fft(indDoG),Zc_max,12)
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zc max'); 
        xlabel('dog gOSI fft (at SF 0.05)')
        xlim([0 1])
    subplot(3,3,6)
        scatter_reg(OSI_dog_fft(indDoG),Zp_max,12)
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zp max'); 
        xlabel('dog gOSI fft (at SF 0.05)')
        xlim([0 1])
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary6.pdf'), '-dpdf', '-bestfit')


figure;
    subplot(4,3,1)
        scatter_reg(OSI_dog_fftAll(indDoG),baseline,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('dog gOSI fft (pref SF)')
    subplot(4,3,2)
        scatter_reg(OSI_dog_fftAll(indDoG),amplitude,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('dog gOSI fft (pref SF)')
    subplot(4,3,3)
        scatter_reg(OSI_dog_fftAll(indDoG),Zc_avg,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zc avg'); 
        xlabel('dog gOSI fft (pref SF)')
    subplot(4,3,4)
        scatter_reg(OSI_dog_fftAll(indDoG),Zp_avg,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zp avg'); 
        xlabel('dog gOSI fft (pref SF)')
    subplot(4,3,5)
        scatter_reg(OSI_dog_fftAll(indDoG),Zc_max,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zc max'); 
        xlabel('dog gOSI fft (pref SF)')
    subplot(4,3,6)
        scatter_reg(OSI_dog_fftAll(indDoG),Zp_max,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zp max'); 
        xlabel('dog gOSI fft (pref SF)')

    subplot(4,3,7)
        scatter_reg(OSI_dog_fft(indDoG),baseline,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('dog gOSI fft (at SF 0.05)')
    subplot(4,3,8)
        scatter_reg(OSI_dog_fft(indDoG),amplitude,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('dog gOSI fft (at SF 0.05)')
    subplot(4,3,9)
        scatter_reg(OSI_dog_fft(indDoG),Zc_avg,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zc avg'); 
        xlabel('dog gOSI fft (at SF 0.05)')
    subplot(4,3,10)
        scatter_reg(OSI_dog_fft(indDoG),Zp_avg,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-2 6])
        ylabel('Zp avg'); 
        xlabel('dog gOSI fft (at SF 0.05)')
    subplot(4,3,11)
        scatter_reg(OSI_dog_fft(indDoG),Zc_max,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zc max'); 
        xlabel('dog gOSI fft (at SF 0.05)')
    subplot(4,3,12)
        scatter_reg(OSI_dog_fft(indDoG),Zp_max,12,prefSF(indDoG))
        set(gca,'TickDir','out'); box off; ylim([-1 7])
        ylabel('Zp max'); 
        xlabel('dog gOSI fft (at SF 0.05)')
sgtitle('color code by preferred SF (from FFT of DoG)')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary6_colorPrefSF.pdf'), '-dpdf', '-bestfit')





%%

stop

% fprintf('Saving output... \n')
% 
% save( ...
%     fullfile( ...
%         dirBase, ...
%         exptStruct.loc, ...
%         'Analysis', ...
%         'Neuropixel', ...
%         exptStruct.date, ...
%         'spatialRFs_heldOut', ...
%         [mouse '-' date '_heldOut_correlations.mat']), ...
%     'runloc', ...
%     'cellsIdx', ...
%     'corr_full', ... % correlations
%     'corr_HO', ... % correlations, held out trials
%     'mNames', ...  % model names
%     'nChunks', ...
%     'its', ...
%     'spkCounts', ...
%     'heldOutMask', ...
%     'STA_for_fitting_all', ...
%     'results_full', ...
%     'results_HO', ...
%     'dog_fits_Uncropped', ...
%     'gabor_fits_Uncropped', ...
%     'gaus_fits_Uncropped', ...
%     'zscoreSTAs_all');
% 
% 
% fprintf(['Process done. Output saved in... \n' exptStruct.loc '\\Analysis\\Neuropixel\\' exptStruct.date '\\spatialRFs_heldOut\\' mouse '-' date '_heldOut_correlations.mat'])
% fprintf('\n')

%% 




ZcAvg_all = mean(Zc_all,1);
ZpAvg_all = mean(Zp_all,1);

ZcNeg = find(ZcAvg_all<0);
ZpNeg = find(ZpAvg_all<0);
badzoneNicholas = intersect(ZcNeg, ZpNeg);

figure;
      ind_use = intersect(resp_ind_dir_all,find(~isnan(layer_all)));  


maxGratResp

    ind_use = intersect(resp_ind_dir_all,find(~isnan(layer_all)));




badMouse = intersect(badzoneNicholas,ind_mouseEphys);





