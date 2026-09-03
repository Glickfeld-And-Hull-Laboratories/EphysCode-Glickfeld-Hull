%%
% This takes ~7h to run for all 15 experiments (100 cells) for 5 chunks
clear all; close all; clc

exptsToRun  = [1:15];
exptloc     = 'V1';
runloc      = 1;   % Where is this script being run? 1 == Hubel, 2 == Wiesel
nChunks     = 10;   % number of held-out segments, nChunks=10 is 10% held out
doCrop      = 1;


tic
for exptN = exptsToRun   % Choose experiment (1 through 15)

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

    iexp            = expts(exptN);
    nCells          = nCells_list(exptN);

    % make cellMap to find local index of the global index of all cells for each experiment
        allCells    = [0 cumsum(nCells_list)];
        cellMap     = cell(length(expts),1);
        for i = 1:length(expts)
            globalIdx   = (allCells(i)+1):allCells(i+1);
            localIdx    = 1:nCells_list(i);
            cellMap{i}  = [globalIdx(:), localIdx(:)];
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
        ind_DS      = intersect(idxInt,ind); % visually responsive and direction-selective

    % use visually responsive cells with DS > .5 and reliable RFs.
        cellsSelected = intersect(idxInt, ind_DS);

    % get cell lists for the current experiment
        expt_cellsIdx           = cellMap{exptN};
        expt_cellsIdx_global    = expt_cellsIdx(:,1);
        expt_cellsIdx_local     = expt_cellsIdx(:,2);
    % which of the cells for this experiment are in the variable cellsSelected?
        global_cellsIdx_bin = ismember(expt_cellsIdx_global,cellsSelected);
        cellsIdx            = expt_cellsIdx_local(global_cellsIdx_bin);
    % get held out data correlations
        getSpatialRF_HeldOut_Correlations(iexp, exptloc, runloc, cellsIdx, nChunks, doCrop)
        fprintf(['Completed expt ' num2str(exptN) '/' num2str(length(exptsToRun)) ' '])
end
toc


%% concatenate across experiments

zscoreSTAs_allExpts = [];
dog_fits_all        = [];
gabor_fits_all      = [];
gaus_fits_all       = [];
corr_HO_all   = struct('dog', [], 'gabor', [], 'gaus', []);
corr_full_all = struct('dog', [], 'gabor', [], 'gaus', []);
model_params = repmat({cell(0,1)}, 3, 1);   % one growing cell array per model

