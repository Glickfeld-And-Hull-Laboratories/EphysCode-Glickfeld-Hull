%% ========================================================================
%  runRFModelComparison
%
%  Modular RF model comparison pipeline.
%
%  Fits multiple receptive field models to STA data, computes R² and AICc,
%  and optionally visualizes or exports comparison figures.
%
%  ------------------------------------------------------------------------
%  INPUTS
%
%  indLoop        : indices of cells to process (e.g., indLoop)
%  ind_DS         : vector mapping index → actual cell ID
%  STA_cropped    : 3D array (y × x × cellIndex) of cropped STA images
%  modelRegistry  : struct array defining models to run (see example below)
%  omitCells      : vector of cell IDs to skip (based on actual cell ID)
%
%  plotMode       : (optional) controls visualization behavior
%                   'show'  → display figures only
%                   'pdf'   → export figures to single PDF (no pop-up)
%                   'both'  → display AND export
%                   'none'  → no plotting (compute only)
%
%  pdfFile        : (optional) filename for PDF export (required if
%                   plotMode = 'pdf' or 'both')
%
%  ------------------------------------------------------------------------
%  OUTPUT
%
%  results : struct containing
%       .cellIDs      → processed cell IDs
%       .R2{m}        → R² per model
%       .AIC{m}       → AICc per model
%       .models{m}{k} → fitted RF images
%
%  ------------------------------------------------------------------------
%  EXAMPLE USAGE
%
%  % --- Define models ---
%  modelRegistry = [
%      struct('name','Circular DoG', ...
%             'type','standard', ...
%             'fitFcn', @(STA) fitDoG2D_JM(STA,'unnormalized',20), ...
%             'k',6)
%
%      struct('name','SG Gabor', ...
%             'type','sg', ...
%             'fitFcn', @(STA) fit2dGabor_SG(STA,options), ...
%             'k',10)
%  ];
%
%  % --- Cells to omit (by cell ID) ---
%  omitCells = [39 102];
%
%  % --- Run and show only ---
%  results = runRFModelComparison( ...
%      indLoop, ind_DS, STA_cropped, ...
%      modelRegistry, omitCells, 'show');
%
%  % --- Run and export to PDF ---
%  results = runRFModelComparison( ...
%      indLoop, ind_DS, STA_cropped, ...
%      modelRegistry, omitCells, ...
%      'pdf', 'RF_Comparison_AllCells.pdf');
%
%  ------------------------------------------------------------------------
%  NOTES
%
%  • Models of type 'standard' must return:
%        [params, RF, fitInfo]
%
%  • Models of type 'sg' must return struct with fields:
%        .patch (fitted RF image)
%        .r2    (R² value)
%
%  • AICc is computed internally using computeAIC.
%
%  • Omit list is based on actual cell ID (ic), NOT loop index (ii).
%
%  ========================================================================
function results = runRFModelComparison( ...
    indLoop, ind_DS, STA_cropped, ...
    modelRegistry, omitCells, ...
    plotMode, pdfFile, ...
    compareR2Models, compareAICModels)

if nargin < 6 || isempty(plotMode)
    plotMode = 'show';   % default behavior
end

if nargin < 8
    compareR2Models = [];
end

if nargin < 9
    compareAICModels = [];
end

%% -----------------------------
% Setup results folder
%% -----------------------------

resultsFolder = fullfile(pwd, 'results');

if ~exist(resultsFolder, 'dir')
    mkdir(resultsFolder);
end

if strcmp(plotMode,'pdf') || strcmp(plotMode,'both')

    if nargin < 7 || isempty(pdfFile)
        pdfFile = 'RF_Model_Comparison.pdf';
    end

    pdfFile = fullfile(resultsFolder, pdfFile);

    if exist(pdfFile,'file')
        delete(pdfFile)
    end
end

computeR2 = @(data, model) ...
    1 - sum((data(:) - model(:)).^2) / ...
        sum((data(:) - mean(data(:))).^2);

nModels = numel(modelRegistry);
nValid  = numel(indLoop);

results = struct;
results.cellIDs = [];
results.R2  = cell(nModels,1);
results.AIC = cell(nModels,1);
results.models = cell(nModels,1);

for m = 1:nModels
    results.R2{m}  = nan(nValid,1);
    results.AIC{m} = nan(nValid,1);
    results.models{m} = cell(nValid,1);
