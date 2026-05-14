close all; clearvars; clc;

%% debug mode one cell test
debugMode = false;
debugCell = 375;   % check indRFint
%rng(0,'twister');   % randomness fully reproducible

%% Load data 
% load file with data concatenated across experiments

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

totalCells = totCells;   % cell number

fprintf('Loaded %d cells.\n', totalCells);

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
% Use visually responsive cells with reliable RFs.
cellsSelected = intersect(idxInt, resp_ind_dir_all);

if debugMode
    assert(ismember(debugCell, cellsSelected), ...
        'debugCell is not in cellsSelected.');
    cellsSelected = debugCell;
end

cellIDs = cellsSelected(:);

fprintf('Selected %d cells for fitting.\n', numel(cellIDs));

%% Calculate time point of STA
% The first dimension of bestTimePoint_all is the one computed by the local contrast method

cellsToRun = unique(cellIDs(:))';

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
%% Crop STA around RF center

sideLength = 20;
nSelected = numel(cellIDs);

STA_cropped = nan(sideLength, sideLength, nSelected);

for k = 1:nSelected

    ic = cellIDs(k);

    fprintf('k = %d maps to original cell index ic = %d\n', k, ic);

    avgImgZscore = squeeze(avgImgZscore_all(ic, :, :, :));
    bestTP = bestTimePoint_all(ic, 1);

    data = squeeze(avgImgZscore(bestTP, :, :));
    data = medfilt2(imgaussfilt(data, 1));

    [el, az] = getRFcenter(data);

    STA_cropped(:, :, k) = cropRFtoCenter(az, el, data, sideLength);
end
%%
% k = 10;
% ic = cellIDs(k);
% 
% figure;
% 
% subplot(1, 2, 1)
% imagesc(STA_cropped(:, :, k))
% axis image off
% title(sprintf('STA\\_cropped(:,:,k), k = %d', k))
% 
% subplot(1, 2, 2)
% avgImgZscore = squeeze(avgImgZscore_all(ic, :, :, :));
% bestTP = bestTimePoint_all(ic, 1);
% data = squeeze(avgImgZscore(bestTP, :, :));
% data = medfilt2(imgaussfilt(data, 1));
% 
% [el, az] = getRFcenter(data);
% data_check = cropRFtoCenter(az, el, data, sideLength);
% 
% imagesc(data_check)
% axis image off
% title(sprintf('Recomputed from cellIDs(k) = %d', ic))
% maxDiff = max(abs(STA_cropped(:, :, k) - data_check), [], 'all');
% 
% fprintf('Max difference = %.6g\n', maxDiff);
%% Run Gabor fit
options.visualize = 0;
options.parallel  = 1;
options.shape     = 'elliptical';
options.runs      = 48;
% options.getAllFits = false;

% copy format from the first example
modelRegistry = [

    % struct( ...
    %     'name','Circular DoG', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitDoG2D(STA), ...
    %     'k',6)
    % 
    % struct( ...
    %     'name','Elliptical DoG', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitEllipticalDoG2D(STA,[],'unnormalized',20), ...
    %     'k',8)
    % 
    % struct( ...
    %     'name','Noncon DoG', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitNonConcentricEllipticalDoG(STA,'unnormalized',20), ...
    %     'k',10)
    % 
    % struct( ...
    %     'name','Custom Gabor', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitEllipGabor_fit_full(STA), ...
    %     'k',9)

    struct( ...
        'name','SG Gabor', ...
        'type','sg', ...
        'fitFcn', @(STA) fit2dGabor_JM(STA,options), ...
        'k',10)
    % struct( ...
    %     'name','DoG x cos alpha', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitNoncDoGCosineRF_sigmaXY(STA), ...
    %     'k',13)

    % struct( ...
    %     'name','DoG x cos test', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitNoncDoGCosineRF_diff(STA), ...
    %      'k',12)
     % struct( ...
     %    'name','DoG x cos weighted', ...
     %    'type','standard', ...
     %    'fitFcn', @(STA) fitNoncDoGCosineRF_weighted(STA), ...
     %    'k',12)
];

omitCells = [114, 634];   % cell(s) with NaN

% results = refitCellsNoSurroundAndExportPDF( ...
%     STA_cropped, ...
%     'refit_comparison.pdf', ...
%     1.0, ...
%     1.0, ...
%     'unnormalized', ...
%     20);
%% Global STA contrast scale

allPeak = nan(nSelected, 1);

for k = 1:nSelected
    sta = STA_cropped(:, :, k);
    allPeak(k) = max(abs(sta(:)));
end

globalClim = prctile(allPeak, 95);
%%
%% Run model fit

omitCells = [114, 634];

fitIdx = 1:nSelected;

results = runRFModelComparison( ...
    fitIdx, ...
    cellIDs, ...
    STA_cropped, ...
    modelRegistry, ...
    omitCells, ...6
    'pdf', ...
    'test_all_fit.pdf');

%%
modelIdx = find(strcmp({modelRegistry.name}, ...
    'SG Gabor'), 1);

RF_cells = results.models{modelIdx};
paramCell = results.params{modelIdx};

fprintf('STA_cropped n = %d\n', size(STA_cropped, 3));
fprintf('cellIDs n = %d\n', numel(cellIDs));
fprintf('RF_cells n = %d\n', numel(RF_cells));
fprintf('paramCell n = %d\n', numel(paramCell));

