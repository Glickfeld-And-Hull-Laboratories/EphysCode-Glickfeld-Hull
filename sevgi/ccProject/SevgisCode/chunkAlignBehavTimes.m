function behavTimesAligned = chunkAlignBehavTimes(timesToBeAlignedSec, behavioralTimes)
    globals;
    
    allTrialCount = length(behavioralTimes);
    behavTimesAligned = cell(1,allTrialCount);                

    if ~isempty(timesToBeAlignedSec)
        for indTrial=1:allTrialCount        
            timesOfTrial = timesToBeAlignedSec{indTrial};        
            behavTimesAligned(indTrial) = {timesOfTrial - behavioralTimes(indTrial)}; % align according to Behav event
        end 
    end
end