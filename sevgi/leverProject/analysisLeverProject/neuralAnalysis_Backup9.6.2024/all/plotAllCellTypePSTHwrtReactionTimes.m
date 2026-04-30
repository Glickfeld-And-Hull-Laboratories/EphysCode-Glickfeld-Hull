function plotAllCellTypePSTHwrtReactionTimes(allMeanSmthFast, arrCellCounts, fastMarkedEvent, sTitle, sFileName, fastTrialCount, startTime, endTime)
        globalsAll;

        if ~isempty(fastMarkedEvent)
            fastMeanVal = mean(fastMarkedEvent);
            fastMinVal = mean(fastMarkedEvent)-std(fastMarkedEvent)/sqrt(length(fastMarkedEvent)); % std err
            fastMaxVal = mean(fastMarkedEvent)+std(fastMarkedEvent)/sqrt(length(fastMarkedEvent));
        end

        f = figure;
        f.Position = [globalX globalY 2*globalW globalH];
        hold on        

        edges = -startTime-BIN_SIZE_PSTH:BIN_SIZE_PSTH:endTime+BIN_SIZE_PSTH;
        edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;

        xline(0, 'Color', 'black', 'LineStyle', '--', 'LineWidth',2);

        if ~isempty(fastMarkedEvent)
            % Mark behaviorally relevant event
            xline(fastMeanVal, 'Color', [1, 0.2, 0.1], 'LineWidth',2);
            patch([fastMinVal, fastMaxVal, fastMaxVal, fastMinVal], [-0.1 , -0.1 , 600, 600], [1, 0.2, 0.1] , 'EdgeColor', 'none', 'FaceAlpha',0.2);
        end

        pLegFast = zeros(1,length(NEURON_TYPES));
        legText = cell(1,length(NEURON_TYPES));
        maxMeanSmthFast = 0;
        for iType = 1:length(allMeanSmthFast)
                meanSmthFast = allMeanSmthFast{iType};
                if ~isempty(meanSmthFast)
                    if iType<length(NEURON_TYPES)
                        cellTypeName = NEURON_TYPES{iType};
                    else
                        cellTypeName = 'Unknown';
                    end
                    % Plot mean firing rates of each cell type                    
                    pLegFast(iType) = plot(edgesPlt, meanSmthFast, 'LineWidth',2.5, 'Color', COLOR_CODES{iType});
                    maxMeanSmthFast = max(maxMeanSmthFast, max(meanSmthFast));
                    legText(iType) = {[NEURON_TYPES{iType} ' n=' num2str(arrCellCounts(iType))]};
                end
        end
        ylabel('Spikes/s');
        xlabel('Time from behavioral event (s)');
        indNotExistingType = find(pLegFast==0,1);
        while(~isempty(indNotExistingType))
            pLegFast = pLegFast(1:end ~= indNotExistingType);
            legText = legText(1:end ~= indNotExistingType);
            indNotExistingType = find(pLegFast==0,1);
        end
        legend(pLegFast,legText, 'Location', 'northeastoutside', 'color','none');
        xlim([edges(1)+CUT_SMOOTHER_EFFECT_ON_EDGES edges(end)-CUT_SMOOTHER_EFFECT_ON_EDGES]);
        ylim([-0.1 maxMeanSmthFast*1.1]);
        grid on
        set(gca,'TickDir','out');
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)                   
        title(sTitle);
        if PLOT_FONT_SIZE == PRINT_FONT_SIZE
            ax = gca;
            ax.TitleFontSizeMultiplier = .5; % so that Title can fit in
        end
        
        sFullFileName = [pathToFigureFolder REACTION_TIME_FOLDER];
        print([sFullFileName 'AllCells_' sFileName], '-dtiff', '-r300');
        close all
        logger.info('plotAllCellTypePSTHwrtReactionTimes', ['All cells with fast vs slow reaction time PSTHs are plotted with title: ' sTitle]);
end