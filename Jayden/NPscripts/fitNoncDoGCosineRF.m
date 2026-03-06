function [params, modelRF, fitInfo] = fitNoncDoGCosineRF(data, gaussianMode, nStarts)

    if nargin < 2 || isempty(gaussianMode)
        gaussianMode = 'unnormalized';
    end

    if nargin < 3 || isempty(nStarts)
        nStarts = 20;
    end

%% Coordinate system
    [ny, nx] = size(data);

    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);

    [X,Y] = meshgrid(x,y);

    XYdata = [X(:) Y(:)];
    datav = data(:);

%% Model handle
    fun = @(p,xy) nonConcentricDoGCosineModel_sigmaXY(p,xy,gaussianMode);

%% Initial guess

    amp = max(abs(datav));

% PARAMETERS
% [Ac As sigmaX sigmaY deltaSigma theta x0 y0 f phi dx dy]

    p0 = [
        amp
        amp/2
        min(nx,ny)/4
        min(nx,ny)/4
        min(nx,ny)/4
        0
        0
        0
        0.1
        0
        0
        0 ];

%% Bounds

    lb = [
        -amp*3
        -amp*3
        eps
        eps
        eps
        -pi
        min(x)
        min(y)
        0
        -pi
        -max(nx,ny)
        -max(nx,ny)];

    ub = [
        amp*3
        amp*3
        max(nx,ny)
        max(nx,ny)
        max(nx,ny)
        pi
        max(x)
        max(y)
        0.5
        pi
        max(nx,ny)
        max(nx,ny)];

%% Optimizer options

    opts = optimoptions('lsqcurvefit', ...
        'Display','off', ...
        'MaxFunctionEvaluations',1e4);

%% ======================================
% Hybrid Global Search
%% ======================================

    bestRSS = Inf;
    candidates = [];

    thetaGrid = linspace(-pi/2,pi/2,12);
    freqGrid = linspace(0.05,0.35,8);

%% Stage 1: grid search

    for th = thetaGrid
        for f = freqGrid

            p0s = p0;

            p0s(6) = th;
            p0s(9) = f;
            p0s(10) = 0;

            try
                [pfit,~,res] = lsqcurvefit(fun,p0s,XYdata,datav,lb,ub,opts);

                RSS = sum(res.^2);

                candidates = [candidates; RSS pfit];

            catch
            end

        end
    end

%% Sort candidates

    candidates = sortrows(candidates,1);

    topK = min(6,size(candidates,1));

    candidates = candidates(1:topK,:);

%% Stage 2: phase refinement

    phaseGrid = linspace(-pi,pi,6);

    for i = 1:topK

        baseParams = candidates(i,2:end);

        for ph = phaseGrid

            p0s = baseParams;

            p0s(10) = ph;

            try

                [pfit,~,res] = lsqcurvefit(fun,p0s,XYdata,datav,lb,ub,opts);

                RSS = sum(res.^2);

                if RSS < bestRSS

                    bestRSS = RSS;
                    bestParams = pfit;

                end

            catch
            end

        end

    end

%% Final refinement

    [pfit,~,res] = lsqcurvefit(fun,bestParams,XYdata,datav,lb,ub,opts);

    bestParams = pfit;

    bestRSS = sum(res.^2);

%% Output

    params = bestParams;

    modelRF = reshape( ...
        nonConcentricDoGCosineModel_sigmaXY(params,XYdata,gaussianMode), ...
        ny,nx);

    fitInfo.RSS = bestRSS;

    fprintf('BestRSS:\n');
    disp(bestRSS)

end


function y = nonConcentricDoGCosineModel_sigmaXY(p,XY,gaussianMode)

% p = [Ac As sigmaX sigmaY deltaSigma theta x0 y0 f phi dx dy]

    Ac = p(1);
    As = p(2);

    sigmaX = p(3);
    sigmaY = p(4);

    delta = p(5);

    sigmaSx = sigmaX + delta;
    sigmaSy = sigmaY + delta;

    theta = p(6);

    x0 = p(7);
    y0 = p(8);

    f = p(9);
    phi = p(10);

    dx = p(11);
    dy = p(12);

%% Coordinates

    Xc = XY(:,1) - x0;
    Yc = XY(:,2) - y0;

    Xs = XY(:,1) - (x0 + dx);
    Ys = XY(:,2) - (y0 + dy);

%% Rotate

    Xcp = cos(theta)*Xc + sin(theta)*Yc;
    Ycp = -sin(theta)*Xc + cos(theta)*Yc;

    Xsp = cos(theta)*Xs + sin(theta)*Ys;
    Ysp = -sin(theta)*Xs + cos(theta)*Ys;

%% Gaussian envelopes

    switch gaussianMode

        case 'unnormalized'

            Gc = exp(-(Xcp.^2/(2*sigmaX^2) + Ycp.^2/(2*sigmaY^2)));

            Gs = exp(-(Xsp.^2/(2*sigmaSx^2) + Ysp.^2/(2*sigmaSy^2)));

        case 'normalized'

            Gc = (1/(2*pi*sigmaX*sigmaY)) .* ...
                exp(-(Xcp.^2/(2*sigmaX^2) + Ycp.^2/(2*sigmaY^2)));

            Gs = (1/(2*pi*sigmaSx*sigmaSy)) .* ...
                exp(-(Xsp.^2/(2*sigmaSx^2) + Ysp.^2/(2*sigmaSy^2)));

    end

%% DoG envelope

    DoG = Ac .* Gc - As .* Gs;

%% Carrier

    carrier = cos(2*pi*f*Xcp + phi);

%% Output

    y = DoG .* carrier;

end