for exptN = 1:15   % Choose experiment(s) (1 through 15)

    exptloc     = 'V1';
    analysisDir = ('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
    load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])
    
    iexp        = expts(exptN);
    nCells      = nCells_list(exptN);
    
    [exptStruct] = createExptStruct(iexp,exptloc); % Load relevant times and directories for this experiment

    allCells    = [0 cumsum(nCells_list)];
    cellMap     = cell(length(expts),1);
    for i = 1:length(expts)
        globalIdx   = (allCells(i)+1):allCells(i+1);
        localIdx    = 1:nCells_list(i);
        cellMap{i}  = [globalIdx(:), localIdx(:)];
    end
    
    load(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs_heldOut\' exptStruct.mouse '-' exptStruct.date '_heldOut_correlations.mat'])
    zscoreSTAs_allExpts = [zscoreSTAs_allExpts, zscoreSTAs_all];

    dog_fits_all    = cat(3, dog_fits_all, dog_fits_Uncropped);
    gabor_fits_all  = cat(3, gabor_fits_all, gabor_fits_Uncropped);
    gaus_fits_all   = cat(3, gaus_fits_all, gaus_fits_Uncropped);

    flds = fieldnames(corr_HO);
    for k = 1:numel(flds)
        f = flds{k};
        corr_HO_all.(f)   = [corr_HO_all.(f);   corr_HO.(f)];
        corr_full_all.(f) = [corr_full_all.(f); corr_full.(f)];
    end

    % get model parameters for the full model
    m_params = [results_full.params];
    for m = 1:3
        model_params{m} = [model_params{m}; m_params{m}];
    end

end

%% get winning model for all cells

mNames   = {'dog','gabor','gaus'};
nParams  = struct('dog',10,'gabor',8,'gaus',7);
paramVec = [10 8 7];  % dog, gabor, gaus - matches column order below
nSelected = size(corr_HO_all.dog, 1);
nChunks   = size(corr_HO_all.dog, 2);
winCounts = zeros(nSelected, length(mNames));
maxValAllChunks = nan(nSelected, nChunks);  % <-- NEW: store per-chunk max (across models)

for ic = 1:nSelected
    for ih = 1:nChunks
        vals = [corr_HO_all.dog(ic,ih), corr_HO_all.gabor(ic,ih), corr_HO_all.gaus(ic,ih)];
        [maxVal, winnerIdx] = max(vals);
        maxValAllChunks(ic, ih) = maxVal; 

        % Find all models within epsilon of the max (candidate ties)
        tol = 0.05 * maxVal;
        tiedIdx = find(vals >= (maxVal - tol));

        if length(tiedIdx) > 1
            % Among tied models, pick the one with fewest params
            tiedParams = cellfun(@(m) nParams.(m), mNames(tiedIdx));
            [~, minParamLocalIdx] = min(tiedParams);
            winnerIdx = tiedIdx(minParamLocalIdx);
        end

        winCounts(ic, winnerIdx) = winCounts(ic, winnerIdx) + 1;
    end
end

winFractions = winCounts ./ sum(winCounts,2);
[maxFrac, winningModel] = max(winFractions, [], 2);

% break exact ties by lower param count
for ic = 1:size(winFractions,1)
    tiedIdx = find(winFractions(ic,:) == maxFrac(ic));
    if length(tiedIdx) > 1
        [~, minLocal] = min(paramVec(tiedIdx));
        winningModel(ic) = tiedIdx(minLocal);
    end
end


% maxVal for the winning model, averaged across chunks
maxVal_winningModel = nan(nSelected, 1);
for ic = 1:nSelected
    thisModelData = corr_HO_all.(mNames{winningModel(ic)})(ic, :);  % 1 x nChunks
    maxVal_winningModel(ic) = mean(thisModelData);
end

% maxVal averaged across all chunks and models
% (maxValAllChunks already took the max across models per chunk,
%  so averaging it across chunks gives the "best available model each
%  chunk, averaged over chunks" value)
maxVal_avgAcrossChunksAndModels = mean(maxValAllChunks, 2);

figure;
scatter(maxVal_winningModel,maxVal_avgAcrossChunksAndModels)

%% Determine winning model from one-standard-error (1-SE) rule, from the cross-validation model-selection literature (Hastie/Tibshirani/Friedman)
% choose the simplest model whose performance is not statistically distinguishable from the best model, 
% using the actual variability across your folds/chunks rather than an arbitrary % cutoff
%
% Steps per unit (ic):
% 1.  Fisher z-transform the correlations before averaging (raw correlations aren't additive/normally 
%     distributed).
% 2.  Compute mean and SEM of z-transformed correlation across chunks, for each model.
% 3.  Find the model with the max mean.
% 4.  Among models whose mean is within 1 SEM of that max, pick the one with fewest parameters.

mNames   = {'dog','gabor','gaus'};
nParams  = struct('dog',10,'gabor',8,'gaus',7);
paramVec = [10 8 7];  % dog, gabor, gaus - matches column order below

nSelected = size(corr_HO_all.dog, 1);

winningModel = zeros(nSelected,1);
for ic = 1:nSelected
    vals = [corr_HO_all.dog(ic,:); corr_HO_all.gabor(ic,:); corr_HO_all.gaus(ic,:)]'; % nChunks x 3

    % Fisher z-transform (clip to avoid atanh(+/-1) = Inf)
    z = atanh(max(min(vals, 0.999999), -0.999999));

    zMean = mean(z, 1);
    zSEM  = std(z, 0, 1) / sqrt(nChunks);

    [bestMean, bestIdx] = max(zMean);
    thresh = bestMean - zSEM(bestIdx);

    withinSE = find(zMean >= thresh);
    [~, minLocal] = min(paramVec(withinSE));
    winningModel(ic) = withinSE(minLocal);
end



%%

data_all                    =  zscoreSTAs_allExpts;
maxSmth = max(max(max(max(abs(data_all)))));

% Print STA time point choices
pdfDir = fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut');
if ~exist(pdfDir, 'dir'); mkdir(pdfDir); end

pdfFile = fullfile(pdfDir, 'spatialRFs_zscored_heldOut_withWinningFit.pdf');
if isfile(pdfFile); delete(pdfFile); end

for ic = 1:size(zscoreSTAs_allExpts,2)
    iCell = cellsSelected(ic);
    figure();
    sgtitle(['cell ' num2str(iCell) ', ic = ' num2str(ic)])
        data = medfilt2(imgaussfilt(squeeze(data_all(1,ic,:,:)),1));
        subplot(1,2,1)
            imagesc(data); hold on
            pbaspect([16 9 1])
            colormap(gray)
            clim([-5 5])
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            subtitle('STA')

    modelToPlot = winningModel(ic);
    if modelToPlot == 1
        data = squeeze(dog_fits_all(:,:,ic,1));
    elseif modelToPlot == 2
        data = squeeze(gabor_fits_all(:,:,ic,1));
    else
        data = squeeze(gaus_fits_all(:,:,ic,1));
    end
    
    subplot(1,2,2)
        imagesc(data); hold on
        subtitle(mNames{modelToPlot})
        pbaspect([16 9 1])
        colormap(gray)
        clim([-5 5])
        set(gca,'xtick',[]); set(gca,'xticklabel',[])
        set(gca,'ytick',[]); set(gca,'yticklabel',[])
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

dogFits_params = model_params{1};

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
        offsetMag(i)   = sqrt(dx.^2 + dy.^2) * 2;  % x2 to convert to degrees
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


% ---------------------
% Gabor params
    % 1         - Ac
    % 2         - (empty)
    % 3         - sigmax
    % 4         - (empty)
    % 5         - tau (sigmay/sigmax)
    % 6         - phi (unwrapped)
    % 7         - x0
    % 8         - y0
    % 9         - lambda
    % 10        - phase
    % 11, 12    - (empty)

gabFits_params = model_params{2};

% aspect ratio
    gabor_AR = nan(nSelected,1);
    for i = 1:nSelected
        p = gabFits_params{i};
        if isempty(p)
            continue
        end
        tau = p(5); 
        gabor_AR(i) = tau;
    end

% size
    gabor_size = nan(nSelected,1);
    for i = 1:nSelected
        p = gabFits_params{i};
        if isempty(p), continue; end
        sigmax = p(3);          % correct index
        tau    = p(5);          % tau = sigmay/sigmax (per this model's convention)
        sigmay = sigmax * tau;  % reconstruct actual sigmay
        gabor_size(i) = sqrt(sigmax * sigmay);   % = sigmax * sqrt(tau)
    end


% ---------------------
% 2D Gaussian
    % 1,        - ampltideu
    % 2         - sigma
    % 3         - tau 
    % 4         - theta
    % 5, 6      - x0, y0

gausFits_params = model_params{3};

% aspect ratio
    gaus_AR = nan(nSelected,1);
    for i = 1:nSelected
        p = gausFits_params{i};
        if isempty(p)
            continue
        end
        gaus_AR(i) = p(3);   % tau
    end

% size
    gaus_size = nan(nSelected,1);
    for i = 1:nSelected
        p = gausFits_params{i};
        if isempty(p), continue; end
        sigma = p(2);
        tau   = p(3);
        gaus_size(i) = sqrt(sigma * (sigma/tau));   % = sigma/sqrt(tau)
    end

% ---------------------



gabor_subunit_size = nan(nSelected,1);
gabor_subunit_AR   = nan(nSelected,1);
gabor_nSubunits    = nan(nSelected,1);

for i = 1:nSelected
    p = gabFits_params{i};
    if isempty(p), continue; end
    sigmax = p(3);
    tau    = p(5);
    theta  = p(6);      % ellipse tilt relative to wave (xip) axis
    lambda = p(9);      % already true wavelength in pixels
    sigmay = sigmax * tau;

    % ellipse radius along wave axis (xip) and orthogonal axis (yip)
    sigma_xip = 1 / sqrt( cos(theta)^2/sigmax^2 + sin(theta)^2/sigmay^2 );
    sigma_yip = 1 / sqrt( sin(theta)^2/sigmax^2 + cos(theta)^2/sigmay^2 );

    % shrink only the wave-axis sigma by the wavelength (curvature match)
    sigma_xip_subunit = 1 / sqrt( 1/sigma_xip^2 + (2*pi/lambda)^2 );
    sigma_yip_subunit = sigma_yip;   % unmodulated axis, unchanged

    gabor_subunit_size(i) = sqrt(sigma_xip_subunit * sigma_yip_subunit);
    gabor_subunit_AR(i)   = sigma_yip_subunit / sigma_xip_subunit;

    % continuous subunit count along the wave axis (half-wavelength spacing)
    gabor_nSubunits(i) = 4*sigma_xip / lambda;
end


%% Load Zp Zc data

doL4only = 1;

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

Zc_avg = mean(Zc_all(:, cellsSelected),1);
Zp_avg = mean(Zp_all(:, cellsSelected),1);

omitcells = [19 41 43 57 65 79 95];

L4_ind = find(layer_all(cellsSelected)==4);
if doL4only == 1
    indDoG = intersect(setdiff(find(winningModel==1),omitcells),L4_ind);
    indGab = intersect(setdiff(find(winningModel==2),omitcells),L4_ind);
    indGau = intersect(setdiff(find(winningModel==3),omitcells),L4_ind);
else
    indDoG = setdiff(find(winningModel==1),omitcells);
    indGab = setdiff(find(winningModel==2),omitcells);
    indGau = setdiff(find(winningModel==3),omitcells);
end

figure;
    sgtitle('DoG winners')
    subplot(4,2,1)
        scatter(offsetMag(indDoG),Zc_avg(indDoG),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('offset')
    subplot(4,2,2)
        scatter(offsetMag(indDoG),Zp_avg(indDoG),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('offset')
    subplot(4,2,3)
        scatter(dog_AR(indDoG),Zc_avg(indDoG),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('aspect ratio (tau)')
    subplot(4,2,4)
        scatter(dog_AR(indDoG),Zp_avg(indDoG),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('aspect ratio (tau)')
    subplot(4,2,5)
        scatter(dog_sizeC(indDoG),Zc_avg(indDoG),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('size center')
    subplot(4,2,6)
        scatter(dog_sizeC(indDoG),Zp_avg(indDoG),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('size center')
    subplot(4,2,7)
        scatter(dog_sizeS(indDoG),Zc_avg(indDoG),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('size surround')
        subtitle('DoG winners')
    subplot(4,2,8)
        scatter(dog_sizeS(indDoG),Zp_avg(indDoG),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('size surround')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_dog.pdf'), '-dpdf', '-bestfit')




figure;
    sgtitle('2D gaussian winners')
    subplot(4,2,1)
        scatter(gaus_AR(indGau),Zc_avg(indGau),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('aspect ratio (tau)'); %xlim([0 2.5])
    subplot(4,2,2)
        scatter(gaus_AR(indGau),Zp_avg(indGau),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('aspect ratio (tau)'); %xlim([0 2.5])
    subplot(4,2,3)
        scatter(gaus_size(indGau),Zc_avg(indGau),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('size'); 
    subplot(4,2,4)
        scatter(gaus_size(indGau),Zp_avg(indGau),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('size'); 
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_gauss.pdf'), '-dpdf', '-bestfit')



figure;
    sgtitle('Gabor winners')
    subplot(4,2,1)
        scatter(gabor_AR(indGab),Zc_avg(indGab),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('aspect ratio'); % xlim([0 2.5])
    subplot(4,2,2)
        scatter(gabor_AR(indGab),Zp_avg(indGab),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4]); % xlim([0 2.5])
        xlabel('aspect ratio')
    subplot(4,2,3)
        scatter(gabor_size(indGab),Zc_avg(indGab),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('size'); 
    subplot(4,2,4)
        scatter(gabor_size(indGab),Zp_avg(indGab),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('size')
    subplot(4,2,5)
        scatter(gabor_subunit_AR(indGab),Zc_avg(indGab),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('subunit aspect ratio'); % xlim([0 2.5])
    subplot(4,2,6)
        scatter(gabor_subunit_AR(indGab),Zp_avg(indGab),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4]); % xlim([0 2.5])
        xlabel('subunit aspect ratio')
    subplot(4,2,7)
        scatter(gabor_subunit_size(indGab),Zc_avg(indGab),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('subunit size'); 
    subplot(4,2,8)
        scatter(gabor_subunit_size(indGab),Zp_avg(indGab),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('subunit size')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_gabor.pdf'), '-dpdf','-bestfit')



%% plot STAs and fits


% DoG, offset x Zp, STAs
    figure;
        ax = axes;
        scatter(offsetMag(indDoG),Zp_avg(indDoG),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('offset')
        hold on
        axpos = ax.Position;   % position of main axes in figure
        for ic = 1:length(indDoG)
            % normalize data within axes limits
            xn = (offsetMag(indDoG(ic)) - ax.XLim(1)) / diff(ax.XLim);
            yn = (Zp_avg(indDoG(ic)) - ax.YLim(1)) / diff(ax.YLim);
            % convert to figure coordinates
            xf = axpos(1) + xn * axpos(3);
            yf = axpos(2) + yn * axpos(4);
            w = 0.04;
            h = 0.04;
            ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
            clim = max(abs(zscoreSTAs_allExpts(:)));
            data = squeeze(zscoreSTAs_allExpts(1,indDoG(ic),:,:));
            data_sm = medfilt2(imgaussfilt(data,1));
            imagesc(data_sm,[-5 5])
            axis image off
            colormap gray
        end
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_dog_STAs_Offset.pdf'), '-dpdf','-bestfit')

% DoG, offset x Zp, Fits
    figure;
        ax = axes;
        scatter(offsetMag(indDoG),Zp_avg(indDoG),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('offset')
        hold on
        axpos = ax.Position;   % position of main axes in figure
        for ic = 1:length(indDoG)
            % normalize data within axes limits
            xn = (offsetMag(indDoG(ic)) - ax.XLim(1)) / diff(ax.XLim);
            yn = (Zp_avg(indDoG(ic)) - ax.YLim(1)) / diff(ax.YLim);
            % convert to figure coordinates
            xf = axpos(1) + xn * axpos(3);
            yf = axpos(2) + yn * axpos(4);
            w = 0.04;
            h = 0.04;
            ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
            clim = max(abs(dog_fits_all(:)));
            data = squeeze(dog_fits_all(:,:,indDoG(ic),1));
            data_sm = medfilt2(imgaussfilt(data,1));
            imagesc(data_sm,[-5 5])
            axis image off
            colormap gray
        end
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_dog_STAs_Offset2.pdf'), '-dpdf','-bestfit')

% DoG, aspect ratio x Zp, STAs
    figure;
        ax = axes;
        scatter(dog_AR(indDoG),Zp_avg(indDoG),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('aspect ratio')
        hold on
        axpos = ax.Position;   % position of main axes in figure
        for ic = 1:length(indDoG)
            % normalize data within axes limits
            xn = (dog_AR(indDoG(ic)) - ax.XLim(1)) / diff(ax.XLim);
            yn = (Zp_avg(indDoG(ic)) - ax.YLim(1)) / diff(ax.YLim);
            % convert to figure coordinates
            xf = axpos(1) + xn * axpos(3);
            yf = axpos(2) + yn * axpos(4);
            w = 0.04;
            h = 0.04;
            ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
            clim = max(abs(zscoreSTAs_allExpts(:)));
            data = squeeze(zscoreSTAs_allExpts(1,indDoG(ic),:,:));
            data_sm = medfilt2(imgaussfilt(data,1));
            imagesc(data_sm,[-5 5])
            axis image off
            colormap gray
        end
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_dog_STAs_AR.pdf'), '-dpdf','-bestfit')

% DoG, aspect ratio x Zp, Fits
    figure;
        ax = axes;
        scatter(dog_AR(indDoG),Zp_avg(indDoG),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('aspect ratio')
        hold on
        axpos = ax.Position;   % position of main axes in figure
        for ic = 1:length(indDoG)
            % normalize data within axes limits
            xn = (dog_AR(indDoG(ic)) - ax.XLim(1)) / diff(ax.XLim);
            yn = (Zp_avg(indDoG(ic)) - ax.YLim(1)) / diff(ax.YLim);
            % convert to figure coordinates
            xf = axpos(1) + xn * axpos(3);
            yf = axpos(2) + yn * axpos(4);
            w = 0.04;
            h = 0.04;
            ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
            clim = max(abs(dog_fits_all(:)));
            data = squeeze(dog_fits_all(:,:,indDoG(ic),1));
            data_sm = medfilt2(imgaussfilt(data,1));
            imagesc(data_sm,[-5 5])
            axis image off
            colormap gray
        end
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_dog_STAs_AR2.pdf'), '-dpdf','-bestfit')







% Gabor, aspect ratio x Zp, STAs
    figure;
        ax = axes;
        scatter(gabor_AR(indGab),Zp_avg(indGab),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('aspect ratio')
        hold on
        axpos = ax.Position;   % position of main axes in figure
        for ic = 1:length(indGab)
            % normalize data within axes limits
            xn = (gabor_AR(indGab(ic)) - ax.XLim(1)) / diff(ax.XLim);
            yn = (Zp_avg(indGab(ic)) - ax.YLim(1)) / diff(ax.YLim);
            % convert to figure coordinates
            xf = axpos(1) + xn * axpos(3);
            yf = axpos(2) + yn * axpos(4);
            w = 0.04;
            h = 0.04;
            ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
            clim = max(abs(zscoreSTAs_allExpts(:)));
            data = squeeze(zscoreSTAs_allExpts(1,indGab(ic),:,:));
            data_sm = medfilt2(imgaussfilt(data,1));
            imagesc(data_sm,[-5 5])
            axis image off
            colormap gray
        end
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_gabor_STAs_AR.pdf'), '-dpdf','-bestfit')

% Gabor, aspect ratio x Zp, Fits
    figure;
        ax = axes;
        scatter(gabor_AR(indGab),Zp_avg(indGab),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('aspect ratio')
        hold on
        axpos = ax.Position;   % position of main axes in figure
        for ic = 1:length(indGab)
            % normalize data within axes limits
            xn = (gabor_AR(indGab(ic)) - ax.XLim(1)) / diff(ax.XLim);
            yn = (Zp_avg(indGab(ic)) - ax.YLim(1)) / diff(ax.YLim);
            % convert to figure coordinates
            xf = axpos(1) + xn * axpos(3);
            yf = axpos(2) + yn * axpos(4);
            w = 0.04;
            h = 0.04;
            ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
            clim = max(abs(gabor_fits_all(:)));
            data = squeeze(gabor_fits_all(:,:,indGab(ic),1));
            data_sm = medfilt2(imgaussfilt(data,1));
            imagesc(data_sm,[-5 5])
            axis image off
            colormap gray
        end
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_gabor_STAs_AR2.pdf'), '-dpdf','-bestfit')

% Gabor, size x Zp, STAs
    figure;
        ax = axes;
        scatter(gabor_size(indGab),Zp_avg(indGab),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('size')
        hold on
        axpos = ax.Position;   % position of main axes in figure
        for ic = 1:length(indGab)
            % normalize data within axes limits
            xn = (gabor_size(indGab(ic)) - ax.XLim(1)) / diff(ax.XLim);
            yn = (Zp_avg(indGab(ic)) - ax.YLim(1)) / diff(ax.YLim);
            % convert to figure coordinates
            xf = axpos(1) + xn * axpos(3);
            yf = axpos(2) + yn * axpos(4);
            w = 0.04;
            h = 0.04;
            ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
            clim = max(abs(zscoreSTAs_allExpts(:)));
            data = squeeze(zscoreSTAs_allExpts(1,indGab(ic),:,:));
            data_sm = medfilt2(imgaussfilt(data,1));
            imagesc(data_sm,[-5 5])
            axis image off
            colormap gray
        end
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_gabor_STAs_size.pdf'), '-dpdf','-bestfit')

% Gabor, size ratio x Zp, Fits
    figure;
        ax = axes;
        scatter(gabor_size(indGab),Zp_avg(indGab),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('size')
        hold on
        axpos = ax.Position;   % position of main axes in figure
        for ic = 1:length(indGab)
            % normalize data within axes limits
            xn = (gabor_size(indGab(ic)) - ax.XLim(1)) / diff(ax.XLim);
            yn = (Zp_avg(indGab(ic)) - ax.YLim(1)) / diff(ax.YLim);
            % convert to figure coordinates
            xf = axpos(1) + xn * axpos(3);
            yf = axpos(2) + yn * axpos(4);
            w = 0.04;
            h = 0.04;
            ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
            clim = max(abs(gabor_fits_all(:)));
            data = squeeze(gabor_fits_all(:,:,indGab(ic),1));
            data_sm = medfilt2(imgaussfilt(data,1));
            imagesc(data_sm,[-5 5])
            axis image off
            colormap gray
        end
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_gabor_STAs_size2.pdf'), '-dpdf','-bestfit')




% Gauss, size x Zp, STAs
    figure;
        ax = axes;
        scatter(gaus_size(indGau),Zp_avg(indGau),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('size')
        hold on
        axpos = ax.Position;   % position of main axes in figure
        for ic = 1:length(indGau)
            % normalize data within axes limits
            xn = (gaus_size(indGau(ic)) - ax.XLim(1)) / diff(ax.XLim);
            yn = (Zp_avg(indGau(ic)) - ax.YLim(1)) / diff(ax.YLim);
            % convert to figure coordinates
            xf = axpos(1) + xn * axpos(3);
            yf = axpos(2) + yn * axpos(4);
            w = 0.04;
            h = 0.04;
            ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
            clim = max(abs(zscoreSTAs_allExpts(:)));
            data = squeeze(zscoreSTAs_allExpts(1,indGau(ic),:,:));
            data_sm = medfilt2(imgaussfilt(data,1));
            imagesc(data_sm,[-5 5])
            axis image off
            colormap gray
        end
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_gauss_STAs_size.pdf'), '-dpdf','-bestfit')

% Gauss, size x Zp, Fits
    figure;
        ax = axes;
        scatter(gaus_size(indGau),Zp_avg(indGau),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('size')
        hold on
        axpos = ax.Position;   % position of main axes in figure
        for ic = 1:length(indGau)
            % normalize data within axes limits
            xn = (gaus_size(indGau(ic)) - ax.XLim(1)) / diff(ax.XLim);
            yn = (Zp_avg(indGau(ic)) - ax.YLim(1)) / diff(ax.YLim);
            % convert to figure coordinates
            xf = axpos(1) + xn * axpos(3);
            yf = axpos(2) + yn * axpos(4);
            w = 0.04;
            h = 0.04;
            ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
            clim = max(abs(gaus_fits_all(:)));
            data = squeeze(gaus_fits_all(:,:,indGau(ic),1));
            data_sm = medfilt2(imgaussfilt(data,1));
            imagesc(data_sm,[-5 5])
            axis image off
            colormap gray
        end
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_gauss_STAs_size2.pdf'), '-dpdf','-bestfit')


% Gauss, aspect ratio x Zp, STAs
    figure;
        ax = axes;
        scatter(gaus_AR(indGau),Zp_avg(indGau),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('aspect ratio')
        hold on
        axpos = ax.Position;   % position of main axes in figure
        for ic = 1:length(indGau)
            % normalize data within axes limits
            xn = (gaus_AR(indGau(ic)) - ax.XLim(1)) / diff(ax.XLim);
            yn = (Zp_avg(indGau(ic)) - ax.YLim(1)) / diff(ax.YLim);
            % convert to figure coordinates
            xf = axpos(1) + xn * axpos(3);
            yf = axpos(2) + yn * axpos(4);
            w = 0.04;
            h = 0.04;
            ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
            clim = max(abs(zscoreSTAs_allExpts(:)));
            data = squeeze(zscoreSTAs_allExpts(1,indGau(ic),:,:));
            data_sm = medfilt2(imgaussfilt(data,1));
            imagesc(data_sm,[-5 5])
            axis image off
            colormap gray
        end
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_gauss_STAs_AR.pdf'), '-dpdf','-bestfit')

% Gauss, aspect ratio x Zp, Fits
    figure;
        ax = axes;
        scatter(gaus_AR(indGau),Zp_avg(indGau),8,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('aspect ratio')
        hold on
        axpos = ax.Position;   % position of main axes in figure
        for ic = 1:length(indGau)
            % normalize data within axes limits
            xn = (gaus_AR(indGau(ic)) - ax.XLim(1)) / diff(ax.XLim);
            yn = (Zp_avg(indGau(ic)) - ax.YLim(1)) / diff(ax.YLim);
            % convert to figure coordinates
            xf = axpos(1) + xn * axpos(3);
            yf = axpos(2) + yn * axpos(4);
            w = 0.04;
            h = 0.04;
            ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
            clim = max(abs(gaus_fits_all(:)));
            data = squeeze(gaus_fits_all(:,:,indGau(ic),1));
            data_sm = medfilt2(imgaussfilt(data,1));
            imagesc(data_sm,[-5 5])
            axis image off
            colormap gray
        end
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'fits_gauss_STAs_AR2.pdf'), '-dpdf','-bestfit')






%% plot across models
 

figure;
    subplot(2,2,1)
        scatter(gaus_size(indGau),Zc_avg(indGau),12,'filled'); hold on
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('Size'); 
    subplot(2,2,2)
        scatter(gaus_size(indGau),Zp_avg(indGau),12,'filled'); hold on
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('Size'); 
    subplot(2,2,1)
        scatter(dog_sizeC(indDoG),Zc_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        %xlabel('Size center')
    subplot(2,2,2)
        scatter(dog_sizeC(indDoG),Zp_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
        %xlabel('Size center')
    subplot(2,2,1)
        scatter(gabor_size(indGab),Zc_avg(indGab),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
    subplot(2,2,2)
        scatter(gabor_size(indGab),Zp_avg(indGab),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
    subplot(2,2,3)
        scatter(gaus_AR(indGau),Zc_avg(indGau),12,'filled'); hold on
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
    subplot(2,2,4)
        scatter(gaus_AR(indGau),Zp_avg(indGau),12,'filled'); hold on
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
    subplot(2,2,3)
        scatter(dog_AR(indDoG),Zc_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('Aspect ratio')
    subplot(2,2,4)
        scatter(dog_AR(indDoG),Zp_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('Aspect ratio')
    subplot(2,2,3)
        scatter(gabor_AR(indGab),Zc_avg(indGab),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('Aspect ratio');
    subplot(2,2,4)
        scatter(gabor_AR(indGab),Zp_avg(indGab),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('Aspect ratio'); 
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_summary.pdf'), '-dpdf', '-bestfit')


figure;
    subplot(2,2,1)
        scatter(offsetMag(indDoG),Zc_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('Subunit offset')
    subplot(2,2,2)
        scatter(offsetMag(indDoG),Zp_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('Subunit offset')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_summary2.pdf'), '-dpdf', '-bestfit')


figure;
    subplot(1,3,1)
        histogram(winningModel)
        set(gca,'TickDir','out'); box off; 
        ylabel('# of cells')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_winners.pdf'), '-dpdf', '-bestfit')


%save('workspace_5chunks_crop_260821.mat')
%%
% --- Combine Size across groups ---
allSize = [gaus_size(indGau); dog_sizeC(indDoG); gabor_size(indGab)];
allAR   = [gaus_AR(indGau);   dog_AR(indDoG);    gabor_AR(indGab)];

% Zc/Zp need to be combined using the SAME index pattern per group
Zc_plot = [Zc_avg(indGau)'; Zc_avg(indDoG)'; Zc_avg(indGab)'];
Zp_plot = [Zp_avg(indGau)'; Zp_avg(indDoG)'; Zp_avg(indGab)'];

b_plot   = [b_all(cellsSelected(indGau)); b_all(cellsSelected(indDoG)); b_all(cellsSelected(indGab))];
amp_plot = [amp_all(cellsSelected(indGau)); amp_all(cellsSelected(indDoG)); amp_all(cellsSelected(indGab))];

figure;
    subplot(2,2,1)
        scatter_reg(allSize,Zc_plot,20)
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4]); 
        xlabel('Size')
    subplot(2,2,2)
        scatter_reg(allSize,Zp_plot,20)
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4]); 
        xlabel('Size')
    subplot(2,2,3)
        scatter_reg(allAR,Zc_plot,20)
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4]); 
        xlabel('Aspect ratio')
    subplot(2,2,4)
        scatter_reg(allAR,Zp_plot,20)
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4]); 
        xlabel('Aspect ratio')
    sgtitle('plot all cells as 1 group')    
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_summary3.pdf'), '-dpdf', '-bestfit')


figure;
    subplot(2,2,1)
        scatter_reg(allSize,b_plot,20)
        set(gca,'TickDir','out'); box off; axis square
        ylabel('baseline'); %ylim([-1 4]); 
        xlabel('Size')
    subplot(2,2,2)
        scatter_reg(allSize,amp_plot,20)
        set(gca,'TickDir','out'); box off; axis square
        ylabel('amplitude'); %ylim([-1 4]); 
        xlabel('Size')
    subplot(2,2,3)
        scatter_reg(allAR,b_plot,20)
        set(gca,'TickDir','out'); box off; axis square
        ylabel('baseline'); %ylim([-1 4]); 
        xlabel('Aspect ratio')
    subplot(2,2,4)
        scatter_reg(allAR,amp_plot,20)
        set(gca,'TickDir','out'); box off; axis square
        ylabel('amplitude');% ylim([-1 4]); 
        xlabel('Aspect ratio')
    sgtitle('plot all cells as 1 group')    
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_summary4.pdf'), '-dpdf', '-bestfit')






%% Zp-Zc baseline and amplitude


figure;
    sgtitle('blue=Gaussian   red=DoG   yellow=Gabor')
        subplot(2,2,1)
            scatter(gaus_AR(indGau),b_all(cellsSelected(indGau)),12,'filled'); hold on
            set(gca,'TickDir','out'); box off; axis square
            ylabel('baseline'); 
        subplot(2,2,2)
            scatter(gaus_AR(indGau),amp_all(cellsSelected(indGau)),12,'filled'); hold on
            set(gca,'TickDir','out'); box off; axis square
            ylabel('amp'); 
        subplot(2,2,1)
            scatter(dog_AR(indDoG),b_all(cellsSelected(indDoG)),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('baseline'); 
            xlabel('Aspect ratio')
        subplot(2,2,2)
            scatter(dog_AR(indDoG),amp_all(cellsSelected(indDoG)),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('amp'); 
            xlabel('Aspect ratio')
        subplot(2,2,1)
            scatter(gabor_AR(indGab),b_all(cellsSelected(indGab)),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('Zp-Zc mod baseline'); 
            xlabel('Aspect ratio');
        subplot(2,2,2)
            scatter(gabor_AR(indGab),amp_all(cellsSelected(indGab)),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('Zp-Zc mod amp');
            xlabel('Aspect ratio');
   
        subplot(2,2,3)
            scatter(gaus_size(indGau),b_all(cellsSelected(indGau)),12,'filled'); hold on
            set(gca,'TickDir','out'); box off; axis square
            ylabel('baseline'); 
            xlabel('Size'); 
        subplot(2,2,4)
            scatter(gaus_size(indGau),amp_all(cellsSelected(indGau)),12,'filled'); hold on
            set(gca,'TickDir','out'); box off; axis square
            ylabel('amp');
            xlabel('Size'); 
        subplot(2,2,3)
            scatter(dog_sizeC(indDoG),b_all(cellsSelected(indDoG)),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('baseline');
            %xlabel('Size center')
        subplot(2,2,4)
            scatter(dog_sizeC(indDoG),amp_all(cellsSelected(indDoG)),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('amp'); 
            %xlabel('Size center')
        subplot(2,2,3)
            scatter(gabor_size(indGab),b_all(cellsSelected(indGab)),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('Zp-Zc mod baseline');
        subplot(2,2,4)
            scatter(gabor_size(indGab),amp_all(cellsSelected(indGab)),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('Zp-Zc mod amp'); 
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_PCIfit.pdf'), '-dpdf', '-bestfit')
           


figure;
        subplot(2,2,1)
            scatter_reg(offsetMag(indDoG),b_all(cellsSelected(indDoG)),20)
            set(gca,'TickDir','out'); box off
            ylabel('Zp-Zc mod baseline'); ylim([-6 2])
            xlabel('offset'); xlim([0 21])
            subtitle('DoG winners')
        subplot(2,2,2)
            scatter_reg(offsetMag(indDoG),amp_all(cellsSelected(indDoG)),20)
            set(gca,'TickDir','out'); box off
            ylabel('Zp-Zc mod amp'); ylim([0 4])
            xlabel('offset') ; xlim([0 21])
            subtitle('DoG winners')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_PCIfit_offset.pdf'), '-dpdf', '-bestfit')


%% Differences in Zp, Zc, phase selectivity, etc.


figure;
    subplot(2,4,1)
        cdfplot(Zc_avg(indGau)); hold on
        cdfplot(Zc_avg(indDoG))
        cdfplot(Zc_avg(indGab))
        axis('square')
        xlabel('Zc avg')
    subplot(2,4,2)
        cdfplot(Zp_avg(indGau)); hold on
        cdfplot(Zp_avg(indDoG))
        cdfplot(Zp_avg(indGab))
        axis('square')
        xlabel('Zp avg')

    subplot(2,4,5)
        data = {Zc_avg(indGau), Zc_avg(indDoG), Zc_avg(indGab)};
        m = cellfun(@mean, data);
        sem = cellfun(@(x) std(x)/sqrt(numel(x)), data);
        b = bar(m); hold on
        errorbar(1:3, m, sem, 'k.', 'LineWidth', 1.2, 'CapSize', 10)
        set(gca, 'XTickLabel', {'Gau','DoG','Gab'})
        ylabel('Zc avg (mean \pm SEM)')
        title('Zc avg by group')
    subplot(2,4,6)
        data = {Zp_avg(indGau), Zp_avg(indDoG), Zp_avg(indGab)};
        m = cellfun(@mean, data);
        sem = cellfun(@(x) std(x)/sqrt(numel(x)), data);
        b = bar(m); hold on
        errorbar(1:3, m, sem, 'k.', 'LineWidth', 1.2, 'CapSize', 10)
        set(gca, 'XTickLabel', {'Gau','DoG','Gab'})
        ylabel('Zp avg (mean \pm SEM)')
        title('Zp avg by group')
    subplot(2,4,7)
        data = {b_all(cellsSelected(indGau)), b_all(cellsSelected(indDoG)), b_all(cellsSelected(indGab))};
        m = cellfun(@mean, data);
        sem = cellfun(@(x) std(x)/sqrt(numel(x)), data);
        b = bar(m); hold on
        errorbar(1:3, m, sem, 'k.', 'LineWidth', 1.2, 'CapSize', 10)
        set(gca, 'XTickLabel', {'Gau','DoG','Gab'})
        ylabel('baseline (mean \pm SEM)')
        title('baseline by group')
    subplot(2,4,8)
        data = {amp_all(cellsSelected(indGau)), amp_all(cellsSelected(indDoG)), amp_all(cellsSelected(indGab))};
        m = cellfun(@mean, data);
        sem = cellfun(@(x) std(x)/sqrt(numel(x)), data);
        b = bar(m); hold on
        errorbar(1:3, m, sem, 'k.', 'LineWidth', 1.2, 'CapSize', 10)
        set(gca, 'XTickLabel', {'Gau','DoG','Gab'})
        ylabel('amp (mean \pm SEM)')
        title('amp by group')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_PopulationComparison.pdf'), '-dpdf', '-bestfit')

winners_DoG = cellsSelected(indDoG);
winners_Gau = cellsSelected(indGau);
winners_Gab = cellsSelected(indGab);

save( ...
    fullfile( ...
        dirBase, ...
        'sara', ...
        'Analysis', ...
        'Neuropixel', ...
        'CrossOri', ...
        'randDirFourPhase', ...
        'spatialRFs_heldOut', ...
        'heldOut_ModelChoice_winningIndices.mat'), ...
    'winners_DoG', ...
    'winners_Gau', ...
    'winners_Gab');

%% layer analysis for each group

layers = [3 4 5];

figure;
    groupNames = {'Gau','DoG','Gab'};
    groupInds  = {indGau, indDoG, indGab};
    
    for g = 1:3
        layerVals = layer_all(cellsSelected(groupInds{g}));
        frac = arrayfun(@(L) mean(layerVals == L), layers);
        
        subplot(2,3,g)
            bar(frac)
            set(gca, 'XTickLabel', {'L2/3','L4','L5/6'})
            ylim([0 1])
            ylabel('Fraction of cells')
            title(groupNames{g})
            axis square
    end
    
    fracMat = zeros(3,3); % rows = layers, cols = groups
    for g = 1:3
        layerVals = layer_all(cellsSelected(groupInds{g}));
        fracMat(:,g) = arrayfun(@(L) mean(layerVals == L), layers);
    end

    subplot(2,3,4)
        bar(fracMat)
        set(gca, 'XTickLabel', {'L2/3','L4','L5/6'})
        legend(groupNames)
        ylabel('Fraction of cells')
        title('Layer distribution by group')
print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_PopulationComparison_layers.pdf'), '-dpdf', '-bestfit')



% offsetMag for L4 vs L5, DoG group only
layerVals_DoG = layer_all(cellsSelected(indDoG));
offsetMag_DoG = offsetMag(indDoG);

idxL4 = layerVals_DoG == 4;
idxL5 = layerVals_DoG == 5;

data = {offsetMag_DoG(idxL4), offsetMag_DoG(idxL5)};
m = cellfun(@mean, data);
sem = cellfun(@(x) std(x)/sqrt(numel(x)), data);

figure;
    b = bar(m); hold on
    errorbar(1:2, m, sem, 'k.', 'LineWidth', 1.2, 'CapSize', 10)
    set(gca, 'XTickLabel', {'L4 DoG','L5 DoG'})
    ylabel('offsetMag (mean \pm SEM)')
    title('offsetMag: DoG cells by layer')
    axis('square')     

% 
% figure;
%     scatter(depth_all(cellsSelected(indDoG)),offsetMag_DoG)

%%


% ===== OSI calculation =====
nCells  = size(avg_resp_dir_all,1);
nDir    = size(avg_resp_dir_all,2);

for iCell = 1:nCells
    resp = squeeze(avg_resp_dir_all(iCell,:,1,1,1));
    resp(resp < 0) = 0;
    % ---- collapse to orientation (average opposite directions) ----
    ori_resp = (resp(1:nDir/2) + resp(nDir/2+1:end)) / 2;
    % ---- preferred orientation ----
    [Rpref, prefInd] = max(ori_resp);
    % ---- orthogonal orientation (90 deg away) ----
    orthShift = (nDir/2) / 2;   % = nDir/4
    orthInd = prefInd + orthShift;
    if orthInd > nDir/2
        orthInd = orthInd - nDir/2;
    end
    Rorth = ori_resp(orthInd);
    % ---- OSI calculation ----
    OSI_mouseEphys(iCell) = (Rpref - Rorth) / (Rpref + Rorth);
    % ---- store preferred orientation (degrees) ----
    OSI_ind(iCell) = (prefInd - 1) * (360 / nDir); 
end

PCI = (Zp_all-Zc_all);
PCI_avg = mean(PCI,1);

figure;
subplot 221
    scatter(OSI_mouseEphys(cellsSelected)',Zc_avg)
subplot 222
    scatter(OSI_mouseEphys(cellsSelected)',Zp_avg)
subplot 223
    scatter(OSI_mouseEphys(cellsSelected)',PCI_avg(cellsSelected))

