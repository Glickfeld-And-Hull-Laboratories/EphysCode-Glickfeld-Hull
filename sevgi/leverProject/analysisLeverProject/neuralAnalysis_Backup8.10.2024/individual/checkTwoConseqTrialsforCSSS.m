% ************************ Check if there is any effect of having CS in a trial suppresses SS in the next trial  % ***********************                
function checkTwoConseqTrialsforCSSS(suppressedPairs_CS_SS, pairs, units, sPairCS, sPairSS, sFolderName, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials)

    globals;
    if ~isempty(pairs)
        for iPair=1:length(pairs)
            unitPairCS = units(find([units.id]==pairs(iPair,1)));
            unitPairSS = units(find([units.id]==pairs(iPair,2)));
            
            if ~isempty(unitPairCS) && ~isempty(unitPairSS) && suppressedPairs_CS_SS(iPair) % is this a real pair-there is a suppression between them 
                %unitPairCS.id==291 && unitPairSS.id == 285 %&& unitPairCS.id == 460 && unitPairSS.id == 364 %  % && unitPairCS.id == 460 && unitPairSS.id == 364  
                [spikeTimeAlignedToLeverHoldCS, spikeTimeAlignedToLeverReleaseCS, spikeTimeAlignedToTargetVisStimCS, spikeTimeAlignedToBaselineVisStimCS, ...
                spikeTimeofTrialAlignedToLeverReleaseCS, spikeTimeofTrialwITIAlignedToLeverReleaseCS, leverHoldTimesAlignedToLeverReleaseCS,...
                leverHoldTimesAlignedToTargetVisStimCS, leverReleaseTimesAlignedToTargetVisStimCS, leverReleaseTimesAlignedToBaselineVisStimCS, targetVisStimAlignedToLeverHoldCS, targetVisStimAlignedToLeverReleaseCS, baselineVisStimAlignedToLeverReleaseCS, ...
                fixedHoldStartsAtTrialCS, allTrialCountCS] = chunkAlignSpikeTimes(unitPairCS.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrStimTurnedOnTrials, allTrials);
            
                [spikeTimeAlignedToLeverHoldSS, spikeTimeAlignedToLeverReleaseSS, spikeTimeAlignedToTargetVisStimSS, spikeTimeAlignedToBaselineVisStimSS, ...
                spikeTimeofTrialAlignedToLeverReleaseSS, spikeTimeofTrialwITIAlignedToLeverReleaseSS, leverHoldTimesAlignedToLeverReleaseSS,...
                leverHoldTimesAlignedToTargetVisStimSS, leverReleaseTimesAlignedToTargetVisStimSS, leverReleaseTimesAlignedToBaselineVisStimSS, targetVisStimAlignedToLeverHoldSS, targetVisStimAlignedToLeverReleaseSS, baselineVisStimAlignedToLeverReleaseSS, ...
                fixedHoldStartsAtTrial, allTrialCount] = chunkAlignSpikeTimes(unitPairSS.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrStimTurnedOnTrials, allTrials);
        
                %********************************************************************************
                logger.info('checkTwoConseqTrialsforCSSS', ['Checking ' sPairCS '=' num2str(unitPairCS.id) ' and ' sPairSS '=' num2str(unitPairSS.id) ' spike times']);
                
                %*********************************************************************************
                [val,pos]=intersect(allTrials,arrStimTurnedOnTrials); % returns the position on the first array
                
                spikeTimeToTargetCS = spikeTimeAlignedToTargetVisStimCS(pos);
                spikeTimeToTargetSS = spikeTimeAlignedToTargetVisStimSS(pos);
                
                if fixedHoldStartsAtTrial>0 % if session is mixed with random/fixed trials
                    indFixedTarget = find(val>=allTrials(fixedHoldStartsAtTrial),1); %find the index in the intersection of two sets (val)                    
                    randSSpksToRelease = spikeTimeAlignedToLeverReleaseSS(1:fixedHoldStartsAtTrial-1)';
                    fixedSSpksToRelease = spikeTimeAlignedToLeverReleaseSS(fixedHoldStartsAtTrial:end)';
                    randSSpksToTarget = spikeTimeToTargetSS(1:indFixedTarget-1)';
                    fixedSSpksToTarget = spikeTimeToTargetSS(indFixedTarget:end)';

                    randCSpksToRelease = spikeTimeAlignedToLeverReleaseCS(1:fixedHoldStartsAtTrial-1)';
                    fixedCSpksToRelease = spikeTimeAlignedToLeverReleaseCS(fixedHoldStartsAtTrial:end)';
                    randCSpksToTarget = spikeTimeToTargetCS(1:indFixedTarget-1)';
                    fixedCSpksToTarget = spikeTimeToTargetCS(indFixedTarget:end)';
                else % fixedHoldStartsAtTrial==0 means only random trials
                    randSSpksToRelease = spikeTimeAlignedToLeverReleaseSS';    
                    randSSpksToTarget = spikeTimeToTargetSS';

                    randCSpksToRelease = spikeTimeAlignedToLeverReleaseCS';    
                    randCSpksToTarget = spikeTimeToTargetCS';
                end

                % ************************ Check if there is any effect of having CS in a trial suppresses SS in the next trial  % ***********************                
                fixedOrRandom=0; % Send 0 parameter for random trials
                plotSSratesvsCSWRTTrialOutcome(randCSpksToRelease, randSSpksToRelease, randCSpksToTarget, randSSpksToTarget, ...
                    num2str(unitPairCS.id), num2str(unitPairSS.id), sFolderName, fixedHoldStartsAtTrial, allTrials, arrStimTurnedOnTrials, arrHitTrials, arrMissTrials, arrFaTrials, ...
                    fixedOrRandom);                
                close all;

                fixedOrRandom=1; % Send 1 parameter for fixed trials
                plotSSratesvsCSWRTTrialOutcome(fixedCSpksToRelease, fixedSSpksToRelease, fixedCSpksToTarget, fixedSSpksToTarget, ...
                    num2str(unitPairCS.id), num2str(unitPairSS.id), sFolderName, fixedHoldStartsAtTrial, allTrials, arrStimTurnedOnTrials, arrHitTrials, arrMissTrials, arrFaTrials, ...
                    fixedOrRandom);                
                close all;                 
            end
        end
    end

end