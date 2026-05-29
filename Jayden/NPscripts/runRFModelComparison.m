%% ========================================================================
%  runRFModelComparison
%
%  Modular RF model comparison pipeline.
%
%  Fits multiple receptive field models to STA data, computes R and AICc,
%  and optionally visualizes or exports comparison figures.
%
%  ------------------------------------------------------------------------
%  INPUTS
%
%  indLoop        : indices of cells to process (e.g., indLoop)
%  ind_DS         : vector mapping index  actual cell ID
%  STA_cropped    : 3D array (y  x  cellIndex) of cropped STA images
%  modelRegistry  : struct array defining models to run (see example below)
%  omitCells      : vector of cell IDs to skip (based on actual cell ID)
%
%  plotMode       : (optional) controls visualization behavior
%                   'show'   display figures only
%                   'pdf'    export figures to single PDF (no pop-up)
%                   'both'   display AND export
%                   'none'   no plotting (compute only)
%
%  pdfFile        : (optional) filename for PDF export (required if
%                   plotMode = 'pdf' or 'both')
%
%  ------------------------------------------------------------------------
%  OUTPUT
%
%  results : struct containing
%       .cellIDs       processed cell IDs
%       .R2{m}         R per model
%       .AIC{m}        AICc per model
%       .models{m}{k}  fitted RF images
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
%   Models of type 'standard' must return:
%        [params, RF, fitInfo]
%
%   Models of type 'sg' must return struct with fields:
%        .patch (fitted RF image)
%        .r2    (R value)
%
%   AICc is computed internally using computeAIC.
%
%   Omit list is based on actual cell ID (ic), NOT loop index (ii).
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
%% Remove omitted cells first
validMask = true(size(indLoop));

for i = 1:numel(indLoop)
    ic = ind_DS(indLoop(i));
    if ismember(ic, omitCells)
        validMask(i) = false;
    end
end

indLoop = indLoop(validMask);
nValid  = numel(indLoop);

results = struct;
results.models = cell(nModels,1);
results.params = cell(nModels,1);
results.R2     = cell(nModels,1);
results.AIC    = cell(nModels,1);
results.cellIDs = nan(nValid,1);
results.RSS = cell(nModels,1);
results.fitInfo = cell(nModels,1);
results.modelRegistry = modelRegistry;
results.indLoopUsed = indLoop(:);

for m = 1:nModels
    results.RSS{m} = nan(nValid,1);
    results.fitInfo{m} = cell(nValid,1);
end


for m = 1:nModels
    results.models{m} = cell(nValid,1);
    results.params{m} = cell(nValid,1);
    results.R2{m}     = nan(nValid,1);
    results.AIC{m}    = nan(nValid,1);
end

k = 0;

results.sgRawFit = cell(nModels, 1);

for m = 1:nModels
    results.sgRawFit{m} = cell(nValid, 1);
end

globalMaxAbs = max(abs(STA_cropped(:,:,indLoop)), [], 'all');
globalCLim = [-globalMaxAbs, globalMaxAbs];

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
    
        switch modelRegistry(m).type
    
            case 'standard'
    
                [params, RF, fitInfo] = ...
                    modelRegistry(m).fitFcn(STA);
    
                results.models{m}{k} = RF;
                results.params{m}{k} = params;
    
            case 'sg'

                resSG = modelRegistry(m).fitFcn(STA);
            
                results.models{m}{k} = resSG.patch;
                results.sgRawFit{m}{k} = resSG.fit;
                sgParams = convertSGGaborToDoGXcosParams(resSG.fit);
                results.params{m}{k} = sgParams;
                disp(resSG.fit)
                disp(fieldnames(resSG.fit))
                sgParams = convertSGGaborToDoGXcosParams(resSG.fit);

                disp('Converted SG params:')
                disp(sgParams)
                
                fprintf('theta p(6) = %.4f rad, %.2f deg\n', ...
                    sgParams(6), rad2deg(sgParams(6)));
                
    
        end
    
        % ---- Compute metrics ----
        RSS = sum((STA(:) - results.models{m}{k}(:)).^2);
        results.RSS{m}(k) = RSS;
        results.fitInfo{m}{k} = fitInfo;
        results.R2{m}(k) = computeR2(STA, results.models{m}{k});
        results.AIC{m}(k) = computeAIC(RSS, n, modelRegistry(m).k);
    
    end

    %% ===============================
    % Visualization
    %% ===============================

    if ~strcmp(plotMode,'none')
        visualizeComparison( ...
            STA, results, modelRegistry, ...
            k, ic, ii, plotMode, pdfFile, globalCLim);
    end

end
modelNames = {modelRegistry.name};
% disp(results.params)
%% tests
% disp(resSG.fit)
% fprintf('a %.3f\n', resSG.fit.a);
% fprintf('b %.3f\n', resSG.fit.b);
% fprintf('x0 %.3f | y0 %.3f\n', resSG.fit.x0, resSG.fit.y0);
% fprintf('sigmax %.3f | sigmay %.3f\n', ...
%     resSG.fit.sigmax, resSG.fit.sigmay);
% fprintf('theta %.3f rad | %.1f deg\n', ...
%     resSG.fit.theta, rad2deg(resSG.fit.theta));
% fprintf('phi %.3f | phase %.3f\n', ...
%     resSG.fit.phi, resSG.fit.phase);
% fprintf('lambda %.3f | frequency %.3f\n', ...
%     resSG.fit.lambda, 1 / resSG.fit.lambda);


%% ============================================
% R Comparison (Display Only)
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
% AIC Histogram Comparison
%% ============================================

