function unitGoodSorted = acgAnalyses(unitGoodSorted, unitMuaSorted, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials)
    
    globals;

    if UNIT_OF_INTEREST~= -1
        unitOfInterest = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        if ~isempty(unitOfInterest) 
            units = unitGoodSorted;            
        else % If UOI cannot be found in GOOD units, it may be in MUA
            unitOfInterest = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
            if ~isempty(unitOfInterest) 
                units = unitMuaSorted;
            else
                disp('No unit info!')
            end
        end
        if ~isempty(unitOfInterest)            
            [~, singleUnit] = plotCCGPairs([unitOfInterest.id unitOfInterest.id], PAIR_TYPE_ACG, units, unitOfInterest.expertLabel, unitOfInterest.expertLabel, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 1);            
            unitOfInterest.singleUnit = singleUnit;
        end
    else % plot all selected units
        
        for indACG=1:length(unitGoodSorted)
            unit = unitGoodSorted(indACG);
            [~, singleUnit] = plotCCGPairs([unit.id unit.id], PAIR_TYPE_ACG, unitGoodSorted, unit.expertLabel, unit.expertLabel, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 1);
            unitGoodSorted(indACG).singleUnit = singleUnit;
        end        
    end
end