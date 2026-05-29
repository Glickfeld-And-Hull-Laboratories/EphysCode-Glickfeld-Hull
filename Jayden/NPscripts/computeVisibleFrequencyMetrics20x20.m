function metrics = computeVisibleFrequencyMetrics20x20(params, ...
    ampExp, minWeight)
% computeVisibleFrequencyMetrics20x20
%
% Frequency-related metrics for the nonconcentric DoG x cosine model,
% evaluated only inside the visible 20x20 window.
%
% params = [Ac, As, sigmaC, deltaSigma, tau, theta, ...
%           x0, y0, f, phi, dx, dy]
%
% Outputs:
%   f                 latent frequency (cycles/pixel)
%   period_pixels     1/f
%   carrier_std       weighted std of carrier inside visible envelope
%   carrier_range     weighted max-min of carrier in visible region
%   cycles_visible    estimated number of cycles across visible RF width
%   osc_score         combined oscillation score
%
% Notes:
%   - carrier_std near 0 means the carrier is almost flat in the
%     visible support, so the RF looks envelope-dominated / DoG-like.
%   - larger carrier_std means the oscillation is actually expressed.

    if nargin < 2 || isempty(ampExp)
        ampExp = 1.0;
    end
    if nargin < 3 || isempty(minWeight)
        minWeight = 0.10;
    end

    Ac = abs(params(1));
    As = abs(params(2));
    sigmaC = params(3);
    deltaSigma = params(4);
    tau = params(5);
    theta = params(6);
    x0 = params(7);
    y0 = params(8);
    f = params(9);
    phi = params(10);
    dx = params(11);
    dy = params(12);

    sigmaS = sigmaC + deltaSigma;

    % Guard
    if sigmaC <= 0 || sigmaS <= 0 || tau <= 0
        metrics = struct( ...
            'f', NaN, ...
            'period_pixels', NaN, ...
            'carrier_std', NaN, ...
            'carrier_range', NaN, ...
            'cycles_visible', NaN, ...
            'osc_score', NaN, ...
            'W', [], ...
            'carrier', []);
        return
    end

    % 20x20 grid
    nx = 20;
    ny = 20;
    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);

    % Relative amplitude weights
    A_sum = Ac + As;
    if A_sum == 0
        wC = 0.5;
        wS = 0.5;
    else
        wC = Ac / A_sum;
        wS = As / A_sum;
    end

    gC = wC ^ ampExp;
    gS = wS ^ ampExp;

    if wC < minWeight
        gC = 0;
    end
    if wS < minWeight
        gS = 0;
    end

    % ----- Center coordinates -----
    Xc = X - x0;
    Yc = Y - y0;

    Xcp = cos(theta) * Xc + sin(theta) * Yc;
    Ycp = -sin(theta) * Xc + cos(theta) * Yc;

    % ----- Surround coordinates -----
    Xs = X - (x0 + dx);
    Ys = Y - (y0 + dy);

    Xsp = cos(theta) * Xs + sin(theta) * Ys;
    Ysp = -sin(theta) * Xs + cos(theta) * Ys;

    % ----- Visible composite envelope weight map -----
    Gc = exp(-(Xcp.^2 + (tau * Ycp).^2) ./ (2 * sigmaC^2));
    Gs = exp(-(Xsp.^2 + (tau * Ysp).^2) ./ (2 * sigmaS^2));

    W = gC * Gc + gS * Gs;
    Wsum = sum(W(:));

    if Wsum == 0
        metrics = struct( ...
            'f', f, ...
            'period_pixels', inf, ...
            'carrier_std', 0, ...
            'carrier_range', 0, ...
            'cycles_visible', 0, ...
            'osc_score', 0, ...
            'W', W, ...
            'carrier', zeros(size(W)));
        return
    end

    % ----- Carrier -----
    carrier = cos(phi) * cos(2 * pi * f * Xcp) - ...
        sin(phi) * sin(2 * pi * f * Xcp);

    % Weighted mean / std of carrier inside visible support
    cbar = sum(W(:) .* carrier(:)) / Wsum;
    cvar = sum(W(:) .* (carrier(:) - cbar).^2) / Wsum;
    carrier_std = sqrt(cvar);

    % Weighted carrier range inside visible support
    mask = W > 0.05 * max(W(:));
    if any(mask(:))
        carrier_vals = carrier(mask);
        carrier_range = max(carrier_vals) - min(carrier_vals);
    else
        carrier_range = 0;
    end

    % Visible RF width along carrier axis
    xbar = sum(W(:) .* X(:)) / Wsum;
    ybar = sum(W(:) .* Y(:)) / Wsum;

    Xrel = X - xbar;
    Yrel = Y - ybar;

    Xpar = cos(theta) * Xrel + sin(theta) * Yrel;
    sigma_parallel = sqrt(sum(W(:) .* Xpar(:).^2) / Wsum);

    % Approx visible width ~ 4 sigma_parallel
    visible_width = 4 * sigma_parallel;
    cycles_visible = f * visible_width;

    % Period
    if abs(f) < eps
        period_pixels = inf;
    else
        period_pixels = 1 / abs(f);
    end

    % Combined oscillation score
    % Higher when:
    %   - carrier varies visibly
    %   - more cycles fit inside visible width
    osc_score = carrier_std * cycles_visible;

    metrics = struct( ...
        'f', f, ...
        'period_pixels', period_pixels, ...
        'carrier_std', carrier_std, ...
        'carrier_range', carrier_range, ...
        'cycles_visible', cycles_visible, ...
        'osc_score', osc_score, ...
        'W', W, ...
        'carrier', carrier);
end