function plotRFThumbnailMap_SC(STA_cropped, results, thumbSize, doJitter)
% Thumbnail-only endpoint map
%
% x-axis = S = |As| * sigma_s^2 / (|Ac| * sigma_c^2)
% y-axis = C = f * sigma_c
%
% Example:
%   plotRFThumbnailMap_SC(STA_cropped, results, 0.035, true)

    if nargin < 3 || isempty(thumbSize)
        thumbSize = 0.035;
    end
    if nargin < 4 || isempty(doJitter)
        doJitter = true;
    end

    paramsCell = results.params{1};
    nCells = length(paramsCell);

    S = nan(nCells,1);
    C = nan(nCells,1);

    for k = 1:nCells
        params = paramsCell{k};

        if isempty(params) || any(isnan(params))
            continue
        end

        Ac = params(1);
        As = params(2);
        sc = params(3);
        ss = sc + params(4);
        f  = params(9);

        S(k) = abs(As) * ss^2 / (abs(Ac) * sc^2 + eps);
        C(k) = f * sc;
    end

    valid = ~(isnan(S) | isnan(C));
    if ~any(valid)
        error('No valid cells found.');
    end

    figure('Position',[120 80 1400 800]);
    ax = axes;
    hold(ax,'on');

    xlabel(ax,'Surround prominence  S');
    ylabel(ax,'Carrier prominence  C');
    title(ax,'Endpoint thumbnail map');

    xMin = min(S(valid));
    xMax = max(S(valid));
    yMin = min(C(valid));
    yMax = max(C(valid));

    if xMin == xMax
        xMin = xMin - 1;
        xMax = xMax + 1;
    end
    if yMin == yMax
        yMin = yMin - 0.05;
        yMax = yMax + 0.05;
    end

    xPad = 0.05 * (xMax - xMin);
    yPad = 0.03 * (yMax - yMin);

    xlim(ax,[max(0,xMin-xPad), xMax+xPad]);
    ylim(ax,[max(0,yMin-yPad), yMax+yPad]);

    grid(ax,'on');
    box(ax,'off');

    text(ax, ax.XLim(1)+0.06*diff(ax.XLim), ax.YLim(2)-0.06*diff(ax.YLim), 'Gabor-like', ...
        'FontWeight','bold');
    text(ax, ax.XLim(2)-0.06*diff(ax.XLim), ax.YLim(1)+0.05*diff(ax.YLim), 'DoG-like', ...
        'HorizontalAlignment','right', 'FontWeight','bold');
    text(ax, ax.XLim(2)-0.06*diff(ax.XLim), ax.YLim(2)-0.06*diff(ax.YLim), 'Hybrid', ...
        'HorizontalAlignment','right', 'FontWeight','bold');
    text(ax, ax.XLim(1)+0.06*diff(ax.XLim), ax.YLim(1)+0.05*diff(ax.YLim), 'Weak / ambiguous', ...
        'FontWeight','bold');

    drawnow;
    axpos = ax.Position;

    xvals = S;
    yvals = C;

    if doJitter
        xr = diff(ax.XLim);
        yr = diff(ax.YLim);

        xvals(valid) = xvals(valid) + 0.01*xr*randn(sum(valid),1);
        yvals(valid) = yvals(valid) + 0.01*yr*randn(sum(valid),1);

        xvals = min(max(xvals, ax.XLim(1)), ax.XLim(2));
        yvals = min(max(yvals, ax.YLim(1)), ax.YLim(2));
    end

    for k = 1:nCells
        if ~valid(k)
            continue
        end

        rf = STA_cropped(:,:,k);
        if isempty(rf) || all(isnan(rf(:)))
            continue
        end

        clim = max(abs(rf(:)));
        if clim <= 0 || isnan(clim)
            continue
        end

        xn = (xvals(k) - ax.XLim(1)) / diff(ax.XLim);
        yn = (yvals(k) - ax.YLim(1)) / diff(ax.YLim);

        xf = axpos(1) + xn * axpos(3);
        yf = axpos(2) + yn * axpos(4);

        axThumb = axes('Position',[xf-thumbSize/2, yf-thumbSize/2, thumbSize, thumbSize]);
        imagesc(axThumb, rf, [-clim clim]);
        axis(axThumb,'image','off');
        colormap(axThumb, gray);
    end
end