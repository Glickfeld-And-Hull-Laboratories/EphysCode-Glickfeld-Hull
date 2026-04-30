function acgAnalyses(unitGoodSorted, unitMuaSorted, unitNoiseSorted, unitUnprocessedSorted, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials)
    
    globals;

    if UNIT_OF_INTEREST~= -1
        unitCategory = '';
        unitOfInterest = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        if ~isempty(unitOfInterest) 
            units = unitGoodSorted;            
            unitCategory = SINGLE_UNIT;
        else % If UOI cannot be found in GOOD units, it may be in MUA
            unitOfInterest = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
            if ~isempty(unitOfInterest) 
                units = unitMuaSorted;
                unitCategory = MULTI_UNIT;
            else
                unitOfInterest = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));
                if ~isempty(unitOfInterest) 
                    units = unitNoiseSorted;
                    unitCategory = NOISE_UNIT;
                else
                    unitOfInterest = unitUnprocessedSorted(find([unitUnprocessedSorted.id]==UNIT_OF_INTEREST));
                    if ~isempty(unitOfInterest) 
                        units = unitUnprocessedSorted;
                        unitCategory = UNPROCESSED_UNIT;
                    else
                        logger.info('acgAnalyses', ['No unit with id=' num2str(UNIT_OF_INTEREST)]); 
                    end
                end
            end
        end
        if ~isempty(unitOfInterest)            
            [~, singleUnit] = plotCCGPairs([unitOfInterest.id unitOfInterest.id], unitCategory, PAIR_TYPE_ACG, units, unitOfInterest.neuronType, unitOfInterest.neuronType, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 1);            
        end
    else % plot all selected units
        
        for indACG=1:length(unitGoodSorted)
            unit = unitGoodSorted(indACG);
            [~, singleUnit] = plotCCGPairs([unit.id unit.id], SINGLE_UNIT, PAIR_TYPE_ACG, unitGoodSorted, unit.neuronType, unit.neuronType, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 1);            
        end     

        for indACG=1:length(unitMuaSorted)
            unit = unitMuaSorted(indACG);
            [~, singleUnit] = plotCCGPairs([unit.id unit.id], MULTI_UNIT, PAIR_TYPE_ACG, unitMuaSorted, unit.neuronType, unit.neuronType, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 1);
        end

        for indACG=1:length(unitNoiseSorted)
            unit = unitNoiseSorted(indACG);
            [~, singleUnit] = plotCCGPairs([unit.id unit.id], NOISE_UNIT, PAIR_TYPE_ACG, unitNoiseSorted, unit.neuronType, unit.neuronType, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 1);
            %unitNoiseSorted(indACG).singleUnit = singleUnit;
        end

        for indACG=1:length(unitUnprocessedSorted)
            unit = unitUnprocessedSorted(indACG);
            [~, singleUnit] = plotCCGPairs([unit.id unit.id], UNPROCESSED_UNIT, PAIR_TYPE_ACG, unitUnprocessedSorted, unit.neuronType, unit.neuronType, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 1);
            %unitUnprocessedSorted(indACG).singleUnit = singleUnit;
        end
    end
end