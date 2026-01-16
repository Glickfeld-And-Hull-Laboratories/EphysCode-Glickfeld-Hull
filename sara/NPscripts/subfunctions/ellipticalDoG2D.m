function y = ellipticalDoG2D(p, XY)
% Elliptical, concentric Difference-of-Gaussians

    Ac     = p(1);
    As     = p(2);
    sigmaC = p(3);
    sigmaS = p(4);
    x0     = p(5);
    y0     = p(6);
    tau    = p(7);   % elongation
    theta  = p(8);   % rotation (radians)

    % Shift to RF center
    X = XY(:,1) - x0;
    Y = XY(:,2) - y0;

    % Rotate coordinates
    Xp =  X*cos(theta) + Y*sin(theta);
    Yp = -X*sin(theta) + Y*cos(theta);

    % Elliptical Gaussian exponent
    r2 = Xp.^2 + tau * Yp.^2;

    % Center and surround
    gc = exp(-r2 ./ (2*sigmaC.^2));
    gs = exp(-r2 ./ (2*sigmaS.^2));

    % DoG
    y = Ac * gc - As * gs;
end
