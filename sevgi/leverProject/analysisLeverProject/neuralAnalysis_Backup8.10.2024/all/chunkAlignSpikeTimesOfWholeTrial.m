function [spikeTimeofTrialAlignedToLeverRelease, spikeTimeofTrialwITIAlignedToLeverRelease, leverHoldTimesAlignedToLeverRelease]= chunkAlignSpikeTimesOfWholeTrial(spikeTimesSec, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, predTrialCount, allTrialCount)
        globals;

        spikeTimeofTrialAlignedToLeverRelease = cell(1,predTrialCount);
        spikeTimeofTrialwITIAlignedToLeverRelease = cell(1,predTrialCount);
        leverHoldTimesAlignedToLeverRelease = -99*ones(1,predTrialCount);

        indPredTrial=1;
        for indTrial=fixedHoldStartsAtTrial:allTrialCount
            % get spikes between hold and release                        
            spikesOfTrial = spikeTimesSec(spikeTimesSec>(leverHoldTimes(indTrial)-PRE_TIME_HOLD) & spikeTimesSec<(leverReleaseTimesGLX(indTrial)+POST_TIME_RELEASE));             
            spikeTimeofTrialAlignedToLeverRelease(indPredTrial) = {spikesOfTrial - leverReleaseTimesGLX(indTrial)}; % align according to Lever Release           
            
            % get spikes between hold of a trial and hold of the next trial
            if indTrial+1>=allTrialCount
                nextTrialStartTime = leverReleaseTimesGLX(indTrial)+POST_TIME_RELEASE;
            else
                nextTrialStartTime = leverHoldTimes(indTrial+1)-PRE_TIME_HOLD;
            end
            spikesOfTrialwITI = spikeTimesSec(spikeTimesSec>(leverHoldTimes(indTrial)-PRE_TIME_HOLD) & spikeTimesSec<nextTrialStartTime); 
            spikeTimeofTrialwITIAlignedToLeverRelease(indPredTrial) = {spikesOfTrialwITI - leverReleaseTimesGLX(indTrial)}; % align according to Lever Release  
            
            leverHoldTimesAlignedToLeverRelease(indPredTrial) = leverHoldTimes(indTrial) - leverReleaseTimesGLX(indTrial); % align Lever Hold times acc to Release

            indPredTrial=indPredTrial+1;
        end
end