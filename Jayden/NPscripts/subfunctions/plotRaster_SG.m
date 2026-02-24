function plotRaster_SG(spikeMatrix, spikeOFFMatrix, unitIdx, dirIdx)
    % Input:
    % spikeMatrix - A cell array where spikeMatrix{unitIdx, dirIdx} contains spike times for each trial (0 to 1s).
    % spikeOFFMatrix - A cell array where spikeOFFMatrix{unitIdx, dirIdx} contains baseline spike times (-0.2 to 0s).
    % unitIdx - Index of the unit to plot.
    % dirIdx - Index of the direction to plot.

    % Check if indices are valid
    if unitIdx > size(spikeMatrix, 1) || dirIdx > size(spikeMatrix, 2)
        error('Invalid unit or direction index');
    end
    
    % Get spike times for the specified unit and direction
    baselineSpikeTimes  = spikeOFFMatrix{unitIdx, dirIdx}; % Spikes in baseline (-0.5 to 0s)
    trialsSpikeTimes    = spikeMatrix{unitIdx, dirIdx};    % Spikes in stimulus (0 to 1s)
    
    % Check if there are any trials
    if isempty(trialsSpikeTimes)
        warning('No trials available for unit %d, direction %d.', unitIdx, dirIdx);
        return;
    end

    hold on;
    
    % Loop over each trial and plot the spikes
    for trialIdx = 1:length(trialsSpikeTimes)
        % Get spike times for this trial
        spikeTimes     = trialsSpikeTimes{trialIdx};  % 0 to 1s
        baselineTimes  = baselineSpikeTimes{trialIdx}; % -0.2 to 0s
        
        % Y-axis position for this trial
        yPosition = trialIdx; 
        
        % Plot **baseline spikes** (should already be between -0.5 and 0s)
        plot(baselineTimes, yPosition * ones(size(baselineTimes)), 'k.', 'MarkerSize', 5);
        
        % Plot **stimulus-related spikes** (stimulus duration--0 to 1s)
        plot(spikeTimes, yPosition * ones(size(spikeTimes)), 'k.', 'MarkerSize', 5);
    end
    
    xlabel('Time (s)');
    ylabel('Trial Number');
    title(['direction ' num2str(dirIdx)]);
    ylim([0 length(trialsSpikeTimes) + 1]);
    xlim([-0.2 1]); % Shows baseline (-0.5 to 0s) and stimulus (0 to 1s)
    
    % Plot stimulus onset line at **0s**
    xline(0, 'r', 'LineWidth', 2); 
    
    hold off;
end
