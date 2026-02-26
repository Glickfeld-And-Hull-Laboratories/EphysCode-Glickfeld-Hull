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

    % % plotting cropped RF
    % figure('Name','RF center & crop','Color','w');
    % movegui('center');
    % 
    % subplot(1,3,1)
    % imagesc(data)
    % axis image off
    % colormap gray
    % title('Full STA (best timepoint)')
    % 
    % subplot(1,3,2)
    % imagesc(data)
    % axis image off
    % colormap gray
    % hold on
    % plot(az, el, 'r+', 'MarkerSize', 12, 'LineWidth', 2)
    % title('RF center (red +)')
    % 
    % subplot(1,3,3)
    % imagesc(data_cropped)
    % axis image off
    % colormap gray
    % title('Cropped STA (used for fits)')
    % 
    % sgtitle(sprintf('Cell %d - RF localization & cropping', ic))

end

%% Run Gabor fit
options.visualize = 0;
options.parallel  = 1;
options.shape     = 'elliptical';
options.runs      = 48;

% copy format from the first example
modelRegistry = [

    struct( ...
        'name','Circular DoG', ...
        'type','standard', ...
        'fitFcn', @(STA) fitDoG2D(STA), ...
        'k',6)

    struct( ...
        'name','Elliptical DoG', ...
        'type','standard', ...
        'fitFcn', @(STA) fitEllipticalDoG2D(STA,[],'unnormalized',20), ...
        'k',8)

    struct( ...
        'name','Noncon DoG', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNonConcentricEllipticalDoG(STA,'unnormalized',20), ...
        'k',10)

    struct( ...
        'name','Custom Gabor', ...
        'type','standard', ...
        'fitFcn', @(STA) fitEllipGabor_fit_full(STA), ...
        'k',9)

    % struct( ...
    %     'name','SG Gabor', ...
    %     'type','sg', ...
    %     'fitFcn', @(STA) fit2dGabor_JM(STA,options), ...
    %     'k',10)
    struct( ...
        'name','DoG x cos', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNoncDoGCosineRF_diff(STA), ...
        'k',12)

];

omitCells = [634];   % cell(s) with NaN

results = runRFModelComparison( ...
    indLoop, ind_DS, STA_cropped, ...
    modelRegistry, omitCells, 'pdf', 'RF_Comparison_DoG.pdf', ...
    {'Noncon DoG', 'Elliptical DoG'},{'Noncon DoG', 'Elliptical DoG'});

%% Ranking
modelIdx = find(strcmp({modelRegistry.name}, 'Noncon DoG'));

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
        paramList{p});
end

