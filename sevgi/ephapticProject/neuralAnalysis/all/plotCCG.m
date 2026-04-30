function plotCCG(slaveSpikeRatesBaseline, slaveSpikeRatesAllBlockers, sLabel)
    globals;
    globalsAll; % to refresh overwritten variables
    
    xMax = X_MAX_CCG;
    binSize = BIN_SIZE_CCG;
    edges = -xMax-binSize:binSize:xMax+binSize;
    meanSlaveSpikeRatesBaseline = mean(slaveSpikeRatesBaseline,1);
    semSlaveSpikeRatesBaseline = std(slaveSpikeRatesBaseline,1)/sqrt(size(slaveSpikeRatesBaseline,1));
    
    meanSlaveSpikeRatesAllBlockers = mean(slaveSpikeRatesAllBlockers,1);
    semSlaveSpikeRatesAllBlockers = std(slaveSpikeRatesAllBlockers,1)/sqrt(size(slaveSpikeRatesAllBlockers,1));

    lowerBoundMeanBaseline = meanSlaveSpikeRatesBaseline-semSlaveSpikeRatesBaseline;
    upperBoundMeanBaseline = meanSlaveSpikeRatesBaseline+semSlaveSpikeRatesBaseline;
    lowerBoundMeanAllBlockers = meanSlaveSpikeRatesAllBlockers-semSlaveSpikeRatesAllBlockers;
    upperBoundMeanAllBlockers = meanSlaveSpikeRatesAllBlockers+semSlaveSpikeRatesAllBlockers;
    
    edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
    slaveSpikeRatesBaseline = slaveSpikeRatesBaseline(:,1:end-1);
    meanSlaveSpikeRatesBaseline = meanSlaveSpikeRatesBaseline(1:end-1);
    lowerBoundMeanBaseline = lowerBoundMeanBaseline(1:end-1);
    upperBoundMeanBaseline = upperBoundMeanBaseline(1:end-1);
    slaveSpikeRatesAllBlockers = slaveSpikeRatesAllBlockers(:,1:end-1);
    meanSlaveSpikeRatesAllBlockers = meanSlaveSpikeRatesAllBlockers(1:end-1);
    lowerBoundMeanAllBlockers = lowerBoundMeanAllBlockers(1:end-1);
    upperBoundMeanAllBlockers = upperBoundMeanAllBlockers(1:end-1);

    f = figure;    
    f.Position = [globalX globalY globalW globalH]; 
    hold on;

    if PLOT_INDIVIDUAL_PAIRS
        for i=1:size(slaveSpikeRatesBaseline,1)
            plot(edgesPlt, slaveSpikeRatesBaseline(i,:), 'LineWidth',1.5, 'Color', [0 0 0 0.2]);
            plot(edgesPlt, slaveSpikeRatesAllBlockers(i,:), 'LineWidth',1.5, 'Color', [1 0 0 0.2]);
        end
    end

    inBetweenBaseline = [upperBoundMeanBaseline, fliplr(lowerBoundMeanBaseline)];
    inBetweenAllBlockers = [upperBoundMeanAllBlockers, fliplr(lowerBoundMeanAllBlockers)];
    x2 = [edgesPlt, fliplr(edgesPlt)];
    fill(x2, inBetweenBaseline, 'k', 'FaceColor', 'k', 'EdgeColor', 'none', 'FaceAlpha', ALPHA_LIGHT);
    fill(x2, inBetweenAllBlockers, 'r', 'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', ALPHA_LIGHT);                

    plot(edgesPlt, meanSlaveSpikeRatesBaseline, 'LineWidth',2, 'Color', 'k');
    plot(edgesPlt, meanSlaveSpikeRatesAllBlockers, 'LineWidth',2, 'Color', 'r');
    
    grid on;
    
    set(gca,'box','off');
    xlabel('lag (ms)'); 
    if DO_RATE_CORRECTED
        ylabel('Spikes/s (rate corrected)');
    else
        ylabel('Spikes/s');
    end
    
    xlim([-xMax xMax]);     
    allSlaveSpikes = [meanSlaveSpikeRatesBaseline meanSlaveSpikeRatesAllBlockers];
    minLim = mean(allSlaveSpikes)-8*std(allSlaveSpikes);
    maxLim = max(allSlaveSpikes)*1.3; %mean(slaveSpikeRates)+6*std(slaveSpikeRates);
    if ~isempty(minLim) && ~isempty(maxLim) && minLim<maxLim
        ylim([minLim maxLim]); %[max(slaveSpikeRates)*.4 max(slaveSpikeRates)*1.3]); 
    end
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE);
    title([sLabel ' SS-MLI pairs n=' num2str(size(slaveSpikeRatesAllBlockers,1))]);
    
    print([pathToFigureFolder '/CCG_' sLabel '.tif'], '-dtiff', '-r120');
    exportgraphics(f,[pathToFigureFolder '/CCG_' sLabel '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
    savefig([pathToFigureFolder '/CCG_' sLabel '.fig']);
    logger.info('correlogram',['CCG plotted for ' sLabel ' SS-MLI pairs n=' num2str(size(slaveSpikeRatesAllBlockers,1))]);
    close all
end