function [params, modelRF, fitInfo, allFits] = fitEllipGabor_fit_full(data)
% FITELLIPGABOR_FIT_FULL
% Fourier-informed, multi-start elliptical Gabor fitting using fit()
%
% Output:
%   params   - best-fit parameter struct
%   modelRF  - reconstructed RF
%   fitInfo  - RSS, R2, GOF
%   allFits  - all attempted fits (struct array)

    nStarts = 40;

    %% Coordinate system
    [ny,nx] = size(data);
    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X,Y] = meshgrid(x,y);

    XY = [X(:), Y(:)];
    Z  = data(:);

    %% Image statistics
    stats.nx   = nx;
    stats.ny   = ny;
    stats.mean = mean(Z);
    stats.var  = var(Z);

    %% Fourier-domain prefit (orientation / lambda / sigma)
    pf = estimateFourierSP(data);

    %% Base starting point
    base = struct( ...
        'A',      max(abs(Z)), ...
        'sigma',  pf.sigma, ...
        'tau',    1, ...
        'theta',  pf.theta, ...
        'x0',     0, ...
        'y0',     0, ...
        'lambda', pf.lambda, ...
        'phase',  0, ...
        'b',      stats.mean );

    %% Generate start points (logic like fit2dGabor)
    SP = makeStartPoints(base, pf, stats, nStarts);

    %% Define Gabor model
    gaborFt = fittype( ...
        @(A,sigma,tau,theta,x0,y0,lambda,phase,b,x1,x2) ...
            ellipGaborFun(A,sigma,tau,theta,x0,y0,lambda,phase,b,x1,x2), ...
        'independent', {'x1','x2'}, ...
        'coefficients', {'A','sigma','tau','theta','x0','y0','lambda','phase','b'} );


    opts = fitoptions(gaborFt);
    opts.Display = 'off';
    opts.MaxIter = 1e4;
    opts.MaxFunEvals = 1e4;

    %% Bounds
    amp = base.A;
    opts.Lower = [-3*amp, eps, 0.2, -pi, min(x), min(y), 2, -pi, -2*amp];
    opts.Upper = [ 3*amp, max(nx,ny), 5,  pi, max(x), max(y), max(nx,ny), pi,  2*amp];

    %% Multi-start fitting loop
    bestRSS = Inf;
    allFits = [];

    for i = 1:numel(SP)

        sp = struct2array(SP(i));
        opts.StartPoint = sp;

        try
            [fitobj, gof] = fit(XY, Z, gaborFt, opts);

            RSS = gof.sse;

            allFits(end+1).fit  = fitobj; %#ok<AGROW>
            allFits(end).RSS    = RSS;
            allFits(end).R2     = 1 - RSS / sum((Z-mean(Z)).^2);

            if RSS < bestRSS
                bestRSS = RSS;
                bestFit = fitobj;
                bestGOF = gof;
            end
        catch
        end
    end

    %% Postprocess parameters
    params = postprocessEllip(bestFit);

    %% Reconstruct RF
    modelRF = reshape(feval(bestFit,X(:),Y(:)), ny, nx);

    %% Fit info
    fitInfo.RSS = bestRSS;
    fitInfo.R2  = 1 - bestRSS / sum((Z-mean(Z)).^2);
    fitInfo.gof = bestGOF;

end

function z = ellipGaborFun(A,sigma,tau,theta,x0,y0,lambda,phase,b,x,y)

    X = x - x0;
    Y = y - y0;

    Xp =  cos(theta)*X + sin(theta)*Y;
    Yp = -sin(theta)*X + cos(theta)*Y;

    env = exp(-(Xp.^2 + (tau*Yp).^2) / (2*sigma^2));
    car = cos(2*pi*Xp/lambda + phase);

    z = A .* env .* car + b;
end

function pf = estimateFourierSP(data)

    Z = log(abs(fftshift(fft2(data))) + 1);

    [ny,nx] = size(Z);
    [X,Y] = meshgrid(linspace(-0.5,0.5,nx), linspace(-0.5,0.5,ny));

    % suppress DC
    R = sqrt(X.^2 + Y.^2);
    Z(R < 0.05) = 0;

    ang = atan2(Y(:), X(:));
    w   = Z(:).^2;

    theta = 0.5 * atan2(sum(w .* sin(2*ang)), sum(w .* cos(2*ang)));

    [~,idx] = max(Z(:));
    sf = hypot(X(idx), Y(idx));
    sf = max(sf, 0.02);

    lambda = 1 / sf;
    sigma  = min(nx,ny) / 6;

    pf.theta  = theta;
    pf.lambda = lambda;
    pf.sigma  = sigma;
end

function SP = makeStartPoints(base, pf, stats, nStarts)

    % Initialize as struct array
    SP = repmat(base, 0, 1);

    % ---- deterministic combinations ----

    % 1. Base
    SP(end+1) = base;

    % 2. Fourier-informed (theta + lambda + sigma)
    tmp = base;
    tmp.theta  = pf.theta;
    tmp.lambda = pf.lambda;
    tmp.sigma  = pf.sigma;
    SP(end+1) = tmp;

    % 3. Only theta from Fourier
    tmp = base;
    tmp.theta = pf.theta;
    SP(end+1) = tmp;

    % 4. Only lambda from Fourier
    tmp = base;
    tmp.lambda = pf.lambda;
    SP(end+1) = tmp;

    % ---- randomized exploration ----
    while numel(SP) < nStarts

        p = base;

        p.A      = base.A * (0.5 + rand);
        p.sigma  = pf.sigma * (0.5 + rand);
        p.tau    = 0.5 + 2*rand;
        p.theta  = pf.theta + randn*pi/6;
        p.x0     = (rand-0.5) * stats.nx;
        p.y0     = (rand-0.5) * stats.ny;
        p.lambda = pf.lambda * (0.5 + rand);
        p.phase  = -pi + 2*pi*rand;
        p.b      = 0.1 * base.A * randn;

        SP(end+1) = p; %#ok<AGROW>
    end
end


function p = postprocessEllip(fitobj)

    p = struct( ...
        'A',      fitobj.A, ...
        'sigma',  fitobj.sigma, ...
        'tau',    fitobj.tau, ...
        'theta',  wrapToPi(fitobj.theta), ...
        'x0',     fitobj.x0, ...
        'y0',     fitobj.y0, ...
        'lambda', fitobj.lambda, ...
        'phase',  wrapToPi(fitobj.phase), ...
        'b',      fitobj.b );

    % enforce orientation symmetry
    if p.theta > pi/2
        p.theta = p.theta - pi;
        p.phase = -p.phase;
    elseif p.theta < -pi/2
        p.theta = p.theta + pi;
        p.phase = -p.phase;
    end
end
