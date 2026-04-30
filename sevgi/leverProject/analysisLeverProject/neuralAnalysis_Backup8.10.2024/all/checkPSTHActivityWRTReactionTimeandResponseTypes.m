function checkPSTHActivityWRTReactionTimeandResponseTypes(arrRecordings)

    globalsAll;
    
    if RECORDING_DAY_OF_INTEREST == -1 % Plot all days of recordings
       
        allFastReactSpikeTimeReleaseHitInc = cell(1,length(NEURON_TYPES));
        allSlowReactSpikeTimeReleaseHitInc = cell(1,length(NEURON_TYPES));
        allFastReactSpikeTimeReleaseHitDec = cell(1,length(NEURON_TYPES));
        allSlowReactSpikeTimeReleaseHitDec = cell(1,length(NEURON_TYPES));

        allFastReactSpikeTimeTargetHitInc = cell(1,length(NEURON_TYPES));
        allSlowReactSpikeTimeTargetHitInc = cell(1,length(NEURON_TYPES));
        allFastReactSpikeTimeTargetHitDec = cell(1,length(NEURON_TYPES));
        allSlowReactSpikeTimeTargetHitDec = cell(1,length(NEURON_TYPES));

        nTotalFastHitTrialCount = 0;
        nTotalSlowHitTrialCount = 0;

        totalArrFastReleaseTimes = [];
        totalArrSlowReleaseTimes = [];

        totalArrFastCueTimes = [];
        totalArrSlowCueTimes = [];

        for indRec = 1:length(arrRecordings)
               
                currentRecording = arrRecordings{1,indRec};
                indices = strfind(currentRecording.name,'_');
                recordingDay = extractBetween(currentRecording.name, indices(1)+1, indices(3)-1);
                recordingDay = recordingDay{:};
                units = currentRecording.unitGood;                

                newHitInds = find(currentRecording.arrHitTrials>=currentRecording.fixedHoldStartsAtTrial);
                newHitTrials = currentRecording.arrHitTrials(newHitInds);
                hitReactionTimes = currentRecording.arrReactTimes(newHitTrials);
                indFastTemp = find(hitReactionTimes<median(hitReactionTimes));
                indSlowTemp = find(hitReactionTimes>=median(hitReactionTimes));
                logger.info('checkPSTHActivityWRTReactionTimeandResponseTypes', ['Median RT : ' num2str(median(hitReactionTimes)) ' for recording day : ' recordingDay]);
                indFastInds = newHitTrials(indFastTemp);
                indSlowInds = newHitTrials(indSlowTemp);

                [~,indFastHitInds] = ismember(indFastInds, currentRecording.arrHitTrials);
                indFastHitInds = indFastHitInds(indFastHitInds~=0);
                [~,indSlowHitInds] = ismember(indSlowInds, currentRecording.arrHitTrials);
                indSlowHitInds = indSlowHitInds(indSlowHitInds~=0);

                %%%%%%%%%%%%%%%%%% PREPARE FOR THE RELATIVE EVENTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [~,indFastHitsInStimOns] = ismember(currentRecording.arrHitTrials(indFastHitInds), currentRecording.arrStimTurnedOnTrials);
                indFastHitsInStimOns = indFastHitsInStimOns(indFastHitsInStimOns~=0);

                [~,indSlowHitsInStimOns] = ismember(currentRecording.arrHitTrials(indSlowHitInds), currentRecording.arrStimTurnedOnTrials);
                indSlowHitsInStimOns = indSlowHitsInStimOns(indSlowHitsInStimOns~=0);

                %%%%%%%%%%%%%%%%%% HIT TRIALS AROUND CUE     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Get behaviorally relevant event times - CUE TIME BEFORE RELEASE
                arrFastReleaseTimes = currentRecording.leverReleaseTimesGLX(currentRecording.arrHitTrials(indFastHitInds)) - currentRecording.targetStimTimesGLX(indFastHitsInStimOns);                    
                arrSlowReleaseTimes = currentRecording.leverReleaseTimesGLX(currentRecording.arrHitTrials(indSlowHitInds)) - currentRecording.targetStimTimesGLX(indSlowHitsInStimOns);

                %%%%%%%%%%%%%%%%%% HIT TRIALS AROUND RELEASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Get behaviorally relevant event times - CUE TIME BEFORE RELEASE
                arrFastCueTimes = currentRecording.targetStimTimesGLX(indFastHitsInStimOns)-currentRecording.leverReleaseTimesGLX(currentRecording.arrHitTrials(indFastHitInds));
                arrSlowCueTimes = currentRecording.targetStimTimesGLX(indSlowHitsInStimOns)-currentRecording.leverReleaseTimesGLX(currentRecording.arrHitTrials(indSlowHitInds));
                    
                for indNeuronType=1:length(NEURON_TYPES)
                        if strcmp(NEURON_TYPES{indNeuronType},NEURON_TYPE_OTHER)
                            indsNeurons = strcmp({units.neuronType},'');
                        else
                            indsNeurons = strcmp({units.neuronType},NEURON_TYPES{indNeuronType});
                        end
                        indsSingleUnits = [units.singleUnit];
                        unitsOfSpecType = units(indsNeurons & indsSingleUnits); 

                        if ~isempty(unitsOfSpecType)
                                                        
                            responseTypeTargetFixedHFM = {unitsOfSpecType.responseTypeTargetFixedHFM}';
                            arrResponseTypeTargetFixedHFM = cell2mat(responseTypeTargetFixedHFM);
                                                                                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HIT TRIALS AROUND TARGET  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                            
                            %%%%%%%%%%%% INCREASING %%%%%%%%%%%%%%
                            indsInc = arrResponseTypeTargetFixedHFM(:,1)==RESPONSE_INCREASING; % select only hit trial response type
                            if any(indsInc)
                                spikeTimeTargetHitInc = {unitsOfSpecType(indsInc).spikeTimeTargetHit}';
                                fastReactSpikeTimeTargetHitInc = cellfun(@(fullCell) fullCell(:,indFastHitInds), spikeTimeTargetHitInc, 'UniformOutput',0); % around cue
                                slowReactSpikeTimeTargetHitInc = cellfun(@(fullCell) fullCell(:,indSlowHitInds), spikeTimeTargetHitInc, 'UniformOutput',0);
    
                                % Collect it to PSTH for all recordings
                                allFastReactSpikeTimeTargetHitInc{indNeuronType} = appendCellArrayofCellArrays(allFastReactSpikeTimeTargetHitInc{indNeuronType}, fastReactSpikeTimeTargetHitInc);
                                allSlowReactSpikeTimeTargetHitInc{indNeuronType} = appendCellArrayofCellArrays(allSlowReactSpikeTimeTargetHitInc{indNeuronType}, slowReactSpikeTimeTargetHitInc);                            
                                
                                sTitle = [recordingDay ' HITS around CUE (release times marked with vertical bars) Facilitated activity'];
                                sFileName = [recordingDay '_psth_FastvsSlowReactTimePSTH_Hits_Target_Inc.tif'];
                                prePlotPSTHwrtReactionTimes(NEURON_TYPES{indNeuronType}, fastReactSpikeTimeTargetHitInc, slowReactSpikeTimeTargetHitInc, ...
                                    arrFastReleaseTimes, arrSlowReleaseTimes, sTitle, sFileName, length(indFastHitInds), length(indSlowHitInds), PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM);
                            end
                            %%%%%%%%%%%% DECREASING %%%%%%%%%%%%%%
                            indsDec = arrResponseTypeTargetFixedHFM(:,1)==RESPONSE_DECREASING; % select only hit trial response type
                            if any(indsDec)
                                spikeTimeTargetHitDec = {unitsOfSpecType(indsDec).spikeTimeTargetHit}';
                                fastReactSpikeTimeTargetHitDec = cellfun(@(fullCell) fullCell(:,indFastHitInds), spikeTimeTargetHitDec, 'UniformOutput',0); % around cue
                                slowReactSpikeTimeTargetHitDec = cellfun(@(fullCell) fullCell(:,indSlowHitInds), spikeTimeTargetHitDec, 'UniformOutput',0);
    
                                % Collect it to PSTH for all recordings
                                allFastReactSpikeTimeTargetHitDec{indNeuronType} = appendCellArrayofCellArrays(allFastReactSpikeTimeTargetHitDec{indNeuronType}, fastReactSpikeTimeTargetHitDec);
                                allSlowReactSpikeTimeTargetHitDec{indNeuronType} = appendCellArrayofCellArrays(allSlowReactSpikeTimeTargetHitDec{indNeuronType}, slowReactSpikeTimeTargetHitDec);                            
                                
                                sTitle = [recordingDay ' HITS around CUE (release times marked with vertical bars) Suppressed activity'];
                                sFileName = [recordingDay '_psth_FastvsSlowReactTimePSTH_Hits_Target_Dec.tif'];
                                prePlotPSTHwrtReactionTimes(NEURON_TYPES{indNeuronType}, fastReactSpikeTimeTargetHitDec, slowReactSpikeTimeTargetHitDec, ...
                                    arrFastReleaseTimes, arrSlowReleaseTimes, sTitle, sFileName, length(indFastHitInds), length(indSlowHitInds), PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM);
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                            responseTypeReleaseFixedHFM = {unitsOfSpecType.responseTypeReleaseFixedHFM}';
                            arrResponseTypeReleaseFixedHFM = cell2mat(responseTypeReleaseFixedHFM);                                
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HIT TRIALS AROUND RELEASE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            %%%%%%%%%%%% INCREASING %%%%%%%%%%%%%%
                            indsInc = arrResponseTypeReleaseFixedHFM(:,1)==RESPONSE_INCREASING; % select only hit trial response type                                
                            if any(indsInc)
                                spikeTimeReleaseHitInc = {unitsOfSpecType(indsInc).spikeTimeReleaseHit}';
                                fastReactSpikeTimeReleaseHitInc = cellfun(@(fullCell) fullCell(:,indFastHitInds), spikeTimeReleaseHitInc, 'UniformOutput',0); % around release
                                slowReactSpikeTimeReleaseHitInc = cellfun(@(fullCell) fullCell(:,indSlowHitInds), spikeTimeReleaseHitInc, 'UniformOutput',0);                            
    
                                % Collect it to PSTH for all recordings
                                allFastReactSpikeTimeReleaseHitInc{indNeuronType} = appendCellArrayofCellArrays(allFastReactSpikeTimeReleaseHitInc{indNeuronType}, fastReactSpikeTimeReleaseHitInc);
                                allSlowReactSpikeTimeReleaseHitInc{indNeuronType} = appendCellArrayofCellArrays(allSlowReactSpikeTimeReleaseHitInc{indNeuronType}, slowReactSpikeTimeReleaseHitInc);                            
                                
                                sTitle = [recordingDay ' HITS around RELEASE (cue times marked with vertical bars) Facilitated activity'];
                                sFileName = [recordingDay '_psth_FastvsSlowReactTimePSTH_Hits_Release_Inc.tif'];
                                prePlotPSTHwrtReactionTimes(NEURON_TYPES{indNeuronType}, fastReactSpikeTimeReleaseHitInc, slowReactSpikeTimeReleaseHitInc, ...
                                    arrFastCueTimes, arrSlowCueTimes, sTitle, sFileName, length(indFastHitInds), length(indSlowHitInds), PRE_TIME_RELEASE, POST_TIME_RELEASE);
                            end
                            %%%%%%%%%%%% DECREASING %%%%%%%%%%%%%%
                            indsDec = arrResponseTypeReleaseFixedHFM(:,1)==RESPONSE_DECREASING; % select only hit trial response type
                            if any(indsDec)
                                spikeTimeReleaseHitDec = {unitsOfSpecType(indsDec).spikeTimeReleaseHit}';
                                fastReactSpikeTimeReleaseHitDec = cellfun(@(fullCell) fullCell(:,indFastHitInds), spikeTimeReleaseHitDec, 'UniformOutput',0); % around release
                                slowReactSpikeTimeReleaseHitDec = cellfun(@(fullCell) fullCell(:,indSlowHitInds), spikeTimeReleaseHitDec, 'UniformOutput',0);                            
    
                                % Collect it to PSTH for all recordings
                                allFastReactSpikeTimeReleaseHitDec{indNeuronType} = appendCellArrayofCellArrays(allFastReactSpikeTimeReleaseHitDec{indNeuronType}, fastReactSpikeTimeReleaseHitDec);
                                allSlowReactSpikeTimeReleaseHitDec{indNeuronType} = appendCellArrayofCellArrays(allSlowReactSpikeTimeReleaseHitDec{indNeuronType}, slowReactSpikeTimeReleaseHitDec);                            
                                
                                sTitle = [recordingDay ' HITS around RELEASE (cue times marked with vertical bars) Suppressed activity'];
                                sFileName = [recordingDay '_psth_FastvsSlowReactTimePSTH_Hits_Release_Dec.tif'];
                                prePlotPSTHwrtReactionTimes(NEURON_TYPES{indNeuronType}, fastReactSpikeTimeReleaseHitDec, slowReactSpikeTimeReleaseHitDec, ...
                                    arrFastCueTimes, arrSlowCueTimes, sTitle, sFileName, length(indFastHitInds), length(indSlowHitInds), PRE_TIME_RELEASE, POST_TIME_RELEASE);
                            end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        end
                end 

                totalArrFastReleaseTimes = [totalArrFastReleaseTimes arrFastReleaseTimes];
                totalArrSlowReleaseTimes = [totalArrSlowReleaseTimes arrSlowReleaseTimes];

                totalArrFastCueTimes = [totalArrFastCueTimes arrFastCueTimes];
                totalArrSlowCueTimes = [totalArrSlowCueTimes arrSlowCueTimes];

                nTotalFastHitTrialCount = nTotalFastHitTrialCount + length(indFastHitInds);
                nTotalSlowHitTrialCount = nTotalSlowHitTrialCount + length(indSlowHitInds);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HIT TRIALS AROUND TARGET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Plot all cells' recordings
        % INCREASING
        sTitle = ['HITS around CUE (release times marked with vertical bars) Facilitated activity'];
        sFileName = ['psth_FastvsSlowReactTimePSTH_Hits_Target_Inc.tif'];
        prePlotPSTHwrtReactionTimes([], allFastReactSpikeTimeTargetHitInc, allSlowReactSpikeTimeTargetHitInc, ...
            totalArrFastReleaseTimes, totalArrSlowReleaseTimes, sTitle, sFileName, nTotalFastHitTrialCount, nTotalSlowHitTrialCount, PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM);

        % DECREASING
        sTitle = ['HITS around CUE (release times marked with vertical bars) Suppressed activity'];
        sFileName = ['psth_FastvsSlowReactTimePSTH_Hits_Target_Dec.tif'];
        prePlotPSTHwrtReactionTimes([], allFastReactSpikeTimeTargetHitDec, allSlowReactSpikeTimeTargetHitDec, ...
            totalArrFastReleaseTimes, totalArrSlowReleaseTimes, sTitle, sFileName, nTotalFastHitTrialCount, nTotalSlowHitTrialCount, PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM);
         
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HIT TRIALS AROUND RELEASE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Plot all cells' recordings
        % INCREASING
        sTitle = ['HITS around RELEASE (cue times marked with vertical bars) Facilitated activity'];
        sFileName = ['psth_FastvsSlowReactTimePSTH_Hits_Release_Inc.tif'];
        prePlotPSTHwrtReactionTimes([], allFastReactSpikeTimeReleaseHitInc, allSlowReactSpikeTimeReleaseHitInc, ...
            totalArrFastCueTimes, totalArrSlowCueTimes, sTitle, sFileName, nTotalFastHitTrialCount, nTotalSlowHitTrialCount, PRE_TIME_RELEASE, POST_TIME_RELEASE);

        % DECREASING
        sTitle = ['HITS around RELEASE (cue times marked with vertical bars) Suppressed activity'];
        sFileName = ['psth_FastvsSlowReactTimePSTH_Hits_Release_Dec.tif'];
        prePlotPSTHwrtReactionTimes([], allFastReactSpikeTimeReleaseHitDec, allSlowReactSpikeTimeReleaseHitDec, ...
            totalArrFastCueTimes, totalArrSlowCueTimes, sTitle, sFileName, nTotalFastHitTrialCount, nTotalSlowHitTrialCount, PRE_TIME_RELEASE, POST_TIME_RELEASE);

    end    
end