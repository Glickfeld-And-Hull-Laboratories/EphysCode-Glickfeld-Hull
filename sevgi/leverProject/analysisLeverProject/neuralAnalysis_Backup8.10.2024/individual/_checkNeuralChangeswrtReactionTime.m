function checkNeuralChangeswrtReactionTime(units, arrReactTimes, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, ...
    lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials)

        globals; 
        
        PRE_TIME_HOLD = .5;

        REACT_FAST_BAND = [-4000 750];
        REACT_SLOW_BAND = [1000 3000];
        WHOLE_TRIAL_DURATION = PRE_TIME_HOLD + 0.5 + 3; % Spike time range starting from PRE_HOLD + cue delay + max response time 

        allTrialCount = length(allTrials);
        %predTrialCount = length(allTrials)-fixedHoldStartsAtTrial+1;

        %arrReactTimes = arrReactTimes(fixedHoldStartsAtTrial:end);
        indFastInds = find(arrReactTimes>REACT_FAST_BAND(1) & arrReactTimes<REACT_FAST_BAND(2));        
        indFastInds = indFastInds(indFastInds>=fixedHoldStartsAtTrial); % get only prediction trials
        indSlowInds = find(arrReactTimes>REACT_SLOW_BAND(1) & arrReactTimes<REACT_SLOW_BAND(2));
        indSlowInds = indSlowInds(indSlowInds>=fixedHoldStartsAtTrial);

        spikeTimeFastReactofTrialAlignedToLeverReleaseAll = cell(1,length(NEURON_TYPES)+1);
        spikeTimeSlowReactofTrialAlignedToLeverReleaseAll = cell(1,length(NEURON_TYPES)+1);

        spikeTimeFastReactofTrialAlignedToLeverReleaseHit = cell(1,length(NEURON_TYPES)+1);
        spikeTimeSlowReactofTrialAlignedToLeverReleaseHit = cell(1,length(NEURON_TYPES)+1);
        
        spikeTimeFastReactAlignedToLeverReleaseHit = cell(1,length(NEURON_TYPES)+1);
        spikeTimeSlowReactAlignedToLeverReleaseHit = cell(1,length(NEURON_TYPES)+1);

        spikeTimeFastReactAlignedToTargetHit = cell(1,length(NEURON_TYPES)+1);
        spikeTimeSlowReactAlignedToTargetHit = cell(1,length(NEURON_TYPES)+1);

        for uid=1:length(units)
            unit = units(uid);            
            %[spikeTimeofTrialAlignedToLeverRelease, spikeTimeofTrialwITIAlignedToLeverRelease, predLeverHoldTimesAlignedToLeverRelease]= chunkAlignSpikeTimesOfWholeTrial(unit.spikeTimesSecs, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, predTrialCount, allTrialCount);

            [spikeTimeAlignedToLeverHoldAll, spikeTimeAlignedToLeverReleaseAll, spikeTimeAlignedToTargetVisStimAll, spikeTimeAlignedToBaselineVisStimAll, ...
            spikeTimeofTrialAlignedToLeverReleaseAll, spikeTimeofTrialwITIAlignedToLeverReleaseAll, leverHoldTimesAlignedToLeverReleaseAll,...
            leverHoldTimesAlignedToTargetVisStimAll, leverReleaseTimesAlignedToTargetVisStimAll, leverReleaseTimesAlignedToBaselineVisStimAll, targetVisStimAlignedToLeverHoldAll, targetVisStimAlignedToLeverReleaseAll, ...
            baselineVisStimAlignedToLeverReleaseAll, fixedHoldStartsAtRelativeTrialAll, allTrialCount] = chunkAlignSpikeTimes(unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials);
        
            [spikeTimeAlignedToLeverHoldHit, spikeTimeAlignedToLeverReleaseHit, spikeTimeAlignedToTargetVisStimHit, spikeTimeAlignedToBaselineVisStimHit, ...
            spikeTimeofTrialAlignedToLeverReleaseHit, spikeTimeofTrialwITIAlignedToLeverReleaseHit, leverHoldTimesAlignedToLeverReleaseHit,...
            leverHoldTimesAlignedToTargetVisStimHit, leverReleaseTimesAlignedToTargetVisStimHit, leverReleaseTimesAlignedToBaselineVisStimHit, targetVisStimAlignedToLeverHoldHit, targetVisStimAlignedToLeverReleaseHit, ...
            baselineVisStimAlignedToLeverReleaseHit, fixedHoldStartsAtRelativeTrialHit, ~] = chunkAlignSpikeTimes(unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrHitTrials);
                    
            indx = find(ismember(NEURON_TYPES,unit.neuronType));
            if isempty(indx) % means Unknown cell type
                indx = length(NEURON_TYPES)+1;
            end

            fastReactSpikesofTrial = spikeTimeofTrialAlignedToLeverReleaseAll(indFastInds);
            slowReactSpikesofTrial = spikeTimeofTrialAlignedToLeverReleaseAll(indSlowInds);
            fastReactSpikesHitofTrial = spikeTimeofTrialAlignedToLeverReleaseHit(indFastInds); % whole trial
            slowReactSpikesHitofTrial = spikeTimeofTrialAlignedToLeverReleaseHit(indSlowInds);

            [~,indFastHitInds] = ismember(indFastInds, arrHitTrials);
            indFastHitInds = indFastHitInds(indFastHitInds~=0);
            fastReactSpikesHitofRelease = spikeTimeAlignedToLeverReleaseHit(indFastHitInds); % around release
            fastReactSpikesHitofTarget = spikeTimeAlignedToTargetVisStimHit(indFastHitInds); % around cue
            [~,indSlowHitInds] = ismember(indSlowInds, arrHitTrials);
            indSlowHitInds = indSlowHitInds(indSlowHitInds~=0);
            slowReactSpikesHitofRelease = spikeTimeAlignedToLeverReleaseHit(indSlowHitInds);
            slowReactSpikesHitofTarget = spikeTimeAlignedToTargetVisStimHit(indSlowHitInds); % around cue
            
            spikeTimeFastReactofTrialAlignedToLeverReleaseAll{indx} = appendCellArrayofCellArrays(spikeTimeFastReactofTrialAlignedToLeverReleaseAll{indx}, fastReactSpikesofTrial);
            spikeTimeSlowReactofTrialAlignedToLeverReleaseAll{indx} = appendCellArrayofCellArrays(spikeTimeSlowReactofTrialAlignedToLeverReleaseAll{indx}, slowReactSpikesofTrial);
            spikeTimeFastReactofTrialAlignedToLeverReleaseHit{indx} = appendCellArrayofCellArrays(spikeTimeFastReactofTrialAlignedToLeverReleaseHit{indx}, fastReactSpikesHitofTrial);
            spikeTimeSlowReactofTrialAlignedToLeverReleaseHit{indx} = appendCellArrayofCellArrays(spikeTimeSlowReactofTrialAlignedToLeverReleaseHit{indx}, slowReactSpikesHitofTrial);

            % Around Release
            spikeTimeFastReactAlignedToLeverReleaseHit{indx} = appendCellArrayofCellArrays(spikeTimeFastReactAlignedToLeverReleaseHit{indx}, fastReactSpikesHitofRelease);
            spikeTimeSlowReactAlignedToLeverReleaseHit{indx} = appendCellArrayofCellArrays(spikeTimeSlowReactAlignedToLeverReleaseHit{indx}, slowReactSpikesHitofRelease);

            % Around Cue (Target)
            spikeTimeFastReactAlignedToTargetHit{indx} = appendCellArrayofCellArrays(spikeTimeFastReactAlignedToTargetHit{indx}, fastReactSpikesHitofTarget);
            spikeTimeSlowReactAlignedToTargetHit{indx} = appendCellArrayofCellArrays(spikeTimeSlowReactAlignedToTargetHit{indx}, slowReactSpikesHitofTarget);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL TRIALS - WHOLE TRIAL DURATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        slowLeverHoldTimes = leverHoldTimesAlignedToLeverReleaseAll(indSlowInds);
        fastLeverHoldTimes = leverHoldTimesAlignedToLeverReleaseAll(indFastInds);                
        
        slowMinVal = mean(slowLeverHoldTimes)-std(slowLeverHoldTimes)/sqrt(length(slowLeverHoldTimes)); % std err
        slowMaxVal = mean(slowLeverHoldTimes)+std(slowLeverHoldTimes)/sqrt(length(slowLeverHoldTimes));

        fastMinVal = mean(fastLeverHoldTimes)-std(fastLeverHoldTimes)/sqrt(length(fastLeverHoldTimes)); % std err
        fastMaxVal = mean(fastLeverHoldTimes)+std(fastLeverHoldTimes)/sqrt(length(fastLeverHoldTimes));
        sTitle = 'Whole trial duration around release - hold times marked with vertical bars';
        sFileName = '_psth_FastvsSlowReactTimePSTH_WholeTrial.tif';
        plotPSTHwrtReactionTimes(spikeTimeFastReactofTrialAlignedToLeverReleaseAll, spikeTimeSlowReactofTrialAlignedToLeverReleaseAll, ...
            [mean(fastLeverHoldTimes) fastMinVal fastMaxVal], [mean(slowLeverHoldTimes) slowMinVal slowMaxVal], sTitle, sFileName, length(indFastInds), length(indSlowInds), WHOLE_TRIAL_DURATION, POST_TIME_RELEASE);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HIT TRIALS - WHOLE TRIAL DURATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        indSlowHitInds = intersect(indSlowInds, arrHitTrials);
        slowLeverHoldTimes = leverHoldTimesAlignedToLeverReleaseHit(indSlowHitInds);
        indFastHitInds = intersect(indFastInds, arrHitTrials);
        fastLeverHoldTimes = leverHoldTimesAlignedToLeverReleaseHit(indFastHitInds);                
        
        slowMinVal = mean(slowLeverHoldTimes)-std(slowLeverHoldTimes)/sqrt(length(slowLeverHoldTimes)); % std err
        slowMaxVal = mean(slowLeverHoldTimes)+std(slowLeverHoldTimes)/sqrt(length(slowLeverHoldTimes));

        fastMinVal = mean(fastLeverHoldTimes)-std(fastLeverHoldTimes)/sqrt(length(fastLeverHoldTimes)); % std err
        fastMaxVal = mean(fastLeverHoldTimes)+std(fastLeverHoldTimes)/sqrt(length(fastLeverHoldTimes));
        sTitle = 'HITS Whole trial duration around release - hold times marked with vertical bars';
        sFileName = '_psth_FastvsSlowReactTimePSTH_Hits_WholeTrial.tif';
        plotPSTHwrtReactionTimes(spikeTimeFastReactofTrialAlignedToLeverReleaseHit, spikeTimeSlowReactofTrialAlignedToLeverReleaseHit, ...
            [mean(fastLeverHoldTimes) fastMinVal fastMaxVal], [mean(slowLeverHoldTimes) slowMinVal slowMaxVal], sTitle, sFileName, length(indFastHitInds), length(indSlowHitInds), WHOLE_TRIAL_DURATION, POST_TIME_RELEASE);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HIT TRIALS AROUND RELEASE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [~,indSlowHitInds] = ismember(indSlowInds, arrHitTrials);
        indSlowHitInds = indSlowHitInds(indSlowHitInds~=0);
        slowCueTimes = targetVisStimAlignedToLeverReleaseHit(indSlowHitInds);
        arrSlowCueTimes = cell2mat(slowCueTimes);

        [~,indFastHitInds] = ismember(indFastInds, arrHitTrials);
        indFastHitInds = indFastHitInds(indFastHitInds~=0);
        % TODO: Check indices of targetVisStimAlignedToLeverReleaseHit
        % array if it really is based on all-trial indices or just hit
        % trials cos indFastHitInds based on all-trial indices
        fastCueTimes = targetVisStimAlignedToLeverReleaseHit(indFastHitInds);
        arrFastCueTimes = cell2mat(fastCueTimes);

        slowMinVal = mean(arrSlowCueTimes)-std(arrSlowCueTimes)/sqrt(length(arrSlowCueTimes)); % std err
        slowMaxVal = mean(arrSlowCueTimes)+std(arrSlowCueTimes)/sqrt(length(arrSlowCueTimes));

        fastMinVal = mean(arrFastCueTimes)-std(arrFastCueTimes)/sqrt(length(arrFastCueTimes)); % std err
        fastMaxVal = mean(arrFastCueTimes)+std(arrFastCueTimes)/sqrt(length(arrFastCueTimes));

        sTitle = 'HITS around release - cue times marked with vertical bars';
        sFileName = '_psth_FastvsSlowReactTimePSTH_Hits_Release.tif';
        plotPSTHwrtReactionTimes(spikeTimeFastReactAlignedToLeverReleaseHit, spikeTimeSlowReactAlignedToLeverReleaseHit, ...
            [mean(arrFastCueTimes) fastMinVal fastMaxVal], [mean(arrSlowCueTimes) slowMinVal slowMaxVal], sTitle, sFileName, length(indFastHitInds), length(indSlowHitInds), PRE_TIME_RELEASE, POST_TIME_RELEASE);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HIT TRIALS AROUND CUE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        [~,indSlowHitInds] = ismember(indSlowInds, arrHitTrials);
        indSlowHitInds = indSlowHitInds(indSlowHitInds~=0);
        slowReleaseTimes = leverReleaseTimesAlignedToTargetVisStimHit(indSlowHitInds);
        arrSlowReleaseTimes = cell2mat(slowReleaseTimes);

        [~,indFastHitInds] = ismember(indFastInds, arrHitTrials);
        indFastHitInds = indFastHitInds(indFastHitInds~=0);
        fastReleaseTimes = leverReleaseTimesAlignedToTargetVisStimHit(indFastHitInds);
        arrFastReleaseTimes = cell2mat(fastReleaseTimes);

        slowMinVal = mean(arrSlowReleaseTimes)-std(arrSlowReleaseTimes)/sqrt(length(arrSlowReleaseTimes)); % std err
        slowMaxVal = mean(arrSlowReleaseTimes)+std(arrSlowReleaseTimes)/sqrt(length(arrSlowReleaseTimes));

        fastMinVal = mean(arrFastReleaseTimes)-std(arrFastReleaseTimes)/sqrt(length(arrFastReleaseTimes)); % std err
        fastMaxVal = mean(arrFastReleaseTimes)+std(arrFastReleaseTimes)/sqrt(length(arrFastReleaseTimes));

        sTitle = 'HITS around cue - release times marked with vertical bars';
        sFileName = '_psth_FastvsSlowReactTimePSTH_Hits_Cue.tif';
        plotPSTHwrtReactionTimes(spikeTimeFastReactAlignedToTargetHit, spikeTimeSlowReactAlignedToTargetHit, ...
            [mean(arrFastReleaseTimes) fastMinVal fastMaxVal], [mean(arrSlowReleaseTimes) slowMinVal slowMaxVal], sTitle, sFileName, length(indFastHitInds), length(indSlowHitInds), PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM);

end