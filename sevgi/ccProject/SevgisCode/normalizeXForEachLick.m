function cellNormSpikeTimes = normalizeXForEachLick(individualSpikeTimes, individualLicks)

    globals;
    cellNormSpikeTimes = cell(1,length(individualSpikeTimes));

    for i=1:length(individualSpikeTimes)
        spikeTimes = individualSpikeTimes{i};
        lickTimes = individualLicks{i};
        normIliSpikeTimes = [];
        for l=1:length(lickTimes)
            if l<length(lickTimes)
                lastLick = lickTimes(l+1);
            else
                lastLick = lickTimes(l) + mean(diff(lickTimes)); % put a hypothetical endpoint to account for the last lick
            end
            
            if l==1 % for the first lick expand the baseline, maybe you'd need it for the pos/neg modulated analysis
                iliSpikes = spikeTimes(spikeTimes>(lickTimes(l)-PRE_BEHAVIORAL_EVENT) & spikeTimes<=lastLick);
            else
                iliSpikes = spikeTimes(spikeTimes>lickTimes(l) & spikeTimes<=lastLick);
            end

            if ~isempty(iliSpikes)
                ili = lastLick-lickTimes(l); % unity lick time
                normIliSpikeTimes = [normIliSpikeTimes; ((iliSpikes-lickTimes(l))/ili + (l-1))]; % normalize and then add lick step
            end
        end
        cellNormSpikeTimes{i} = normIliSpikeTimes;
    end
end