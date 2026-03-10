

function scatter_reg(x,y)
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

scatter(x,y,'filled')
axis square
set(gca,'TickDir','out')

p = polyfit(x,y,1);
hold on
xf = linspace(min(x),max(x),100);
plot(xf,polyval(p,xf),'k','LineWidth',1)

[r,pval] = corr(x(:),y(:),'rows','complete');
title(sprintf('r=%.2f  p=%.3g',r,pval))

end