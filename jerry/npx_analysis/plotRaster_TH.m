% Input:
% spikeMatrix - A cell array where spikeMatrix{unitIdx, stimIdx} contains spike times for each trial (0 to 1s).
% spikeOFFMatrix - A cell array where spikeOFFMatrix{unitIdx, stimIdx} contains baseline spike times (-0.2 to 0s).
% unitIdx - Index of the unit to plot.
% stimIdx - Index of the direction to plot.


function plotRaster_TH(uXtSpikesWithinTrial, stimTrialIdx,unitIdx, stimIdx)

spikeTimes  = uXtSpikesWithinTrial(unitIdx, stimTrialIdx{1,stimIdx}); % Spikes in baseline

hold on
% Loop over each trial and plot the spikes
for trialIdx = 1:length(spikeTimes)
    % Get spike times for this trial
    trialSpikeTimes     = spikeTimes{trialIdx};

    % Y-axis position for this trial
    yPosition = trialIdx; 
    
    % Plot **stimulus-related spikes** (stimulus duration--0 to 1s)
    plot(trialSpikeTimes, yPosition * ones(size(trialSpikeTimes)), 'k.', 'MarkerSize', 5);
end

xlabel('Time (s)');
ylabel('Trial Number');
title(stimTrialIdx{2,stimIdx});
ylim([0 length(spikeTimes) + 1]);
xlim([-.25 .45]); % Shows baseline (-.2 to 0s) and stimulus (0 to 1s)
% Plot stimulus onset line at **0s**
xline(0, 'r', 'LineWidth', 2); 
hold off


end
