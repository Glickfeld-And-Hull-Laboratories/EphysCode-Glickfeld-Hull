
function [trialIdx, frameIdx] = findNoiseStimAtSpike(spikeTime, timestamps, timeBeforeSpike)
    spikeTime = spikeTime - timeBeforeSpike;

    [nTrials, nFrames] = size(timestamps);
    trialIdx = NaN;
    frameIdx = NaN;

    for it = 1:nTrials
        ts = timestamps(it, :);

        for ff = 1:nFrames
            frameStart = ts(ff);
            if ff < nFrames
                frameEnd = ts(ff+1);
            else
                frameEnd = frameStart + 0.1;  % last frame ends 0.1s after its timestamp
            end

            if spikeTime >= frameStart && spikeTime < frameEnd
                trialIdx = it;
                frameIdx = ff;
                return
            end
        end
    end
end
