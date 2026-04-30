function plotSpikeWaveForm(unit, waveForms, samplingRate, sLocalTitle)
    
    chMatrix = getChannelMatrix(unit.ch);

    globals;
    SKIP_TO_PLOT = 1;
    uVCoeff = 10^6;

    f = figure;
    f.Position = [globalX globalY globalW globalH*5];
    x=-RAW_PRE_SPIKE:1/samplingRate:RAW_POST_SPIKE-1/samplingRate;
    x=x.*1000; % convert to ms
    xPlot = x(1:SKIP_TO_PLOT:end); % You don't need that high resolution to plot

    avgWaveForms=cellfun(@mean,waveForms,'UniformOutput',false);
    maxWaveForms=max(max(cellfun(@max,avgWaveForms)));
    minWaveForms=min(min(cellfun(@min,avgWaveForms)));
    absMax = max(abs(maxWaveForms),abs(minWaveForms));

    for row = 1:CHANNEL_MATRIX_ROWS
        for col = 1:CHANNEL_MATRIX_COLUMNS
            waveForm = waveForms{row,col};
            waveFormPlt = waveForm(:,1:SKIP_TO_PLOT:end);
            if ~isempty(waveForm)
                subplot(CHANNEL_MATRIX_ROWS, CHANNEL_MATRIX_COLUMNS, (row-1)*CHANNEL_MATRIX_COLUMNS + col);
                waveFormMean = nanmean(waveForm,1);
                waveFormMeanPlt = waveFormMean(1:SKIP_TO_PLOT:end);
                waveFormMin = waveFormMean-nanstd(waveForm,1);
                waveFormMinPlt = waveFormMin(1:SKIP_TO_PLOT:end);
                waveFormMax = waveFormMean+nanstd(waveForm,1);
                waveFormMaxPlt = waveFormMax(1:SKIP_TO_PLOT:end);            
                
                %plot(xPlot,waveFormPlt,'LineWidth',.5, 'color',[.9 .9 .9 0.7]);
                hold on
                maxThis = max(waveFormMeanPlt);
                minThis = min(waveFormMeanPlt);
                absMaxThis = max(abs(maxThis),abs(minThis));
                if absMaxThis>.2*absMax
                    plot(xPlot,waveFormMeanPlt*uVCoeff,'LineWidth',1.5, 'color','blue')
                end
                %plot(xPlot,waveFormMinPlt,'LineWidth',1, 'color','blue')
                %plot(xPlot,waveFormMaxPlt,'LineWidth',1, 'color','blue')
                %patch([xPlot fliplr(xPlot)], [waveFormMeanPlt fliplr(waveFormMinPlt)], 'blue', 'FaceAlpha',0.1); % fill between
                %patch([xPlot fliplr(xPlot)], [waveFormMeanPlt fliplr(waveFormMaxPlt)], 'b', 'FaceAlpha',0.1); % fill between
%                 if max(waveFormMaxPlt)>min(waveFormMinPlt)
%                     ylim([min(waveFormMinPlt)*1.1 max(waveFormMaxPlt)*1.1]);
%                 end
                xlim([-RAW_PRE_SPIKE*1000*1.01 RAW_POST_SPIKE*1000*1.01]);
                ylim([uVCoeff*minWaveForms uVCoeff*maxWaveForms]);
                if ((row-1)*CHANNEL_MATRIX_COLUMNS + col)==unit.ch                    
                    title(num2str(unit.ch));
                    set(gca,'XColor', 'none');
                    set(gca, 'color', 'none');
                else
                    yticklabels({});
                    xticklabels({});
                    set(gca,'XColor', 'none', 'YColor','none');
                    set(gca, 'color', 'none');
                end
                %set(gca,'TickDir','out');                
                set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',SMALL_PLOT_FONT_SIZE,'LineWidth',1.5)
            end
        end
    end
    sgtitle(['Unit=' num2str(unit.id) ' (' unit.layer ' ch=' num2str(unit.ch) ') ' sLocalTitle]);

    han=axes(f,'visible','off'); 
    han.Title.Visible='on';
    han.XLabel.Visible='on';
    han.YLabel.Visible='on';
    ylabel(han,'uV');
    xlabel(han,'Time (ms)');
    

%     ylabel('uV');
%     xlabel('Time (ms)');     
    %xlim([-PRE_TIME_RELEASE POST_TIME_RELEASE]);
    
%     sgtitle(['Unit=' num2str(unit.id) ' (' unit.layer ' ch=' num2str(unit.ch) ') ' sLocalTitle]); % unit.expertLabel
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)
    sFolder = [pathToFigureFolder num2str(unit.id)];
%     if ~isempty(unit.expertLabel)
%         sFolder = [sFolder '_' unit.expertLabel];
%     end
    print([sFolder '/' FILE_NAME_WAVEFORM sLocalTitle '.tif'], '-dtiff', '-r300');    
    exportgraphics(f,[sFolder '/' FILE_NAME_WAVEFORM sLocalTitle '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
    if READ_RAW_OR_FILTERED_SIGNAL
        logger.info('plotSpikeWaveForm', ['Raw waveform is plot for unit=' num2str(unit.id) ' for ' sLocalTitle]);
    else
        logger.info('plotSpikeWaveForm', ['Filtered waveform is plot for unit=' num2str(unit.id) ' for ' sLocalTitle]);
    end
    close all
end