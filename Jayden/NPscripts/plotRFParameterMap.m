function plotRFParameterMap(STA_cropped, results)

paramsCell = results.params{1};   % first model

nCells = length(paramsCell);

As = nan(nCells,1);
cycles = nan(nCells,1);

%% Extract parameters

for k = 1:nCells

    params = paramsCell{k};

    if isempty(params) || any(isnan(params))
        continue
    end

    As(k)     = abs(params(2));
    cycles(k) = params(9);

end

%% Plot parameter map

figure('Position',[200 200 900 700])
ax = axes;
hold on

scatter(As,cycles,20,'k','filled')

xlabel('|As|')
ylabel('Spatial frequency (f)')
title('RF Parameter Map')

drawnow

axpos = ax.Position;

%% Overlay RF thumbnails

for k = 1:nCells

    if isnan(As(k)) || isnan(cycles(k))
        continue
    end

    rf = STA_cropped(:,:,k);

    if isempty(rf) || all(isnan(rf(:)))
        continue
    end

    % robust contrast scaling
    clim = max(abs(rf(:)));

    if clim == 0 || isnan(clim)
        continue
    end

    xn = (As(k) - ax.XLim(1)) / diff(ax.XLim);
    yn = (cycles(k) - ax.YLim(1)) / diff(ax.YLim);

    xf = axpos(1) + xn * axpos(3);
    yf = axpos(2) + yn * axpos(4);

    w = 0.045;
    h = 0.045;

    ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);

    imagesc(rf,[-clim clim])

    axis image off
    colormap gray

end

end