%%%% PLOT PSTH %%%%%%%%%%%%
% timeStamps (s): Spike times in sec
% preHoldTime (ms): wait time in MWorks after level hold press. Task actually starts after preHoldTime amounts of time if it is defined in doPreHold=1 and preHoldTimeMs=200 ms
% 
% SO 12/14/2022 Hull Lab
function [plt, spikeRates, responseType] = psth(arrSpikeTimes, trialCount, markRelevantTimes1, markRelevantTimes2, edges, colors, lineColor)

        globals;        
        unitColors={[0.1 0.1 0.1], [0.1 0.1 0.1], [0.7 0.7 0.7], [0.7 0.7 0.7]}; % gray,
                
        smtSpikeRates = 0;

        if isempty(lineColor)
            lineColor = 'b';
        end
        
        binCounts = histcounts(arrSpikeTimes,edges); % optimumBinCount);
        spikeRates = binCounts/(trialCount*BIN_SIZE_PSTH); % averaged over trials and specified bin
        
        plt = NaN;
        responseType = 0;
        if ~isempty(arrSpikeTimes) %&& ~all(isnan(spikeRates))
            edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
            %if isempty(span)
                smtSpikeRates = smooth(edgesPlt,spikeRates, SPIKE_SPAN, SMOOTH_TYPE_L);
%             else
%                 smtSpikeRates = smooth(edgesPlt,spikeRates, span, SMOOTH_TYPE_L); % comes from shifted psth, which searches for shifted timestamps
%             end
            plt = plot(edgesPlt, smtSpikeRates, 'LineWidth',1.4, 'Color', lineColor);
            responseType = classifyCellbyResponse(smtSpikeRates, edgesPlt);             
            %ylim([0 max(spikeRates)*1.5]);
            %spikeRate = mean(spikeRates);
        else
            %spikeRate = 0;
        end

        if (~isempty(markRelevantTimes1)) % mark behaviorally relevant events
%             minVal = mean(markRelevantTimes1)-std(markRelevantTimes1)/sqrt(length(markRelevantTimes1)); % min(markRelevantTimes); %
%             maxVal = mean(markRelevantTimes1)+std(markRelevantTimes1)/sqrt(length(markRelevantTimes1)); % max(markRelevantTimes); %
%             xline(mean(markRelevantTimes1), colors{1}, 'LineWidth',1.7);
%             patch([minVal, maxVal, maxVal, minVal], [0, 0, 600, 600], colors{1} , 'EdgeColor', 'none', 'FaceAlpha',0.3); % MARK around the behavioral parameter. 600 is some arbitrary big y value
            plot(markRelevantTimes1, ones(length(markRelevantTimes1)), '*', 'color', colors{1});
        end

        if (~isempty(markRelevantTimes2)) % mark behaviorally relevant events
%             minVal = mean(markRelevantTimes2)-std(markRelevantTimes2)/sqrt(length(markRelevantTimes2)); % min(markRelevantTimes); %
%             maxVal = mean(markRelevantTimes2)+std(markRelevantTimes2)/sqrt(length(markRelevantTimes2)); % max(markRelevantTimes); %
%             xline(mean(markRelevantTimes2), colors{1}, 'LineWidth',1.7);
%             patch([minVal, maxVal, maxVal, minVal], [0, 0, 600, 600], colors{1} , 'EdgeColor', 'none', 'FaceAlpha',0.3); % MARK around the behavioral parameter. 600 is some arbitrary big y value
            plot(markRelevantTimes2, ones(length(markRelevantTimes2)), '*', 'color', colors{2});
        end
        
        set(gca,'box','off');        
end