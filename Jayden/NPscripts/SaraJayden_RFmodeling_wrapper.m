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
k = 10;
ic = cellIDs(k);

figure;

subplot(1, 2, 1)
imagesc(STA_cropped(:, :, k))
axis image off
title(sprintf('STA\\_cropped(:,:,k), k = %d', k))

subplot(1, 2, 2)
avgImgZscore = squeeze(avgImgZscore_all(ic, :, :, :));
bestTP = bestTimePoint_all(ic, 1);
data = squeeze(avgImgZscore(bestTP, :, :));
data = medfilt2(imgaussfilt(data, 1));

[el, az] = getRFcenter(data);
data_check = cropRFtoCenter(az, el, data, sideLength);

imagesc(data_check)
axis image off
title(sprintf('Recomputed from cellIDs(k) = %d', ic))
maxDiff = max(abs(STA_cropped(:, :, k) - data_check), [], 'all');

fprintf('Max difference = %.6g\n', maxDiff);
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

    % struct( ...
    %     'name','SG Gabor', ...
    %     'type','sg', ...
    %     'fitFcn', @(STA) fit2dGabor_JM(STA,options), ...
    %     'k',10)
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
     struct( ...
        'name','DoG x cos weighted', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNoncDoGCosineRF_weighted(STA), ...
        'k',12)
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
    omitCells, ...
    'pdf', ...
    'test_fit.pdf');

%%
modelIdx = find(strcmp({modelRegistry.name}, ...
    'DoG x cos weighted'), 1);

RF_cells = results.models{modelIdx};
paramCell = results.params{modelIdx};

fprintf('STA_cropped n = %d\n', size(STA_cropped, 3));
fprintf('cellIDs n = %d\n', numel(cellIDs));
fprintf('RF_cells n = %d\n', numel(RF_cells));
fprintf('paramCell n = %d\n', numel(paramCell));

%%
%% Eye-test DSI/OSI for fitted cells

isFitted = ~cellfun(@isempty, paramCell);
fittedIdx = find(isFitted);
    checkSingleCellDSIOSI(avg_resp_dir_all, 60);

%%
%% Calculate DSI/OSI for fitted cells and print Group 1

nStimDir = size(avg_resp_dir_all, 2);
nOri = nStimDir / 2;

nFitted = numel(fittedIdx);

DSI = nan(nFitted, 1);
OSI = nan(nFitted, 1);
fittedCellIDs = nan(nFitted, 1);
staModelIdx = nan(nFitted, 1);

for ii = 1:nFitted

    k = fittedIdx(ii);      % index into STA_cropped / paramCell
    iCell = cellIDs(k);     % original index into avg_resp_dir_all

    staModelIdx(ii) = k;
    fittedCellIDs(ii) = iCell;

    resp = squeeze(avg_resp_dir_all(iCell, :, 1, 1, 1));
    resp(resp < 0) = 0;

    % DSI
    [Rpref_dir, prefDirInd] = max(resp);

    nullInd = prefDirInd + nOri;
    if nullInd > nStimDir
        nullInd = nullInd - nStimDir;
    end

    Rnull = resp(nullInd);

    if Rpref_dir + Rnull > 0
        DSI(ii) = (Rpref_dir - Rnull) / (Rpref_dir + Rnull);
    end

    % OSI
    ori_resp = (resp(1:nOri) + resp(nOri + 1:end)) / 2;

    [Rpref_ori, prefOriInd] = max(ori_resp);

    orthInd = prefOriInd + nStimDir / 4;
    if orthInd > nOri
        orthInd = orthInd - nOri;
    end

    Rorth = ori_resp(orthInd);

    if Rpref_ori + Rorth > 0
        OSI(ii) = (Rpref_ori - Rorth) / (Rpref_ori + Rorth);
    end
end

%% Group 1: low DSI, high OSI

group1 = DSI < 0.3 & OSI > 0.5;

group1_table = table( ...
    find(group1), ...
    staModelIdx(group1), ...
    fittedCellIDs(group1), ...
    DSI(group1), ...
    OSI(group1), ...
    'VariableNames', { ...
    'FittedIndex_ii', ...
    'STA_Model_Index_k', ...
    'Original_Cell_Index_iCell', ...
    'DSI', ...
    'OSI'});

