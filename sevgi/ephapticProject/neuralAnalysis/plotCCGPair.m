function [needToSave, unitGoodSorted] = plotCCGPair(unitPairMaster, unitPairSlave, ccgFolder, neuronTypeMaster, neuronTypeSlave, unitGoodSorted, movingTimesToBeExcluded)
    globals;

    needToSave = 0;
    synchExcFirstDrug = 0;
    synchInhFirstDrug = 0;
    synchExcSecondDrug = 0;
    synchInhSecondDrug = 0;

    f = figure;    
    f.Position = [globalX globalY globalW globalH]; 
    hold on;

    [~, ~, ~, synchExc, synchInh, unitGoodSorted, readForTheFirstTime, ~, ~] = correlogramRateCorrected([unitPairMaster.id unitPairSlave.id], ccgFolder, unitGoodSorted, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimesToBeExcluded, BASELINE, 'k', 1, 0);                    
    if readForTheFirstTime
        needToSave = 1;
    end

    sDrugConditions = '';
    if isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
        [~, ~, ~, synchExcFirstDrug, synchInhFirstDrug, unitGoodSorted, readForTheFirstTime, ~, ~] = correlogramRateCorrected([unitPairMaster.id unitPairSlave.id], ccgFolder, unitGoodSorted, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, movingTimesToBeExcluded, FIRST_DRUG, 'r', 1, 0);
        if readForTheFirstTime
            needToSave = 1;
        end
        sDrugConditions = [BASELINE '_VS_' FIRST_DRUG];
    else
        [~, ~, ~, synchExcFirstDrug, synchInhFirstDrug, unitGoodSorted, readForTheFirstTime, ~, ~] = correlogramRateCorrected([unitPairMaster.id unitPairSlave.id], ccgFolder, unitGoodSorted, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, movingTimesToBeExcluded, FIRST_DRUG, 'r', 1, 0);
        if readForTheFirstTime
            needToSave = 1;
        end

        [~, ~, ~, synchExcSecondDrug, synchInhSecondDrug, unitGoodSorted, readForTheFirstTime, ~, ~] = correlogramRateCorrected([unitPairMaster.id unitPairSlave.id], ccgFolder, unitGoodSorted, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, movingTimesToBeExcluded, SECOND_DRUG, 'b', 1, 0);
        if readForTheFirstTime
            needToSave = 1;
        end             
        sDrugConditions = [BASELINE '_VS_' FIRST_DRUG '_VS_' SECOND_DRUG];
    end

    if synchExc == 1
        logger.info('ccgAnalyses', ['WHOOOOOAAAA there is a synchrony in excitation during BASELINE! Check the latency of synchrony! ' neuronTypeSlave '_' num2str(unitPairSlave.id) '(' num2str(unitPairSlave.depth) 'um) ' neuronTypeMaster '_' num2str(unitPairMaster.id) '(' num2str(unitPairMaster.depth) 'um)']);
    end
    if synchInh == 1
        logger.info('ccgAnalyses', ['WHOOOOOAAAA there is a synchrony in inhibition during BASELINE! THIS IS THE PAIR YOU ARE LOOKING FOR ' neuronTypeSlave '_' num2str(unitPairSlave.id) '(' num2str(unitPairSlave.depth) 'um) ' neuronTypeMaster '_' num2str(unitPairMaster.id) '(' num2str(unitPairMaster.depth) 'um)']);
    end
    if synchExcFirstDrug == 1
        logger.info('ccgAnalyses', ['WHOOOOOAAAA there is a synchrony in excitation during FIRST DRUG! Check the latency of synchrony! ' neuronTypeSlave '_' num2str(unitPairSlave.id) '(' num2str(unitPairSlave.depth) 'um) ' neuronTypeMaster '_' num2str(unitPairMaster.id) '(' num2str(unitPairMaster.depth) 'um)']);
    end
    if synchInhFirstDrug == 1
        logger.info('ccgAnalyses', ['WHOOOOOAAAA there is a synchrony in inhibition during FIRST DRUG! THIS IS THE PAIR YOU ARE LOOKING FOR ' neuronTypeSlave '_' num2str(unitPairSlave.id) '(' num2str(unitPairSlave.depth) 'um) ' neuronTypeMaster '_' num2str(unitPairMaster.id) '(' num2str(unitPairMaster.depth) 'um)']);
    end
    if synchExcSecondDrug == 1
        logger.info('ccgAnalyses', ['WHOOOOOAAAA there is a synchrony in excitation during SECOND DRUG! Check the latency of synchrony! ' neuronTypeSlave '_' num2str(unitPairSlave.id) '(' num2str(unitPairSlave.depth) 'um) ' neuronTypeMaster '_' num2str(unitPairMaster.id) '(' num2str(unitPairMaster.depth) 'um)']);
    end
    if synchInhSecondDrug == 1
        logger.info('ccgAnalyses', ['WHOOOOOAAAA there is a synchrony in inhibition during SECOND DRUG! THIS IS THE PAIR YOU ARE LOOKING FOR ' neuronTypeSlave '_' num2str(unitPairSlave.id) '(' num2str(unitPairSlave.depth) 'um) ' neuronTypeMaster '_' num2str(unitPairMaster.id) '(' num2str(unitPairMaster.depth) 'um)']);
    end
    print([pathToCollaboratorsFolder ccgFolder '/CCG_' num2str(unitPairSlave.id) 'wrt' num2str(unitPairMaster.id) '_' sDrugConditions '.tif'], '-dtiff', '-r120');
    exportgraphics(f,[pathToCollaboratorsFolder ccgFolder '/CCG_' num2str(unitPairSlave.id) 'wrt' num2str(unitPairMaster.id) '_' sDrugConditions '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
    savefig([pathToCollaboratorsFolder ccgFolder '/CCG_' num2str(unitPairSlave.id) 'wrt' num2str(unitPairMaster.id) '_' sDrugConditions '.fig']);

    close all;
end