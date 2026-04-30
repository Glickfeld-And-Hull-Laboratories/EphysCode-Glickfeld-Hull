function [needToSave, unitGoodSorted] = plotAndSavePairsForCollaborators(unitsOfInterest, pairType, neuronTypeMaster, neuronTypeSlave, maxDistance, pairFolder, unitGoodSorted, movingTimesToBeExcluded)

    globals;
    
    pairs_MLI_SS = findPairs(unitsOfInterest, pairType, neuronTypeMaster, neuronTypeSlave, maxDistance, []);
        
    needToSave = 0;
    if ~isempty(pairs_MLI_SS)        
        for iPair=1:size(pairs_MLI_SS,1)
            unitPairMLI = unitsOfInterest(find([unitsOfInterest.id]==pairs_MLI_SS(iPair,1)));
            unitPairSS = unitsOfInterest(find([unitsOfInterest.id]==pairs_MLI_SS(iPair,2)));
            
            if ~isempty(unitPairMLI) && ~isempty(unitPairSS)
                logger.info('plotAndSavePairsForCollaborators', ['Will plot ' pairFolder ' for ' neuronTypeSlave '_' num2str(unitPairSS.id) '(' num2str(unitPairSS.depth) 'um) ' neuronTypeMaster '_' num2str(unitPairMLI.id) '(' num2str(unitPairMLI.depth) 'um)']);
                [needToSave, unitGoodSorted] = plotCCGPair(unitPairMLI, unitPairSS, pairFolder, neuronTypeMaster, neuronTypeSlave, unitGoodSorted, movingTimesToBeExcluded);                                
            end
        end

        saveCCGPair(pairs_MLI_SS, unitGoodSorted, 0);
    end
end