%%
%% Modular RF Group Analysis Workflow
% This script replaces repeated group-specific plotting/export blocks.
%
% Expected variables in workspace:
%   avg_resp_dir_all, fittedIdx, cellIDs, STA_cropped, results,
%   modelRegistry, F1F0_all, DSI_prefdir
%
% Main idea:
%   1. Compute fitted-cell metrics once.
%   2. Define groups in one place.
%   3. Run the same analysis/export function for every group.
%
% To add a future group, add one new entry to groupDefs below.

%% Settings

modelName = 'SG Gabor';

useVonMisesOri = true;  % true = smooth von Mises, false = raw no fit
outDir = 'group_analysis_outputs_gabor';
if useVonMisesOri
    outDir = [outDir '_vonmises'];
else
    outDir = [outDir '_raw'];
end
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get fitted model parameters

modelIdx = find(strcmp({modelRegistry.name}, modelName), 1);
assert(~isempty(modelIdx), 'Model name not found in modelRegistry.');

RF_cells = results.models{modelIdx};
paramCell = results.params{modelIdx};
%%
% k = 1;
% rfSG = RF_cells{k};
% p = paramCell{k};
% sgFit = results.sgRawFit{k};
% 
% thetaList = [
%     p(6), ...
%     p(6) + pi / 2, ...
%     -p(6), ...
%     -p(6) + pi / 2
% ];
% 
% thetaNames = {'theta', 'theta+90', '-theta', '-theta+90'};
% 
% phaseList = [sgFit.phase, sgFit.phi];
% phaseNames = {'phase', 'phi'};
% 
% carrierAxes = {'xp', 'yp'};
% 
% bestSSE = Inf;
% bestLabel = '';
% 
% for iTheta = 1:numel(thetaList)
%     for iPhase = 1:numel(phaseList)
%         for iAxis = 1:numel(carrierAxes)
% 
%             rfRecon = reconstructGaborFlexible( ...
%                 p, size(rfSG), thetaList(iTheta), ...
%                 phaseList(iPhase), carrierAxes{iAxis});
% 
%             sse = sum((rfSG(:) - rfRecon(:)).^2);
% 
%             label = sprintf('%s | %s | carrier %s', ...
%                 thetaNames{iTheta}, phaseNames{iPhase}, ...
%                 carrierAxes{iAxis});
% 
%             fprintf('%s: SSE = %.4f\n', label, sse);
% 
%             if sse < bestSSE
%                 bestSSE = sse;
%                 bestLabel = label;
%                 bestRF = rfRecon;
%             end
%         end
%     end
% end
% 
% fprintf('\nBest convention: %s, SSE = %.4f\n', bestLabel, bestSSE);
% 
% figure;
% subplot(1, 3, 1)
% imagesc(rfSG); axis image off; colormap gray
% title('SG patch')
% 
% subplot(1, 3, 2)
% imagesc(bestRF); axis image off; colormap gray
% title(bestLabel)
% 
% subplot(1, 3, 3)
% imagesc(rfSG - bestRF); axis image off; colormap gray
% title('Difference')
% colorbar
%% Compute metrics once for all fitted cells
sgRawFit = results.sgRawFit{modelIdx}; % change this
metrics = computeFittedCellMetrics( ...
    avg_resp_dir_all, fitIdx, cellIDs, paramCell, sgRawFit);

%% Optional F1/F0 metric for group definition

metrics.F1F0 = nan(metrics.nFitted, 1);

