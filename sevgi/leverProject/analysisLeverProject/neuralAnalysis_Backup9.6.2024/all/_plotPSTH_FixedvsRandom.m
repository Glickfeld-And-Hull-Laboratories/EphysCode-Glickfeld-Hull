function plotPSTH_FixedvsRandom(recordingDay, neuronType, allTrialCount, cellSpikeRatesRandom, cellSpikeRatesFixed, fixedHoldStartsAtTrial, behavRelevantTimes1, behavRelevantTimes2, preTime, postTime, edges, sTitleFixed, sTitleRandom, sFileName, strTrialType, colorsLine, colorsMark)
    globalsAll;
    
    f = figure;
    f.Position = [globalX globalY globalW globalH];
     
    %%%%%%%%%%%%%%%%%%%%%% PSTH - Fixed Delay Spikes with Behavioral Event Aligned %%%%%%%%%%%%%%%%%%%        

    sp1 = subplot(2,1,1);
    hold on        
    grid on
    
    yLimMax = 0;
    yLimMin = 10000;
    plt = nan(1,length(cellSpikeRatesFixed));
    legends = cell(1,length(cellSpikeRatesFixed));
    for ind=1:length(cellSpikeRatesFixed) % run through all types of trials (All, Hit, Fa, Miss)
        arrSpikeRatesFixed = cell2mat(cellSpikeRatesFixed{ind});
        if ~isempty(arrSpikeRatesFixed)
            meanSpikeRatesFixed = mean(arrSpikeRatesFixed,1);
            semSpikeRatesFixed = std(arrSpikeRatesFixed)/sqrt(size(arrSpikeRatesFixed,1));
            lowerBoundSpikeRatesFixed = meanSpikeRatesFixed - semSpikeRatesFixed;
            upperBoundSpikeRatesFixed = meanSpikeRatesFixed + semSpikeRatesFixed;
    
            edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
            smtSpikeRates = smooth(edgesPlt,meanSpikeRatesFixed, SPIKE_SPAN, SMOOTH_TYPE_L);
            smtLowerBoundSpikeRates = smooth(edgesPlt,lowerBoundSpikeRatesFixed, SPIKE_SPAN, SMOOTH_TYPE_L)';
            smtUpperBoundSpikeRates = smooth(edgesPlt,upperBoundSpikeRatesFixed, SPIKE_SPAN, SMOOTH_TYPE_L)';
    
            x2 = [edgesPlt, fliplr(edgesPlt)];
            inBetween = [smtUpperBoundSpikeRates, fliplr(smtLowerBoundSpikeRates)];
            fill(x2, inBetween, colorsLine{ind},'FaceAlpha', .2);
     
            plt(ind) = plot(edgesPlt, smtSpikeRates, colorsLine{ind}, 'LineWidth',1.4);
            set(gca,'box','off'); 
    
            legends{ind} = [strTrialType{ind} ' (' num2str(mean(meanSpikeRatesFixed),'%.2f') ' spk/s)'];
            if yLimMax < max(smtUpperBoundSpikeRates)
                yLimMax = max(smtUpperBoundSpikeRates);
            end
            if yLimMin > min(smtLowerBoundSpikeRates)
                yLimMin = min(smtLowerBoundSpikeRates);
            end
        end
    end
    
    legends(isnan(plt))=[];
    plt(isnan(plt))=[];
    
    ylabel('Spikes/s');
    %xlabel('Time (s)');
    xlim([-preTime postTime]);
    legend(plt, legends{:});
    set(gca,'TickDir','out');
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
    title(['Fixed Trials - ' sTitleFixed]);
            
    %%%%%%%%%%%%%%%%%%%%%% PSTH - Random Delay Spikes with Behavioral Event Aligned %%%%%%%%%%%%%%%%%%%       
    sp2 = subplot(2,1,2); % prepare for random portion
    hold on        
    grid on
        
    plt = nan(1,length(cellSpikeRatesRandom));
    legends = cell(1,length(cellSpikeRatesRandom));
    for ind=1:length(cellSpikeRatesRandom) % run through all types of trials (All, Hit, Fa, Miss)
        arrSpikeRatesRandom = cell2mat(cellSpikeRatesRandom{ind});
        if ~isempty(arrSpikeRatesRandom)
            meanSpikeRatesRandom = mean(arrSpikeRatesRandom,1);
            semSpikeRatesRandom = std(arrSpikeRatesRandom)/sqrt(size(arrSpikeRatesRandom,1));
            lowerBoundSpikeRatesRandom = meanSpikeRatesRandom - semSpikeRatesRandom;
            upperBoundSpikeRatesRandom = meanSpikeRatesRandom + semSpikeRatesRandom;
    
            edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
            smtSpikeRates = smooth(edgesPlt,meanSpikeRatesRandom, SPIKE_SPAN, SMOOTH_TYPE_L);
            smtLowerBoundSpikeRates = smooth(edgesPlt,lowerBoundSpikeRatesRandom, SPIKE_SPAN, SMOOTH_TYPE_L)';
            smtUpperBoundSpikeRates = smooth(edgesPlt,upperBoundSpikeRatesRandom, SPIKE_SPAN, SMOOTH_TYPE_L)';
    
            x2 = [edgesPlt, fliplr(edgesPlt)];
            inBetween = [smtUpperBoundSpikeRates, fliplr(smtLowerBoundSpikeRates)];
            fill(x2, inBetween, colorsLine{ind},'FaceAlpha', .2);
    
            plt(ind) = plot(edgesPlt, smtSpikeRates, colorsLine{ind}, 'LineWidth',1.4);
            set(gca,'box','off'); 
    
            legends{ind} = [strTrialType{ind} ' (' num2str(mean(meanSpikeRatesRandom),'%.2f') ' spk/s)'];
            if yLimMax < max(smtUpperBoundSpikeRates)
                yLimMax = max(smtUpperBoundSpikeRates);
            end
            if yLimMin > min(smtLowerBoundSpikeRates)
                yLimMin = min(smtLowerBoundSpikeRates);
            end
        end
    end
    
    legends(isnan(plt))=[];
    plt(isnan(plt))=[];
    
    ylabel('Spikes/s');
    %xlabel('Time (s)');
    xlim([-preTime postTime]);
    legend(plt, legends{:});
    set(gca,'TickDir','out');
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
    title(['Random Trials - ' sTitleRandom]);

    set(sp1,'Ylim',[yLimMin/1.2 yLimMax*1.1]);
    set(sp2,'Ylim',[yLimMin/1.2 yLimMax*1.1]);
    sgtitle([recordingDay ' ' neuronType '(n=' num2str(size(cellSpikeRatesFixed{1},1)) ') trials=' num2str(allTrialCount)])
    print([pathToFigureFolder recordingDay '_' neuronType '_psth_' sFileName '_' strTrialType{:} '_xlim_' num2str(preTime) '_' num2str(postTime) '.tif'], '-dtiff', '-r200');

end
