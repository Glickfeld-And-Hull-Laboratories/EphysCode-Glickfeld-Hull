% fitNonConcentricEllipticalDoG
%
% Fits the non-concentric elliptical Difference-of-Gaussians (DoG) model
% described in De & Horwitz (2021).
%
% In this model:
%   - The center and surround are both elliptical Gaussians
%   - They share the same orientation and aspect ratio
%   - The surround is spatially offset from the center
%
% This offset produces a "crescent-shaped" surround without explicit
% angular gating.
%
% Model:
%   f(x,y) = Ac * Gc(x,y) - As * Gs(x,y)
%
% Reference:
%   De & Horwitz (2021), Model Fitting of the Spatial Weighting Function
%
% INPUT
%   data : 2D receptive field (e.g., STA image)
%
% OUTPUT
%   params  : fitted parameters
%             [Ac As sigmaC sigmaS tau theta ...
%              x0 y0 dx dy]
%   modelRF : fitted RF evaluated on the input grid
%   fitInfo : struct with detailed fit output


function [params, modelRF, fitInfo] = fitNonConcentricEllipticalDoG(data)


    % Coordinate system
    % Define a centered pixel grid with unit spacing
    [ny, nx] = size(data);
    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);

    XYdata = [X(:) Y(:)];
    datav  = data(:);


    % Model function handle
    fun = @(p, xy) nonConcentricEllipticalDoG(p, xy);

    % Initial parameter guesses
    % Amplitudes are initialized symmetrically to avoid ON/OFF bias
    amp = max(abs(datav));
    sgn = sign(randn);

    p0 = [ ...
        sgn * amp, ...          % Ac (center amplitude)
        sgn * amp/2, ...        % As (surround amplitude)
        min(nx,ny)/4, ...       % sigmaC (center size)
        min(nx,ny)/2, ...       % sigmaS (surround size)
        1, ...                  % tau (aspect ratio; 1 = circular)
        0, ...                  % theta (orientation)
        0, 0, ...               % x0, y0 (center location)
        min(nx,ny)/6, 0 ];      % dx, dy (surround offset)


    % Parameter bounds
    lb = [ ...
        -amp*3, -amp*3, ...     % Ac, As
        eps, eps, ...           % sigmaC, sigmaS
        0.2, ...                % tau
        -pi, ...                % theta
        min(x), min(y), ...     % x0, y0
        -max(nx,ny), -max(nx,ny) ]; % dx, dy

    ub = [ ...
         amp*3,  amp*3, ...     % Ac, As
         max(nx,ny), max(nx,ny), ... % sigmaC, sigmaS
         5, ...                 % tau
         pi, ...                % theta
         max(x), max(y), ...    % x0, y0
         max(nx,ny), max(nx,ny) ];   % dx, dy

    % Optimization options
    opts = optimoptions('lsqcurvefit', ...
        'Display', 'off', ...
        'MaxFunctionEvaluations', 1e4);

    % Fit model
    [params, ~, res, exitflag, output] = lsqcurvefit(fun, p0, XYdata, datav, lb, ub, opts);

    % Evaluate fitted model
    modelRF = reshape(nonConcentricEllipticalDoG(params, XYdata), ny, nx);

    fitInfo.residual = res;
    fitInfo.exitflag = exitflag;
    fitInfo.output = output;
end


function y = nonConcentricEllipticalDoG(p, XY)
% Parameters:
%   p = [Ac As sigmaC sigmaS tau theta x0 y0 dx dy]

    Ac    = p(1);   % center amplitude
    As    = p(2);   % surround amplitude
    sc    = p(3);   % center width
    ss    = p(4);   % surround width
    tau   = p(5);   % aspect ratio
    theta = p(6);   % orientation
    x0    = p(7);   % center x-position
    y0    = p(8);   % center y-position
    dx    = p(9);   % surround x-offset
    dy    = p(10);  % surround y-offset

    % Center coordinates
    Xc = XY(:,1) - x0;
    Yc = XY(:,2) - y0;

    % Surround coordinates (shifted relative to center)
    Xs = XY(:,1) - (x0 + dx);
    Ys = XY(:,2) - (y0 + dy);

    % Rotate both center and surround into shared RF frame. Rotation ensures both Gaussians share orientation
    Xcp =  cos(theta)*Xc + sin(theta)*Yc;
    Ycp = -sin(theta)*Xc + cos(theta)*Yc;

    Xsp =  cos(theta)*Xs + sin(theta)*Ys;
    Ysp = -sin(theta)*Xs + cos(theta)*Ys;

    % Elliptical gaussians
    Gc = exp(-(Xcp.^2 + (tau*Ycp).^2) / (2*sc^2));
    Gs = exp(-(Xsp.^2 + (tau*Ysp).^2) / (2*ss^2));

    % Difference of gaussians
    y = Ac .* Gc - As .* Gs;
end
