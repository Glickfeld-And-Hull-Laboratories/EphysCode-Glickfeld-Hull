function [unitGoodSorted,unitMuaSorted,unitNoiseSorted]=identifyMLIs(unitGoodSorted,unitMuaSorted,unitNoiseSorted, movingTimesToBeExcluded)
        globals;

        sMLI1 = '';
        sMLI2 = '';
        readForTheFirstTime = 0;
        %%%%%%%%%%%%%%%% IS THIS MLI1? %%%%%%%%%%%%%%%%%%%
        for indMLI1=1:length(unitGoodSorted)
            if strcmp(unitGoodSorted(indMLI1).neuronType,NEURON_TYPE_MLI) % found an MLI
                rule1MLI1_inhibitSS = -1;
                rule2MLI1_doesNotInhibitMLI = -1;
                rule3MLI1_synchWOtherMLI = -1; % Optional rule, let's see if you need to use it, since there may not be enough other MLIs

                logger.info('identifyMLIs', ['CHECKING IF MLI1?: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI1).id) ' layer=' unitGoodSorted(indMLI1).layer ' (' num2str(unitGoodSorted(indMLI1).depth) 'um)']);

                % MLI1 RULE 1: inhibits PCs
                for indSS=1:length(unitGoodSorted)
                    if strcmp(unitGoodSorted(indSS).neuronType,NEURON_TYPE_SS) && unitGoodSorted(indSS).id~=unitGoodSorted(indMLI1).id % found an SS
                        rule1MLI1_inhibitSS = 0; % change the state of the flag from No SS at all (-1) to 'there were some SS' (0) since it is not the same thing that this MLI either did not have any SS or it had but did not suppressed
                        [~, inhibited, ~, synchEd] = correlogramRateCorrected([unitGoodSorted(indMLI1).id unitGoodSorted(indSS).id], SS_MLI, unitGoodSorted, unitGoodSorted, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimesToBeExcluded, BASELINE, 'k', 0);
                        if synchEd
                            logger.info('identifyMLIs', ['WHOOOOOAAAA there is a synchrony in excitation! Check the latency of synchrony! Is this disinhibition really or C4-misclassification of this MLI (actually it is SS!) ' ...
                                NEURON_TYPE_SS '_' num2str(unitGoodSorted(indSS).id) '(' num2str(unitGoodSorted(indSS).depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI1).id) '(' num2str(unitGoodSorted(indMLI1).depth) 'um)']);
                        elseif synchEd==-1
                            logger.info('identifyMLIs', ['WHOOOOOAAAA there is a synchrony in inhibition! ' ...
                                NEURON_TYPE_SS '_' num2str(unitGoodSorted(indSS).id) '(' num2str(unitGoodSorted(indSS).depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI1).id) '(' num2str(unitGoodSorted(indMLI1).depth) 'um)']);
                        end
                        
                        if inhibited
                            rule1MLI1_inhibitSS = 1;
                            logger.info('identifyMLIs', ['MLI1 RULE1: INHIBITS SS: ' SS_MLI ' ' NEURON_TYPE_SS '_' num2str(unitGoodSorted(indSS).id) '(' num2str(unitGoodSorted(indSS).depth) 'um) ' ...
                            NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI1).id) '(' num2str(unitGoodSorted(indMLI1).depth) 'um)']);
                            break; % At least one inhibition is enough
                        end
                    end
                end    

                if rule1MLI1_inhibitSS==1 % If MLI1 RULE 1 holds, then go check MLI1 RULE 2
                    % MLI1 RULE 2: does not inhibit other MLIs
                    for indMLIOther=1:length(unitGoodSorted)
                        if strcmp(unitGoodSorted(indMLIOther).neuronType,NEURON_TYPE_MLI) && unitGoodSorted(indMLIOther).id~=unitGoodSorted(indMLI1).id % found another MLI
                            rule2MLI1_doesNotInhibitMLI = 0; % change the state of the flag from No SS at all (-1) to 'there were some SS' (0) since it is not the same thing that this MLI either did not have any SS or it had but did not suppressed
                            [~, inhibitedOtherMLI, ~, ~] = correlogramRateCorrected([unitGoodSorted(indMLI1).id unitGoodSorted(indMLIOther).id], MLI_MLI, unitGoodSorted, unitGoodSorted, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimesToBeExcluded, BASELINE, 'k', 0);
                            if inhibitedOtherMLI
                                logger.info('identifyMLIs', ['BROKEN MLI1(' num2str(unitGoodSorted(indMLI1).id) ') RULE2: INHIBIT OTHER MLI: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLIOther).id) '(' num2str(unitGoodSorted(indMLIOther).depth) 'um) ' ...
                                NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI1).id) '(' num2str(unitGoodSorted(indMLI1).depth) 'um)']);
                                break; % Even if you found one inhibition on one of the other MLIs, no need to look the rest - rule breaks!
                            else
                                rule2MLI1_doesNotInhibitMLI = 1;
                                logger.info('identifyMLIs', ['MLI1 RULE2: DID NOT INHIBIT OTHER MLI: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLIOther).id) '(' num2str(unitGoodSorted(indMLIOther).depth) 'um) ' ...
                                NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI1).id) '(' num2str(unitGoodSorted(indMLI1).depth) 'um)']);
                            end
                        end
                    end
    
                    if rule2MLI1_doesNotInhibitMLI==1                         
                        if ~isfield(unitGoodSorted(indMLI1),'neuronSubType') || (isfield(unitGoodSorted(indMLI1),'neuronSubType') && ~strcmp(unitGoodSorted(indMLI1).neuronSubType,NEURON_TYPE_MLI1))
                            unitGoodSorted(indMLI1).neuronSubType = NEURON_TYPE_MLI1;
                            readForTheFirstTime = 1;
                        end
                        logger.info('identifyMLIs', ['MLI1 FOUND: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI1).id) ' layer=' unitGoodSorted(indMLI1).layer ' (' num2str(unitGoodSorted(indMLI1).depth) 'um)']);
                        sMLI1 = [sMLI1 ' ' num2str(unitGoodSorted(indMLI1).id)];
                    end
                else
                    logger.info('identifyMLIs', ['BROKEN MLI1(' num2str(unitGoodSorted(indMLI1).id) ') RULE1: CANNOT INHIBIT ANY SS: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI1).id) '(' num2str(unitGoodSorted(indMLI1).depth) 'um)']);
                end
            end
        end

        %%%%%%%%%%%%%%%% IS THIS MLI2? %%%%%%%%%%%%%%%%%%%
        for indMLI2=1:length(unitGoodSorted)
            % found an unassigned MLI (If it is assigned as an MLI1, skip it)
            if strcmp(unitGoodSorted(indMLI2).neuronType,NEURON_TYPE_MLI) && (~isfield(unitGoodSorted,'neuronSubType') || (isfield(unitGoodSorted,'neuronSubType') && ~strcmp(unitGoodSorted(indMLI2).neuronSubType,NEURON_TYPE_MLI1)))
                rule1MLI2_doesNotInhibitSS = -1;
                rule2MLI2_NotSynchWOtherMLI = -1;
                rule3MLI2_inhibitMLI = -1;                
                rule4MLI2_closeToSS = -1;                
                
                logger.info('identifyMLIs', ['CHECKING IF MLI2?: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) ' layer=' unitGoodSorted(indMLI2).layer ' (' num2str(unitGoodSorted(indMLI2).depth) 'um)']);

                % MLI2 RULE 4: MLI2 should be around SS
                for indSS=1:length(unitGoodSorted)
                    if strcmp(unitGoodSorted(indSS).neuronType,NEURON_TYPE_SS) % found an SS
                        rule4MLI2_closeToSS = 0; % change the state of the flag from No SS at all (-1) to 'there were some SS' (0) but they were far! since it is not the same thing that this MLI either did not have any SS or it had but they were far away
                        distance = abs(unitGoodSorted(indSS).depth-unitGoodSorted(indMLI2).depth);
                        if distance<=IDENTIFY_MLI2_MAX_SS_DISTANCE
                            rule4MLI2_closeToSS = 1; % change the state of the flag from No SS at all (-1) to 'there were some SS' (0) since it is not the same thing that this MLI either did not have any SS or it had but did not suppressed
                            logger.info('identifyMLIs', ['MLI2 RULE4: HAS SS CLOSE BY: ' SS_MLI ' ' NEURON_TYPE_SS '_' num2str(unitGoodSorted(indSS).id) '(' num2str(unitGoodSorted(indSS).depth) 'um) ' ...
                            NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);
                            break;
                        end
                    end
                end

                if rule4MLI2_closeToSS ~= 1
                    logger.info('identifyMLIs', ['BROKEN MLI2(' num2str(unitGoodSorted(indMLI2).id) ') NON-MANDATORY RULE4: HAD NO SS CLOSE BY: ' SS_MLI ' ' ...
                            NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);
                end

                % MLI2 RULE 1: does NOT inhibit PCs
                for indSS=1:length(unitGoodSorted)
                    if strcmp(unitGoodSorted(indSS).neuronType,NEURON_TYPE_SS) && unitGoodSorted(indSS).id~=unitGoodSorted(indMLI2).id % found an SS
                        rule1MLI2_doesNotInhibitSS = 0; % change the state of the flag from No SS at all (-1) to 'there were some SS' (0) since it is not the same thing that this MLI either did not have any SS or it had but did not suppressed
                        [~, inhibited, ~, synchEd] = correlogramRateCorrected([unitGoodSorted(indMLI2).id unitGoodSorted(indSS).id], SS_MLI, unitGoodSorted, unitGoodSorted, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimesToBeExcluded, BASELINE, 'k', 0);
                        if synchEd
                            logger.info('identifyMLIs', ['WHOOOOOAAAA there is a synchrony in excitation! Check the latency of synchrony! Is this disinhibition really or C4-misclassification of this MLI (actually it is SS!) ' ...
                                NEURON_TYPE_SS '_' num2str(unitGoodSorted(indSS).id) '(' num2str(unitGoodSorted(indSS).depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);
                        elseif synchEd==-1                        
                            logger.info('identifyMLIs', ['WHOOOOOAAAA there is a synchrony in inhibition! ' ...
                                NEURON_TYPE_SS '_' num2str(unitGoodSorted(indSS).id) '(' num2str(unitGoodSorted(indSS).depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);
                        end

                        if inhibited
                            logger.info('identifyMLIs', ['BROKEN MLI2(' num2str(unitGoodSorted(indMLI2).id) ') RULE1: INHIBIT SS: ' SS_MLI ' ' NEURON_TYPE_SS '_' num2str(unitGoodSorted(indSS).id) '(' num2str(unitGoodSorted(indSS).depth) 'um) ' ...
                            NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);
                            break; % Even if you found one inhibition on one of SS, no need to look the rest, this is NOT MLI2 - rule breaks!
                        else
                            rule1MLI2_doesNotInhibitSS = 1;
                            logger.info('identifyMLIs', ['MLI2 RULE1: DOES NOT INHIBIT SS: ' SS_MLI ' ' NEURON_TYPE_SS '_' num2str(unitGoodSorted(indSS).id) '(' num2str(unitGoodSorted(indSS).depth) 'um) ' ...
                            NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);
                        end
                    end
                end    

                if rule1MLI2_doesNotInhibitSS==1 % If MLI2 RULE 1 holds, then go check MLI2 RULE 2
                    % MLI2 RULE 2: NOT synchronous with other MLIs
                    for indMLIOther=1:length(unitGoodSorted)
                        if strcmp(unitGoodSorted(indMLIOther).neuronType,NEURON_TYPE_MLI) && unitGoodSorted(indMLIOther).id~=unitGoodSorted(indMLI2).id % found another MLI
                            rule2MLI2_NotSynchWOtherMLI = 0; % change the state of the flag from No SS at all (-1) to 'there were some SS' (0) since it is not the same thing that this MLI either did not have any SS or it had but did not suppressed
                            [~, ~, ~, synchEd] = correlogramRateCorrected([unitGoodSorted(indMLI2).id unitGoodSorted(indMLIOther).id], MLI_MLI, unitGoodSorted, unitGoodSorted, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimesToBeExcluded, BASELINE, 'k', 0);
                            if synchEd
                                logger.info('identifyMLIs', ['BROKEN MLI2(' num2str(unitGoodSorted(indMLI2).id) ') RULE2: SYNCH in EXCITATION WITH OTHER MLI: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLIOther).id) '(' num2str(unitGoodSorted(indMLIOther).depth) 'um) ' ...
                                NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);
                                break; % Even if you found one synchronicity on one of the other MLIs, that's enough to say this is NOT MLI2, no need to look the rest
                            elseif synchEd==-1
                                logger.info('identifyMLIs', ['WHOOOOOAAAA there is a synchrony in inhibition! Check the latency of synchrony! Is this inhibition really or C4-misclassification of this MLI (actually it is SS!) MLI2(' num2str(unitGoodSorted(indMLI2).id) ') RULE2: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLIOther).id) '(' num2str(unitGoodSorted(indMLIOther).depth) 'um) ' ...
                                NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);                                
                            elseif synchEd==0
                                rule2MLI2_NotSynchWOtherMLI = 1;
                            end
                        end
                    end                 
    
                    if rule2MLI2_NotSynchWOtherMLI==1
                        logger.info('identifyMLIs', ['MLI2 RULE2: NOT SYNCH WITH OTHER MLI: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);

                        % MLI2 RULE 3: inhibit other MLIs
                        for indMLIOther=1:length(unitGoodSorted)
                            if strcmp(unitGoodSorted(indMLIOther).neuronType,NEURON_TYPE_MLI) && unitGoodSorted(indMLIOther).id~=unitGoodSorted(indMLI2).id % found another MLI
                                rule3MLI2_inhibitMLI = 0; % change the state of the flag from No SS at all (-1) to 'there were some SS' (0) since it is not the same thing that this MLI either did not have any SS or it had but did not suppressed
                                [~, inhibitedOtherMLI, ~, ~] = correlogramRateCorrected([unitGoodSorted(indMLI2).id unitGoodSorted(indMLIOther).id], MLI_MLI, unitGoodSorted, unitGoodSorted, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimesToBeExcluded, BASELINE, 'k', 0);
                                if inhibitedOtherMLI
                                    rule3MLI2_inhibitMLI = 1;
                                    logger.info('identifyMLIs', ['MLI2 RULE3: INHIBIT OTHER MLI: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLIOther).id) '(' num2str(unitGoodSorted(indMLIOther).depth) 'um) ' ...
                                    NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);
                                    break; % Even if you found one inhibition on one of the other MLIs, that's enough to say this is MLI2, no need to look the rest
                                end
                            end
                        end      

                        if rule3MLI2_inhibitMLI~=1
                            logger.info('identifyMLIs', ['BROKEN MLI2(' num2str(unitGoodSorted(indMLI2).id) ') NON-MANDATORY RULE3: NOT FOUND OTHER INHIBITED MLIs: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);
                        end

                        if (rule3MLI2_inhibitMLI==1 || rule4MLI2_closeToSS) 
                            if ~isfield(unitGoodSorted(indMLI2),'neuronSubType') || (isfield(unitGoodSorted(indMLI2),'neuronSubType') && ~strcmp(unitGoodSorted(indMLI2).neuronSubType,NEURON_TYPE_MLI2))
                                unitGoodSorted(indMLI2).neuronSubType = NEURON_TYPE_MLI2;
                                readForTheFirstTime = 1;
                            end
                            logger.info('identifyMLIs', ['MLI2 FOUND: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) ' layer=' unitGoodSorted(indMLI2).layer ' (' num2str(unitGoodSorted(indMLI2).depth) 'um)']);
                            sMLI2 = [sMLI2 ' ' num2str(unitGoodSorted(indMLI2).id)];
                        else
                            logger.info('identifyMLIs', ['BROKEN MLI2(' num2str(unitGoodSorted(indMLI2).id) ') COULDNT SATISFY EITHER RULE3 OR RULE 4 (HAD NO SS CLOSE BY): NOT FOUND OTHER INHIBITED MLIs: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);
                        end
                    elseif rule2MLI2_NotSynchWOtherMLI==-1
                        logger.info('identifyMLIs', ['BROKEN MLI2 RULE2 (-1): NO OTHER MLIs to be NOT SYNCH WITH: ' NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI2).id) '(' num2str(unitGoodSorted(indMLI2).depth) 'um)']);
                    end
                end
            end
        end

        logger.info('identifyMLIs', [' TOTAL FOUND MLI1s=' sMLI1 ' and MLI2s=' sMLI2]);

        if readForTheFirstTime % If any new data appears, save it to the dataset
            [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = saveUnits({unitGoodSorted, unitMuaSorted, unitNoiseSorted});
        end
end