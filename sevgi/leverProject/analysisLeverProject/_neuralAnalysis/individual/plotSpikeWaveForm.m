function plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, sLocalTitle)
    
    globals;
    
    f = figure;
    f.Position = [globalX globalY globalW globalH];     
    x=-RAW_PRE_SPIKE:1/samplingRate:RAW_POST_SPIKE-1/samplingRate;
    x=x.*1000; % convert to ms
    %plot(x,waveForms);
    hold on
    plot(x,waveFormMean,'LineWidth',2, 'color','blue')
    plot(x,waveFormMin,'LineWidth',1.5, 'color','blue')
    plot(x,waveFormMax,'LineWidth',1.5, 'color','blue')
    patch([x fliplr(x)], [waveFormMean fliplr(waveFormMin)], 'blue', 'FaceAlpha',0.1); % fill between
    patch([x fliplr(x)], [waveFormMean fliplr(waveFormMax)], 'b', 'FaceAlpha',0.1); % fill between
        
    ylabel('uV');
    xlabel('Time (ms)');        
    %xlim([-PRE_TIME_RELEASE POST_TIME_RELEASE]);
    set(gca,'TickDir','out');
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)
    title(['Unit=' num2str(unit.id) ' ' unit.expertLabel ' (' unit.layer ' ch=' num2str(unit.ch) ') ' sLocalTitle])

    sFolder = [pathToFigureFolder num2str(unit.id)];
    if ~isempty(unit.expertLabel)
        sFolder = [sFolder '_' unit.expertLabel];
    end
    print([sFolder '/' 'spikeWaveForm_' sLocalTitle '.tif'], '-dtiff', '-r100');    
    % exportgraphics(f,[sFolder '/' 'spikeWaveForm_' sLocalTitle '.pdf'], 'ContentType', 'vector', 'Resolution', 200);
    logger.info('plotSpikeWaveForm', ['Raw waveform is plot for unit=' num2str(unit.id)]);
    close all
end