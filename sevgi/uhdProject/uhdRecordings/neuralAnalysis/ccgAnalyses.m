function ccgAnalyses(unitGoodSorted, unitMuaSorted, laserOnsetTimesGLX, laserOffsetTimesGLX)
    
    globals;

    if UNIT_OF_INTEREST~=-1 && UNIT_OF_INTEREST2~=-1

        unitsMaster = [];
        if UNIT_OF_INTEREST~= -1    
            unitOfInterest = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
            if ~isempty(unitOfInterest) 
                unitsMaster = unitGoodSorted;            
            else % If UOI cannot be found in GOOD units, it may be in MUA
                unitOfInterest = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
                if ~isempty(unitOfInterest) 
                    unitsMaster = unitMuaSorted;
                else
                    logger.info('main', ['No unit info for UNIT_OF_INTEREST id=' numstr(UNIT_OF_INTEREST)]);
                end
            end  
        end
        unitsSlave = [];
        if UNIT_OF_INTEREST2~= -1    
            unitOfInterest2 = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST2));
            if ~isempty(unitOfInterest2) 
                unitsSlave = unitGoodSorted;            
            else % If UOI cannot be found in GOOD units, it may be in MUA
                unitOfInterest2 = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST2));
                if ~isempty(unitOfInterest2) 
                    unitsSlave = unitMuaSorted;
                else
                    logger.info('main', ['No unit info for UNIT_OF_INTEREST2 id=' numstr(UNIT_OF_INTEREST2)]);
                end
            end
        end
        if ~isempty(unitOfInterest) && ~isempty(unitOfInterest2)
            [singleUnit] = correlogram([unitOfInterest.id unitOfInterest2.id], PAIR_TYPE_MF_OTHER, unitsMaster, unitsSlave, laserOnsetTimesGLX, laserOffsetTimesGLX);
            correlogram([unitOfInterest.id unitOfInterest2.id], PAIR_TYPE_MF_OTHER, unitsMaster, unitsSlave, laserOnsetTimesGLX, laserOffsetTimesGLX, 0, MOMENT_OF_1ST_DRUG_PUT_IN, BASELINE);
            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                correlogram([unitOfInterest.id unitOfInterest2.id], PAIR_TYPE_MF_OTHER, unitsMaster, unitsSlave, laserOnsetTimesGLX, laserOffsetTimesGLX, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, FIRST_DRUG);
                correlogram([unitOfInterest.id unitOfInterest2.id], PAIR_TYPE_MF_OTHER, unitsMaster, unitsSlave, laserOnsetTimesGLX, laserOffsetTimesGLX, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, SECOND_DRUG);
            else
                correlogram([unitOfInterest.id unitOfInterest2.id], PAIR_TYPE_MF_OTHER, unitsMaster, unitsSlave, laserOnsetTimesGLX, laserOffsetTimesGLX, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, FIRST_DRUG);
            end            
        end
        
     else % plot all selected units
        for indACG=1:length(unitGoodSorted)
            unitOfInterest = unitGoodSorted(indACG);
            for indACG2=1:length(unitGoodSorted)
                unitOfInterest2 = unitGoodSorted(indACG2);
                [singleUnit] = correlogram([unitOfInterest.id unitOfInterest2.id], PAIR_TYPE_MF_OTHER, unitGoodSorted, unitGoodSorted, laserOnsetTimesGLX, laserOffsetTimesGLX);
                correlogram([unitOfInterest.id unitOfInterest2.id], PAIR_TYPE_MF_OTHER, unitGoodSorted, unitGoodSorted, laserOnsetTimesGLX, laserOffsetTimesGLX, 0, MOMENT_OF_1ST_DRUG_PUT_IN, BASELINE);
                if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                    correlogram([unitOfInterest.id unitOfInterest2.id], PAIR_TYPE_MF_OTHER, unitGoodSorted, unitGoodSorted, laserOnsetTimesGLX, laserOffsetTimesGLX, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, FIRST_DRUG);
                    correlogram([unitOfInterest.id unitOfInterest2.id], PAIR_TYPE_MF_OTHER, unitGoodSorted, unitGoodSorted, laserOnsetTimesGLX, laserOffsetTimesGLX, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, SECOND_DRUG);
                else
                    correlogram([unitOfInterest.id unitOfInterest2.id], PAIR_TYPE_MF_OTHER, unitGoodSorted, unitGoodSorted, laserOnsetTimesGLX, laserOffsetTimesGLX, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, FIRST_DRUG);
                end
            end
        end 
        logger.info('main', 'Good units'' ACGs are plotted!');
     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     if UNIT_OF_INTEREST~= -1
