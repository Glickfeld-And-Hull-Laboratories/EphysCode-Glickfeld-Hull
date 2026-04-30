function [spikeTimeAlignedToLeverHold, spikeTimeAlignedToLeverRelease, spikeTimeAlignedToTargetVisStim, spikeTimeAlignedToBaselineVisStim, spikeTimeofTrialAlignedToLeverRelease, spikeTimeofTrialwITIAlignedToLeverRelease, leverHoldTimesAlignedToLeverRelease, ...
    leverHoldTimesAlignedToTargetVisStim, leverReleaseTimesAlignedToTargetVisStim, leverReleaseTimesAlignedToBaselineVisStim, targetVisStimAlignedToLeverHold, targetVisStimAlignedToLeverRelease, baselineVisStimAlignedToLeverRelease, ...
    fixedHoldStartsAtRelativeTrial, allTrialCount]= chunkAlignSpikeTimes(spikeTimesSec, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrStimTurnedOnTrials, arrSelectedTrials)
        globals;
        
        allTrialCount = length(leverHoldTimes);
        allTrials = [1:allTrialCount];
        
        spikeTimeAlignedToLeverHold = cell(1,allTrialCount); % {};
        spikeTimeAlignedToLeverRelease = cell(1,allTrialCount); % {};
        spikeTimeofTrialAlignedToLeverRelease = cell(1,allTrialCount);
        spikeTimeofTrialwITIAlignedToLeverRelease = cell(1,allTrialCount);
        spikeTimeAlignedToTargetVisStim = cell(1,allTrialCount); % {};
        spikeTimeAlignedToBaselineVisStim = cell(1,allTrialCount); % {};

        leverHoldTimesAlignedToLeverRelease = -99*ones(1,allTrialCount);
        leverHoldTimesAlignedToTargetVisStim = cell(1,allTrialCount); % {};
        leverReleaseTimesAlignedToTargetVisStim = cell(1,allTrialCount); % {};
        leverReleaseTimesAlignedToBaselineVisStim = cell(1,allTrialCount); % {};
        targetVisStimAlignedToLeverHold = cell(1,allTrialCount); % {};
        targetVisStimAlignedToLeverRelease = cell(1,allTrialCount); % {};
        baselineVisStimAlignedToLeverRelease = cell(1,allTrialCount); % {};
                
        %********************************* ALIGNMENTS **************************
        for indTrial=1:allTrialCount
            % get spikes between hold and release
            if isempty(arrSelectedTrials) || (~isempty(arrSelectedTrials) && ismember(indTrial,arrSelectedTrials))
                spikesOfTrial = spikeTimesSec(spikeTimesSec>(leverHoldTimes(indTrial)-PRE_TIME_HOLD) & spikeTimesSec<(leverHoldTimes(indTrial)+POST_TIME_HOLD)); 
                spikeTimeAlignedToLeverHold(indTrial) = {spikesOfTrial - leverHoldTimes(indTrial)}; % align according to Lever Hold
                
                spikesOfTrial = spikeTimesSec(spikeTimesSec>(leverReleaseTimesGLX(indTrial)-PRE_TIME_RELEASE) & spikeTimesSec<(leverReleaseTimesGLX(indTrial)+POST_TIME_RELEASE)); 
                spikeTimeAlignedToLeverRelease(indTrial) = {spikesOfTrial - leverReleaseTimesGLX(indTrial)}; % align according to Lever Release

                % get spikes between hold and release                        
                spikesOfTrial = spikeTimesSec(spikeTimesSec>(leverHoldTimes(indTrial)-PRE_TIME_HOLD) & spikeTimesSec<(leverReleaseTimesGLX(indTrial)+POST_TIME_RELEASE));             
                spikeTimeofTrialAlignedToLeverRelease(indTrial) = {spikesOfTrial - leverReleaseTimesGLX(indTrial)}; % align according to Lever Release  

                % get spikes between hold of a trial and hold of the next trial
                if indTrial+1>=allTrialCount
                    nextTrialStartTime = leverReleaseTimesGLX(indTrial)+POST_TIME_RELEASE;
                else
                    nextTrialStartTime = leverHoldTimes(indTrial+1)-PRE_TIME_HOLD;
                end
                spikesOfTrialwITI = spikeTimesSec(spikeTimesSec>(leverHoldTimes(indTrial)-PRE_TIME_HOLD) & spikeTimesSec<nextTrialStartTime); 
                spikeTimeofTrialwITIAlignedToLeverRelease(indTrial) = {spikesOfTrialwITI - leverReleaseTimesGLX(indTrial)}; % align according to Lever Release 

                leverHoldTimesAlignedToLeverRelease(indTrial) = leverHoldTimes(indTrial) - leverReleaseTimesGLX(indTrial); % align Lever Hold times acc to Release

                % get if any visual stim change happened between lever hold and release of this trial    
                if any(arrStimTurnedOnTrials==indTrial) % if target visual stim turned on in this trial
                    indVisStimOnTrial = find(arrStimTurnedOnTrials==indTrial);
                    targetVisStimAlignedToLeverHold(indTrial) = {targetVisStimChangeTimeGLX(indVisStimOnTrial)-leverHoldTimes(indTrial)};
                    targetVisStimAlignedToLeverRelease(indTrial) = {targetVisStimChangeTimeGLX(indVisStimOnTrial)-leverReleaseTimesGLX(indTrial)};
                    baselineVisStimAlignedToLeverRelease(indTrial) = {baselineVisStimChangeTimeGLX(indVisStimOnTrial)-leverReleaseTimesGLX(indTrial)};

                    spikesOfTrial = spikeTimesSec(spikeTimesSec>(targetVisStimChangeTimeGLX(indVisStimOnTrial)-PRE_TIME_VIS_STIM) & spikeTimesSec<(targetVisStimChangeTimeGLX(indVisStimOnTrial)+POST_TIME_VIS_STIM)); 
                    spikeTimeAlignedToTargetVisStim(indTrial) = {spikesOfTrial - targetVisStimChangeTimeGLX(indVisStimOnTrial)}; % align Spikes according to Vis Stim On
                    
                    spikesOfTrial = spikeTimesSec(spikeTimesSec>(baselineVisStimChangeTimeGLX(indVisStimOnTrial)-PRE_TIME_VIS_STIM) & spikeTimesSec<(baselineVisStimChangeTimeGLX(indVisStimOnTrial)+POST_TIME_VIS_STIM)); 
                    spikeTimeAlignedToBaselineVisStim(indTrial) = {spikesOfTrial - baselineVisStimChangeTimeGLX(indVisStimOnTrial)}; % align Spikes according to Vis Stim Off
                    
                    leverHoldTimesAlignedToTargetVisStim(indTrial) = {leverHoldTimes(indTrial) - targetVisStimChangeTimeGLX(indVisStimOnTrial)}; % align Lever Hold times acc to Vis Stim On 
                    leverReleaseTimesAlignedToTargetVisStim(indTrial) = {leverReleaseTimesGLX(indTrial) - targetVisStimChangeTimeGLX(indVisStimOnTrial)}; % align Lever Release times acc to Vis Stim Off
                    leverReleaseTimesAlignedToBaselineVisStim(indTrial) = {leverReleaseTimesGLX(indTrial) - baselineVisStimChangeTimeGLX(indVisStimOnTrial)}; % align Lever Release times acc to Vis Stim Off
                end
            end
        end
                
        % DONE: TODO: Check if empty cells are really non-relevant trials -ie; fa trials when getting hit trial analyses- or the trials with no spike! 
        % If the case is the second, then we should not eliminate those!! this increases firing rate!
        %nonSelectedTrials = cellfun(@isempty,spikeTimeAlignedToLeverHold); % find empty cells        
        nonSelectedTrials = setdiff(allTrials,arrSelectedTrials); % eliminate non-selected trials
        
        countEmptyBefFixed = sum(nonSelectedTrials<fixedHoldStartsAtTrial);
        fixedHoldStartsAtRelativeTrial = fixedHoldStartsAtTrial-countEmptyBefFixed; % Find relative fixed trial number when empty cells removed
        spikeTimeAlignedToLeverHold(nonSelectedTrials) = []; % remove empty cells      
        spikeTimeAlignedToLeverRelease(nonSelectedTrials) = [];   
        targetVisStimAlignedToLeverHold(nonSelectedTrials) = []; % it will be the same cells for these, too
        targetVisStimAlignedToLeverRelease(nonSelectedTrials) = [];
        baselineVisStimAlignedToLeverRelease(nonSelectedTrials) = []; % it will be the same cells for these, too
        
        spikeTimeAlignedToTargetVisStim(nonSelectedTrials) = []; % remove empty cells      
        spikeTimeAlignedToBaselineVisStim(nonSelectedTrials) = []; % it will be the same cells for Baseline and Target, no need to check again which are empty cos visStimOn trials have both target and baseline stimuli
        leverHoldTimesAlignedToTargetVisStim(nonSelectedTrials) = []; % it will be the same cells for these, too
        leverReleaseTimesAlignedToTargetVisStim(nonSelectedTrials) = [];
        leverReleaseTimesAlignedToBaselineVisStim(nonSelectedTrials) = []; % it will be the same cells for these, too
end