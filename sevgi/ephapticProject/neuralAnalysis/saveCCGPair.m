function saveCCGPair(pairs_MLI_SS, unitGoodSorted, doRateCorrected)
    globals;

    indPair = 1;

    for iPair=1:size(pairs_MLI_SS,1)
        unitMaster = unitGoodSorted(find([unitGoodSorted.id]==pairs_MLI_SS(iPair,1)));
        unitSlave = unitGoodSorted(find([unitGoodSorted.id]==pairs_MLI_SS(iPair,2)));

        ccgSpikeRatesClassic = [];
        ccgSpikeRatesBaseline = [];
        ccgSpikeRatesFirstDrug = [];
        ccgSpikeRatesSecondDrug = [];

        if doRateCorrected    
                if isfield(unitGoodSorted,'rateCorrectedCCGPairs') % CLASSIC
                    ccgIdsVSSpikeRates = unitSlave.rateCorrectedCCGPairs;
                    ccgSpikeRatesClassic = ccgIdsVSSpikeRates(find([ccgIdsVSSpikeRates.id]==unitMaster.id));
                end
                if isfield(unitGoodSorted,'rateCorrectedCCGPairs0') % BASELINE
                    ccgIdsVSSpikeRates = unitSlave.rateCorrectedCCGPairs0;
                    ccgSpikeRatesBaseline = ccgIdsVSSpikeRates(find([ccgIdsVSSpikeRates.id]==unitMaster.id));
                end
                if isfield(unitGoodSorted,'rateCorrectedCCGPairs1') % FIRST_DRUG
                    ccgIdsVSSpikeRates = unitSlave.rateCorrectedCCGPairs1;
                    ccgSpikeRatesFirstDrug = ccgIdsVSSpikeRates(find([ccgIdsVSSpikeRates.id]==unitMaster.id));
                end
                if isfield(unitGoodSorted,'rateCorrectedCCGPairs2') % SECOND_DRUG
                    ccgIdsVSSpikeRates = unitSlave.rateCorrectedCCGPairs2;
                    ccgSpikeRatesSecondDrug = ccgIdsVSSpikeRates(find([ccgIdsVSSpikeRates.id]==unitMaster.id));
                end
        else
                if isfield(unitGoodSorted,'regularCCGSpikeRates') % CLASSIC
                    ccgIdsVSSpikeRates = unitSlave.regularCCGSpikeRates;
                    ccgSpikeRatesClassic = ccgIdsVSSpikeRates(find([ccgIdsVSSpikeRates.id]==unitMaster.id));
                end
                if isfield(unitGoodSorted,'regularCCGSpikeRates0') % BASELINE
                    ccgIdsVSSpikeRates = unitSlave.regularCCGSpikeRates0;
                    ccgSpikeRatesBaseline = ccgIdsVSSpikeRates(find([ccgIdsVSSpikeRates.id]==unitMaster.id));
                end
                if isfield(unitGoodSorted,'regularCCGSpikeRates1') % FIRST_DRUG
                    ccgIdsVSSpikeRates = unitSlave.regularCCGSpikeRates1;
                    ccgSpikeRatesFirstDrug = ccgIdsVSSpikeRates(find([ccgIdsVSSpikeRates.id]==unitMaster.id));
                end
                if isfield(unitGoodSorted,'regularCCGSpikeRates2') % SECOND_DRUG
                    ccgIdsVSSpikeRates = unitSlave.regularCCGSpikeRates2;
                    ccgSpikeRatesSecondDrug = ccgIdsVSSpikeRates(find([ccgIdsVSSpikeRates.id]==unitMaster.id));
                end            
        end

        if ~isempty(ccgSpikeRatesClassic) || ~isempty(ccgSpikeRatesBaseline) || ~isempty(ccgSpikeRatesFirstDrug) || ~isempty(ccgSpikeRatesSecondDrug) 
            unitPairs(indPair).slaveId = unitSlave.id;
            unitPairs(indPair).slaveNeuronType = unitSlave.neuronType;
            unitPairs(indPair).slaveDepth = unitSlave.depth;
            unitPairs(indPair).masterId = unitMaster.id;
            unitPairs(indPair).masterNeuronType = unitMaster.neuronType;
            unitPairs(indPair).masterDepth = unitMaster.depth;
            if ~isempty(ccgSpikeRatesClassic)
                unitPairs(indPair).ccgSpikeRatesClassic = ccgSpikeRatesClassic.spikeRates(1:end-1);
            end            
            if ~isempty(ccgSpikeRatesBaseline)
                unitPairs(indPair).ccgSpikeRatesBaseline = ccgSpikeRatesBaseline.spikeRates(1:end-1);
            end
            if ~isempty(ccgSpikeRatesFirstDrug)
                unitPairs(indPair).ccgSpikeRatesFirstDrug = ccgSpikeRatesFirstDrug.spikeRates(1:end-1);
            end
            if ~isempty(ccgSpikeRatesSecondDrug)
                unitPairs(indPair).ccgSpikeRatesSecondDrug = ccgSpikeRatesSecondDrug.spikeRates(1:end-1);
            end
            indPair = (indPair)+1;
        end

    end
    
    edges = -X_MAX_CCG-BIN_SIZE_CCG:BIN_SIZE_CCG:X_MAX_CCG+BIN_SIZE_CCG;
    edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;

    unitPairsPath = [pathToCollaboratorsFolder UNIT_CCG_PAIRS_FILE_NAME];
    if exist(unitPairsPath,'file')
        oldData = load(unitPairsPath);
        unitPairs = [oldData.unitPairs unitPairs];
    end
    save(unitPairsPath,'unitPairs', 'edgesPlt', '-v7.3');
end