disp(group1_table);

fprintf('Group 1 count: %d / %d fitted cells\n', ...
    sum(group1), nFitted);

%%
%% Group 1 orientation distributions and differences
% group1 = DSI < 0.3 & OSI > 0.5;

group1_ii = find(group1);

nStimDir = size(avg_resp_dir_all, 2);
nOri = nStimDir / 2;
oriDeg = 0:(360 / nStimDir):(180 - 360 / nStimDir);

dataOri_group1 = nan(numel(group1_ii), 1);
modelOri_group1 = nan(numel(group1_ii), 1);
diff_group1 = nan(numel(group1_ii), 1);

for jj = 1:numel(group1_ii)

    ii = group1_ii(jj);

    k = staModelIdx(ii);        % index into paramCell / STA_cropped
    iCell = fittedCellIDs(ii);  % original index into avg_resp_dir_all

    % Data grating preferred orientation
    [data_deg, ori_resp, resp] = getDataOrientation(avg_resp_dir_all, iCell);   

    % Model fit envelope orientation
    p = paramCell{k};

    tau = p(5);
    theta = p(6);

    theta_env = theta;
    if tau < 1
        theta_env = theta + pi / 2;
    end

    modelOri_group1(jj) = mod(rad2deg(-theta_env), 180);

    % Difference, wrapped for orientation
    diff_group1(jj) = angleDiff180( ...
        modelOri_group1(jj), dataOri_group1(jj));
end

%% Plot Group 1 histograms

edgesOri = 0:30:180;
edgesDiff = -90:15:90;

figure('Color', 'w', 'Position', [200 200 1200 400]);

subplot(1, 3, 1)
histogram(dataOri_group1, edgesOri);
xlabel('Grating preferred orientation (deg)');
ylabel('Cell count');
title('Group 1 data orientation');
xlim([0 180]);
xticks(0:30:180);
grid on

subplot(1, 3, 2)
histogram(modelOri_group1, edgesOri);
xlabel('Model fit orientation (deg)');
ylabel('Cell count');
title('Group 1 model orientation');
xlim([0 180]);
xticks(0:30:180);
grid on

subplot(1, 3, 3)
histogram(diff_group1, edgesDiff);
xlabel('Model - data orientation (deg)');
ylabel('Cell count');
title('Group 1 orientation difference');
xlim([-90 90]);
xticks(-90:30:90);
grid on

sgtitle(sprintf('Group 1: DSI < 0.3 and OSI > 0.5, n = %d', ...
    numel(group1_ii)));

exportgraphics(gcf, 'group1_orientation_histograms.pdf');
%%
allFitted_kList = fittedIdx;

plotGroupModelOriVsTuningPDF( ...
    results, modelRegistry, 'DoG x cos weighted', ...
    avg_resp_dir_all, cellIDs, allFitted_kList, ...
    'all_fitted_three_orientation_fits.pdf', ...
    'All fitted cells');
%%
group1_kList = staModelIdx(group1);

plotGroupModelOriVsTuningPDF( ...
    results, modelRegistry, 'DoG x cos weighted', ...
    avg_resp_dir_all, cellIDs, group1_kList, ...
    'group1_three_orientation_fits.pdf', ...
    'Group 1: DSI < 0.3 and OSI > 0.5');

%%
%% Print Group 1 STA cells

group1_kList = staModelIdx(group1);
group1_cellIDs = fittedCellIDs(group1);

disp(table(group1_kList, group1_cellIDs, DSI(group1), OSI(group1), ...
    'VariableNames', {'STA_Index_k', 'Original_Cell_Index', 'DSI', 'OSI'}));

%% Export Group 1 STAs

pdfFile = 'group1_STA_only.pdf';

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

nPages = ceil(numel(group1_kList) / nPerPage);

