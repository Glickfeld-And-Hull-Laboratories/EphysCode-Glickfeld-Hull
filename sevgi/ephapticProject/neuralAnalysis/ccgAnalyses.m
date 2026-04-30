function [needToSave, unitGoodSorted] = ccgAnalyses(unitGoodSorted, unitMuaSorted, unitNoiseSorted, movingTimes, sStationaryOrMoving)
    
    globals;

    needToSave = 0;
    synchExcFirstDrug = 0;
    synchInhFirstDrug = 0;
    synchExcSecondDrug = 0;
    synchInhSecondDrug = 0;

    unitOfInterestSlave = [];
    unitOfInterestMaster = [];

    tic

    if UNIT_OF_INTEREST_SLAVE~=-1 && UNIT_OF_INTEREST_MASTER~=-1

        if UNIT_OF_INTEREST_SLAVE~= -1    
            unitOfInterestSlave = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST_SLAVE));
            if isempty(unitOfInterestSlave)
                unitOfInterestSlave = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST_SLAVE));
                if isempty(unitOfInterestSlave)
                    unitOfInterestSlave = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST_SLAVE));
                    if isempty(unitOfInterestSlave)
                        logger.info('ccgAnalyses', ['No unit info for UNIT_OF_INTEREST_SLAVE id=' numstr(UNIT_OF_INTEREST_SLAVE)]);
                        return;
                    end
                end
            end  
        end
        
        if UNIT_OF_INTEREST_MASTER~= -1    
            unitOfInterestMaster = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST_MASTER));
            if isempty(unitOfInterestMaster)                 
                unitOfInterestMaster = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST_MASTER));
                if isempty(unitOfInterestMaster) 
                    unitOfInterestMaster = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST_MASTER));
                    if isempty(unitOfInterestMaster)                        
                        logger.info('ccgAnalyses', ['No unit info for UNIT_OF_INTEREST_MASTER id=' numstr(UNIT_OF_INTEREST_MASTER)]);
                        return;
                    end
                end
            end
        end
    end

    if ~isempty(unitOfInterestSlave) && ~isempty(unitOfInterestMaster)
            unitGoodSortedToJoin = removeUnrelatedFields(unitGoodSorted);
            unitMuaSorted = removeUnrelatedFields(unitMuaSorted);
            unitNoiseSorted = removeUnrelatedFields(unitNoiseSorted);   
            unitsAll = [unitGoodSortedToJoin; unitMuaSorted; unitNoiseSorted];
            logger.info('ccgAnalyses', ['Will plot ' SS_MLI ' for ' NEURON_TYPE_SS '_' num2str(unitOfInterestSlave.id) '(' num2str(unitOfInterestSlave.depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitOfInterestMaster.id) '(' num2str(unitOfInterestMaster.depth) 'um)']);
            
            f = figure;    
            f.Position = [globalX globalY globalW globalH]; 
            hold on;

            [~, ~, ~, ~, ~, ~, ~, ~, meanRateBaseline] = correlogramRateCorrected([unitOfInterestMaster.id unitOfInterestSlave.id], SS_MLI, unitsAll, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimes, BASELINE, 'k', 1);
            
            if isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                [~, ~, ~, ~, ~, ~, ~, ~, meanRateDrug1] = correlogramRateCorrected([unitOfInterestMaster.id unitOfInterestSlave.id], SS_MLI, unitsAll, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, movingTimes, FIRST_DRUG, 'r', 1);
                legend(BASELINE, '', FIRST_DRUG, '', "Color",'none');
            else
                [~, ~, ~, ~, ~, ~, ~, ~, meanRateDrug1] = correlogramRateCorrected([unitOfInterestMaster.id unitOfInterestSlave.id], SS_MLI, unitsAll, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, movingTimes, FIRST_DRUG, 'b', 1);
                [~, ~, ~, ~, ~, ~, ~, ~, meanRateDrug2] = correlogramRateCorrected([unitOfInterestMaster.id unitOfInterestSlave.id], SS_MLI, unitsAll, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, movingTimes, SECOND_DRUG, 'r', 1);
                legend(BASELINE,'', FIRST_DRUG, '', SECOND_DRUG, '', "Color",'none');
            end

            sHeader = ['CCG ' sStationaryOrMoving ' ' num2str(unitOfInterestSlave.id) ' (' unitOfInterestSlave.neuronType ' depth=' num2str(unitOfInterestSlave.depth) ' um) wrt ' num2str(unitOfInterestMaster.id) ' (' unitOfInterestMaster.neuronType ' depth=' num2str(unitOfInterestMaster.depth) ' um)'];
            sFRs = ['FR_{Bsl}=' num2str(meanRateBaseline,'%.0f') ' FR_{Drug}=' num2str(meanRateDrug1,'%.0f')];
            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                sFRs = [sFRs ' FR_{Drug2}=' num2str(meanRateDrug2,'%.0f')];
            end
            sFRs = [sFRs ' spk/s'];
            set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE);
            title({sHeader, sFRs});
                        
            print([pathToFigureFolder SS_MLI '/CCG_' sStationaryOrMoving '_' num2str(unitOfInterestSlave.id) 'wrt' num2str(unitOfInterestMaster.id) '_' BASELINE '_VS_' FIRST_DRUG '.tif'], '-dtiff', '-r120');
            exportgraphics(f,[pathToFigureFolder SS_MLI '/CCG_' sStationaryOrMoving '_' num2str(unitOfInterestSlave.id) 'wrt' num2str(unitOfInterestMaster.id) '_' BASELINE '_VS_' FIRST_DRUG '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
            savefig([pathToFigureFolder SS_MLI '/CCG_' sStationaryOrMoving '_' num2str(unitOfInterestSlave.id) 'wrt' num2str(unitOfInterestMaster.id) '_' BASELINE '_VS_' FIRST_DRUG '.fig']);
            close all;        
    elseif ~isempty(UNIT_OF_INTEREST_SLAVES) && ~isempty(UNIT_OF_INTEREST_MASTERS)

            for ind=1:length(UNIT_OF_INTEREST_SLAVES)   
                unitOfInterestSlave = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST_SLAVES(ind)));
                if isempty(unitOfInterestSlave)
                    unitOfInterestSlave = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST_SLAVES(ind)));
                    if isempty(unitOfInterestSlave)
                        unitOfInterestSlave = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST_SLAVES(ind)));
                        if isempty(unitOfInterestSlave)
                            logger.info('ccgAnalyses', ['No unit info for UNIT_OF_INTEREST_SLAVE id=' numstr(UNIT_OF_INTEREST_SLAVES(ind))]);
                            return;
                        end
                    end
                end 

                unitOfInterestMaster = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST_MASTERS(ind)));
                if isempty(unitOfInterestMaster)                 
                    unitOfInterestMaster = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST_MASTERS(ind)));
                    if isempty(unitOfInterestMaster) 
                        unitOfInterestMaster = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST_MASTERS(ind)));
                        if isempty(unitOfInterestMaster)                        
                            logger.info('ccgAnalyses', ['No unit info for UNIT_OF_INTEREST_MASTER id=' numstr(UNIT_OF_INTEREST_MASTERS(ind))]);
                            return;
                        end
                    end
                end

                if ~isempty(unitOfInterestSlave) && ~isempty(unitOfInterestMaster)
                    unitGoodSortedToJoin = removeUnrelatedFields(unitGoodSorted);
                    unitMuaSorted = removeUnrelatedFields(unitMuaSorted);
                    unitNoiseSorted = removeUnrelatedFields(unitNoiseSorted);   
                    unitsAll = [unitGoodSortedToJoin; unitMuaSorted; unitNoiseSorted];

                    ccgType = OTHER_OTHER;
                    if strcmp(NEURON_TYPE_SS, unitOfInterestSlave.neuronType()) && strcmp(NEURON_TYPE_MLI, unitOfInterestMaster.neuronType())
                        ccgType = SS_MLI;
                        logger.info('ccgAnalyses', ['Will plot ' SS_MLI ' for ' NEURON_TYPE_SS '_' num2str(unitOfInterestSlave.id) '(' num2str(unitOfInterestSlave.depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitOfInterestMaster.id) '(' num2str(unitOfInterestMaster.depth) 'um)']);
                    elseif strcmp(NEURON_TYPE_MLI, unitOfInterestSlave.neuronType()) && strcmp(NEURON_TYPE_MLI, unitOfInterestMaster.neuronType())
                        ccgType = MLI_MLI;
                        logger.info('ccgAnalyses', ['Will plot ' MLI_MLI ' for ' NEURON_TYPE_MLI '_' num2str(unitOfInterestSlave.id) '(' num2str(unitOfInterestSlave.depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitOfInterestMaster.id) '(' num2str(unitOfInterestMaster.depth) 'um)']);
                    end

                    f = figure;    
                    f.Position = [globalX globalY globalW globalH]; 
                    hold on;
        
                    [~, ~, ~, ~, ~, ~, ~, ~, meanRateBaseline] = correlogramRateCorrected([unitOfInterestMaster.id unitOfInterestSlave.id], ccgType, unitsAll, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimes, BASELINE, 'k', 1);
                    
                    if isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                        [~, ~, ~, ~, ~, ~, ~, ~, meanRateDrug1] = correlogramRateCorrected([unitOfInterestMaster.id unitOfInterestSlave.id], ccgType, unitsAll, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, movingTimes, FIRST_DRUG, 'r', 1);
                    else
                        % Commented out since excitatory blockers are usually same as baseline
