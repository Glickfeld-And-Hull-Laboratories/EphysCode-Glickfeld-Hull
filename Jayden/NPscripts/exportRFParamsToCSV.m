function T = exportRFParamsToCSV(results, modelRegistry, modelName, outFile)
% exportRFParamsToCSV
%
% Export fitted RF parameters for one model to a CSV table.
%
% Parameters:
%   p = [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]

    modelIdx = find(strcmp({modelRegistry.name}, modelName), 1);
    assert(~isempty(modelIdx), 'Model name not found in modelRegistry.');

    paramsCell = results.params{modelIdx};
    cellIDs = results.cellIDs;

    nCells = numel(paramsCell);
    assert(numel(cellIDs) == nCells, 'cellIDs and params length mismatch');

    P = nan(nCells, 12);

    for k = 1:nCells
        p = paramsCell{k};
        if isnumeric(p) && numel(p) >= 12 && all(isfinite(p(1:12)))
            P(k, :) = p(1:12);
        end
    end

    T = table( ...
        cellIDs(:), ...
        P(:,1), P(:,2), P(:,3), P(:,4), P(:,5), P(:,6), ...
        P(:,7), P(:,8), P(:,9), P(:,10), P(:,11), P(:,12), ...
        'VariableNames', { ...
        'CellID', ...
        'Ac', 'As', 'sigmaC', 'deltaSigma', 'tau', 'theta', ...
        'x0', 'y0', 'f', 'phi', 'dx', 'dy'});

    if nargin >= 4 && ~isempty(outFile)
        writetable(T, outFile);
    end
end