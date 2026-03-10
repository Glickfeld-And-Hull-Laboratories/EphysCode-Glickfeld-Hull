close all; clearvars; clc;

%% debug mode one cell test
debugMode = false;
debugCell = 986;   % check indRFint
%rng(0,'twister');   % randomness fully reproducible

%% Load data 
% load file with data concatenated across experiments

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

totalCells = totCells;   % cell number

if debugMode
    cellsToRun = debugCell; % test one cell here instead of total cell
    fprintf('Cell\n');
    disp(cellsToRun');
else
    cellsToRun = 1:totalCells;
end

fprintf('Running analysis on %d cell(s)\n', numel(cellsToRun));

%% Decide what index of cells you're going to use

indCortex   = find(depth_all>-1300);
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

%% Calculate time point of STA
% The first dimension of bestTimePoint_all is the one computed by the local contrast method

%totalCells = sum(nCells_list);

% Calculate best it by taking max zscore 
for ic = cellsToRun
    for it = 2:4
        avgImgZscore(it,:,:) = squeeze(avgImgZscore_all(ic,it,:,:));     % Grab avg zscore STA images for time points 0.04 0.07 and 0.1
    end 
    [m, it_best]            = max(sum(sum(abs(avgImgZscore(:,:,:)),2),3),[],1);      % which of the three has the max cumulative zscore?
    bestTimePoint_all(ic,3) = it_best;
    bestTimePoint_all(ic,4) = m;
end

% Calculate best it by taking zscore threshold mask and taking highest cumulative CI value
for ic = cellsToRun
    for it = 2:4
        pixMask             = imgaussfilt(abs(squeeze(avgImgZscoreThresh_all(ic,it,:,:))),3);
        conMap              = squeeze(localConMap_map_all(ic, it, :,:));
        maskMap             = pixMask.*conMap;
        maskMap_sum(ic,it)  = mean(maskMap(:));
    end
    [m, it_best]            = max(maskMap_sum(ic,:),[],2);
    bestTimePoint_all(ic,5) = it_best;
    bestTimePoint_all(ic,6) = m;   
end


%% Find center of RF and crop
if debugMode
    indLoop = find(ind_DS == debugCell);
    assert(~isempty(indLoop), 'debugCell is not in ind_DS');
else
    indLoop = 1:length(ind_DS);
end

for ii = indLoop
    ic = ind_DS(ii);
    avgImgZscore = squeeze(avgImgZscore_all(ic,:,:,:));     % Grab avg zscore STA images for all time points
    data = medfilt2(imgaussfilt(squeeze(avgImgZscore(bestTimePoint_all(ic,1),:,:)),1));
    [el, az] = getRFcenter(data); % reversed because of how I had swapped xDim and yDim for the image
    sideLength = 20;
    [data_cropped] = cropRFtoCenter(az, el, data, sideLength);
    STA_cropped(:,:,ii) = data_cropped;
end


figure;
is=1;
for ic = 1:size(STA_cropped,3)
    subplot(6,7,is)
        % clim = max(abs(STA_cropped(:)));
        % imagesc(STA_cropped(:,:,ic),[-clim clim])
        imagesc(STA_cropped(:,:,ic))
        subtitle(num2str(ind_DS(ic)))
        axis image off
        axis square
        colormap gray
        hold on
    is=is+1;
end
print(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\STAs_cropped_notNormalized.pdf'], '-dpdf','-bestfit')


%% Run Gabor fit
options.visualize = 0;
options.parallel  = 1;
options.shape     = 'elliptical';
options.runs      = 48;

% copy format from the first example
modelRegistry = [
    struct( ...
        'name','DoG x cos', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNoncDoGCosineRF_diff(STA), ...
        'k',12)

    struct( ...
        'name','DoG x cos mod', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNoncDoGCosineRF_sigmaXY(STA), ...
        'k',12)
];

omitCells = [634];   % cell(s) with NaN

results = runRFModelComparison( ...
    indLoop, ind_DS, STA_cropped, ...
    modelRegistry, omitCells, 'pdf', 'RF_DoGxcos.pdf', ...
    {'DoG x cos', 'DoG x cos mod'}, {'DoG x cos', 'DoG x cos mod'});

%% Ranking
modelIdx = find(strcmp({modelRegistry.name}, 'DoG x cos'));

paramList = {'orientation','frequency','elongation','size'};

for p = 1:length(paramList)

    rankRFsByParameter( ...
        results.models{modelIdx}, ...
        results.params{modelIdx}, ...
        results.cellIDs, ...
        sprintf('results/Rank_%s_%s.pdf', ...
            modelRegistry(modelIdx).name, paramList{p}), ...
        sprintf('%s - %s Ranking', ...
            modelRegistry(modelIdx).name, paramList{p}), ...
        'standard', ...
        paramList{p}, ...
        'sg' ...
        );
end


%% Load .mat files of tuning

resultsDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\';

load(fullfile([resultsDir, 'RFparams_orientation.mat']))
    valOrientationID = paramResults.cellIDs;  
    valOrientation = paramResults.values;
load(fullfile([resultsDir, 'RFparams_frequency.mat']))
    valFrequencyID = paramResults.cellIDs;  
    valFrequency = paramResults.values;
load(fullfile([resultsDir, 'RFparams_elongation.mat']))
    valElongationID = paramResults.cellIDs;  
    valElongation = paramResults.values;      
load(fullfile([resultsDir, 'RFparams_size.mat']))
    valSizeID = paramResults.cellIDs;  
    valSize = paramResults.values;      