%                         [~, ~, ~, ~, ~, ~, ~, ~, meanRateDrug1] = correlogramRateCorrected([unitOfInterestMaster.id unitOfInterestSlave.id], ccgType, unitsAll, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, movingTimesToBeExcluded, FIRST_DRUG, 'b', 1);
                        [~, ~, ~, ~, ~, ~, ~, ~, meanRateDrug2] = correlogramRateCorrected([unitOfInterestMaster.id unitOfInterestSlave.id], ccgType, unitsAll, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, movingTimes, SECOND_DRUG, 'r', 1);
                    end
                                
                    sHeader = ['CCG ' sStationaryOrMoving ' ' num2str(unitOfInterestSlave.id) ' (' unitOfInterestSlave.neuronType ' depth=' num2str(unitOfInterestSlave.depth) ' um) wrt ' num2str(unitOfInterestMaster.id) ' (' unitOfInterestMaster.neuronType ' depth=' num2str(unitOfInterestMaster.depth) ' um)'];
                    sFRs = ['FRBsln=' num2str(meanRateBaseline,'%.0f') ' FRDrug=' num2str(meanRateDrug1,'%.0f')];
                    if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                        sFRs = [sFRs ' FRDrug2=' num2str(meanRateDrug2,'%.0f')];
                    end
                    sFRs = [sFRs ' spk/s'];
                    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE);
                    title([sHeader sFRs]);

                    print([pathToFigureFolder ccgType '/CCG_' sStationaryOrMoving '_' num2str(unitOfInterestSlave.id) 'wrt' num2str(unitOfInterestMaster.id) '_' BASELINE '_VS_' FIRST_DRUG '.tif'], '-dtiff', '-r120');
                    exportgraphics(f,[pathToFigureFolder ccgType '/CCG_' sStationaryOrMoving '_' num2str(unitOfInterestSlave.id) 'wrt' num2str(unitOfInterestMaster.id) '_' BASELINE '_VS_' FIRST_DRUG '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
                    if FLAG_SAVE_FIG
                        savefig([pathToFigureFolder ccgType '/CCG_' sStationaryOrMoving '_' num2str(unitOfInterestSlave.id) 'wrt' num2str(unitOfInterestMaster.id) '_' BASELINE '_VS_' FIRST_DRUG '.fig']);
                    end
                    close all;    
                end
            end
    else % plot all selected units
        pairs_MLI_SS = findPairs(unitGoodSorted, PAIR_TYPE_SS_MLI, NEURON_TYPE_MLI, NEURON_TYPE_SS, PAIR_SS_MLI_MAX_LAYER_DISTANCE, []);
        
        if ~isempty(pairs_MLI_SS)        
            for iPair=1:size(pairs_MLI_SS,1)
                unitPairMLI = unitGoodSorted(find([unitGoodSorted.id]==pairs_MLI_SS(iPair,1)));
                unitPairSS = unitGoodSorted(find([unitGoodSorted.id]==pairs_MLI_SS(iPair,2)));
                
                if ~isempty(unitPairMLI) && ~isempty(unitPairSS)
                    logger.info('ccgAnalyses', ['Will plot ' SS_MLI ' for ' NEURON_TYPE_SS '_' num2str(unitPairSS.id) '(' num2str(unitPairSS.depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitPairMLI.id) '(' num2str(unitPairMLI.depth) 'um)']);
                    
                    f = figure;    
                    f.Position = [globalX globalY globalW globalH]; 
                    hold on;

                    [~, ~, ~, synchExc, synchInh, unitGoodSorted, readForTheFirstTime, ~, meanRateBaseline] = correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, unitGoodSorted, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimes, BASELINE, 'k', 1);                    
                    if readForTheFirstTime
                        needToSave = 1;
                    end

                    if isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                        [~, ~, ~, synchExcFirstDrug, synchInhFirstDrug, unitGoodSorted, readForTheFirstTime, ~, meanRateDrug1] = correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, unitGoodSorted, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, movingTimes, FIRST_DRUG, 'r', 1);
                        if readForTheFirstTime
                            needToSave = 1;
                        end
                    else                        
                        [~, ~, ~, synchExcFirstDrug, synchInhFirstDrug, unitGoodSorted, readForTheFirstTime, ~, meanRateDrug1] = correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, unitGoodSorted, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, movingTimes, FIRST_DRUG, 'b', 1);
                        if readForTheFirstTime
                            needToSave = 1;
                        end

                        [~, ~, ~, synchExcSecondDrug, synchInhSecondDrug, unitGoodSorted, readForTheFirstTime, ~, meanRateDrug2] = correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, unitGoodSorted, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, movingTimes, SECOND_DRUG, 'r', 1);
                        if readForTheFirstTime
                            needToSave = 1;
                        end                        
                    end

                    sHeader = ['CCG ' num2str(unitPairSS.id) ' (' unitPairSS.neuronType ' depth=' num2str(unitPairSS.depth) ' um) wrt ' num2str(unitPairMLI.id) ' (' unitPairMLI.neuronType ' depth=' num2str(unitPairMLI.depth) ' um)'];
                    sFRs = ['FR_{Bsl}=' num2str(meanRateBaseline,'%.0f') ' FR_{Drug}=' num2str(meanRateDrug1,'%.0f')];
                    if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                        sFRs = [sFRs ' FR_{Drug2}=' num2str(meanRateDrug2,'%.0f')];
                    end
                    sFRs = [sFRs ' spk/s'];
                    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE);
                    title([sHeader sFRs]);

                    if synchExc == 1
                        logger.info('ccgAnalyses', ['WHOOOOOAAAA there is a synchrony in excitation during BASELINE! Check the latency of synchrony (SS?)! ' NEURON_TYPE_SS '_' num2str(unitPairSS.id) '(' num2str(unitPairSS.depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitPairMLI.id) '(' num2str(unitPairMLI.depth) 'um)']);
                    end
                    if synchInh == 1
                        logger.info('ccgAnalyses', ['WHOOOOOAAAA there is a synchrony in inhibition during BASELINE! THIS IS THE PAIR YOU ARE LOOKING FOR ' NEURON_TYPE_SS '_' num2str(unitPairSS.id) '(' num2str(unitPairSS.depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitPairMLI.id) '(' num2str(unitPairMLI.depth) 'um)']);
                    end
                    if synchExcFirstDrug == 1
                        logger.info('ccgAnalyses', ['WHOOOOOAAAA there is a synchrony in excitation during FIRST DRUG! Check the latency of synchrony (SS?)! ' NEURON_TYPE_SS '_' num2str(unitPairSS.id) '(' num2str(unitPairSS.depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitPairMLI.id) '(' num2str(unitPairMLI.depth) 'um)']);
                    end
                    if synchInhFirstDrug == 1
                        logger.info('ccgAnalyses', ['WHOOOOOAAAA there is a synchrony in inhibition during FIRST DRUG! THIS IS THE PAIR YOU ARE LOOKING FOR ' NEURON_TYPE_SS '_' num2str(unitPairSS.id) '(' num2str(unitPairSS.depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitPairMLI.id) '(' num2str(unitPairMLI.depth) 'um)']);
                    end
                    if synchExcSecondDrug == 1
                        logger.info('ccgAnalyses', ['WHOOOOOAAAA there is a synchrony in excitation during SECOND DRUG! Check the latency of synchrony (SS?)! ' NEURON_TYPE_SS '_' num2str(unitPairSS.id) '(' num2str(unitPairSS.depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitPairMLI.id) '(' num2str(unitPairMLI.depth) 'um)']);
                    end
                    if synchInhSecondDrug == 1
                        logger.info('ccgAnalyses', ['WHOOOOOAAAA there is a synchrony in inhibition during SECOND DRUG! THIS IS THE PAIR YOU ARE LOOKING FOR ' NEURON_TYPE_SS '_' num2str(unitPairSS.id) '(' num2str(unitPairSS.depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitPairMLI.id) '(' num2str(unitPairMLI.depth) 'um)']);
                    end
                    print([pathToFigureFolder SS_MLI '/CCG_' num2str(unitPairSS.id) 'wrt' num2str(unitPairMLI.id) '_' BASELINE '_VS_' FIRST_DRUG '.tif'], '-dtiff', '-r120');
                    exportgraphics(f,[pathToFigureFolder SS_MLI '/CCG_' num2str(unitPairSS.id) 'wrt' num2str(unitPairMLI.id) '_' BASELINE '_VS_' FIRST_DRUG '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
                    savefig([pathToFigureFolder SS_MLI '/CCG_' num2str(unitPairSS.id) 'wrt' num2str(unitPairMLI.id) '_' BASELINE '_VS_' FIRST_DRUG '.fig']);
            
                    close all;
                end
            end
        else
            logger.info('ccgAnalyses', ['No pairs found!']);
        end

%         %%%%%%%%%%%%%%%% COMMENT OUT THIS PORTION IF YOU EXPLORED ALL POSSIBLE PAIRS ALREADY %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%% Work harder to find more possible pairs %%%%%%%%%
%         unitGoodSortedToJoin = removeUnrelatedFields(unitGoodSorted);
%         unitMuaSorted = removeUnrelatedFields(unitMuaSorted);
%         unitNoiseSorted = removeUnrelatedFields(unitNoiseSorted);
%         units = [unitGoodSortedToJoin; unitMuaSorted; unitNoiseSorted];
%         %%%%% FIRST MLIs %%%%%%%%%%%%%
%         for indPair=1:length(POSSIBLE_MLIs)
%             unitPairMLI = units(find([units.id]==POSSIBLE_MLIs(indPair)));            
%             if ~isempty(unitPairMLI)
%                 possible_pairs_MLI_SS = findPairs(units, PAIR_TYPE_SS_MLI, NEURON_TYPE_MLI, NEURON_TYPE_SS, PAIR_SS_MLI_MAX_LAYER_DISTANCE, unitPairMLI);
%                 if ~isempty(possible_pairs_MLI_SS)        
%                     for iPair=1:size(possible_pairs_MLI_SS,1)
%                         unitPairMLI = units(find([units.id]==possible_pairs_MLI_SS(iPair,1)));
%                         unitPairSS = units(find([units.id]==possible_pairs_MLI_SS(iPair,2)));
%                         
%                         if ~isempty(unitPairMLI) && ~isempty(unitPairSS)
%                             logger.info('ccgAnalyses', ['Will plot ' SS_MLI ' for ' NEURON_TYPE_SS '_' num2str(unitPairSS.id) '(' num2str(unitPairSS.depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitPairMLI.id) '(' num2str(unitPairMLI.depth) 'um)']);
%                             
%                             f = figure;    
%                             f.Position = [globalX globalY globalW globalH]; 
%                             hold on;
%         
%                             correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, units, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimesToBeExcluded, BASELINE, 'k', 1);                            
%                             if isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
%                                 correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, units, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, movingTimesToBeExcluded, FIRST_DRUG, 'r', 1);
%                             else
%                                 correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, units, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, movingTimesToBeExcluded, FIRST_DRUG, 'r', 1);
%                                 correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, units, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, movingTimesToBeExcluded, SECOND_DRUG, 'b', 1);
%                             end
%                                         
%                             print([pathToFigureFolder SS_MLI '/CCG_' num2str(unitPairSS.id) 'wrt' num2str(unitPairMLI.id) '_' BASELINE '_VS_' FIRST_DRUG '.tif'], '-dtiff', '-r120');
%         %                     exportgraphics(f,[pathToFigureFolder SS_MLI '/CCG_' num2str(unitPairSS.id) 'wrt' num2str(unitPairMLI.id) '_' BASELINE '_VS_' FIRST_DRUG '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
%                             close all;
%                         end
%                     end
%                 end
%             end
%         end
% 
%         %%%%% THEN SSs %%%%%%%%%%%%%
%         for indPair=1:length(POSSIBLE_SSs)
%             unitPairSS = units(find([units.id]==POSSIBLE_SSs(indPair)));
%             
%             if ~isempty(unitPairSS)
%                 possible_pairs_SS_MLI = findPairs(units, PAIR_TYPE_SS_MLI, NEURON_TYPE_SS, NEURON_TYPE_MLI, PAIR_SS_MLI_MAX_LAYER_DISTANCE, unitPairSS);
%                 if ~isempty(possible_pairs_SS_MLI)        
%                     for iPair=1:size(possible_pairs_SS_MLI,1)
%                         unitPairSS = units(find([units.id]==possible_pairs_SS_MLI(iPair,1)));
%                         unitPairMLI = units(find([units.id]==possible_pairs_SS_MLI(iPair,2)));
%                         
%                         if ~isempty(unitPairSS) && ~isempty(unitPairMLI)
%                             logger.info('ccgAnalyses', ['Will plot ' SS_MLI ' for ' NEURON_TYPE_SS '_' num2str(unitPairSS.id) '(' num2str(unitPairSS.depth) 'um) ' NEURON_TYPE_MLI '_' num2str(unitPairMLI.id) '(' num2str(unitPairMLI.depth) 'um)']);
%                             
%                             f = figure;    
%                             f.Position = [globalX globalY globalW globalH]; 
%                             hold on;
%         
%                             correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, units, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimesToBeExcluded, BASELINE, 'k', 1);                            
%                             if isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
%                                 correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, units, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, movingTimesToBeExcluded, FIRST_DRUG, 'r', 1);
%                             else
%                                 correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, units, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, movingTimesToBeExcluded, FIRST_DRUG, 'r', 1);
%                                 correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, units, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, movingTimesToBeExcluded, SECOND_DRUG, 'b', 1);
%                             end
%                                         
%                             print([pathToFigureFolder SS_MLI '/CCG_' num2str(unitPairSS.id) 'wrt' num2str(unitPairMLI.id) '_' BASELINE '_VS_' FIRST_DRUG '.tif'], '-dtiff', '-r120');
%         %                     exportgraphics(f,[pathToFigureFolder SS_MLI '/CCG_' num2str(unitPairSS.id) 'wrt' num2str(unitPairMLI.id) '_' BASELINE '_VS_' FIRST_DRUG '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
%                             close all;
%                         end
%                     end
%                 end
%             end
%         end
% 
%         logger.info('ccgAnalyses', ['All possible pairs of ' SS_MLI ' CCGs are plotted!']);
        %%%%%%%%%%%%%%%% COMMENT OUT THIS PORTION IF YOU EXPLORED ALL POSSIBLE PAIRS ALREADY %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end

    totalRunningTimeSec = toc;
    totalRunningTimeHrs = totalRunningTimeSec/3600;
    logger.info('ccgAnalyses', [' TOTAL elapsed time:' num2str(totalRunningTimeHrs) ' hrs (or ' num2str(totalRunningTimeHrs*60) ' minutes)']);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end