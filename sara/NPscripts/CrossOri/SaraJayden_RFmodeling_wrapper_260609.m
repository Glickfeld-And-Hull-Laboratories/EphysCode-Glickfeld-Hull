close all; clearvars; clc;

%% debug mode one cell test
debugMode = false;
debugCell = 1080;   % check indRFint
%rng(0,'twister');   % randomness fully reproducible

%% Load data 
% load file with data concatenated across experiments

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

totalCells = totCells;   % cell number

fprintf('Loaded %d cells.\n', totalCells);

%%
vars = whos('-file', fullfile(analysisDir, ...
    'CrossOri_randDirFourPhase_summary.mat'));

for i = 1:numel(vars)
    fprintf('%-35s %s\n', vars(i).name, mat2str(vars(i).size));
end

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
% Use visually responsive cells with DS > .5 and reliable RFs.
cellsSelected = intersect(idxInt, ind_DS);


if debugMode
    assert(ismember(debugCell, cellsSelected), ...
        'debugCell is not in cellsSelected.');
    cellsSelected = debugCell;
end

cellIDs = cellsSelected(:);

fprintf('Selected %d cells for fitting.\n', numel(cellIDs));

%%

rfvisresp = intersect(resp_ind_dir_all, idxInt);
figure; 
    histogram(DSI_all(rfvisresp),100)

 xxx = find(DSI_all(rfvisresp)<.3);




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

sideLength = 20; 
nSelected = numel(cellIDs); 
STA_cropped_allTP = nan(sideLength, sideLength, nSelected, 4); 

for k = 1:nSelected 
    for it = 1:4 
        ic = cellIDs(k); 

        avgImgZscore = squeeze(avgImgZscore_all(ic, :, :, :)); 

        bestTP = bestTimePoint_all(ic, 1); 
        dataBest = squeeze(avgImgZscore(bestTP, :, :));
        dataBest = medfilt2(imgaussfilt(dataBest, 1));
        [el, az] = getRFcenter(dataBest); 

        data = squeeze(avgImgZscore(it, :, :)); 
        data = medfilt2(imgaussfilt(data, 1)); 

        STA_cropped_allTP(:, :, k, it) = cropRFtoCenter(az, el, data, sideLength); 
    end 
end




pdfFile = fullfile(pwd, 'STA_cells_allTimepoints_cropped.pdf');

for k = 1:nSelected
    ic = cellIDs(k);
    bestTP = bestTimePoint_all(ic, 1);
    
    f = figure('Visible', 'off', 'Color', 'w');
    
    for it = 1:4
        subplot(1,4,it);

        img(isnan(img)) = 0;
        img = STA_cropped_allTP(:, :, k, it);
        
        imagesc(img);
        colormap(gray);   % <-- FIXED
        caxis([-4 4])
        axis image off;
        
        
        if it == 1
            title(sprintf('Cell %d | bestTP = %d', ic, bestTP));
        end
        
    end

     drawnow;  % ensures figure is fully rendered

    if k == 1
        saveas(f, pdfFile);              % create file
    else
        exportgraphics(f, pdfFile, 'Append', true);  % append pages
    end
    close(f);
end

fprintf('Saved PDF to: %s\n', pdfFile);




%%
%% ============================================================
% Export best-time-point STAs
% 30 cells per page
%% ============================================================

%% ============================================================
% One page per cell: all STA time points
%% ============================================================

outDir = pwd;

cellsToPlot = cellsSelected(:);   % original cell IDs
timePointsToShow = 1:size(avgImgZscore_all, 2);

outPdf = fullfile(outDir, 'STA_all_timepoints_one_cell_per_page.pdf');

if exist(outPdf, 'file')
    delete(outPdf);
end

