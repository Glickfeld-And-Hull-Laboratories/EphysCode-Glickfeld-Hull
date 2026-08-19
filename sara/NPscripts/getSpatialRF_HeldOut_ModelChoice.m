%%
% This takes ~7h to run for all 15 experiments (100 cells) for 5 chunks
clear all; close all; clc

exptsToRun  = [1:15];
exptloc     = 'V1';
runloc      = 1;   % Where is this script being run? 1 == Hubel, 2 == Wiesel
nChunks     = 5; % number of held-out segments, nChunks=10 is 10% held out
doCrop      = 0;


tic
for exptN = exptsToRun   % Choose experiment (1 through 15)
    analysisDir     = ('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
    load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

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

for exptN = 1:15 %:15   % Choose experiment (1 through 15)

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

for ic = 1:nSelected
    for ih = 1:nChunks
        vals = [corr_HO_all.dog(ic,ih), corr_HO_all.gabor(ic,ih), corr_HO_all.gaus(ic,ih)];
        [maxVal, winnerIdx] = max(vals);

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


%% Determine winning model from one-standard-error (1-SE) rule, from the cross-validation model-selection literature (Hastie/Tibshirani/Friedman)
% choose the simplest model whose performance is not statistically distinguishable from the best model, 
% using the actual variability across your folds/chunks rather than an arbitrary % cutoff
%
% Steps per unit (ic):
% 1.  Fisher z-transform the correlations before averaging (raw correlations aren't additive/normally 
%     distributed -- averaging r directly is a common but technically incorrect shortcut).
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

for ic = 1:length(cellsSelected)
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
        sigmax = p(5);
        sigmay = p(6);
        gabor_AR(i) = sigmax / abs(sigmay);
        %gabor_AR(i) = max(sigmax,sigmay) / min(sigmax,sigmay);   % always >= 1
    end

% size
    gabor_size = nan(nSelected,1);
    for i = 1:nSelected
        p = gabFits_params{i};
        if isempty(p), continue; end
        sigmax = p(5);
        sigmay = p(6);
        gabor_size(i) = sqrt(sigmax * abs(sigmay));
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





%% Load Zp Zc data

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

Zc_avg = mean(Zc_all(:, cellsSelected),1);
Zp_avg = mean(Zp_all(:, cellsSelected),1);

indDoG = find(winningModel==1);
indGab = find(winningModel==2);
indGau = find(winningModel==3);

figure;
    sgtitle('DoG winners')
    subplot(4,2,1)
        scatter(offsetMag(indDoG),Zc_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('offset')
    subplot(4,2,2)
        scatter(offsetMag(indDoG),Zp_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('offset')
    subplot(4,2,3)
        scatter(dog_AR(indDoG),Zc_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('aspect ratio (tau)')
    subplot(4,2,4)
        scatter(dog_AR(indDoG),Zp_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('aspect ratio (tau)')
    subplot(4,2,5)
        scatter(dog_sizeC(indDoG),Zc_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('size center')
    subplot(4,2,6)
        scatter(dog_sizeC(indDoG),Zp_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('size center')
    subplot(4,2,7)
        scatter(dog_sizeS(indDoG),Zc_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('size surround')
        subtitle('DoG winners')
    subplot(4,2,8)
        scatter(dog_sizeS(indDoG),Zp_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('size surround')



figure;
    sgtitle('2D gaussian winners')
    subplot(3,2,1)
        scatter(gaus_AR(indGau),Zc_avg(indGau),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('aspect ratio (tau)'); %xlim([0 2.5])
    subplot(3,2,2)
        scatter(gaus_AR(indGau),Zp_avg(indGau),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('aspect ratio (tau)'); %xlim([0 2.5])
    subplot(3,2,3)
        scatter(gaus_size(indGau),Zc_avg(indGau),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('size'); 
    subplot(3,2,4)
        scatter(gaus_size(indGau),Zp_avg(indGau),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('size'); 



figure;
    sgtitle('Gabor winners')
    subplot(3,2,1)
        scatter(gabor_AR(indGab),Zc_avg(indGab),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('aspect ratio'); % xlim([0 2.5])
    subplot(3,2,2)
        scatter(gabor_AR(indGab),Zp_avg(indGab),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4]); % xlim([0 2.5])
        xlabel('aspect ratio')
    subplot(3,2,3)
        scatter(gabor_size(indGab),Zc_avg(indGab),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('size'); 
    subplot(3,2,4)
        scatter(gabor_size(indGab),Zp_avg(indGab),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('size')


%% plot across models
 

figure;
    subplot(4,4,1)
        scatter(gaus_size(indGau),Zc_avg(indGau),12,'filled'); hold on
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('Size'); 
    subplot(4,4,2)
        scatter(gaus_size(indGau),Zp_avg(indGau),12,'filled'); hold on
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('Size'); 
    subplot(4,4,1)
        scatter(dog_sizeC(indDoG),Zc_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        %xlabel('Size center')
    subplot(4,4,2)
        scatter(dog_sizeC(indDoG),Zp_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
        %xlabel('Size center')
% print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_size.pdf'), '-dpdf', '-bestfit')

figure;
    subplot(4,4,1)
        scatter(gaus_AR(indGau),Zc_avg(indGau),12,'filled'); hold on
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
    subplot(4,4,2)
        scatter(gaus_AR(indGau),Zp_avg(indGau),12,'filled'); hold on
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
    subplot(4,4,1)
        scatter(dog_AR(indDoG),Zc_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('Aspect ratio')
    subplot(4,4,2)
        scatter(dog_AR(indDoG),Zp_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('Aspect ratio')
% print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_aspectratio.pdf'), '-dpdf', '-bestfit')


figure;
    subplot(4,4,1)
        scatter(offsetMag(indDoG),Zc_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zc'); ylim([-1 4])
        xlabel('Subunit offset')
    subplot(4,4,2)
        scatter(offsetMag(indDoG),Zp_avg(indDoG),12,'filled')
        set(gca,'TickDir','out'); box off; axis square
        ylabel('mean Zp'); ylim([-1 4])
        xlabel('Subunit offset')
% print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_offset.pdf'), '-dpdf', '-bestfit')


figure;
    subplot(1,3,1)
        histogram(winningModel)
        set(gca,'TickDir','out'); box off; axis square
        ylabel('# of cells')
% print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', 'sara', 'Analysis', 'Neuropixel','CrossOri', 'randDirFourPhase','spatialRFs_heldOut', 'modelFits_winners.pdf'), '-dpdf', '-bestfit')


% save('workspace_5chunks_260818.mat')

%% Zp-Zc baseline and amplitude

baseline = b_all(cellsSelected);
amplitude = amp_all(cellsSelected);

    figure;
        subplot(4,4,1)
            scatter(dog_sizeC(indDoG),b_all(indDoG),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('baseline'); %ylim([-1 4])
            xlabel('size center')
            subtitle('DoG winners')
        subplot(4,4,2)
            scatter(dog_sizeC(indDoG),amp_all(indDoG),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('amp'); %ylim([-1 4])
            xlabel('size center')
            subtitle('DoG winners')
        subplot(4,4,3)
            scatter(dog_sizeS(indDoG),b_all(indDoG),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('baseline'); %ylim([-1 4])
            xlabel('size surr')
            subtitle('DoG winners')
        subplot(4,4,4)
            scatter(dog_sizeS(indDoG),amp_all(indDoG),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('amp'); %ylim([-1 4])
            xlabel('size surr')
            subtitle('DoG winners')


    figure;
        subplot(4,4,1)
            scatter(offsetMag(indDoG),b_all(indDoG),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('baseline'); %ylim([-1 4])
            xlabel('offset')
            subtitle('DoG winners')
        subplot(4,4,2)
            scatter(offsetMag(indDoG),amp_all(indDoG),12,'filled')
            set(gca,'TickDir','out'); box off
            ylabel('amp'); %ylim([-1 4])
            xlabel('offset')
            subtitle('DoG winners')







