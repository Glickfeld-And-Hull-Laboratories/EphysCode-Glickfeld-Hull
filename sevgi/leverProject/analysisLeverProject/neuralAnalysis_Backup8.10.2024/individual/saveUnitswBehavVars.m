function saveUnitswBehavVars(dataSetNeedsToBeResaved, unitGood, unitMua, unitNoise, unitUnprocessed, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, trialCutIndex, ...
allTrials, arrHitTrials, arrFaTrials, arrMissTrials, arrStimTurnedOnTrials, arrReqHoldTimes, arrReactTimes, tooFastTime, reactTime, preHoldTime, fixedHoldStartsAtTrial, ...
spikeRatesHoldRandomAll, spikeRatesHoldFixedAll, spikeRatesHoldRandomHFM, spikeRatesHoldFixedHFM, spikeRatesReleaseRandomAll, spikeRatesReleaseFixedAll, ...
                spikeRatesReleaseRandomHFM, spikeRatesReleaseFixedHFM, spikeRatesTargetRandomAll, spikeRatesTargetFixedAll, spikeRatesTargetRandomHFM, spikeRatesTargetFixedHFM, ...
                responseTypeHoldFixedAll, responseTypeHoldFixedHFM, responseTypeReleaseFixedAll, responseTypeReleaseFixedHFM, responseTypeTargetFixedAll, responseTypeTargetFixedHFM)

    globals;
    unitsAndVarsPath = strcat(pathToUnitsDataFolder,UNITS_AND_VARS_FILE_NAME);
    
    if dataSetNeedsToBeResaved && exist(unitsAndVarsPath,'file')
        oldUnitsAndVarsPath = strcat(pathToUnitsDataFolder,['_renamed_' date UNITS_AND_VARS_FILE_NAME]);
        status = movefile(unitsAndVarsPath,oldUnitsAndVarsPath);
        if ~status
            logger.log('saveUnitswBehavVars', 'Could not rename data file!');
            exit;
        end
    end

    if ~exist(unitsAndVarsPath,'file')
    
        softCut = SOFT_CUT;
        softCutPartition = SOFT_CUT_PARTITION;
        hardCut = HARD_CUT;
        hardCutPartition = HARD_CUT_PARTITION;
        
        if UNIT_OF_INTEREST== -1 % save all units             

            unitCategoryList = [unitGood, unitMua];
            newUnitCategoryList = cell(1,2);

            for cid=1:length(unitCategoryList)
                unitList = unitCategoryList(cid); % first good units, then multi units
                for uid=1:length(unitList)
                    unit = unitList(uid);
                    newUnit.id = unit.id;
                    newUnit.spikeTimesSecs = unit.spikeTimesSecs;
                    newUnit.amplitudes = unit.amplitudes;
                    newUnit.ch = unit.ch;
                    newUnit.depth = unit.depth;
                    newUnit.fr = unit.fr;
                    newUnit.clusterAmpl = unit.clusterAmpl;
                    newUnit.group = unit.group;
                    newUnit.nSpikes = unit.nSpikes;
                    newUnit.SNR = unit.SNR;
                    newUnit.neuronType = unit.neuronType;
                    newUnit.layer = unit.layer;
                    newUnit.KSLabel = unit.KSLabel;
                    newUnit.neuronType = unit.neuronType;
                    newUnit.singleUnit = unit.singleUnit;
        
                    [spikeTimeAlignedToLeverHoldAll, spikeTimeAlignedToLeverReleaseAll, spikeTimeAlignedToTargetVisStimAll, spikeTimeAlignedToBaselineVisStimAll, ~, ~, ~, ~, ~, ~, ~, ~, ~, fixedHoldStartsAtRelativeTrial, ~] = ...
                        chunkAlignSpikeTimes(unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials);
                    newUnit.spikeTimeHoldAll = spikeTimeAlignedToLeverHoldAll;
                    newUnit.spikeTimeReleaseAll = spikeTimeAlignedToLeverReleaseAll;
                    newUnit.spikeTimeTargetAll = spikeTimeAlignedToTargetVisStimAll;
                    newUnit.spikeTimeBaselineAll = spikeTimeAlignedToBaselineVisStimAll;
    
                    newUnit.spikeRatePerTrialHoldAll = cellfun(@length,spikeTimeAlignedToLeverHoldAll)/(POST_TIME_HOLD+PRE_TIME_HOLD);
                    newUnit.spikeRatePerTrialReleaseAll = cellfun(@length,spikeTimeAlignedToLeverReleaseAll)/(POST_TIME_RELEASE+PRE_TIME_RELEASE);
                    newUnit.spikeRatePerTrialTargetAll = cellfun(@length,spikeTimeAlignedToTargetVisStimAll)/(POST_TIME_VIS_STIM+PRE_TIME_VIS_STIM);
    
                    % Add Fixed/Random versions too
                    if fixedHoldStartsAtRelativeTrial>0                        
                        spikeTimeHoldRandomAll = spikeTimeAlignedToLeverHoldAll(1:fixedHoldStartsAtRelativeTrial-1)';
                        spikeTimeHoldFixedAll = spikeTimeAlignedToLeverHoldAll(fixedHoldStartsAtRelativeTrial:end)';
                        spikeTimeReleaseRandomAll = spikeTimeAlignedToLeverReleaseAll(1:fixedHoldStartsAtRelativeTrial-1)';
                        spikeTimeReleaseFixedAll = spikeTimeAlignedToLeverReleaseAll(fixedHoldStartsAtRelativeTrial:end)';
                        
                        spikeTimeTargetRandomAll = spikeTimeAlignedToTargetVisStimAll(1:fixedHoldStartsAtRelativeTrial-1)';
                        spikeTimeTargetFixedAll = spikeTimeAlignedToTargetVisStimAll(fixedHoldStartsAtRelativeTrial:end)';
                    else
                        spikeTimeHoldRandomAll = spikeTimeAlignedToLeverHoldAll';
                        spikeTimeReleaseRandomAll = spikeTimeAlignedToLeverReleaseAll';    
                        spikeTimeTargetRandomAll = spikeTimeAlignedToTargetVisStimAll';
                    end
    
                    newUnit.spikeTimeHoldRandomAll = spikeTimeHoldRandomAll;
                    newUnit.spikeTimeHoldFixedAll = spikeTimeHoldFixedAll;
                    newUnit.spikeTimeReleaseRandomAll = spikeTimeReleaseRandomAll;
                    newUnit.spikeTimeReleaseFixedAll = spikeTimeReleaseFixedAll;
                    newUnit.spikeTimeTargetRandomAll = spikeTimeTargetRandomAll;
                    newUnit.spikeTimeTargetFixedAll = spikeTimeTargetFixedAll;
    
                    newUnit.spikeRatePerTrialHoldRandomAll = cellfun(@length,spikeTimeHoldRandomAll)/(POST_TIME_HOLD+PRE_TIME_HOLD);
                    newUnit.spikeRatePerTrialHoldFixedAll = cellfun(@length,spikeTimeHoldFixedAll)/(POST_TIME_HOLD+PRE_TIME_HOLD);
                    newUnit.spikeRatePerTrialReleaseRandomAll = cellfun(@length,spikeTimeReleaseRandomAll)/(POST_TIME_RELEASE+PRE_TIME_RELEASE);
                    newUnit.spikeRatePerTrialReleaseFixedAll = cellfun(@length,spikeTimeReleaseFixedAll)/(POST_TIME_RELEASE+PRE_TIME_RELEASE);
                    newUnit.spikeRatePerTrialTargetRandomAll = cellfun(@length,spikeTimeTargetRandomAll)/(POST_TIME_VIS_STIM+PRE_TIME_VIS_STIM);
                    newUnit.spikeRatePerTrialTargetFixedAll = cellfun(@length,spikeTimeTargetFixedAll)/(POST_TIME_VIS_STIM+PRE_TIME_VIS_STIM);
    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HIT TRIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [spikeTimeAlignedToLeverHoldHit, spikeTimeAlignedToLeverReleaseHit, spikeTimeAlignedToTargetVisStimHit, spikeTimeAlignedToBaselineVisStimHit, ~, ~, ~, ~, ~, ~, ~, ~, ~, fixedHoldStartsAtRelativeTrial, ~] = ...
                        chunkAlignSpikeTimes(unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrHitTrials);
                    [val,pos]=intersect(arrHitTrials,arrStimTurnedOnTrials); % returns the position on the first array
                    spikeTimeOnlyTargetVisStimHit = spikeTimeAlignedToTargetVisStimHit(pos);
    
                    newUnit.spikeTimeHoldHit = spikeTimeAlignedToLeverHoldHit;
                    newUnit.spikeTimeReleaseHit = spikeTimeAlignedToLeverReleaseHit;
                    newUnit.spikeTimeTargetHit = spikeTimeAlignedToTargetVisStimHit;
                    newUnit.spikeTimeBaselineHit = spikeTimeAlignedToBaselineVisStimHit;
    
                    if fixedHoldStartsAtRelativeTrial>0                        
                        spikeTimeHoldRandomHit = spikeTimeAlignedToLeverHoldHit(1:fixedHoldStartsAtRelativeTrial-1)';
                        spikeTimeHoldFixedHit = spikeTimeAlignedToLeverHoldHit(fixedHoldStartsAtRelativeTrial:end)';
                        spikeTimeReleaseRandomHit = spikeTimeAlignedToLeverReleaseHit(1:fixedHoldStartsAtRelativeTrial-1)';
                        spikeTimeReleaseFixedHit = spikeTimeAlignedToLeverReleaseHit(fixedHoldStartsAtRelativeTrial:end)';
                        
                        indFixedTarget = find(val>=arrHitTrials(fixedHoldStartsAtRelativeTrial),1); %find the index in the intersection of two sets (val)
                        spikeTimeTargetRandomHit = spikeTimeOnlyTargetVisStimHit(1:indFixedTarget-1)';
                        spikeTimeTargetFixedHit = spikeTimeOnlyTargetVisStimHit(indFixedTarget:end)';
                    else
                        spikeTimeHoldRandomHit = spikeTimeAlignedToLeverHoldHit';
                        spikeTimeReleaseRandomHit = spikeTimeAlignedToLeverReleaseHit';    
                        spikeTimeTargetRandomHit = spikeTimeOnlyTargetVisStimHit';
                    end
    
                    newUnit.spikeRatePerTrialHoldRandomHit = cellfun(@length,spikeTimeHoldRandomHit)/(POST_TIME_HOLD+PRE_TIME_HOLD);
                    newUnit.spikeRatePerTrialHoldFixedHit = cellfun(@length,spikeTimeHoldFixedHit)/(POST_TIME_HOLD+PRE_TIME_HOLD);
                    newUnit.spikeRatePerTrialReleaseRandomHit = cellfun(@length,spikeTimeReleaseRandomHit)/(POST_TIME_RELEASE+PRE_TIME_RELEASE);
                    newUnit.spikeRatePerTrialReleaseFixedHit = cellfun(@length,spikeTimeReleaseFixedHit)/(POST_TIME_RELEASE+PRE_TIME_RELEASE);
                    newUnit.spikeRatePerTrialTargetRandomHit = cellfun(@length,spikeTimeTargetRandomHit)/(POST_TIME_VIS_STIM+PRE_TIME_VIS_STIM);
                    newUnit.spikeRatePerTrialTargetFixedHit = cellfun(@length,spikeTimeTargetFixedHit)/(POST_TIME_VIS_STIM+PRE_TIME_VIS_STIM);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FA TRIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [spikeTimeAlignedToLeverHoldFa, spikeTimeAlignedToLeverReleaseFa, spikeTimeAlignedToTargetVisStimFa, spikeTimeAlignedToBaselineVisStimFa, ~, ~, ~, ~, ~, ~, ~, ~, ~, fixedHoldStartsAtRelativeTrial, ~] = ...
                        chunkAlignSpikeTimes(unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrFaTrials);
                    [val,pos]=intersect(arrFaTrials,arrStimTurnedOnTrials); % returns the position on the first array
                    spikeTimeOnlyTargetVisStimFa = spikeTimeAlignedToTargetVisStimFa(pos);
    
                    newUnit.spikeTimeHoldFa = spikeTimeAlignedToLeverHoldFa;
                    newUnit.spikeTimeReleaseFa = spikeTimeAlignedToLeverReleaseFa;
                    newUnit.spikeTimeTargetFa = spikeTimeAlignedToTargetVisStimFa;
                    newUnit.spikeTimeBaselineFa = spikeTimeAlignedToBaselineVisStimFa;
    
                    if fixedHoldStartsAtRelativeTrial>0                        
                        spikeTimeHoldRandomFa = spikeTimeAlignedToLeverHoldFa(1:fixedHoldStartsAtRelativeTrial-1)';
                        spikeTimeHoldFixedFa = spikeTimeAlignedToLeverHoldFa(fixedHoldStartsAtRelativeTrial:end)';
                        spikeTimeReleaseRandomFa = spikeTimeAlignedToLeverReleaseFa(1:fixedHoldStartsAtRelativeTrial-1)';
                        spikeTimeReleaseFixedFa = spikeTimeAlignedToLeverReleaseFa(fixedHoldStartsAtRelativeTrial:end)';
                        
                        indFixedTarget = find(val>=arrFaTrials(fixedHoldStartsAtRelativeTrial),1); %find the index in the intersection of two sets (val)
                        spikeTimeTargetRandomFa = spikeTimeOnlyTargetVisStimFa(1:indFixedTarget-1)';
                        spikeTimeTargetFixedFa = spikeTimeOnlyTargetVisStimFa(indFixedTarget:end)';
                    else
                        spikeTimeHoldRandomFa = spikeTimeAlignedToLeverHoldFa';
                        spikeTimeReleaseRandomFa = spikeTimeAlignedToLeverReleaseFa';    
                        spikeTimeTargetRandomFa = spikeTimeOnlyTargetVisStimFa';
                    end
    
                    newUnit.spikeRatePerTrialHoldRandomFa = cellfun(@length,spikeTimeHoldRandomFa)/(POST_TIME_HOLD+PRE_TIME_HOLD);
                    newUnit.spikeRatePerTrialHoldFixedFa = cellfun(@length,spikeTimeHoldFixedFa)/(POST_TIME_HOLD+PRE_TIME_HOLD);
                    newUnit.spikeRatePerTrialReleaseRandomFa = cellfun(@length,spikeTimeReleaseRandomFa)/(POST_TIME_RELEASE+PRE_TIME_RELEASE);
                    newUnit.spikeRatePerTrialReleaseFixedFa = cellfun(@length,spikeTimeReleaseFixedFa)/(POST_TIME_RELEASE+PRE_TIME_RELEASE);
                    newUnit.spikeRatePerTrialTargetRandomFa = cellfun(@length,spikeTimeTargetRandomFa)/(POST_TIME_VIS_STIM+PRE_TIME_VIS_STIM);
                    newUnit.spikeRatePerTrialTargetFixedFa = cellfun(@length,spikeTimeTargetFixedFa)/(POST_TIME_VIS_STIM+PRE_TIME_VIS_STIM);
    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MISS TRIALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [spikeTimeAlignedToLeverHoldMiss, spikeTimeAlignedToLeverReleaseMiss, spikeTimeAlignedToTargetVisStimMiss, spikeTimeAlignedToBaselineVisStimMiss, ~, ~, ~, ~, ~, ~, ~, ~, ~, fixedHoldStartsAtRelativeTrial, ~] = ...
                        chunkAlignSpikeTimes(unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrMissTrials);
                    [val,pos]=intersect(arrMissTrials,arrStimTurnedOnTrials); % returns the position on the first array
                    spikeTimeOnlyTargetVisStimMiss = spikeTimeAlignedToTargetVisStimMiss(pos);
    
                    newUnit.spikeTimeHoldMiss = spikeTimeAlignedToLeverHoldMiss;
                    newUnit.spikeTimeReleaseMiss = spikeTimeAlignedToLeverReleaseMiss;
                    newUnit.spikeTimeTargetMiss = spikeTimeAlignedToTargetVisStimMiss;
                    newUnit.spikeTimeBaselineMiss = spikeTimeAlignedToBaselineVisStimMiss;
    
                    if fixedHoldStartsAtRelativeTrial>0                        
                        spikeTimeHoldRandomMiss = spikeTimeAlignedToLeverHoldMiss(1:fixedHoldStartsAtRelativeTrial-1)';
                        spikeTimeHoldFixedMiss = spikeTimeAlignedToLeverHoldMiss(fixedHoldStartsAtRelativeTrial:end)';
                        spikeTimeReleaseRandomMiss = spikeTimeAlignedToLeverReleaseMiss(1:fixedHoldStartsAtRelativeTrial-1)';
                        spikeTimeReleaseFixedMiss = spikeTimeAlignedToLeverReleaseMiss(fixedHoldStartsAtRelativeTrial:end)';
                        
                        indFixedTarget = find(val>=arrMissTrials(fixedHoldStartsAtRelativeTrial),1); %find the index in the intersection of two sets (val)
                        spikeTimeTargetRandomMiss = spikeTimeOnlyTargetVisStimMiss(1:indFixedTarget-1)';
                        spikeTimeTargetFixedMiss = spikeTimeOnlyTargetVisStimMiss(indFixedTarget:end)';
                    else
                        spikeTimeHoldRandomMiss = spikeTimeAlignedToLeverHoldMiss';
                        spikeTimeReleaseRandomMiss = spikeTimeAlignedToLeverReleaseMiss';    
                        spikeTimeTargetRandomMiss = spikeTimeOnlyTargetVisStimMiss';
                    end
    
                    newUnit.spikeRatePerTrialHoldRandomMiss = cellfun(@length,spikeTimeHoldRandomMiss)/(POST_TIME_HOLD+PRE_TIME_HOLD);
                    newUnit.spikeRatePerTrialHoldFixedMiss = cellfun(@length,spikeTimeHoldFixedMiss)/(POST_TIME_HOLD+PRE_TIME_HOLD);
                    newUnit.spikeRatePerTrialReleaseRandomMiss = cellfun(@length,spikeTimeReleaseRandomMiss)/(POST_TIME_RELEASE+PRE_TIME_RELEASE);
                    newUnit.spikeRatePerTrialReleaseFixedMiss = cellfun(@length,spikeTimeReleaseFixedMiss)/(POST_TIME_RELEASE+PRE_TIME_RELEASE);
                    newUnit.spikeRatePerTrialTargetRandomMiss = cellfun(@length,spikeTimeTargetRandomMiss)/(POST_TIME_VIS_STIM+PRE_TIME_VIS_STIM);
                    newUnit.spikeRatePerTrialTargetFixedMiss = cellfun(@length,spikeTimeTargetFixedMiss)/(POST_TIME_VIS_STIM+PRE_TIME_VIS_STIM);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                    newUnit.spikeRatesHoldRandomAll = spikeRatesHoldRandomAll{uid};
                    newUnit.spikeRatesHoldFixedAll = spikeRatesHoldFixedAll{uid};
                    newUnit.spikeRatesHoldRandomHFM = spikeRatesHoldRandomHFM{uid};
                    newUnit.spikeRatesHoldFixedHFM = spikeRatesHoldFixedHFM{uid};
                    newUnit.spikeRatesReleaseRandomAll = spikeRatesReleaseRandomAll{uid};
                    newUnit.spikeRatesReleaseFixedAll = spikeRatesReleaseFixedAll{uid};
                    newUnit.spikeRatesReleaseRandomHFM = spikeRatesReleaseRandomHFM{uid};
                    newUnit.spikeRatesReleaseFixedHFM = spikeRatesReleaseFixedHFM{uid};
                    newUnit.spikeRatesTargetRandomAll = spikeRatesTargetRandomAll{uid};
                    newUnit.spikeRatesTargetFixedAll = spikeRatesTargetFixedAll{uid};
                    newUnit.spikeRatesTargetRandomHFM = spikeRatesTargetRandomHFM{uid};
                    newUnit.spikeRatesTargetFixedHFM = spikeRatesTargetFixedHFM{uid};
    
                    newUnit.responseTypeHoldFixedAll = responseTypeHoldFixedAll{uid};
                    newUnit.responseTypeHoldFixedHFM = responseTypeHoldFixedHFM{uid};
                    newUnit.responseTypeReleaseFixedAll = responseTypeReleaseFixedAll{uid};
                    newUnit.responseTypeReleaseFixedHFM = responseTypeReleaseFixedHFM{uid};
                    newUnit.responseTypeTargetFixedAll = responseTypeTargetFixedAll{uid};
                    newUnit.responseTypeTargetFixedHFM = responseTypeTargetFixedHFM{uid};
        
                    newUnits(uid) = newUnit;
                end
                newUnitCategoryList(cid) = newUnits;
                newUnits = [];
            end

            unitGood = newUnitCategoryList(1);
            unitMua = newUnitCategoryList(2);
            save(unitsAndVarsPath,'unitGood', 'unitMua', 'unitNoise', 'unitUnprocessed', 'leverHoldTimes', 'leverReleaseTimesGLX', 'targetStimTimesGLX', 'baselineStimTimesGLX', ...
                'trialCutIndex', 'allTrials', 'arrHitTrials', 'arrFaTrials', 'arrMissTrials', 'arrStimTurnedOnTrials', 'arrReqHoldTimes', 'arrReactTimes', ...
                'tooFastTime', 'reactTime', 'preHoldTime', 'fixedHoldStartsAtTrial','softCut','softCutPartition','hardCut','hardCutPartition');
            logger.info('saveUnitswBehavVars', [num2str(length(unitGood)) ' single units and' num2str(length(unitMua)) ' multi units are saved together with behavioral variables into :' unitsAndVarsPath]);
        end
    end
end