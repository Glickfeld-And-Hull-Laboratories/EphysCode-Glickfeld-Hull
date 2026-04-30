function plotPSTH_WRTCellTypes(arrRecordings)

    globalsAll;
    
    if RECORDING_DAY_OF_INTEREST == -1 % Plot all days of recordings
        allTrialCount = 0;
        allHitFixedTrialCount = 0;
        allHitRandomTrialCount = 0;

        allFaFixedTrialCount = 0;
        allFaRandomTrialCount = 0;

        allMissFixedTrialCount = 0;
        allMissRandomTrialCount = 0;

        unitsOfSpecTypeForAllRec = cell(length(NEURON_TYPES),1); %struct([]);
        for indRec = 1:length(arrRecordings)
                
                currentRecording = arrRecordings{1,indRec};
                indices = strfind(currentRecording.name,'_');
                recordingDay = extractBetween(currentRecording.name, indices(1)+1, indices(3)-1);
                recordingDay = recordingDay{:};
                units = currentRecording.unitGood;                

                trialCount = length(currentRecording.allTrials);
                hitFixedTrialCount = length(units(1).spikeRatePerTrialHoldFixedHit); %currentRecording.arrHitTrials);
                hitRandomTrialCount = length(units(1).spikeRatePerTrialHoldRandomHit);
                
                faFixedTrialCount = length(units(1).spikeRatePerTrialHoldFixedFa);
                faRandomTrialCount = length(units(1).spikeRatePerTrialHoldRandomFa);

                missFixedTrialCount = length(units(1).spikeRatePerTrialHoldFixedMiss);
                missRandomTrialCount = length(units(1).spikeRatePerTrialHoldRandomMiss);

                allHitFixedTrialCount = allHitFixedTrialCount + hitFixedTrialCount;
                allHitRandomTrialCount = allHitRandomTrialCount + hitRandomTrialCount;
                
                allFaFixedTrialCount = allFaFixedTrialCount + faFixedTrialCount;
                allFaRandomTrialCount = allFaRandomTrialCount + faRandomTrialCount;

                allMissFixedTrialCount = allMissFixedTrialCount + missFixedTrialCount;
                allMissRandomTrialCount = allMissRandomTrialCount + missRandomTrialCount;

                allTrialCount = allTrialCount + trialCount;
                    
                for indNeuronType=1:length(NEURON_TYPES)
                    if strcmp(NEURON_TYPES{indNeuronType},NEURON_TYPE_OTHER)
                        indsNeurons = strcmp({units.neuronType},'');
                    else
                        indsNeurons = strcmp({units.neuronType},NEURON_TYPES{indNeuronType});
                    end
                    indsSingleUnits = [units.singleUnit];
                    unitsOfSpecType = units(indsNeurons & indsSingleUnits);
                    if ~isempty(unitsOfSpecType)
                        unitsOfSpecTypeForAllRec(indNeuronType) = {[unitsOfSpecTypeForAllRec{indNeuronType}, unitsOfSpecType]};                        
                        %%%%%%%%%%%%%%%%%%%% HOLD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        spikeRatesHoldRandomAll = {unitsOfSpecType.spikeRatesHoldRandomAll}';
                        spikeRatesHoldFixedAll = {unitsOfSpecType.spikeRatesHoldFixedAll}';
                        spikeRatesHoldRandomHFM = {unitsOfSpecType.spikeRatesHoldRandomHFM}';
                        spikeRatesHoldFixedHFM = {unitsOfSpecType.spikeRatesHoldFixedHFM}';  
                        
                        if ~isempty(spikeRatesHoldFixedAll)
                            plotPSTH_AllvsHFM(recordingDay, NEURON_TYPES{indNeuronType}, [hitFixedTrialCount, hitRandomTrialCount, faFixedTrialCount, faRandomTrialCount, missFixedTrialCount, missRandomTrialCount, trialCount], ...
                                spikeRatesHoldFixedAll, spikeRatesHoldRandomAll, spikeRatesHoldFixedHFM, spikeRatesHoldRandomHFM, ...
                                PRE_TIME_HOLD, POST_TIME_HOLD, EDGES_HOLD, 'Cue Prediction - Hold aligned', 'Cue Reaction - Hold aligned', 'holdAligned');
                        end
                        %%%%%%%%%%%%%%%%%%%% RELEASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        spikeRatesReleaseRandomAll = {unitsOfSpecType.spikeRatesReleaseRandomAll}';
                        spikeRatesReleaseFixedAll = {unitsOfSpecType.spikeRatesReleaseFixedAll}';
                        spikeRatesReleaseRandomHFM = {unitsOfSpecType.spikeRatesReleaseRandomHFM}';
                        spikeRatesReleaseFixedHFM = {unitsOfSpecType.spikeRatesReleaseFixedHFM}';  
                        if ~isempty(spikeRatesReleaseFixedAll)
                            plotPSTH_AllvsHFM(recordingDay, NEURON_TYPES{indNeuronType}, [hitFixedTrialCount, hitRandomTrialCount, faFixedTrialCount, faRandomTrialCount, missFixedTrialCount, missRandomTrialCount, trialCount], ...
                                spikeRatesReleaseFixedAll, spikeRatesReleaseRandomAll, spikeRatesReleaseFixedHFM, spikeRatesReleaseRandomHFM, ...
                                PRE_TIME_RELEASE, POST_TIME_RELEASE, EDGES_RELEASE, 'Cue Prediction - Release aligned', 'Cue Reaction - Release aligned', 'releaseAligned');
                        end
                        %%%%%%%%%%%%%%%%%%%% TARGET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        spikeRatesTargetRandomAll = {unitsOfSpecType.spikeRatesTargetRandomAll}';
                        spikeRatesTargetFixedAll = {unitsOfSpecType.spikeRatesTargetFixedAll}';
                        spikeRatesTargetRandomHFM = {unitsOfSpecType.spikeRatesTargetRandomHFM}';
                        spikeRatesTargetFixedHFM = {unitsOfSpecType.spikeRatesTargetFixedHFM}';  
                        if ~isempty(spikeRatesTargetFixedAll)
                            plotPSTH_AllvsHFM(recordingDay, NEURON_TYPES{indNeuronType}, [hitFixedTrialCount, hitRandomTrialCount, NaN, NaN, missFixedTrialCount, missRandomTrialCount, trialCount], ...
                                spikeRatesTargetFixedAll, spikeRatesTargetRandomAll, spikeRatesTargetFixedHFM, spikeRatesTargetRandomHFM, ...
                                PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM, EDGES_VIS_STIM, 'Cue Prediction - Target aligned', 'Cue Reaction - Target aligned', 'targetAligned');
                        end
                        close all;
                    end
                end
        end
    
        % Plot each unit type joined from all recordings
        for indNeuronType=1:length(NEURON_TYPES)        
            unitsOfSpecType = unitsOfSpecTypeForAllRec{indNeuronType};
            if ~isempty(unitsOfSpecType)
                %%%%%%%%%%%%%%%%%%%% HOLD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                spikeRatesHoldRandomAll = {unitsOfSpecType.spikeRatesHoldRandomAll}';
                spikeRatesHoldFixedAll = {unitsOfSpecType.spikeRatesHoldFixedAll}';
                spikeRatesHoldRandomHFM = {unitsOfSpecType.spikeRatesHoldRandomHFM}';
                spikeRatesHoldFixedHFM = {unitsOfSpecType.spikeRatesHoldFixedHFM}';  
                if ~isempty(spikeRatesHoldFixedAll)
                    plotPSTH_AllvsHFM('AllRec', NEURON_TYPES{indNeuronType}, [allHitFixedTrialCount, allHitRandomTrialCount, allFaFixedTrialCount, allFaRandomTrialCount, allMissFixedTrialCount, allMissRandomTrialCount, allTrialCount],...
                        spikeRatesHoldFixedAll, spikeRatesHoldRandomAll, spikeRatesHoldFixedHFM, spikeRatesHoldRandomHFM, ...
                        PRE_TIME_HOLD, POST_TIME_HOLD, EDGES_HOLD, 'Fixed - Hold aligned', 'Random - Hold aligned', 'holdAligned');
                end
                %%%%%%%%%%%%%%%%%%%% RELEASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                spikeRatesReleaseRandomAll = {unitsOfSpecType.spikeRatesReleaseRandomAll}';
                spikeRatesReleaseFixedAll = {unitsOfSpecType.spikeRatesReleaseFixedAll}';
                spikeRatesReleaseRandomHFM = {unitsOfSpecType.spikeRatesReleaseRandomHFM}';
                spikeRatesReleaseFixedHFM = {unitsOfSpecType.spikeRatesReleaseFixedHFM}';  
                if ~isempty(spikeRatesReleaseFixedAll)
                    plotPSTH_AllvsHFM('AllRec', NEURON_TYPES{indNeuronType}, [allHitFixedTrialCount, allHitRandomTrialCount, allFaFixedTrialCount, allFaRandomTrialCount, allMissFixedTrialCount, allMissRandomTrialCount, allTrialCount],...
                        spikeRatesReleaseFixedAll, spikeRatesReleaseRandomAll, spikeRatesReleaseFixedHFM, spikeRatesReleaseRandomHFM, ...
                        PRE_TIME_RELEASE, POST_TIME_RELEASE, EDGES_RELEASE, 'Cue Prediction - Release aligned', 'Cue Reaction - Release aligned', 'releaseAligned');
                end
                %%%%%%%%%%%%%%%%%%%% TARGET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                spikeRatesTargetRandomAll = {unitsOfSpecType.spikeRatesTargetRandomAll}';
                spikeRatesTargetFixedAll = {unitsOfSpecType.spikeRatesTargetFixedAll}';
                spikeRatesTargetRandomHFM = {unitsOfSpecType.spikeRatesTargetRandomHFM}';
                spikeRatesTargetFixedHFM = {unitsOfSpecType.spikeRatesTargetFixedHFM}';  
                if ~isempty(spikeRatesTargetFixedAll)
                    plotPSTH_AllvsHFM('AllRec', NEURON_TYPES{indNeuronType}, [allHitFixedTrialCount, allHitRandomTrialCount, NaN, NaN, allMissFixedTrialCount, allMissRandomTrialCount, allTrialCount],...
                        spikeRatesTargetFixedAll, spikeRatesTargetRandomAll, spikeRatesTargetFixedHFM, spikeRatesTargetRandomHFM, ...
                        PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM, EDGES_VIS_STIM, 'Cue Prediction - Target aligned', 'Cue Reaction - Target aligned', 'targetAligned');
                end
                close all;
            end
        end
    end
end