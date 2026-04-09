function modelVec = nonConcentricDoGCosineModel(p, XY, mode)
% ============================================================
% Nonconcentric DoG x Cosine RF model
%
% p = [Ac, As, sigmaC, deltaSigma, tau, theta, ...
%      x0, y0, f, phi, dx, dy]
%
% XY = [X(:) Y(:)]
% mode = 'unnormalized' or 'normalized'
% ============================================================

    if nargin < 3 || isempty(mode)
        mode = 'unnormalized';
    end

    Ac = p(1);
    As = p(2);
    sigmaC = p(3);
    deltaSigma = p(4);
    sigmaS = sigmaC + deltaSigma;   % critical fix

    tau = p(5);
    theta = p(6);
    x0 = p(7);
    y0 = p(8);
    f = p(9);
    phi = p(10);
    dx = p(11);
    dy = p(12);

    X = XY(:, 1);
    Y = XY(:, 2);

    % Center coordinates
    Xc = X - x0;
    Yc = Y - y0;

    % Surround coordinates
    Xs = X - (x0 + dx);
    Ys = Y - (y0 + dy);

    % Rotate both
    Xc_r =  cos(theta) * Xc + sin(theta) * Yc;
    Yc_r = -sin(theta) * Xc + cos(theta) * Yc;

    Xs_r =  cos(theta) * Xs + sin(theta) * Ys;
    Ys_r = -sin(theta) * Xs + cos(theta) * Ys;

    switch mode
        case 'unnormalized'
            G_center = exp(-(Xc_r.^2 + (tau * Yc_r).^2) ./ ...
                (2 * sigmaC^2));
            G_surround = exp(-(Xs_r.^2 + (tau * Ys_r).^2) ./ ...
                (2 * sigmaS^2));

        case 'normalized'
            G_center = (1 / (2 * pi * sigmaC^2)) * ...
                exp(-(Xc_r.^2 + (tau * Yc_r).^2) ./ ...
                (2 * sigmaC^2));
            G_surround = (1 / (2 * pi * sigmaS^2)) * ...
                exp(-(Xs_r.^2 + (tau * Ys_r).^2) ./ ...
                (2 * sigmaS^2));

        otherwise
            error('Unknown mode');
    end

    DoG = Ac .* G_center - As .* G_surround;
    carrier = cos(2 * pi * f * Xc_r + phi);

    modelVec = DoG .* carrier;
end