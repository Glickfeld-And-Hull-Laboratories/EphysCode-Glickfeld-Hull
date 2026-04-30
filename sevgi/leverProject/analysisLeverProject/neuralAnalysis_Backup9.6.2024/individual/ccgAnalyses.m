function [suppressedPairs_CS_SS, pairs_CS_SS] = ccgAnalyses(unitGoodSorted, unitMuaSorted, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials)
    
    globals;

    if UNIT_OF_INTEREST~= -1
        unitOfInterest = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        if ~isempty(unitOfInterest) 
            units = unitGoodSorted;            
        else % If UOI cannot be found in GOOD units, it may be in MUA
            unitOfInterest = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
            if ~isempty(unitOfInterest) 
                units = unitMuaSorted;
            else
                disp('No unit info!')
            end
        end
        if ~isempty(unitOfInterest)
            
            pairs_CS_SS = [];
            suppressedPairs_CS_SS = [];
            if strcmp(unitOfInterest.neuronType, NEURON_TYPE_CS) || strcmp(unitOfInterest.neuronType, NEURON_TYPE_SS)
                pairs_CS_SS = findPairs(units, PAIR_TYPE_CS_SS, NEURON_TYPE_CS, NEURON_TYPE_SS, PAIR_CS_SS_MAX_LAYER_DISTANCE, unitOfInterest);
                if strcmp(unitOfInterest.neuronType,NEURON_TYPE_CS)
                    otherNeuronType = NEURON_TYPE_SS;
                else
                    otherNeuronType = NEURON_TYPE_CS;
                end
                [suppressedPairs_CS_SS, ~] = plotCCGPairs(pairs_CS_SS, '', PAIR_TYPE_CS_SS, units, unitOfInterest.neuronType, otherNeuronType, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
            end
%             if strcmp(unitOfInterest.neuronType, NEURON_TYPE_DCS) || strcmp(unitOfInterest.neuronType, NEURON_TYPE_SS)
%                 pairs_DCS_SS = findPairs(units, PAIR_TYPE_CS_SS, NEURON_TYPE_DCS, NEURON_TYPE_SS, PAIR_CS_SS_MAX_LAYER_DISTANCE, unitOfInterest);
%                 if strcmp(unitOfInterest.neuronType,NEURON_TYPE_DCS)
%                     otherNeuronType = NEURON_TYPE_SS;
%                 else
%                     otherNeuronType = NEURON_TYPE_DCS;
%                 end
%                 [suppressedPairs_DCS_SS, ~] = plotCCGPairs(pairs_DCS_SS, '', PAIR_TYPE_CS_SS, units, unitOfInterest.neuronType, otherNeuronType, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
%             end
            if strcmp(unitOfInterest.neuronType, NEURON_TYPE_MFB) || strcmp(unitOfInterest.neuronType, NEURON_TYPE_GoC)
                pairs_MF_GO = findPairs(units, PAIR_TYPE_MF_GO, NEURON_TYPE_MFB, NEURON_TYPE_GoC, PAIR_MF_GO_MAX_LAYER_DISTANCE, unitOfInterest);
                if strcmp(unitOfInterest.neuronType,NEURON_TYPE_MFB)
                    otherNeuronType = NEURON_TYPE_GoC;
                else
                    otherNeuronType = NEURON_TYPE_MFB;
                end
                [suppressedPairs_MF_GO, ~] = plotCCGPairs(pairs_MF_GO, '', PAIR_TYPE_MF_GO, units, unitOfInterest.neuronType, otherNeuronType, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
            end
            if strcmp(unitOfInterest.neuronType, NEURON_TYPE_GoC) || strcmp(unitOfInterest.neuronType, NEURON_TYPE_SS)
                pairs_GO_SS = findPairs(units, PAIR_TYPE_GO_SS, NEURON_TYPE_GoC, NEURON_TYPE_SS, PAIR_GO_SS_MAX_LAYER_DISTANCE, unitOfInterest);
                if strcmp(unitOfInterest.neuronType,NEURON_TYPE_GoC)
                    otherNeuronType = NEURON_TYPE_SS;
                else
                    otherNeuronType = NEURON_TYPE_GoC;
                end
                [suppressedPairs_GO_SS, ~] = plotCCGPairs(pairs_GO_SS, '', PAIR_TYPE_GO_SS, units, unitOfInterest.neuronType, otherNeuronType, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
            end
            if strcmp(unitOfInterest.neuronType, NEURON_TYPE_MLI) || strcmp(unitOfInterest.neuronType, NEURON_TYPE_SS)
                pairs_MLI_SS = findPairs(units, PAIR_TYPE_MLI_SS, NEURON_TYPE_MLI, NEURON_TYPE_SS, PAIR_MLI_SS_MAX_LAYER_DISTANCE, unitOfInterest);
                if strcmp(unitOfInterest.neuronType,NEURON_TYPE_MLI)
                    otherNeuronType = NEURON_TYPE_SS;
                else
                    otherNeuronType = NEURON_TYPE_MLI;
                end
                [suppressedPairs_MLI_SS, ~] = plotCCGPairs(pairs_MLI_SS, '', PAIR_TYPE_MLI_SS, units, unitOfInterest.neuronType, otherNeuronType, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
            end
            if strcmp(unitOfInterest.neuronType, NEURON_TYPE_MFB) || strcmp(unitOfInterest.neuronType, NEURON_TYPE_SS)
                pairs_MF_SS = findPairs(units, PAIR_TYPE_MF_SS, NEURON_TYPE_MFB, NEURON_TYPE_SS, PAIR_MF_SS_MAX_LAYER_DISTANCE, unitOfInterest);
                if strcmp(unitOfInterest.neuronType,NEURON_TYPE_MFB)
                    otherNeuronType = NEURON_TYPE_SS;
                else
                    otherNeuronType = NEURON_TYPE_MFB;
                end
                [suppressedPairs_MF_SS, ~] = plotCCGPairs(pairs_MF_SS, '', PAIR_TYPE_MF_SS, units, unitOfInterest.neuronType, otherNeuronType, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
            end            
            if strcmp(unitOfInterest.neuronType, NEURON_TYPE_SS) || strcmp(unitOfInterest.neuronType, NEURON_TYPE_DCN)
                pairs_SS_DCN = findPairs(units, PAIR_TYPE_SS_DCN, NEURON_TYPE_SS, NEURON_TYPE_DCN, PAIR_SS_DCN_MAX_LAYER_DISTANCE, unitOfInterest);
                if strcmp(unitOfInterest.neuronType,NEURON_TYPE_SS)
                    otherNeuronType = NEURON_TYPE_DCN;
                else
                    otherNeuronType = NEURON_TYPE_SS;
                end
                [suppressedPairs_SS_DCN, ~] = plotCCGPairs(pairs_SS_DCN, '', PAIR_TYPE_SS_DCN, units, unitOfInterest.neuronType, otherNeuronType, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
            end

            % Now look at the cell types inhibiting each other or excited together (synchronous)
            if strcmp(unitOfInterest.neuronType, NEURON_TYPE_MLI)
                pairs_MLI_MLI = findPairs(units, PAIR_TYPE_MLI_MLI, NEURON_TYPE_MLI, NEURON_TYPE_MLI, PAIR_MLI_MLI_MAX_LAYER_DISTANCE, unitOfInterest);
                [suppressedPairs_MLI_MLI, ~] = plotCCGPairs(pairs_MLI_MLI, '', PAIR_TYPE_MLI_MLI, units,NEURON_TYPE_MLI,NEURON_TYPE_MLI, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
            end
            if strcmp(unitOfInterest.neuronType, NEURON_TYPE_GoC)
                pairs_GO_GO = findPairs(units, PAIR_TYPE_GO_GO, NEURON_TYPE_GoC, NEURON_TYPE_GoC, PAIR_GO_GO_MAX_LAYER_DISTANCE, unitOfInterest);
                [suppressedPairs_GO_GO, ~] = plotCCGPairs(pairs_GO_GO, '', PAIR_TYPE_GO_GO, units,NEURON_TYPE_GoC,NEURON_TYPE_GoC, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
            end
            if strcmp(unitOfInterest.neuronType, NEURON_TYPE_SS)
                pairs_SS_SS = findPairs(units, PAIR_TYPE_SS_SS, NEURON_TYPE_SS, NEURON_TYPE_SS, PAIR_SS_SS_MAX_LAYER_DISTANCE, unitOfInterest);
                [suppressedPairs_SS_SS, ~] = plotCCGPairs(pairs_SS_SS, '', PAIR_TYPE_SS_SS, units,NEURON_TYPE_SS,NEURON_TYPE_SS, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
            end
        end
    else % plot all selected units
        
        pairs_CS_SS = findPairs(unitGoodSorted, PAIR_TYPE_CS_SS, NEURON_TYPE_CS, NEURON_TYPE_SS, PAIR_CS_SS_MAX_LAYER_DISTANCE, []);
        %pairs_DCS_SS = findPairs(unitGoodSorted, PAIR_TYPE_CS_SS, NEURON_TYPE_DCS, NEURON_TYPE_SS, PAIR_CS_SS_MAX_LAYER_DISTANCE, []);
        pairs_MF_GO = findPairs(unitGoodSorted, PAIR_TYPE_MF_GO, NEURON_TYPE_MFB, NEURON_TYPE_GoC, PAIR_MF_GO_MAX_LAYER_DISTANCE, []);
        pairs_GO_SS = findPairs(unitGoodSorted, PAIR_TYPE_GO_SS, NEURON_TYPE_GoC, NEURON_TYPE_SS, PAIR_GO_SS_MAX_LAYER_DISTANCE, []);
        pairs_MLI_SS = findPairs(unitGoodSorted, PAIR_TYPE_MLI_SS, NEURON_TYPE_MLI, NEURON_TYPE_SS, PAIR_MLI_SS_MAX_LAYER_DISTANCE, []);
        pairs_MF_SS = findPairs(unitGoodSorted, PAIR_TYPE_MF_SS, NEURON_TYPE_MFB, NEURON_TYPE_SS, PAIR_MF_SS_MAX_LAYER_DISTANCE, []);        
        pairs_SS_DCN = findPairs(unitGoodSorted, PAIR_TYPE_SS_DCN, NEURON_TYPE_SS, NEURON_TYPE_DCN, PAIR_SS_DCN_MAX_LAYER_DISTANCE, []);

        % Now look at the cell types inhibiting each other or excited together (synchronous)
        pairs_MLI_MLI = findPairs(unitGoodSorted, PAIR_TYPE_MLI_MLI, NEURON_TYPE_MLI, NEURON_TYPE_MLI, PAIR_MLI_MLI_MAX_LAYER_DISTANCE, []);
        pairs_GO_GO = findPairs(unitGoodSorted, PAIR_TYPE_GO_GO, NEURON_TYPE_GoC, NEURON_TYPE_GoC, PAIR_GO_GO_MAX_LAYER_DISTANCE, []);
        pairs_SS_SS = findPairs(unitGoodSorted, PAIR_TYPE_SS_SS, NEURON_TYPE_SS, NEURON_TYPE_SS, PAIR_SS_SS_MAX_LAYER_DISTANCE, []);

        [suppressedPairs_CS_SS, ~] = plotCCGPairs(pairs_CS_SS, '', PAIR_TYPE_CS_SS, unitGoodSorted,NEURON_TYPE_CS,NEURON_TYPE_SS, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
        [suppressedPairs_MF_GO, ~] = plotCCGPairs(pairs_MF_GO, '', PAIR_TYPE_MF_GO, unitGoodSorted,NEURON_TYPE_MFB,NEURON_TYPE_GoC, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
        [suppressedPairs_GO_SS, ~] = plotCCGPairs(pairs_GO_SS, '', PAIR_TYPE_GO_SS, unitGoodSorted,NEURON_TYPE_GoC,NEURON_TYPE_SS, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
        [suppressedPairs_MLI_SS, ~] = plotCCGPairs(pairs_MLI_SS, '', PAIR_TYPE_MLI_SS, unitGoodSorted,NEURON_TYPE_MLI,NEURON_TYPE_SS, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
        [suppressedPairs_MF_SS, ~] = plotCCGPairs(pairs_MF_SS, '', PAIR_TYPE_MF_SS, unitGoodSorted,NEURON_TYPE_MFB,NEURON_TYPE_SS, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);      
        [suppressedPairs_SS_DN, ~] = plotCCGPairs(pairs_SS_DCN, '', PAIR_TYPE_SS_DCN, unitGoodSorted, NEURON_TYPE_SS, NEURON_TYPE_DCN, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
                
        [suppressedPairs_MLI_MLI, ~] = plotCCGPairs(pairs_MLI_MLI, '', PAIR_TYPE_MLI_MLI, unitGoodSorted,NEURON_TYPE_MLI,NEURON_TYPE_MLI, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
        [suppressedPairs_GO_GO, ~] = plotCCGPairs(pairs_GO_GO, '', PAIR_TYPE_GO_GO, unitGoodSorted,NEURON_TYPE_GoC,NEURON_TYPE_GoC, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
        [suppressedPairs_SS_SS, ~] = plotCCGPairs(pairs_SS_SS, '', PAIR_TYPE_SS_SS, unitGoodSorted,NEURON_TYPE_SS,NEURON_TYPE_SS, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);

        pairs_Other_SS = findPairs(unitGoodSorted, PAIR_TYPE_OTHER_SS, NEURON_TYPE_OTHER, NEURON_TYPE_SS, PAIR_OTHER_MAX_LAYER_DISTANCE, []);
        plotCCGPairs(pairs_Other_SS, '', PAIR_TYPE_OTHER_SS, unitGoodSorted,NEURON_TYPE_OTHER,NEURON_TYPE_SS, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);

        pairs_Other_CS = findPairs(unitGoodSorted, PAIR_TYPE_OTHER_CS, NEURON_TYPE_OTHER, NEURON_TYPE_CS, PAIR_OTHER_MAX_LAYER_DISTANCE, []);
        plotCCGPairs(pairs_Other_CS, '', PAIR_TYPE_OTHER_CS, unitGoodSorted,NEURON_TYPE_OTHER,NEURON_TYPE_CS, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);

        pairs_Other_MF = findPairs(unitGoodSorted, PAIR_TYPE_OTHER_MF, NEURON_TYPE_OTHER, NEURON_TYPE_MFB, PAIR_OTHER_MAX_LAYER_DISTANCE, []);
        plotCCGPairs(pairs_Other_MF, '', PAIR_TYPE_OTHER_MF, unitGoodSorted,NEURON_TYPE_OTHER,NEURON_TYPE_MFB, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);

        pairs_Other_GO = findPairs(unitGoodSorted, PAIR_TYPE_OTHER_GO, NEURON_TYPE_OTHER, NEURON_TYPE_GoC, PAIR_OTHER_MAX_LAYER_DISTANCE, []);
        plotCCGPairs(pairs_Other_GO, '', PAIR_TYPE_OTHER_GO, unitGoodSorted,NEURON_TYPE_OTHER,NEURON_TYPE_GoC, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);
        
        pairs_Other_MLI = findPairs(unitGoodSorted, PAIR_TYPE_OTHER_MLI, NEURON_TYPE_OTHER, NEURON_TYPE_MLI, PAIR_OTHER_MAX_LAYER_DISTANCE, []);
        plotCCGPairs(pairs_Other_MLI, '', PAIR_TYPE_OTHER_MLI, unitGoodSorted,NEURON_TYPE_OTHER,NEURON_TYPE_MLI, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials, 0);

        % TODO: Other to Other CCG
    end
end