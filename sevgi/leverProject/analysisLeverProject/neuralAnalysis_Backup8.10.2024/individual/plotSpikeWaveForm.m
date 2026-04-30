function plotSpikeWaveForm(unit, unitCategory, waveForms, waveFormMean, waveFormStd, samplingRate, sLocalTitle)
    
    globals;
        
    % SNR calculation - https://spikeinterface.readthedocs.io/en/latest/modules/qualitymetrics/snr.html
    noise_level = mad(waveForms,1,'all'); % median absolute deviation since it's more robust to outliers than mean absolute deviation
    amplitude = max(abs(waveFormMean));
    SNR = amplitude / noise_level;

    f = figure;
    f.Position = [globalX globalY globalW globalH];     
    x=-RAW_PRE_SPIKE:1/samplingRate:RAW_POST_SPIKE-1/samplingRate;
    x=x.*1000; % convert to ms

    plot(x,waveForms,'LineWidth',0.02, 'color',[0 0 1 0.2]);
    hold on    
    waveFormMin = waveFormMean-waveFormStd;
    waveFormMax = waveFormMean+waveFormStd;
    plot(x,waveFormMean, 'LineWidth',2, 'color','black')
    plot(x,waveFormMin, 'LineStyle', '--', 'LineWidth',1.5, 'color','black')
    plot(x,waveFormMax, 'LineStyle', '--', 'LineWidth',1.5, 'color','black')
    %patch([x fliplr(x)], [waveFormMean fliplr(waveFormMin)], 'blue', 'FaceAlpha',0.1); % fill between
    %patch([x fliplr(x)], [waveFormMean fliplr(waveFormMax)], 'b', 'FaceAlpha',0.1); % fill between
        
    ylabel('uV');
    xlabel('Time (ms)');        
    %xlim([-PRE_TIME_RELEASE POST_TIME_RELEASE]);
    ylim([-max(abs(waveFormMax))*3 max(abs(waveFormMax))*3]);
    set(gca,'TickDir','out');
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)
    title(['Unit=' num2str(unit.id) ' ' unit.neuronType ' (' unit.layer ' ch=' num2str(unit.ch) ' SNRphyllum= ' num2str(unit.SNR,'%.2f') ' SNRmine= ' num2str(SNR,'%.2f') ') ' sLocalTitle])

    sFolder = [pathToFigureFolder unitCategory '/' num2str(unit.id)];
    if ~isempty(unit.neuronType)
        sFolder = [sFolder '_' unit.neuronType];
    end
    print([sFolder '/' 'spikeWaveForm_' sLocalTitle '.tif'], '-dtiff', '-r100');    
    % exportgraphics(f,[sFolder '/' 'spikeWaveForm_' sLocalTitle '.pdf'], 'ContentType', 'vector', 'Resolution', 200);
    logger.info('plotSpikeWaveForm', ['Raw waveform is plot for unit=' num2str(unit.id)]);
    close all
end