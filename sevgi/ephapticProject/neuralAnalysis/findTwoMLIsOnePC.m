% Finds 2 MLI1s and 1 PC in close proximity
% SO - Hull lab 8/20/2025
function findTwoMLIsOnePC(unitGood)
    
    globals;

    for ind1=1:length(unitGood)
        unit1 = unitGood(ind1);
        if strcmp(unit1.neuronSubType,NEURON_TYPE_MLI1)
            for ind2=ind1+1:length(unitGood)
                unit2 = unitGood(ind2);
                if strcmp(unit2.neuronSubType,NEURON_TYPE_MLI1)
                    for indSS=1:length(unitGood)
                        unitSS = unitGood(indSS);
                        if strcmp(unitSS.neuronType,NEURON_TYPE_SS) && ...
                                abs(unitSS.depth-unit1.depth)<=PAIR_SS_MLI_MAX_LAYER_DISTANCE && ...
                                abs(unitSS.depth-unit2.depth)<=PAIR_SS_MLI_MAX_LAYER_DISTANCE
                                synchDetector(unit1, unit2, unitSS, unitGood);
                        end
                    end
                end
            end
        end
    end
end