function prePlotPSTHwrtReactionTimes(cellTypeName, spikeTimeofFastReact, spikeTimeofSlowReact, fastMarkedEvent, slowMarkedEvent, sTitle, sFileName, fastTrialCount, slowTrialCount, startTime, endTime)
        
        globalsAll;

        if ~isempty(cellTypeName) 
            if ~isempty(spikeTimeofFastReact) 
                plotPSTHwrtReactionTimes(cellTypeName, spikeTimeofFastReact, spikeTimeofSlowReact, fastMarkedEvent, slowMarkedEvent, sTitle, sFileName, fastTrialCount, slowTrialCount, startTime, endTime);
            end
        else
            for iType = 1:length(NEURON_TYPES)
                if iType<length(NEURON_TYPES)
                    cellTypeName = NEURON_TYPES{iType};
                else
                    cellTypeName = 'Unknown';
                end
                cellFastReactSpikes = spikeTimeofFastReact{iType};
                cellSlowReactSpikes = spikeTimeofSlowReact{iType};
                
                if ~isempty(cellFastReactSpikes) && ~isempty(cellSlowReactSpikes)
                    plotPSTHwrtReactionTimes(cellTypeName, cellFastReactSpikes, cellSlowReactSpikes, fastMarkedEvent, slowMarkedEvent, sTitle, sFileName, fastTrialCount, slowTrialCount, startTime, endTime);
                end
            end
        end
end