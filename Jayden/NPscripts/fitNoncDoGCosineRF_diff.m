function [params, modelRF, fitInfo] = fitNoncDoGCosineRF_diff(data, gaussianMode, nStarts)

%%
 % Important assumption check, center size is smaller than surrounding
%%
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
    [X, Y] = meshgrid(x, y);

    XYdata = [X(:) Y(:)];
    datav  = data(:);

    %% Model handle
    fun = @(p, xy) nonConcentricDoGCosineModel(p, xy, gaussianMode);

    %% Initial guess
    amp = max(abs(datav));
    % sgn = sign(randn);
    % PARAMETERS:
    % [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]
    p0 = [ ...
        amp, ...                % Ac
        amp/2, ...              % As
        min(nx,ny)/4, ...       % sigmaC
        min(nx,ny)/4, ...       % deltaSigma (sigmaS - sigmaC)
        1, ...                  % tau
        0, ...                  % theta
        0, 0, ...               % x0, y0
        0.1, ...                % f
        0, ...                  % phi
        0, 0 ];                 % dx, dy

    %% Bounds
    % maxShift = max(nx,ny)/4;

    lb = [ ...
        -amp*3, -amp*3, ...
        eps, eps, ...           % sigmaC, deltaSigma > 0
        0.2, ...
        -pi, ...
        min(x), min(y), ...
        0, ...
        -pi, ...
        -max(nx,ny), -max(nx,ny)];

    ub = [ ...
         amp*3, amp*3, ...
         max(nx,ny), max(nx,ny), ...
         5, ...
         pi, ...
         max(x), max(y), ...
         0.5, ...
         pi, ...
         max(nx,ny), max(nx,ny)];

    opts = optimoptions('lsqcurvefit', ...
        'Display','off', ...
        'MaxFunctionEvaluations',1e4);

    %% ======================================
    % Hybrid Global Search
    %% ======================================
    
    bestRSS = Inf;
    candidates = [];
    
    thetaGrid = linspace(-pi/2, pi/2, 12);
    freqGrid  = linspace(0.05, 0.35, 8);
    
    % ---------- Stage 1: 2D grid ----------
    for th = thetaGrid
        for f = freqGrid
            
            p0s = p0;
            p0s(6) = th;
            p0s(9) = f;
            p0s(10) = 0;   % phase neutral
            
            try
                [pfit,~,res] = lsqcurvefit(fun,p0s,XYdata,datav,lb,ub,opts);
                RSS = sum(res.^2);
                
                candidates = [candidates; RSS pfit];
                
            catch
            end
            
        end
    end
    
    % Sort by RSS
    candidates = sortrows(candidates,1);
    
    % Keep best 6
    topK = min(6,size(candidates,1));
    candidates = candidates(1:topK,:);
    
    % ---------- Stage 2: refine phase ----------
    phaseGrid = linspace(-pi, pi, 6);
    
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
    
    % ---------- Final refinement ----------
    [pfit,~,res] = lsqcurvefit(fun,bestParams,XYdata,datav,lb,ub,opts);
    bestParams = pfit;
    bestRSS = sum(res.^2);

    
    % bestExit   = exitflag;
    % bestOut    = output;


    %% Canonical sign convention
    % if bestParams(1) < 0
    %     bestParams(1) = -bestParams(1);
    %     bestParams(2) = -bestParams(2);
    %     bestParams(10) = bestParams(10) + pi;
    % end
    % 
    % bestParams(10) = wrapToPi(bestParams(10));
    % bestParams(6)  = wrapToPi(bestParams(6));


    %% Stability diagnostics
    % paramSTD = std(params_all,0,1);
    % RSS_STD  = std(RSS_all);
    % 
    % fprintf('\n---- DoGCos Stability ----\n');
    % fprintf('Best RSS: %.6f\n', bestRSS);
    % fprintf('RSS STD: %.6f\n', RSS_STD);
    % fprintf('Param STD:\n');
    % disp(paramSTD)

    %% Output
    params  = bestParams;
    modelRF = reshape( ...
        nonConcentricDoGCosineModel(params, XYdata, gaussianMode), ...
        ny, nx);

    fitInfo.RSS      = bestRSS;
    fprintf('BestRSS:\n');
    disp(bestRSS)

    %fitInfo.exitflag = bestExit;
    %fitInfo.output   = bestOut;
end

function y = nonConcentricDoGCosineModel(p, XY, gaussianMode)
% p = [Ac As sigmaC deltaSigma tau theta x0 y0 f phi dx dy]

    Ac    = p(1);
    As    = p(2);
    sc    = p(3);
    delta = p(4);
    ss    = sc + delta;   % <-- enforced sigmaS > sigmaC

    tau   = p(5);
    theta = p(6);
    x0    = p(7);
    y0    = p(8);
    f     = p(9);
    phi   = p(10);
    dx    = p(11);
    dy    = p(12);

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
            Gc = (1/(2*pi*sc^2)) * ...
                 exp(-(Xcp.^2 + (tau*Ycp).^2) / (2*sc^2));
            Gs = (1/(2*pi*ss^2)) * ...
                 exp(-(Xsp.^2 + (tau*Ysp).^2) / (2*ss^2));
    end

    DoG = Ac .* Gc - As .* Gs;
    carrier = cos(2*pi*f*Xcp + phi);

    y = DoG .* carrier;
end

