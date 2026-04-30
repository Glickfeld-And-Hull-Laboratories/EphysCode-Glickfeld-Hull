function [slaveSpikeRates, semSpikeRates] = getRates(sWhichPhase, units, slaveId, unitMasterID, doRateCorrected)
        globals;

        if doRateCorrected   
            if strcmp(sWhichPhase,CLASSIC)
                if isfield(units(slaveId),'rateCorrectedCCGPairs') && ~isempty(units(slaveId).rateCorrectedCCGPairs)
                    indForCCG = find([units(slaveId).rateCorrectedCCGPairs.id]==unitMasterID);
                    if ~isempty(indForCCG) && indForCCG>0
                        slaveSpikeRates = units(slaveId).rateCorrectedCCGPairs(indForCCG).spikeRates; 
                        semSpikeRates = units(slaveId).rateCorrectedCCGPairs(indForCCG).semSpikeRates;
                    else
                        logger.info('getRates',['Something went WRONG!! Couldnt find rateCorrectedCCGPairs field for unitMasterID=' num2str(unitMasterID) ' of slaveId=' num2str(slaveId)]);
                    end
                else
                    logger.info('getRates',['Something went WRONG!! Couldnt find rateCorrectedCCGPairs field for slaveId=' num2str(slaveId)]);
                end
            elseif strcmp(sWhichPhase,BASELINE)
                if isfield(units(slaveId),'rateCorrectedCCGPairs0') && ~isempty(units(slaveId).rateCorrectedCCGPairs0)
                    indForCCG = find([units(slaveId).rateCorrectedCCGPairs0.id]==unitMasterID);
                    if ~isempty(indForCCG) && indForCCG>0
                        slaveSpikeRates = units(slaveId).rateCorrectedCCGPairs0(indForCCG).spikeRates;   
                        semSpikeRates = units(slaveId).rateCorrectedCCGPairs0(indForCCG).semSpikeRates;   
                    else
                        logger.info('getRates',['Something went WRONG!! Couldnt find rateCorrectedCCGPairs0 field for unitMasterID=' num2str(unitMasterID) ' of slaveId=' num2str(slaveId)]);
                    end
                else
                    logger.info('getRates',['Something went WRONG!! Couldnt find rateCorrectedCCGPairs0 field for slaveId=' num2str(slaveId)]);
                end
            elseif strcmp(sWhichPhase,FIRST_DRUG)
                if isfield(units(slaveId),'rateCorrectedCCGPairs1') && ~isempty(units(slaveId).rateCorrectedCCGPairs1)
                    indForCCG = find([units(slaveId).rateCorrectedCCGPairs1.id]==unitMasterID);
                    if ~isempty(indForCCG) && indForCCG>0
                        slaveSpikeRates = units(slaveId).rateCorrectedCCGPairs1(indForCCG).spikeRates;   
                        semSpikeRates = units(slaveId).rateCorrectedCCGPairs1(indForCCG).semSpikeRates;
                    else
                        logger.info('getRates',['Something went WRONG!! Couldnt find rateCorrectedCCGPairs1 field for unitMasterID=' num2str(unitMasterID) ' of slaveId=' num2str(slaveId)]);
                    end
                else
                    logger.info('getRates',['Something went WRONG!! Couldnt find rateCorrectedCCGPairs1 field for slaveId=' num2str(slaveId)]);
                end                
            elseif strcmp(sWhichPhase,SECOND_DRUG)
                if isfield(units(slaveId),'rateCorrectedCCGPairs2') && ~isempty(units(slaveId).rateCorrectedCCGPairs2)
                    indForCCG = find([units(slaveId).rateCorrectedCCGPairs2.id]==unitMasterID);
                    if ~isempty(indForCCG) && indForCCG>0
                        slaveSpikeRates = units(slaveId).rateCorrectedCCGPairs2(indForCCG).spikeRates; 
                        semSpikeRates = units(slaveId).rateCorrectedCCGPairs2(indForCCG).semSpikeRates;
                    else
                        logger.info('getRates',['Something went WRONG!! Couldnt find rateCorrectedCCGPairs2 field for unitMasterID=' num2str(unitMasterID) ' of slaveId=' num2str(slaveId)]);
                    end
                else
                    logger.info('getRates',['Something went WRONG!! Couldnt find rateCorrectedCCGPairs2 field for slaveId=' num2str(slaveId)]);
                end
            end

        else
            if strcmp(sWhichPhase,CLASSIC)
                if isfield(units(slaveId),'regularCCGSpikeRates') && ~isempty(units(slaveId).regularCCGSpikeRates)
                    indForCCG = find([units(slaveId).regularCCGSpikeRates.id]==unitMasterID);
                    if ~isempty(indForCCG) && indForCCG>0
                        slaveSpikeRates = units(slaveId).regularCCGSpikeRates(indForCCG).spikeRates;  
                        semSpikeRates = units(slaveId).regularCCGSpikeRates(indForCCG).semSpikeRates;
                    else
                        logger.info('getRates',['Something went WRONG!! Couldnt find regularCCGSpikeRates0 field for unitMasterID=' num2str(unitMasterID) ' of slaveId=' num2str(slaveId)]);
                    end
                else
                    logger.info('getRates',['Something went WRONG!! Couldnt find regularCCGSpikeRates0 field for slaveId=' num2str(slaveId)]);
                end
            elseif strcmp(sWhichPhase,BASELINE)
                if isfield(units(slaveId),'regularCCGSpikeRates0') && ~isempty(units(slaveId).regularCCGSpikeRates0)
                    indForCCG = find([units(slaveId).regularCCGSpikeRates0.id]==unitMasterID);
                    if ~isempty(indForCCG) && indForCCG>0
                        slaveSpikeRates = units(slaveId).regularCCGSpikeRates0(indForCCG).spikeRates;    
                        semSpikeRates = units(slaveId).regularCCGSpikeRates0(indForCCG).semSpikeRates;  
                    else
                        logger.info('getRates',['Something went WRONG!! Couldnt find regularCCGSpikeRates0 field for unitMasterID=' num2str(unitMasterID) ' of slaveId=' num2str(slaveId)]);
                    end
                else
                    logger.info('getRates',['Something went WRONG!! Couldnt find regularCCGSpikeRates0 field for slaveId=' num2str(slaveId)]);
                end
            elseif strcmp(sWhichPhase,FIRST_DRUG)
                if isfield(units(slaveId),'regularCCGSpikeRates1') && ~isempty(units(slaveId).regularCCGSpikeRates1)
                    indForCCG = find([units(slaveId).regularCCGSpikeRates1.id]==unitMasterID);
                    if ~isempty(indForCCG) && indForCCG>0
                        slaveSpikeRates = units(slaveId).regularCCGSpikeRates1(indForCCG).spikeRates;      
                        semSpikeRates = units(slaveId).regularCCGSpikeRates1(indForCCG).semSpikeRates;
                    else
                        logger.info('getRates',['Something went WRONG!! Couldnt find regularCCGSpikeRates1 field for unitMasterID=' num2str(unitMasterID) ' of slaveId=' num2str(slaveId)]);
                    end
                else
                    logger.info('getRates',['Something went WRONG!! Couldnt find regularCCGSpikeRates1 field for slaveId=' num2str(slaveId)]);
                end                
            elseif strcmp(sWhichPhase,SECOND_DRUG)
                if isfield(units(slaveId),'regularCCGSpikeRates2') && ~isempty(units(slaveId).regularCCGSpikeRates2)
                    indForCCG = find([units(slaveId).regularCCGSpikeRates2.id]==unitMasterID);
                    if ~isempty(indForCCG) && indForCCG>0
                        slaveSpikeRates = units(slaveId).regularCCGSpikeRates2(indForCCG).spikeRates;    
                        semSpikeRates = units(slaveId).regularCCGSpikeRates2(indForCCG).semSpikeRates;
                    else
                        logger.info('getRates',['Something went WRONG!! Couldnt find regularCCGSpikeRates2 field for unitMasterID=' num2str(unitMasterID) ' of slaveId=' num2str(slaveId)]);
                    end
                else
                    logger.info('getRates',['Something went WRONG!! Couldnt find regularCCGSpikeRates2 field for slaveId=' num2str(slaveId)]);
                end
            end
        end
end