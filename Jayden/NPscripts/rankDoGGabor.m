%This to extract from params:
for ic = 1:40
    params = paramArray{ic};
    As(ic) = params(2);
    delts(ic) = params(4);
    Ac(ic) = params(1);
    cycles(ic) = params(9);
    effectiveSigma(ic) = params(3) / sqrt(params(5));
end

% Plot w STAs


figure;
    ax = axes;

    As_abs = abs(As);

    scatter(As_abs, cycles, 10, 'k') % optional reference points
    xlabel('|As|')
    ylabel('f')
    hold on

    axpos = ax.Position;   % position of main axes in figure

    for ic = 1:length(As_abs)

        % normalize data within axes limits
        xn = (As_abs(ic) - ax.XLim(1)) / diff(ax.XLim);
        yn = (cycles(ic) - ax.YLim(1)) / diff(ax.YLim);

        % convert to figure coordinates
        xf = axpos(1) + xn * axpos(3);
        yf = axpos(2) + yn * axpos(4);

        w = 0.03;
        h = 0.03;

        ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);

        clim = max(abs(STA_cropped(:)));
        imagesc(STA_cropped(:,:,ic),[-clim clim])
        axis image off
        colormap gray
    end