if ~isempty(compareAICModels)

    idx1 = find(strcmp(modelNames, compareAICModels{1}));
    idx2 = find(strcmp(modelNames, compareAICModels{2}));

    if isempty(idx1) || isempty(idx2)
        error('Invalid model name in compareAICModels')
    end

    AIC_1 = results.AIC{idx1};
    AIC_2 = results.AIC{idx2};

    % AIC definition
    deltaAIC = AIC_2 - AIC_1;

    figure('Color','w');
    histogram(deltaAIC, 20);
    hold on
    xline(0,'r','LineWidth',2)

    xlabel(sprintf('\\DeltaAIC = %s  %s', ...
        compareAICModels{2}, compareAICModels{1}))
    ylabel('Number of Cells')
    title('\DeltaAIC Model Comparison')
    grid on

    % Print summary
    fprintf('\nAIC Comparison: %s vs %s\n', ...
        compareAICModels{1}, compareAICModels{2});

    fprintf('Mean AIC: %.3f\n', mean(deltaAIC));
    fprintf('Median AIC: %.3f\n', median(deltaAIC));

    fprintf('Cells where %s wins: %d / %d\n', ...
        compareAICModels{1}, ...
        sum(deltaAIC > 0), length(deltaAIC));

    fprintf('Cells where %s wins: %d / %d\n\n', ...
        compareAICModels{2}, ...
        sum(deltaAIC < 0), length(deltaAIC));


    validIdx = ~isnan(R2_1) & ~isnan(R2_2);
    
    R2_diff = R2_1(validIdx) - R2_2(validIdx);
    
    fprintf('\nR mean difference: %.4f\n', mean(R2_diff));
    fprintf('R median difference: %.4f\n', median(R2_diff));
    fprintf('Valid cells used: %d\n', sum(validIdx));
    
    validIdx = ~isnan(AIC_1) & ~isnan(AIC_2);
    
    AIC_diff = AIC_1(validIdx) - AIC_2(validIdx);
    
    fprintf('\nAIC mean difference: %.4f\n', mean(AIC_diff));
    fprintf('AIC median difference: %.4f\n', median(AIC_diff));
    fprintf('Valid cells used: %d\n', sum(validIdx));
end 
end

function p = convertSGGaborToDoGXcosParams(sgFit)
%CONVERTSGGABORTODOGXCOSPARAMS Convert SG Gabor to 12-param format.
%
% DoG x cos format:
% p = [Ac, As, sigmaC, deltaSigma, tau, theta, x0, y0, f, phi, dx, dy]
%
% For SG Gabor:
% sgFit.phi   = carrier / FFT orientation
% sgFit.theta = envelope rotation relative to carrier
%
% For circular/equal Gabor:
% sgFit.sigma is used for sigmaC
% tau is set to 1

    p = nan(1, 12);

    % Amplitude
    p(1) = sgFit.a;

    % No surround for regular Gabor
    p(2) = 0;

    % Gaussian size and aspect ratio
    if isfield(sgFit, 'sigmax') && isfield(sgFit, 'sigmay') && ...
            isfinite(sgFit.sigmax) && isfinite(sgFit.sigmay)

        p(3) = sgFit.sigmax;
        p(5) = sgFit.sigmay / sgFit.sigmax;

    elseif isfield(sgFit, 'sigma') && isfinite(sgFit.sigma)

        p(3) = sgFit.sigma;
        p(5) = 1;

    else
        warning('No valid sigma / sigmax / sigmay found in sgFit.');
        p(3) = NaN;
        p(5) = NaN;
    end

    % No surround width difference for SG Gabor
    p(4) = 0;

    % Carrier orientation
    if isfield(sgFit, 'phi') && isfinite(sgFit.phi)
        p(6) = sgFit.phi;
    else
        p(6) = NaN;
    end

    % RF center
    p(7) = sgFit.x0;
    p(8) = sgFit.y0;

    % Spatial frequency
    if isfield(sgFit, 'lambda') && isfinite(sgFit.lambda) && ...
            sgFit.lambda > 0

        p(9) = 1 / sgFit.lambda;

    else
        p(9) = 0;
    end

    % Carrier phase
    if isfield(sgFit, 'phase') && isfinite(sgFit.phase)
        p(10) = sgFit.phase;
    else
        p(10) = 0;
    end

    % No center-surround offset for regular Gabor
    p(11) = 0;
    p(12) = 0;
end

% function p = convertSGGaborToDoGXcosParams(sgFit)
% %CONVERTSGGABORTODOGXCOSPARAMS Convert SG Gabor to 12-param format.
% %
% % DoG x cos format:
% % p = [Ac, As, sigmaC, deltaSigma, tau, theta, x0, y0, f, phi, dx, dy]
% %
% % For SG Gabor:
% % sgFit.phi   = carrier / FFT orientation
% % sgFit.theta = envelope rotation relative to carrier
% 
%     p = nan(1, 12);
% 
%     p(1) = sgFit.a;
%     p(2) = 0;
% 
%     p(3) = sgFit.sigmax;
%     p(4) = 0;
%     p(5) = sgFit.sigmay / sgFit.sigmax;
% 
%     % IMPORTANT:
%     % Store carrier / FFT orientation in p(6)
%     p(6) = sgFit.phi;
% 
%     p(7) = sgFit.x0;
%     p(8) = sgFit.y0;
% 
%     if isfield(sgFit, 'lambda') && isfinite(sgFit.lambda) && sgFit.lambda > 0
%         p(9) = 1 / sgFit.lambda;
%     else
%         p(9) = 0;
%     end
% 
%     p(10) = sgFit.phase;
% 
%     p(11) = 0;
%     p(12) = 0;
% end