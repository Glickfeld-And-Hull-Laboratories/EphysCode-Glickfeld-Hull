function [params, modelRF, fitInfo] = fitEllipticalDoG2D(data, opts, gaussianMode, nStarts)
% fitEllipticalDoG2D fits an elliptical, concentric Difference-of-Gaussians
% (eDoG) model to a 2D receptive field.
%
% ASSUMPTIONS:
%   1) Center and surround are concentric (shared x0, y0)
%   2) Both are elliptical Gaussians
%   3) Center and surround share orientation (theta) and elongation (tau)
%   4) RF polarity (ON vs OFF) is NOT assumed
%
% Model:
%   f(x,y) = Ac * Gc(x,y) - As * Gs(x,y)
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
%   modelRF - fitted RF (same size as data)
%   fitInfo - optimization diagnostics

% Manual MultiStart elliptical DoG (no Global Optimization Toolbox)

    if nargin < 2 || isempty(opts)
        opts = struct();
    end
    if nargin < 3 || isempty(gaussianMode)
        gaussianMode = 'unnormalized';
    end
    if nargin < 4
        nStarts = 20;
    end

    %% Coordinate system
    [ny, nx] = size(data);
    xCoords = (1:nx) - mean(1:nx);
    yCoords = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(xCoords, yCoords);

    XYdata = [X(:), Y(:)];
    datav  = data(:);

    %% Model handle
    eDogFun = @(p, XY) ellipticalDoG2D(p, XY, gaussianMode);

    %% Bounds
    amp = max(abs(datav));

    lb = [ ...
        -amp*3, -amp*3, ...
        eps, eps, ...
        min(xCoords), min(yCoords), ...
        0.2, ...
        -pi ];

    ub = [ ...
         amp*3,  amp*3, ...
         max(nx,ny), max(nx,ny), ...
         max(xCoords), max(yCoords), ...
         5, ...
         pi ];

    %% Optim options
    fitOpts = optimoptions('lsqcurvefit', ...
        'Display','off', ...
        'MaxFunctionEvaluations',1e4);

    %% MultiStart loop
    bestRSS = Inf;
    bestParams = [];
    bestRes = [];

    for s = 1:nStarts

        % --- randomized, polarity-agnostic initialization ---
        sgn = sign(randn);     % random polarity
        if sgn == 0; sgn = 1; end

        p0 = [ ...
            sgn * amp * (0.5 + rand), ...        % Ac
            sgn * amp * (0.2 + rand), ...        % As
            (min(nx,ny)/6) * (0.5 + rand), ...  % sigmaC
            (min(nx,ny)/3) * (0.5 + rand), ...  % sigmaS
            randn * 1, ...                       % x0
            randn * 1, ...                       % y0
            0.5 + 2*rand, ...                    % tau
            -pi + 2*pi*rand ];                  % theta

        try
            [p, ~, res] = lsqcurvefit( ...
                eDogFun, p0, XYdata, datav, lb, ub, fitOpts);

            RSS = sum(res.^2);

            if RSS < bestRSS
                bestRSS = RSS;
                bestParams = p;
                bestRes = res;
            end
        catch
            % ignore failed starts
        end
    end

    %% Output
    params = bestParams;
    modelRF = reshape( ...
        ellipticalDoG2D(bestParams, XYdata, gaussianMode), ny, nx);

    fitInfo.residual = bestRes;
    fitInfo.RSS = bestRSS;
end


function y = ellipticalDoG2D(p, XY, gaussianMode)
% Elliptical, concentric Difference-of-Gaussians

    Ac     = p(1);
    As     = p(2);
    sigmaC = p(3);
    sigmaS = p(4);
    x0     = p(5);
    y0     = p(6);
    tau    = p(7);   % elongation
    theta  = p(8);   % orientation

    % Shift to RF center
    X = XY(:,1) - x0;
    Y = XY(:,2) - y0;

    % Rotate coordinates
    Xp =  cos(theta)*X + sin(theta)*Y;
    Yp = -sin(theta)*X + cos(theta)*Y;

    % Elliptical radius
    r2 = Xp.^2 + (tau * Yp).^2;

    switch gaussianMode
        case 'unnormalized'   
    % Center and surround
            Gc = exp(-r2 ./ (2*sigmaC.^2));
            Gs = exp(-r2 ./ (2*sigmaS.^2));
    % unnomarlizaed
        case 'normalized'
            Gc = (1 ./ sqrt(2*pi*sigmaC.^2)) .* ...
             exp(-r2 ./ (sigmaC.^2));
        
            Gs = (1 ./ sqrt(2*pi*sigmaS.^2)) .* ...
             exp(-r2 ./ (sigmaS.^2));

    otherwise
            error('Unknown gaussianMode');
    end

    % Difference of Gaussians
    y = Ac .* Gc - As .* Gs;
end
