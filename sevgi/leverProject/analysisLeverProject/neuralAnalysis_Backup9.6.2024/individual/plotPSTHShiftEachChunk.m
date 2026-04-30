function plotPSTHShiftEachChunk(unitID, neuronType, layer, arrSpks1, arrSpks2, trialCount1, trialCount2, preTime, postTime, edges, sTitle, sSubTitle, sFirst, sSecond, sFileName, sSubFileName, strTrialType, colors)

        globals;
        
        if ~isempty(arrSpks1) && ~isempty(arrSpks2)
            [h,p] = ttest2(arrSpks1,arrSpks2);
            
            if h==1 % significant difference between distributions then plot superimposed PSTH

                if abs(mean(arrSpks1)-mean(arrSpks2))>0
                    sPrintFolder = [pathToFigureFolder num2str(unitID)];
                    if ~isempty(neuronType)
                        sPrintFolder = [sPrintFolder '_' neuronType];
                    end   

                    sStr = [sSubTitle ' ' sFirst ' vs ' sSecond ' 1/3 of'];
        
                    logger.info('plotPSTHShiftEachChunk', ['plotPSTHShiftEachChunk found sign. difference for ( ' sTitle ' ' strTrialType ' ' sStr ' ' num2str(mean(arrSpks1), '%.2f') ' vs ' num2str(mean(arrSpks2),'%.2f') ' ) in mean spike times for unit=' num2str(unitID) ' ' neuronType ' diff=' num2str((mean(arrSpks1)-mean(arrSpks2)),'%.2f')]);
        
                    plt = zeros(1,2);
        
                    f = figure;
                    f.Position = [globalX globalY globalW globalH];
                    hold on
                    [plt(1), spikeRatesRand1, ~] = psth(arrSpks1, trialCount1, [], [], edges, colors{1}); %SPAN_TIMESHIFTED
                    [plt(2), spikeRatesRand2, ~] = psth(arrSpks2, trialCount2, [], [], edges, colors{2}); %SPAN_TIMESHIFTED
                    xline(mean(arrSpks1),['--' colors{1}],'LineWidth',1.5);
                    xline(mean(arrSpks2),['--' colors{2}],'LineWidth',1.5);
                    legends{1} = [sFirst ' mean = ' num2str(mean(arrSpks1),'%.2f') ' s'];
                    legends{2} = [sSecond ' mean = ' num2str(mean(arrSpks2),'%.2f') ' s'];
                    legends(isnan(plt))=[];
                    plt(isnan(plt))=[];
                    ylabel('Spikes/s');
                    xlabel('Time (s)');
                    ylim([0 max(max(spikeRatesRand1),max(spikeRatesRand2))*1.5]);
                    xlim([-preTime postTime]);
                    legend(plt, legends{:});
                    set(gca,'TickDir','out');
                    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
                    title(['Unit=' num2str(unitID) ' ' neuronType ' (' layer ') ' sTitle ' ' sStr ' ' strTrialType ' Trials p=' num2str(p,'%.2f')]);
                    print([sPrintFolder '/' neuronType '_' num2str(unitID) '_psthShifted_' sFileName '_' sSubFileName strTrialType '_xlim_' num2str(preTime) '_' num2str(postTime) '.tif'], '-dtiff', '-r200');
                end
            end
        end
end