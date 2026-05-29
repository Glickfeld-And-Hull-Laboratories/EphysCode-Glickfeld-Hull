

function scatter_reg(x,y,sz)
% SCATTER_REG Plot scatter with linear regression and correlation stats
%
%   scatter_reg(x,y) creates a scatter plot of x vs y and overlays the
%   best-fit linear regression line. The function also computes the Pearson
%   correlation coefficient (r) and corresponding p-value and displays
%   them in the plot title.
%
%   Inputs
%   ------
%   x : vector
%       Values for the x-axis.
%
%   y : vector
%       Values for the y-axis. Must be the same length as x.
%
%   Behavior
%   --------
%   - Plots filled scatter points of x vs y.
%   - Fits a first-order polynomial (linear regression) using polyfit.
%   - Draws the regression line across the range of x.
%   - Computes Pearson correlation coefficient and p-value using corr().
%   - Displays r and p in the subplot title.
%
%   Example
%   -------
%   scatter_reg(valSize, amp_all(valSizeID))
%
%   See also polyfit, polyval, corr, scatter

if nargin <3
    sz = [];
end

% ---- remove NaNs ----
valid = ~isnan(x) & ~isnan(y);
x = x(valid);
y = y(valid);

scatter(x,y,sz,'filled','LineWidth',0.2,'MarkerEdgeColor','w')
axis square
set(gca,'TickDir','out')
hold on

% ---- only fit if enough data ----
if numel(x) > 1 && numel(unique(x)) > 1
    p = polyfit(x,y,1);
    xf = linspace(min(x),max(x),100);
    plot(xf,polyval(p,xf),'k','LineWidth',1)
end

[r,pval] = corr(x(:),y(:),'rows','complete');
title(sprintf('r=%.2f  p=%.3g',r,pval))

end