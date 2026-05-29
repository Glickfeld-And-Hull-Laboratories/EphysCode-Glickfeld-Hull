function results = refitCellsNoSurroundAndExportPDF( ...
    staArray, pdfFile, threshSigma, threshShift, gaussianMode, nStarts)
% REFITCELLSNOSURROUNDANDEXPORTPDF
% Fit the full nonconcentric DoG-cosine model to each STA, identify cells
% whose fitted surround is effectively negligible based on thresholds on
% deltaSigma, dx, and dy, refit those cells with a reduced no-surround
% model, and export 3-panel comparison figures to a PDF.
%
% Panels:
%   1) Raw STA
%   2) Full-model fit
%   3) Reduced no-surround fit
%
% INPUTS
%   staArray      : STA data, size [ny, nx, nCells]
%   pdfFile       : output PDF filename, e.g. 'refit_comparison.pdf'
%   threshSigma   : threshold for deltaSigma
%   threshShift   : threshold for abs(dx) and abs(dy)
%   gaussianMode  : e.g. 'unnormalized'
%   nStarts       : kept for compatibility; not heavily used here
%
% OUTPUT
%   results       : struct array with fields:
%       .fullParams
%       .reducedParams
%       .fullRSS
%       .reducedRSS
%       .usedReduced
%       .triggeredThreshold
%       .deltaSigma
%       .dx
%       .dy
%
% NOTES
%   - This code assumes you already have a function:
%       nonConcentricDoGCosineModel(p, xy, gaussianMode)
%     with parameter order:
%       [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]
%
%   - The reduced model here removes the surround by enforcing:
%       As = 0, deltaSigma = 0, dx = 0, dy = 0
%     and refits only:
%       [Ac sigmaC tau theta x0 y0 f phi]
%
%   - This function exports only cells that trigger the threshold rule.
%     If you want all cells exported, that can be changed easily.

    if nargin < 4 || isempty(threshShift)
        threshShift = 0.5;
    end
    if nargin < 3 || isempty(threshSigma)
        threshSigma = 0.5;
    end
    if nargin < 5 || isempty(gaussianMode)
        gaussianMode = 'unnormalized';
    end
    if nargin < 6 || isempty(nStarts)
        nStarts = 20;
    end

    %#ok<NASGU>
    nStarts = nStarts;

    [ny, nx, nCells] = size(staArray);

    if exist(pdfFile, 'file') == 2
        delete(pdfFile);
    end

    results = repmat(struct( ...
        'fullParams', [], ...
        'reducedParams', [], ...
        'fullRSS', NaN, ...
        'reducedRSS', NaN, ...
        'usedReduced', false, ...
        'triggeredThreshold', false, ...
        'deltaSigma', NaN, ...
        'dx', NaN, ...
        'dy', NaN), ...
        nCells, 1);

    for iCell = 1:nCells
        data = staArray(:, :, iCell);

        try
            [fullParams, fullModel, fullFitInfo] = ...
                fitFullModelSingleCell(data, gaussianMode);

            deltaSigmaFit = fullParams(4);
            dxFit = fullParams(11);
            dyFit = fullParams(12);

            triggered = (deltaSigmaFit < threshSigma) && ...
                        (abs(dxFit) < threshShift) && ...
                        (abs(dyFit) < threshShift);

            results(iCell).fullParams = fullParams;
            results(iCell).fullRSS = fullFitInfo.RSS;
            results(iCell).triggeredThreshold = triggered;
            results(iCell).deltaSigma = deltaSigmaFit;
            results(iCell).dx = dxFit;
            results(iCell).dy = dyFit;

            if triggered
                [reducedParams, reducedModel, reducedFitInfo] = ...
                    fitReducedNoSurroundSingleCell(data, gaussianMode, ...
                    fullParams);

                results(iCell).reducedParams = reducedParams;
                results(iCell).reducedRSS = reducedFitInfo.RSS;
                results(iCell).usedReduced = true;

                exportComparisonFigure( ...
                    data, fullModel, reducedModel, ...
                    fullParams, reducedParams, ...
                    fullFitInfo.RSS, reducedFitInfo.RSS, ...
                    iCell, threshSigma, threshShift, pdfFile);
            end

        catch ME
            warning('Cell %d failed: %s', iCell, ME.message);
        end
    end
end


function [params, modelRF, fitInfo] = fitFullModelSingleCell( ...
    data, gaussianMode)
