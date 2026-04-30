function flag = isNotStoredPreviously(sWhichPhase, units, masterId, slaveId, unitMasterID, unitSlaveID, doRateCorrected)
    globals;

    flag = 1;
    if doRateCorrected   
            if strcmp(sWhichPhase,CLASSIC)
                flag = ~isfield(units(slaveId),'rateCorrectedCCGPairs') ... % CLASSIC 
                        || ((isempty(units(slaveId).rateCorrectedCCGPairs) || ~any([units(slaveId).rateCorrectedCCGPairs.id]==unitMasterID)) ...
                        && (isempty(units(masterId).rateCorrectedCCGPairs) || ~any([units(masterId).rateCorrectedCCGPairs.id]==unitSlaveID)));                
            elseif strcmp(sWhichPhase,BASELINE)
                flag = ~isfield(units(slaveId),'rateCorrectedCCGPairs0') ...  % BASELINE
                        || ((isempty(units(slaveId).rateCorrectedCCGPairs0) || ~any([units(slaveId).rateCorrectedCCGPairs0.id]==unitMasterID)) ...
                        && (isempty(units(masterId).rateCorrectedCCGPairs0) || ~any([units(masterId).rateCorrectedCCGPairs0.id]==unitSlaveID)));
            elseif strcmp(sWhichPhase,FIRST_DRUG)
                flag = ~isfield(units(slaveId),'rateCorrectedCCGPairs1') ...  % FIRST_DRUG
                        || ((isempty(units(slaveId).rateCorrectedCCGPairs1) || ~any([units(slaveId).rateCorrectedCCGPairs1.id]==unitMasterID)) ...
                        && (isempty(units(masterId).rateCorrectedCCGPairs1) || ~any([units(masterId).rateCorrectedCCGPairs1.id]==unitSlaveID)));                
            elseif strcmp(sWhichPhase,SECOND_DRUG)
                flag = ~isfield(units(slaveId),'rateCorrectedCCGPairs2') ...  % SECOND_DRUG
                        || ((isempty(units(slaveId).rateCorrectedCCGPairs2) || ~any([units(slaveId).rateCorrectedCCGPairs2.id]==unitMasterID)) ...
                        && (isempty(units(masterId).rateCorrectedCCGPairs2) || ~any([units(masterId).rateCorrectedCCGPairs2.id]==unitSlaveID)));
            end
    else
            if strcmp(sWhichPhase,CLASSIC)
                flag = ~isfield(units(slaveId),'regularCCGSpikeRates') ...  
                        || ((isempty(units(slaveId).regularCCGSpikeRates) || ~any([units(slaveId).regularCCGSpikeRates.id]==unitMasterID)) ...
                        && (isempty(units(masterId).regularCCGSpikeRates) || ~any([units(masterId).regularCCGSpikeRates.id]==unitSlaveID)));            
            elseif strcmp(sWhichPhase,BASELINE)
                flag = ~isfield(units(slaveId),'regularCCGSpikeRates0') ...  
                        || ((isempty(units(slaveId).regularCCGSpikeRates0) || ~any([units(slaveId).regularCCGSpikeRates0.id]==unitMasterID)) ...
                        && (isempty(units(masterId).regularCCGSpikeRates0) || ~any([units(masterId).regularCCGSpikeRates0.id]==unitSlaveID)));
            elseif strcmp(sWhichPhase,FIRST_DRUG)
                flag = ~isfield(units(slaveId),'regularCCGSpikeRates1') ...  
                        || ((isempty(units(slaveId).regularCCGSpikeRates1) || ~any([units(slaveId).regularCCGSpikeRates1.id]==unitMasterID)) ...
                        && (isempty(units(masterId).regularCCGSpikeRates1) || ~any([units(masterId).regularCCGSpikeRates1.id]==unitSlaveID)));                
            elseif strcmp(sWhichPhase,SECOND_DRUG)
                flag = ~isfield(units(slaveId),'regularCCGSpikeRates2') ...  
                        || ((isempty(units(slaveId).regularCCGSpikeRates2) || ~any([units(slaveId).regularCCGSpikeRates2.id]==unitMasterID)) ...
                        && (isempty(units(masterId).regularCCGSpikeRates2) || ~any([units(masterId).regularCCGSpikeRates2.id]==unitSlaveID)));
            end
    end
end