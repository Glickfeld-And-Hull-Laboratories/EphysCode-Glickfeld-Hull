% Suspected if all functions with fixedHoldStartsAt... need to be arranged
% like this function handles it with
% find(val>=arrSelectedTrials(fixedHoldStartsAtRelativeTrial),1) for different indexing in Hit/Miss/FA trials
%     and apparently no need in other functions
% Checked the functions below:
% checkTwoConseqTrialsforCSSS 	has it: indFixedTarget = find(val>=allTrials(fixedHoldStartsAtTrial),1);
% compareFR_ISI 			no need
% plotPSTHToCheckShift		no need
% plotRasterLeverVisStim		no need
% 
% checkCSSSandBehavEventTimes has it: indFixedTarget = find(val>=arrSelectedTrials(fixedHoldStartsAtRelativeTrial),1); %find the index in the intersection of two sets (val)
% 							where [val,pos]=intersect(arrSelectedTrials,arrStimTurnedOnTrials);
% plotSSratesvsCSWRTTrialOutcome has it: indFixed = find(arrStimTurnedOnTrials==fixedHoldStartsAtTrial,1);

function checkCSSSandBehavEventTimes(suppressedPairs_CS_SS, pairs, units, sPairCS, sPairSS, sFolderName, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrReactTimes, arrStimTurnedOnTrials, arrSelectedTrials, strTrialType)

    globals;
    if ~isempty(pairs)
        for iPair=1:length(pairs)
            unitPairCS = units(find([units.id]==pairs(iPair,1)));
            unitPairSS = units(find([units.id]==pairs(iPair,2)));
            
            if ~isempty(unitPairCS) && ~isempty(unitPairSS) %&& suppressedPairs_CS_SS(iPair) % is this a real pair-there is a suppression between them %  && unitPairCS.id==651 && unitPairSS.id == 95 % 
                [spikeTimeAlignedToLeverHoldCS, spikeTimeAlignedToLeverReleaseCS, spikeTimeAlignedToTargetVisStimCS, spikeTimeAlignedToBaselineVisStimCS, ...
                spikeTimeofTrialAlignedToLeverReleaseCS, spikeTimeofTrialwITIAlignedToLeverReleaseCS, leverHoldTimesAlignedToLeverReleaseCS,...
                leverHoldTimesAlignedToTargetVisStimCS, leverReleaseTimesAlignedToTargetVisStimCS, leverReleaseTimesAlignedToBaselineVisStimCS, targetVisStimAlignedToLeverHoldCS, targetVisStimAlignedToLeverReleaseCS, baselineVisStimAlignedToLeverReleaseCS, ...
                fixedHoldStartsAtRelativeTrialCS, allTrialCountCS] = chunkAlignSpikeTimes(unitPairCS.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrStimTurnedOnTrials, arrSelectedTrials);
            
                [spikeTimeAlignedToLeverHoldSS, spikeTimeAlignedToLeverReleaseSS, spikeTimeAlignedToTargetVisStimSS, spikeTimeAlignedToBaselineVisStimSS, ...
                spikeTimeofTrialAlignedToLeverReleaseSS, spikeTimeofTrialwITIAlignedToLeverReleaseSS, leverHoldTimesAlignedToLeverReleaseSS,...
                leverHoldTimesAlignedToTargetVisStimSS, leverReleaseTimesAlignedToTargetVisStimSS, leverReleaseTimesAlignedToBaselineVisStimSS, targetVisStimAlignedToLeverHoldSS, targetVisStimAlignedToLeverReleaseSS, baselineVisStimAlignedToLeverReleaseSS, ...
                fixedHoldStartsAtRelativeTrial, allTrialCount] = chunkAlignSpikeTimes(unitPairSS.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrStimTurnedOnTrials, arrSelectedTrials);
        
                %********************************************************************************
                logger.info('checkCSSSandBehavEventTimes', ['Checking ' sPairCS '=' num2str(unitPairCS.id) ' and ' sPairSS '=' num2str(unitPairSS.id) ' spike times ' strTrialType]);
                
                %*********************************************************************************
