function stats = scatter_reg_circ(x,y,sz,c,varargin)
% SCATTER_REG_CIRC Scatter + regression/correlation for circular variables
%
%   scatter_reg_circ(x,y,sz,c,'XPeriod',P,'YPeriod',P, ...) plots a scatter
%   of x vs y with a fit and correlation that respect periodic axes
%   (e.g. preferred orientation with period 180 deg).
%
%   Cases (chosen by which periods are given)
%   -----------------------------------------
%   XPeriod only  (circular x, linear y): first-harmonic regression
%       y = a + b*cos(th) + c*sin(th),  th = 2*pi*x/XPeriod.
%       Stat: r = sqrt(R^2); p from the regression F-test (2, n-3 df).
%
%   YPeriod only  (linear x, circular y): circular-linear fit
%       y_hat = y0 + k*(x-xmin)/range(x)*YPeriod (mod YPeriod), with the
%       "phase slope" k (cycles across the x range) found by maximising the
%       mean resultant length R (Kempter et al., 2012). Stat: R; p by
%       permutation.
%
%   Both periods  (circular-circular): Jammalamadaka & SenGupta circular
%       correlation (rho, -1..1). Fit is a wrapped line of slope sign(rho),
%       offset = circular mean of (y - slope*x). p by permutation.
%
%   Neither period: ordinary linear regression / Pearson (same as scatter_reg).
%
%   Inputs
%   ------
%   x, y : vectors (same length)
%   sz   : marker size(s), [] for default
%   c    : color values, [] for none
%
%   Name-value options
%   ------------------
%   'XPeriod'   : period of x (default [] = linear)
%   'YPeriod'   : period of y (default [] = linear)
%   'CPeriod'   : period of c; uses cyclic colormap (hsv) over [0 CPeriod]
%                 (default [] = turbo, ordinary scaling)
%   'MaxWraps'  : max cycles of y across x range for the YPeriod-only fit
%                 (default 1)
%   'NPerm'     : number of permutations for p-values (default 5000)
%
%   Output
%   ------
%   stats : struct with fields r, p, case, and fit parameters
%
%   Example
%   -------
%   scatter_reg_circ(valSize, prefOri_all(valSizeID), [], [], 'YPeriod',180)
%   scatter_reg_circ(prefOri1, prefOri2, [], [], 'XPeriod',180,'YPeriod',180)
%   scatter_reg_circ(valSize, amp, [], prefOri, 'CPeriod',180)

% ---- parse inputs ----
if nargin < 3, sz = []; end
if nargin < 4, c = []; end
ip = inputParser;
addParameter(ip,'XPeriod',[]);
addParameter(ip,'YPeriod',[]);
addParameter(ip,'CPeriod',[]);
addParameter(ip,'MaxWraps',1);
addParameter(ip,'NPerm',5000);
parse(ip,varargin{:});
Px = ip.Results.XPeriod;  Py = ip.Results.YPeriod;  Pc = ip.Results.CPeriod;
maxWraps = ip.Results.MaxWraps;  nPerm = ip.Results.NPerm;

x = x(:); y = y(:);
useColor = ~isempty(c);
if useColor, c = c(:); end

% ---- remove NaNs ----
valid = ~isnan(x) & ~isnan(y);
if useColor, valid = valid & ~isnan(c); end
x = x(valid); y = y(valid);
if useColor, c = c(valid); end
n = numel(x);

if isempty(sz), sz = 36; end

% ---- scatter ----
if useColor
    scatter(x,y,sz,c,'filled','LineWidth',0.2,'MarkerEdgeColor','w')
    colorbar
    if ~isempty(Pc)
        colormap(gca,hsv); clim([0 Pc])
    else
        colormap(gca,turbo)
    end
else
    scatter(x,y,sz,'filled','LineWidth',0.2,'MarkerEdgeColor','w')
end
set(gca,'TickDir','out')
axis square
hold on

stats = struct('r',NaN,'p',NaN,'case','');
if n < 4 || numel(unique(x)) < 2
    title('insufficient data'); return
end

xf = linspace(min(x),max(x),360)';