% Fit the full 12-parameter model for one cell.

    [ny, nx] = size(data);

    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);

    XYdata = [X(:), Y(:)];
    datav = data(:);

    fun = @(p, xy) nonConcentricDoGCosineModel(p, xy, gaussianMode);

    amp = max(abs(datav));
    if amp == 0
        amp = 1;
    end

    % [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]
    p0 = [ ...
        amp, ...
        amp / 2, ...
        min(nx, ny) / 4, ...
        min(nx, ny) / 4, ...
        1, ...
        0, ...
        0, 0, ...
        0.1, ...
        0, ...
        0, 0];

    lb = [ ...
        -amp * 3, -amp * 3, ...
        eps, eps, ...
        0.2, ...
        -pi, ...
        min(x), min(y), ...
        0, ...
        -pi, ...
        -max(nx, ny), -max(nx, ny)];

    ub = [ ...
        amp * 3, amp * 3, ...
        max(nx, ny), max(nx, ny), ...
        5, ...
        pi, ...
        max(x), max(y), ...
        0.5, ...
        pi, ...
        max(nx, ny), max(nx, ny)];

    opts = optimoptions( ...
        'lsqcurvefit', ...
        'Display', 'off', ...
        'MaxFunctionEvaluations', 1e4);

    bestRSS = Inf;
    bestParams = [];
    candidates = [];

    thetaGrid = linspace(-pi / 2, pi / 2, 12);
    freqGrid = linspace(0.05, 0.35, 8);

    for th = thetaGrid
        for f = freqGrid
            p0s = p0;
            p0s(6) = th;
            p0s(9) = f;
            p0s(10) = 0;

            try
                [pfit, ~, res] = lsqcurvefit( ...
                    fun, p0s, XYdata, datav, lb, ub, opts);
                rss = sum(res .^ 2);
                candidates = [candidates; rss, pfit]; %#ok<AGROW>
            catch
            end
        end
    end

    if isempty(candidates)
        error('No successful full-model fits.');
    end

    candidates = sortrows(candidates, 1);
    topK = min(6, size(candidates, 1));
    candidates = candidates(1:topK, :);

    phaseGrid = linspace(-pi, pi, 6);

    for i = 1:topK
        baseParams = candidates(i, 2:end);

        for ph = phaseGrid
            p0s = baseParams;
            p0s(10) = ph;

            try
                [pfit, ~, res] = lsqcurvefit( ...
                    fun, p0s, XYdata, datav, lb, ub, opts);
                rss = sum(res .^ 2);

                if rss < bestRSS
                    bestRSS = rss;
                    bestParams = pfit;
                end
            catch
            end
        end
    end

    if isempty(bestParams)
        error('No successful final full-model candidate.');
    end

    [pfit, ~, res] = lsqcurvefit( ...
        fun, bestParams, XYdata, datav, lb, ub, opts);

    bestParams = pfit;
    bestRSS = sum(res .^ 2);

    params = bestParams;
    modelRF = reshape( ...
        nonConcentricDoGCosineModel(params, XYdata, gaussianMode), ...
        ny, nx);

    fitInfo.RSS = bestRSS;
end


function [params, modelRF, fitInfo] = fitReducedNoSurroundSingleCell( ...
    data, gaussianMode, fullParams)
% Refit a reduced model with no surround:
%   As = 0, deltaSigma = 0, dx = 0, dy = 0
% Free parameters:
%   [Ac sigmaC tau theta x0 y0 f phi]

    [ny, nx] = size(data);

    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);

    XYdata = [X(:), Y(:)];
    datav = data(:);

    amp = max(abs(datav));
    if amp == 0
        amp = 1;
    end

    % Start from full fit:
    % full = [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]
    p0 = fullParams([1, 3, 5, 6, 7, 8, 9, 10]);

    % [Ac sigmaC tau theta x0 y0 f phi]
    lb = [ ...
        -amp * 3, ...
        eps, ...
        0.2, ...
        -pi, ...
        min(x), min(y), ...
        0, ...
        -pi];

    ub = [ ...
        amp * 3, ...
        max(nx, ny), ...
        5, ...
        pi, ...
        max(x), max(y), ...
        0.5, ...
        pi];

    opts = optimoptions( ...
        'lsqcurvefit', ...
        'Display', 'off', ...
        'MaxFunctionEvaluations', 1e4);

    fun = @(p, xy) reducedNoSurroundModel(p, xy, gaussianMode);

    [params, ~, res] = lsqcurvefit( ...
        fun, p0, XYdata, datav, lb, ub, opts);

    fitInfo.RSS = sum(res .^ 2);

    modelRF = reshape( ...
        reducedNoSurroundModel(params, XYdata, gaussianMode), ...
        ny, nx);
end


