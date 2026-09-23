function scatter_reg(x,y,sz,c)
% SCATTER_REG Plot scatter with linear regression and correlation stats
%
%   scatter_reg(x,y) creates a scatter plot of x vs y and overlays the
%   best-fit linear regression line. The function also computes the Pearson
%   correlation coefficient (r) and corresponding p-value and displays
%   them in the plot title.
%
%   scatter_reg(x,y,sz) additionally sets marker size(s) sz (scalar or
%   vector, same convention as MATLAB's scatter).
%
%   scatter_reg(x,y,sz,c) additionally color-codes each point by the
%   values in c (vector, same length as x/y). A colormap and colorbar
%   are added to reflect c.
%
%   Inputs
%   ------
%   x : vector
%       Values for the x-axis.
%
%   y : vector
%       Values for the y-axis. Must be the same length as x.
%
%   sz : scalar or vector, optional
%       Marker size(s). Pass [] to use the default size.
%
%   c : vector, optional
%       Values to color-code each point by. Must be the same length as x
%       and y. When provided, points are colored using the current
%       colormap and a colorbar is added.
%
%   Behavior
%   --------
%   - Plots filled scatter points of x vs y (optionally colored by c).
%   - Fits a first-order polynomial (linear regression) using polyfit.
%   - Draws the regression line across the range of x.
%   - Computes Pearson correlation coefficient and p-value using corr().
%   - Displays r and p in the subplot title.
%
%   Example
%   -------
%   scatter_reg(valSize, amp_all(valSizeID))
%   scatter_reg(valSize, amp_all(valSizeID), [], prefOri_all(valSizeID))
%
%   See also polyfit, polyval, corr, scatter

if nargin < 3
    sz = [];
end
if nargin < 4
    c = [];
end

useColor = ~isempty(c);

% ---- remove NaNs ----
if useColor
    valid = ~isnan(x) & ~isnan(y) & ~isnan(c);
    x = x(valid);
    y = y(valid);
    c = c(valid);
else
    valid = ~isnan(x) & ~isnan(y);
    x = x(valid);
    y = y(valid);
end

% ---- marker size default (needed explicitly when using color data) ----
if isempty(sz)
    sz = 36;   % MATLAB's default scatter marker size
end

if useColor
    scatter(x,y,sz,c,'filled','LineWidth',0.2,'MarkerEdgeColor','w')
    colorbar
    colormap(gca,turbo)
else
    scatter(x,y,sz,'filled','LineWidth',0.2,'MarkerEdgeColor','w')
end

set(gca,'TickDir','out')
axis square
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