function checkPSTHActivityWRTReactionTime(arrRecordings)

    globalsAll;
    REACT_FAST_BAND = [-4000 750];
    REACT_SLOW_BAND = [1000 3000];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3rd STEP of ANALYSES :  Plot raster & PSTH (Qualitative) %%%%%%%%%%%%%%%%%%%%
    if ismember(ANALYSIS_STEP_3,ARR_DO_ANALYSES) 
        if RECORDING_DAY_OF_INTEREST == -1 % Plot all days of recordings
            allTrialCount = 0;
         
            allFastReactSpikeTimeReleaseHit = cell(1,length(NEURON_TYPES));
            allSlowReactSpikeTimeReleaseHit = cell(1,length(NEURON_TYPES));

            allFastReactSpikeTimeTargetHit = cell(1,length(NEURON_TYPES));
            allSlowReactSpikeTimeTargetHit = cell(1,length(NEURON_TYPES));

            nTotalFastHitTrialCount = 0;
            nTotalSlowHitTrialCount = 0;
            %unitsOfSpecTypeForAllRec = cell(length(NEURON_TYPES),1); %struct([]);

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

                    indFastInds = find(currentRecording.arrReactTimes>REACT_FAST_BAND(1) & currentRecording.arrReactTimes<REACT_FAST_BAND(2));        
                    indFastInds = indFastInds(indFastInds>=currentRecording.fixedHoldStartsAtTrial); % get only prediction trials
                    indSlowInds = find(currentRecording.arrReactTimes>REACT_SLOW_BAND(1) & currentRecording.arrReactTimes<REACT_SLOW_BAND(2));
                    indSlowInds = indSlowInds(indSlowInds>=currentRecording.fixedHoldStartsAtTrial);

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
%                     targetVisStimAlignedToLeverReleaseHit = currentRecording.targetStimTimesGLX-currentRecording.leverReleaseTimesGLX(currentRecording.arrStimTurnedOnTrials);                    
%                     arrFastCueTimes = targetVisStimAlignedToLeverReleaseHit(indFastHitsInStimOns);
%                     arrSlowCueTimes = targetVisStimAlignedToLeverReleaseHit(indSlowHitsInStimOns);

                    arrFastCueTimes = currentRecording.targetStimTimesGLX(indFastHitsInStimOns)-currentRecording.leverReleaseTimesGLX(currentRecording.arrHitTrials(indFastHitInds));
                    arrSlowCueTimes = currentRecording.targetStimTimesGLX(indSlowHitsInStimOns)-currentRecording.leverReleaseTimesGLX(currentRecording.arrHitTrials(indSlowHitInds));
                        
                    for indNeuronType=1:length(NEURON_TYPES)
                            if strcmp(NEURON_TYPES{indNeuronType},NEURON_TYPE_UNKNOWN)
                                indsNeurons = strcmp({units.expertLabel},'');
                            else
                                indsNeurons = strcmp({units.expertLabel},NEURON_TYPES{indNeuronType});
                            end
                            unitsOfSpecType = units(indsNeurons);                         
                            %unitsOfSpecTypeForAllRec(indNeuronType) = {[unitsOfSpecTypeForAllRec{indNeuronType}, unitsOfSpecType]};                        
                            
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HIT TRIALS AROUND TARGET  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                            
                            spikeTimeTargetHit = {unitsOfSpecType.spikeTimeTargetHit}';
                            fastReactSpikeTimeTargetHit = cellfun(@(fullCell) fullCell(:,indFastHitInds), spikeTimeTargetHit, 'UniformOutput',0); % around cue
                            slowReactSpikeTimeTargetHit = cellfun(@(fullCell) fullCell(:,indSlowHitInds), spikeTimeTargetHit, 'UniformOutput',0);

                            % Collect it to PSTH for all recordings
                            allFastReactSpikeTimeTargetHit{indNeuronType} = appendCellArrayofCellArrays(allFastReactSpikeTimeTargetHit{indNeuronType}, fastReactSpikeTimeTargetHit);
                            allSlowReactSpikeTimeTargetHit{indNeuronType} = appendCellArrayofCellArrays(allSlowReactSpikeTimeTargetHit{indNeuronType}, slowReactSpikeTimeTargetHit);                            
                            
                            sTitle = [recordingDay ' HITS around cue - release times marked with vertical bars'];
                            sFileName = [recordingDay '_psth_FastvsSlowReactTimePSTH_Hits_Target.tif'];
                            prePlotPSTHwrtReactionTimes(NEURON_TYPES{indNeuronType}, fastReactSpikeTimeTargetHit, slowReactSpikeTimeTargetHit, ...
                                arrFastReleaseTimes, arrSlowReleaseTimes, sTitle, sFileName, length(indFastHitInds), length(indSlowHitInds), PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM);
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HIT TRIALS AROUND RELEASE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            spikeTimeReleaseHit = {unitsOfSpecType.spikeTimeReleaseHit}';
                            fastReactSpikeTimeReleaseHit = cellfun(@(fullCell) fullCell(:,indFastHitInds), spikeTimeReleaseHit, 'UniformOutput',0); % around release
                            slowReactSpikeTimeReleaseHit = cellfun(@(fullCell) fullCell(:,indSlowHitInds), spikeTimeReleaseHit, 'UniformOutput',0);                            

                            % Collect it to PSTH for all recordings
                            allFastReactSpikeTimeReleaseHit{indNeuronType} = appendCellArrayofCellArrays(allFastReactSpikeTimeReleaseHit{indNeuronType}, fastReactSpikeTimeReleaseHit);
                            allSlowReactSpikeTimeReleaseHit{indNeuronType} = appendCellArrayofCellArrays(allSlowReactSpikeTimeReleaseHit{indNeuronType}, slowReactSpikeTimeReleaseHit);                            
                            
                            sTitle = [recordingDay ' HITS around release - cue times marked with vertical bars'];
                            sFileName = [recordingDay '_psth_FastvsSlowReactTimePSTH_Hits_Release.tif'];
                            prePlotPSTHwrtReactionTimes(NEURON_TYPES{indNeuronType}, fastReactSpikeTimeReleaseHit, slowReactSpikeTimeReleaseHit, ...
                                arrFastCueTimes, arrSlowCueTimes, sTitle, sFileName, length(indFastHitInds), length(indSlowHitInds), PRE_TIME_RELEASE, POST_TIME_RELEASE);
                            
                    end 

                    totalArrFastReleaseTimes = [totalArrFastReleaseTimes arrFastReleaseTimes];
                    totalArrSlowReleaseTimes = [totalArrSlowReleaseTimes arrSlowReleaseTimes];

                    totalArrFastCueTimes = [totalArrFastCueTimes arrFastCueTimes];
                    totalArrSlowCueTimes = [totalArrSlowCueTimes arrSlowCueTimes];

                    nTotalFastHitTrialCount = nTotalFastHitTrialCount + length(indFastHitInds);
                    nTotalSlowHitTrialCount = nTotalSlowHitTrialCount + length(indSlowHitInds);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HIT TRIALS AROUND TARGET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Plot all recordings
            sTitle = ['HITS around cue - release times marked with vertical bars'];
            sFileName = ['psth_FastvsSlowReactTimePSTH_Hits_Target.tif'];
            prePlotPSTHwrtReactionTimes([], allFastReactSpikeTimeTargetHit, allSlowReactSpikeTimeTargetHit, ...
                totalArrFastReleaseTimes, totalArrSlowReleaseTimes, sTitle, sFileName, nTotalFastHitTrialCount, nTotalSlowHitTrialCount, PRE_TIME_RELEASE, POST_TIME_RELEASE);
             
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HIT TRIALS AROUND RELEASE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Plot all recordings
            sTitle = ['HITS around release - cue times marked with vertical bars'];
            sFileName = ['psth_FastvsSlowReactTimePSTH_Hits_Release.tif'];
            prePlotPSTHwrtReactionTimes([], allFastReactSpikeTimeReleaseHit, allSlowReactSpikeTimeReleaseHit, ...
                totalArrFastCueTimes, totalArrSlowCueTimes, sTitle, sFileName, nTotalFastHitTrialCount, nTotalSlowHitTrialCount, PRE_TIME_RELEASE, POST_TIME_RELEASE);

        end
    end
end