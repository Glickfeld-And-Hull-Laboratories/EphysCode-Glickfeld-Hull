function spikeTimesAligned = chunkAlignSpikeTimes(timesToBeAlignedSec, behavioralTimes)
    globals;
    
    allTrialCount = length(behavioralTimes);
    spikeTimesAligned = cell(1,allTrialCount);                

    for indTrial=1:allTrialCount
        % get spikes between hold and release
        spikesOfTrial = timesToBeAlignedSec(timesToBeAlignedSec>(behavioralTimes(indTrial)-PRE_BEHAVIORAL_EVENT) & timesToBeAlignedSec<(behavioralTimes(indTrial)+PRE_BEHAVIORAL_EVENT)); 
        spikeTimesAligned(indTrial) = {spikesOfTrial - behavioralTimes(indTrial)}; % align according to Lever Hold                               
    end                       
end