for iCell = 1:numel(cellsToPlot)

    ic = cellsToPlot(iCell);
    nTP = numel(timePointsToShow);

    allSTA = squeeze(avgImgZscore_all(ic, timePointsToShow, :, :));
    clim = max(abs(allSTA(:)), [], 'omitnan');

    if ~isfinite(clim) || clim == 0
        clim = 1;
    end

    fig = figure('Color', 'w', ...
        'Position', [100 100 220*nTP 300]);

    tiledlayout(1, nTP, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');

    for j = 1:nTP

        it = timePointsToShow(j);

        STA = squeeze(avgImgZscore_all(ic, it, :, :));
        STA = medfilt2(imgaussfilt(STA, 1));

        nexttile;
        imagesc(STA, [-clim clim]);
        axis image off;
        colormap gray;

        if it == bestTimePoint_all(ic, 1)
            title(sprintf('t%d best', it), ...
                'FontSize', 10, ...
                'FontWeight', 'bold');
        else
            title(sprintf('t%d', it), ...
                'FontSize', 10);
        end
    end

    sgtitle(sprintf('Cell %d STA across time points', ic), ...
        'FontWeight', 'bold');

    exportgraphics(fig, outPdf, ...
        'Append', true, ...
        'ContentType', 'image');

    close(fig);

    fprintf('Saved cell %d / %d: cellID %d\n', ...
        iCell, numel(cellsToPlot), ic);
end

fprintf('\nSaved PDF: %s\n', outPdf);
%% Run Gabor fit
options.visualize = 0;
options.parallel  = 1;
options.shape     = 'equal';
options.runs      = 48;
% options.getAllFits = false;

% copy format from the first example
modelRegistry = [
    % 
    struct( ...
        'name','Circular DoG', ...
        'type','standard', ...
        'fitFcn', @(STA) fitDoG2D(STA), ...
        'k',6)
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
    % 
    struct( ...
        'name','Gabor', ...
        'type','sg', ...
        'fitFcn', @(STA) fit2dGabor_JM(STA,options), ...
        'k',10)
    % struct( ...
    %     'name','DoG x cos alpha', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitNoncDoGCosineRF_sigmaXY(STA), ...
    %     'k',13)

    % struct( ...
    %     'name','DoG x cos tau', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitNoncDoGCosineRF_tau(STA), ...
    %      'k',11)
     struct( ...
        'name','DoG x cos', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNoncDoGCosineRF_tau(STA), ...
        'k',11)
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
    'test_all_fit.pdf');

%%
modelNames = {results.modelRegistry.name};
nModels = numel(modelNames);

R2mat = nan(numel(results.cellIDs), nModels);

for m = 1:nModels
    R2mat(:, m) = results.R2{m};
end

R2table = array2table(R2mat, ...
    'VariableNames', matlab.lang.makeValidName(modelNames));

R2table.cellID = results.cellIDs;
R2table = movevars(R2table, 'cellID', 'Before', 1);

disp(R2table)


%%
%% ============================================================
% Model R2 comparison: DoG, Gabor, Hybrid
%% ============================================================

disp(modelNames')

dogIdx = find(contains(modelNames, 'Circular DoG', 'IgnoreCase', true) & ...
              ~contains(modelNames, 'cos', 'IgnoreCase', true), 1);

gaborIdx = find(contains(modelNames, 'Gabor', 'IgnoreCase', true), 1);

hybridIdx = find(contains(modelNames, 'DoG x cos', 'IgnoreCase', true), 1);

R2_DoG = R2mat(:, dogIdx);
R2_Gabor = R2mat(:, gaborIdx);
R2_Hybrid = R2mat(:, hybridIdx);

valid = isfinite(R2_DoG) & isfinite(R2_Gabor) & isfinite(R2_Hybrid);

R2_DoG = R2_DoG(valid);
R2_Gabor = R2_Gabor(valid);
R2_Hybrid = R2_Hybrid(valid);

bestSimple = max(R2_DoG, R2_Gabor);
deltaHybrid = R2_Hybrid - bestSimple;

nCells = numel(R2_Hybrid);

fprintf('\n===== Hybrid improvement summary =====\n');
fprintf('N cells = %d\n', nCells);
fprintf('Hybrid > best simple: %.1f%%\n', ...
    100 * mean(deltaHybrid > 0));
fprintf('Hybrid > best simple by >0.02 R2: %.1f%%\n', ...
    100 * mean(deltaHybrid > 0.02));
fprintf('Hybrid > best simple by >0.05 R2: %.1f%%\n', ...
    100 * mean(deltaHybrid > 0.05));

fprintf('pass');
%% C. DoG vs Gabor, color-coded by hybrid improvement

%% ============================================================
% Suggested 3-panel model comparison figure
% 1. DoG vs Gabor, colored by hybrid improvement
% 2. Hybrid vs best simple model
% 3. Hybrid improvement histogram
%% ============================================================

figure('Color', 'w', 'Position', [100 100 1350 390]);

tiledlayout(1, 3, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

%% Panel 1: DoG vs Gabor, color-coded by hybrid improvement
nexttile;

scatter(R2_DoG, R2_Gabor, 45, deltaHybrid, 'filled', ...
    'MarkerFaceAlpha', 0.75);

hold on;
plot([0 1], [0 1], 'k--', 'LineWidth', 1.2);

axis square;
xlim([0 1]);
ylim([0 1]);

xlabel('Circular DoG R^2');
ylabel('Gabor R^2');
title('DoG vs Gabor fit quality');

cb = colorbar;
ylabel(cb, '\DeltaR^2 hybrid - best simple');

grid on;
box off;
set(gca, 'FontSize', 11);

%% Panel 2: Hybrid vs best simple model
nexttile;

scatter(bestSimple, R2_Hybrid, 45, 'filled', ...
    'MarkerFaceAlpha', 0.65);

hold on;
plot([0 1], [0 1], 'k--', 'LineWidth', 1.2);

axis square;
xlim([0 1]);
ylim([0 1]);

xlabel('Best simple model R^2');
ylabel('DoG x cos R^2');
title('Hybrid vs best simple model');

grid on;
box off;
set(gca, 'FontSize', 11);

%% Panel 3: Hybrid improvement histogram
nexttile;

histogram(deltaHybrid, 20, ...
    'FaceColor', [0.4 0.7 0.9], ...
    'EdgeColor', 'k');

hold on;
xline(0, 'k--', 'LineWidth', 1.3);
xline(median(deltaHybrid, 'omitnan'), 'r-', 'LineWidth', 1.3);

xlabel('\DeltaR^2 = hybrid - best simple');
ylabel('Number of cells');
title('Hybrid improvement');

grid on;
box off;
set(gca, 'FontSize', 11);

sgtitle('DoG x cosine model captures RF structure beyond simple DoG or Gabor models', ...
    'FontSize', 15, ...
    'FontWeight', 'bold');

%% Optional print summary
fprintf('\n===== Hybrid improvement summary =====\n');
fprintf('N cells = %d\n', nCells);
fprintf('Hybrid > best simple: %.1f%%\n', ...
    100 * mean(deltaHybrid > 0));
fprintf('Hybrid > best simple by >0.02 R2: %.1f%%\n', ...
    100 * mean(deltaHybrid > 0.02));
fprintf('Hybrid > best simple by >0.05 R2: %.1f%%\n', ...
    100 * mean(deltaHybrid > 0.05));
fprintf('Median delta R2 = %.4f\n', ...
    median(deltaHybrid, 'omitnan'));
%% ============================================================
% Overlay histogram:
% 1. Circular hybrid improvement over best simple
% 2. Elliptical model improvement over circular hybrid
%% ============================================================

% Assumes:
% R2_DoG
% R2_Gabor
% R2_Hybrid  = circular DoG x cos model R2
%
% Also assumes you have loaded elliptical model summary separately:
% Elliptical summary = A
% Circular summary   = B or current results

%% -----------------------------
% Hybrid circular vs best simple
%% -----------------------------
bestSimple = max(R2_DoG, R2_Gabor);
deltaHybrid = R2_Hybrid - bestSimple;

%% -----------------------------
% Load elliptical model summary
%% -----------------------------
ellipticalFile = "DoGXCosWeightedfull_summary.mat";

SE = load(ellipticalFile);
E = SE.exportSummary;

% Current circular model cell IDs from results
circularCellIDs = results.cellIDs(:);

% Align elliptical and circular cells
commonIDs = intersect(E.cellIDs(:), circularCellIDs);

[~, iE] = ismember(commonIDs, E.cellIDs);
[~, iC] = ismember(commonIDs, circularCellIDs);

R2_Elliptical = E.R2(iE);
R2_Circular = R2_Hybrid(iC);

validEllipse = isfinite(R2_Elliptical) & isfinite(R2_Circular);

R2_Elliptical = R2_Elliptical(validEllipse);
R2_Circular = R2_Circular(validEllipse);

deltaEllipse = R2_Circular - R2_Elliptical;

%% -----------------------------
% Overlay histogram
%% -----------------------------
figure('Color', 'w', 'Position', [100 100 540 430]);

edges = -0.15:0.02:0.40;

h1 = histogram(deltaHybrid, edges, ...
    'Normalization', 'count', ...
    'FaceColor', [0.1 0.45 0.8], ...
    'FaceAlpha', 0.65, ...
    'EdgeColor', 'none');

hold on;

h2 = histogram(deltaEllipse, edges, ...
    'Normalization', 'count', ...
    'FaceColor', [0.7 0.7 0.7], ...
    'FaceAlpha', 0.30, ...
    'EdgeColor', 'none');

xline(0, 'k--', 'LineWidth', 1.2);

xline(median(deltaHybrid, 'omitnan'), ...
    '-', ...
    'Color', [0.1 0.45 0.8], ...
    'LineWidth', 1.5);

xline(median(deltaEllipse, 'omitnan'), ...
    '-', ...
    'Color', [0.4 0.4 0.4], ...
    'LineWidth', 1.5);

xlabel('\DeltaR^2');
ylabel('Number of cells');
title('Model improvement comparison');

legend([h1 h2], ...
    {'Circular hybrid - best simple', ...
     'Circular hybrid - elliptical hybrid'}, ...
    'Location', 'northeast', ...
    'Box', 'off');

grid on;
box off;
set(gca, 'FontSize', 12);

%% -----------------------------
% Print summary
%% -----------------------------
fprintf('\n===== Overlay histogram summaries =====\n');

fprintf('Circular hybrid - best simple:\n');
fprintf('N = %d\n', numel(deltaHybrid));
fprintf('Median delta R2 = %.4f\n', median(deltaHybrid, 'omitnan'));
fprintf('Fraction > 0 = %.1f%%\n', 100 * mean(deltaHybrid > 0));

fprintf('\nElliptical hybrid - circular hybrid:\n');
fprintf('N = %d\n', numel(deltaEllipse));
fprintf('Median delta R2 = %.4f\n', median(deltaEllipse, 'omitnan'));
fprintf('Fraction > 0 = %.1f%%\n', 100 * mean(deltaEllipse > 0));
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

%modelName = 'Circular DoG';
modelName = 'DoG x cos';

useVonMisesOri = false;  % true = smooth von Mises, false = raw no fit
outDir = 'group_analysis_cir';
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
cellIDs = results.cellIDs;
fitIdx = (1:numel(cellIDs))';

RF_cells = results.models{modelIdx};
paramCell = results.params{modelIdx};


save(fullfile([pwd, '\CircularDoG_params.mat']),'paramCell', 'RF_cells', 'cellIDs')


%% 



%%


params = cell2mat(paramCell);

clear metrics
for ic = 1:size(params,1)
    metrics(ic) = computeEffectiveEnvelopeGeometry(params(ic,:));
end

As = params(:,2);
Ac = params(:,1);
sigC = params(:,3);
sigS = params(:,3)+params(:,4);

cycles = params(:,9);

        dx = params(:,11);
        dy = params(:,12);
        offsets = sqrt(dx.^2 + dy.^2);

        
figure;
    ax = axes;
    
    As_abs = abs(As);
    
    scatter(As_abs, cycles, 10, 'k') % optional reference points
    xlabel('|As|')
    ylabel('f')
    hold on
    
    axpos = ax.Position;   % position of main axes in figure
    
    for ic = 1:length(As_abs)
    
        % normalize data within axes limits
        xn = (As_abs(ic) - ax.XLim(1)) / diff(ax.XLim);
        yn = (cycles(ic) - ax.YLim(1)) / diff(ax.YLim);
    
        % convert to figure coordinates
        xf = axpos(1) + xn * axpos(3);
        yf = axpos(2) + yn * axpos(4);
    
        w = 0.03;
        h = 0.03;
    
        ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
    
        clim = max(abs(STA_cropped(:)));
        imagesc(STA_cropped(:,:,ic),[-clim clim])
        axis image off
        colormap gray
    end

print(fullfile([pwd, '\STAs_cropped_byCyclesAndAs.pdf']), '-dpdf','-bestfit')




figure;
    ax = axes;
    
    As_abs = abs(As);
    As_norm = As_abs./abs(Ac);

    freq = cycles.*sigC*2;
    dogish = offsets.*sigS;
    dogish2 = offsets.*As_abs;
    
    scatter(dogish2, freq, 10, 'k') % optional reference points
    xlabel('subunit offset * |As|')
    ylabel('cycles (f*sigC*2)')
    hold on
    
    axpos = ax.Position;   % position of main axes in figure
    
    for ic = 1:length(dogish2)
    
        % normalize data within axes limits
        xn = (dogish2(ic) - ax.XLim(1)) / diff(ax.XLim);
        yn = (freq(ic) - ax.YLim(1)) / diff(ax.YLim);
    
        % convert to figure coordinates
        xf = axpos(1) + xn * axpos(3);
        yf = axpos(2) + yn * axpos(4);
    
        w = 0.03;
        h = 0.03;
    
        ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
    
        clim = max(abs(STA_cropped(:)));
        imagesc(STA_cropped(:,:,ic),[-clim clim])
        axis image off
        colormap gray
    end

print(fullfile([pwd, '\STAs_cropped_byCyclesAndAs.pdf']), '-dpdf','-bestfit')


figure(6);
orient(fig,'landscape')
print(fullfile([pwd, '\modelRsqOriComparison.pdf']),  '-dpdf','-bestfit')


% Rank by frequency
% Extract sizes
    freq_vals = cycles;
    [sorted_size, sort_idx] = sort(freq_vals, 'ascend'); % Sort (small → large)
    STA_sorted = STA_cropped(:,:,sort_idx);

figure;
    for i = 1:nCells
        subplot(nRows, nCols, i)
            clim = max(abs(STA_sorted(:,:,i)), [], 'all');
            imagesc(STA_sorted(:,:,i), [-clim clim])
            axis image off
            colormap gray
            % title(sprintf('%.2f', sorted_size(i))) % show size
    end
    sgtitle('STAs ranked by freq')
    print(fullfile(pwd, 'STAs_ranked_by_freq.pdf'), '-dpdf', '-bestfit')





% Rank by effective size
% Extract sizes
    size_vals = [metrics(:).size_eff];
    [sorted_size, sort_idx] = sort(size_vals, 'ascend'); % Sort (small → large)
    STA_sorted = STA_cropped(:,:,sort_idx);


nCells = length(sort_idx);
nCols = ceil(sqrt(nCells));
nRows = ceil(nCells / nCols);

figure;
    for i = 1:nCells
        subplot(nRows, nCols, i)
            clim = max(abs(STA_sorted(:,:,i)), [], 'all');
            imagesc(STA_sorted(:,:,i), [-clim clim])
            axis image off
            colormap gray
            title(sprintf('%.2f', sorted_size(i))) % show size
    end
    sgtitle('STAs ranked by effective size')
    print(fullfile(pwd, 'STAs_ranked_by_size.pdf'), '-dpdf', '-bestfit')





% Rank by elongation
% Extract sizes
    elong_vals = [metrics(:).elongation_eff];
    [sorted_size, sort_idx] = sort(elong_vals, 'ascend'); % Sort (small → large)
    STA_sorted = STA_cropped(:,:,sort_idx);

figure;
    for i = 1:nCells
        subplot(nRows, nCols, i)
            clim = max(abs(STA_sorted(:,:,i)), [], 'all');
            imagesc(STA_sorted(:,:,i), [-clim clim])
            axis image off
            colormap gray
            title(sprintf('%.2f', sorted_size(i))) % show size
    end
    sgtitle('STAs ranked by elongation')
    print(fullfile(pwd, 'STAs_ranked_by_elongation.pdf'), '-dpdf', '-bestfit')



% Rank by elongation of center subunit
% Extract sizes
    elongC_vals = [metrics(:).elongationCent_eff];
    [sorted_size, sort_idx] = sort(elongC_vals, 'ascend'); % Sort (small → large)
    STA_sorted = STA_cropped(:,:,sort_idx);

figure;
    for i = 1:nCells
        subplot(nRows, nCols, i)
            clim = max(abs(STA_sorted(:,:,i)), [], 'all');
            imagesc(STA_sorted(:,:,i), [-clim clim])
            axis image off
            colormap gray
            title(sprintf('%.2f', sorted_size(i))) % show size
    end
    sgtitle('STAs ranked by elongationCenter')
    print(fullfile(pwd, 'STAs_ranked_by_elongationCenter.pdf'), '-dpdf', '-bestfit')


% Rank by area
% Extract sizes
    area_vals = [metrics(:).area_eff];
    [sorted_size, sort_idx] = sort(area_vals, 'ascend'); % Sort (small → large)
    STA_sorted = STA_cropped(:,:,sort_idx);

figure;
    for i = 1:nCells
        subplot(nRows, nCols, i)
            clim = max(abs(STA_sorted(:,:,i)), [], 'all');
            imagesc(STA_sorted(:,:,i), [-clim clim])
            axis image off
            colormap gray
            title(sprintf('%.2f', sorted_size(i))) % show size
    end
    sgtitle('STAs ranked by area')
    print(fullfile(pwd, 'STAs_ranked_by_area.pdf'), '-dpdf', '-bestfit')




save(fullfile([pwd, '\computed_params.mat']),'offsets', 'metrics')









%%


modelName = 'Circular DoG';

modelIdx = find(strcmp({modelRegistry.name}, modelName), 1);
assert(~isempty(modelIdx), 'Model name not found in modelRegistry.');
cellIDs = results.cellIDs;
fitIdx = (1:numel(cellIDs))';

RF_cells = results.models{modelIdx};
paramCell = results.params{modelIdx};
save(fullfile([pwd, '\2d_circDoG_params.mat']),'paramCell', 'RF_cells')



modelName = 'Gabor';

modelIdx = find(strcmp({modelRegistry.name}, modelName), 1);
assert(~isempty(modelIdx), 'Model name not found in modelRegistry.');
cellIDs = results.cellIDs;
fitIdx = (1:numel(cellIDs))';

RF_cells = results.models{modelIdx};
paramCell = results.params{modelIdx};
save(fullfile([pwd, '\Gabor_params.mat']),'paramCell', 'RF_cells')














%% Compute metrics once for all fitted cells
sgRawFit = results.sgRawFit{modelIdx}; % change this
sgRawFit = {};
metrics = computeFittedCellMetrics( ...
    avg_resp_dir_all, fitIdx, cellIDs, paramCell, sgRawFit);
fprintf('pass\n')
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
% 
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
% allMask = true(metrics.nFitted, 1);
% 
% plotOrientationStatsForPoster( ...
%     metrics, ...
%     allMask, ...
%     'All fitted cells, n = 209', ...
%     fullfile(outDir, 'all_fitted_orientation_stats'));
%%
% plotCellGroupingPanel(metrics, outDir);
%% Example cell RF + tuning summary
% Run manually for OS, DS, and ambiguous example cells.

cellIDToPlot = 353;   % real/original cell ID, not row index

rowIdx = find(results.cellIDs == cellIDToPlot, 1);

if isempty(rowIdx)
    error('Cell ID %d was not found in results.cellIDs.', cellIDToPlot);
end
%% -----------------------------
% User inputs to check/change
%% -----------------------------
STA = STA_cropped(:, :, rowIdx);
modelRF = results.models{modelIdx}{rowIdx};

dataOriDeg = metrics.dataOriDeg(rowIdx);
modelOriDeg = metrics.fftDeg(rowIdx);

resp = squeeze(avg_resp_dir_all(cellIDToPlot, :, 1, 1, 1));

%% -----------------------------
% Extract raw direction response
%% -----------------------------
resp(resp < 0) = 0;

nStimDir = numel(resp);
nOri = nStimDir / 2;

dirDeg = linspace(0, 360, nStimDir + 1);
respDirClosed = [resp(:); resp(1)];

oriResp = (resp(1:nOri) + resp(nOri + 1:end)) / 2;
oriDeg = linspace(0, 180, nOri + 1);
respOriClosed = [oriResp(:); oriResp(1)];

thetaDir = deg2rad(dirDeg);

%% -----------------------------
% Plot compact example row
%% -----------------------------
figure('Color', 'w', 'Position', [100 100 1800 360]);

t = tiledlayout(1, 5, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

%% 1. STA
nexttile;
imagesc(STA);
axis image off;
colormap gray;
title(sprintf('Cell %d STA', cellIDToPlot), 'FontWeight', 'bold');

%% 2. Model fit + orientation overlays
nexttile;
imagesc(modelRF);
axis image off;
colormap gray;
hold on;

plotOrientationLine(gca, dataOriDeg, size(modelRF), 'c', 2.5);
plotOrientationLine(gca, modelOriDeg, size(modelRF), 'y', 2.5);

title(sprintf('Model fit\ncyan = data, yellow = model'), ...
    'FontWeight', 'bold');

%% 3. Direction tuning curve
nexttile;
plot(dirDeg, respDirClosed, '-o', ...
    'Color', 'k', ...
    'MarkerFaceColor', 'k', ...
    'LineWidth', 2, ...
    'MarkerSize', 5);

xlim([0 360]);
xticks(0:60:360);
xlabel('Direction (deg)');
ylabel('Firing rate (Hz)');
title('Direction tuning');
grid on;
box off;

%% 4. Orientation tuning curve
nexttile;
plot(oriDeg, respOriClosed, '-o', ...
    'Color', 'k', ...
    'MarkerFaceColor', 'k', ...
    'LineWidth', 2, ...
    'MarkerSize', 5);

hold on;

yl = ylim;
xline(dataOriDeg, 'c-', 'LineWidth', 2);
xline(modelOriDeg, 'y-', 'LineWidth', 2);

ylim(yl);
xlim([0 180]);
xticks(0:30:180);
xlabel('Orientation (deg)');
ylabel('Firing rate (Hz)');
title('Orientation tuning');
grid on;
box off;

%% 5. Direction polar plot
nexttile;
polarplot(thetaDir, respDirClosed, '-o', ...
    'Color', 'k', ...
    'MarkerFaceColor', 'k', ...
    'LineWidth', 2, ...
    'MarkerSize', 5);

title('Direction polar');

ax = gca;
ax.RAxis.Label.String = 'Firing rate (Hz)';
ax.ThetaZeroLocation = 'right';
ax.ThetaDir = 'counterclockwise';

sgtitle(sprintf('Example cell %d: RF-derived orientation vs measured tuning', ...
    cellIDToPlot), ...
    'FontSize', 15, ...
    'FontWeight', 'bold');

%%

for iGroup = 1:numel(groupDefs)
    runGroupWorkflow( ...
        groupDefs(iGroup), metrics, STA_cropped, RF_cells, paramCell, ...
        avg_resp_dir_all, cellIDs, outDir, useVonMisesOri, oriFitStruct);
end
%% Export model summary after each model run
% FFT test
%% Compare fitted model theta to FFT orientation measured directly from STA

nCells = size(STA_cropped, 3);
staFftDeg = nan(nCells, 1);

for i = 1:nCells

    STA = STA_cropped(:, :, i);

    staFftDeg(i) = getSTAFFTOrientation(STA);
end

modelDeg = summary.fftDeg(:);

valid = isfinite(staFftDeg) & isfinite(modelDeg);

diffModelSTA = abs(angleDiff180(modelDeg(valid), staFftDeg(valid)));

fprintf('\n===== Model theta vs STA FFT orientation =====\n');
fprintf('Median difference = %.2f deg\n', ...
    median(diffModelSTA, 'omitnan'));
fprintf('Fraction within 15 deg = %.2f%%\n', ...
    100 * mean(diffModelSTA < 15));
fprintf('Fraction within 30 deg = %.2f%%\n', ...
    100 * mean(diffModelSTA < 30));

%% Plot comparison

figure('Color', 'w', 'Position', [100 100 500 430]);

scatter(staFftDeg(valid), modelDeg(valid), 45, summary.R2(valid), ...
    'filled');

hold on;
plot([0 180], [0 180], 'k--', 'LineWidth', 1.2);

xlabel('STA FFT orientation (deg)');
ylabel('Model carrier orientation (deg)');
title('Model orientation vs STA FFT orientation');

xlim([0 180]);
ylim([0 180]);
xticks(0:30:180);
yticks(0:30:180);
axis square;
grid on;
box off;

cb = colorbar;
ylabel(cb, 'R^2');

%% Histograms

figure('Color', 'w', 'Position', [100 100 900 350]);

subplot(1,2,1)
histogram(staFftDeg, 0:15:180);
xlabel('STA FFT orientation (deg)');
ylabel('Cell count');
title('STA-derived FFT orientation');
xlim([0 180]);
xticks(0:30:180);
grid on;

subplot(1,2,2)
histogram(modelDeg, 0:15:180);
xlabel('Model carrier orientation (deg)');
ylabel('Cell count');
title('Model fitted carrier orientation');
xlim([0 180]);
xticks(0:30:180);
grid on;


%% Compare carrier/theta prediction error across groups

carrierDeg = metrics.fftDeg;        % model theta / carrier axis
dataDeg = metrics.dataOriDeg;       % measured orientation tuning

carrierErr = abs(angleDiff180(carrierDeg, dataDeg));

groupNames = strings(numel(groupDefs), 1);
errCell = cell(numel(groupDefs), 1);

for iGroup = 1:numel(groupDefs)

    groupNames(iGroup) = string(groupDefs(iGroup).name);

    mask = groupDefs(iGroup).mask;

    valid = mask(:) & ...
        isfinite(carrierErr(:)) & ...
        isfinite(carrierDeg(:)) & ...
        isfinite(dataDeg(:));

    errCell{iGroup} = carrierErr(valid);

    fprintf('\n===== %s =====\n', groupNames(iGroup));
    fprintf('N = %d\n', sum(valid));
    fprintf('Median carrier error = %.2f deg\n', ...
        median(carrierErr(valid), 'omitnan'));
    fprintf('Mean carrier error = %.2f deg\n', ...
        mean(carrierErr(valid), 'omitnan'));
end
%% Build long-format table for plotting

allErr = [];
allGroup = strings(0, 1);

for iGroup = 1:numel(groupDefs)
    thisErr = errCell{iGroup};

    allErr = [allErr; thisErr(:)];
    allGroup = [allGroup; ...
        repmat(groupNames(iGroup), numel(thisErr), 1)];
end

T = table(allGroup, allErr, ...
    'VariableNames', {'Group', 'CarrierErrorDeg'});

%% Boxplot comparison

figure('Color', 'w', 'Position', [100 100 650 450]);

boxchart(categorical(T.Group), T.CarrierErrorDeg, ...
    'BoxFaceColor', [0.7 0.7 0.7], ...
    'MarkerColor', [0.3 0.3 0.3], ...
    'LineWidth', 1.5);

ylabel('|Carrier orientation - measured orientation| (deg)');
title('Carrier axis prediction error across groups');

ylim([0 90]);
grid on;
box off;

%%
%% Plot low vs high F1/F0 example temporal responses
% Manually choose original cell IDs
lowCellID = 127;    % change this
highCellID = 107;   % change this

stimHz = 2;
tWindow = [0 1];

%% -----------------------------
% Get time vector and responses
%% -----------------------------
% Change these names if your temporal response variable is named differently.
% Expected format example:
% temporalRespAll: nCells x nTime
% timeVec: 1 x nTime, in seconds

lowResp = temporalRespAll(lowCellID, :);
highResp = temporalRespAll(highCellID, :);

timeMask = timeVec >= tWindow(1) & timeVec <= tWindow(2);

t = timeVec(timeMask);
lowResp = lowResp(timeMask);
highResp = highResp(timeMask);

%% -----------------------------
% Optional: get F1/F0 values
%% -----------------------------
lowF1F0 = metrics.F1F0(results.cellIDs == lowCellID);
highF1F0 = metrics.F1F0(results.cellIDs == highCellID);

%% -----------------------------
% Plot
%% -----------------------------
figure('Color', 'w', 'Position', [100 100 900 350]);

tiledlayout(1, 2, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

%% Low F1/F0
nexttile;
plot(t, lowResp, 'k-', 'LineWidth', 2);
hold on;

xline(0, 'k:');
xline(0.5, 'k:');
xline(1.0, 'k:');

xlabel('Time (s)');
ylabel('Firing rate (Hz)');
title(sprintf('Low F1/F0 example\nCell %d, F1/F0 = %.2f', ...
    lowCellID, lowF1F0));

xlim(tWindow);
grid on;
box off;

%% High F1/F0
nexttile;
plot(t, highResp, 'k-', 'LineWidth', 2);
hold on;

xline(0, 'k:');
xline(0.5, 'k:');
xline(1.0, 'k:');

xlabel('Time (s)');
ylabel('Firing rate (Hz)');
title(sprintf('High F1/F0 example\nCell %d, F1/F0 = %.2f', ...
    highCellID, highF1F0));

xlim(tWindow);
grid on;
box off;

sgtitle('Temporal modulation examples during 2 Hz grating stimulation', ...
    'FontWeight', 'bold');
%%
%% Orientation prediction error across groups + ANOVA
% Uses absolute model-data orientation error.

% Change this if your preferred prediction is fftMinusData instead.
%% Define group masks for fitted cells

DSI = metrics.DSI(:);
OSI = metrics.OSI(:);
F1F0 = metrics.F1F0(:);

group1Mask = DSI < 0.3 & OSI > 0.5;

f1Valid = isfinite(F1F0);
f1Thresh = prctile(F1F0(f1Valid), 80);
group2Mask = f1Valid & F1F0 >= f1Thresh;

group3Mask = DSI > 0.5;

fprintf('Group 1 n = %d\n', sum(group1Mask));
fprintf('Group 2 n = %d\n', sum(group2Mask));
fprintf('Group 3 n = %d\n', sum(group3Mask));

errAll = abs(metrics.fftMinusData);

g1 = errAll(group1Mask);
g2 = errAll(group2Mask);
g3 = errAll(group3Mask);

g1 = g1(isfinite(g1));
g2 = g2(isfinite(g2));
g3 = g3(isfinite(g3));

vals = [g1(:); g2(:); g3(:)];

groupLabels = [
    repmat({'Group 1'}, numel(g1), 1)
    repmat({'Group 2'}, numel(g2), 1)
    repmat({'Group 3'}, numel(g3), 1)
];

%% -----------------------------
% One-way ANOVA
%% -----------------------------
[pAnova, tblAnova, statsAnova] = anova1(vals, groupLabels, 'off');

fprintf('\n===== Orientation prediction error ANOVA =====\n');
fprintf('p = %.4g\n', pAnova);
disp(tblAnova)

posthoc = multcompare(statsAnova, ...
    'Display', 'off');

posthocTable = array2table(posthoc, ...
    'VariableNames', ...
    {'GroupA', 'GroupB', 'LowerCI', 'MeanDiff', 'UpperCI', 'pValue'});

disp(posthocTable)

%% -----------------------------
% Plot boxplot
%% -----------------------------
figure('Color', 'w', 'Position', [100 100 560 430]);

boxchart(categorical(groupLabels), vals, ...
    'BoxFaceColor', [0.8 0.8 0.8], ...
    'MarkerColor', [0.4 0.4 0.4], ...
    'LineWidth', 1.4);

ylabel('|Model orientation - measured orientation| (deg)');
title(sprintf('Orientation prediction error across groups, ANOVA p = %.3g', ...
    pAnova));

ylim([0 90]);
grid on;
box off;

set(gca, 'FontSize', 12);

%% -----------------------------
% Optional: add group n values
%% -----------------------------
xt = 1:3;
ns = [numel(g1), numel(g2), numel(g3)];

for i = 1:3
    text(xt(i), 87, sprintf('n=%d', ns(i)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 11);
end
%% Export model summary after each model run

modelNameToExport = modelName;
modelIdxToExport = modelIdx;

exportSummary = struct;

% -----------------------------
% Model identity
% -----------------------------
exportSummary.modelName = modelNameToExport;
exportSummary.modelIdx = modelIdxToExport;
% exportSummary.modelSpec = modelSpec;

% -----------------------------
% Cell identity / alignment
% -----------------------------
exportSummary.cellIDs = results.cellIDs(:);
exportSummary.fittedCellIDs = metrics.fittedCellIDs(:);

if isfield(results, 'indLoopUsed')
    exportSummary.indLoopUsed = results.indLoopUsed(:);
end

% -----------------------------
% Fit quality
% -----------------------------
exportSummary.R2 = results.R2{modelIdxToExport}(:);
exportSummary.AICc = results.AIC{modelIdxToExport}(:);

if isfield(results, 'RSS')
    exportSummary.RSS = results.RSS{modelIdxToExport}(:);
end

exportSummary.nPixels = numel(STA_cropped(:, :, 1));
% exportSummary.nFreeParams = modelSpec.nFreeParams;

% -----------------------------
% Parameters and fitted RFs
% -----------------------------
exportSummary.params = results.params{modelIdxToExport};

if isfield(results, 'models')
    exportSummary.modelRF = results.models{modelIdxToExport};
end

if isfield(results, 'fitInfo')
    exportSummary.fitInfo = results.fitInfo{modelIdxToExport};
end

% -----------------------------
% Cell response metrics
% -----------------------------
exportSummary.DSI = metrics.DSI(:);
exportSummary.OSI = metrics.OSI(:);
exportSummary.F1F0 = metrics.F1F0(:);
exportSummary.dataOriDeg = metrics.dataOriDeg(:);

% -----------------------------
% Model-derived orientations
% -----------------------------
exportSummary.modelOriDeg = metrics.fftDeg(:);
exportSummary.fftDeg = metrics.fftDeg(:);
exportSummary.envDeg = metrics.envDeg(:);
exportSummary.env90Deg = metrics.env90Deg(:);
exportSummary.offsetDeg = metrics.offsetDeg(:);

% -----------------------------
% Orientation mismatch
% -----------------------------
exportSummary.fftMinusData = metrics.fftMinusData(:);
exportSummary.envMinusData = metrics.envMinusData(:);
exportSummary.env90MinusData = metrics.env90MinusData(:);
exportSummary.offsetMinusData = metrics.offsetMinusData(:);

exportSummary.absFftMinusData = abs(metrics.fftMinusData(:));
exportSummary.absEnvMinusData = abs(metrics.envMinusData(:));
exportSummary.absEnv90MinusData = abs(metrics.env90MinusData(:));
exportSummary.absOffsetMinusData = abs(metrics.offsetMinusData(:));

% -----------------------------
% Useful derived parameter metrics
% -----------------------------
params = results.params{modelIdxToExport};
nCells = numel(params);

tau = nan(nCells, 1);
f = nan(nCells, 1);
offsetMag = nan(nCells, 1);
sigmaC = nan(nCells, 1);
deltaSigma = nan(nCells, 1);
sigmaS = nan(nCells, 1);
Ac = nan(nCells, 1);
As = nan(nCells, 1);

for iCell = 1:nCells
    p = params{iCell};

    if isempty(p) || numel(p) < 12
        continue
    end

    Ac(iCell) = p(1);
    As(iCell) = p(2);
    sigmaC(iCell) = p(3);
    deltaSigma(iCell) = p(4);
    sigmaS(iCell) = p(3) + p(4);
    tau(iCell) = p(5);
    f(iCell) = p(9);
    offsetMag(iCell) = sqrt(p(11)^2 + p(12)^2);
end

exportSummary.Ac = Ac;
exportSummary.As = As;
exportSummary.sigmaC = sigmaC;
exportSummary.deltaSigma = deltaSigma;
exportSummary.sigmaS = sigmaS;
exportSummary.tau = tau;
exportSummary.f = f;
exportSummary.offsetMag = offsetMag;

% -----------------------------
% Group labels for later plots
% -----------------------------
groupLabel = strings(numel(exportSummary.cellIDs), 1);
groupLabel(:) = "all";

groupLabel(exportSummary.DSI < 0.3 & exportSummary.OSI > 0.5) = ...
    "low DSI high OSI";

f1Valid = isfinite(exportSummary.F1F0);
f1Thresh = prctile(exportSummary.F1F0(f1Valid), 80);

groupLabel(f1Valid & exportSummary.F1F0 >= f1Thresh) = ...
    "top 20 F1F0";

groupLabel(exportSummary.DSI >= 0.5) = ...
    "high DSI";

exportSummary.groupLabel = groupLabel;

% -----------------------------
% Save
% -----------------------------
saveFile = fullfile(outDir, ...
    matlab.lang.makeValidName(modelNameToExport) + "_tau_summary.mat");

save(saveFile, 'exportSummary');

fprintf('Saved model summary: %s\n', saveFile);

%%
%% ============================================================
% Compare two model summaries:
% STA | model 1 fit | model 2 fit examples
% plus population R2 and orientation mismatch comparison
%% ============================================================

clearvars -except STA_cropped cellIDs

%% -----------------------------
% User settings
%% -----------------------------
outDir = "";

file1 = fullfile(outDir, "DoGXCos_tau_summary.mat");
file2 = fullfile(outDir, "DoGXCosWeighted_summary.mat");
gabor = fullfile(outDir, "DoGXCosWeightedgabor_summary.mat");
DoG = fullfile(outDir, "DoGXCosWeightedDoG_summary.mat");


label1 = "Circular Model";
label2 = "Elliptical full model";

manualCellIDs = [375];      % example: [121 250 430]
nRandomCells = 6;

rng(1);                  % reproducible random pick

%% -----------------------------
% Load summaries
%% -----------------------------
S1 = load(file1);
S2 = load(file2);

M1 = S1.exportSummary;
M2 = S2.exportSummary;

%% -----------------------------
% Align model summaries by original cell ID
%% -----------------------------
commonIDs = intersect(M1.cellIDs(:), M2.cellIDs(:));

[~, i1] = ismember(commonIDs, M1.cellIDs(:));
[~, i2] = ismember(commonIDs, M2.cellIDs(:));

valid = isfinite(M1.R2(i1)) & isfinite(M2.R2(i2));

commonIDs = commonIDs(valid);
i1 = i1(valid);
i2 = i2(valid);

%% -----------------------------
% Subgroup selection by measured orientation
%% -----------------------------
% Choose one:
% subgroupMode = "near90";
% subgroupMode = "near0or180";
% subgroupMode = "all";
Gaborinf = load(gabor);
doginf = load(DoG);
G1 = Gaborinf.exportSummary;
D1 = doginf.exportSummary;
R2_Gabor = G1.R2;
R2_DoG = D1.R2;

subgroupMode = "gaborBetterThanDoG";

oriWindow = 30;   % degrees around target orientation

dataOri = M1.dataOriDeg(i1);

switch subgroupMode
    case "near90"
        subgroupMask = abs(angleDiff180(dataOri, 90)) <= oriWindow;

    case "near0or180"
        subgroupMask = abs(angleDiff180(dataOri, 0)) <= oriWindow | ...
                       abs(angleDiff180(dataOri, 180)) <= oriWindow;

    case "highOSI"
        OSI = M1.OSI(i1);
        osiValid = isfinite(OSI);
        osiThresh = prctile(OSI(osiValid), 80);

        subgroupMask = osiValid & OSI >= osiThresh;

    case "gaborBetterThanDoG"
        % Requires R2_DoG and R2_Gabor aligned to commonIDs.
        % If these are not already available, compute them before this block.
        deltaGabor = R2_Gabor - R2_DoG;

        subgroupMask = isfinite(deltaGabor) & deltaGabor > 0.05;

    case "highF1F0"
        F1F0 = M1.F1F0(i1);
        f1Valid = isfinite(F1F0);
        f1Thresh = prctile(F1F0(f1Valid), 80);

        subgroupMask = f1Valid & F1F0 >= f1Thresh;

    case "highFreqHighR2"
        f = M1.f(i1);
        R2 = M1.R2(i1);

        fValid = isfinite(f);
        r2Valid = isfinite(R2);

        fThresh = prctile(f(fValid), 75);
        r2Thresh = 0.75;

        subgroupMask = fValid & r2Valid & ...
                       f >= fThresh & ...
                       R2 >= r2Thresh;

    case "all"
        subgroupMask = true(size(dataOri));

    otherwise
        error('Unknown subgroupMode: %s', subgroupMode);
end
fprintf('\nSubgroup mode: %s\n', subgroupMode);
fprintf('Keeping %d / %d cells\n', sum(subgroupMask), numel(subgroupMask));

commonIDs = commonIDs(subgroupMask);
i1 = i1(subgroupMask);
i2 = i2(subgroupMask);
%% -----------------------------
% Select example cells
%% -----------------------------
manualCellIDs = manualCellIDs(:);

manualCellIDs = manualCellIDs(ismember(manualCellIDs, commonIDs));

remainingIDs = setdiff(commonIDs, manualCellIDs);

nToRandom = max(0, nRandomCells - numel(manualCellIDs));
nToRandom = min(nToRandom, numel(remainingIDs));

randomIDs = remainingIDs(randperm(numel(remainingIDs), nToRandom));

exampleIDs = [manualCellIDs; randomIDs(:)];
nShow = numel(exampleIDs);

[~, exIdxCommon] = ismember(exampleIDs, commonIDs);
exI1 = i1(exIdxCommon);
exI2 = i2(exIdxCommon);

%% -----------------------------
% Get population values
%% -----------------------------
R2_1 = M1.R2(i1);
R2_2 = M2.R2(i2);

err1 = abs(M1.fftMinusData(i1));
err2 = abs(M2.fftMinusData(i2));

validErr = isfinite(err1) & isfinite(err2);

%% ============================================================
% Compact figure: examples left, statistics right
%% ============================================================

figure('Color', 'w', 'Position', [50 50 1450 900]);

outer = tiledlayout(1, 2, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

%% -----------------------------
% LEFT: example cells
%% -----------------------------
leftPanel = tiledlayout(outer, nShow, 3, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

leftPanel.Layout.Tile = 1;

for k = 1:nShow

    cellID = exampleIDs(k);

    staIdx = find(M1.cellIDs(:) == cellID, 1);

    STA = STA_cropped(:, :, staIdx);
    fit1 = M1.modelRF{exI1(k)};
    fit2 = M2.modelRF{exI2(k)};

    clim = max(abs([STA(:); fit1(:); fit2(:)]), [], 'omitnan');
    if ~isfinite(clim) || clim == 0
        clim = 1;
    end

    nexttile(leftPanel, (k - 1) * 3 + 1);
    imagesc(STA, [-clim clim]);
    axis image off;
    colormap gray;
    title(sprintf('Cell %d STA', cellID), 'FontSize', 9);

    nexttile(leftPanel, (k - 1) * 3 + 2);
    imagesc(fit1, [-clim clim]);
    axis image off;
    colormap gray;
    title(sprintf('%s\nR^2=%.2f, err=%.1f°', ...
        label1, M1.R2(exI1(k)), abs(M1.fftMinusData(exI1(k)))), ...
        'FontSize', 9);

    nexttile(leftPanel, (k - 1) * 3 + 3);
    imagesc(fit2, [-clim clim]);
    axis image off;
    colormap gray;
    title(sprintf('%s\nR^2=%.2f, err=%.1f°', ...
        label2, M2.R2(exI2(k)), abs(M2.fftMinusData(exI2(k)))), ...
        'FontSize', 9);
end

%% -----------------------------
% RIGHT: population stats
%% -----------------------------
rightPanel = tiledlayout(outer, 4, 1, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

rightPanel.Layout.Tile = 2;

%% 1. R2 scatter
nexttile(rightPanel);

scatter(R2_1, R2_2, 25, 'filled', ...
    'MarkerFaceAlpha', 0.65);
hold on;
plot([0 1], [0 1], 'k--', 'LineWidth', 1);

axis square;
xlim([0 1]);
ylim([0 1]);
xlabel(label1 + " R^2");
ylabel(label2 + " R^2");
title('R^2 comparison');
grid on;
box off;
set(gca, 'FontSize', 9);

%% 2. Delta R2 histogram
nexttile(rightPanel);

deltaR2 = R2_2 - R2_1;

histogram(deltaR2, 18, ...
    'FaceAlpha', 0.7, ...
    'EdgeColor', 'none');
hold on;
xline(0, 'k--', 'LineWidth', 1);
xline(median(deltaR2, 'omitnan'), 'r-', 'LineWidth', 1.2);

xlabel("\DeltaR^2 = " + label2 + " - " + label1);
ylabel('Count');
title('\DeltaR^2 distribution');
grid on;
box off;
set(gca, 'FontSize', 9);

%% 3. Orientation error scatter
nexttile(rightPanel);

scatter(err1(validErr), err2(validErr), 25, 'filled', ...
    'MarkerFaceAlpha', 0.65);
hold on;
plot([0 90], [0 90], 'k--', 'LineWidth', 1);

axis square;
xlim([0 90]);
ylim([0 90]);
xlabel(label1 + " error (deg)");
ylabel(label2 + " error (deg)");
title('Orientation error comparison');
grid on;
box off;
set(gca, 'FontSize', 9);

%% 4. Orientation error boxplot
%% 4. Orientation error boxplot
nexttile(rightPanel);

errMat = [err1(validErr), err2(validErr)];

xBox = [
    ones(size(errMat, 1), 1)
    2 * ones(size(errMat, 1), 1)
];

yBox = [
    errMat(:, 1)
    errMat(:, 2)
];

boxchart(xBox, yBox, ...
    'BoxFaceColor', [0.75 0.75 0.75], ...
    'MarkerColor', [0.35 0.35 0.35], ...
    'LineWidth', 1.2);

set(gca, ...
    'XTick', [1 2], ...
    'XTickLabel', {char(label1), char(label2)}, ...
    'FontSize', 9);

ylabel('|Model - data| (deg)');
title('Orientation mismatch');
ylim([0 90]);
grid on;
box off;
%%
%% Histogram of preferred grating orientation from data

dataOri = M1.dataOriDeg(subgroupMask);   % aligned cells after subgroup filtering

validOri = isfinite(dataOri);

figure('Color', 'w', 'Position', [100 100 520 400]);

histogram(dataOri(validOri), 0:30:180, ...
    'FaceColor', [0.65 0.65 0.65], ...
    'EdgeColor', 'k');

xlabel('Preferred grating orientation (deg)');
ylabel('Number of cells');
title(sprintf('Preferred grating orientation: %s', subgroupMode), ...
    'Interpreter', 'none');

xlim([0 180]);
xticks(0:30:180);

grid on;
box off;
set(gca, 'FontSize', 12);

%% Print all raw STAs on a separate PDF page

rawStaPdf = fullfile(outDir, ...
    "Raw_STA_" + subgroupMode + ".pdf");

nCellsPlot = numel(commonIDs);

nCol = 8;
nRow = ceil(nCellsPlot / nCol);

fig = figure('Color', 'w', 'Position', [100 100 1400 180*nRow]);

tiledlayout(nRow, nCol, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

for k = 1:nCellsPlot
    cellID = commonIDs(k);

    staIdx = find(M1.cellIDs(:) == cellID, 1);
    STA = STA_cropped(:, :, staIdx);

    clim = max(abs(STA(:)), [], 'omitnan');
    if ~isfinite(clim) || clim == 0
        clim = 1;
    end

    nexttile;
    imagesc(STA, [-clim clim]);
    axis image off;
    colormap gray;
    title(sprintf('%d', cellID), 'FontSize', 7);
end

sgtitle("Raw STAs: " + subgroupMode, ...
    'Interpreter', 'none', ...
    'FontWeight', 'bold');

exportgraphics(fig, rawStaPdf, ...
    'ContentType', 'image');

fprintf('Saved raw STA page: %s\n', rawStaPdf);

%% Save figure

saveFile = fullfile(outDir, ...
    'new_Comparison.pdf');
set(gcf, 'PaperPositionMode', 'auto');
exportgraphics(gcf, saveFile, ...
    'ContentType', 'vector');

fprintf('Saved figure: %s\n', saveFile);

%% mismatch analysis
% for iGroup = 1:numel(groupDefs)
% 
%     mask = groupDefs(iGroup).mask;
%     groupName = groupDefs(iGroup).name;
%     groupLabel = groupDefs(iGroup).label;
% 
%     plotOrientationExplanatoryStats(metrics, mask, groupName, groupLabel);
% 
% end
%% Compare orientation mismatch across saved model summaries

summaryFiles = {
    'DoGxcosweightedfull_summary.mat'
    'DoGxcosweightedtau_summary.mat'
};

modelLabels = {
    'DoG x cos'
    'tau'
};

errorField = 'fftMinusData';  
% options:
% 'fftMinusData'
% 'env90MinusData'
% 'offsetMinusData'

%% Load summaries

nModels = numel(summaryFiles);
S = cell(nModels, 1);

for i = 1:nModels
    tmp = load(summaryFiles{i});
    S{i} = tmp.exportSummary;
end

%% Find cells shared by all models

commonIDs = S{1}.cellIDs(:);

for i = 2:nModels
    commonIDs = intersect(commonIDs, S{i}.cellIDs(:));
end

fprintf('Number of shared cells = %d\n', numel(commonIDs));

%% Build aligned error matrix

nCells = numel(commonIDs);
absErr = nan(nCells, nModels);
R2 = nan(nCells, nModels);

for i = 1:nModels
    [tf, loc] = ismember(commonIDs, S{i}.cellIDs(:));

    errSigned = S{i}.(errorField)(loc(tf));
    absErr(tf, i) = abs(errSigned);

    R2(tf, i) = S{i}.R2(loc(tf));
end
%% Define groups

[~, locBase] = ismember(commonIDs, S{1}.cellIDs(:));

DSI = S{1}.DSI(locBase);
OSI = S{1}.OSI(locBase);
F1F0 = S{1}.F1F0(locBase);

f1Valid = isfinite(F1F0);
f1Thresh = prctile(F1F0(f1Valid), 80);

groupNames = {
    'Low DSI high OSI'
    'Top 20% F1/F0'
    'High DSI'
    'All cells'
};

groupMasks = {
    DSI < 0.3 & OSI > 0.5
    f1Valid & F1F0 >= f1Thresh
    DSI >= 0.5
    true(size(DSI))
};
%% Analyze each group separately

for g = 1:numel(groupNames)

    groupName = groupNames{g};
    groupMask = groupMasks{g};

    groupErr = absErr(groupMask, :);
    groupR2 = R2(groupMask, :);

    fprintf('\n==============================\n');
    fprintf('%s\n', groupName);
    fprintf('N cells = %d\n', sum(groupMask));

    groupTable = table;
    groupTable.model = string(modelLabels(:));
    groupTable.nCells = repmat(sum(groupMask), nModels, 1);
    groupTable.medianAbsErr = median(groupErr, 1, 'omitnan')';
    groupTable.meanAbsErr = mean(groupErr, 1, 'omitnan')';
    groupTable.rmse = sqrt(mean(groupErr.^2, 1, 'omitnan'))';
    groupTable.fracWithin15 = mean(groupErr <= 15, 1, 'omitnan')';
    groupTable.fracWithin30 = mean(groupErr <= 30, 1, 'omitnan')';
    groupTable.medianR2 = median(groupR2, 1, 'omitnan')';

    disp(groupTable);

    fprintf('\nPaired signrank tests against %s:\n', modelLabels{1});

    for i = 2:nModels
        valid = isfinite(groupErr(:, 1)) & isfinite(groupErr(:, i));

        if sum(valid) >= 3
            [p, ~, stats] = signrank(groupErr(valid, 1), ...
                groupErr(valid, i));

            fprintf('%s vs %s: p = %.4g, signedrank = %.3f\n', ...
                modelLabels{1}, modelLabels{i}, p, ...
                stats.signedrank);
        else
            fprintf('%s vs %s: not enough valid cells\n', ...
                modelLabels{1}, modelLabels{i});
        end
    end

    figure('Name', ['Paired mismatch - ' groupName]);
    hold on;

    x = 1:nModels;

    for c = 1:size(groupErr, 1)
        plot(x, groupErr(c, :), '-', ...
            'Color', [0.7 0.7 0.7], ...
            'LineWidth', 0.5);
    end

    plot(x, median(groupErr, 1, 'omitnan'), 'ko-', ...
        'LineWidth', 2, ...
        'MarkerFaceColor', 'k');

    xlim([0.5 nModels + 0.5]);
    xticks(x);
    xticklabels(modelLabels);
    ylabel('Absolute orientation mismatch (deg)');
    title([groupName ': ' errorField], 'Interpreter', 'none');
    box off;

    figure('Name', ['CDF mismatch - ' groupName]);
    hold on;

    for i = 1:nModels
        e = groupErr(:, i);
        e = e(isfinite(e));

        if numel(e) >= 2
            [f, xcdf] = ecdf(e);
            plot(xcdf, f, 'LineWidth', 2);
        end
    end

    xlabel('Absolute orientation mismatch (deg)');
    ylabel('Fraction of cells');
    legend(modelLabels, 'Location', 'southeast');
    title([groupName ': CDF of ' errorField], ...
        'Interpreter', 'none');
    box off;

end

%% test  ori
%% Test which RF geometry explains tuning best
% Classifies cells as:
%   1. Carrier/FFT dominated
%   2. Envelope + 90 dominated
%   3. Offset-axis dominated
%% Extract raw fitted theta from cell-array params

nCells = numel(summary.params);
thetaRaw = nan(nCells, 1);

for i = 1:nCells
    p = summary.params{i};

    if ~isempty(p) && numel(p) >= 6
        thetaRaw(i) = rad2deg(p(6));
    end
end

theta180 = mod(thetaRaw, 180);

figure('Color', 'w');
histogram(theta180, 0:15:180);
xlabel('Raw fitted theta mod 180');
ylabel('Cell count');
title('Raw fitted carrier theta');
xlim([0 180]);
xticks(0:30:180);
grid on;
box off;

figure('Color', 'w');

subplot(1, 2, 1)
histogram(theta180, 0:15:180);
title('Raw fitted theta');
xlim([0 180]);

subplot(1, 2, 2)
histogram(summary.fftDeg, 0:15:180);
title('Saved fftDeg');
xlim([0 180]);

%%
theta180 = mod(thetaRaw, 180);
f = summary.f(:);
R2 = summary.R2(:);

near90 = abs(angleDiff180(theta180, 90)) < 7.5;
near0 = abs(angleDiff180(theta180, 0)) < 7.5 | ...
        abs(angleDiff180(theta180, 180)) < 7.5;

fprintf('Near 90: n=%d, median f=%.4f, median R2=%.4f\n', ...
    sum(near90), median(f(near90), 'omitnan'), median(R2(near90), 'omitnan'));

fprintf('Near 0/180: n=%d, median f=%.4f, median R2=%.4f\n', ...
    sum(near0), median(f(near0), 'omitnan'), median(R2(near0), 'omitnan'));

figure;
scatter(f, theta180, 40, R2, 'filled');
xlabel('Carrier frequency f');
ylabel('Raw fitted theta (deg)');
title('Fitted carrier orientation vs frequency');
ylim([0 180]);
colorbar;
grid on;
box off;

%% Compare model orientation distribution to data orientation

dataOri = summary.dataOriDeg(:);
modelOri = mod(summary.fftDeg(:), 180);

figure('Color', 'w', 'Position', [100 100 900 380]);

subplot(1,2,1)
histogram(dataOri, 0:15:180);
title('Measured tuning orientation');
xlabel('Orientation (deg)');
ylabel('Cell count');
xlim([0 180]);
xticks(0:30:180);
grid on;

subplot(1,2,2)
histogram(modelOri, 0:15:180);
title('Model carrier orientation');
xlabel('Orientation (deg)');
ylabel('Cell count');
xlim([0 180]);
xticks(0:30:180);
grid on;
nearData0 = abs(angleDiff180(dataOri, 0)) < 15;
nearData90 = abs(angleDiff180(dataOri, 90)) < 15;

fprintf('Data near 0: model median = %.2f\n', ...
    median(modelOri(nearData0), 'omitnan'));

fprintf('Data near 90: model median = %.2f\n', ...
    median(modelOri(nearData90), 'omitnan'));

figure;
subplot(1,2,1)
histogram(modelOri(nearData0), 0:15:180);
title('Model orientation when data near 0');

subplot(1,2,2)
histogram(modelOri(nearData90), 0:15:180);
title('Model orientation when data near 90');
err = abs(angleDiff180(modelOri, dataOri));

fprintf('Median model-data error = %.2f deg\n', ...
    median(err, 'omitnan'));
fprintf('Fraction error < 15 deg = %.2f%%\n', ...
    100 * mean(err < 15, 'omitnan'));
fprintf('Fraction error < 30 deg = %.2f%%\n', ...
    100 * mean(err < 30, 'omitnan'));

modelOri1 = mod(summary.fftDeg(:), 180);
modelOri2 = mod(summary.fftDeg(:) + 90, 180);
dataOri = summary.dataOriDeg(:);

err1 = abs(angleDiff180(modelOri1, dataOri));
err2 = abs(angleDiff180(modelOri2, dataOri));

fprintf('Median error raw = %.2f\n', median(err1, 'omitnan'));
fprintf('Median error +90 = %.2f\n', median(err2, 'omitnan'));
fprintf('Fraction < 30 raw = %.2f%%\n', 100 * mean(err1 < 30, 'omitnan'));
fprintf('Fraction < 30 +90 = %.2f%%\n', 100 * mean(err2 < 30, 'omitnan'));
%% -----------------------------
% User settings
%% -----------------------------
%% ============================================================
% Compare carrier and offset prediction error across groups
% ============================================================

%% ============================================================
% RF parameter comparison across functional groups
% ============================================================

summaryFile = 'DoGXCos_tau_summary.mat';

S = load(summaryFile);
summary = S.exportSummary;

%% -----------------------------
% Extract variables
%% -----------------------------

cellIDs = summary.cellIDs(:);

DSI = summary.DSI(:);
OSI = summary.OSI(:);
F1F0 = summary.F1F0(:);
R2 = summary.R2(:);

carrierErr = abs(summary.fftMinusData(:));
offsetErr = abs(summary.offsetMinusData(:));

tau = summary.tau(:);
f = summary.f(:);
offsetMag = summary.offsetMag(:);

% Optional surround strength
if isfield(summary, 'As') && isfield(summary, 'Ac')
    surroundStrength = abs(summary.As(:)) ./ ...
        (abs(summary.Ac(:)) + eps);
else
    surroundStrength = nan(size(cellIDs));
end

%% -----------------------------
% Optional: extract dx and dy directly if saved
%% -----------------------------

if isfield(summary, 'dx')
    dx = summary.dx(:);
else
    dx = nan(size(cellIDs));
end

if isfield(summary, 'dy')
    dy = summary.dy(:);
else
    dy = nan(size(cellIDs));
end

%% -----------------------------
% Define functional groups
%% -----------------------------

groupNames = [
    "Low DSI / High OSI"
    "Top 20% F1/F0"
    "High DSI"
];

f1Valid = isfinite(F1F0);
f1Thresh = prctile(F1F0(f1Valid), 80);

groupMask = false(numel(cellIDs), numel(groupNames));

groupMask(:, 1) = DSI < 0.3 & OSI > 0.5;
groupMask(:, 2) = f1Valid & F1F0 >= f1Thresh;
groupMask(:, 3) = DSI > 0.5;

%% -----------------------------
% Build analysis table
%% -----------------------------

T = table;

T.cellID = cellIDs;
T.DSI = DSI;
T.OSI = OSI;
T.F1F0 = F1F0;
T.R2 = R2;

T.carrierErr = carrierErr;
T.offsetErr = offsetErr;
T.offsetMinusCarrier = offsetErr - carrierErr;

T.tau = tau;
T.f = f;
T.offsetMag = offsetMag;
T.dx = dx;
T.dy = dy;
T.surroundStrength = surroundStrength;

T.group = strings(height(T), 1);

for iGroup = 1:numel(groupNames)
    T.group(groupMask(:, iGroup)) = groupNames(iGroup);
end

T = T(T.group ~= "", :);

%% -----------------------------
% Parameters to compare
%% -----------------------------

paramNames = {
    'R2'
    'carrierErr'
    'offsetErr'
    'offsetMinusCarrier'
    'tau'
    'f'
    'offsetMag'
    'dx'
    'dy'
    'surroundStrength'
};

paramLabels = containers.Map;

paramLabels('R2') = 'Model fit quality (R^2)';
paramLabels('carrierErr') = ...
    '|Carrier orientation - measured tuning| (deg)';
paramLabels('offsetErr') = ...
    '|Offset axis - measured tuning| (deg)';
paramLabels('offsetMinusCarrier') = ...
    'Offset error - carrier error (deg)';
paramLabels('tau') = 'Envelope elongation (\tau)';
paramLabels('f') = 'Carrier spatial frequency';
paramLabels('offsetMag') = 'Offset magnitude';
paramLabels('dx') = 'Offset dx';
paramLabels('dy') = 'Offset dy';
paramLabels('surroundStrength') = '|A_s| / |A_c|';



%% ============================================================
% 1. Summary statistics and group tests
%% ============================================================

fprintf('\n===== RF parameter comparison across functional groups =====\n');

statsSummary = table;

for p = 1:numel(paramNames)

    paramName = paramNames{p};
    y = T.(paramName);

    fprintf('\nParameter: %s\n', paramName);

    for iGroup = 1:numel(groupNames)

        mask = T.group == groupNames(iGroup) & isfinite(y);

        fprintf('%s: n = %d, median = %.4f, mean = %.4f\n', ...
            groupNames(iGroup), ...
            sum(mask), ...
            median(y(mask), 'omitnan'), ...
            mean(y(mask), 'omitnan'));
    end

    valid = isfinite(y);

    if sum(valid) >= 6 && numel(unique(T.group(valid))) >= 2

%% Group tests: one-way ANOVA + Kruskal-Wallis

[pAnova, tblAnova, statsAnova] = anova1( ...
    y(valid), T.group(valid), 'off');

pKW = kruskalwallis(y(valid), T.group(valid), 'off');

fprintf('One-way ANOVA p = %.4g\n', pAnova);
fprintf('Kruskal-Wallis p = %.4g\n', pKW);

% Post hoc ANOVA multiple comparisons
posthocAnova = multcompare(statsAnova, ...
    'Display', 'off');

posthocTable = array2table(posthocAnova, ...
    'VariableNames', ...
    {'GroupA', 'GroupB', 'LowerCI', ...
     'MeanDiff', 'UpperCI', 'pValue'});

fprintf('Post hoc ANOVA comparisons:\n');
disp(posthocTable)

newRow = table( ...
    string(paramName), ...
    pAnova, ...
    pKW, ...
    'VariableNames', ...
    {'Parameter', 'AnovaP', 'KruskalWallisP'});

statsSummary = [statsSummary; newRow];
    end
end

disp(statsSummary);

%% ============================================================
% 2. Boxplots across groups
%% ============================================================

outFigDir = fullfile(pwd, 'group_parameter_figures');

if ~exist(outFigDir, 'dir')
    mkdir(outFigDir);
end

for p = 1:numel(paramNames)

    paramName = paramNames{p};
    y = T.(paramName);

    valid = isfinite(y);

    figure('Color', 'w', 'Position', [100 100 700 430]);

    boxchart( ...
        categorical(T.group(valid), groupNames, 'Ordinal', true), ...
        y(valid), ...
        'BoxFaceColor', [0.75 0.75 0.75], ...
        'MarkerColor', [0.35 0.35 0.35], ...
        'LineWidth', 1.4);

    ylabel(paramLabels(paramName), 'Interpreter', 'tex');
    xlabel('Functional group');
    title(['Group comparison: ' paramName], ...
        'Interpreter', 'none');

    grid on
    box off
    set(gca, 'FontSize', 12);
    xtickangle(20);

    if contains(paramName, 'Err') || contains(paramName, 'error')
        ylim([0 90]);
    end

    if strcmp(paramName, 'offsetMinusCarrier')
        yline(0, 'k--', 'LineWidth', 1.2);
    end

    saveas(gcf, fullfile(outFigDir, ...
        ['boxplot_' paramName '.png']));
end

%% ============================================================
% 3. Poster-style multi-panel parameter summary
%% ============================================================

posterParams = {
    'R2'
    'carrierErr'
    'offsetMinusCarrier'
    'tau'
    'f'
    'offsetMag'
    'surroundStrength'
};

figure('Color', 'w', 'Position', [100 100 1300 700]);

tiledlayout(2, 4, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

for p = 1:numel(posterParams)

    paramName = posterParams{p};
    y = T.(paramName);
    valid = isfinite(y);

    nexttile

    boxchart( ...
        categorical(T.group(valid), groupNames, 'Ordinal', true), ...
        y(valid), ...
        'BoxFaceColor', [0.75 0.75 0.75], ...
        'MarkerStyle', 'none', ...
        'LineWidth', 1.2);

    ylabel(paramLabels(paramName), 'Interpreter', 'tex');
    title(paramName, 'Interpreter', 'none');

    grid on
    box off
    set(gca, 'FontSize', 10);
    xtickangle(30);

    if contains(paramName, 'Err') || contains(paramName, 'error')
        ylim([0 90]);
    end

    if strcmp(paramName, 'offsetMinusCarrier')
        yline(0, 'k--', 'LineWidth', 1.1);
    end
end

sgtitle('RF model parameters across functional neuronal groups');

saveas(gcf, fullfile(outFigDir, ...
    'poster_parameter_summary.png'));

%% ============================================================
% 4. Correlations with DSI
%% ============================================================

corrParams = {
    'carrierErr'
    'offsetErr'
    'offsetMinusCarrier'
    'tau'
    'f'
    'offsetMag'
    'surroundStrength'
    'R2'
};

fprintf('\n===== Spearman correlations with DSI =====\n');

corrSummary = table;

for p = 1:numel(corrParams)

    paramName = corrParams{p};

    x = T.DSI;
    y = T.(paramName);

    valid = isfinite(x) & isfinite(y);

    if sum(valid) < 5
        continue
    end

    [rho, pVal] = corr(x(valid), y(valid), ...
        'Type', 'Spearman');

    fprintf('DSI vs %s: rho = %.4f, p = %.4g\n', ...
        paramName, rho, pVal);

    newRow = table( ...
        string(paramName), ...
        rho, ...
        pVal, ...
        sum(valid), ...
        'VariableNames', {'Parameter', 'SpearmanRho', 'PValue', 'N'});

    corrSummary = [corrSummary; newRow];
end

disp(corrSummary);

%% ============================================================
% 5. Scatter plots vs DSI
%% ============================================================

scatterParams = {
    'carrierErr'
    'offsetMinusCarrier'
    'tau'
    'f'
    'offsetMag'
    'surroundStrength'
};

for p = 1:numel(scatterParams)

    paramName = scatterParams{p};

    x = T.DSI;
    y = T.(paramName);

    valid = isfinite(x) & isfinite(y);

    figure('Color', 'w', 'Position', [100 100 520 430]);

    scatter(x(valid), y(valid), ...
        45, ...
        'filled', ...
        'MarkerFaceAlpha', 0.65);

    xlabel('DSI');
    ylabel(paramLabels(paramName), 'Interpreter', 'tex');
    title(['DSI vs ' paramName], ...
        'Interpreter', 'none');

    grid on
    box off
    set(gca, 'FontSize', 12);

    if strcmp(paramName, 'offsetMinusCarrier')
        yline(0, 'k--', 'LineWidth', 1.2);
    end

    % Linear trend line for visualization
    hold on

    xx = x(valid);
    yy = y(valid);

    pFit = polyfit(xx, yy, 1);
    xLine = linspace(min(xx), max(xx), 100);
    yLine = polyval(pFit, xLine);

    plot(xLine, yLine, 'k-', 'LineWidth', 1.5);

    saveas(gcf, fullfile(outFigDir, ...
        ['scatter_DSI_' paramName '.png']));
end

%% ============================================================
% 6. Save outputs
%% ============================================================

save('RF_parameter_group_analysis.mat', ...
    'T', 'statsSummary', 'corrSummary', 'groupNames');

writetable(T, 'RF_parameter_group_table.csv');
writetable(statsSummary, 'RF_parameter_group_stats.csv');
writetable(corrSummary, 'RF_parameter_DSI_correlations.csv');

fprintf('\nSaved RF parameter group analysis outputs.\n');
fprintf('Figures saved in: %s\n', outFigDir);
%% Compare R2 between two model summaries
%% Schematic F1/F0 examples matched to 2 Hz, 0-1 s stimulus

stimHz = 2;
t = linspace(0, 1, 500);

% Baseline firing rate, Hz
F0 = 10;

% Low and high modulation amplitudes
F1_low = 2;
F1_high = 8;

% Responses
respLow = F0 + F1_low * sin(2 * pi * stimHz * t);
respHigh = F0 + F1_high * sin(2 * pi * stimHz * t);

figure('Color', 'w', 'Position', [100 100 850 330]);

tiledlayout(1, 2, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');

%% Low F1/F0
nexttile;
plot(t, respLow, 'k-', 'LineWidth', 2);
hold on;
yline(F0, 'k--', 'LineWidth', 1.2);
xline(0.5, 'k:', 'LineWidth', 1);
xline(1.0, 'k:', 'LineWidth', 1);

xlabel('Time (s)');
ylabel('Firing rate (Hz)');
title(sprintf('Low temporal modulation\nF1/F0 = %.2f', F1_low / F0));

xlim([0 1]);
ylim([0 20]);
xticks(0:0.25:1);
grid on;
box off;

text(0.05, F0 + 0.5, 'F0 mean', 'FontSize', 10);

%% High F1/F0
nexttile;
plot(t, respHigh, 'k-', 'LineWidth', 2);
hold on;
yline(F0, 'k--', 'LineWidth', 1.2);
xline(0.5, 'k:', 'LineWidth', 1);
xline(1.0, 'k:', 'LineWidth', 1);

xlabel('Time (s)');
ylabel('Firing rate (Hz)');
title(sprintf('High temporal modulation\nF1/F0 = %.2f', F1_high / F0));

xlim([0 1]);
ylim([0 20]);
xticks(0:0.25:1);
grid on;
box off;

text(0.05, F0 + 0.5, 'F0 mean', 'FontSize', 10);

sgtitle('F1/F0 schematic for 2 Hz grating response', ...
    'FontWeight', 'bold');
% clear; clc;

%%
%% Confirm As and f continuum in modified model

summaryFile = 'DoGXCos_tau_summary.mat';

S = load(summaryFile);
summary = S.exportSummary;

cellIDs = summary.cellIDs(:);
R2 = summary.R2(:);

As = summary.As(:);
Ac = summary.Ac(:);
f = summary.f(:);

surroundStrength = abs(As) ./ (abs(Ac) + eps);

valid = isfinite(f) & isfinite(surroundStrength) & isfinite(R2);

cellIDs = cellIDs(valid);
f = f(valid);
surroundStrength = surroundStrength(valid);
R2 = R2(valid);

%% Continuum score
% High f, low As = more Gabor-like
% Low f, high As = more DoG-like

zF = zscore(f);
zAs = zscore(surroundStrength);

continuumScore = zF - zAs;

[~, sortIdx] = sort(continuumScore, 'ascend');

%% Scatter: As vs f

figure('Color', 'w', 'Position', [100 100 520 430]);

scatter(surroundStrength, f, 45, R2, 'filled', ...
    'MarkerFaceAlpha', 0.75);

xlabel('|A_s| / |A_c|');
ylabel('Carrier spatial frequency');
title('DoG-to-Gabor continuum parameters');

cb = colorbar;
ylabel(cb, 'R^2');

grid on;
box off;
set(gca, 'FontSize', 12);

%% Correlation test

[rho, pVal] = corr(surroundStrength, f, ...
    'Type', 'Spearman', ...
    'Rows', 'complete');

fprintf('\n===== As-f continuum test =====\n');
fprintf('Spearman corr(|As|/|Ac|, f): rho = %.3f, p = %.4g\n', ...
    rho, pVal);

%% Sorted continuum plot

figure('Color', 'w', 'Position', [100 100 850 360]);

yyaxis left
plot(f(sortIdx), '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
ylabel('Carrier spatial frequency');

yyaxis right
plot(surroundStrength(sortIdx), '-o', 'LineWidth', 1.5, ...
    'MarkerSize', 4);
ylabel('|A_s| / |A_c|');

xlabel('Cells sorted by continuum score');
title('Cells ordered from DoG-like to Gabor-like');

grid on;
box off;
set(gca, 'FontSize', 12);

%% Classify rough continuum groups

lowF = f < median(f, 'omitnan');
highF = f >= median(f, 'omitnan');

lowAs = surroundStrength < median(surroundStrength, 'omitnan');
highAs = surroundStrength >= median(surroundStrength, 'omitnan');

group = strings(numel(f), 1);
group(lowF & highAs) = "DoG-like";
group(highF & lowAs) = "Gabor-like";
group(group == "") = "Intermediate";

T_continuum = table(cellIDs, R2, f, surroundStrength, ...
    continuumScore, group);

disp(groupcounts(T_continuum, 'group'));

save('As_f_continuum_check.mat', 'T_continuum');
writetable(T_continuum, 'As_f_continuum_check.csv');

%%
%% Check As/Ac and f for one cell

cellIDToCheck = 986;   % original cell ID

summaryFile = 'DoGXCos_tau_summary.mat';
S = load(summaryFile);
summary = S.exportSummary;

rowIdx = find(summary.cellIDs == cellIDToCheck, 1);

if isempty(rowIdx)
    error('Cell ID %d not found in summary.cellIDs.', cellIDToCheck);
end

Ac = summary.Ac(rowIdx);
As = summary.As(rowIdx);
f  = summary.f(rowIdx);
R2 = summary.R2(rowIdx);

AsOverAc = abs(As) / (abs(Ac) + eps);

fprintf('\nCell ID %d\n', cellIDToCheck);
fprintf('rowIdx = %d\n', rowIdx);
fprintf('Ac = %.4f\n', Ac);
fprintf('As = %.4f\n', As);
fprintf('|As|/|Ac| = %.4f\n', AsOverAc);
fprintf('f = %.4f\n', f);
fprintf('R2 = %.4f\n', R2);

%% -----------------------------
% User settings
%% -----------------------------
outDir = "";

fileA = fullfile(outDir, "DoGXCosWeightedfull_summary.mat");
fileB = fullfile(outDir, "DoGXCosWeightedtau_summary.mat");

labelA = "Elliptical Model";
labelB = "Circular Model";

kA = 12;
kB = 11;

%% -----------------------------
% Load summaries
%% -----------------------------
SA = load(fileA);
SB = load(fileB);

A = SA.exportSummary;
B = SB.exportSummary;

%% -----------------------------
% Align cells by cellID
%% -----------------------------
commonIDs = intersect(A.cellIDs(:), B.cellIDs(:));

[~, iA] = ismember(commonIDs, A.cellIDs);
[~, iB] = ismember(commonIDs, B.cellIDs);

R2_A = A.R2(iA);
R2_B = B.R2(iB);

valid = isfinite(R2_A) & isfinite(R2_B);

cellIDs = commonIDs(valid);
R2_A = R2_A(valid);
R2_B = R2_B(valid);

%% -----------------------------
% Get RSS or reconstruct from R2
%% -----------------------------
if isfield(A, 'RSS') && isfield(B, 'RSS')
    RSS_A = A.RSS(iA);
    RSS_B = B.RSS(iB);
    RSS_A = RSS_A(valid);
    RSS_B = RSS_B(valid);
else
    warning('RSS not found. AICc cannot be computed reliably.');
    RSS_A = nan(size(R2_A));
    RSS_B = nan(size(R2_B));
end

if isfield(A, 'nPixels')
    n = A.nPixels;
else
    n = 400; % for 20 x 20 STA
end

%% -----------------------------
% Compute AICc manually
%% -----------------------------
AICc_A = computeAICc_manual(RSS_A, n, kA);
AICc_B = computeAICc_manual(RSS_B, n, kB);

validAIC = isfinite(AICc_A) & isfinite(AICc_B);

%% -----------------------------
% Paired R2 line plot
%% -----------------------------
figure('Color', 'w'); hold on;

R2mat = [R2_A, R2_B];
x = [1 2];

for i = 1:numel(cellIDs)
    plot(x, R2mat(i, :), '-', ...
        'Color', [0.75 0.75 0.75], ...
        'LineWidth', 0.7);
end

scatter(ones(size(R2_A)), R2_A, 40, 'filled');
scatter(2 * ones(size(R2_B)), R2_B, 40, 'filled');

boxplot(R2mat, [labelA, labelB], ...
    'Colors', 'k', ...
    'Symbol', '');

ylabel('R^2');
title('Paired R^2 comparison');
grid on;
set(gca, 'FontSize', 12);

%% -----------------------------
% Delta R2 histogram
%% -----------------------------
deltaR2 = R2_A - R2_B;

figure('Color', 'w');
histogram(deltaR2, 20);
xline(0, 'r--', 'LineWidth', 1.5);

xlabel("\DeltaR^2 = " + labelA + " - " + labelB);
ylabel('Number of cells');
title('Difference in R^2');
grid on;
set(gca, 'FontSize', 12);

%% -----------------------------
% Scatter R2 comparison
%% -----------------------------

figure('Color', 'w', 'Position', [100 100 500 450]);

scatter(R2_B, R2_A, 45, 'filled', ...
    'MarkerFaceAlpha', 0.65);

hold on;
plot([0 1], [0 1], 'k--', 'LineWidth', 1.3);

axis square;
xlim([0 1]);
ylim([0 1]);

xlabel(labelB + " R^2");
ylabel(labelA + " R^2");
title("R^2 comparison: " + labelA + " vs " + labelB);

grid on;
box off;
set(gca, 'FontSize', 12);

%% Add summary text
deltaR2 = R2_A - R2_B;

txt = sprintf('%s better: %d/%d\n%s better: %d/%d', ...
    labelA, sum(deltaR2 > 0), numel(deltaR2), ...
    labelB, sum(deltaR2 < 0), numel(deltaR2));

text(0.05, 0.95, txt, ...
    'Units', 'normalized', ...
    'VerticalAlignment', 'top', ...
    'FontSize', 11);
%% -----------------------------
% Paired AICc line plot
%% -----------------------------
figure('Color', 'w'); hold on;

AICmat = [AICc_A(validAIC), AICc_B(validAIC)];

for i = 1:size(AICmat, 1)
    plot(x, AICmat(i, :), '-', ...
        'Color', [0.75 0.75 0.75], ...
        'LineWidth', 0.7);
end

scatter(ones(size(AICmat, 1), 1), AICmat(:, 1), 40, 'filled');
scatter(2 * ones(size(AICmat, 1), 1), AICmat(:, 2), 40, 'filled');

boxplot(AICmat, [labelA, labelB], ...
    'Colors', 'k', ...
    'Symbol', '');

ylabel('AICc');
title('Paired AICc comparison');
grid on;
set(gca, 'FontSize', 12);

%% -----------------------------
% Delta AICc histogram
%% -----------------------------
deltaAICc = AICc_A - AICc_B;

figure('Color', 'w');
histogram(deltaAICc(validAIC), 20);
xline(0, 'r--', 'LineWidth', 1.5);

xlabel("\DeltaAICc = " + labelA + " - " + labelB);
ylabel('Number of cells');
title('Difference in AICc');
grid on;
set(gca, 'FontSize', 12);

%% -----------------------------
% Statistics
%% -----------------------------
pR2 = signrank(R2_A, R2_B);

fprintf('\n===== Paired R2 comparison =====\n');
fprintf('%s vs %s\n', labelA, labelB);
fprintf('N = %d\n', numel(R2_A));
fprintf('Median %s R2 = %.4f\n', labelA, median(R2_A));
fprintf('Median %s R2 = %.4f\n', labelB, median(R2_B));
fprintf('Median delta R2 = %.4f\n', median(deltaR2));
fprintf('Mean delta R2 = %.4f\n', mean(deltaR2));
fprintf('Wilcoxon signed-rank p = %.4g\n', pR2);

fprintf('\nCells where %s has higher R2: %d / %d\n', ...
    labelA, sum(deltaR2 > 0), numel(deltaR2));

fprintf('Cells where %s has higher R2: %d / %d\n', ...
    labelB, sum(deltaR2 < 0), numel(deltaR2));

if any(validAIC)
    pAIC = signrank(AICc_A(validAIC), AICc_B(validAIC));

    fprintf('\n===== Paired AICc comparison =====\n');
    fprintf('k %s = %d\n', labelA, kA);
    fprintf('k %s = %d\n', labelB, kB);
    fprintf('N = %d\n', sum(validAIC));
    fprintf('Median %s AICc = %.4f\n', ...
        labelA, median(AICc_A(validAIC)));
    fprintf('Median %s AICc = %.4f\n', ...
        labelB, median(AICc_B(validAIC)));
    fprintf('Median delta AICc = %.4f\n', ...
        median(deltaAICc(validAIC)));
    fprintf('Mean delta AICc = %.4f\n', ...
        mean(deltaAICc(validAIC)));
    fprintf('Wilcoxon signed-rank p = %.4g\n', pAIC);

    fprintf('\nCells where %s has lower AICc: %d / %d\n', ...
        labelA, sum(deltaAICc(validAIC) < 0), sum(validAIC));

    fprintf('Cells where %s has lower AICc: %d / %d\n', ...
        labelB, sum(deltaAICc(validAIC) > 0), sum(validAIC));
end

%% Local functions
%% -----------------------------
% Local function
%% -----------------------------
function plotOrientationStatsForPoster(metrics, mask, groupLabel, saveName)

    methods = {'Carrier/FFT', 'Envelope + 90�', 'Offset axis'};

    errCarrier = abs(metrics.fftMinusData(mask));
    errEnv90 = abs(metrics.env90MinusData(mask));
    errOffset = abs(metrics.offsetMinusData(mask));

    errMat = [errCarrier(:), errEnv90(:), errOffset(:)];

    valid = all(isfinite(errMat), 2);
    errMat = errMat(valid, :);

    fprintf('\n%s\n', groupLabel);
    fprintf('N = %d cells\n', size(errMat, 1));

    [pCarrierEnv, ~, statsCE] = signrank(errMat(:, 1), errMat(:, 2));
    [pCarrierOff, ~, statsCO] = signrank(errMat(:, 1), errMat(:, 3));
    [pEnvOff, ~, statsEO] = signrank(errMat(:, 2), errMat(:, 3));

    fprintf('Carrier vs Envelope+90: p = %.4g\n', pCarrierEnv);
    fprintf('Carrier vs Offset:      p = %.4g\n', pCarrierOff);
    fprintf('Envelope+90 vs Offset:  p = %.4g\n', pEnvOff);

    %% 1. Paired dot/line plot
    figure('Color', 'w', 'Position', [200 200 500 420]);
    hold on;

    x = 1:3;
    for i = 1:size(errMat, 1)
        plot(x, errMat(i, :), '-', ...
            'Color', [0.75 0.75 0.75], ...
            'LineWidth', 0.7);
    end

    scatter(ones(size(errMat, 1), 1), errMat(:, 1), 28, 'filled');
    scatter(2 * ones(size(errMat, 1), 1), errMat(:, 2), 28, 'filled');
    scatter(3 * ones(size(errMat, 1), 1), errMat(:, 3), 28, 'filled');

    medVals = median(errMat, 1, 'omitnan');
    plot(x, medVals, 'k-', 'LineWidth', 3);

    xlim([0.6 3.4]);
    ylim([0 90]);
    xticks(x);
    xticklabels(methods);
    ylabel('|Predicted orientation - measured tuning| (deg)');
    title(groupLabel);
    box off;
    set(gca, 'FontSize', 12);

    saveas(gcf, [saveName '_paired_dot.png']);

    %% 2. Box plot / swarm-style summary
    figure('Color', 'w', 'Position', [200 200 450 420]);

    boxplot(errMat, ...
        'Labels', methods, ...
        'Whisker', 1.5);

    ylabel('|Predicted orientation - measured tuning| (deg)');
    title(groupLabel);
    ylim([0 90]);
    set(gca, 'FontSize', 12);
    box off;

    saveas(gcf, [saveName '_boxplot.png']);

    %% 3. CDF plot
    figure('Color', 'w', 'Position', [200 200 480 420]);
    hold on;

    [f1, x1] = ecdf(errMat(:, 1));
    [f2, x2] = ecdf(errMat(:, 2));
    [f3, x3] = ecdf(errMat(:, 3));

    plot(x1, f1, 'LineWidth', 2.5);
    plot(x2, f2, 'LineWidth', 2.5);
    plot(x3, f3, 'LineWidth', 2.5);

    xlim([0 90]);
    ylim([0 1]);
    xlabel('Absolute orientation mismatch (deg)');
    ylabel('Fraction of cells with mismatch  x');
    legend(methods, 'Location', 'southeast');
    title(groupLabel);
    set(gca, 'FontSize', 12);
    box off;

    saveas(gcf, [saveName '_cdf.png']);
end

function plotCellGroupingPanel(metrics, outDir)

    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    validF1 = isfinite(metrics.F1F0);
    f1Thresh = prctile(metrics.F1F0(validF1), 80);

    group1 = metrics.DSI < 0.3 & metrics.OSI > 0.5;
    group2 = validF1 & metrics.F1F0 >= f1Thresh;
    group3 = metrics.DSI > 0.5;

    groupNames = { ...
        'Low DSI / High OSI', ...
        'Top 20% F1/F0', ...
        'High DSI'};

    groupCounts = [sum(group1), sum(group2), sum(group3)];

    figure('Color', 'w', 'Position', [100 100 1200 360]);

    %% A. DSI vs OSI scatter
    subplot(1, 3, 1);
    hold on;

    scatter(metrics.DSI, metrics.OSI, 28, ...
        [0.75 0.75 0.75], 'filled');

    scatter(metrics.DSI(group1), metrics.OSI(group1), ...
        45, 'filled');

    xline(0.3, '--', 'DSI = 0.3');
    yline(0.5, '--', 'OSI = 0.5');

    xlabel('Direction selectivity index (DSI)');
    ylabel('Orientation selectivity index (OSI)');
    title('Group 1: orientation-selective');
    xlim([0 1]);
    ylim([0 1]);
    axis square;
    box off;

    %% B. F1/F0 histogram
    subplot(1, 3, 2);
    hold on;

    histogram(metrics.F1F0(validF1), 20);
    xline(f1Thresh, '--', ...
        sprintf('Top 20%% threshold = %.2f', f1Thresh), ...
        'LabelOrientation', 'horizontal');

    xlabel('F1/F0');
    ylabel('Cell count');
    title('Group 2: simple-like cells');
    box off;

    %% C. Group size bar plot
    subplot(1, 3, 3);

    bar(groupCounts);
    xticks(1:3);
    xticklabels(groupNames);
    xtickangle(30);

    ylabel('Number of cells');
    title('Defined analysis groups');
    box off;

    set(findall(gcf, '-property', 'FontSize'), 'FontSize', 11);

    saveas(gcf, fullfile(outDir, 'cell_grouping_panel.png'));
    savefig(gcf, fullfile(outDir, 'cell_grouping_panel.fig'));
end

function AICc = computeAICc_manual(RSS, n, k)

    AIC = n .* log(RSS ./ n) + 2 .* k;
    AICc = AIC + (2 .* k .* (k + 1)) ./ (n - k - 1);

end

function checkEnvelopeTheta(params, gaussianMode)

    nPix = 20;
    [X, Y] = meshgrid(1:nPix, 1:nPix);
    XY = [X(:), Y(:)];

    rf = nonConcentricDoGCosineModel(params, XY, gaussianMode);
    rf = reshape(rf, nPix, nPix);

    theta = params(6);
    thetaDeg = mod(rad2deg(theta), 180);

    % Remove cosine effect by reconstructing envelope only if possible.
    env = abs(rf);

    % Weighted PCA envelope orientation.
    W = abs(env);
    W = W / sum(W(:), 'omitnan');

    xMean = sum(X(:) .* W(:), 'omitnan');
    yMean = sum(Y(:) .* W(:), 'omitnan');

    Xc = X - xMean;
    Yc = Y - yMean;

    Cxx = sum(W(:) .* Xc(:).^2, 'omitnan');
    Cyy = sum(W(:) .* Yc(:).^2, 'omitnan');
    Cxy = sum(W(:) .* Xc(:) .* Yc(:), 'omitnan');

    C = [Cxx Cxy; Cxy Cyy];
    [V, D] = eig(C);

    [~, idx] = max(diag(D));
    v = V(:, idx);

    % Important: y-flip for image display.
    envDeg = mod(rad2deg(atan2(-v(2), v(1))), 180);

    diffDeg = abs(angleDiff180(envDeg, thetaDeg));

    fprintf('theta = %.2f deg\n', thetaDeg);
    fprintf('extracted envelope = %.2f deg\n', envDeg);
    fprintf('|difference| = %.2f deg\n', diffDeg);

    figure;
    imagesc(rf);
    axis image;
    colormap gray;
    hold on;

    cx = nPix / 2;
    cy = nPix / 2;
    L = 8;

    plot(cx + L * [-cosd(thetaDeg), cosd(thetaDeg)], ...
         cy - L * [-sind(thetaDeg), sind(thetaDeg)], ...
         'y-', 'LineWidth', 2);

    plot(cx + L * [-cosd(envDeg), cosd(envDeg)], ...
         cy - L * [-sind(envDeg), sind(envDeg)], ...
         'r-', 'LineWidth', 2);

    legend({'theta', 'extracted envelope'});
    title(sprintf('|env - theta| = %.1f deg', diffDeg));
end
function d = signedAngleDiff180(a, b)
%SIGNEDANGLEDIFF180 Signed orientation difference in degrees.
% Returns a - b wrapped to [-90, 90].

    d = mod((a - b) + 90, 180) - 90;
end

function plotOrientationExplanatoryStats(metrics, mask, groupName, groupLabel)

    fftDeg = metrics.fftDeg(mask);
    env90Deg = metrics.env90Deg(mask);
    offsetDeg = metrics.offsetDeg(mask);
    dataDeg = metrics.dataOriDeg(mask);
    % Orientation correlation summary
    r_fft = orientationCorr(fftDeg, dataDeg);
    r_env90 = orientationCorr(env90Deg, dataDeg);
    r_offset = orientationCorr(offsetDeg, dataDeg);

    r_vals = [r_fft, r_env90, r_offset];
    r2_vals = r_vals.^2;

    figure('Name', [groupName '_OrientationCorr']);
    bar(r2_vals);

    set(gca, 'XTickLabel', ...
        {'Carrier / FFT', 'Envelope + 90', 'Offset axis'});

    ylabel('Squared orientation correlation');
    title(['Orientation correspondence strength: ' groupLabel], ...
        'Interpreter', 'none');

    ylim([0, 1]);
    box off;

    fftErr = abs(metrics.fftMinusData(mask));
    envErr = abs(metrics.env90MinusData(mask));
    offErr = abs(metrics.offsetMinusData(mask));

    fprintf('\n===== %s =====\n', groupLabel);
    fprintf('N cells = %d\n', sum(mask));

    % Angular prediction error summary
    MSE_fft = mean(fftErr.^2, 'omitnan');
    MSE_env90 = mean(envErr.^2, 'omitnan');
    MSE_offset = mean(offErr.^2, 'omitnan');
    
    RMSE_fft = sqrt(MSE_fft);
    RMSE_env90 = sqrt(MSE_env90);
    RMSE_offset = sqrt(MSE_offset);
    
    RMSE_vals = [RMSE_fft, RMSE_env90, RMSE_offset];
    
    figure('Name', [groupName '_RMSE']);
    bar(RMSE_vals);
    
    set(gca, 'XTickLabel', ...
        {'Carrier / FFT', 'Envelope + 90', 'Offset axis'});
    
    ylabel('Root mean squared mismatch (deg)');
    title(['Angular prediction error: ' groupLabel], ...
        'Interpreter', 'none');
    
    ylim([0, max(RMSE_vals) + 5]);
    box off;

    % CDF plot
    figure('Name', [groupName '_CDF']);
    hold on;

    legendText = {};

    if any(~isnan(fftErr))
        cdfplot(fftErr(~isnan(fftErr)));
        legendText{end + 1} = 'Carrier / FFT';
    end

    if any(~isnan(envErr))
        cdfplot(envErr(~isnan(envErr)));
        legendText{end + 1} = 'Envelope + 90';
    end

    if any(~isnan(offErr))
        cdfplot(offErr(~isnan(offErr)));
        legendText{end + 1} = 'Offset axis';
    end

    xlabel('Mismatch to data orientation (deg)');
    ylabel('Cumulative fraction of cells');
    title(['Orientation mismatch distributions: ' groupLabel], ...
        'Interpreter', 'none');

    if ~isempty(legendText)
        legend(legendText, 'Location', 'southeast');
    end

    xlim([0 90]);
    grid on;
    box off;

    % Boxplot
    errMat = [fftErr(:), envErr(:), offErr(:)];
    labels = {'Carrier', 'Envelope+90', 'Offset'};

    validCols = any(~isnan(errMat), 1);
    errMat = errMat(:, validCols);
    labels = labels(validCols);

    figure('Name', [groupName '_Boxplot']);
    boxplot(errMat, 'Labels', labels);

    ylabel('Mismatch to measured orientation (deg)');
    title(['Mismatch comparison: ' groupLabel], ...
        'Interpreter', 'none');
    box off;

    % Statistics
    fprintf('\nMedian mismatch:\n');
    fprintf('Carrier / FFT: %.2f deg\n', median(fftErr, 'omitnan'));
    fprintf('Envelope + 90: %.2f deg\n', median(envErr, 'omitnan'));
    fprintf('Offset axis:   %.2f deg\n', median(offErr, 'omitnan'));

    fprintf('\nAngular prediction error:\n');
    fprintf('Carrier / FFT RMSE: %.2f deg, MSE: %.2f\n', ...
        RMSE_fft, MSE_fft);
    fprintf('Envelope + 90 RMSE: %.2f deg, MSE: %.2f\n', ...
        RMSE_env90, MSE_env90);
    fprintf('Offset axis RMSE:   %.2f deg, MSE: %.2f\n', ...
        RMSE_offset, MSE_offset);

    fprintf('\nOrientation correlation:\n');
    fprintf('Carrier / FFT r: %.3f, r^2: %.3f\n', ...
        r_fft, r_fft^2);
    fprintf('Envelope + 90 r: %.3f, r^2: %.3f\n', ...
        r_env90, r_env90^2);
    fprintf('Offset axis r:   %.3f, r^2: %.3f\n', ...
        r_offset, r_offset^2);

    fprintf('\nPaired signrank tests:\n');

    runSignrankSafe(fftErr, envErr, 'Carrier vs Envelope+90');
    runSignrankSafe(fftErr, offErr, 'Carrier vs Offset');
    runSignrankSafe(envErr, offErr, 'Envelope+90 vs Offset');

end

function r = orientationCorr(predDeg, dataDeg)

    valid = ~isnan(predDeg) & ~isnan(dataDeg);

    predDeg = predDeg(valid);
    dataDeg = dataDeg(valid);

    predVec = [
        cosd(2 * predDeg(:)), ...
        sind(2 * predDeg(:))
    ];

    dataVec = [
        cosd(2 * dataDeg(:)), ...
        sind(2 * dataDeg(:))
    ];

    predVec = predVec(:);
    dataVec = dataVec(:);

    r = corr(predVec, dataVec);

end

function runSignrankSafe(err1, err2, label)

    valid = ~isnan(err1) & ~isnan(err2);

    if sum(valid) < 3
        fprintf('%s: not enough valid paired cells\n', label);
        return
    end

    [p, ~, stats] = signrank(err1(valid), err2(valid));

    fprintf('%s: p = %.4g, N = %d\n', ...
        label, p, sum(valid));

end

function R2 = orientationVectorR2(predDeg, dataDeg)

    valid = ~isnan(predDeg) & ~isnan(dataDeg);

    predDeg = predDeg(valid);
    dataDeg = dataDeg(valid);

    Y = [cosd(2 * dataDeg(:)), sind(2 * dataDeg(:))];
    Yhat = [cosd(2 * predDeg(:)), sind(2 * predDeg(:))];

    Ymean = mean(Y, 1);

    ssRes = sum((Y - Yhat).^2, 'all');
    ssTot = sum((Y - Ymean).^2, 'all');

    if ssTot == 0
        R2 = NaN;
    else
        R2 = 1 - ssRes / ssTot;
    end
end

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
    metrics.F1F0 = nan(nFitted, 1);
    metrics.smoothDataOriDeg = nan(nFitted, 1);

    for ii = 1:nFitted
        k = fittedIdx(ii);      % k is 1 to 209
        iCell = cellIDs(k);     % iCell is original cell index

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
        ori = getModelOrientations(paramCell{k});
        % if exist('sgRawFit', 'var') && ~isempty(sgRawFit{k})
        %     ori = getSGGaborOrientations(sgRawFit{k});
        %     fprintf("Gabor mode/n");
        % end
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
    % 
    % plotGroupVsRestOSI( ...
    %     metrics, groupMask, ...
    %     fullfile(outDir, [groupDef.name '_OSI_group_vs_rest.pdf']), ...
    %     groupDef.label);
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
            assert(numel(oriDeg) == numel(oriResp), ...
             'oriDeg and oriResp length mismatch.');
            
            ii = find(metrics.staModelIdx == k, 1);
            
            assert(~isempty(ii), 'No metrics row found for this k.');
            assert(metrics.fittedCellIDs(ii) == iCell, ...
                'Mismatch: metrics fittedCellIDs does not match plotted cell.');
            dataDeg = metrics.dataOriDeg(ii);
            ori = getModelOrientations(p);

            envDiff = abs(angleDiff180(ori.env_deg, dataDeg));
            fftDiff = abs(angleDiff180(ori.fft_deg, dataDeg));

            subplot(nRows, nCols, panelRF)
            tau = p(5);
            
            plotRFWithOrientationLines(rf, ori, dataDeg, iCell, ...
                envDiff, fftDiff, p);

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

function plotRFWithOrientationLines(rf, ori, dataDeg, iCell, ...
    envDiff, fftDiff, p)
%PLOTRFWITHORIENTATIONLINES Plot RF with axes and fitted envelopes.

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

    % Plot envelope axis.
    thetaEnvDisplay = deg2rad(-ori.env_deg);
    plotOriLine(cx, cy, L, thetaEnvDisplay, 'r-');

    % Yellow theta / FFT line, kept for reference but commented out.
    % thetaFftDisplay = deg2rad(-ori.fft_deg);
    % plotOriLine(cx, cy, L, thetaFftDisplay, 'y-');

    % Plot data orientation.
    thetaDataDisplay = deg2rad(-dataDeg);
    plotOriLine(cx, cy, L, thetaDataDisplay, 'c-');

    % Plot fitted center and surround Gaussian envelopes.
    plotDoGEllipsesOnRF(p, nx, ny);

    tau = p(5);

    title(sprintf(['Cell %d | tau %.2f\n' ...
        'Data %.0f | Env %.0f d %.0f\n' ...
        'FFT %.0f d %.0f'], ...
        iCell, tau, dataDeg, ori.env_deg, envDiff, ...
        ori.fft_deg, fftDiff), 'FontSize', 7);

    hold off
end

function plotDoGEllipsesOnRF(p, nx, ny)
%PLOTDOGELLIPSESONRF Plot center and surround Gaussian envelope ellipses.
%
% This assumes the model uses:
%     exp(-(Xcp.^2 + (tau * Ycp).^2) / (2 * sigma^2))
%
% Therefore:
%     sigmaX = sigma
%     sigmaY = sigma / tau

    sc = p(3);
    deltaSigma = p(4);
    ss = sc + deltaSigma;
    tau = p(5);
    theta = p(6);
    x0 = p(7);
    y0 = p(8);
    dx = p(11);
    dy = p(12);

    % Convert model-centered coordinates to image pixel coordinates.
    cxImg = (nx + 1) / 2 + x0;
    cyImg = (ny + 1) / 2 + y0;

    sxImg = (nx + 1) / 2 + x0 + dx;
    syImg = (ny + 1) / 2 + y0 + dy;

    % Effective Gaussian standard deviations.
    sigmaCx = sc;
    sigmaCy = sc / tau;

    sigmaSx = ss;
    sigmaSy = ss / tau;

    nSigma = 2;

    plotEllipse(cxImg, cyImg, nSigma * sigmaCx, ...
        nSigma * sigmaCy, theta, 'g-', 1.5);

    plotEllipse(sxImg, syImg, nSigma * sigmaSx, ...
        nSigma * sigmaSy, theta, 'm-', 1.5);
end

function plotEllipse(cx, cy, rx, ry, theta, lineSpec, lineWidth)
%PLOTELLIPSE Plot a rotated ellipse on an imagesc axis.

    t = linspace(0, 2 * pi, 200);

    x = rx * cos(t);
    y = ry * sin(t);

    xr = x * cos(theta) - y * sin(theta);
    yr = x * sin(theta) + y * cos(theta);

    plot(cx + xr, cy + yr, lineSpec, 'LineWidth', lineWidth);
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

    edgesOri = 0:15:180;
    edgesOri30 = 0:30:180;
    edgesDiff = -90:15:90;

    fig = figure('Color', 'w', 'Position', [200 200 1200 400]);

    subplot(1, 3, 1)
    histogram(metrics.dataOriDeg(groupMask), edgesOri30);
    % histogram(metrics.smoothDataOriDeg(groupMask), edgesOri);
    xlabel('Grating preferred orientation (deg)');
    ylabel('Cell count');
    title('Data orientation');
    xlim([0 180]);
    xticks(0:30:180);
    grid on

    subplot(1, 3, 2)
    histogram(metrics.fftDeg(groupMask), edgesOri);
    xlabel('Model predicted orientation (deg)');
    ylabel('Cell count');
    title('Model orientation');
    xlim([0 180]);
    xticks(0:15:180);
    grid on

    subplot(1, 3, 3)
    histogram(metrics.fftMinusData(groupMask), edgesDiff);
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
        offsetDeg = mod(rad2deg(atan2(-dy, dx)), 180);
    end

    ori.env_deg = mod(rad2deg(-thetaEnv), 180);
    ori.env90_deg = mod(ori.env_deg + 90, 180);
    ori.fft_deg = mod(rad2deg(atan2(-fy, fx)), 180);
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

function plotTuningMetricGraphics_clean(outDir)

    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    dirs = 0:30:330;
    theta = deg2rad(dirs);

    prefDir = 60;
    respDir = 0.1 + exp(1.8 * cosd(dirs - prefDir));
    respDir = respDir ./ max(respDir);

    oriDeg = 0:30:150;
    respOri = zeros(size(oriDeg));

    for i = 1:numel(oriDeg)
        d1 = oriDeg(i);
        d2 = mod(d1 + 180, 360);
        [~, i1] = min(abs(angleDiff360(dirs, d1)));
        [~, i2] = min(abs(angleDiff360(dirs, d2)));
        respOri(i) = mean([respDir(i1), respDir(i2)]);
    end

    respOri = respOri ./ max(respOri);

    [RprefDir, prefIdx] = max(respDir);
    prefDirDeg = dirs(prefIdx);

    nullDirDeg = mod(prefDirDeg + 180, 360);
    [~, nullIdx] = min(abs(angleDiff360(dirs, nullDirDeg)));
    Rnull = respDir(nullIdx);

    [RprefOri, prefOriIdx] = max(respOri);
    prefOriDeg = oriDeg(prefOriIdx);

    orthOriDeg = mod(prefOriDeg + 90, 180);
    [~, orthIdx] = min(abs(angleDiff180(oriDeg, orthOriDeg)));
    Rorth = respOri(orthIdx);

    DSI = (RprefDir - Rnull) / (RprefDir + Rnull);
    OSI = (RprefOri - Rorth) / (RprefOri + Rorth);

    t = linspace(0, 2, 500);
    F0 = 1.5;
    F1 = 1.1;
    temporalResp = F0 + F1 * sin(2 * pi * 2 * t);
    F1F0 = F1 / F0;

    figure('Color', 'w', 'Position', [100 100 1050 650]);

    %% Direction polar plot
    subplot(2, 3, 1);
    polarplot([theta theta(1)], [respDir respDir(1)], ...
        'k-', 'LineWidth', 2);
    hold on;
    polarplot(deg2rad(prefDirDeg), RprefDir, ...
        'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7);
    polarplot(deg2rad(nullDirDeg), Rnull, ...
        'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 7);
    title('Direction tuning');

    %% Orientation polar plot
    subplot(2, 3, 2);
    oriTheta = deg2rad([oriDeg oriDeg + 180]);
    oriRespPlot = [respOri respOri];

    polarplot([oriTheta oriTheta(1)], ...
        [oriRespPlot oriRespPlot(1)], ...
        'k-', 'LineWidth', 2);
    hold on;
    polarplot(deg2rad(prefOriDeg), RprefOri, ...
        'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7);
    polarplot(deg2rad(prefOriDeg + 180), RprefOri, ...
        'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 7);
    polarplot(deg2rad(orthOriDeg), Rorth, ...
        'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 7);
    polarplot(deg2rad(orthOriDeg + 180), Rorth, ...
        'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 7);
    title('Orientation tuning');

    %% Temporal modulation
    subplot(2, 3, 3);
    plot(t, temporalResp, 'k-', 'LineWidth', 2);
    hold on;
    yline(F0, '--', 'F0 mean');
    xlabel('Time');
    ylabel('Response');
    title('Temporal modulation');
    text(0.15, 2.75, sprintf('F1/F0 = %.2f', F1F0), ...
        'FontSize', 11);
    box off;

    %% DSI formula
    subplot(2, 3, 4);
    axis off;
    text(0, 0.80, 'Direction Selectivity Index', ...
        'FontSize', 13, 'FontWeight', 'bold');
    text(0, 0.55, ...
        'DSI = (R_{pref} - R_{null}) / (R_{pref} + R_{null})', ...
        'FontSize', 12);
    text(0, 0.32, sprintf('Example DSI = %.2f', DSI), ...
        'FontSize', 12);
    text(0, 0.12, ...
        'Compares preferred direction with opposite direction.', ...
        'FontSize', 10);

    %% OSI formula
    subplot(2, 3, 5);
    axis off;
    text(0, 0.80, 'Orientation Selectivity Index', ...
        'FontSize', 13, 'FontWeight', 'bold');
    text(0, 0.55, ...
        'OSI = (R_{pref} - R_{orth}) / (R_{pref} + R_{orth})', ...
        'FontSize', 12);
    text(0, 0.32, sprintf('Example OSI = %.2f', OSI), ...
        'FontSize', 12);
    text(0, 0.12, ...
        'Compares preferred orientation with orthogonal orientation.', ...
        'FontSize', 10);

    %% F1/F0 formula
    subplot(2, 3, 6);
    axis off;
    text(0, 0.80, 'F1/F0', ...
        'FontSize', 13, 'FontWeight', 'bold');
    text(0, 0.55, ...
        'F1/F0 = first harmonic / mean response', ...
        'FontSize', 12);
    text(0, 0.32, sprintf('Example F1/F0 = %.2f', F1F0), ...
        'FontSize', 12);
    text(0, 0.12, ...
        'Higher F1/F0 indicates stronger stimulus-locked modulation.', ...
        'FontSize', 10);

    sgtitle('Tuning Metrics Used to Define Functional Groups', ...
        'FontSize', 16, 'FontWeight', 'bold');

    saveas(gcf, fullfile(outDir, 'tuning_metric_graphics_clean.png'));
    savefig(gcf, fullfile(outDir, 'tuning_metric_graphics_clean.fig'));
end

function d = angleDiff360(a, b)
    d = abs(mod(a - b + 180, 360) - 180);
end

%% -----------------------------
% Local plotting function
%% -----------------------------
function plotErrorVsDSI(x, y, yLabelText, titleText)

    valid = isfinite(x) & isfinite(y);

    x = x(valid);
    y = y(valid);

    figure('Color', 'w');
    scatter(x, y, 45, 'filled');
    hold on;

    % Linear regression line
    pFit = polyfit(x, y, 1);
    xFit = linspace(min(x), max(x), 100);
    yFit = polyval(pFit, xFit);
    plot(xFit, yFit, 'k-', 'LineWidth', 2);

    % Spearman correlation
    [rho, pVal] = corr(x, y, 'Type', 'Spearman');

    xlabel('DSI');
    ylabel(yLabelText);
    title(sprintf('%s: rho = %.2f, p = %.3g', ...
        titleText, rho, pVal));

    box off;
    grid on;
    set(gca, 'FontSize', 12);
end

% Helper function
%% -----------------------------
function plotOrientationLine(ax, oriDeg, imSize, lineColor, lineWidth)

    axes(ax);

    nY = imSize(1);
    nX = imSize(2);

    cx = (nX + 1) / 2;
    cy = (nY + 1) / 2;

    len = 0.42 * min(nX, nY);

    theta = deg2rad(oriDeg);

    dx = len * cos(theta);
    dy = -len * sin(theta);  % negative because image y-axis points down

    plot([cx - dx, cx + dx], ...
         [cy - dy, cy + dy], ...
         '-', ...
         'Color', lineColor, ...
         'LineWidth', lineWidth);
end

%% Helper function
function oriDeg = getSTAFFTOrientation(STA)

    STA = double(STA);
    STA = STA - mean(STA(:), 'omitnan');

    if all(~isfinite(STA(:))) || max(abs(STA(:))) == 0
        oriDeg = NaN;
        return
    end

    STA(~isfinite(STA)) = 0;

    F = abs(fftshift(fft2(STA)));
    F = F .^ 2;

    [ny, nx] = size(STA);
    cx = floor(nx / 2) + 1;
    cy = floor(ny / 2) + 1;

    % Remove DC / very low frequency center
    [X, Y] = meshgrid(1:nx, 1:ny);
    R = sqrt((X - cx).^2 + (Y - cy).^2);
    F(R < 2) = 0;

    % Find strongest FFT component
    [~, idx] = max(F(:));
    [iy, ix] = ind2sub(size(F), idx);

    fx = ix - cx;
    fy = -(iy - cy);  % flip because image y-axis points downward

    % Frequency-vector orientation
    oriDeg = mod(rad2deg(atan2(fy, fx)), 180);
end