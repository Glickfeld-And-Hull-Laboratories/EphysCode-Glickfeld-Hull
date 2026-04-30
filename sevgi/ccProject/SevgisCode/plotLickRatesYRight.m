function plotLickRatesYRight(individualLickRates, edgesLickPlt)

    globals;
    
    yyaxis right                    
    meanLickRates = mean(individualLickRates,1);
    semLickRates = std(individualLickRates,'omitnan')/sqrt(size(individualLickRates,1));
    earlyLowerBoundSpikeRatesInc = meanLickRates - semLickRates;
    earlyUpperBoundSpikeRatesInc = meanLickRates + semLickRates;
    inBetween = [earlyUpperBoundSpikeRatesInc, fliplr(earlyLowerBoundSpikeRatesInc)];
    x2 = [edgesLickPlt, fliplr(edgesLickPlt)];
    fill(x2, inBetween, 'k', 'FaceColor', COLOR_BLIND_FRIENDLY_GREEN, 'EdgeColor', 'none', 'FaceAlpha', ALPHA_LIGHT); %, 'EdgeAlpha',ALPHA_EDGE);
    %pause(0.5);                            % [0 .5 .5]
    plot(edgesLickPlt, meanLickRates, 'LineWidth',1.5, 'Color', [COLOR_BLIND_FRIENDLY_GREEN ALPHA],'LineStyle','-');
%                     ax = gca;                                                % [0 .5 .5 ALPHA]
%                     ax.YAxis(2). Color = [0.9 0.9 0.9];
    if max(meanLickRates)>0
        ylim([0 max(meanLickRates)*2]);
    end
    ylabel('Lick rate/s');
    yyaxis left
end