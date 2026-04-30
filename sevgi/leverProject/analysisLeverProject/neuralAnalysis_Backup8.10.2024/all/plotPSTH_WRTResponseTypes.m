function plotPSTH_WRTResponseTypes(arrRecordings)

    globalsAll;        

    responseTypesPerCellType_fixedHoldAll = cell(1,length(NEURON_TYPES)); % 12 columns for (All,Hit,Miss,Fa)x(INCREASING,DECREASING,NO_CHANGE_OR_MIXED)
    spikeRatesPerCellType_fixedHoldAll = cell(1,length(NEURON_TYPES));
    responseTypesPerCellType_fixedHoldHFM = cell(1,length(NEURON_TYPES));
    spikeRatesPerCellType_fixedHoldHFM = cell(1,length(NEURON_TYPES));

    responseTypesPerCellType_fixedReleaseAll = cell(1,length(NEURON_TYPES)); % 12 columns for (All,Hit,Miss,Fa)x(INCREASING,DECREASING,NO_CHANGE_OR_MIXED)
    spikeRatesPerCellType_fixedReleaseAll = cell(1,length(NEURON_TYPES));
    responseTypesPerCellType_fixedReleaseHFM = cell(1,length(NEURON_TYPES));
    spikeRatesPerCellType_fixedReleaseHFM = cell(1,length(NEURON_TYPES));

    responseTypesPerCellType_fixedTargetAll = cell(1,length(NEURON_TYPES)); % 12 columns for (All,Hit,Miss,Fa)x(INCREASING,DECREASING,NO_CHANGE_OR_MIXED)
    spikeRatesPerCellType_fixedTargetAll = cell(1,length(NEURON_TYPES));
    responseTypesPerCellType_fixedTargetHFM = cell(1,length(NEURON_TYPES));
    spikeRatesPerCellType_fixedTargetHFM = cell(1,length(NEURON_TYPES));

    allTrialCount = 0;

    for indRec = 1:length(arrRecordings)
        currentRecording = arrRecordings{1,indRec};
        indices = strfind(currentRecording.name,'_');
        recordingDay = extractBetween(currentRecording.name, indices(1)+1, indices(3)-1);
        recordingDay = recordingDay{:};
        trialCount = length(currentRecording.leverHoldTimes);
        units = currentRecording.unitGood;                
        allTrialCount = allTrialCount + trialCount;
    
        for indNeuronType=1:length(NEURON_TYPES)
                indsNeurons = strcmp({units.neuronType},NEURON_TYPES{indNeuronType});
                if strcmp(NEURON_TYPES{indNeuronType},NEURON_TYPE_OTHER)
                    indsNeurons = strcmp({units.neuronType},'');
                else
                    indsNeurons = strcmp({units.neuronType},NEURON_TYPES{indNeuronType});
                end
                indsSingleUnits = [units.singleUnit];
                unitsOfSpecType = units(indsNeurons & indsSingleUnits); 

                if ~isempty(unitsOfSpecType)

                %if any(indsNeurons)
                    %unitsOfSpecType = units(indsNeurons); % get all neurons with the same cell type                                    

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HOLD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    responseTypeHoldFixedAll = {unitsOfSpecType.responseTypeHoldFixedAll}';
                    responseTypeHoldFixedHFM = {unitsOfSpecType.responseTypeHoldFixedHFM}';
                    spikeRatesHoldFixedAll = {unitsOfSpecType.spikeRatesHoldFixedAll}';                     
                    spikeRatesHoldFixedHFM = {unitsOfSpecType.spikeRatesHoldFixedHFM}';

                    plotPSTH_WRTResponseTypesForAHFM(recordingDay, NEURON_TYPES{indNeuronType}, ...
                        responseTypeHoldFixedAll, spikeRatesHoldFixedAll, responseTypeHoldFixedHFM, spikeRatesHoldFixedHFM, ...
                        PRE_TIME_HOLD, POST_TIME_HOLD, EDGES_HOLD, 'fixed_hold', 'Fixed Hold', trialCount);
                    responseTypesPerCellType_fixedHoldAll(indNeuronType) = {[responseTypesPerCellType_fixedHoldAll{indNeuronType}; responseTypeHoldFixedAll]};
                    spikeRatesPerCellType_fixedHoldAll(indNeuronType) = {[spikeRatesPerCellType_fixedHoldAll{indNeuronType}; spikeRatesHoldFixedAll]};
                    responseTypesPerCellType_fixedHoldHFM(indNeuronType) = {[responseTypesPerCellType_fixedHoldHFM{indNeuronType}; responseTypeHoldFixedHFM]};
                    spikeRatesPerCellType_fixedHoldHFM(indNeuronType) = {[spikeRatesPerCellType_fixedHoldHFM{indNeuronType}; spikeRatesHoldFixedHFM]};

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RELEASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                    responseTypeReleaseFixedAll = {unitsOfSpecType.responseTypeReleaseFixedAll}';                    
                    responseTypeReleaseFixedHFM = {unitsOfSpecType.responseTypeReleaseFixedHFM}';
                    spikeRatesReleaseFixedAll = {unitsOfSpecType.spikeRatesReleaseFixedAll}'; 
                    spikeRatesReleaseFixedHFM = {unitsOfSpecType.spikeRatesReleaseFixedHFM}';

                    plotPSTH_WRTResponseTypesForAHFM(recordingDay, NEURON_TYPES{indNeuronType}, ...
                        responseTypeReleaseFixedAll, spikeRatesReleaseFixedAll, responseTypeReleaseFixedHFM, spikeRatesReleaseFixedHFM, ...
                        PRE_TIME_RELEASE, POST_TIME_RELEASE, EDGES_RELEASE, 'fixed_release', 'Fixed Release', trialCount);
                    responseTypesPerCellType_fixedReleaseAll(indNeuronType) = {[responseTypesPerCellType_fixedReleaseAll{indNeuronType}; responseTypeReleaseFixedAll]};
                    spikeRatesPerCellType_fixedReleaseAll(indNeuronType) = {[spikeRatesPerCellType_fixedReleaseAll{indNeuronType}; spikeRatesReleaseFixedAll]};
                    responseTypesPerCellType_fixedReleaseHFM(indNeuronType) = {[responseTypesPerCellType_fixedReleaseHFM{indNeuronType}; responseTypeReleaseFixedHFM]};
                    spikeRatesPerCellType_fixedReleaseHFM(indNeuronType) = {[spikeRatesPerCellType_fixedReleaseHFM{indNeuronType}; spikeRatesReleaseFixedHFM]};

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TARGET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    responseTypeTargetFixedAll = {unitsOfSpecType.responseTypeTargetFixedAll}';
                    responseTypeTargetFixedHFM = {unitsOfSpecType.responseTypeTargetFixedHFM}';
                    spikeRatesTargetFixedAll = {unitsOfSpecType.spikeRatesTargetFixedAll}';                     
                    spikeRatesTargetFixedHFM = {unitsOfSpecType.spikeRatesTargetFixedHFM}';

                    plotPSTH_WRTResponseTypesForAHFM(recordingDay, NEURON_TYPES{indNeuronType}, ...
                        responseTypeTargetFixedAll, spikeRatesTargetFixedAll, responseTypeTargetFixedHFM, spikeRatesTargetFixedHFM, ...
                        PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM, EDGES_VIS_STIM, 'fixed_target', 'Fixed Target', trialCount);
                    responseTypesPerCellType_fixedTargetAll(indNeuronType) = {[responseTypesPerCellType_fixedTargetAll{indNeuronType}; responseTypeTargetFixedAll]};
                    spikeRatesPerCellType_fixedTargetAll(indNeuronType) = {[spikeRatesPerCellType_fixedTargetAll{indNeuronType}; spikeRatesTargetFixedAll]};
                    responseTypesPerCellType_fixedTargetHFM(indNeuronType) = {[responseTypesPerCellType_fixedTargetHFM{indNeuronType}; responseTypeTargetFixedHFM]};
                    spikeRatesPerCellType_fixedTargetHFM(indNeuronType) = {[spikeRatesPerCellType_fixedTargetHFM{indNeuronType}; spikeRatesTargetFixedHFM]};
                end
        end
    end

    %%%%%%% PLOT ALL RECORDINGS %%%%%%%%%%%%%%
    for indNeuronType=1:length(NEURON_TYPES)
        plotPSTH_WRTResponseTypesForAHFM('', NEURON_TYPES{indNeuronType}, ...
                        responseTypesPerCellType_fixedHoldAll{indNeuronType}, spikeRatesPerCellType_fixedHoldAll{indNeuronType}, ...
                        responseTypesPerCellType_fixedHoldHFM{indNeuronType}, spikeRatesPerCellType_fixedHoldHFM{indNeuronType}, ...
                        PRE_TIME_HOLD, POST_TIME_HOLD, EDGES_HOLD, 'fixed_hold', 'Fixed Hold', allTrialCount);
        plotPSTH_WRTResponseTypesForAHFM('', NEURON_TYPES{indNeuronType}, ...
                        responseTypesPerCellType_fixedReleaseAll{indNeuronType}, spikeRatesPerCellType_fixedReleaseAll{indNeuronType}, ...
                        responseTypesPerCellType_fixedReleaseHFM{indNeuronType}, spikeRatesPerCellType_fixedReleaseHFM{indNeuronType}, ...
                        PRE_TIME_RELEASE, POST_TIME_RELEASE, EDGES_RELEASE, 'fixed_release', 'Fixed Release', allTrialCount);
        plotPSTH_WRTResponseTypesForAHFM('', NEURON_TYPES{indNeuronType}, ...
                        responseTypesPerCellType_fixedTargetAll{indNeuronType}, spikeRatesPerCellType_fixedTargetAll{indNeuronType}, ...
                        responseTypesPerCellType_fixedTargetHFM{indNeuronType}, spikeRatesPerCellType_fixedTargetHFM{indNeuronType}, ...
                        PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM, EDGES_VIS_STIM, 'fixed_target', 'Fixed Target', allTrialCount);
    end
end