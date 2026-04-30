%%%% PLOT Cross Correlogram between two units %%%%%%%%%%%%
% unitRefID: Reference Unit ID (Effector - check if this unit manipulates the target unit's activity)
% unitTargetID: Target Unit ID (Effected - check if this unit's activity modulated by reference unit's activity)
% unitRefSpikeTimesSec: Reference Unit Spike Times (s)
% unitTargetSpikeTimesSec: Target Unit Spike Times (s)
%
% SO 1/2/2023 Hull Lab
function [suppressed, singleUnit] = plotCCG(ccgType, unitCategory, unitRefID, unitTargetID, unitRefSpikeTimesSec,unitTargetSpikeTimesSec, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, visStimTimesGLX, arrStimTurnedOnTrials, arrSelectedTrials, whichCellTypes, isACG, neuronType)
    
    globals;    
    trialCount = length(arrSelectedTrials);    
    
    %********************************* ALIGNMENTS TO LEVER HOLD/RELEASE **************************
    for ind=1:trialCount
        indTrial = arrSelectedTrials(ind);
        
        preHoldTime = leverHoldTimes(indTrial)-PRE_TIME_HOLD;
        postHoldTime = leverHoldTimes(indTrial)+POST_TIME_HOLD;
        preReleaseTime = leverReleaseTimesGLX(indTrial)-PRE_TIME_RELEASE;
        postReleaseTime = leverReleaseTimesGLX(indTrial)+POST_TIME_RELEASE;

        %Divide spike times into trials beginning from preHoldTime(t) to preHoldTime(t+1) so that it also includes iti for further CCG analysis
        if ind+1<=trialCount
            indNextTrial = arrSelectedTrials(ind+1);
            preHoldTimeNext = leverHoldTimes(indNextTrial)-PRE_TIME_HOLD; % beginning of next trial
            spikesOfTrialForRef = unitRefSpikeTimesSec(unitRefSpikeTimesSec>preHoldTime & unitRefSpikeTimesSec<preHoldTimeNext);
            spikesOfTrialForRef = spikesOfTrialForRef - leverHoldTimes(indTrial);
            spikesOfTrialForTarget = unitTargetSpikeTimesSec(unitTargetSpikeTimesSec>preHoldTime & unitTargetSpikeTimesSec<preHoldTimeNext);
            spikesOfTrialForTarget = spikesOfTrialForTarget - leverHoldTimes(indTrial);
        else
            spikesOfTrialForRef = unitRefSpikeTimesSec(unitRefSpikeTimesSec>preHoldTime); % no preHoldTimeNext cos it's the end of the session
            spikesOfTrialForRef = spikesOfTrialForRef - preHoldTime;
            spikesOfTrialForTarget = unitTargetSpikeTimesSec(unitTargetSpikeTimesSec>preHoldTime);
            spikesOfTrialForTarget = spikesOfTrialForTarget - preHoldTime;
        end
        unitRefSpikeTimesTrialITIAlignedToLeverHold(ind) = {spikesOfTrialForRef}; % align according to Pre Lever Hold
        unitTargetSpikeTimesTrialITIAlignedToLeverHold(ind) = {spikesOfTrialForTarget}; % align according to Pre Lever Hold
                
        % Align Spikes to Lever Hold
        spikesOfTrial = unitRefSpikeTimesSec(unitRefSpikeTimesSec>preHoldTime & unitRefSpikeTimesSec<postHoldTime); 
        unitRefSpikeTimesAlignedToLeverHold(ind) = {spikesOfTrial - leverHoldTimes(indTrial)}; % align according to Lever Hold
        spikesOfTrial = unitTargetSpikeTimesSec(unitTargetSpikeTimesSec>preHoldTime & unitTargetSpikeTimesSec<postHoldTime); 
        unitTargetSpikeTimesAlignedToLeverHold(ind) = {spikesOfTrial - leverHoldTimes(indTrial)}; % align according to Lever Hold

        % Align Spikes to Lever Release
        spikesOfTrial = unitRefSpikeTimesSec(unitRefSpikeTimesSec>preReleaseTime & unitRefSpikeTimesSec<postReleaseTime); 
        unitRefSpikeTimesAlignedToLeverRelease(ind) = {spikesOfTrial - leverReleaseTimesGLX(indTrial)}; % align according to Lever Release
        spikesOfTrial = unitTargetSpikeTimesSec(unitTargetSpikeTimesSec>preReleaseTime & unitTargetSpikeTimesSec<postReleaseTime); 
        unitTargetSpikeTimesAlignedToLeverRelease(ind) = {spikesOfTrial - leverReleaseTimesGLX(indTrial)}; % align according to Lever Release

        % get if any visual stim change happened between lever hold and release of this trial    
        if any(arrStimTurnedOnTrials==indTrial) % if target visual stim turned on in this trial
            indVisStimOnTrial = find(arrStimTurnedOnTrials==indTrial);
            preVisStimTime = visStimTimesGLX(indVisStimOnTrial)-PRE_TIME_VIS_STIM;
            postVisStimTime = visStimTimesGLX(indVisStimOnTrial)+POST_TIME_VIS_STIM;
            spikesOfTrial = unitRefSpikeTimesSec(unitRefSpikeTimesSec>preVisStimTime & unitRefSpikeTimesSec<postVisStimTime); 
            unitRefSpikeTimesAlignedToVisStim(ind) = {spikesOfTrial - visStimTimesGLX(indVisStimOnTrial)}; % align Spikes according to Vis Stim On
            spikesOfTrial = unitTargetSpikeTimesSec(unitTargetSpikeTimesSec>preVisStimTime & unitTargetSpikeTimesSec<postVisStimTime); 
            unitTargetSpikeTimesAlignedToVisStim(ind) = {spikesOfTrial - visStimTimesGLX(indVisStimOnTrial)}; % align Spikes according to Vis Stim On
        else
            unitRefSpikeTimesAlignedToVisStim(ind) = {[]};
            unitTargetSpikeTimesAlignedToVisStim(ind) = {[]};
        end

        % Get Spikes within the duration of the whole trial, will later align some salient event of Ref Unit (i.e; increased activity around reward)
        spikesOfTrial = unitRefSpikeTimesSec(unitRefSpikeTimesSec>preHoldTime & unitRefSpikeTimesSec<postReleaseTime); 
        unitRefSpikeTimesTrial(ind) = {spikesOfTrial - leverReleaseTimesGLX(indTrial)}; % align according to Lever Release            
        spikesOfTrial = unitTargetSpikeTimesSec(unitTargetSpikeTimesSec>preHoldTime & unitTargetSpikeTimesSec<postReleaseTime); 
        unitTargetSpikeTimesTrial(ind) = {spikesOfTrial - leverReleaseTimesGLX(indTrial)}; % align according to Lever Release
    end
    
    %correlogram(unitRefID, unitTargetID, unitRefSpikeTimesSec, unitTargetSpikeTimesSec, trialCount, ['Bulky ' whichCellTypes]);
    %*************************** CLASSIC CORRELOGRAM *******************************
    % Classic CCG focuses on the spike times from the beginning of a trial to the beginning of next trial
    logger.info('plotCCG', ['trying ' ccgType ' CLASSIC']);
    [suppressedClassic, singleUnit] = correlogram(ccgType, unitCategory, unitRefID, unitTargetID, unitRefSpikeTimesTrialITIAlignedToLeverHold, unitTargetSpikeTimesTrialITIAlignedToLeverHold, trialCount, ['Classic ' whichCellTypes], isACG, neuronType);
    
%     %*************************** CORRELOGRAM FOCUSED ON LEVEL HOLD *******************************
%     logger.info('plotCCG', ['trying ' ccgType ' HOLD']);
%     [suppressedHold, ~] = correlogram(ccgType, unitCategory, unitRefID, unitTargetID, unitRefSpikeTimesAlignedToLeverHold, unitTargetSpikeTimesAlignedToLeverHold, trialCount, ['LeverHold ' whichCellTypes], isACG, neuronType);    
%     %*************************** CORRELOGRAM FOCUSED ON LEVEL RELEASE *******************************
%     logger.info('plotCCG', ['trying ' ccgType ' RELEASE']);
%     [suppressedRelease, ~] = correlogram(ccgType, unitCategory, unitRefID, unitTargetID, unitRefSpikeTimesAlignedToLeverRelease, unitTargetSpikeTimesAlignedToLeverRelease, trialCount, ['LeverRelease ' whichCellTypes], isACG, neuronType);    
%     %*************************** CORRELOGRAM FOCUSED ON VIS STIM *******************************
%     logger.info('plotCCG', ['trying ' ccgType ' VIS STIM']);
%     [suppressedVisStim, ~] = correlogram(ccgType, unitCategory, unitRefID, unitTargetID, unitRefSpikeTimesAlignedToVisStim, unitTargetSpikeTimesAlignedToVisStim, trialCount, ['VisStimChange ' whichCellTypes], isACG, neuronType);    
%     %********************************* ALIGN TO THE MOST SALIENT EVENT OF REF NEURON **************************
%     % Find the reference neuron's most salient time of event, so that you'll check around that time for the target neuron
%     unitRefSpikeTimesWholeTrials = [unitRefSpikeTimesTrial{:}];
%     optimumBinCount = sshist(unitRefSpikeTimesWholeTrials); % Use optimized bin count for histogram
%     suppressedSalient = 0;
%     if ~isempty(optimumBinCount)
%         [binCounts, edges] = histcounts(unitRefSpikeTimesWholeTrials,optimumBinCount);
%         [maxFiring, indBin] = max(binCounts);
%         salientEventTime = edges(indBin);
%     %     for ind=1:trialCount
%     %         unitRefSpikeTimesTrial(ind) = {unitRefSpikeTimesTrial{ind} - salientEventTime}; % align according to the most salient time
%     %         unitTargetSpikeTimesTrial(ind) = {unitRefSpikeTimesTrial{ind} - salientEventTime};
%     %     end    
%         [suppressedSalient, ~] = correlogram(ccgType, unitCategory, unitRefID, unitTargetID, unitRefSpikeTimesTrial, unitTargetSpikeTimesTrial, trialCount, ['SalientAroundLevRel' num2str(salientEventTime,3) ' ' whichCellTypes], isACG, neuronType);
%     end
     suppressed = 0;
%     if suppressedClassic || suppressedHold || suppressedRelease || suppressedVisStim || suppressedSalient
%         suppressed = 1;
%     end
end