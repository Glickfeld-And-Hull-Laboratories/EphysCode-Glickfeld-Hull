function plotPSTHs(cellSpikeRates, trialCounts, behavRelevantTimes1, behavRelevantTimes2, preTime, postTime, edges, sTitles, sGlobalTitle, sFileName, sTrialTypes, colorsLines, colorsMark, compareFixedVsRandom)
    globalsAll;
    
    if length(trialCounts)==2
        type1TrialCounts = trialCounts';
        type2TrialCounts = trialCounts;
    else
        allHitFixedTrialCount = trialCounts(1);
        allHitRandomTrialCount = trialCounts(2);
        allFaFixedTrialCount = trialCounts(3);
        allFaRandomTrialCount = trialCounts(4);
        allMissFixedTrialCount = trialCounts(5);
        allMissRandomTrialCount = trialCounts(6);

        type1TrialCounts = [allHitFixedTrialCount, allFaFixedTrialCount, allMissFixedTrialCount; allHitRandomTrialCount, allFaRandomTrialCount, allMissRandomTrialCount];
        type2TrialCounts = [allHitFixedTrialCount, allHitRandomTrialCount; allFaFixedTrialCount, allFaRandomTrialCount; allMissFixedTrialCount, allMissRandomTrialCount];        
    end

    len = length(cellSpikeRates);

    f = figure;
    f.Position = [globalX globalY len*globalW globalH];     
    
    yLimMax = 1;
    yLimMin = 10000;        
    

    for spInd = 1:len
        sp{spInd} = subplot(1, len, spInd);
        hold on        
        grid on
        
        currentSpikeRates = cellSpikeRates{spInd};
        sTrialType = sTrialTypes{spInd};
        colorsLine = colorsLines{spInd};

        plt = nan(1,length(currentSpikeRates));
        legends = cell(1,length(currentSpikeRates));
        for ind=1:length(currentSpikeRates) % run through all types of trials (All, Hit, Fa, Miss)
            arrSpikeRates = cell2mat(currentSpikeRates{ind});            
            if ~isempty(arrSpikeRates) && ~all(all(isnan(arrSpikeRates)))
                arrSpikeRates = arrSpikeRates(~isnan(mean(arrSpikeRates,2)),:); % get rid of nan rows
                meanSpikeRatesFixed = mean(arrSpikeRates,1);
                semSpikeRatesFixed = std(arrSpikeRates)/sqrt(size(arrSpikeRates,1));
                lowerBoundSpikeRatesFixed = meanSpikeRatesFixed - semSpikeRatesFixed;
                upperBoundSpikeRatesFixed = meanSpikeRatesFixed + semSpikeRatesFixed;
        
                edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
                smtSpikeRates = smooth(edgesPlt,meanSpikeRatesFixed, SPIKE_SPAN, SMOOTH_TYPE_L);
                %smtLowerBoundSpikeRates = smooth(edgesPlt,lowerBoundSpikeRatesFixed, SPIKE_SPAN, SMOOTH_TYPE_L)';
                %smtUpperBoundSpikeRates = smooth(edgesPlt,upperBoundSpikeRatesFixed, SPIKE_SPAN, SMOOTH_TYPE_L)';
        
