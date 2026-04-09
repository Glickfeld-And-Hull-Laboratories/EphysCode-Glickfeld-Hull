function [params, modelRF, fitInfo] = fitNoncDoGCosineRF_diff_regularized(data, gaussianMode, nStarts, reg)
% Explicit DoG <-> Gabor continuum model using alpha mixing
%
% MODEL:
%   y = [ Ac*Gc - (1-alpha)*As*Gs ] .* cos( 2*pi*(alpha*f)*Xcp + phi )
%
% PARAMETERS:
%   p = [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy alpha]
%
% Interpretation:
%   alpha = 0  -> DoG-like
%   alpha = 1  -> Gabor-like
%   alpha in (0,1) -> hybrid
%
% Why this helps:
%   The continuum is now explicit in the parameterization.
%   The optimizer no longer has to "discover" the endpoints through two
%   separate parameters drifting toward zero.

    if nargin < 2 || isempty(gaussianMode)
        gaussianMode = 'unnormalized';
    end
    if nargin < 3 || isempty(nStarts)
        nStarts = 20;
    end
    if nargin < 4 || isempty(reg)
        reg.lambda_alpha = 0.01;   % endpoint-seeking penalty
        reg.lambda_phi   = 0.002;  % encourages phi ~ 0 near DoG-like end
        reg.lambda_shift = 0.001;  % weak penalty on dx, dy
        reg.eps0         = 1e-6;
    end

    %% Coordinate system
    [ny, nx] = size(data);
    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);

    XYdata = [X(:) Y(:)];
    datav  = data(:);

    amp = max(abs(datav));
    if amp < eps
        amp = 1;
    end
    spaceScale = max(nx, ny);

    %% Initial guess
    % p = [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy alpha]
    p0 = [ ...
        amp, ...                % Ac
        amp/2, ...              % As
        min(nx,ny)/4, ...       % sigmaC
        min(nx,ny)/4, ...       % deltaSigma
        1, ...                  % tau
        0, ...                  % theta
        0, 0, ...               % x0, y0
        0.15, ...               % f (maximum carrier frequency when alpha=1)
        0, ...                  % phi
        0, 0, ...               % dx, dy
        0.5 ];                  % alpha

    %% Bounds
    lb = [ ...
        -amp*3, -amp*3, ...
        eps, eps, ...
        0.2, ...
        -pi, ...
        min(x), min(y), ...
        0, ...
        -pi, ...
        -max(nx,ny), -max(nx,ny), ...
        0];

    ub = [ ...
         amp*3, amp*3, ...
         max(nx,ny), max(nx,ny), ...
         5, ...
         pi, ...
         max(x), max(y), ...
         0.5, ...
         pi, ...
         max(nx,ny), max(nx,ny), ...
         1];

    opts = optimoptions('lsqnonlin', ...
        'Display','off', ...
        'MaxFunctionEvaluations',1e4, ...
        'MaxIterations',1e3);

    %% Residual handle
    resFun = @(p) alphaMixResidual(p, XYdata, datav, gaussianMode, reg, spaceScale);

    %% ======================================
    % Structured initialization
    %% ======================================
    bestObj = Inf;
    bestRSS = Inf;
    bestParams = p0;
    candidates = [];

    thetaGrid = linspace(-pi/2, pi/2, 10);
    freqGrid  = linspace(0.05, 0.35, 6);
    alphaGrid = [0, 0.15, 0.5, 0.85, 1];

    for th = thetaGrid
        for f = freqGrid
            for a = alphaGrid
                p0s = p0;
                p0s(6)  = th;
                p0s(9)  = f;
                p0s(10) = 0;
                p0s(13) = a;

                try
                    [pfit,~,res] = lsqnonlin(resFun, p0s, lb, ub, opts);
                    objVal = sum(res.^2);

                    dataRes = alphaMixModel(pfit, XYdata, gaussianMode) - datav;
                    RSS = sum(dataRes.^2);

                    candidates = [candidates; objVal RSS pfit];
                catch
                end
            end
        end
    end

    if isempty(candidates)
        error('No successful fits found.');
    end

    candidates = sortrows(candidates,1);
    topK = min(8, size(candidates,1));
    candidates = candidates(1:topK,:);

    %% Phase refinement
    phaseGrid = linspace(-pi, pi, 6);

    for i = 1:topK
        baseParams = candidates(i,3:end);

        for ph = phaseGrid
            p0s = baseParams;
            p0s(10) = ph;

            try
                [pfit,~,res] = lsqnonlin(resFun, p0s, lb, ub, opts);

                objVal = sum(res.^2);
                dataRes = alphaMixModel(pfit, XYdata, gaussianMode) - datav;
                RSS = sum(dataRes.^2);

                if objVal < bestObj
                    bestObj = objVal;
                    bestRSS = RSS;
                    bestParams = pfit;
                end
            catch
            end
        end
    end

    %% Final refinement
    [pfit,~,res] = lsqnonlin(resFun, bestParams, lb, ub, opts);
    bestParams = pfit;
    bestObj = sum(res.^2);

    dataRes = alphaMixModel(bestParams, XYdata, gaussianMode) - datav;
    bestRSS = sum(dataRes.^2);

    %% Output
    params = bestParams;
    modelRF = reshape(alphaMixModel(params, XYdata, gaussianMode), ny, nx);

    Ac    = params(1);
    As    = params(2);
    sc    = params(3);
    ss    = sc + params(4);
    fmax  = params(9);
    phi   = params(10);
    dx    = params(11);
    dy    = params(12);
    alpha = params(13);

    % effective interpretable quantities
    effectiveSurround = (1 - alpha) * abs(As) * ss^2 / (abs(Ac) * sc^2 + eps);
    effectiveCarrier  = alpha * fmax * sc;

    fitInfo.RSS                = bestRSS;
    fitInfo.objective          = bestObj;
    fitInfo.alpha              = alpha;
    fitInfo.effectiveSurround  = effectiveSurround;
    fitInfo.effectiveCarrier   = effectiveCarrier;
    fitInfo.phi                = phi;
    fitInfo.shiftMag           = sqrt(dx^2 + dy^2);
    fitInfo.reg                = reg;

    fprintf('Best data RSS:\n');
    disp(bestRSS)
    fprintf('Best penalized objective:\n');
    disp(bestObj)
    fprintf('alpha (0=DoG-like, 1=Gabor-like): %.4f\n', alpha);
    fprintf('effectiveSurround: %.4f\n', effectiveSurround);
    fprintf('effectiveCarrier : %.4f\n', effectiveCarrier);
