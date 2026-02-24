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


function [params, modelRF, fitInfo] = fitNonConcentricEllipticalDoG(data, gaussianMode, nStarts)

    if nargin < 2 || isempty(gaussianMode)
        gaussianMode = 'unnormalized';
    end
    
    if nargin < 2 || isempty(nStarts)
        nStarts = 20;
    end

    % Coordinate system
    % Define a centered pixel grid with unit spacing
    [ny, nx] = size(data);
    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);

    XYdata = [X(:) Y(:)];
    datav  = data(:);


    % Model function handle
    fun = @(p, xy) nonConcentricEllipticalDoG(p, xy, gaussianMode);

    % Initial parameter guesses
    % Amplitudes are initialized symmetrically to avoid ON/OFF bias
    amp = max(abs(datav));
    sgn = sign(randn); % need to improve !!!!!
    % sgn = sign(sum(datav));   % data-driven polarity
    % if sgn == 0
    %     sgn = 1;
    % end

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
    bestRSS = Inf;
    bestParams = [];
    bestOutput = [];
    bestExitflag = [];
    
    for s = 1:nStarts
    
        % ---- Generate a randomized initial guess ----
        p0s = p0;
    
        % randomize amplitudes (preserve scale)
        p0s(1:2) = p0(1:2) .* (0.5 + rand(1,2));
    
        % randomize sigmas
        p0s(3) = p0(3) * (0.5 + rand);
        p0s(4) = p0(4) * (0.5 + rand);
    
        % randomize tau
        p0s(5) = 0.5 + 2*rand;
    
        % randomize theta
        p0s(6) = -pi + 2*pi*rand;
    
        % randomize center
        p0s(7) = (rand-0.5) * range(x);
        p0s(8) = (rand-0.5) * range(y);
    
        % randomize surround offset
        p0s(9)  = (rand-0.5) * nx/2;
        p0s(10) = (rand-0.5) * ny/2;
    
        % ---- Fit ----
        try
            [pfit, ~, res, exitflag, output] = ...
                lsqcurvefit(fun, p0s, XYdata, datav, lb, ub, opts);
    
            RSS = sum(res.^2);
    
            % ---- Keep best ----
            if RSS < bestRSS
                bestRSS = RSS;
                bestParams = pfit;
                bestOutput = output;
                bestExitflag = exitflag;
            end
        catch
            % ignore failed starts
        end
    end


    % Evaluate fitted model
    params = bestParams;
    modelRF = reshape(nonConcentricEllipticalDoG(params, XYdata, gaussianMode), ny, nx);
    
    fitInfo.residual = bestRSS;
    fitInfo.exitflag = bestExitflag;
    fitInfo.output   = bestOutput;

end


function y = nonConcentricEllipticalDoG(p, XY, gaussianMode)
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

    % % Elliptical gaussians
    % % Gc = exp(-(Xcp.^2 + (tau*Ycp).^2) / (2*sc^2));
    % % Gs = exp(-(Xsp.^2 + (tau*Ysp).^2) / (2*ss^2));
    % 
    % Gc = (1 ./ sqrt(2*pi*sc.^2)) .* ...
    %  exp(-(Xcp.^2 + (tau*Ycp).^2) / (sc^2));
    % 
    % Gs = (1 ./ sqrt(2*pi*ss.^2)) .* ...
    %  exp(-(Xsp.^2 + (tau*Ysp).^2) / (ss^2));

    switch gaussianMode
        case 'unnormalized'
            Gc = exp(-(Xcp.^2 + (tau*Ycp).^2) / (2*sc^2));
            Gs = exp(-(Xsp.^2 + (tau*Ysp).^2) / (2*ss^2));
    
        case 'normalized'
            Gc = (1 ./ sqrt(2*pi*sc.^2)) .* ...
                 exp(-(Xcp.^2 + (tau*Ycp).^2) / (sc^2));
            Gs = (1 ./ sqrt(2*pi*ss.^2)) .* ...
                 exp(-(Xsp.^2 + (tau*Ysp).^2) / (ss^2));
    
        otherwise
            error('Unknown gaussianMode');
    end

    % Difference of gaussians
    y = Ac .* Gc - As .* Gs;
end