for iPage = 1:nPages

    fig = figure('Color', 'w', 'Position', [100 100 1600 1200]);

    tiledlayout(nRows, nCols, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');

    idxStart = (iPage - 1) * nPerPage + 1;
    idxEnd = min(iPage * nPerPage, numel(group1_kList));

    for jj = idxStart:idxEnd

        k = group1_kList(jj);
        iCell = cellIDs(k);

        nexttile
        imagesc(STA_cropped(:, :, k), [-globalClim globalClim]);
        axis image off
        colormap gray

        title(sprintf('Cell %d\nDSI %.2f | OSI %.2f', ...
            iCell, DSI(group1_ii(jj)), OSI(group1_ii(jj))), ...
            'FontSize', 7);
    end

    sgtitle(sprintf('Group 1 STAs | Page %d/%d', iPage, nPages), ...
        'FontWeight', 'bold');

    exportgraphics(fig, pdfFile, 'Append', true);
    close(fig);
end

fprintf('Saved %s\n', pdfFile);

%% Plot FFT-data and envelope+90-data differences

group1_ii = find(group1);

fftMinusData_group1 = nan(numel(group1_ii), 1);
env90MinusData_group1 = nan(numel(group1_ii), 1);

for jj = 1:numel(group1_ii)

    ii = group1_ii(jj);

    k = staModelIdx(ii);
    iCell = fittedCellIDs(ii);

    % Data orientation
    [data_deg, ori_resp, resp] = getDataOrientation(avg_resp_dir_all, iCell);

    % Model orientations
    p = paramCell{k};
    ori = getModelOrientations(p);
    
    env_deg = ori.env_deg;
    env90_deg = ori.env90_deg;
    fft_deg = ori.fft_deg;
    theta_env = ori.theta_env;
    fx_pred = ori.fx;
    fy_pred = ori.fy;

    % Differences
    fftMinusData_group1(jj) = angleDiff180(fft_deg, data_deg);
    env90MinusData_group1(jj) = angleDiff180(env90_deg, data_deg);
end

%% Histogram comparison

edgesDiff = -90:15:90;

figure('Color', 'w', 'Position', [200 200 900 400]);

subplot(1, 2, 1)
histogram(fftMinusData_group1, edgesDiff);
xlabel('FFT/carrier - data orientation (deg)');
ylabel('Cell count');
title('Group 1: FFT - data');
xlim([-90 90]);
xticks(-90:30:90);
grid on

subplot(1, 2, 2)
histogram(env90MinusData_group1, edgesDiff);
xlabel('Envelope + 90 - data orientation (deg)');
ylabel('Cell count');
title('Group 1: envelope + 90 - data');
xlim([-90 90]);
xticks(-90:30:90);
grid on

sgtitle(sprintf('Group 1 orientation mismatch comparison, n = %d', ...
    numel(group1_ii)));

exportgraphics(gcf, 'group1_fft_and_env90_minus_data.pdf');


%% Offset axis - data orientation difference

group1_ii = find(group1);

offsetMinusData_group1 = nan(numel(group1_ii), 1);
offsetOri_group1 = nan(numel(group1_ii), 1);
dataOri_group1 = nan(numel(group1_ii), 1);

for jj = 1:numel(group1_ii)

    ii = group1_ii(jj);

    k = staModelIdx(ii);
    iCell = fittedCellIDs(ii);

    % Data orientation
    [data_deg, ori_resp, resp] = getDataOrientation(avg_resp_dir_all, iCell);
    dataOri_group1(jj) = data_deg;

    % Offset orientation from dx/dy
    p = paramCell{k};

    dx = p(11);
    dy = p(12);
    offsetMag = hypot(dx, dy);
    
    if offsetMag < 1
        offset_deg = NaN;
    else
        offset_deg = mod(rad2deg(atan2(dy, dx)), 180);
    end
        %offset_deg = mod(rad2deg(atan2(dy, dx)), 180);

    offsetOri_group1(jj) = offset_deg;

    % Difference to data
    offsetMinusData_group1(jj) = angleDiff180(offset_deg, data_deg);
end

%% Plot offset-data difference

edgesDiff = -90:15:90;

figure('Color', 'w', 'Position', [200 200 700 500]);

histogram(offsetMinusData_group1, edgesDiff);
xlabel('Offset axis - data orientation (deg)');
ylabel('Cell count');
title(sprintf('Group 1: dx/dy offset axis vs data, n = %d', ...
    numel(group1_ii)));
xlim([-90 90]);
xticks(-90:30:90);
grid on

exportgraphics(gcf, 'group1_offset_axis_minus_data.pdf');

%%
%% Group 2
%% Compute F1/F0 for fitted cells

idx = sub2ind(size(F1F0_all), ...
    (1:size(F1F0_all, 1))', DSI_prefdir(:));

pref_F1F0_all = F1F0_all(idx);

F1F0_fitted = pref_F1F0_all(fittedCellIDs);

top20_cutoff = prctile(F1F0_fitted, 80);

groupTopF1F0 = F1F0_fitted >= top20_cutoff;

topF1F0_table = table( ...
    find(groupTopF1F0), ...
    staModelIdx(groupTopF1F0), ...
    fittedCellIDs(groupTopF1F0), ...
    F1F0_fitted(groupTopF1F0), ...
    DSI(groupTopF1F0), ...
    OSI(groupTopF1F0), ...
    'VariableNames', { ...
    'FittedIndex_ii', ...
    'STA_Model_Index_k', ...
    'Original_Cell_Index_iCell', ...
    'F1F0', ...
    'DSI', ...
    'OSI'});

disp(topF1F0_table);

fprintf('Top 20%% F1/F0 group count: %d / %d fitted cells\n', ...
    sum(groupTopF1F0), nFitted);
%%
plotGroupModelOriVsTuningPDF( ...
    results, modelRegistry, 'DoG x cos weighted', ...
    avg_resp_dir_all, cellIDs, topF1F0_kList, ...
    'top20_F1F0_three_orientation_fits.pdf', ...
    'Top 20% F1/F0 cells');
%% Top 20% F1/F0 orientation distributions and differences

topF1F0_ii = find(groupTopF1F0);

dataOri_topF1F0 = nan(numel(topF1F0_ii), 1);
modelOri_topF1F0 = nan(numel(topF1F0_ii), 1);
diff_topF1F0 = nan(numel(topF1F0_ii), 1);

for jj = 1:numel(topF1F0_ii)

    ii = topF1F0_ii(jj);

    k = staModelIdx(ii);
    iCell = fittedCellIDs(ii);

    [data_deg, ~, ~] = getDataOrientation(avg_resp_dir_all, iCell);
    ori = getModelOrientations(paramCell{k});

    dataOri_topF1F0(jj) = data_deg;
    modelOri_topF1F0(jj) = ori.env_deg;

    diff_topF1F0(jj) = angleDiff180( ...
        modelOri_topF1F0(jj), dataOri_topF1F0(jj));
end

%% Plot Top 20% F1/F0 histograms

edgesOri = 0:30:180;
edgesDiff = -90:15:90;

figure('Color', 'w', 'Position', [200 200 1200 400]);

subplot(1, 3, 1)
histogram(dataOri_topF1F0, edgesOri);
xlabel('Grating preferred orientation (deg)');
ylabel('Cell count');
title('Top 20% F1/F0 data orientation');
xlim([0 180]);
xticks(0:30:180);
grid on

subplot(1, 3, 2)
histogram(modelOri_topF1F0, edgesOri);
xlabel('Model fit orientation (deg)');
ylabel('Cell count');
title('Top 20% F1/F0 model orientation');
xlim([0 180]);
xticks(0:30:180);
grid on

subplot(1, 3, 3)
histogram(diff_topF1F0, edgesDiff);
xlabel('Model - data orientation (deg)');
ylabel('Cell count');
title('Top 20% F1/F0 orientation difference');
xlim([-90 90]);
xticks(-90:30:90);
grid on

sgtitle(sprintf('Top 20%% F1/F0 cells, n = %d', ...
    numel(topF1F0_ii)));

exportgraphics(gcf, 'top20_F1F0_orientation_histograms.pdf');
%% Group 2: Plot FFT-data and envelope+90-data differences

group2_ii = find(groupTopF1F0);

fftMinusData_group2 = nan(numel(group2_ii), 1);
env90MinusData_group2 = nan(numel(group2_ii), 1);

for jj = 1:numel(group2_ii)

    ii = group2_ii(jj);

    k = staModelIdx(ii);
    iCell = fittedCellIDs(ii);

    [data_deg, ~, ~] = getDataOrientation(avg_resp_dir_all, iCell);
    ori = getModelOrientations(paramCell{k});

    fftMinusData_group2(jj) = angleDiff180(ori.fft_deg, data_deg);
    env90MinusData_group2(jj) = angleDiff180(ori.env90_deg, data_deg);
end

%% Group 2 histogram comparison

edgesDiff = -90:15:90;

figure('Color', 'w', 'Position', [200 200 900 400]);

subplot(1, 2, 1)
histogram(fftMinusData_group2, edgesDiff);
xlabel('FFT/carrier - data orientation (deg)');
ylabel('Cell count');
title('Group 2: FFT - data');
xlim([-90 90]);
xticks(-90:30:90);
grid on

subplot(1, 2, 2)
histogram(env90MinusData_group2, edgesDiff);
xlabel('Envelope + 90 - data orientation (deg)');
ylabel('Cell count');
title('Group 2: envelope + 90 - data');
xlim([-90 90]);
xticks(-90:30:90);
grid on

sgtitle(sprintf('Group 2 orientation mismatch comparison, n = %d', ...
    numel(group2_ii)));

exportgraphics(gcf, 'group2_fft_and_env90_minus_data.pdf');
%% Export all fitted STAs

pdfFile = 'all_fitted_STA_only.pdf';

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

allFitted_kList = fittedIdx;
nPages = ceil(numel(allFitted_kList) / nPerPage);

for iPage = 1:nPages

    fig = figure('Color', 'w', 'Position', [100 100 1600 1200]);

    tiledlayout(nRows, nCols, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');

    idxStart = (iPage - 1) * nPerPage + 1;
    idxEnd = min(iPage * nPerPage, numel(allFitted_kList));

    for jj = idxStart:idxEnd

        k = allFitted_kList(jj);
        iCell = cellIDs(k);

        nexttile
        imagesc(STA_cropped(:, :, k), [-globalClim globalClim]);
        axis image off
        colormap gray

        ii = find(staModelIdx == k, 1);

        title(sprintf('Cell %d\nDSI %.2f | OSI %.2f', ...
            iCell, DSI(ii), OSI(ii)), ...
            'FontSize', 7);
    end

    sgtitle(sprintf('All fitted STAs | Page %d/%d', iPage, nPages), ...
        'FontWeight', 'bold');

    exportgraphics(fig, pdfFile, 'Append', true);
    close(fig);
end

fprintf('Saved %s\n', pdfFile);
%% Check fitted theta distribution

theta_fit = nan(numel(fittedIdx), 1);
theta_env = nan(numel(fittedIdx), 1);
fft_ori = nan(numel(fittedIdx), 1);

for ii = 1:numel(fittedIdx)

    k = fittedIdx(ii);
    p = paramCell{k};

    theta = p(6);
    tau = p(5);
    f = p(9);

    theta_fit(ii) = mod(rad2deg(theta), 180);

    theta_env_i = theta;
    if tau < 1
        theta_env_i = theta + pi / 2;
    end

    theta_env(ii) = mod(rad2deg(-theta_env_i), 180);

    fx = f * cos(theta);
    fy = f * sin(theta);
    fft_ori(ii) = mod(rad2deg(atan2(fy, fx)), 180);
end

figure;
histogram(theta_fit, 0:15:180);
xlabel('Raw fitted theta (deg)');
ylabel('Cell count');
title('Raw fitted theta distribution');
xlim([0 180]);
grid on;
%%
function checkSingleCellDSIOSI(avg_resp_dir_all, iCell)
%CHECKSINGLECELLDSIOSI Plot raw direction tuning and orientation tuning.
%
% Args:
%     avg_resp_dir_all: response array.
%     iCell: original cell index into avg_resp_dir_all.

    nStimDir = size(avg_resp_dir_all, 2);
    nOri = nStimDir / 2;

    dirDeg = 0:(360 / nStimDir):(360 - 360 / nStimDir);
    oriDeg = 0:(360 / nStimDir):(180 - 360 / nStimDir);

    %% Raw direction response

    resp_raw = squeeze(avg_resp_dir_all(iCell, :, 1, 1, 1));
    resp = resp_raw;
    resp(resp < 0) = 0;

    %% DSI: preferred direction vs opposite direction

    [Rpref_dir, prefDirInd] = max(resp);

    nullInd = prefDirInd + nOri;
    if nullInd > nStimDir
        nullInd = nullInd - nStimDir;
    end

    Rnull = resp(nullInd);

    if Rpref_dir + Rnull > 0
        DSI = (Rpref_dir - Rnull) / (Rpref_dir + Rnull);
    else
        DSI = NaN;
    end

    %% OSI: preferred orientation vs orthogonal orientation

    ori_resp = (resp(1:nOri) + resp(nOri + 1:end)) / 2;

    [Rpref_ori, prefOriInd] = max(ori_resp);

    orthInd = prefOriInd + nStimDir / 4;
    if orthInd > nOri
        orthInd = orthInd - nOri;
    end

    Rorth = ori_resp(orthInd);

    if Rpref_ori + Rorth > 0
        OSI = (Rpref_ori - Rorth) / (Rpref_ori + Rorth);
    else
        OSI = NaN;
    end

    %% Print values

    fprintf('\nCell %d\n', iCell);
    fprintf('Preferred direction: %.1f deg, response %.3f\n', ...
        dirDeg(prefDirInd), Rpref_dir);
    fprintf('Null direction: %.1f deg, response %.3f\n', ...
        dirDeg(nullInd), Rnull);
    fprintf('DSI = %.3f\n', DSI);

    fprintf('Preferred orientation: %.1f deg, response %.3f\n', ...
        oriDeg(prefOriInd), Rpref_ori);
    fprintf('Orthogonal orientation: %.1f deg, response %.3f\n', ...
        oriDeg(orthInd), Rorth);
    fprintf('OSI = %.3f\n', OSI);

    %% Plot eye-test figure

    figure('Color', 'w', 'Position', [200 200 1100 450]);

    subplot(1, 2, 1)
    plot(dirDeg, resp_raw, '-ko', 'LineWidth', 1.5, ...
        'MarkerFaceColor', 'k');
    hold on
    plot(dirDeg, resp, '--o', 'LineWidth', 1.2);
    xline(dirDeg(prefDirInd), 'r-', 'LineWidth', 1.5);
    xline(dirDeg(nullInd), 'b-', 'LineWidth', 1.5);
    xlabel('Direction (deg)');
    ylabel('Response');
    title(sprintf('Direction tuning | DSI = %.2f', DSI));
    legend('Raw response', 'Negative clipped', ...
        'Preferred dir', 'Null dir', ...
        'Location', 'best');
    xlim([0 330]);
    xticks(0:30:330);
    grid on

    subplot(1, 2, 2)
    plot(oriDeg, ori_resp, '-ko', 'LineWidth', 1.5, ...
        'MarkerFaceColor', 'k');
    hold on
    xline(oriDeg(prefOriInd), 'r-', 'LineWidth', 1.5);
    xline(oriDeg(orthInd), 'b-', 'LineWidth', 1.5);
    xlabel('Orientation (deg)');
    ylabel('Average response');
    title(sprintf('Orientation tuning | OSI = %.2f', OSI));
    legend('Orientation response', 'Preferred ori', ...
        'Orthogonal ori', ...
        'Location', 'best');
    xlim([0 150]);
    xticks(0:30:150);
    grid on

    sgtitle(sprintf('Cell %d tuning sanity check', iCell), ...
        'FontWeight', 'bold');
end

function d = angleDiff180(a, b)
%ANGLEDIFF180 Signed orientation difference in [-90, 90].

    d = a - b;
    d = mod(d + 90, 180) - 90;
end

function plotGroupModelOriVsTuningPDF( ...
    results, modelRegistry, modelName, avg_resp_dir_all, cellIDs, ...
    kList, pdfFile, figTitle)

    modelIdx = find(strcmp({modelRegistry.name}, modelName), 1);
    assert(~isempty(modelIdx), 'Model name not found.');

    RF_cells = results.models{modelIdx};
    paramCell = results.params{modelIdx};

    nStimDir = size(avg_resp_dir_all, 2);
    nOri = nStimDir / 2;

    oriDeg = 0:(360 / nStimDir):(180 - 360 / nStimDir);

    if exist(pdfFile, 'file')
        delete(pdfFile);
    end

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

            %% Get data orientation tuning

            [data_deg, ori_resp, resp] = getDataOrientation(avg_resp_dir_all, iCell);

            %% Get model orientations

            theta = p(6);
            tau = p(5);
            f = p(9);

            theta_env = theta;
            if tau < 1
                theta_env = theta + pi / 2;
            end

            env_deg = mod(rad2deg(-theta_env), 180);

            fx_pred = f * cos(theta);
            fy_pred = f * sin(theta);
            fft_deg = mod(rad2deg(atan2(fy_pred, fx_pred)), 180);

            env_diff = abs(angleDiff180(env_deg, data_deg));
            fft_diff = abs(angleDiff180(fft_deg, data_deg));

            %% Left panel: model RF with overlays

            subplot(nRows, nCols, panelRF)

            if isempty(rf) || any(~isfinite(rf(:)))
                axis off
                title(sprintf('Cell %d invalid RF', iCell), ...
                    'FontSize', 7);
            else
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

                % Red = envelope orientation
                plotOriLine(cx, cy, L, theta_env, 'r-', false);

                % Yellow = FFT/carrier orientation, y-flipped display
                theta_fft_display = atan2(-fy_pred, fx_pred);
                plotOriLine(cx, cy, L, theta_fft_display, 'y-', false);

                % Cyan = data grating orientation, y-flipped display
                theta_data_display = deg2rad(-data_deg);
                plotOriLine(cx, cy, L, theta_data_display, 'c-', false);

                title(sprintf(['Cell %d\nData %.0f | Env %.0f d %.0f\n' ...
                    'FFT %.0f d %.0f'], ...
                    iCell, data_deg, env_deg, env_diff, ...
                    fft_deg, fft_diff), ...
                    'FontSize', 7);

                hold off
            end

            %% Right panel: orientation tuning curve

            subplot(nRows, nCols, panelTC)

            oriDegPlot = [oriDeg, 180];
            oriRespPlot = [ori_resp(:)', ori_resp(1)];

            plot(oriDegPlot, oriRespPlot, '-ko', ...
                'LineWidth', 1.2, 'MarkerSize', 4);
            hold on

            xline(data_deg, 'c-', 'LineWidth', 1.4);
            xline(env_deg, 'r-', 'LineWidth', 1.4);
            xline(fft_deg, 'y-', 'LineWidth', 1.4);

            xlabel('Ori (deg)');
            ylabel('Resp');
            xlim([0 180]);
            xticks(0:30:180);
            grid on

            title(sprintf('Cell %d tuning', iCell), ...
                'FontSize', 7);

            hold off
        end

        sgtitle(sprintf('%s | Page %d/%d', ...
            figTitle, iPage, nPages), ...
            'FontWeight', 'bold');

        exportgraphics(fig, pdfFile, 'Append', true);
        close(fig);
    end

    fprintf('Saved PDF: %s\n', pdfFile);
end

function plotOriLine(cx, cy, L, thetaDisplay, lineSpec, useHold)

    if nargin < 6
        useHold = true;
    end

    if useHold
        hold on
    end

    ux = cos(thetaDisplay);
    uy = sin(thetaDisplay);

    plot([cx - L * ux, cx + L * ux], ...
         [cy - L * uy, cy + L * uy], ...
         lineSpec, 'LineWidth', 1.6);
end

function [data_deg, ori_resp, resp] = getDataOrientation(avg_resp_dir_all, iCell)
    nStimDir = size(avg_resp_dir_all, 2);
    nOri = nStimDir / 2;
    oriDeg = 0:(360 / nStimDir):(180 - 360 / nStimDir);

    resp = squeeze(avg_resp_dir_all(iCell, :, 1, 1, 1));
    resp(resp < 0) = 0;

    ori_resp = (resp(1:nOri) + resp(nOri + 1:end)) / 2;
    [~, prefOriInd] = max(ori_resp);

    data_deg = oriDeg(prefOriInd);
end

function ori = getModelOrientations(p)
    theta = p(6);
    tau = p(5);
    f = p(9);

    theta_env = theta;
    if tau < 1
        theta_env = theta + pi / 2;
    end

    ori.env_deg = mod(rad2deg(-theta_env), 180);
    ori.env90_deg = mod(ori.env_deg + 90, 180);

    fx = f * cos(theta);
    fy = f * sin(theta);

    ori.fft_deg = mod(rad2deg(atan2(fy, fx)), 180);
    ori.theta_env = theta_env;
    ori.fx = fx;
    ori.fy = fy;
end