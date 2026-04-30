function unitStructToBeRemoved = removeUnrelatedFields(unitStructToBeRemoved)

        if isfield(unitStructToBeRemoved,'amplitudePerChannel') 
            unitStructToBeRemoved = rmfield(unitStructToBeRemoved,"amplitudePerChannel");
        end
            
        if isfield(unitStructToBeRemoved,'sMLIClassificationResult') 
            unitStructToBeRemoved = rmfield(unitStructToBeRemoved,"sMLIClassificationResult");
        end

        if isfield(unitStructToBeRemoved,'rateCorrectedCCGPairs') 
            unitStructToBeRemoved = rmfield(unitStructToBeRemoved,"rateCorrectedCCGPairs");
        end

        if isfield(unitStructToBeRemoved,'rateCorrectedCCGPairs0') 
            unitStructToBeRemoved = rmfield(unitStructToBeRemoved,"rateCorrectedCCGPairs0");
        end

        if isfield(unitStructToBeRemoved,'rateCorrectedCCGPairs1') 
                unitStructToBeRemoved = rmfield(unitStructToBeRemoved,"rateCorrectedCCGPairs1");
        end

        if isfield(unitStructToBeRemoved,'rateCorrectedCCGPairs2') 
                unitStructToBeRemoved = rmfield(unitStructToBeRemoved,"rateCorrectedCCGPairs2");
        end
        
        if isfield(unitStructToBeRemoved,'regularCCGSpikeRates') 
            unitStructToBeRemoved = rmfield(unitStructToBeRemoved,"regularCCGSpikeRates");
        end

        if isfield(unitStructToBeRemoved,'regularCCGSpikeRates0') 
            unitStructToBeRemoved = rmfield(unitStructToBeRemoved,"regularCCGSpikeRates0");
        end

        if isfield(unitStructToBeRemoved,'regularCCGSpikeRates1') 
                unitStructToBeRemoved = rmfield(unitStructToBeRemoved,"regularCCGSpikeRates1");
        end

        if isfield(unitStructToBeRemoved,'regularCCGSpikeRates2') 
                unitStructToBeRemoved = rmfield(unitStructToBeRemoved,"regularCCGSpikeRates2");
        end

        if isfield(unitStructToBeRemoved,'singleUnit') 
            unitStructToBeRemoved = rmfield(unitStructToBeRemoved,"singleUnit");
        end
end