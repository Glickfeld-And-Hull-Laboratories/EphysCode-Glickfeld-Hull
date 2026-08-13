%%
% This takes ~7h to run for all 15 experiments (100 cells)

clear all; close all; clc

for exptN = [1:15]   % Choose experiment (1 through 15)
    exptloc = 'V1';
    runloc = 1;   % Where is this script being run? 1 == Hubel, 2 == Wiesel
    nChunks = 5; % number of held-out segments, nChunks=10 is 10% held out
    
    
    %Find cells to run for this experiment
    
    analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
    load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])
    
    iexp = expts(exptN);
    nCells = nCells_list(exptN);
    
    %Make cellMap to find local index of the global index of all cells for each experiment
    
    allCells = [0 cumsum(nCells_list)];
    
    cellMap = cell(length(expts),1);
    for i = 1:length(expts)
        globalIdx = (allCells(i)+1):allCells(i+1);
        localIdx  = 1:nCells_list(i);
        cellMap{i} = [globalIdx(:), localIdx(:)];
    end
    
    %Get index of vis resp, DS cells with RFs
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
    
    % Use visually responsive cells with DS > .5 and reliable RFs.
    cellsSelected = intersect(idxInt, ind_DS);
    
    
    % get cell lists for the current experiment
    expt_cellsIdx           = cellMap{exptN};
    expt_cellsIdx_global    = expt_cellsIdx(:,1);
    expt_cellsIdx_local     = expt_cellsIdx(:,2);
    
    % which of the cells for this experiment are in the variable cellsSelected?
    global_cellsIdx_bin = ismember(expt_cellsIdx_global,cellsSelected);
    cellsIdx            = expt_cellsIdx_local(global_cellsIdx_bin);
    
    
    %Get held out data correlations
    
    tic
    getSpatialRF_HeldOut_Correlations(iexp, exptloc, runloc, cellsIdx, nChunks)
    toc
    
    fprintf(['exptN ' num2str(exptN) ', done.\n\n'])
end



%% concatenate across experiments

zscoreSTAs_allExpts = [];
dog_fits_all        = [];
gabor_fits_all      = [];
gaus_fits_all       = [];
corr_HO_all   = struct('dog', [], 'gabor', [], 'gaus', []);
corr_full_all = struct('dog', [], 'gabor', [], 'gaus', []);
model_params = repmat({cell(0,1)}, 3, 1);   % one growing cell array per model

for exptN = 1:15   % Choose experiment (1 through 15)

    exptloc='V1';
     
    analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
    load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])
    
    iexp = expts(exptN);
    nCells = nCells_list(exptN);
    
    [exptStruct] = createExptStruct(iexp,exptloc); % Load relevant times and directories for this experiment

    allCells = [0 cumsum(nCells_list)];
    cellMap = cell(length(expts),1);
    for i = 1:length(expts)
        globalIdx = (allCells(i)+1):allCells(i+1);
        localIdx  = 1:nCells_list(i);
        cellMap{i} = [globalIdx(:), localIdx(:)];
    end
    
    load(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs_heldOut\' exptStruct.mouse '-' exptStruct.date '_heldOut_correlations.mat'])

    zscoreSTAs_allExpts = [zscoreSTAs_allExpts, zscoreSTAs_all];

    dog_fits_all = cat(3, dog_fits_all, dog_fits_Uncropped);
    gabor_fits_all = cat(3, gabor_fits_all, gabor_fits_Uncropped);
    gaus_fits_all = cat(3, gaus_fits_all, gaus_fits_Uncropped);

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

