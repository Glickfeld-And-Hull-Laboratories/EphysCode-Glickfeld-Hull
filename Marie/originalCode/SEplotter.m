function SEplotter(edges, mean, SE, color, linewidth, facealpha)
%take in vectors of mean and st for plotting responses. mean = Y;, edges =
%X, SE = pre-calculated SE for each point.

x_vector = [edges, fliplr(edges)];
    patch = fill(x_vector, [mean+SE,fliplr(mean-SE)], color);
    set(patch, 'edgecolor', 'none');
    set(patch, 'FaceAlpha', facealpha);
    hold on;
    plot(edges, mean, color, 'LineWidth', linewidth);
end

