function [fullRF, centerRF, surroundRF, X, Y] = ...
    build_DoGCos_components(params, gridSize)
% Build full model, center Gabor term, and surround Gabor term.

    if nargin < 2 || isempty(gridSize)
        gridSize = 20;
    end

    Ac = params(1);
    As = params(2);
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

    x = (1:gridSize) - mean(1:gridSize);
    y = (1:gridSize) - mean(1:gridSize);
    [X, Y] = meshgrid(x, y);

    % Center coordinates
    Xc = X - x0;
    Yc = Y - y0;

    Xcp = cos(theta) * Xc + sin(theta) * Yc;
    Ycp = -sin(theta) * Xc + cos(theta) * Yc;

    % Surround coordinates
    Xs = X - (x0 + dx);
    Ys = Y - (y0 + dy);

    Xsp = cos(theta) * Xs + sin(theta) * Ys;
    Ysp = -sin(theta) * Xs + cos(theta) * Ys;

    % Envelopes
    Gc = exp(-(Xcp.^2 + (tau * Ycp).^2) ./ (2 * sigmaC^2));
    Gs = exp(-(Xsp.^2 + (tau * Ysp).^2) ./ (2 * sigmaS^2));

    % Common carrier based on center frame
    carrier = cos(phi) * cos(2 * pi * f * Xcp) - ...
        sin(phi) * sin(2 * pi * f * Xcp);

    centerRF = Ac .* Gc .* carrier;
    surroundRF = As .* Gs .* carrier;

    fullRF = centerRF - surroundRF;
end