if exist('F1F0_all', 'var') && exist('DSI_prefdir', 'var')
    idx = sub2ind(size(F1F0_all), ...
        (1:size(F1F0_all, 1))', DSI_prefdir(:));
    pref_F1F0_all = F1F0_all(idx);
    metrics.F1F0 = pref_F1F0_all(metrics.fittedCellIDs);
end

%% Replace raw data orientation with smoothed data orientation for comparison
%% Smooth grating orientation tuning once

%% Choose data orientation source: raw or smooth von Mises

rawDataOriDeg = metrics.dataOriDeg;
oriFitStruct = [];
if useVonMisesOri
    oriFitStruct = getOrientationTuningCurveFit(avg_resp_dir_all);

    metrics.smoothDataOriDeg = oriFitStruct.prefOri(metrics.fittedCellIDs);
    metrics.smoothDataMaxResp = oriFitStruct.maxResp(metrics.fittedCellIDs);

    metrics.dataOriDeg = metrics.smoothDataOriDeg;

    fprintf('Using smooth von Mises orientation.\n');
    fprintf('Number changed by smoothing: %d / %d\n', ...
        sum(rawDataOriDeg ~= metrics.smoothDataOriDeg), ...
        numel(rawDataOriDeg));

    disp(table( ...
        metrics.fittedCellIDs, ...
        rawDataOriDeg, ...
        metrics.smoothDataOriDeg, ...
        angleDiff180(metrics.smoothDataOriDeg, rawDataOriDeg), ...
        'VariableNames', { ...
        'CellID', 'RawOri', 'SmoothOri', 'SmoothMinusRaw'}));

else
    metrics.smoothDataOriDeg = nan(metrics.nFitted, 1);
    metrics.smoothDataMaxResp = nan(metrics.nFitted, 1);

    fprintf('Using raw orientation. No von Mises smoothing.\n');
end

%% Recompute all model-data differences using selected dataOriDeg

metrics.envMinusData = angleDiff180(metrics.envDeg, metrics.dataOriDeg);
metrics.env90MinusData = angleDiff180(metrics.env90Deg, metrics.dataOriDeg);
metrics.fftMinusData = angleDiff180(metrics.fftDeg, metrics.dataOriDeg);
metrics.offsetMinusData = angleDiff180(metrics.offsetDeg, metrics.dataOriDeg);

if useVonMisesOri
    metrics.rawDataOriDeg = rawDataOriDeg;
    
    metrics.fftMinusRaw = angleDiff180( ...
        metrics.fftDeg, ...
        metrics.rawDataOriDeg);
    
    metrics.fftMinusSmooth = angleDiff180( ...
        metrics.fftDeg, ...
        metrics.smoothDataOriDeg);
    
    rawErr = abs(metrics.fftMinusRaw);
    smoothErr = abs(metrics.fftMinusSmooth);
    [p,~,stats] = signrank(rawErr, smoothErr);
    
    fprintf('Median raw FFT mismatch: %.2f deg\n', median(rawErr));
    fprintf('Median smooth FFT mismatch: %.2f deg\n', median(smoothErr));
    fprintf('Wilcoxon signed-rank p = %.4g\n', p);
    
    figure;
    boxplot([rawErr(:), smoothErr(:)], ...
        'Labels', {'Raw', 'Von Mises'});
    ylabel('|FFT - data orientation| (deg)');
    title('Orientation mismatch comparison');
end
%% Define groups here
% Add future groups by adding one more struct entry.
% mask must be nFitted x 1 and index into metrics rows.

groupDefs = struct([]);

groupDefs(end + 1).name = 'group1_lowDSI_highOSI';
groupDefs(end).label = 'Group 1: DSI < 0.3 and OSI > 0.5';
groupDefs(end).mask = metrics.DSI < 0.3 & metrics.OSI > 0.5;

groupDefs(end + 1).name = 'group3_highDSI';
groupDefs(end).label = 'Group 3: DSI > 0.5';
groupDefs(end).mask = metrics.DSI > 0.5;

groupDefs(end + 1).name = 'group2_top20_F1F0';
groupDefs(end).label = 'Group 2: Top 20% F1/F0';
groupDefs(end).mask = metrics.F1F0 >= prctile(metrics.F1F0, 80);
% 
% groupDefs(end + 1).name = 'all_fitted';
% groupDefs(end).label = 'All fitted cells';
% groupDefs(end).mask = true(metrics.nFitted, 1);

% groupDefs(end + 1).name = 'group3_lowDSI_highOSI_top20_F1F0';
% groupDefs(end).label = ...
%     'Group 3: DSI < 0.3, OSI > 0.5, and Top 20% F1/F0';
% groupDefs(end).mask = ...
%     metrics.DSI < 0.3 & ...
%     metrics.OSI > 0.5 & ...
%     metrics.F1F0 >= prctile(metrics.F1F0, 80);

% groupDefs(end + 1).name = 'group6_lowOSI';
% groupDefs(end).label = 'Group 6: OSI < 0.5';
% groupDefs(end).mask = metrics.OSI < 0.5;

% groupDefs(end + 1).name = 'group7_bottom20_F1F0_complex';
% groupDefs(end).label = 'Group 7: Bottom 20% F1/F0, complex-like cells';
% groupDefs(end).mask = metrics.F1F0 <= prctile(metrics.F1F0, 20);
%% Run the same workflow for every group

for iGroup = 1:numel(groupDefs)
    runGroupWorkflow( ...
        groupDefs(iGroup), metrics, STA_cropped, RF_cells, paramCell, ...
        avg_resp_dir_all, cellIDs, outDir, useVonMisesOri, oriFitStruct);
end

fprintf('\nFinished all group workflows. Files saved in: %s\n', outDir);

%% tests
k = 1;

rfSG = RF_cells{k};
p = paramCell{k};

rfRecon = reconstructGaborFromConvertedParams(p, size(rfSG));

figure;
subplot(1,3,1)
imagesc(rfSG); axis image off; colormap gray
title('SG patch')

subplot(1,3,2)
imagesc(rfRecon); axis image off; colormap gray
title('Reconstructed from p')

subplot(1,3,3)
imagesc(rfSG - rfRecon); axis image off; colormap gray
title('Difference')
colorbar

%% Local functions

function plotGroupVsRestOSI(metrics, groupMask, pdfFile, figTitle)
%PLOTGROUPVSRESTOSI Compare OSI between selected group and all other cells.

    groupOSI = metrics.OSI(groupMask);
    restOSI = metrics.OSI(~groupMask);

    groupOSI = groupOSI(isfinite(groupOSI));
    restOSI = restOSI(isfinite(restOSI));

    y = [groupOSI; restOSI];
    g = [repmat({'Group'}, numel(groupOSI), 1); ...
         repmat({'Rest'}, numel(restOSI), 1)];

    fig = figure('Color', 'w', 'Position', [300 300 500 450]);

    boxplot(y, g);
    ylabel('OSI');
    title(sprintf('%s: OSI comparison', figTitle));
    grid on

    [p, ~, stats] = ranksum(groupOSI, restOSI);

    text(1.5, max(y), sprintf('ranksum p = %.3g', p), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 10);

    exportgraphics(fig, pdfFile);
    close(fig);

    fprintf('\n%s OSI comparison\n', figTitle);
    fprintf('Group median OSI: %.3f\n', median(groupOSI));
    fprintf('Rest median OSI: %.3f\n', median(restOSI));
    fprintf('Ranksum p = %.4g\n', p);
end


function plotDataVsModelThetaScatter(metrics, groupMask, pdfFile, figTitle)
%PLOTDATAVSMODELTHETASCATTER Scatter data pref orientation vs model theta.

    fig = figure('Color', 'w', 'Position', [200 200 650 550]);

    x = metrics.dataOriDeg(groupMask);
    y = metrics.fftDeg(groupMask);  % model fit theta / carrier orientation
    c = metrics.OSI(groupMask);

    scatter(x, y, 45, c, 'filled');
    hold on

    plot([0 180], [0 180], 'k--', 'LineWidth', 1.2);

    xlabel('Data preferred orientation (deg)');
    ylabel('Model fit theta orientation (deg)');
    title(sprintf('%s: data vs model theta', figTitle));

    xlim([0 180]);
    ylim([0 180]);
    xticks(0:30:180);
    yticks(0:30:180);
    axis square
    grid on

    cb = colorbar;
    ylabel(cb, 'OSI');

    exportgraphics(fig, pdfFile);
    close(fig);
end

function metrics = computeFittedCellMetrics( ...
    avg_resp_dir_all, fittedIdx, cellIDs, paramCell, sgRawFit)
%COMPUTEFITTEDCELLMETRICS Compute all reusable fitted-cell metrics.
%
% Args:
%     avg_resp_dir_all: Direction tuning response array.
%     fittedIdx: Indices into STA_cropped / paramCell that were fitted.
%     cellIDs: Mapping from STA index k to original cell index.
%     paramCell: Fitted parameter cell array for the selected model.
%
% Returns:
%     metrics: Struct with one row per fitted cell.

    nStimDir = size(avg_resp_dir_all, 2);
    nOri = nStimDir / 2;
    nFitted = numel(fittedIdx);

    metrics.nFitted = nFitted;
    metrics.fittedIdx = fittedIdx(:);
    metrics.staModelIdx = nan(nFitted, 1);
    metrics.fittedCellIDs = nan(nFitted, 1);

    metrics.DSI = nan(nFitted, 1);
    metrics.OSI = nan(nFitted, 1);
    metrics.dataOriDeg = nan(nFitted, 1);
    metrics.envDeg = nan(nFitted, 1);
    metrics.env90Deg = nan(nFitted, 1);
    metrics.fftDeg = nan(nFitted, 1);
    metrics.offsetDeg = nan(nFitted, 1);
    metrics.offsetMag = nan(nFitted, 1);

    metrics.envMinusData = nan(nFitted, 1);
    metrics.env90MinusData = nan(nFitted, 1);
    metrics.fftMinusData = nan(nFitted, 1);
    metrics.offsetMinusData = nan(nFitted, 1);

    for ii = 1:nFitted
        k = fittedIdx(ii);
        iCell = cellIDs(k);

        metrics.staModelIdx(ii) = k;
        metrics.fittedCellIDs(ii) = iCell;

        resp = squeeze(avg_resp_dir_all(iCell, :, 1, 1, 1));
        resp(resp < 0) = 0;

        [RprefDir, prefDirInd] = max(resp);
        nullInd = prefDirInd + nOri;
        if nullInd > nStimDir
            nullInd = nullInd - nStimDir;
        end
        Rnull = resp(nullInd);

        if RprefDir + Rnull > 0
            metrics.DSI(ii) = (RprefDir - Rnull) / ...
                (RprefDir + Rnull);
        end

        oriResp = (resp(1:nOri) + resp(nOri + 1:end)) / 2;
        [RprefOri, prefOriInd] = max(oriResp);
        orthInd = prefOriInd + nStimDir / 4;
        if orthInd > nOri
            orthInd = orthInd - nOri;
        end
        Rorth = oriResp(orthInd);

        if RprefOri + Rorth > 0
            metrics.OSI(ii) = (RprefOri - Rorth) / ...
                (RprefOri + Rorth);
        end

        [dataDeg, ~, ~] = getDataOrientation(avg_resp_dir_all, iCell);
        if exist('sgRawFit', 'var') && ~isempty(sgRawFit{k})
            ori = getSGGaborOrientations(sgRawFit{k});
        else
            ori = getModelOrientations(paramCell{k});
        end
        %% Smooth orientation tuning once
        metrics.dataOriDeg(ii) = dataDeg;
        metrics.envDeg(ii) = ori.env_deg;
        metrics.env90Deg(ii) = ori.env90_deg;
        metrics.fftDeg(ii) = ori.fft_deg;
        metrics.offsetDeg(ii) = ori.offset_deg;
        metrics.offsetMag(ii) = ori.offset_mag;

        metrics.envMinusData(ii) = angleDiff180(ori.env_deg, dataDeg);
        metrics.env90MinusData(ii) = angleDiff180(ori.env90_deg, dataDeg);
        metrics.fftMinusData(ii) = angleDiff180(ori.fft_deg, dataDeg);
        metrics.offsetMinusData(ii) = angleDiff180(ori.offset_deg, dataDeg);
    end
end

function runGroupWorkflow( ...
    groupDef, metrics, STA_cropped, RF_cells, paramCell, ...
    avg_resp_dir_all, cellIDs, outDir, useVonMisesOri, oriFitStruct)
%RUNGROUPWORKFLOW Run all tables, histograms, and PDFs for one group.

    groupMask = groupDef.mask(:);
    groupII = find(groupMask);
    groupKList = metrics.staModelIdx(groupMask);

    fprintf('\n%s\n', groupDef.label);
    fprintf('Count: %d / %d fitted cells\n', numel(groupII), ...
        metrics.nFitted);

    groupTable = table( ...
        groupII, ...
        metrics.staModelIdx(groupMask), ...
        metrics.fittedCellIDs(groupMask), ...
        metrics.DSI(groupMask), ...
        metrics.OSI(groupMask), ...
        metrics.F1F0(groupMask), ...
        metrics.dataOriDeg(groupMask), ...
        metrics.smoothDataOriDeg(groupMask), ...
        metrics.envDeg(groupMask), ...
        metrics.fftDeg(groupMask), ...
        metrics.envMinusData(groupMask), ...
        metrics.fftMinusData(groupMask), ...
        'VariableNames', { ...
        'FittedIndex_ii', ...
        'STA_Model_Index_k', ...
        'Original_Cell_Index_iCell', ...
        'DSI', 'OSI', 'F1F0', ...
        'DataOriDeg', 'SmoothDataOriDeg','EnvOriDeg', 'FFTOriDeg', ...
        'EnvMinusData', 'FFTMinusData'});

    disp(groupTable);

    tableFile = fullfile(outDir, [groupDef.name '_table.csv']);
    writetable(groupTable, tableFile);

    exportSTAOnlyPDF( ...
        STA_cropped, cellIDs, groupKList, metrics, groupII, ...
        fullfile(outDir, [groupDef.name '_STA_only.pdf']), ...
        groupDef.label);

    exportModelOriVsTuningPDF( ...
        RF_cells, paramCell, avg_resp_dir_all, cellIDs, groupKList, ...
        metrics, ...
        fullfile(outDir, [groupDef.name '_model_tuning_overlay.pdf']), ...
        groupDef.label, useVonMisesOri, oriFitStruct);

    plotOrientationHistograms( ...
        metrics, groupMask, ...
        fullfile(outDir, [groupDef.name '_orientation_histograms.pdf']), ...
        groupDef.label);

    plotMismatchComparison( ...
        metrics, groupMask, ...
        fullfile(outDir, [groupDef.name '_mismatch_comparison.pdf']), ...
        groupDef.label);

    plotOffsetComparison( ...
        metrics, groupMask, ...
        fullfile(outDir, [groupDef.name '_offset_axis_minus_data.pdf']), ...
        groupDef.label);

    plotDataVsModelThetaScatter( ...
        metrics, groupMask, ...
        fullfile(outDir, [groupDef.name '_data_vs_model_theta_scatter.pdf']), ...
        groupDef.label);

    plotGroupVsRestOSI( ...
        metrics, groupMask, ...
        fullfile(outDir, [groupDef.name '_OSI_group_vs_rest.pdf']), ...
        groupDef.label);
end

function exportSTAOnlyPDF( ...
    STA_cropped, cellIDs, kList, metrics, groupII, pdfFile, figTitle)
%EXPORTSTAONLYPDF Export STA panels using one global color scale.

    if exist(pdfFile, 'file')
        delete(pdfFile);
    end

    nPerPage = 30;
    nRows = 5;
    nCols = 6;

    globalClim = max(abs(STA_cropped(:)), [], 'all', 'omitnan');
    if globalClim == 0 || ~isfinite(globalClim)
        globalClim = 1;
    end

    nPages = ceil(numel(kList) / nPerPage);

    for iPage = 1:nPages
        fig = figure('Color', 'w', 'Position', [100 100 1600 1200]);
        tiledlayout(nRows, nCols, 'TileSpacing', 'compact', ...
            'Padding', 'compact');

        idxStart = (iPage - 1) * nPerPage + 1;
        idxEnd = min(iPage * nPerPage, numel(kList));

        for jj = idxStart:idxEnd
            k = kList(jj);
            iCell = cellIDs(k);
            ii = groupII(jj);

            nexttile
            imagesc(STA_cropped(:, :, k), [-globalClim globalClim]);
            axis image off
            colormap gray

            title(sprintf('Cell %d\nDSI %.2f | OSI %.2f', ...
                iCell, metrics.DSI(ii), metrics.OSI(ii)), ...
                'FontSize', 7);
        end

        sgtitle(sprintf('%s STAs | Page %d/%d', figTitle, ...
            iPage, nPages), 'FontWeight', 'bold');

        exportgraphics(fig, pdfFile, 'Append', true);
        close(fig);
    end

    fprintf('Saved %s\n', pdfFile);
end

function exportModelOriVsTuningPDF( ...
    RF_cells, paramCell, avg_resp_dir_all, cellIDs, kList, ...
    metrics, pdfFile, figTitle, useVonMisesOri, oriFitStruct)
%EXPORTMODELORIVSTUNINGPDF Export RF/tuning overlays for a group.

    if exist(pdfFile, 'file')
        delete(pdfFile);
    end

    nStimDir = size(avg_resp_dir_all, 2);
    oriDeg = 0:(360 / nStimDir):(180 - 360 / nStimDir);

    nCellsPerPage = 8;
    nRows = 4;
    nCols = 4;
    nPages = ceil(numel(kList) / nCellsPerPage);

    for iPage = 1:nPages
        idxStart = (iPage - 1) * nCellsPerPage + 1;
        idxEnd = min(iPage * nCellsPerPage, numel(kList));
        pageIdx = idxStart:idxEnd;

        fig = figure('Color', 'w', 'Position', [100 100 1400 1000]);

        for jj = 1:numel(pageIdx)
            k = kList(pageIdx(jj));
            iCell = cellIDs(k);
            rf = RF_cells{k};
            p = paramCell{k};

            panelRF = 2 * jj - 1;
            panelTC = 2 * jj;

            [~, oriResp, ~] = getDataOrientation(avg_resp_dir_all, iCell);
            
            ii = find(metrics.staModelIdx == k, 1);
            dataDeg = metrics.dataOriDeg(ii);
            ori = getModelOrientations(p);

            envDiff = abs(angleDiff180(ori.env_deg, dataDeg));
            fftDiff = abs(angleDiff180(ori.fft_deg, dataDeg));

            subplot(nRows, nCols, panelRF)
            plotRFWithOrientationLines(rf, ori, dataDeg, iCell, ...
                envDiff, fftDiff);

            subplot(nRows, nCols, panelTC)
            plotOrientationTuning( ...
                oriDeg, oriResp, dataDeg, ori, iCell, ...
                useVonMisesOri, oriFitStruct);
        end

        sgtitle(sprintf('%s | Page %d/%d', figTitle, iPage, nPages), ...
            'FontWeight', 'bold');

        exportgraphics(fig, pdfFile, 'Append', true);
        close(fig);
    end

    fprintf('Saved %s\n', pdfFile);
end

function plotRFWithOrientationLines(rf, ori, dataDeg, iCell, envDiff, fftDiff)
%PLOTRFWITHORIENTATIONLINES Plot RF with envelope, FFT, and data axes.

    if isempty(rf) || any(~isfinite(rf(:)))
        axis off
        title(sprintf('Cell %d invalid RF', iCell), 'FontSize', 7);
        return
    end

    clim = max(abs(rf(:)));
    if clim == 0 || ~isfinite(clim)
        clim = 1;
    end

    imagesc(rf, [-clim clim]);
    axis image off
    colormap(gca, gray);
    set(gca, 'YDir', 'reverse');
    hold on

    [ny, nx] = size(rf);
    cx = (nx + 1) / 2;
    cy = (ny + 1) / 2;
    L = 0.45 * min(nx, ny);

    plotOriLine(cx, cy, L, ori.theta_env, 'r-');

    thetaFftDisplay = atan2(-ori.fy, ori.fx);
    plotOriLine(cx, cy, L, thetaFftDisplay, 'y-');

    thetaDataDisplay = deg2rad(-dataDeg);
    plotOriLine(cx, cy, L, thetaDataDisplay, 'c-');

    title(sprintf(['Cell %d\nData %.0f | Env %.0f d %.0f\n' ...
        'FFT %.0f d %.0f'], iCell, dataDeg, ori.env_deg, ...
        envDiff, ori.fft_deg, fftDiff), 'FontSize', 7);

    hold off
end

function plotOrientationTuning( ...
    oriDeg, oriResp, dataDeg, ori, iCell, useVonMisesOri, oriFitStruct)
%PLOTORIENTATIONTUNING Plot raw or von Mises-smoothed orientation tuning.

    if useVonMisesOri
        oriDegSmooth = oriFitStruct.oriDegSmooth;
        ySmooth = oriFitStruct.oriSmooth(:, iCell);
    
        plot(oriDegSmooth, ySmooth, 'k-', 'LineWidth', 1.5);
        hold on
    
        xlabel('Ori (deg)');
        ylabel('Von Mises fit');
        titleText = sprintf('Cell %d von Mises tuning', iCell);
    else
        oriDegPlot = [oriDeg, 180];
        oriRespPlot = [oriResp(:)', oriResp(1)];

        plot(oriDegPlot, oriRespPlot, '-ko', 'LineWidth', 1.2, ...
            'MarkerSize', 4);
        hold on

        xlabel('Ori (deg)');
        ylabel('Resp');
        titleText = sprintf('Cell %d raw tuning', iCell);
    end

    xline(dataDeg, 'c-', 'LineWidth', 1.4);
    xline(ori.env_deg, 'r-', 'LineWidth', 1.4);
    xline(ori.fft_deg, 'y-', 'LineWidth', 1.4);

    xlim([0 180]);
    xticks(0:30:180);
    grid on
    title(titleText, 'FontSize', 7);
    hold off
end

function plotOrientationHistograms(metrics, groupMask, pdfFile, figTitle)
%PLOTORIENTATIONHISTOGRAMS Plot data, model, and model-data histograms.

    edgesOri = 0:30:180;
    edgesDiff = -90:15:90;

    fig = figure('Color', 'w', 'Position', [200 200 1200 400]);

    subplot(1, 3, 1)
    histogram(metrics.dataOriDeg(groupMask), edgesOri);
    % histogram(metrics.smoothDataOriDeg(groupMask), edgesOri);
    xlabel('Grating preferred orientation (deg)');
    ylabel('Cell count');
    title('Data orientation');
    xlim([0 180]);
    xticks(0:30:180);
    grid on

    subplot(1, 3, 2)
    histogram(metrics.envDeg(groupMask), edgesOri);
    xlabel('Model envelope orientation (deg)');
    ylabel('Cell count');
    title('Model orientation');
    xlim([0 180]);
    xticks(0:30:180);
    grid on

    subplot(1, 3, 3)
    histogram(metrics.envMinusData(groupMask), edgesDiff);
    xlabel('Model - data orientation (deg)');
    ylabel('Cell count');
    title('Model-data difference');
    xlim([-90 90]);
    xticks(-90:30:90);
    grid on

    sgtitle(sprintf('%s, n = %d', figTitle, sum(groupMask)));
    exportgraphics(fig, pdfFile);
    close(fig);
end

function plotMismatchComparison(metrics, groupMask, pdfFile, figTitle)
%PLOTMISMATCHCOMPARISON Compare FFT-data and envelope+90-data mismatch.

    edgesDiff = -90:15:90;

    fig = figure('Color', 'w', 'Position', [200 200 900 400]);

    subplot(1, 2, 1)
    histogram(metrics.fftMinusData(groupMask), edgesDiff);
    xlabel('FFT/carrier - data orientation (deg)');
    ylabel('Cell count');
    title('FFT - data');
    xlim([-90 90]);
    xticks(-90:30:90);
    grid on

    subplot(1, 2, 2)
    histogram(metrics.env90MinusData(groupMask), edgesDiff);
    xlabel('Envelope + 90 - data orientation (deg)');
    ylabel('Cell count');
    title('Envelope + 90 - data');
    xlim([-90 90]);
    xticks(-90:30:90);
    grid on

    sgtitle(sprintf('%s mismatch comparison, n = %d', ...
        figTitle, sum(groupMask)));
    exportgraphics(fig, pdfFile);
    close(fig);
end

function plotOffsetComparison(metrics, groupMask, pdfFile, figTitle)
%PLOTOFFSETCOMPARISON Plot dx/dy offset axis relative to data orientation.

    edgesDiff = -90:15:90;

    fig = figure('Color', 'w', 'Position', [200 200 700 500]);

    histogram(metrics.offsetMinusData(groupMask), edgesDiff);
    xlabel('Offset axis - data orientation (deg)');
    ylabel('Cell count');
    title(sprintf('%s: dx/dy offset axis vs data, n = %d', ...
        figTitle, sum(groupMask)));
    xlim([-90 90]);
    xticks(-90:30:90);
    grid on

    exportgraphics(fig, pdfFile);
    close(fig);
end

function [dataDeg, oriResp, resp] = getDataOrientation(avg_resp_dir_all, iCell)
%GETDATAORIENTATION Get preferred orientation from grating responses.

    nStimDir = size(avg_resp_dir_all, 2);
    nOri = nStimDir / 2;
    oriDeg = 0:(360 / nStimDir):(180 - 360 / nStimDir);

    resp = squeeze(avg_resp_dir_all(iCell, :, 1, 1, 1));
    resp(resp < 0) = 0;

    oriResp = (resp(1:nOri) + resp(nOri + 1:end)) / 2;
    [~, prefOriInd] = max(oriResp);

    dataDeg = oriDeg(prefOriInd);
end

function ori = getModelOrientations(p)
%GETMODELORIENTATIONS Return envelope, FFT, and offset orientations.

    theta = p(6);
    tau = p(5);
    f = p(9);
    dx = p(11);
    dy = p(12);
    % if ~isfinite(f) || f <= 0
    %     f = 1;
    % end
    thetaEnv = theta;
    if tau < 1
        thetaEnv = theta + pi / 2;
    end

    fx = f * cos(theta);
    fy = f * sin(theta);

    offsetMag = hypot(dx, dy);
    if offsetMag < 1
        offsetDeg = NaN;
    else
        offsetDeg = mod(rad2deg(atan2(dy, dx)), 180);
    end

    ori.env_deg = mod(rad2deg(-thetaEnv), 180);
    ori.env90_deg = mod(ori.env_deg + 90, 180);
    ori.fft_deg = mod(rad2deg(atan2(fy, fx)), 180);
    ori.offset_deg = offsetDeg;
    ori.offset_mag = offsetMag;
    ori.theta_env = thetaEnv;
    ori.fx = fx;
    ori.fy = fy;
end

function d = angleDiff180(a, b)
%ANGLEDIFF180 Signed orientation difference in [-90, 90].

    d = a - b;
    d = mod(d + 90, 180) - 90;
end

function plotOriLine(cx, cy, L, thetaDisplay, lineSpec)
%PLOTORILINE Plot an orientation axis through a center point.

    ux = cos(thetaDisplay);
    uy = sin(thetaDisplay);

    plot([cx - L * ux, cx + L * ux], ...
         [cy - L * uy, cy + L * uy], ...
         lineSpec, 'LineWidth', 1.6);
end

function fftDeg = estimateRFOrientationFFT(rf)
    rf = rf - mean(rf(:), 'omitnan');

    F = abs(fftshift(fft2(rf)));
    [ny, nx] = size(F);

    cx = floor(nx / 2) + 1;
    cy = floor(ny / 2) + 1;

    F(cy-1:cy+1, cx-1:cx+1) = 0;

    [~, ind] = max(F(:));
    [py, px] = ind2sub(size(F), ind);

    fx = px - cx;
    fy = py - cy;

    fftDeg = mod(rad2deg(atan2(fy, fx)), 180);
end

function envDeg = estimateEnvelopeOrientationMoment(rf)
    rfEnergy = rf.^2;
    rfEnergy = rfEnergy / sum(rfEnergy(:), 'omitnan');

    [ny, nx] = size(rf);
    [X, Y] = meshgrid(1:nx, 1:ny);

    xMean = sum(X(:) .* rfEnergy(:), 'omitnan');
    yMean = sum(Y(:) .* rfEnergy(:), 'omitnan');

    Xc = X - xMean;
    Yc = Y - yMean;

    Cxx = sum((Xc(:).^2) .* rfEnergy(:), 'omitnan');
    Cyy = sum((Yc(:).^2) .* rfEnergy(:), 'omitnan');
    Cxy = sum((Xc(:) .* Yc(:)) .* rfEnergy(:), 'omitnan');

    C = [Cxx, Cxy; Cxy, Cyy];

    [V, D] = eig(C);
    [~, idx] = max(diag(D));
    v = V(:, idx);

    envDeg = mod(rad2deg(atan2(v(2), v(1))), 180);
end

function rf = reconstructGaborFromConvertedParams(p, imSize)

    ny = imSize(1);
    nx = imSize(2);

    [X, Y] = meshgrid(1:nx, 1:ny);

    A = p(1);
    b = 0;  % use 0 unless you store SG baseline separately
    sigmaX = p(3);
    sigmaY = p(3) * p(5);
    theta = p(6);
    x0 = p(7);
    y0 = p(8);
    f = p(9);
    phase = p(10);

    Xc = X - x0;
    Yc = Y - y0;

    xp = Xc .* cos(theta) + Yc .* sin(theta);
    yp = -Xc .* sin(theta) + Yc .* cos(theta);

    env = exp(-(xp.^2 ./ (2 * sigmaX^2) + ...
                yp.^2 ./ (2 * sigmaY^2)));

    carrier = cos(2 * pi * f .* xp + phase);

    rf = b + A .* env .* carrier;
end

function rf = reconstructGaborWithTheta(p, imSize, theta)

    ny = imSize(1);
    nx = imSize(2);

    [X, Y] = meshgrid(1:nx, 1:ny);

    A = p(1);
    sigmaX = p(3);
    sigmaY = p(3) * p(5);
    x0 = p(7);
    y0 = p(8);
    f = p(9);
    phase = p(10);

    Xc = X - x0;
    Yc = Y - y0;

    xp = Xc .* cos(theta) + Yc .* sin(theta);
    yp = -Xc .* sin(theta) + Yc .* cos(theta);

    env = exp(-(xp.^2 ./ (2 * sigmaX^2) + ...
                yp.^2 ./ (2 * sigmaY^2)));

    carrier = cos(2 * pi * f .* xp + phase);

    rf = A .* env .* carrier;
end

function rf = reconstructGaborFlexible( ...
    p, imSize, theta, phase, carrierAxis)

    ny = imSize(1);
    nx = imSize(2);

    [X, Y] = meshgrid(1:nx, 1:ny);

    A = p(1);
    sigmaX = p(3);
    sigmaY = p(3) * p(5);
    x0 = p(7);
    y0 = p(8);
    f = p(9);

    Xc = X - x0;
    Yc = Y - y0;

    xp = Xc .* cos(theta) + Yc .* sin(theta);
    yp = -Xc .* sin(theta) + Yc .* cos(theta);

    env = exp(-(xp.^2 ./ (2 * sigmaX^2) + ...
                yp.^2 ./ (2 * sigmaY^2)));

    if strcmp(carrierAxis, 'xp')
        carrierCoord = xp;
    else
        carrierCoord = yp;
    end

    carrier = cos(2 * pi * f .* carrierCoord + phase);

    rf = A .* env .* carrier;
end

function ori = getSGGaborOrientations(sgFit)

    carrierTheta = sgFit.phi;
    envelopeTheta = sgFit.phi + sgFit.theta;

    ori.fft_deg = mod(rad2deg(carrierTheta), 180);
    ori.env_deg = mod(rad2deg(envelopeTheta), 180);
    ori.env90_deg = mod(ori.env_deg + 90, 180);

    ori.offset_deg = NaN;
    ori.offset_mag = NaN;

    ori.theta_env = envelopeTheta;
    ori.fx = cos(carrierTheta);
    ori.fy = sin(carrierTheta);
end