function [params, modelRF, fitInfo] = fitEllipticalDoG2D(data, opts)
% fitEllipticalDoG2D fits an elliptical Difference-of-Gaussians (eDoG) model
% to a 2D receptive field.
%
% Model:
%   f(x,y) = Ac * exp(-(x'^2 + tau*y'^2) / (2*sigmaC^2))
%          - As * exp(-(x'^2 + tau*y'^2) / (2*sigmaS^2))
%
% where:
%   x' = (x-x0)*cos(theta) + (y-y0)*sin(theta)
%   y' = -(x-x0)*sin(theta) + (y-y0)*cos(theta)
%
% Parameters:
%   p = [Ac As sigmaC sigmaS x0 y0 tau theta]
%
% Inputs:
%   data  - 2D RF (e.g. cropped STA)
%   opts  - optional lsqcurvefit options
%
% Outputs:
%   params  - fitted parameters
%   modelRF - fitted model RF (same size as data)
%   fitInfo - residuals, exitflag, optimizer output

    %% Coordinate system
    [ny, nx] = size(data);
    xCoords = (1:nx) - mean(1:nx);
    yCoords = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(xCoords, yCoords);

    XYdata = [X(:), Y(:)];
    datav  = data(:);

    %% Model handle
    eDogFun = @(p, XY) ellipticalDoG2D(p, XY);

    %% Initial guesses
    maxResp = max(datav);

    p0 = [ ...
        maxResp, ...            % Ac
        maxResp * 0.5, ...      % As
        range(xCoords)/4, ...   % sigmaC
        range(xCoords)/2, ...   % sigmaS
        0, 0, ...               % x0, y0
        1.0, ...                % tau (no elongation)
        0 ];                    % theta (radians)

    %% Bounds
    lb = [ ...
        0, 0, ...               % Ac, As
        eps, eps, ...           % sigmaC, sigmaS
        min(xCoords), min(yCoords), ...
        0.2, ...                % tau (avoid collapse)
        -pi/2 ];                % theta

    ub = [ ...
        maxResp*3, maxResp*3, ...
        max(nx, ny), max(nx, ny), ...
        max(xCoords), max(yCoords), ...
        5, ...                  % tau (elongation)
        pi/2 ];

    %% Optimization options
    if nargin < 2
        opts = struct();
    end
    if ~isfield(opts,'Display')
        opts.Display = 'off';
    end

    fitOpts = optimoptions('lsqcurvefit','Display',opts.Display);

    %% Fit
    [pfit, ~, res, exitflag, output] = ...
        lsqcurvefit(eDogFun, p0, XYdata, datav, lb, ub, fitOpts);

    %% Outputs
    params  = pfit;
    modelRF = reshape(ellipticalDoG2D(pfit, XYdata), size(data));
    fitInfo.residual = res;
    fitInfo.exitflag = exitflag;
    fitInfo.output   = output;
end