% ======================================================================
if isempty(Px) && isempty(Py)
    % ---- linear / linear ----
    stats.case = 'linear';
    pf = polyfit(x,y,1);
    plot(xf,polyval(pf,xf),'k','LineWidth',1)
    [stats.r,stats.p] = corr(x,y,'rows','complete');
    stats.coef = pf;

elseif ~isempty(Px) && isempty(Py)
    % ---- circular x, linear y: harmonic regression ----
    stats.case = 'circular x, linear y';
    th = 2*pi*x/Px;
    X = [ones(n,1) cos(th) sin(th)];
    b = X\y;
    res = y - X*b;
    R2 = 1 - sum(res.^2)/sum((y-mean(y)).^2);
    Fstat = (R2/2)/((1-R2)/(n-3));
    stats.r = sqrt(max(R2,0));
    stats.p = 1 - fcdf(Fstat,2,n-3);
    stats.coef = b;
    thf = 2*pi*xf/Px;
    plot(xf,b(1)+b(2)*cos(thf)+b(3)*sin(thf),'k','LineWidth',1)

elseif isempty(Px) && ~isempty(Py)
    % ---- linear x, circular y: circular-linear (phase-slope) fit ----
    stats.case = 'linear x, circular y';
    xr = range(x);
    xn = (x - min(x))/xr;
    ty = 2*pi*y/Py;
    kgrid = linspace(-maxWraps,maxWraps,2001);
    [R,k,y0] = best_phase_slope(xn,ty,kgrid);
    stats.r = R; stats.k = k; stats.offset = y0*Py/(2*pi);
    stats.p = perm_p(@(yy) best_phase_slope(xn,yy,kgrid),ty,R,nPerm);
    xnf = (xf - min(x))/xr;
    yf = Py*(y0/(2*pi) + k*xnf);
    plot(xf,wrap_nan(yf,Py),'k','LineWidth',1)

else
    % ---- circular x, circular y ----
    stats.case = 'circular x, circular y';
    tx = 2*pi*x/Px;  ty = 2*pi*y/Py;
    rho = circ_circ_corr(tx,ty);
    s = sign(rho); if s == 0, s = 1; end
    y0 = angle(mean(exp(1i*(ty - s*tx))));
    stats.r = rho; stats.slope = s; stats.offset = y0*Py/(2*pi);
    stats.p = perm_p(@(yy) abs(circ_circ_corr(tx,yy)),ty,abs(rho),nPerm);
    % wrapped line: y = offset + s*x*(Py/Px)  (mod Py)
    yf = Py*(y0/(2*pi)) + s*xf*(Py/Px);
    plot(xf,wrap_nan(yf,Py),'k','LineWidth',1)
end

if isnan(stats.r)
    title('r = NaN')
else
    title(sprintf('r=%.2f  p=%.3g',stats.r,stats.p))
end
end

% ======================= helpers =======================

function [R,k,y0] = best_phase_slope(xn,ty,kgrid)
% Maximise mean resultant length over phase-slope grid.
z = exp(1i*(ty(:) - 2*pi*xn(:)*kgrid));   % n x nk
m = mean(z,1);
[R,i] = max(abs(m));
k = kgrid(i);
y0 = angle(m(i));
end

function rho = circ_circ_corr(a,b)
% Jammalamadaka & SenGupta circular-circular correlation.
a = a(:); b = b(:);
sa = sin(a - angle(mean(exp(1i*a))));
sb = sin(b - angle(mean(exp(1i*b))));
rho = sum(sa.*sb)/sqrt(sum(sa.^2)*sum(sb.^2));
end

function p = perm_p(statfun,ty,obs,nPerm)
% Permutation p-value (one stat output taken; shuffles y).
cnt = 0;
for i = 1:nPerm
    s = statfun(ty(randperm(numel(ty))));
    cnt = cnt + (s >= obs);
end
p = (cnt + 1)/(nPerm + 1);
end

function yw = wrap_nan(yf,P)
% Wrap to [0,P) and break the line at wrap-arounds.
yw = mod(yf,P);
yw([abs(diff(yw)) > P/2; false]) = NaN;
end