end

k = 0;

for idx = 1:numel(indLoop)

    ii = indLoop(idx);
    ic = ind_DS(ii);

    if ismember(ic, omitCells)
        continue
    end

    k = k + 1;

    STA = STA_cropped(:,:,ii);
    n   = numel(STA);

    results.cellIDs(k) = ic;

    fprintf('\nProcessing Cell %d (ii=%d)\n', ic, ii);

    %% ===============================
    % Run All Models
    %% ===============================

    for m = 1:nModels

        model = modelRegistry(m);

        if strcmp(model.type, 'sg')

            res = model.fitFcn(STA);
            RF  = res.patch;
            R2  = res.r2;

        else

            [~, RF, ~] = model.fitFcn(STA);
            R2 = computeR2(STA, RF);

        end

        RSS = sum((STA(:) - RF(:)).^2);

        results.models{m}{k} = RF;
        results.R2{m}(k)  = R2;
        results.AIC{m}(k) = computeAIC(RSS, n, model.k);

    end

    %% ===============================
    % Visualization
    %% ===============================

    if ~strcmp(plotMode,'none')
        visualizeComparison( ...
            STA, results, modelRegistry, ...
            k, ic, ii, plotMode, pdfFile);
    end

end
modelNames = {modelRegistry.name};

%% ============================================
% R² Comparison (Display Only)
%% ============================================

if ~isempty(compareR2Models)

    idx1 = find(strcmp(modelNames, compareR2Models{1}));
    idx2 = find(strcmp(modelNames, compareR2Models{2}));

    if isempty(idx1) || isempty(idx2)
        error('Invalid model name in compareR2Models')
    end

    R2_1 = results.R2{idx1};
    R2_2 = results.R2{idx2};

    figure('Color','w');
    scatter(R2_1, R2_2, 60, 'filled');
    hold on
    plot([0 1],[0 1],'k--','LineWidth',1.5)
    xlabel(compareR2Models{1})
    ylabel(compareR2Models{2})
    title('R^2 Model Comparison')
    axis square
    grid on
end

%% ============================================
% ΔAIC Histogram Comparison
%% ============================================

if ~isempty(compareAICModels)

    idx1 = find(strcmp(modelNames, compareAICModels{1}));
    idx2 = find(strcmp(modelNames, compareAICModels{2}));

    if isempty(idx1) || isempty(idx2)
        error('Invalid model name in compareAICModels')
    end

    AIC_1 = results.AIC{idx1};
    AIC_2 = results.AIC{idx2};

    % ΔAIC definition
    deltaAIC = AIC_2 - AIC_1;

    figure('Color','w');
    histogram(deltaAIC, 20);
    hold on
    xline(0,'r','LineWidth',2)

    xlabel(sprintf('\\DeltaAIC = %s − %s', ...
        compareAICModels{2}, compareAICModels{1}))
    ylabel('Number of Cells')
    title('\DeltaAIC Model Comparison')
    grid on

    % Print summary
    fprintf('\nAIC Comparison: %s vs %s\n', ...
        compareAICModels{1}, compareAICModels{2});

    fprintf('Mean ΔAIC: %.3f\n', mean(deltaAIC));
    fprintf('Median ΔAIC: %.3f\n', median(deltaAIC));

    fprintf('Cells where %s wins: %d / %d\n', ...
        compareAICModels{1}, ...
        sum(deltaAIC > 0), length(deltaAIC));

    fprintf('Cells where %s wins: %d / %d\n\n', ...
        compareAICModels{2}, ...
        sum(deltaAIC < 0), length(deltaAIC));
end

validIdx = ~isnan(R2_1) & ~isnan(R2_2);

R2_diff = R2_1(validIdx) - R2_2(validIdx);

fprintf('\nR² mean difference: %.4f\n', mean(R2_diff));
fprintf('R² median difference: %.4f\n', median(R2_diff));
fprintf('Valid cells used: %d\n', sum(validIdx));

validIdx = ~isnan(AIC_1) & ~isnan(AIC_2);

AIC_diff = AIC_1(validIdx) - AIC_2(validIdx);

fprintf('\nAIC mean difference: %.4f\n', mean(AIC_diff));
fprintf('AIC median difference: %.4f\n', median(AIC_diff));
fprintf('Valid cells used: %d\n', sum(validIdx));

end