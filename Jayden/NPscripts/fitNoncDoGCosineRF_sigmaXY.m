function [params, modelRF, fitInfo] = fitNoncDoGCosineRF_sigmaXY( ...
    data, gaussianMode, nStarts)
% fitNoncDoGCosineRF_diff
%
% Penalized DoG x cosine fit using lsqnonlin.
%
% Model:
%   y = (Ac * Gc - As * Gs) .* carrier
%
% Parameters:
%   p = [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]
%
% Main soft penalties:
%   1) large deltaSigma is discouraged when As is weak
%   2) large nonconcentric shift is discouraged when center/surround
%      overlap strongly
%   3) nonzero As is discouraged when surround is highly redundant
%
% Inputs:
%   data          2D RF image
%   gaussianMode  'unnormalized' or 'normalized'
%   nStarts       currently unused in the hybrid grid logic, retained
%                 for compatibility
%
% Outputs:
%   params        best-fit parameter vector
%   modelRF       fitted RF image
%   fitInfo       diagnostics

    if nargin < 2 || isempty(gaussianMode)
        gaussianMode = 'unnormalized';
    end
    if nargin < 3 || isempty(nStarts)
        nStarts = 20;
    end

    %#ok<NASGU>
    nStarts = nStarts;

    %% Coordinate system
    [ny, nx] = size(data);
    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);

    XYdata = [X(:) Y(:)];
    datav = data(:);

    %% Initial guess
    amp = max(abs(datav));
    if ~isfinite(amp) || amp == 0
        amp = 1;
    end

    % PARAMETERS:
    % [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]
    p0 = [ ...
        amp, ...                % Ac
        amp / 2, ...            % As
        min(nx, ny) / 4, ...    % sigmaC
        min(nx, ny) / 4, ...    % deltaSigma
        1, ...                  % tau
        0, ...                  % theta
        0, 0, ...               % x0, y0
        0.1, ...                % f
        0, ...                  % phi
        0, 0];                  % dx, dy

    %% Bounds
    lb = [ ...
        -amp * 3, -amp * 3, ...
        eps, eps, ...
        0.2, ...
        -pi, ...
        min(x), min(y), ...
        0, ...
        0, ...
        -max(nx, ny), -max(nx, ny)];

    ub = [ ...
         amp * 3, amp * 3, ...
         max(nx, ny), max(nx, ny), ...
         5, ...
         pi, ...
         max(x), max(y), ...
         0.5, ...
         0, ...
         max(nx, ny), max(nx, ny)];

    %% Penalty settings
    penalty = defaultPenaltySettings();

    %% Optimizer options
    opts = optimoptions('lsqnonlin', ...
        'Display', 'off', ...
        'MaxFunctionEvaluations', 1e4);

    objfun = @(p) penalizedResidualDoGCos( ...
        p, XYdata, datav, gaussianMode, penalty, [ny nx]);

    %% ======================================
    % Hybrid Global Search
    %% ======================================
    bestRSS = Inf;
    bestParams = p0;
    candidates = [];

    thetaGrid = linspace(-pi/2, pi/2, 12);
    freqGrid = linspace(0.05, 0.35, 8);

    % ---------- Stage 1: 2D grid ----------
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
        % fall back to one direct run
        [pfit, ~, res] = lsqnonlin(objfun, p0, lb, ub, opts);
        bestParams = pfit;
        bestRSS = sum(res .^ 2);
    else
        candidates = sortrows(candidates, 1);
        topK = min(6, size(candidates, 1));
        candidates = candidates(1:topK, :);

        % ---------- Stage 2: refine phase ----------
        phaseGrid = linspace(0, 0, 1);

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

    %% Output
    params = bestParams;
    modelRF = reshape( ...
        nonConcentricDoGCosineModel(params, XYdata, gaussianMode), ...
        ny, nx);

    fitInfo.RSS = bestRSS;
    fitInfo.penalty = penalty;
    fitInfo.overlap = estimateEnvelopeOverlap(params, gaussianMode, [ny nx]);
    fitInfo.redundancy = computeRedundancyFactor(params, gaussianMode, ...
        penalty, [ny nx]);

    fprintf('BestRSS:\n');
    disp(bestRSS)
end


function r = penalizedResidualDoGCos( ...
    p, XYdata, datav, gaussianMode, penalty, imSize)
% penalizedResidualDoGCos
%
% Returns residual vector for lsqnonlin:
%   [data residuals; penalty residuals]

    yhat = nonConcentricDoGCosineModel(p, XYdata, gaussianMode);
    r_data = yhat - datav;

    if any(~isfinite(p)) || any(~isfinite(r_data))
        r = [zeros(size(datav)); 1e3];
        return
    end

    % unpack
    Ac = p(1);
    As = p(2);
    sc = p(3);
    delta = p(4);
    ss = sc + delta;
    tau = p(5);
    dx = p(11);
    dy = p(12);

    if sc <= 0 || ss <= 0 || tau <= 0
        r = [r_data; 1e3];
        return
    end

    shiftMag = sqrt(dx ^ 2 + dy ^ 2);

    % relative surround strength
    Aref = abs(Ac) + abs(As) + eps;
    As_rel = abs(As) / Aref;

    % effective scale
    sizeC = sc / sqrt(tau);

    % overlap / redundancy
    overlap = estimateEnvelopeOverlap(p, gaussianMode, imSize);
    redundancy = computeRedundancyFactor(p, gaussianMode, penalty, imSize);

    % 1) Penalize deltaSigma when surround is weak
    weakSurroundWeight = max(0, 1 - As_rel / penalty.AsRelAllowDelta);
    pen_delta_weakAs = penalty.lamDeltaWeakAs * weakSurroundWeight * ...
        (delta / (sc + eps));

    % 2) Penalize shift when overlap is high
    pen_shift_overlap = penalty.lamShiftOverlap * overlap * ...
        (shiftMag / (sizeC + eps));

    % 3) Penalize As when surround looks redundant
    pen_As_redundant = penalty.lamAsRedundant * redundancy * As_rel;

    % 4) Mild shrinkage on tau away from 1
    pen_tau = penalty.lamTau * abs(log(tau));

    r = [
        r_data;
        pen_delta_weakAs;
        pen_shift_overlap;
        pen_As_redundant;
        pen_tau
    ];
