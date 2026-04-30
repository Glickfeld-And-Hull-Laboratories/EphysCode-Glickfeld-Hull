function [needToSave, unitGoodSorted] = saveCCGDataForCollaborators(unitsOfInterest, unitGoodSorted, movingTimesToBeExcluded)

    globals;

    % SS-MLI pairs
    [needToSave1, unitGoodSorted] = plotAndSavePairsForCollaborators(unitsOfInterest, PAIR_TYPE_SS_MLI, NEURON_TYPE_MLI, NEURON_TYPE_SS, PAIR_SS_MLI_MAX_LAYER_DISTANCE, SS_MLI, unitGoodSorted, movingTimesToBeExcluded);
    % SS-SS pairs
    [needToSave2, unitGoodSorted] = plotAndSavePairsForCollaborators(unitsOfInterest, PAIR_TYPE_SS_SS, NEURON_TYPE_SS, NEURON_TYPE_SS, PAIR_SS_SS_MAX_LAYER_DISTANCE, SS_SS, unitGoodSorted, movingTimesToBeExcluded);
    % MLI-MLI pairs
    [needToSave3, unitGoodSorted] = plotAndSavePairsForCollaborators(unitsOfInterest, PAIR_TYPE_MLI_MLI, NEURON_TYPE_MLI, NEURON_TYPE_MLI, PAIR_MLI_MLI_MAX_LAYER_DISTANCE, MLI_MLI, unitGoodSorted, movingTimesToBeExcluded);

    needToSave = any([needToSave1 needToSave2 needToSave3]);
    logger.info('saveCCGDataForCollaborators', 'Saved CCG Data!');
end