%                 x2 = [edgesPlt, fliplr(edgesPlt)];
%                 inBetween = [smtUpperBoundSpikeRates, fliplr(smtLowerBoundSpikeRates)];
%                 fill(x2, inBetween, colorsLine{ind},'FaceAlpha', .2);
         
                plt(ind) = plot(edgesPlt, smtSpikeRates, colorsLine{ind}, 'LineWidth',1.4);
                set(gca,'box','off'); 
        
                legends{ind} = [sTrialType{ind} ' (' num2str(mean(meanSpikeRatesFixed),'%.1f') ' spk/s) (tr=' num2str(type1TrialCounts(spInd,ind)) ')'];
                if yLimMax < max(smtSpikeRates) % && spInd~=len % skip the last subplot, cos it is noChange or Mixed response and keeps increasing ylim
                    yLimMax = max(smtSpikeRates);
                end
                if yLimMin > min(smtSpikeRates) % && spInd~=len % skip the last subplot, cos it is noChange or Mixed response and keeps increasing ylim
                    yLimMin = min(smtSpikeRates);
                end
            end
        end
        
        legends(isnan(plt))=[];
        plt(isnan(plt))=[];
        
        ylabel('Spikes/s');
        %if spInd==len
            xlabel('Time around the behavioral event(s)');
        %end
        xlim([-preTime+CUT_SMOOTHER_EFFECT_ON_EDGES postTime-CUT_SMOOTHER_EFFECT_ON_EDGES]);
        legend(plt, legends{:},'Color','none');
        legend boxoff;
        set(gca,'TickDir','out');
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
        title([sTitles{spInd} ' (tr=' num2str(sum(type1TrialCounts(spInd,~isnan(type1TrialCounts(spInd,:))))) ')']);
    end
        
    if yLimMin/1.2<yLimMax*1.1 % If first two subplots have some data
        for spInd = 1:len %-1 % skip the last subplot, cos it is noChange or Mixed response
            set(sp{spInd},'Ylim',[yLimMin/1.2 yLimMax*1.1]);
        end
    end
    sgtitle(sGlobalTitle); % [recordingDay ' ' neuronType '(n=' num2str(size(cellSpikeRatesFixed{1},1)) ') trials=' num2str(allTrialCount)]
    print(sFileName, '-dtiff', '-r200'); % [pathToFigureFolder recordingDay '_' neuronType '_psth_' sFileName '_' strTrialType{:} '_xlim_' num2str(preTime) '_' num2str(postTime) '.tif']

    % ******************* PLOT Fixed vs Random on the same plot *****************

    if compareFixedVsRandom
        colorsRandFixed = {FIXED_COLOR, RANDOM_COLOR};    
        sFixedvsRandom = {'Prediction', 'Reaction'};
                
        yLimMax = 1;
        yLimMin = 10000;        
        len = length(cellSpikeRates);

        currentSpikeRates = cellSpikeRates{1}; % pick a random one to get the length
        f = figure;
        f.Position = [globalX globalY length(currentSpikeRates)*globalW globalH];     
        for indSubPlt=1:length(currentSpikeRates)
        %for spInd = 1:len
            if ~isempty(currentSpikeRates{indSubPlt})
                spNew{indSubPlt} = subplot(1, length(currentSpikeRates), indSubPlt);
                hold on        
                %grid on
                
                %currentSpikeRates = cellSpikeRates{indSubPlt};
                sTitle = sTrialType{indSubPlt};
                plt = nan(1,len); %length(currentSpikeRates));
                legends = cell(1,len); %length(currentSpikeRates));
                for ind=1:len % length(currentSpikeRates) % run through trials types (All, Hit, Fa, Miss) for Random and Fixed
                    currentSpikeRates = cellSpikeRates{ind};
                    arrSpikeRates = cell2mat(currentSpikeRates{indSubPlt});                
                    if ~isempty(arrSpikeRates) && ~all(all(isnan(arrSpikeRates)))    
                        arrSpikeRates = arrSpikeRates(~isnan(mean(arrSpikeRates,2)),:); % get rid of nan rows
                        meanSpikeRatesFixed = mean(arrSpikeRates,1);
                        semSpikeRatesFixed = std(arrSpikeRates)/sqrt(size(arrSpikeRates,1));
                        lowerBoundSpikeRatesFixed = meanSpikeRatesFixed - semSpikeRatesFixed;
                        upperBoundSpikeRatesFixed = meanSpikeRatesFixed + semSpikeRatesFixed;
                
                        edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
                        smtSpikeRates = smooth(edgesPlt,meanSpikeRatesFixed, SPIKE_SPAN, SMOOTH_TYPE_L);
                        smtLowerBoundSpikeRates = smooth(edgesPlt,lowerBoundSpikeRatesFixed, SPIKE_SPAN, SMOOTH_TYPE_L)';
                        smtUpperBoundSpikeRates = smooth(edgesPlt,upperBoundSpikeRatesFixed, SPIKE_SPAN, SMOOTH_TYPE_L)';
                
                        x2 = [edgesPlt, fliplr(edgesPlt)];
                        inBetween = [smtUpperBoundSpikeRates, fliplr(smtLowerBoundSpikeRates)];
                        fill(x2, inBetween, 'k', 'FaceColor', colorsRandFixed{ind}, 'EdgeColor', colorsRandFixed{ind}, 'FaceAlpha', .2);
                        xline(0,'--');
    %                     plt(ind) = plot(edgesPlt, smtSpikeRates, 'LineWidth',1.5, 'Color', colorsRandFixed{ind});
    %                     set(gca,'box','off'); 
                
                        legends{ind} = [sFixedvsRandom{ind} ' (' num2str(mean(meanSpikeRatesFixed),'%.1f') ' spk/s) (tr=' num2str(type2TrialCounts(indSubPlt,ind)) ')'];
                        if yLimMax < max(smtSpikeRates) % && spInd~=length(currentSpikeRates) % skip the last subplot, cos it is noChange or Mixed response and keeps increasing ylim
                            yLimMax = max(smtSpikeRates);
                        end
                        if yLimMin > min(smtSpikeRates) % && spInd~=length(currentSpikeRates) % skip the last subplot, cos it is noChange or Mixed response and keeps increasing ylim
                            yLimMin = min(smtSpikeRates);
                        end
                    end
                end
    
                for ind=1:len % length(currentSpikeRates) % run through trials types (All, Hit, Fa, Miss) for Random and Fixed
                    currentSpikeRates = cellSpikeRates{ind};
                    arrSpikeRates = cell2mat(currentSpikeRates{indSubPlt});
                    if ~isempty(arrSpikeRates) && ~all(all(isnan(arrSpikeRates)))
                        arrSpikeRates = arrSpikeRates(~isnan(mean(arrSpikeRates,2)),:); % get rid of nan rows
                        meanSpikeRatesFixed = mean(arrSpikeRates,1);
                        semSpikeRatesFixed = std(arrSpikeRates)/sqrt(size(arrSpikeRates,1));
                        lowerBoundSpikeRatesFixed = meanSpikeRatesFixed - semSpikeRatesFixed;
                        upperBoundSpikeRatesFixed = meanSpikeRatesFixed + semSpikeRatesFixed;
                
                        edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
                        smtSpikeRates = smooth(edgesPlt,meanSpikeRatesFixed, SPIKE_SPAN, SMOOTH_TYPE_L);             
                        plt(ind) = plot(edgesPlt, smtSpikeRates, 'LineWidth',2.5, 'Color', colorsRandFixed{ind});
                    end
                end
                
                legends(isnan(plt))=[];
                plt(isnan(plt))=[];
                
                ylabel('Spikes/s');
                %if indSubPlt==length(currentSpikeRates)
                    xlabel('Time around the behavioral event(s)');
                %end
                xlim([-preTime+CUT_SMOOTHER_EFFECT_ON_EDGES postTime-CUT_SMOOTHER_EFFECT_ON_EDGES]);
                legend(plt, legends{:},'Color','none');
                legend boxoff;
                set(gca,'TickDir','out');
                set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5) 
                grid on;
                %header = substring(sTitles{end}, strfind(sTitles{end},'-'), length(sTitles{end}))
                %title([ extractAfter(sTitles{end},'-') ' - ' sTitle ' trials']);
                title([extractAfter(sTitles{end},'-') ' - ' sTitle ' trials (tr=' num2str(sum(type2TrialCounts(indSubPlt,~isnan(type2TrialCounts(indSubPlt,:))))) ')']);
            end
        end
            
        if yLimMin/1.2<yLimMax*1.2 % If first two subplots have some data
            for spInd = 1:length(currentSpikeRates) %-1 % skip the last subplot, cos it is noChange or Mixed response
                set(spNew{spInd},'Ylim',[yLimMin/1.2 yLimMax*1.2]);
            end
        end
        sgtitle(sGlobalTitle); % [recordingDay ' ' neuronType '(n=' num2str(size(cellSpikeRatesFixed{1},1)) ') trials=' num2str(allTrialCount)]
        sFileName = [extractBefore(sFileName,'.tif') '_FixedvsRandom.tif']; 
        print(sFileName, '-dtiff', '-r200'); % [pathToFigureFolder recordingDay '_' neuronType '_psth_' sFileName '_' strTrialType{:} '_xlim_' num2str(preTime) '_' num2str(postTime) '.tif']
        % sFileName = [extractBefore(sFileName,'.tif') '.pdf'];
        % exportgraphics(f,sFileName, 'ContentType', 'vector', 'Resolution', 200);
    end
end
