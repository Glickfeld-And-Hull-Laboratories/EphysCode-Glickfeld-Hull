function [params, modelRF, fitInfo] = fitNoncDoGCosineRF_weighted( ...
    data, gaussianMode, nStarts)
% fitNoncDoGCosineRF_weightedAuto
%
% Weighted DoG x cosine fit where the pixel-weight map is built
% automatically from the input cropped STA itself.
%
% This keeps the function signature compatible with modelRegistry:
%   fitFcn = @(STA) fitNoncDoGCosineRF_weightedAuto(STA)

    if nargin < 2 || isempty(gaussianMode)
        gaussianMode = 'unnormalized';
    end
    if nargin < 3 || isempty(nStarts)
        nStarts = 20;
    end

    %#ok<NASGU>
    nStarts = nStarts;

    [ny, nx] = size(data);

    % ---------------------------------------
    % Build pixel weights from raw STA
    % ---------------------------------------
    Wpix = buildAutoWeightsFromSTA(data);

    % ---------------------------------------
    % Coordinate system
    % ---------------------------------------
    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);

    XYdata = [X(:) Y(:)];
    datav = data(:);
    wvec = Wpix(:);

    % ---------------------------------------
    % Initial guess
    % ---------------------------------------
    amp = max(abs(datav));
    if ~isfinite(amp) || amp == 0
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

    % ---------------------------------------
    % Bounds
    % ---------------------------------------
    lb = [ ...
        -amp * 3, 0, ...
        0.5, 0, ...
        0.5, ...
        -pi, ...
        -6, -6, ...
        0, ...
        -pi, ...
        -5, -5];

    ub = [ ...
         amp * 3, amp * 3, ...
         10, 10, ...
         3, ...
         pi, ...
         6, 6, ...
         0.35, ...
         pi, ...
         5, 5];

    opts = optimoptions('lsqnonlin', ...
        'Display', 'off', ...
        'MaxFunctionEvaluations', 1e4);

    objfun = @(p) weightedResidualDoGCos( ...
        p, XYdata, datav, wvec, gaussianMode);

    % ---------------------------------------
    % Hybrid search
    % ---------------------------------------
    bestRSS = Inf;
    bestParams = p0;
    candidates = [];

    thetaGrid = linspace(-pi/2, pi/2, 12);
    freqGrid = linspace(0.05, 0.35, 8);

    % ---------- Stage 1 ----------
    for th = thetaGrid
        for f = freqGrid
            p0s = p0;
            p0s(6) = th;
            p0s(9) = f;
            p0s(10) = 0;

            try
                [pfit, ~, res] = lsqnonlin(objfun, p0s, lb, ub, opts);
                RSS = sum(res .^ 2);
                candidates = [candidates; RSS pfit]; %#ok<AGROW>
            catch
            end
        end
    end

    if isempty(candidates)
        [pfit, ~, res] = lsqnonlin(objfun, p0, lb, ub, opts);
        bestParams = pfit;
        bestRSS = sum(res .^ 2);
    else
        candidates = sortrows(candidates, 1);
        topK = min(6, size(candidates, 1));
        candidates = candidates(1:topK, :);

        % ---------- Stage 2 ----------
        phaseGrid = linspace(-pi, pi, 6);

        for i = 1:topK
            baseParams = candidates(i, 2:end);

            for ph = phaseGrid
                p0s = baseParams;
                p0s(10) = ph;

                try
                    [pfit, ~, res] = lsqnonlin(objfun, p0s, lb, ub, opts);
                    RSS = sum(res .^ 2);

                    if RSS < bestRSS
                        bestRSS = RSS;
                        bestParams = pfit;
                    end
                catch
                end
            end
        end

        % ---------- Final refinement ----------
        [pfit, ~, res] = lsqnonlin(objfun, bestParams, lb, ub, opts);
        bestParams = pfit;
        bestRSS = sum(res .^ 2);
    end

    % ---------------------------------------
    % Output
    % ---------------------------------------
    params = bestParams;
    modelRF = reshape( ...
        nonConcentricDoGCosineModel(params, XYdata, gaussianMode), ...
        ny, nx);

    fitInfo.RSS = bestRSS;
    fitInfo.Wpix = Wpix;

    fprintf('Auto-weighted BestRSS:\n');
    disp(bestRSS)
