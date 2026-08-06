function [params, modelRF, fitInfo] = fitConcentricDifferenceOfGaborsRF( ...
    data, gaussianMode, nStarts)
% fitGaussianPlusGaborRF
%
% Model:
%   RF = circular Gaussian center + elliptical Gabor surround + baseline
%
% Parameter vector:
%   p = [Ac As sigmaC sigmaS tauS thetaS ...
%        xC yC xS yS fS phiS B]

    if nargin < 2 || isempty(gaussianMode)
        gaussianMode = 'unnormalized';
    end

    if nargin < 3 || isempty(nStarts)
        nStarts = 50;
    end

    [ny, nx] = size(data);

    Wpix = buildAutoWeightsFromSTA(data);

    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);

    XYdata = [X(:) Y(:)];
    datav = data(:);
    wvec = Wpix(:);

    amp = max(abs(datav));
    if ~isfinite(amp) || amp == 0
        amp = 1;
    end

    dataMean = mean(datav, 'omitnan');
    baseSigma = max(nx, ny) / 8;

    p0 = [ ...
        amp, ...
        amp / 2, ...
        baseSigma, ...
        baseSigma * 1.5, ...
        1.5, ...
        0, ...
        0, 0, ...
        0, 0, ...
        0.1, ...
        0, ...
        dataMean];

    lb = [ ...
        -amp * 3, ...
        -amp * 3, ...
        0.5, ...
        0.5, ...
        1, ...
        -pi, ...
        -6, -6, ...
        -6, -6, ...
        0, ...
        -pi, ...
        -amp];

    ub = [ ...
        amp * 3, ...
        amp * 3, ...
        12, ...
        12, ...
        5, ...
        pi, ...
        6, 6, ...
        6, 6, ...
        0.35, ...
        pi, ...
        amp];

    opts = optimoptions('lsqnonlin', ...
        'Display', 'off', ...
        'MaxFunctionEvaluations', 2e4, ...
        'MaxIterations', 1e3);

    objfun = @(p) weightedResidualGaussianPlusGabor( ...
        p, XYdata, datav, wvec, gaussianMode);

    bestRSS = Inf;
    bestParams = p0;
    candidates = [];

    nRandomStarts = max(1, round(nStarts));

    startParams = cell(nRandomStarts + 1, 1);
    startParams{1} = p0;

    for s = 1:nRandomStarts
        p0s = p0;

        p0s(1) = amp * (0.5 + 2.0 * rand);
        p0s(2) = amp * (-1.5 + 3.0 * rand);

        p0s(3) = 0.75 + 9.25 * rand;
        p0s(4) = 0.75 + 11.25 * rand;

        p0s(5) = 1 + 3 * rand;
        p0s(6) = -pi + 2 * pi * rand;

        p0s(7) = -3 + 6 * rand;
        p0s(8) = -3 + 6 * rand;
        p0s(9) = -3 + 6 * rand;
        p0s(10) = -3 + 6 * rand;

        p0s(11) = 0.02 + 0.31 * rand;
        p0s(12) = -pi + 2 * pi * rand;

        p0s(13) = dataMean + 0.25 * amp * randn;

        p0s = wrapGaussianPlusGaborParams(p0s);
        p0s = min(max(p0s, lb), ub);

        startParams{s + 1} = p0s;
    end

    for s = 1:numel(startParams)
        p0s = startParams{s};

        try
            [pfit, ~, res] = lsqnonlin(objfun, p0s, lb, ub, opts);
            RSS = sum(res .^ 2);
            candidates = [candidates; RSS pfit]; %#ok<AGROW>

            if RSS < bestRSS
                bestRSS = RSS;
                bestParams = pfit;
            end
        end
    end

    if isempty(candidates)
        [pfit, ~, res] = lsqnonlin(objfun, p0, lb, ub, opts);
        bestParams = pfit;
        bestRSS = sum(res .^ 2);
    else
        candidates = sortrows(candidates, 1);
        topK = min(5, size(candidates, 1));
        candidates = candidates(1:topK, :);

        nJitterPerCandidate = 3;

        for i = 1:topK
            baseParams = candidates(i, 2:end);

            for j = 1:nJitterPerCandidate
                p0s = baseParams;

                p0s(5) = p0s(5) .* exp(0.15 * randn);
                p0s(6) = p0s(6) + 0.35 * randn;

                p0s(7:10) = p0s(7:10) + 0.75 * randn(1, 4);

                p0s(11) = p0s(11) .* exp(0.20 * randn);
                p0s(12) = p0s(12) + 0.75 * randn;

                p0s = wrapGaussianPlusGaborParams(p0s);
                p0s = min(max(p0s, lb), ub);

                try
                    [pfit, ~, res] = lsqnonlin(objfun, p0s, lb, ub, opts);
                    RSS = sum(res .^ 2);

                    if RSS < bestRSS
                        bestRSS = RSS;
                        bestParams = pfit;
                    end
                end
            end
        end

        [pfit, ~, res] = lsqnonlin(objfun, bestParams, lb, ub, opts);
        bestParams = pfit;
        bestRSS = sum(res .^ 2);
    end

    bestParams = wrapGaussianPlusGaborParams(bestParams);

    params = bestParams;

    modelRF = reshape( ...
        gaussianPlusGaborModel(params, XYdata, gaussianMode), ...
        ny, nx);

    modelOriDeg = mod(rad2deg(params(6)), 180);

    fitInfo.RSS = bestRSS;
    fitInfo.Wpix = Wpix;
    fitInfo.modelOriDeg = modelOriDeg;
    fitInfo.predOriDeg = modelOriDeg;
    fitInfo.predOriMethod = 'gabor theta params(6)';
    fitInfo.paramNames = { ...
        'Ac', 'As', 'sigmaC', 'sigmaS', 'tauS', 'thetaS', ...
        'xC', 'yC', 'xS', 'yS', 'fS', 'phiS', 'B'};

    fprintf('Gaussian + Gabor BestRSS:\n');
    disp(bestRSS)