end


function r = alphaMixResidual(p, XY, datav, gaussianMode, reg, spaceScale)
% Residual for alpha-mix model

    yhat = alphaMixModel(p, XY, gaussianMode);
    dataRes = yhat - datav;

    phi   = p(10);
    dx    = p(11);
    dy    = p(12);
    alpha = p(13);

    % Endpoint-seeking regularization:
    % alpha*(1-alpha) is 0 at endpoints and maximal at alpha=0.5
    r_alpha = sqrt(reg.lambda_alpha) * sqrt(alpha * (1 - alpha) + reg.eps0);

    % Phase penalty only matters near DoG-like end.
    % When alpha ~ 0, we want phi ~ 0 so the carrier becomes +1 cleanly.
    r_phi = sqrt(reg.lambda_phi) * (1 - alpha) * sin(phi/2);

    % Weak penalty on surround displacement
    shiftTerm = sqrt(dx.^2 + dy.^2) / spaceScale;
    r_shift = sqrt(reg.lambda_shift) * shiftTerm;

    r = [dataRes; r_alpha; r_phi; r_shift];
end


function y = alphaMixModel(p, XY, gaussianMode)
% p = [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy alpha]

    Ac    = p(1);
    As    = p(2);
    sc    = p(3);
    delta = p(4);
    ss    = sc + delta;

    tau   = p(5);
    theta = p(6);

    x0    = p(7);
    y0    = p(8);
    fmax  = p(9);
    phi   = p(10);
    dx    = p(11);
    dy    = p(12);
    alpha = p(13);

    % Effective quantities
    surroundWeight = (1 - alpha) * As;
    freqEff        = alpha * fmax;

    Xc = XY(:,1) - x0;
    Yc = XY(:,2) - y0;

    Xs = XY(:,1) - (x0 + dx);
    Ys = XY(:,2) - (y0 + dy);

    Xcp =  cos(theta)*Xc + sin(theta)*Yc;
    Ycp = -sin(theta)*Xc + cos(theta)*Yc;

    Xsp =  cos(theta)*Xs + sin(theta)*Ys;
    Ysp = -sin(theta)*Xs + cos(theta)*Ys;

    switch gaussianMode
        case 'unnormalized'
            Gc = exp(-(Xcp.^2 + (tau*Ycp).^2) / (2*sc^2));
            Gs = exp(-(Xsp.^2 + (tau*Ysp).^2) / (2*ss^2));

        case 'normalized'
            Gc = (1/(2*pi*sc^2)) .* ...
                 exp(-(Xcp.^2 + (tau*Ycp).^2) / (2*sc^2));
            Gs = (1/(2*pi*ss^2)) .* ...
                 exp(-(Xsp.^2 + (tau*Ysp).^2) / (2*ss^2));

        otherwise
            error('Unknown gaussianMode: %s', gaussianMode);
    end

    env = Ac .* Gc - surroundWeight .* Gs;
    carrier = cos(2*pi*freqEff*Xcp + phi);

    y = env .* carrier;
end