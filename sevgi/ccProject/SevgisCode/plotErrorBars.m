function plotErrorBars(spikeRates, edgesPlt, color)

    globals;

    meanSpikeRate = mean(spikeRates,1, 'omitnan');
    semSpikeRates = std(spikeRates,'omitnan')/sqrt(size(spikeRates,1));
    earlyLowerBoundSpikeRates = meanSpikeRate - semSpikeRates;
    earlyUpperBoundSpikeRates = meanSpikeRate + semSpikeRates;
    
    smtEarlyLowerBoundSpikeRates = smooth(edgesPlt,earlyLowerBoundSpikeRates, SPIKE_SPAN, SMOOTH_TYPE_L)';
    smtEarlyUpperBoundSpikeRates = smooth(edgesPlt,earlyUpperBoundSpikeRates, SPIKE_SPAN, SMOOTH_TYPE_L)';
    inBetween = [smtEarlyUpperBoundSpikeRates, fliplr(smtEarlyLowerBoundSpikeRates)];
    x2 = [edgesPlt, fliplr(edgesPlt)];
    fill(x2, inBetween, 'k', 'FaceColor', color, 'EdgeColor', 'none', 'FaceAlpha', ALPHA_LIGHT); %, 'EdgeAlpha',ALPHA_EDGE); %                  
    
end