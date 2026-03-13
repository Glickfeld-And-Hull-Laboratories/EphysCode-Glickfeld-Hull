function result = parameter_ablation_DoGcos(STA)

[param_full,~,fitInfo] = fitNoncDoGCosineRF_diff(STA);

RSS_full = fitInfo.RSS;

paramNames = {'Ac','As','sigmaC','deltaSigma','tau','theta',...
              'x0','y0','f','phi','dx','dy'};

nParams = length(paramNames);

result.deltaRSS = zeros(1,nParams);
result.RSS = zeros(1,nParams);

[ny,nx] = size(STA);

x = (1:nx) - mean(1:nx);
y = (1:ny) - mean(1:ny);

[X,Y] = meshgrid(x,y);
XYdata = [X(:) Y(:)];
datav = STA(:);

amp = max(abs(datav));

lb = [-amp*3 -amp*3 eps eps 0.2 -pi min(x) min(y) 0 -pi -nx -ny];
ub = [ amp*3  amp*3 max(nx,ny) max(nx,ny) 5  pi max(x) max(y) 0.5  pi nx ny];

opts = optimoptions('lsqcurvefit','Display','off');

fun = @(p,xy) nonConcentricDoGCosineModel(p,xy,'unnormalized');

for i = 1:nParams

    lb_i = lb;
    ub_i = ub;

    fixedVal = param_full(i);

    switch i
        case 2 % As
            fixedVal = 0;
        case 4 % deltaSigma
            fixedVal = 0;
        case 5 % tau
            fixedVal = 1;
        case 6 % theta
            fixedVal = 0;
        case 9 % frequency
            fixedVal = 0;
        case 10 % phase
            fixedVal = 0;
        case 11 % dx
            fixedVal = 0;
        case 12 % dy
            fixedVal = 0;
    end

    lb_i(i) = fixedVal;
    ub_i(i) = fixedVal;

    [pfit,~,res] = lsqcurvefit(fun,param_full,XYdata,datav,lb_i,ub_i,opts);

    RSS_new = sum(res.^2);

    result.deltaRSS(i) = RSS_new - RSS_full;
    result.RSS(i) = RSS_new;

end

result.paramNames = paramNames;

end