%                 [val,pos]=intersect(arrStimTurnedOnTrials, arrSelectedTrials); % common elements that are both in selected trials(hit/miss/fa) and vis stim on trials
%                 reactionTimeMsGLX = (leverReleaseTimesGLX(val)-targetVisStimChangeTimeGLX(pos))*1000; % reaction time (difference from uncond. stim. to cond. stim.) for this trial (ms)
                reactionTimeToRelease = arrReactTimes(arrSelectedTrials);
                [val,pos]=intersect(arrSelectedTrials,arrStimTurnedOnTrials); % returns the position on the first array
                reactionTimeMsOnlyTargetVisStim = arrReactTimes(val); %-cell2mat(targetVisStimAlignedToLeverReleaseSS)*1000; % Since targetVisStim aligned to releases, they are negative, converted them!
                %reactionTimeMsOnlyTargetVisStimGLX = -cell2mat(targetVisStimAlignedToLeverReleaseSS)*1000;
                
                spikeTimeOnlyTargetVisStimCS = spikeTimeAlignedToTargetVisStimCS(pos);
                spikeTimeOnlyTargetVisStimSS = spikeTimeAlignedToTargetVisStimSS(pos);
                
                if fixedHoldStartsAtRelativeTrial>0 % if session is mixed with random/fixed trials
                    reactionTimeRandomToRelease = reactionTimeToRelease(1:fixedHoldStartsAtRelativeTrial-1);
                    reactionTimeFixedToRelease = reactionTimeToRelease(fixedHoldStartsAtRelativeTrial:end);
                    indFixedTarget = find(val>=arrSelectedTrials(fixedHoldStartsAtRelativeTrial),1); %find the index in the intersection of two sets (val)
                    reactionTimeRandomMsOnlyTargetVisStim = reactionTimeMsOnlyTargetVisStim(1:indFixedTarget-1);
                    reactionTimeFixedMsOnlyTargetVisStim = reactionTimeMsOnlyTargetVisStim(indFixedTarget:end);
                    
                    randSSpksToRelease = spikeTimeAlignedToLeverReleaseSS(1:fixedHoldStartsAtRelativeTrial-1)';
                    fixedSSpksToRelease = spikeTimeAlignedToLeverReleaseSS(fixedHoldStartsAtRelativeTrial:end)';
                    randSSpksOnlyTargetVisStim = spikeTimeOnlyTargetVisStimSS(1:indFixedTarget-1)';
                    fixedSSpksOnlyTargetVisStim = spikeTimeOnlyTargetVisStimSS(indFixedTarget:end)';

                    randCSpksToRelease = spikeTimeAlignedToLeverReleaseCS(1:fixedHoldStartsAtRelativeTrial-1)';
                    fixedCSpksToRelease = spikeTimeAlignedToLeverReleaseCS(fixedHoldStartsAtRelativeTrial:end)';
                    randCSpksOnlyTargetVisStim = spikeTimeOnlyTargetVisStimCS(1:indFixedTarget-1)';
                    fixedCSpksOnlyTargetVisStim = spikeTimeOnlyTargetVisStimCS(indFixedTarget:end)';
                else % fixedHoldStartsAtTrial==0 means only random trials
                    reactionTimeRandomToRelease = reactionTimeToRelease;
                    reactionTimeRandomMsOnlyTargetVisStim = reactionTimeMsOnlyTargetVisStim;

                    randSSpksToRelease = spikeTimeAlignedToLeverReleaseSS';    
                    randSSpksOnlyTargetVisStim = spikeTimeOnlyTargetVisStimSS';
                    randCSpksToRelease = spikeTimeAlignedToLeverReleaseCS';    
                    randCSpksOnlyTargetVisStim = spikeTimeOnlyTargetVisStimCS';
                end
                
                %************************* Time from behav.event vs Trials - CHECK IF THERE IS ANY TREND along the trials                                
                plotSpikeTimevsTrialsWRTBehavEvent(randCSpksToRelease, fixedCSpksToRelease, randCSpksOnlyTargetVisStim, fixedCSpksOnlyTargetVisStim, ...
                    {'Random delay CS times','Fixed delay CS times','Random delay CS times','Fixed delay CS times'}, 'Trials', {'Time from release (s)','Time from release (s)','Time from target stim (s)','Time from target stim (s)'}, ...
                    ['CS Unit=' num2str(unitPairCS.id)], sFolderName, ['CS_' num2str(unitPairCS.id) '_spikeTimevsTrials'], strTrialType);
                
                plotSpikeTimevsTrialsWRTBehavEvent(randSSpksToRelease, fixedSSpksToRelease, randSSpksOnlyTargetVisStim, fixedSSpksOnlyTargetVisStim, ...
                    {'Random delay SS times','Fixed delay SS times','Random delay SS times','Fixed delay SS times'}, 'Trials', {'Time from release (s)','Time from release (s)','Time from target stim (s)','Time from target stim (s)'}, ...
                    ['SS Unit=' num2str(unitPairSS.id)], sFolderName, ['SS_' num2str(unitPairSS.id) '_spikeTimevsTrials'], strTrialType);

                %************** CHECK IF THERE IS ANY CORRELATION BETWEEN CS timing and Reaction time of that trial ****************
                plotViolinsForSpikeTimevsChunks({randCSpksToRelease fixedCSpksToRelease randCSpksOnlyTargetVisStim fixedCSpksOnlyTargetVisStim}, ...
                    {reactionTimeRandomToRelease reactionTimeFixedToRelease reactionTimeRandomMsOnlyTargetVisStim reactionTimeFixedMsOnlyTargetVisStim}, CHUNK_OF_REACTION_TIMES, ...
                    CHUNK_NAMES, -PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM, {'Random delay CS times', 'Fixed delay CS times','',''}, 'Reaction time categories (ms)', ...
                    {'Time from release (s)','Time from release (s)','Time from target stim (s)','Time from target stim (s)'}, ['CS Unit=' num2str(unitPairCS.id)], sFolderName, ['CS_' num2str(unitPairCS.id) '_spikeTimevsViolinsofEvents'], strTrialType);
                plotViolinsForSpikeTimevsChunks({randSSpksToRelease fixedSSpksToRelease randSSpksOnlyTargetVisStim fixedSSpksOnlyTargetVisStim}, ...
                    {reactionTimeRandomToRelease reactionTimeFixedToRelease reactionTimeRandomMsOnlyTargetVisStim reactionTimeFixedMsOnlyTargetVisStim}, CHUNK_OF_REACTION_TIMES, ...
                    CHUNK_NAMES, -PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM, {'Random delay SS times', 'Fixed delay SS times','',''}, 'Reaction time categories (ms)', ...
                    {'Time from release (s)','Time from release (s)','Time from target stim (s)','Time from target stim (s)'}, ['SS Unit=' num2str(unitPairSS.id)], sFolderName, ['SS_' num2str(unitPairSS.id) '_spikeTimevsViolinsofEvents'], strTrialType);
                close all;
            end
        end
    end

end
