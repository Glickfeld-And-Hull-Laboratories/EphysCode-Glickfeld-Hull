%%%% Plot CCGs of paired units %%%%%%%%%%%%
% pairs: pairs found effecting eachother
% units: all good units]
% SO 2/17/2023 Hull Lab
function [suppressedPairs, singleUnit] = plotCCGPairs(pairs, unitCategory, pairType, units, sPair1, sPair2, isACG)
    globals;
    nPairs = size(pairs,1);
    suppressedPairs = zeros(1,nPairs);

    if pairType == PAIR_TYPE_ACG
        ccgType = ACG;
    elseif pairType == PAIR_TYPE_CS_SS
        ccgType = CS_SS;        
    elseif pairType == PAIR_TYPE_MF_SS
        ccgType = MF_SS;
    elseif pairType == PAIR_TYPE_MF_GO
        ccgType = MF_GO;
    elseif pairType == PAIR_TYPE_GO_SS
        ccgType = GO_SS;
    elseif pairType == PAIR_TYPE_MLI_SS
        ccgType = MLI_SS;
    elseif pairType == PAIR_TYPE_SS_DCN
        ccgType = SS_DCN;
    elseif pairType == PAIR_TYPE_SS_SS
        ccgType = SS_SS;
    elseif pairType == PAIR_TYPE_MLI_MLI
        ccgType = MLI_MLI;
    elseif pairType == PAIR_TYPE_GO_GO
        ccgType = GO_GO;  
    elseif pairType == PAIR_TYPE_OTHER_SS
        ccgType = OTHER_SS;
    elseif pairType == PAIR_TYPE_OTHER_CS
        ccgType = OTHER_CS;
    elseif pairType == PAIR_TYPE_OTHER_MF
        ccgType = OTHER_MF;
    elseif pairType == PAIR_TYPE_OTHER_GO
        ccgType = OTHER_GO;
    elseif pairType == PAIR_TYPE_OTHER_MLI
        ccgType = OTHER_MLI;
    elseif pairType == PAIR_TYPE_OTHER_OTHER
        ccgType = OTHER_OTHER;
    end

    singleUnit = 0;
    if ~isempty(pairs)        
        for iPair=1:nPairs
            unitPair1 = units(find([units.id]==pairs(iPair,1)));
            unitPair2 = units(find([units.id]==pairs(iPair,2)));
            
            if ~isempty(unitPair1) && ~isempty(unitPair2) % && unitPair1.id==297 && unitPair2.id == 279 %&& unitPair1.id==339 && unitPair2.id == 97 %&& unitPair1.id==291 && unitPair2.id == 285
                logger.info('plotCCGPairs', ['Will plot ' ccgType ' for ' sPair1 '_' num2str(unitPair1.id) '(' num2str(unitPair1.depth) 'um) ' sPair2 '_' num2str(unitPair2.id) '(' num2str(unitPair2.depth) 'um)']);
%                 [suppressedAll, singleUnit] = plotCCG(ccgType, unitCategory, unitPair1.id, unitPair2.id, unitPair1.spikeTimesSecs', unitPair2.spikeTimesSecs', leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, [sPair1 '(' num2str(unitPair1.depth) 'um) ' sPair2 '(' num2str(unitPair2.depth) 'um)'], isACG, unitPair1.neuronType);
%                 [suppressedClassic, singleUnit] = correlogram(ccgType, unitCategory, unitRefID, unitTargetID, unitRefSpikeTimesTrialITIAlignedToLeverHold, unitTargetSpikeTimesTrialITIAlignedToLeverHold, trialCount, ['Classic ' whichCellTypes], isACG, neuronType);
                             correlogram([unitPair1.id unitPair2.id], ccgType, unitMuaSorted, unitMuaSorted, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, FIRST_DRUG);
                             correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitGoodSorted, unitGoodSorted, 0, MOMENT_OF_1ST_DRUG_PUT_IN, BASELINE);
                if suppressedAll
                    suppressedPairs(iPair) = 1;
                end
            end
        end
    end
    
end