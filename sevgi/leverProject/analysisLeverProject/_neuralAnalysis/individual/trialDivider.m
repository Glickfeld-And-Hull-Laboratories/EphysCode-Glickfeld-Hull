%%%% Divide trials into 3 to observe if any change in Spike Waveform during the trial %%%%%%%%%%%%
% spikeTimes: Spike times cell per trial
%
% SO 2/17/2023 Hull Lab
function [spikeTimes1, spikeTimes2, spikeTimes3] = trialDivider(spikeTimes)
    % Divide the trials into 3: BEGINNING, MIDDLE, END
    oneThird = fix(length(spikeTimes)/3);
    spikeTimes1 = spikeTimes(1:oneThird);
    spikeTimes2 = spikeTimes(oneThird+1:2*oneThird);
    spikeTimes3 = spikeTimes(2*oneThird+1:end);
end