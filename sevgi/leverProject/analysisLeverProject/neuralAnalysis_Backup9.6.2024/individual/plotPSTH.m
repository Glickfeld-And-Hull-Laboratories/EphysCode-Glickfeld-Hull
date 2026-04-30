function [spikeRatesRandom, spikeRatesFixed, responseTypeFixed] = plotPSTH(unitID, neuronCategory, neuronType, layer, channel, allTrialCount, cellSpikeTimes, fixedHoldStartsAtTrial, behavRelevantTimes1, behavRelevantTimes2, preTime, postTime, edges, sTitleFixed, sTitleRandom, sFileName, strTrialType, colors, lineColors)
        globals;
                
        sPrintFolder = [pathToFigureFolder neuronCategory '/' num2str(unitID)];
        if ~isempty(neuronType)
            sPrintFolder = [sPrintFolder '_' neuronType];
        end
        
        randomTrials = cell(1,length(cellSpikeTimes));
        fixedTrials = cell(1,length(cellSpikeTimes));
        
        for ind=1:length(cellSpikeTimes)
            cellSpkTimes = cellSpikeTimes{ind};
            if fixedHoldStartsAtTrial{ind}>0 % if session is mixed with random/fixed trials
                randomTrials{ind} = cellSpkTimes(1:fixedHoldStartsAtTrial{ind}-1)';
                fixedTrials{ind} = cellSpkTimes(fixedHoldStartsAtTrial{ind}:end)';
            else % fixedHoldStartsAtTrial==0 means only random trials
                randomTrials{ind} = cellSpkTimes'; % All random trials
            end
        end
        
        f = figure;
        f.Position = [globalX globalY globalW globalH];
         
        %%%%%%%%%%%%%%%%%%%%%% PSTH - Fixed Delay Spikes with Behavioral Event Aligned %%%%%%%%%%%%%%%%%%%        

        sp1 = subplot(2,1,1);
        hold on        
        grid on
        
        yLimMax = 0;
        edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;

        plt = zeros(1,length(fixedTrials));
        legends = cell(1,length(fixedTrials));
        for ind=1:length(fixedTrials) % run through all types of trials (All, Hit, Fa, Miss)
            arrSpikeTimeFixed = cell2mat(fixedTrials{ind})';
            
            markBehavRelevantTimes1 = [];
            if ~isempty(behavRelevantTimes1)
                markTimes = behavRelevantTimes1{ind};
                markBehavRelevantTimes1 = cell2mat(markTimes(fixedHoldStartsAtTrial{ind}:end)')';
            end

            markBehavRelevantTimes2 = [];
            if ~isempty(behavRelevantTimes2)
                markTimes = behavRelevantTimes2{ind};
                markBehavRelevantTimes2 = cell2mat(markTimes(fixedHoldStartsAtTrial{ind}:end)')';
            end

            [plt(ind), spikeRatesFixed(ind,:), responseTypeFixed(ind)] = psth(arrSpikeTimeFixed, length(fixedTrials{ind}), markBehavRelevantTimes1, markBehavRelevantTimes2, edges, colors, lineColors{ind});
            legends{ind} = [strTrialType{ind} '(' num2str(responseTypeFixed(ind)) ') (' num2str(mean(spikeRatesFixed(ind,:)),'%.2f') ' spk/s) (n=' num2str(length(fixedTrials{ind})) ')'];
            
            smtSpikeRates = smooth(edgesPlt,spikeRatesFixed(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
            if yLimMax < max(smtSpikeRates)
                yLimMax = max(smtSpikeRates);
            end
%             if yLimMax < max(spikeRatesFixed(ind,:))
%                 yLimMax = max(spikeRatesFixed(ind,:));
%             end
        end
        
        legends(isnan(plt))=[];
        plt(isnan(plt))=[];
        
        ylabel('Spikes/s');
        %xlabel('Time (s)');
        xlim([-preTime postTime]);
        lgnd = legend(plt, legends{:});
        set(lgnd,'color','none');
        set(gca,'TickDir','out');
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
        title(['Prediction - ' sTitleFixed]);
                
        %%%%%%%%%%%%%%%%%%%%%% PSTH - Random Delay Spikes with Behavioral Event Aligned %%%%%%%%%%%%%%%%%%%       
        sp2 = subplot(2,1,2); % prepare for random portion
        hold on        
        grid on
                
        plt = zeros(1,length(randomTrials));
        legends = cell(1,length(randomTrials));
        for ind=1:length(randomTrials) % run through all types of trials (All, Hit, Fa, Miss)
            arrSpikeTimeRand = cell2mat(randomTrials{ind})';
            [plt(ind), spikeRatesRandom(ind,:), ~] = psth(arrSpikeTimeRand, length(randomTrials{ind}), [], [], edges, colors, lineColors{ind});
            legends{ind} = [strTrialType{ind} ' (' num2str(mean(spikeRatesRandom(ind,:)),'%.2f') ' spk/s) (n=' num2str(length(randomTrials{ind})) ')'];

            smtSpikeRates = smooth(edgesPlt,spikeRatesRandom(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
            if yLimMax < max(smtSpikeRates)
                yLimMax = max(smtSpikeRates);
            end
%             if yLimMax < max(spikeRatesRandom(ind,:))
%                 yLimMax = max(spikeRatesRandom(ind,:));
%             end
        end
        
        legends(isnan(plt))=[];
        plt(isnan(plt))=[];
        
        ylabel('Spikes/s');
        xlabel('Time (s)');
        lgnd = legend(plt, legends{:});
        set(lgnd,'color','none');
        xlim([-preTime postTime]);
        set(gca,'TickDir','out');
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
        title(['Reaction - ' sTitleRandom])        
        
        if yLimMax>0 && length(yLimMax)==1
            set(sp1,'Ylim',[0 yLimMax]);
            set(sp2,'Ylim',[0 yLimMax]);
        end
        sgtitle(['Unit=' num2str(unitID) ' ' neuronType ' (' layer ' ch=' num2str(channel) ') trials=' num2str(allTrialCount)]); %  ' ' str
        print([sPrintFolder '/' neuronType '_psth_' sFileName '_' strTrialType{:} '_xlim_' num2str(preTime) '_' num2str(postTime) '.tif'], '-dtiff', '-r200');


        %%%%%%%%%%%%%%%%%%%%%% PSTH - Random vs Fixed Delay Spikes with Behavioral Event Aligned %%%%%%%%%%%%%%%%%%%        

        f = figure;
        f.Position = [globalX globalY globalW*2.3 globalH];
        
        yLimMax = 0;
        edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;

        for ind=1:length(fixedTrials) % run through all types of trials (All, Hit, Fa, Miss)
            spFixedVsRandom{ind} = subplot(1,length(fixedTrials),ind);
            hold on        
            grid on
            arrSpikeTimeRand = cell2mat(randomTrials{ind})';
            [~, spikeRatesRandom(ind,:), ~] = psth(arrSpikeTimeRand, length(randomTrials{ind}), [], [], edges, colors, RANDOM_COLOR);
            legends{1} = ['Reaction ' strTrialType{ind} ' (' num2str(mean(spikeRatesRandom(ind,:)),'%.1f') ' spk/s) (n=' num2str(length(randomTrials{ind})) ')'];
            
            smtSpikeRates = smooth(edgesPlt,spikeRatesRandom(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
            if yLimMax < max(smtSpikeRates)
                yLimMax = max(smtSpikeRates);
            end

            arrSpikeTimeFixed = cell2mat(fixedTrials{ind})';
            [~, spikeRatesFixed(ind,:), responseTypeFixed(ind)] = psth(arrSpikeTimeFixed, length(fixedTrials{ind}), [], [], edges, colors, FIXED_COLOR);
            legends{2} = ['Prediction ' strTrialType{ind} '(' num2str(responseTypeFixed(ind)) ') (' num2str(mean(spikeRatesFixed(ind,:)),'%.1f') ' spk/s) (n=' num2str(length(fixedTrials{ind})) ')'];

            smtSpikeRates = smooth(edgesPlt,spikeRatesFixed(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
            if yLimMax < max(smtSpikeRates)
                yLimMax = max(smtSpikeRates);
            end

            if ind==1
                ylabel('Spikes/s');
            end
            if ind==2 || length(fixedTrials)==1
                xlabel('Time (s)');
            end
            lgnd = legend(legends{:});
            set(lgnd,'color','none');
            xlim([-preTime postTime]);
            set(gca,'TickDir','out');
            set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)           
        end
                
        for i=1:length(fixedTrials)
            if yLimMax>0
                set(spFixedVsRandom{i},'Ylim',[0 yLimMax*1.3]);
            end
        end
        sgtitle(['Reaction vs Prediction Trials - ' sTitleFixed ' Unit=' num2str(unitID) ' ' neuronType ' (layer=' layer ' ch=' num2str(channel) ') trials=' num2str(allTrialCount)]); %  ' ' str
        print([sPrintFolder '/' neuronType '_ReactVSPred_psth_' sFileName '_' strTrialType{:} '_xlim_' num2str(preTime) '_' num2str(postTime) '.tif'], '-dtiff', '-r200');
end