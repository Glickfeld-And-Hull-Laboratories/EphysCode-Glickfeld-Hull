function plotWaveform_SG(waveformStruct, unitIdx)

    units = waveformStruct.good_units;
    unitIdx = units(unitIdx);

    % Check if the specified unit index exists in the waveformStruct
    if isKey(waveformStruct.mean_waveform, unitIdx)
        % Extract mean and std waveforms for the specified unit
        meanWaveform    = waveformStruct.mean_waveform(unitIdx); % Use () for containers.Map
        stdWaveform     = waveformStruct.std_waveform(unitIdx);   % Use () for containers.Map
        
        % Create time vector for plotting (assuming 1 ms sample intervals)
        t               = (0:length(meanWaveform)-1); % Adjust based on actual sampling rate if necessary

        % Plot the average waveform with shaded error region
        figure;
        hold on;
        plot(t, meanWaveform, 'LineWidth', 1.5, 'Color', 'b'); % Mean waveform
        fill([t, fliplr(t)], [meanWaveform - stdWaveform, fliplr(meanWaveform + stdWaveform)], ...
            'b', 'FaceAlpha', 0.3, 'EdgeColor', 'none'); % Shaded error region
        hold off;

        % Add labels and title
        xlabel('Time (ms)');
        ylabel('Amplitude (uV)');
        title(['Average Waveform for Good Unit ID ', num2str(unitIdx)]);
        grid on;
    else
        error('Unit ID %d does not exist in waveformStruct.', unitIdx);
    end
end
