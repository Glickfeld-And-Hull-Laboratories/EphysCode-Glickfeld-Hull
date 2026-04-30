function prePlotPSTHwrtReactionTimes(cellTypeName, spikeTimeofFastReact, spikeTimeofSlowReact, fastMarkedEvent, slowMarkedEvent, sTitle, sFileName, fastTrialCount, slowTrialCount, startTime, endTime)
        
        globalsAll;

        if ~isempty(cellTypeName) 
            if ~isempty(spikeTimeofFastReact) 
                plotPSTHwrtReactionTimes(cellTypeName, spikeTimeofFastReact, spikeTimeofSlowReact, fastMarkedEvent, slowMarkedEvent, sTitle, sFileName, fastTrialCount, slowTrialCount, startTime, endTime);
            end
        else
            allMeanSmthFast = cell(1,length(NEURON_TYPES));
            arrCellCounts = zeros(1,length(NEURON_TYPES));
            for iType = 1:length(NEURON_TYPES)
                if iType<length(NEURON_TYPES)
                    cellTypeName = NEURON_TYPES{iType};
                else
                    cellTypeName = 'Unknown';
                end
                cellFastReactSpikes = spikeTimeofFastReact{iType};
                cellSlowReactSpikes = spikeTimeofSlowReact{iType};
                
                if ~isempty(cellFastReactSpikes) && ~isempty(cellSlowReactSpikes)
                    meanSmthFast = plotPSTHwrtReactionTimes(cellTypeName, cellFastReactSpikes, cellSlowReactSpikes, fastMarkedEvent, slowMarkedEvent, sTitle, sFileName, fastTrialCount, slowTrialCount, startTime, endTime);
                    allMeanSmthFast{iType} = meanSmthFast;   
                    arrCellCounts(iType) = length(cellFastReactSpikes);
                end
            end
            if any(~cellfun(@isempty,allMeanSmthFast))
                plotAllCellTypePSTHwrtReactionTimes(allMeanSmthFast, arrCellCounts, fastMarkedEvent, sTitle, sFileName, fastTrialCount, startTime, endTime);
            
                %%%%%%%%%%%%%%%%%%% NORMALIZED FIRING RATES %%%%%%%%%%%%%%%
                %%%% Needed to chop beginning and end of the signal cos edges
                %%%% have smoother effect - downwards! may affect the minimum FR in normalized FR calculation
                %%% Let's cut ~0.1s from the beginning and end
                CHOP_AMOUNT = floor(0.1/BIN_SIZE_PSTH);
                edges = -startTime-BIN_SIZE_PSTH:BIN_SIZE_PSTH:endTime+BIN_SIZE_PSTH;            
                choppedAllMeanSmthFast = cellfun(@(c) c(CHOP_AMOUNT+1:end-CHOP_AMOUNT),allMeanSmthFast(~cellfun('isempty',allMeanSmthFast)),'UniformOutput',false);
                normalizedAllMeanSmthFast = cellfun( @(c) (c-min(c))/(max(c)-min(c)),choppedAllMeanSmthFast,'UniformOutput',false);
                % TODO: see plotHeatMap() for a better z-scored firing rate implementation
                emptyInd = find(cellfun('isempty',allMeanSmthFast));
                if ~isempty(emptyInd)
                    normalizedAllMeanSmthFast(emptyInd+1:end+1) = normalizedAllMeanSmthFast(emptyInd:end);
                    normalizedAllMeanSmthFast(emptyInd)=[];
                    normalizedAllMeanSmthFast = {normalizedAllMeanSmthFast{1:emptyInd-1}, [], normalizedAllMeanSmthFast{emptyInd:end}};
                end
                plotAllCellTypePSTHwrtReactionTimes(normalizedAllMeanSmthFast, arrCellCounts, fastMarkedEvent, ['Norm. FR - ' sTitle], ['NormFR_' sFileName], fastTrialCount, -1*edges(CHOP_AMOUNT+1)-BIN_SIZE_PSTH, edges(end-CHOP_AMOUNT)-BIN_SIZE_PSTH);
            end
        end
end