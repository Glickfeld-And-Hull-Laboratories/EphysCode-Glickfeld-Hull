function results = runRFModelComparison( ...
    indLoop, ind_DS, STA_cropped, ...
    modelRegistry, omitCells)

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

    visualizeComparison(STA, results, modelRegistry, k, ic, ii)

end
end