function yhat = reducedNoSurroundModel(p, xy, gaussianMode)
% Reduced model wrapper mapped back into the 12-parameter full model form.
%
% Reduced p:
%   [Ac sigmaC tau theta x0 y0 f phi]
%
% Full p:
%   [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]

    pFull = [ ...
        p(1), ...   % Ac
        0, ...      % As
        p(2), ...   % sigmaC
        0, ...      % deltaSigma
        p(3), ...   % tau
        p(4), ...   % theta
        p(5), ...   % x0
        p(6), ...   % y0
        p(7), ...   % f
        p(8), ...   % phi
        0, ...      % dx
        0];         % dy

    yhat = nonConcentricDoGCosineModel(pFull, xy, gaussianMode);
end


function exportComparisonFigure( ...
    rawSTA, fullModel, reducedModel, ...
    fullParams, reducedParams, fullRSS, reducedRSS, ...
    iCell, threshSigma, threshShift, pdfFile)
% Make and export a 3-panel comparison figure.

    fig = figure('Visible', 'off', 'Color', 'w', ...
        'Position', [100, 100, 1200, 380]);

    clim = max(abs([rawSTA(:); fullModel(:); reducedModel(:)]));
    if clim == 0
        clim = 1;
    end

    tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

    nexttile;
    imagesc(rawSTA);
    axis image off;
    colormap(gca, parula);
    caxis([-clim, clim]);
    colorbar;
    title(sprintf('Raw STA (Cell %d)', iCell), 'Interpreter', 'none');

    nexttile;
    imagesc(fullModel);
    axis image off;
    colormap(gca, parula);
    caxis([-clim, clim]);
    colorbar;
    title({ ...
        'Full model', ...
        sprintf('RSS = %.4g', fullRSS), ...
        sprintf(['As = %.3g, dSigma = %.3g, dx = %.3g, ' ...
                 'dy = %.3g'], ...
                fullParams(2), fullParams(4), ...
                fullParams(11), fullParams(12))}, ...
        'Interpreter', 'none');

    nexttile;
    imagesc(reducedModel);
    axis image off;
    colormap(gca, parula);
    caxis([-clim, clim]);
    colorbar;
    title({ ...
        'Reduced no-surround model', ...
        sprintf('RSS = %.4g', reducedRSS), ...
        sprintf('Ac = %.3g, sigmaC = %.3g, f = %.3g', ...
                reducedParams(1), reducedParams(2), ...
                reducedParams(7))}, ...
        'Interpreter', 'none');

    sgtitle(sprintf([ ...
        'Cell %d | threshold rule triggered: dSigma < %.3g, ' ...
        '|dx| < %.3g, |dy| < %.3g'], ...
        iCell, threshSigma, threshShift, threshShift), ...
        'Interpreter', 'none');

    exportgraphics(fig, pdfFile, ...
        'Append', true, ...
        'ContentType', 'vector');

    close(fig);
end

function y = nonConcentricDoGCosineModel(p, XY, gaussianMode)
% p = [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]

    Ac    = p(1);
    As    = p(2);
    sc    = p(3);
    delta = p(4);
    ss    = sc + delta;   % <-- enforced sigmaS > sigmaC

    tau   = p(5);
    theta = p(6);

    x0    = p(7);
    y0    = p(8);
    f     = p(9);
    phi   = p(10);
    dx    = p(11);
    dy    = p(12);

    Xc = XY(:,1) - x0;
    Yc = XY(:,2) - y0;

    Xs = XY(:,1) - (x0 + dx);
    Ys = XY(:,2) - (y0 + dy);

    Xcp =  cos(theta)*Xc + sin(theta)*Yc;
    Ycp = -sin(theta)*Xc + cos(theta)*Yc;

    Xsp =  cos(theta)*Xs + sin(theta)*Ys;
    Ysp = -sin(theta)*Xs + cos(theta)*Ys;

    switch gaussianMode
        case 'unnormalized'
            Gc = exp(-(Xcp.^2 + (tau*Ycp).^2) / (2*sc^2));
            Gs = exp(-(Xsp.^2 + (tau*Ysp).^2) / (2*ss^2));
        case 'normalized'
            Gc = (1/(2*pi*sc^2)) * ...
                 exp(-(Xcp.^2 + (tau*Ycp).^2) / (2*sc^2));
            Gs = (1/(2*pi*ss^2)) * ...
                 exp(-(Xsp.^2 + (tau*Ysp).^2) / (2*ss^2));
    end

    DoG = Ac .* Gc - As .* Gs;
    carrier = cos(2*pi*f*Xcp + phi);

    y = DoG .* carrier;
end
