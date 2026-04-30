function ccgAnalysesOnlySSCS(unitGoodSorted, unitMuaSorted, unitNoiseSorted)
    
    globals;

    if UNIT_OF_INTEREST_SS~=-1 && UNIT_OF_INTEREST_CS~=-1

        if UNIT_OF_INTEREST_SS~= -1    
            unitOfInterestSS = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST_SS));
            if isempty(unitOfInterestSS)
                unitOfInterestSS = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST_SS));
                if isempty(unitOfInterestSS)
                    unitOfInterestSS = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST_SS));
                    if isempty(unitOfInterestSS)
                        logger.info('ccgAnalyses', ['No unit info for UNIT_OF_INTEREST_SS id=' numstr(UNIT_OF_INTEREST_SS)]);
                        return;
                    end
                end
            end  
        end
        
        if UNIT_OF_INTEREST_CS~= -1    
            unitOfInterestCS = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST_CS));
            if isempty(unitOfInterestCS)                 
                unitOfInterestCS = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST_CS));
                if isempty(unitOfInterestCS) 
                    unitOfInterestCS = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST_CS));
                    if isempty(unitOfInterestCS)                        
                        logger.info('ccgAnalyses', ['No unit info for UNIT_OF_INTEREST_CS id=' numstr(UNIT_OF_INTEREST_CS)]);
                        return;
                    end
                end
            end
        end
        if ~isempty(unitOfInterestSS) && ~isempty(unitOfInterestCS)
            unitGoodSortedToJoin = rmfield(unitGoodSorted,"amplitudePerChannel");
            if isfield(unitGoodSortedToJoin,'cv2') 
                unitGoodSortedToJoin = rmfield(unitGoodSortedToJoin,"cv2");
            end
            unitsAll = [unitGoodSortedToJoin; unitMuaSorted; unitNoiseSorted];
            logger.info('ccgAnalyses', ['Will plot ' SS_CS ' for ' NEURON_TYPE_SS '_' num2str(unitOfInterestSS.id) '(' num2str(unitOfInterestSS.depth) 'um) ' NEURON_TYPE_CS '_' num2str(unitOfInterestCS.id) '(' num2str(unitOfInterestCS.depth) 'um)']);
            
            f = figure;    
            f.Position = [globalX globalY globalW globalH]; 
            hold on;

            [~, suppressed, ~, synchExc, synchInh, ~, ~, ~, ~] = correlogramRateCorrected([unitOfInterestCS.id unitOfInterestSS.id], SS_CS, unitsAll, [], [], [], BASELINE, 'k', 1, 0);
%             [~, suppressed, ~, synchEd] = correlogram([unitOfInterestCS.id unitOfInterestSS.id], SS_CS, unitsAll, unitsAll, [], [], [], BASELINE, 'k', 1);
                        
            if suppressed
                logger.info('ccgAnalyses', ['WHOOOOOAAAA SUPPRESSION! ' NEURON_TYPE_SS '_' num2str(unitOfInterestSS.id) '(' num2str(unitOfInterestSS.depth) 'um) ' NEURON_TYPE_CS '_' num2str(unitOfInterestCS.id) '(' num2str(unitOfInterestCS.depth) 'um)']);
            end

            print([pathToFigureFolder SS_CS '/CCG_' num2str(unitOfInterestSS.id) 'wrt' num2str(unitOfInterestCS.id) '.tif'], '-dtiff', '-r120');
            exportgraphics(f,[pathToFigureFolder SS_CS '/CCG_' num2str(unitOfInterestSS.id) 'wrt' num2str(unitOfInterestCS.id) '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
            close all;
        end
        
     else % plot all selected units
        pairs_CS_SS = findPairs(unitGoodSorted, PAIR_TYPE_CS_SS, NEURON_TYPE_CS, NEURON_TYPE_SS, PAIR_CS_SS_MAX_LAYER_DISTANCE, []);
        
        if ~isempty(pairs_CS_SS)        
            for iPair=1:size(pairs_CS_SS,1)
                unitPairCS = unitGoodSorted(find([unitGoodSorted.id]==pairs_CS_SS(iPair,1)));
                unitPairSS = unitGoodSorted(find([unitGoodSorted.id]==pairs_CS_SS(iPair,2)));
                
                if ~isempty(unitPairCS) && ~isempty(unitPairSS)
                    logger.info('ccgAnalyses', ['Will plot ' SS_CS ' for ' NEURON_TYPE_SS '_' num2str(unitPairSS.id) '(' num2str(unitPairSS.depth) 'um) ' NEURON_TYPE_CS '_' num2str(unitPairCS.id) '(' num2str(unitPairCS.depth) 'um)']);
                    
                    f = figure;    
                    f.Position = [globalX globalY globalW globalH]; 
                    hold on;

                    [~, suppressed, synchExc, synchInh, ~, ~, ~, ~] = correlogramRateCorrected([unitPairCS.id unitPairSS.id], SS_CS, unitGoodSorted, [], [], [], BASELINE, 'k', 1, 0);
                                                   
                    if suppressed
                        logger.info('ccgAnalyses', ['WHOOOOOAAAA SUPPRESSION! ' NEURON_TYPE_SS '_' num2str(unitPairSS.id) '(' num2str(unitPairSS.depth) 'um) ' NEURON_TYPE_CS '_' num2str(unitPairCS.id) '(' num2str(unitPairCS.depth) 'um)']);
                    end
                    print([pathToFigureFolder SS_CS '/CCG_' num2str(unitPairSS.id) 'wrt' num2str(unitPairCS.id) '.tif'], '-dtiff', '-r120');
                    exportgraphics(f,[pathToFigureFolder SS_CS '/CCG_' num2str(unitPairSS.id) 'wrt' num2str(unitPairCS.id) '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
                    close all;
                end
            end
        else
            logger.info('ccgAnalyses', ['No pairs found!']);
        end

%         %%%%%%%%%%%%%%%% COMMENT OUT THIS PORTION IF YOU EXPLORED ALL POSSIBLE PAIRS ALREADY %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%% Work harder to find more possible pairs %%%%%%%%%
%         unitGoodSorted = rmfield(unitGoodSorted,"amplitudePerChannel"); % some nonsense detail-didn't allow me to join these structs if they don't have same fields
%         if isfield(unitGoodSorted,'neuronSubType') 
%             unitGoodSorted = rmfield(unitGoodSorted,"neuronSubType");
%         end
%         units = [unitGoodSorted; unitMuaSorted; unitNoiseSorted];
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
%                             correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, units, units, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimesToBeExcluded, BASELINE, 'k', 1);
%                             correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, units, units, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, movingTimesToBeExcluded, FIRST_DRUG, 'r', 1);
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
%                             correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, units, units, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimesToBeExcluded, BASELINE, 'k', 1);
%                             correlogramRateCorrected([unitPairMLI.id unitPairSS.id], SS_MLI, units, units, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, movingTimesToBeExcluded, FIRST_DRUG, 'r', 1);
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
%         %%%%%%%%%%%%%%%% COMMENT OUT THIS PORTION IF YOU EXPLORED ALL POSSIBLE PAIRS ALREADY %%%%%%%%%%%%%%%%%%%%%%%%%%%%
     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end