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
    
        dog_sizeC(i) = sqrt(sigma_x * sigma_y); % center size
        dog_sizeS(i) = sigmaS / sqrt(tau); % surround size
    end


%%

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

Zc_avg = mean(Zc_all(:, cellsIdx_final),1);
Zp_avg = mean(Zp_all(:, cellsIdx_final),1);
Zc_max = max(Zc_all(:, cellsIdx_final),[],1);
Zp_max = max(Zp_all(:, cellsIdx_final),[],1);

baseline = b_all(cellsIdx_final)';
amplitude = amp_all(cellsIdx_final)';

indDoG = ~ismember(cellsIdx,omitCells);

% cell1 = find(cellsIdx==1015);
% cell2 = find(cellsIdx==1438);
% 
% offsetMag(cell1) = 0;
% offsetMag(cell2) = 0;

%%

figure;
    subplot(4,3,1)
        scatter_reg(offsetMag(indDoG)',Zc_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('offset')
    subplot(4,3,2)
        scatter_reg(offsetMag(indDoG)',Zp_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('offset')
    subplot(4,3,3)
        scatter_reg(dog_AR(indDoG)',Zc_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('aspect ratio (tau)')
    subplot(4,3,4)
        scatter_reg(dog_AR(indDoG)',Zp_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('aspect ratio (tau)')
    subplot(4,3,5)
        scatter_reg(dog_sizeC(indDoG)',Zc_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('size center')
    subplot(4,3,6)
        scatter_reg(dog_sizeC(indDoG)',Zp_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-2 6])
        xlabel('size center')
    subplot(4,3,7)
        scatter_reg(dog_sizeS(indDoG)',Zc_avg,12)
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-2 6])
        xlabel('size surround')
    subplot(4,3,8)
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
    subplot(4,3,1)
        scatter_reg(offsetMag(indDoG)',baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('offset')
    subplot(4,3,2)
        scatter_reg(offsetMag(indDoG)',amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('offset')
    subplot(4,3,3)
        scatter_reg(dog_AR(indDoG)',baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('aspect ratio (tau)')
    subplot(4,3,4)
        scatter_reg(dog_AR(indDoG)',amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude');
        xlabel('aspect ratio (tau)')
    subplot(4,3,5)
        scatter_reg(dog_sizeC(indDoG)',baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('size center')
    subplot(4,3,6)
        scatter_reg(dog_sizeC(indDoG)',amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('size center')
    subplot(4,3,7)
        scatter_reg(dog_sizeS(indDoG)',baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('size surround')
    subplot(4,3,8)
        scatter_reg(dog_sizeS(indDoG)',amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('size surround')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary3.pdf'), '-dpdf', '-bestfit')





%%

for ic = 1:nSelected
    prefDir     = dirs(indDir(ic));    % actual direction in degrees, 0-330
    RF          = squeeze(data_all(ic,:,:));
    ygrid       = ((1:29) - 14.5) * 2;   % 29 points, centered, spanning -28 to +28 deg
    xgrid       = ((1:52) - 26) * 2; % 52 points, centered, spanning -51 to +51 deg
    PO(ic)      = mod(prefDir, 180);   % preferred orientation
    PO_fft(ic)  = estimatePOfromFFT(RF, xgrid, ygrid);
    SF          = 0.05; % plaid grating's spatial frequency
    beta        = 60; % half the angle between the two plaid components
    
    phaseCoh(ic) = estimatePhaseCoherence(RF, xgrid, ygrid, PO(ic), SF, beta);
    phaseCoh_fft(ic) = estimatePhaseCoherence(RF, xgrid, ygrid, PO_fft(ic), SF, beta);
end

figure;
scatter_reg(PO(indDoG),PO_fft(indDoG))


% 
% 
% figure;
%     subplot(4,4,1)
%         scatter_reg(phaseCoh(indDoG),baseline,12)
%         set(gca,'TickDir','out'); box off
%         ylabel('baseline'); 
%         xlabel('phaseCoh')
%     subplot(4,4,2)
%         scatter_reg(phaseCoh(indDoG),amplitude,12)
%         set(gca,'TickDir','out'); box off
%         ylabel('amplitude'); 
%         xlabel('phaseCoh')
%     subplot(4,4,3)
%         scatter_reg(phaseCoh_fft(indDoG),baseline,12)
%         set(gca,'TickDir','out'); box off
%         ylabel('baseline'); 
%         xlabel('phaseCoh POfft')
%     subplot(4,4,4)
%         scatter_reg(phaseCoh_fft(indDoG),amplitude,12)
%         set(gca,'TickDir','out'); box off
%         ylabel('amplitude'); 
%         xlabel('phaseCoh POfft')



figure;
    subplot(4,3,1)
        scatter_reg(offsetMag(indDoG)',baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('offset')
    subplot(4,3,2)
        scatter_reg(offsetMag(indDoG)',amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('offset')
    subplot(4,3,3)
        scatter_reg(dog_AR(indDoG)',baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('aspect ratio (tau)')
    subplot(4,3,4)
        scatter_reg(dog_AR(indDoG)',amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude');
        xlabel('aspect ratio (tau)')
    subplot(4,3,5)
        scatter_reg(dog_sizeC(indDoG)',baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('size center')
    subplot(4,3,6)
        scatter_reg(dog_sizeC(indDoG)',amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('size center')
    subplot(4,3,7)
        scatter_reg(dog_sizeS(indDoG)',baseline,12)
        set(gca,'TickDir','out'); box off
        ylabel('baseline'); 
        xlabel('size surround')
    subplot(4,3,8)
        scatter_reg(dog_sizeS(indDoG)',amplitude,12)
        set(gca,'TickDir','out'); box off
        ylabel('amplitude'); 
        xlabel('size surround')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','mouse_RFs', 'spatialRFs_zscore_DoGfits_summary3.pdf'), '-dpdf', '-bestfit')






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