end


function Wpix = buildAutoWeightsFromSTA(data)
% Build soft weights directly from STA amplitude.

    A = abs(data);

    % optional light smoothing to reduce one-pixel noise influence
    A = imgaussfilt(A, 0.75);

    A = A / (max(A(:)) + eps);

    % soft weighting:
    % weak pixels still matter a little, strong pixels matter more
    Wpix = 0.1 + 0.9 * (A .^ 2);
end

function r = weightedResidualDoGCos(p, XYdata, datav, wvec, gaussianMode)

    yhat = nonConcentricDoGCosineModel(p, XYdata, gaussianMode);
    err = yhat - datav;

    if any(~isfinite(p)) || any(~isfinite(err))
        r = [zeros(size(datav)); 1e3];
        return
    end

    sc = p(3);
    ss = p(3) + p(4);
    tau = p(5);

    if sc <= 0 || ss <= 0 || tau <= 0
        r = [sqrt(wvec) .* err; 1e3];
        return
    end

    Ac = p(1);
    As = p(2);
    dx = p(11);
    dy = p(12);

    nPix = numel(datav);
    scaleReg = sqrt(nPix);

    lambda_As = 0.2;
    lambda_sc = 0.01;
    lambda_off = 0.02;

    r = sqrt(wvec) .* err;

    pen_As = scaleReg * lambda_As * abs(As) / (abs(Ac) + eps);
    pen_sc = scaleReg * lambda_sc / (sc + eps);
    pen_off = scaleReg * lambda_off * sqrt(dx^2 + dy^2);

    % r = [r_data;
    %      pen_As;
    %      pen_sc;
    %      pen_off];
end


function y = nonConcentricDoGCosineModel(p, XY, gaussianMode)
% p = [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]

    Ac = p(1);
    As = p(2);
    sc = p(3);
    delta = p(4);
    ss = sc + delta;

    tau = p(5);
    theta = p(6);

    x0 = p(7);
    y0 = p(8);
    f = p(9);
    phi = p(10);
    dx = p(11);
    dy = p(12);

    Xc = XY(:, 1) - x0;
    Yc = XY(:, 2) - y0;

    Xs = XY(:, 1) - (x0 + dx);
    Ys = XY(:, 2) - (y0 + dy);

    Xcp = cos(theta) * Xc + sin(theta) * Yc;
    Ycp = -sin(theta) * Xc + cos(theta) * Yc;

    Xsp = cos(theta) * Xs + sin(theta) * Ys;
    Ysp = -sin(theta) * Xs + cos(theta) * Ys;

    switch gaussianMode
        case 'unnormalized'
            Gc = exp(-(Xcp.^2 + (tau * Ycp).^2) / (2 * sc^2));
            Gs = exp(-(Xsp.^2 + (tau * Ysp).^2) / (2 * ss^2));
        case 'normalized'
            Gc = (1 / (2 * pi * sc^2)) * ...
                exp(-(Xcp.^2 + (tau * Ycp).^2) / (2 * sc^2));
            Gs = (1 / (2 * pi * ss^2)) * ...
                exp(-(Xsp.^2 + (tau * Ysp).^2) / (2 * ss^2));
        otherwise
            error('Unknown gaussianMode: %s', gaussianMode)
    end

    DoG = Ac .* Gc - As .* Gs;
    carrier = cos(phi) .* cos(2 * pi * f * Xcp) - ...
        sin(phi) .* sin(2 * pi * f * Xcp);

    y = DoG .* carrier;
end