end


function Wpix = buildAutoWeightsFromSTA(data)

    A = abs(data);
    A = imgaussfilt(A, 0.75);
    A = A / (max(A(:)) + eps);

    Wpix = 0.1 + 0.9 * (A .^ 2);
end


function r = weightedResidualGaussianPlusGabor(p, XYdata, datav, ...
    wvec, gaussianMode)

    yhat = gaussianPlusGaborModel(p, XYdata, gaussianMode);
    err = yhat - datav;

    if any(~isfinite(p)) || any(~isfinite(err))
        r = [zeros(size(datav)); 1e3];
        return
    end

    sigmaC = p(3);
    sigmaS = p(4);
    tauS = p(5);
    fS = p(11);

    if sigmaC <= 0 || sigmaS <= 0 || tauS < 1 || fS < 0
        r = [sqrt(wvec) .* err; 1e3];
        return
    end

    nPix = numel(datav);
    scaleReg = sqrt(nPix);

    lambda_sigma = 0.005;
    lambda_tau = 0.005;
    lambda_offset = 0.002;

    xC = p(7);
    yC = p(8);
    xS = p(9);
    yS = p(10);

    offsetMag = sqrt((xS - xC)^2 + (yS - yC)^2);

    rData = sqrt(wvec) .* err;

    penSigma = scaleReg * lambda_sigma * (sigmaC + sigmaS) / 20;
    penTau = scaleReg * lambda_tau * (tauS - 1);
    penOffset = scaleReg * lambda_offset * offsetMag / 10;

    r = [rData;
         penSigma;
         penTau;
         penOffset];
end


function y = gaussianPlusGaborModel(p, XY, gaussianMode)

    Ac = p(1);
    As = p(2);
    sigmaC = p(3);
    sigmaS = p(4);
    tauS = p(5);
    thetaS = p(6);
    xC = p(7);
    yC = p(8);
    xS = p(9);
    yS = p(10);
    fS = p(11);
    phiS = p(12);
    B = p(13);

    Xc = XY(:, 1) - xC;
    Yc = XY(:, 2) - yC;

    switch gaussianMode
        case 'unnormalized'
            center = Ac .* exp(-(Xc .^ 2 + Yc .^ 2) / ...
                (2 * sigmaC ^ 2));

        case 'normalized'
            center = Ac .* (1 / (2 * pi * sigmaC ^ 2)) .* ...
                exp(-(Xc .^ 2 + Yc .^ 2) / ...
                (2 * sigmaC ^ 2));

        otherwise
            error('Unknown gaussianMode: %s', gaussianMode)
    end

    Xs = XY(:, 1) - xS;
    Ys = XY(:, 2) - yS;

    Xp = cos(thetaS) * Xs + sin(thetaS) * Ys;
    Yp = -sin(thetaS) * Xs + cos(thetaS) * Ys;

    switch gaussianMode
        case 'unnormalized'
            Gs = exp(-(Xp .^ 2 + (tauS * Yp) .^ 2) / ...
                (2 * sigmaS ^ 2));

        case 'normalized'
            Gs = (1 / (2 * pi * sigmaS ^ 2)) .* ...
                exp(-(Xp .^ 2 + (tauS * Yp) .^ 2) / ...
                (2 * sigmaS ^ 2));
    end

    carrier = cos(2 * pi * fS * Xp + phiS);
    surround = As .* Gs .* carrier;

    y = center + surround + B;
end


function p = wrapGaussianPlusGaborParams(p)

    angleIdx = [6, 12];
    p(angleIdx) = mod(p(angleIdx) + pi, 2 * pi) - pi;
end