% Extracts raw waveforms from the AP binary file instead of using templates.npy.
% Inputs:
%   - ksDir: Path to Kilosort output directory
%   - imecFile: Path to the raw AP binary file (e.g., 'imec0.ap.bin')
%   - fs_threshold: Peak-to-trough time threshold (e.g., 0.35 ms)
%   - num_samples: Number of waveform samples per spike (e.g., 50)
% Output:
%   - waveformStruct: Structure containing waveforms, classifications, and cluster IDs


function waveformStruct = createWaveformStruct(ksDir, imecFile, fs_threshold, num_samples)
    % Load spike data
    spike_times  = readNPY(fullfile(ksDir, 'spike_times.npy')); % Spike time indices
    spike_clusters = readNPY(fullfile(ksDir, 'spike_clusters.npy')); % Cluster IDs
    sample_rate = 30000; % SpikeGLX default sample rate

    % Load Phy's cluster group file to filter "good" units
    cluster_file = fullfile(ksDir, 'cluster_group.tsv');
    if exist(cluster_file, 'file')
        fid = fopen(cluster_file, 'r');
        data = textscan(fid, '%d %s', 'HeaderLines', 1); % Read cluster ID and label
        fclose(fid);
        
        good_units = data{1}(strcmp(data{2}, 'good')); % Extract "good" unit IDs
    else
        error('cluster_group.tsv not found. Run Phy and save curation.');
    end

    % Identify "good" spikes
    good_spike_idx      = ismember(spike_clusters, good_units);
    spike_times         = spike_times(good_spike_idx);
    spike_clusters      = spike_clusters(good_spike_idx);

    % Open raw AP file for waveform extraction
    fid = fopen(imecFile, 'r');
    if fid == -1
        error('Could not open raw AP file: %s', imecFile);
    end

    % Get number of channels (assuming 385 for Neuropixels 1.0)
    num_channels        = 385;
    bytes_per_sample    = 2; % int16
    fseek(fid, 0, 'eof');
    file_size           = ftell(fid);
    num_samples_total   = file_size / (num_channels * bytes_per_sample);
    fclose(fid);

    % Re-open for reading waveforms
    fid = fopen(imecFile, 'r');

    % Initialize structure fields
    waveformStruct.mean_waveform    = containers.Map('KeyType', 'double', 'ValueType', 'any');
    waveformStruct.std_waveform     = containers.Map('KeyType', 'double', 'ValueType', 'any');
    waveformStruct.peak_to_trough   = containers.Map('KeyType', 'double', 'ValueType', 'double');
    waveformStruct.RScells          = [];
    waveformStruct.FScells          = [];
    waveformStruct.good_units       = unique(spike_clusters);

    % Define time window for waveform extraction
    pre_samples     = round(num_samples / 3);  % Pre-spike samples
    post_samples    = num_samples - pre_samples; % Post-spike samples

    % Process each unique unit
    for unit_id = waveformStruct.good_units'
        unit_spike_times    = spike_times(spike_clusters == unit_id);
        num_spikes          = min(200, numel(unit_spike_times)); % Limit to 200 spikes per unit for efficiency

        % Extract raw waveforms
        waveforms = zeros(num_spikes, num_samples);
        for j = 1:num_spikes
            spike_idx   = unit_spike_times(j);
            start_idx   = spike_idx - pre_samples;
            end_idx     = spike_idx + post_samples - 1;

            % Ensure index is within valid range
            if start_idx < 1 || end_idx > num_samples_total
                continue;
            end

            % Read waveform snippet
            fseek(fid, start_idx * num_channels * bytes_per_sample, 'bof');
            raw_data                = fread(fid, [num_channels, num_samples], 'int16');
            best_channel_waveform   = raw_data(1, :); % Choose best channel (improve later)
            waveforms(j, :)         = best_channel_waveform;
        end

        % Compute mean and std waveform
        mean_waveform   = mean(waveforms, 1);
        std_waveform    = std(waveforms, [], 1);

        % Compute peak-to-trough time
        [~, peak_idx]   = min(mean_waveform); % Trough
        [~, trough_idx] = max(mean_waveform(peak_idx:end)); % Peak after trough
        peak_to_trough  = (trough_idx) / sample_rate * 1000; % Convert to ms

        % Store waveforms in struct
        waveformStruct.mean_waveform(unit_id)   = mean_waveform;
        waveformStruct.std_waveform(unit_id)    = std_waveform;
        waveformStruct.peak_to_trough(unit_id)  = peak_to_trough;

        % Classify FS vs RS
        if peak_to_trough < fs_threshold
            waveformStruct.FScells = [waveformStruct.FScells, unit_id];
        else
            waveformStruct.RScells = [waveformStruct.RScells, unit_id];
        end
    end

    fclose(fid);
end
