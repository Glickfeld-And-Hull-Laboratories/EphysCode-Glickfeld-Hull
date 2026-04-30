function [unitGoodSorted,unitMuaSorted,unitNoiseSorted, flagInhibit, flagSynchedExc, flagSynchedInh, sInhibit, sSynchExcitation, sSynchInhibition]= ...
    identifyMLIs_Inhibits_Synched(otherType, ccgType, maxDistance, unitGoodSorted,unitMuaSorted,unitNoiseSorted, movingTimesToBeExcluded, indMLI1)
        globals;

        flagInhibit = -1; % the state of 'No Cell from Other Type'
        flagSynchedExc = -1; % the state of 'No Cell from Other Type'
        flagSynchedInh = -1; % the state of 'No Cell from Other Type'

        sInhibit = [];
        sSynchExcitation = [];
        sSynchInhibition = [];
        
        sMLI = [NEURON_TYPE_MLI '_' num2str(unitGoodSorted(indMLI1).id) '(' num2str(unitGoodSorted(indMLI1).depth) 'um) '];

        for indOtherType=1:length(unitGoodSorted)
            if strcmp(unitGoodSorted(indOtherType).neuronType,otherType) && unitGoodSorted(indOtherType).id~=unitGoodSorted(indMLI1).id && ...
                abs(unitGoodSorted(indOtherType).depth-unitGoodSorted(indMLI1).depth)<=maxDistance % found a close-by other type neuron
                
                sOtherType = [otherType '_' num2str(unitGoodSorted(indOtherType).id) '(' num2str(unitGoodSorted(indOtherType).depth) 'um) '];
                
                % change the state of the flags from No other type of cell at all (-1) to 'there were some SS' (0) since it is not the same thing that this MLI either did not have any SS or it had but did not suppressed
                if flagInhibit == -1 % if it is still is the state of 'No Cell from Other Type', say there is at least one since it is in the loop now!
                    flagInhibit = 0; 
                end
                if flagSynchedExc == -1 % if it is still is the state of 'No Cell from Other Type', say there is at least one since it is in the loop now!
                    flagSynchedExc = 0;
                end
                if flagSynchedInh == -1 % if it is still is the state of 'No Cell from Other Type', say there is at least one since it is in the loop now!
                    flagSynchedInh = 0;
                end

                [~, inhibited, ~, synchExc, synchInh, unitGoodSorted, readForTheFirstTime, ~, ~] = correlogramRateCorrected([unitGoodSorted(indMLI1).id unitGoodSorted(indOtherType).id], ccgType, unitGoodSorted, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimesToBeExcluded, BASELINE, 'k', 0);
                if synchExc
                    flagSynchedExc = 1;
                    sSynchExcitation = [sSynchExcitation sOtherType ','];
                end
                if synchInh
                    flagSynchedInh = 1;
                    sSynchInhibition = [sSynchInhibition sOtherType ','];
                end
                
                if inhibited
                    flagInhibit = 1;
                    sInhibit = [sInhibit sOtherType ','];
%                     break; % Since the algorithm faster now we can loop till the end to be able to see all synched couples and misclassified SS as MLI % At least one inhibition is enough
                end
            end
        end    
end