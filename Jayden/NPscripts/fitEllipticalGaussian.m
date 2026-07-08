function [params, modelRF, fitInfo] = fitEllipticalGaussian(data, gaussianMode, nStarts)

    if nargin < 2 || isempty(gaussianMode)
        gaussianMode = 'unnormalized';
    end
    
    if nargin < 3 || isempty(nStarts)
        nStarts = 20;
    end

    % Coordinate system
    [ny, nx] = size(data);
    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);

    XYdata = [X(:) Y(:)];
    datav  = data(:);

    % Model function handle
    fun = @(p, xy) ellipticalGaussian(p, xy, gaussianMode);

    % Initial guess
    amp = max(abs(datav));
    sgn = sign(sum(datav));
    if sgn == 0
        sgn = 1;
    end

    p0 = [ ...
        sgn * amp, ...          % A amplitude
        min(nx,ny)/4, ...       % sigma
        1, ...                  % tau aspect ratio
        0, ...                  % theta orientation
        0, 0, ...               % x0, y0
        median(datav) ];        % baseline

    % Bounds
    lb = [ ...
        -amp*3, ...             % A
        eps, ...                % sigma
        0.2, ...                % tau
        -pi, ...                % theta
        min(x), min(y), ...     % x0, y0
        min(datav) - amp ];     % baseline

    ub = [ ...
         amp*3, ...             % A
         max(nx,ny), ...        % sigma
         5, ...                 % tau
         pi, ...                % theta
         max(x), max(y), ...    % x0, y0
         max(datav) + amp ];    % baseline

    % Optimization options
    opts = optimoptions('lsqcurvefit', ...
        'Display', 'off', ...
        'MaxFunctionEvaluations', 1e4);

    % Multi-start fit
    bestRSS = Inf;
    bestParams = [];
    bestOutput = [];
    bestExitflag = [];

    for s = 1:nStarts

        p0s = p0;

        % Randomize amplitude
        p0s(1) = p0(1) * (0.5 + rand);

        % Randomize sigma
        p0s(2) = p0(2) * (0.5 + rand);

        % Randomize tau
        p0s(3) = 0.5 + 2*rand;

        % Randomize theta
        p0s(4) = -pi + 2*pi*rand;

        % Randomize center
        p0s(5) = (rand-0.5) * range(x);
        p0s(6) = (rand-0.5) * range(y);

        % Randomize baseline slightly
        p0s(7) = median(datav) + 0.2 * amp * randn;

        try
            [pfit, ~, res, exitflag, output] = ...
                lsqcurvefit(fun, p0s, XYdata, datav, lb, ub, opts);

            RSS = sum(res.^2);

            if RSS < bestRSS
                bestRSS = RSS;
                bestParams = pfit;
                bestOutput = output;
                bestExitflag = exitflag;
            end
        catch
            % Ignore failed starts
        end
    end

    % Evaluate fitted model
    params = bestParams;
    modelRF = reshape(ellipticalGaussian(params, XYdata, gaussianMode), ny, nx);

    fitInfo.residual = bestRSS;
    fitInfo.exitflag = bestExitflag;
    fitInfo.output   = bestOutput;

end


function y = ellipticalGaussian(p, XY, gaussianMode)
% Parameters:
%   p = [A sigma tau theta x0 y0 baseline]

    A        = p(1);   % amplitude
    sigma    = p(2);   % Gaussian width
    tau      = p(3);   % aspect ratio
    theta    = p(4);   % orientation
    x0       = p(5);   % x-position
    y0       = p(6);   % y-position
    baseline = p(7);   % baseline offset

    % Center coordinates
    Xc = XY(:,1) - x0;
    Yc = XY(:,2) - y0;

    % Rotate into RF frame
    Xp =  cos(theta)*Xc + sin(theta)*Yc;
    Yp = -sin(theta)*Xc + cos(theta)*Yc;

    switch gaussianMode
        case 'unnormalized'
            G = exp(-(Xp.^2 + (tau*Yp).^2) / (2*sigma^2));

        case 'normalized'
            G = (1 ./ sqrt(2*pi*sigma.^2)) .* ...
                exp(-(Xp.^2 + (tau*Yp).^2) / (sigma^2));

        otherwise
            error('Unknown gaussianMode');
    end

    y = baseline + A .* G;

end