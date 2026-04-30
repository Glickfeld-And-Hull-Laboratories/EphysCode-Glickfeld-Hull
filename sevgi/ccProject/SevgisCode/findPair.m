function [unitSlave, trialsCueResponsive] = findPair(unitSlaves, recordingDayInd, unitMaster, behavioralTimes)
        globals; 
        
        indSlave = [];
        if ~isempty(unitSlaves)
            if FROM_CS_TO_SS
                if FLAG_PLOT_ONLY_PAIRED_WCS % get only paired SSs
                    indSlave = find([unitSlaves.RecorNum]==recordingDayInd & [unitSlaves.unitID]==unitMaster.PCpair);
                else
                    indSlave = find([unitSlaves.RecorNum]==recordingDayInd); % get all SSs from the same day
                end
            else
                if FLAG_PLOT_ONLY_PAIRED_WCS % get CSs that are paired with this SS (master)
                    indSlave = find([unitSlaves.RecorNum]==recordingDayInd & [unitSlaves.PCpair]==unitMaster.unitID);
                else
                    indSlave = find([unitSlaves.RecorNum]==recordingDayInd);  % get all CSs from the same day
                end
            end
        end

        unitSlave = [];
        trialsCueResponsive = [];
        
        if ~isempty(indSlave)
            unitSlave = unitSlaves(indSlave);
            
            if ~isempty(behavioralTimes) 
                allTrialCount = length(behavioralTimes);
                csPotentiationRange = [];
                if FROM_CS_TO_SS
                    if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
                        csPotentiationRange = CS_POTENTIATION_RANGE_AROUND_CUE;
                    elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
                        csPotentiationRange = CS_POTENTIATION_RANGE_AROUND_LICK;
                    end
                end
                
                if ~isempty(csPotentiationRange)                
                    spikeTimesToBeAlignedSec = unitMaster.timestamps;
                    trialsCueResponsive = zeros(1,allTrialCount);                
                
                    for indTrial=1:allTrialCount
                        % get spikes between hold and release
                        spikesOfTrial = spikeTimesToBeAlignedSec(spikeTimesToBeAlignedSec>(behavioralTimes(indTrial)+csPotentiationRange(1)) & spikeTimesToBeAlignedSec<(behavioralTimes(indTrial)+csPotentiationRange(2))); 
                        trialsCueResponsive(indTrial) = ~isempty(spikesOfTrial);                
                    end
                else
                    trialsCueResponsive = ones(1,allTrialCount);
                end
            end
        end
end