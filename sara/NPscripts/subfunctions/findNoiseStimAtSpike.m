% 
% function [trialIdx, frameIdx] = findNoiseStimAtSpike(spikeTime, timestamps, timeBeforeSpike)
%     spikeTime = spikeTime - timeBeforeSpike;
%     [nTrials, nFrames] = size(timestamps);
%     trialIdx = NaN;
%     frameIdx = NaN;
%     for it = 1:nTrials
%         ts = timestamps(it, :);
%         for ff = 1:nFrames
%             frameStart = ts(ff);
%             if ff < nFrames
%                 frameEnd = ts(ff+1);
%             else
%                 frameEnd = frameStart + 0.1;  % last frame ends 0.1s after its timestamp
%             end
%             if spikeTime >= frameStart && spikeTime < frameEnd
%                 trialIdx = it;
%                 frameIdx = ff;
%                 return
%             end
%         end
%     end
% end
% 
% 
% function [trialIdx, frameIdx] = findNoiseStimAtSpike(spikeTime, timestamps, timeBeforeSpike)
% 
%     spikeTime = spikeTime - timeBeforeSpike;
%     [nTrials, nFrames] = size(timestamps);
%     frameDuration = 0.1;
% 
%     trialIdx = NaN;
%     frameIdx = NaN;
% 
%     for it = 1:nTrials
%         ts = timestamps(it, :);
%         % Compute frame ends all at once
%         frameEnds = [ts(2:end), ts(end)+frameDuration];
% 
%         % Vectorized compare for this trial only
%         idx = find(spikeTime >= ts & spikeTime < frameEnds, 1);
%         if ~isempty(idx)
%             trialIdx = it;
%             frameIdx = idx;
%             return
%         end
%     end
% end



function [trialIdx, frameIdx] = findNoiseStimAtSpike(spikeTime, timestamps, timeBeforeSpike)

    spikeTime = spikeTime - timeBeforeSpike;
    [nTrials, nFrames] = size(timestamps);

    % Compute frame start times
    frameStarts = timestamps;

    % Compute frame end times:
    frameEnds = [timestamps(:,2:end), timestamps(:,end) + 0.1];     % Make an array shifted left by 1, and append +0.1s for last frame


    isInFrame = (spikeTime >= frameStarts) & (spikeTime < frameEnds);   % For each trial, check if spikeTime is in any frame interval

    [trialIdx, frameIdx] = find(isInFrame, 1, 'first');     % Find where this is true

    if isempty(trialIdx)    % If not found, set outputs to NaN
        trialIdx = NaN;
        frameIdx = NaN;
    end

end


