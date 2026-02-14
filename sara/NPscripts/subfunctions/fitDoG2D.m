% fitDoG2D fits a Difference of Gaussians (DoG) model to a 2D RF.
%
%   Reference:
%       De & Horwitz (2021), Model Fitting of the Spatial Weighting Function
%
%   Model:
%       f(x,y) = Ac * Gc(x,y) - As * Gs(x,y)
%
%   Inputs:
%       data  - A 2D matrix of receptive field values (e.g., STA)
%       opts    - (optional) struct for optim options, e.g. opts.Display = 'off'
%
%   Outputs:
%       params   - Best-fit parameters: [Ac As sigmaC sigmaS x0 y0]
%       modelRF  - DoG model evaluated on grid
%       fitInfo  - Struct with detailed fit output


function [params, modelRF, fitInfo] = fitDoG2D(data, opts)

    % Coordinate system
    % Create a centered pixel grid with unit spacing
    [ny, nx] = size(data);
    xCoords = (1:nx) - mean(1:nx); % Centered pixel coordinates (unit spacing)
    yCoords = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(xCoords, yCoords);
    datav = data(:); % Flatten RF data for fitting

    % Model function handle
    dogFun = @(p, XY) dog2D(p, XY);

    % Combine coordinates into [x y] pairs expected by lsqcurvefit
    XYdata = [X(:), Y(:)];

    % Initial parameter guesses
    %y
    % Parameters:
    %   Ac     : center amplitude
    %   As     : surround amplitude
    %   sigmaC : center radius
    %   sigmaS : surround radius
    %   x0,y0  : RF center location
    %
    % Initial values are chosen to reflect typical ON-center RFs. Note: this biases the fit toward ON-center solutions unless bounds are expanded to include negative amplitudes.
    maxResp = max(datav);
    minResp = min(datav);

    p0 = [ ...
        maxResp, ...                % Ac (center amplitude)
        maxResp * 0.5, ...          % As (surround amplitude)
        range(xCoords) / 4, ...     % sigmaC
        range(xCoords) / 2, ...     % sigmaS
        0, 0 ];                     % x0, y0


    % Parameter bounds
    % Amplitudes are constrained to be positive, enforcing an ON-center / OFF-surround configuration.
    lb = [ ...
        0, 0, ...                   % Ac, As
        eps, eps, ...               % sigmaC, sigmaS
        min(xCoords), min(yCoords) ];

    ub = [ ...
        maxResp * 3, maxResp * 3, ... % Ac, As
        max(nx, ny), max(nx, ny), ... % sigmaC, sigmaS
        max(xCoords), max(yCoords) ];

    % Optimization options
    if nargin < 2
        opts = struct();
    end

    if ~isfield(opts, 'Display')
        opts.Display = 'off';
    end
    fitOpts = optimoptions('lsqcurvefit', 'Display', opts.Display);

    % Fit model using nonlinear least squares
    [pfit, ~, res, exitflag, output] = lsqcurvefit(dogFun, p0, XYdata, datav, lb, ub, fitOpts);

    % Prepare outputs
    params = pfit;
    modelRF = reshape(dog2D(pfit, XYdata), size(data));   % Evaluate fitted model on the original grid
    fitInfo.residual = res;
    fitInfo.exitflag = exitflag;
    fitInfo.output = output;
end

function y = dog2D(p, XY) % Evaluates a circular, concentric Difference-of-Gaussians model
% Parameters:
%   p = [Ac As sigmaC sigmaS x0 y0]

    % Parameters
    Ac     = p(1);   % center amplitude
    As     = p(2);   % surround amplitude
    sigmaC = p(3);   % center radius
    sigmaS = p(4);   % surround radius
    x0     = p(5);   % RF center x-position
    y0     = p(6);   % RF center y-position

    % Shift coordinates into RF-centered frame
    X = XY(:,1) - x0;
    Y = XY(:,2) - y0;

    % Center and surround Gaussians
    gc = exp(-(X.^2 + Y.^2) ./ (2*sigmaC.^2));
    gs = exp(-(X.^2 + Y.^2) ./ (2*sigmaS.^2));

    % Difference-of-Gaussians
    y = Ac * gc - As * gs;
end
