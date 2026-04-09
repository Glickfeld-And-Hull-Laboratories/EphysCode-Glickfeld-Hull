function metrics = computeEffectiveEnvelopeGeometry(params, ...
    ampExp, minWeight)
% Computes visible composite geometry inside the 20x20 window only.
%
% params = [Ac, As, sigmaC, deltaSigma, tau, theta, ...
%           x0, y0, f, phi, dx, dy]
%
% Returns:
%   size_eff
%   elongation_eff
%   sigma_parallel
%   sigma_perp
%   area_eff

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
    dx = params(11);
    dy = params(12);

    sigmaS = sigmaC + deltaSigma;

    if sigmaC <= 0 || sigmaS <= 0 || tau <= 0
        metrics = struct( ...
            'size_eff', NaN, ...
            'elongation_eff', NaN, ...
            'sigma_parallel', NaN, ...
            'sigma_perp', NaN, ...
            'area_eff', NaN, ...
            'W', []);
        return
    end

    % 20x20 image grid
    nx = 20;
    ny = 20;
    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);

    % Relative component weights
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

    % ----- Center ellipse envelope -----
    Xc = X - x0;
    Yc = Y - y0;

    Xc_r =  cos(theta) * Xc + sin(theta) * Yc;
    Yc_r = -sin(theta) * Xc + cos(theta) * Yc;

    Gc = exp(-(Xc_r.^2 + (tau * Yc_r).^2) ./ (2 * sigmaC^2));

    % ----- Surround ellipse envelope -----
    Xs = X - (x0 + dx);
    Ys = Y - (y0 + dy);

    Xs_r =  cos(theta) * Xs + sin(theta) * Ys;
    Ys_r = -sin(theta) * Xs + cos(theta) * Ys;

    Gs = exp(-(Xs_r.^2 + (tau * Ys_r).^2) ./ (2 * sigmaS^2));

    % ----- Composite visible weight map inside 20x20 -----
    % Envelope-only, amplitude weighted
    W = gC * Gc + gS * Gs;

    Wsum = sum(W(:));
    if Wsum == 0
        metrics = struct( ...
            'size_eff', 0, ...
            'elongation_eff', 1, ...
            'sigma_parallel', 0, ...
            'sigma_perp', 0, ...
            'area_eff', 0, ...
            'W', W);
        return
    end

    % Weighted centroid in visible window
    xbar = sum(W(:) .* X(:)) / Wsum;
    ybar = sum(W(:) .* Y(:)) / Wsum;

    Xrel = X - xbar;
    Yrel = Y - ybar;

    % Coordinates in model-aligned frame
    Xpar =  cos(theta) * Xrel + sin(theta) * Yrel;
    Yperp = -sin(theta) * Xrel + cos(theta) * Yrel;

    % Visible spreads
    sigma_parallel = sqrt(sum(W(:) .* Xpar(:).^2) / Wsum);
    sigma_perp = sqrt(sum(W(:) .* Yperp(:).^2) / Wsum);

    elongation_eff = sigma_parallel / sigma_perp;
    if elongation_eff < 1
        elongation_eff = 1 / elongation_eff;
    end

    % Area-like size from visible spreads
    area_eff = pi * sigma_parallel * sigma_perp;
    size_eff = sqrt(sigma_parallel * sigma_perp);

    metrics = struct( ...
        'size_eff', size_eff, ...
        'elongation_eff', elongation_eff, ...
        'sigma_parallel', sigma_parallel, ...
        'sigma_perp', sigma_perp, ...
        'area_eff', area_eff, ...
        'W', W);
end