function plotPSTHwrtReactionTimes(spikeTimeofFastReact, spikeTimeofSlowReact, fastMarkedEvent, slowMarkedEvent, sTitle, sFileName, fastTrialCount, slowTrialCount, startTime, endTime)
        
        globals;

        if ~isempty(fastMarkedEvent)
            fastMeanVal = fastMarkedEvent(1);
            fastMinVal = fastMarkedEvent(2); 
            fastMaxVal = fastMarkedEvent(3);
        end

        if ~isempty(slowMarkedEvent)
            slowMeanVal = slowMarkedEvent(1);
            slowMinVal = slowMarkedEvent(2); 
            slowMaxVal = slowMarkedEvent(3);
        end

        for iType = 1:length(NEURON_TYPES)+1
            if iType<length(NEURON_TYPES)
                cellTypeName = NEURON_TYPES{iType};
            else
                cellTypeName = 'Unknown';
            end
            cellFastReactSpikes = spikeTimeofFastReact{iType};
            cellSlowReactSpikes = spikeTimeofSlowReact{iType};
            
            if ~isempty(cellFastReactSpikes) && ~isempty(cellSlowReactSpikes)

                f = figure;
                f.Position = [globalX globalY globalW globalH];
                hold on
                
        
    %             loBandSpikes = spikeTimeofTrialAlignedToLeverRelease(indFastInds);
    %             trialCount = length(loBandSpikes);
    %             arrLoBandSpikes = cell2mat(loBandSpikes');
    %             hiBandSpikes = spikeTimeofTrialAlignedToLeverRelease(indSlowInds);
    %             arrHiBandSpikes = cell2mat(hiBandSpikes');
        
    %             minEdge = max([min(arrLoBandSpikes) min(arrHiBandSpikes)]); % get the bigger time point for minEdge so that both distr are treated equatibly
    %             maxEdge = min([max(arrLoBandSpikes) max(arrHiBandSpikes)]); % get the smaller time point for maxEdge so that both distr are treated equatibly
    %             edges = minEdge-BIN_SIZE_PSTH:BIN_SIZE_PSTH:maxEdge+BIN_SIZE_PSTH;
    %             arrLoBandSpikes = arrLoBandSpikes(arrLoBandSpikes>minEdge & arrLoBandSpikes<maxEdge);
    %             arrHiBandSpikes = arrHiBandSpikes(arrHiBandSpikes>minEdge & arrHiBandSpikes<maxEdge);
    
                edges = -startTime-BIN_SIZE_PSTH:BIN_SIZE_PSTH:endTime+BIN_SIZE_PSTH;
                arrSmthFast = zeros(length(cellFastReactSpikes),length(edges)-1);
                arrSmthSlow = zeros(length(cellFastReactSpikes),length(edges)-1);

                for iCell = 1:length(cellFastReactSpikes) % for every unit in this specific iType
                    arrFastReactSpikes = cell2mat(cellFastReactSpikes{iCell}');
                    arrSlowReactSpikes = cell2mat(cellSlowReactSpikes{iCell}');
    
                    if ~isempty(arrFastReactSpikes) && ~isempty(arrSlowReactSpikes)
                        binCounts = histcounts(arrFastReactSpikes,edges); % optimumBinCount);
                        fastSpikeRates = binCounts/(fastTrialCount*BIN_SIZE_PSTH); % averaged over trials and specified bin
                        edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
                        smtFastSpikeRates = smooth(edgesPlt,fastSpikeRates, SPIKE_SPAN, SMOOTH_TYPE_L); %SPIKE_SPAN            
                        arrSmthFast(iCell,:) = smtFastSpikeRates;
                        %scatter(edgesPlt,loSpikeRates,40, '.', 'green');
                        %plot(edgesPlt, smtFastSpikeRates, 'LineWidth',0.5, 'Color', [1, 0.2, 0.1]);
                        
                        binCounts = histcounts(arrSlowReactSpikes,edges); % optimumBinCount);
                        slowSpikeRates = binCounts/(slowTrialCount*BIN_SIZE_PSTH); % averaged over trials and specified bin
                        edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
                        smtSlowSpikeRates = smooth(edgesPlt,slowSpikeRates, SPIKE_SPAN, SMOOTH_TYPE_L);
                        arrSmthSlow(iCell,:) = smtSlowSpikeRates;
                        %scatter(edgesPlt,hiSpikeRates,40, '.', 'red');
                        %plot(edgesPlt, smtSlowSpikeRates, 'LineWidth', 0.5, 'Color', [0.3, 0.7, 0.9]);
                    end                    
                end

                xline(0, 'Color', 'black', 'LineStyle', '--', 'LineWidth',2);

                if ~isempty(fastMarkedEvent)
                    % Mark behaviorally relevant event
                    xline(slowMeanVal, 'Color', [0.1, 0.2, 1], 'LineWidth',2);
                    patch([slowMinVal, slowMaxVal, slowMaxVal, slowMinVal], [0, 0, 600, 600], [0.1, 0.2, 1] , 'EdgeColor', 'none', 'FaceAlpha',0.2);
                end

                if ~isempty(fastMarkedEvent)
                    % Mark behaviorally relevant event
                    xline(fastMeanVal, 'Color', [1, 0.2, 0.1], 'LineWidth',2);
                    patch([fastMinVal, fastMaxVal, fastMaxVal, fastMinVal], [0, 0, 600, 600], [1, 0.2, 0.1] , 'EdgeColor', 'none', 'FaceAlpha',0.2);
                end

                % Plot individual firing rates
                plot(edgesPlt, arrSmthSlow, 'LineWidth', 0.5, 'Color', [0.1, 0.2, 1 0.4]);
                plot(edgesPlt, arrSmthFast, 'LineWidth',0.5, 'Color', [1, 0.2, 0.1, 0.4]);
                
                % Plot mean firing rates
                pLegSlow = plot(edgesPlt, mean(arrSmthSlow,1), 'LineWidth', 3, 'Color', [0.1, 0.2, 1]);
                pLegFast = plot(edgesPlt, mean(arrSmthFast,1), 'LineWidth',3, 'Color', [1, 0.2, 0.1]);

                ylabel('Spikes/s');
                xlabel('Time from behavioral event (s)');
                legend([pLegSlow pLegFast],{['Slow (' num2str(mean(mean(arrSmthSlow,1)),'%.2f') ' spk/s) tr=' num2str(slowTrialCount)], ...
                    ['Fast (' num2str(mean(mean(arrSmthFast,1)),'%.2f') ' spk/s) tr=' num2str(fastTrialCount)]}, 'Location', 'northeast', 'color','none');
                xlim([edges(1) edges(end)]);
                ylim([-1 max(max(mean(arrSmthSlow,1)),max(mean(arrSmthFast,1)))*2]);
                grid on
                set(gca,'TickDir','out');
                set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)                   
                title([cellTypeName ' (n=' num2str(length(cellFastReactSpikes)) ') ' sTitle]);
                
                sReactionTimeAnalysesPSTHFolder = [pathToFigureFolder 'ReactionTimeAnalyses/PSTH/'];
                if ~exist(sReactionTimeAnalysesPSTHFolder)
                    mkdir(sReactionTimeAnalysesPSTHFolder);
                end
                print([sReactionTimeAnalysesPSTHFolder cellTypeName sFileName], '-dtiff', '-r300');
                close all
                logger.info('checkNeuralChangeswrtReactionTime', [cellTypeName ' fast vs slow reaction time PSTHs are plotted with title: ' sTitle]);
            end
        end
end