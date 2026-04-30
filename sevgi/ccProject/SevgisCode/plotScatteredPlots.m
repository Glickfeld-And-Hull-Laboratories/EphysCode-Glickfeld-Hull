function plotScatteredPlots(phases, radius, sTitle, sFile)

    f = prePlot(); 

    phases = phases*180/pi;
    meanValue = mean(phases,2); % convert to degrees
    sem = std(phases,0,2)/sqrt(size(phases,2));
    scatter(meanValue,radius, 100, 'k','filled');
    eb = errorbar(meanValue,radius,sem, 'horizontal', 'LineStyle','None');
    set(eb, 'color', 'k', 'LineWidth', 2);

    postPlot(f, 'Degrees', 'Radius', 0, 360, 0, 1, sTitle, sFile);
end