%         unitOfInterest = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
%         if ~isempty(unitOfInterest) 
%             units = unitGoodSorted;            
%         else % If UOI cannot be found in GOOD units, it may be in MUA
%             unitOfInterest = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
%             if ~isempty(unitOfInterest) 
%                 units = unitMuaSorted;
%             else
%                 logger.info('ccgAnalyses', ['No unit info for unit id=' numstr(UNIT_OF_INTEREST)]);
%             end
%         end
%         if ~isempty(unitOfInterest)
% 
%             [singleUnit] = correlogram([unitOfInterest.id unitPair2.id], PAIR_TYPE_CS_SS, units);
%         end
%     else % plot all selected units
%         
%         pairs_CS_SS = findPairs(unitGoodSorted, PAIR_TYPE_CS_SS, NEURON_TYPE_CS, NEURON_TYPE_SS, PAIR_CS_SS_MAX_LAYER_DISTANCE, []);
%         pairs_DCS_SS = findPairs(unitGoodSorted, PAIR_TYPE_CS_SS, NEURON_TYPE_DCS, NEURON_TYPE_SS, PAIR_CS_SS_MAX_LAYER_DISTANCE, []);
%         pairs_MF_GO = findPairs(unitGoodSorted, PAIR_TYPE_MF_GO, NEURON_TYPE_MF, NEURON_TYPE_GoC, PAIR_MF_GO_MAX_LAYER_DISTANCE, []);
%         pairs_GO_SS = findPairs(unitGoodSorted, PAIR_TYPE_GO_SS, NEURON_TYPE_GoC, NEURON_TYPE_SS, PAIR_GO_SS_MAX_LAYER_DISTANCE, []);
%         pairs_MLI_SS = findPairs(unitGoodSorted, PAIR_TYPE_MLI_SS, NEURON_TYPE_BC_SC, NEURON_TYPE_SS, PAIR_MLI_SS_MAX_LAYER_DISTANCE, []);
%         pairs_MF_SS = findPairs(unitGoodSorted, PAIR_TYPE_MF_SS, NEURON_TYPE_MF, NEURON_TYPE_SS, PAIR_MF_SS_MAX_LAYER_DISTANCE, []);        
%         pairs_SS_DCN = findPairs(unitGoodSorted, PAIR_TYPE_SS_DCN, NEURON_TYPE_SS, NEURON_TYPE_DCN, PAIR_SS_DCN_MAX_LAYER_DISTANCE, []);
% 
%         % Now look at the cell types inhibiting each other or excited together (synchronous)
%         pairs_MLI_MLI = findPairs(unitGoodSorted, PAIR_TYPE_MLI_MLI, NEURON_TYPE_BC_SC, NEURON_TYPE_BC_SC, PAIR_MLI_MLI_MAX_LAYER_DISTANCE, []);
%         pairs_GO_GO = findPairs(unitGoodSorted, PAIR_TYPE_GO_GO, NEURON_TYPE_GoC, NEURON_TYPE_GoC, PAIR_GO_GO_MAX_LAYER_DISTANCE, []);
%         pairs_SS_SS = findPairs(unitGoodSorted, PAIR_TYPE_SS_SS, NEURON_TYPE_SS, NEURON_TYPE_SS, PAIR_SS_SS_MAX_LAYER_DISTANCE, []);
% 
%         [suppressedPairs_CS_SS, ~] = plotCCGPairs([pairs_CS_SS; pairs_DCS_SS], PAIR_TYPE_CS_SS, unitGoodSorted,NEURON_TYPE_CS,NEURON_TYPE_SS, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
%         [suppressedPairs_MF_GO, ~] = plotCCGPairs(pairs_MF_GO, PAIR_TYPE_MF_GO, unitGoodSorted,NEURON_TYPE_MF,NEURON_TYPE_GoC, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
%         [suppressedPairs_GO_SS, ~] = plotCCGPairs(pairs_GO_SS, PAIR_TYPE_GO_SS, unitGoodSorted,NEURON_TYPE_GoC,NEURON_TYPE_SS, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
%         [suppressedPairs_MLI_SS, ~] = plotCCGPairs(pairs_MLI_SS, PAIR_TYPE_MLI_SS, unitGoodSorted,NEURON_TYPE_BC_SC,NEURON_TYPE_SS, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
%         [suppressedPairs_MF_SS, ~] = plotCCGPairs(pairs_MF_SS, PAIR_TYPE_MF_SS, unitGoodSorted,NEURON_TYPE_MF,NEURON_TYPE_SS, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);      
%         [suppressedPairs_SS_DN, ~] = plotCCGPairs(pairs_SS_DCN, PAIR_TYPE_SS_DCN, unitGoodSorted, NEURON_TYPE_SS, NEURON_TYPE_DCN, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
%                 
%         [suppressedPairs_MLI_MLI, ~] = plotCCGPairs(pairs_MLI_MLI, PAIR_TYPE_MLI_MLI, unitGoodSorted,NEURON_TYPE_BC_SC,NEURON_TYPE_BC_SC, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
%         [suppressedPairs_GO_GO, ~] = plotCCGPairs(pairs_GO_GO, PAIR_TYPE_GO_GO, unitGoodSorted,NEURON_TYPE_GoC,NEURON_TYPE_GoC, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
%         [suppressedPairs_SS_SS, ~] = plotCCGPairs(pairs_SS_SS, PAIR_TYPE_SS_SS, unitGoodSorted,NEURON_TYPE_SS,NEURON_TYPE_SS, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
% 
%         pairs_Other_SS = findPairs(unitGoodSorted, PAIR_TYPE_OTHER_SS, NEURON_TYPE_OTHER, NEURON_TYPE_SS, PAIR_OTHER_MAX_LAYER_DISTANCE, []);
%         plotCCGPairs(pairs_Other_SS, PAIR_TYPE_OTHER_SS, unitGoodSorted,NEURON_TYPE_OTHER,NEURON_TYPE_SS, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
% 
%         pairs_Other_CS = findPairs(unitGoodSorted, PAIR_TYPE_OTHER_CS, NEURON_TYPE_OTHER, NEURON_TYPE_CS, PAIR_OTHER_MAX_LAYER_DISTANCE, []);
%         plotCCGPairs(pairs_Other_CS, PAIR_TYPE_OTHER_CS, unitGoodSorted,NEURON_TYPE_OTHER,NEURON_TYPE_CS, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
% 
%         pairs_Other_MF = findPairs(unitGoodSorted, PAIR_TYPE_OTHER_MF, NEURON_TYPE_OTHER, NEURON_TYPE_MF, PAIR_OTHER_MAX_LAYER_DISTANCE, []);
%         plotCCGPairs(pairs_Other_MF, PAIR_TYPE_OTHER_MF, unitGoodSorted,NEURON_TYPE_OTHER,NEURON_TYPE_MF, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
% 
%         pairs_Other_GO = findPairs(unitGoodSorted, PAIR_TYPE_OTHER_GO, NEURON_TYPE_OTHER, NEURON_TYPE_GoC, PAIR_OTHER_MAX_LAYER_DISTANCE, []);
%         plotCCGPairs(pairs_Other_GO, PAIR_TYPE_OTHER_GO, unitGoodSorted,NEURON_TYPE_OTHER,NEURON_TYPE_GoC, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
%         
%         pairs_Other_MLI = findPairs(unitGoodSorted, PAIR_TYPE_OTHER_MLI, NEURON_TYPE_OTHER, NEURON_TYPE_BC_SC, PAIR_OTHER_MAX_LAYER_DISTANCE, []);
%         plotCCGPairs(pairs_Other_MLI, PAIR_TYPE_OTHER_MLI, unitGoodSorted,NEURON_TYPE_OTHER,NEURON_TYPE_BC_SC, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
% 
%         % TODO: Other to Other CCG
%     end
end