end


function penalty = defaultPenaltySettings()
% defaultPenaltySettings
%
% Tuning knobs for soft structural penalties.

    penalty = struct();

    % When As_rel is below this, large deltaSigma becomes increasingly
    % discouraged.
    penalty.AsRelAllowDelta = 0.25;

    % Strengths of penalty residuals
    penalty.lamDeltaWeakAs = 1.0;
    penalty.lamShiftOverlap = 1.0;
    penalty.lamAsRedundant = 1.5;
    penalty.lamTau = 0.2;

    % Redundancy logic
    % Larger -> more forgiving
    penalty.deltaSimilarityScale = 0.35;
    penalty.shiftSimilarityScale = 0.35;
end


function redundancy = computeRedundancyFactor(p, gaussianMode, ...
    penalty, imSize)
% computeRedundancyFactor
%
% High when center/surround are highly overlapping, similarly sized,
% and only weakly shifted.

    sc = p(3);
    delta = p(4);
    tau = p(5);
    dx = p(11);
    dy = p(12);

    %#ok<NASGU>
    tau = tau;

    sizeC = sc / sqrt(max(p(5), eps));
    shiftMag = sqrt(dx ^ 2 + dy ^ 2);
    overlap = estimateEnvelopeOverlap(p, gaussianMode, imSize);

    deltaNorm = delta / (sc + eps);
    shiftNorm = shiftMag / (sizeC + eps);

    similarSize = exp(-(deltaNorm ^ 2) / penalty.deltaSimilarityScale);
    smallShift = exp(-(shiftNorm ^ 2) / penalty.shiftSimilarityScale);

    redundancy = overlap * similarSize * smallShift;
end


function overlap = estimateEnvelopeOverlap(p, gaussianMode, imSize)
% estimateEnvelopeOverlap
%
% Computes normalized overlap of center and surround envelopes.
% Near 1 = very similar / highly overlapping.
% Lower values = more distinct.

    sc = p(3);
    delta = p(4);
    ss = sc + delta;
    tau = p(5);
    theta = p(6);
    x0 = p(7);
    y0 = p(8);
    dx = p(11);
    dy = p(12);

    ny = imSize(1);
    nx = imSize(2);

    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);

    Xc = X - x0;
    Yc = Y - y0;

    Xs = X - (x0 + dx);
    Ys = Y - (y0 + dy);

    Xcp = cos(theta) * Xc + sin(theta) * Yc;
    Ycp = -sin(theta) * Xc + cos(theta) * Yc;

    Xsp = cos(theta) * Xs + sin(theta) * Ys;
    Ysp = -sin(theta) * Xs + cos(theta) * Ys;

    switch gaussianMode
        case 'unnormalized'
            Gc = exp(-(Xcp .^ 2 + (tau * Ycp) .^ 2) / (2 * sc ^ 2));
            Gs = exp(-(Xsp .^ 2 + (tau * Ysp) .^ 2) / (2 * ss ^ 2));
        case 'normalized'
            Gc = (1 / (2 * pi * sc ^ 2)) * ...
                exp(-(Xcp .^ 2 + (tau * Ycp) .^ 2) / (2 * sc ^ 2));
            Gs = (1 / (2 * pi * ss ^ 2)) * ...
                exp(-(Xsp .^ 2 + (tau * Ysp) .^ 2) / (2 * ss ^ 2));
        otherwise
            error('Unknown gaussianMode: %s', gaussianMode)
    end

    num = sum(Gc(:) .* Gs(:));
    den = sqrt(sum(Gc(:) .^ 2) * sum(Gs(:) .^ 2)) + eps;

    overlap = num / den;
end


function y = nonConcentricDoGCosineModel(p, XY, gaussianMode)
% nonConcentricDoGCosineModel
%
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
            Gc = exp(-(Xcp .^ 2 + (tau * Ycp) .^ 2) / (2 * sc ^ 2));
            Gs = exp(-(Xsp .^ 2 + (tau * Ysp) .^ 2) / (2 * ss ^ 2));
        case 'normalized'
            Gc = (1 / (2 * pi * sc ^ 2)) * ...
                 exp(-(Xcp .^ 2 + (tau * Ycp) .^ 2) / (2 * sc ^ 2));
            Gs = (1 / (2 * pi * ss ^ 2)) * ...
                 exp(-(Xsp .^ 2 + (tau * Ysp) .^ 2) / (2 * ss ^ 2));
        otherwise
            error('Unknown gaussianMode: %s', gaussianMode)
    end

    DoG = Ac .* Gc - As .* Gs;
    carrier = cos(phi) .* cos(2 * pi * f * Xcp) - ...
        sin(phi) .* sin(2 * pi * f * Xcp);

    y = DoG .* carrier;
end