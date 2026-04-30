%%%% Plot CCGs of paired units %%%%%%%%%%%%
% pairs: pairs found effecting eachother
% units: all good units]
% SO 2/17/2023 Hull Lab
function [suppressedPairs, singleUnit] = plotCCGPairs(pairs, unitCategory, pairType, units, sPair1, sPair2, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, isACG)
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
                [suppressedAll, singleUnit] = plotCCG(ccgType, unitCategory, unitPair1.id, unitPair2.id, unitPair1.spikeTimesSecs', unitPair2.spikeTimesSecs', leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, [sPair1 '(' num2str(unitPair1.depth) 'um) ' sPair2 '(' num2str(unitPair2.depth) 'um)'], isACG, unitPair1.neuronType);
                               
                suppressedHit = 0;
                suppressedMiss = 0;
                suppressedFa = 0;
                
%                 if isACG % if checkDevFlag==0, this means ACG is plotted
%                     logger.info('plotCCGPairs', ['Will plot ' ccgType ' for HIT ' sPair1 '_' num2str(unitPair1.id) '(' num2str(unitPair1.depth) 'um) ' sPair2 '_' num2str(unitPair2.id) '(' num2str(unitPair2.depth) 'um)']);
%                     [suppressedHit, ~] = plotCCG(ccgType, unitCategory, unitPair1.id, unitPair2.id, unitPair1.spikeTimesSecs', unitPair2.spikeTimesSecs', leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, arrHitTrials, ['HIT ' sPair1 '(' num2str(unitPair1.depth) 'um) ' sPair2 '(' num2str(unitPair2.depth) 'um)'], isACG);
%                     
%                     logger.info('plotCCGPairs', ['Will plot ' ccgType ' for MISS ' sPair1 '_' num2str(unitPair1.id) '(' num2str(unitPair1.depth) 'um) ' sPair2 '_' num2str(unitPair2.id) '(' num2str(unitPair2.depth) 'um)']);
%                     [suppressedMiss, ~] = plotCCG(ccgType, unitCategory, unitPair1.id, unitPair2.id, unitPair1.spikeTimesSecs', unitPair2.spikeTimesSecs', leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, arrMissTrials, ['MISS ' sPair1 '(' num2str(unitPair1.depth) 'um) ' sPair2 '(' num2str(unitPair2.depth) 'um)'], isACG);
%                     
%                     logger.info('plotCCGPairs', ['Will plot ' ccgType ' for FA ' sPair1 '_' num2str(unitPair1.id) '(' num2str(unitPair1.depth) 'um) ' sPair2 '_' num2str(unitPair2.id) '(' num2str(unitPair2.depth) 'um)']);
%                     [suppressedFa, ~] = plotCCG(ccgType, unitCategory, unitPair1.id, unitPair2.id, unitPair1.spikeTimesSecs', unitPair2.spikeTimesSecs', leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, arrFaTrials, ['FA ' sPair1 '(' num2str(unitPair1.depth) 'um) ' sPair2 '(' num2str(unitPair2.depth) 'um)'], isACG);
%                 end

                if suppressedAll || suppressedHit || suppressedMiss || suppressedFa
                    suppressedPairs(iPair) = 1;
                end
            end
        end
    end
    
end