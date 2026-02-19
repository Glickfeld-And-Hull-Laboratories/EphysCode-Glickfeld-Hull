
%% Neuropixel analysis pipeline tutorial
% Made by SG, 2026-02-18


%% Load experiment information

clear all; close all; clc
baseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
iexp = 1; % Choose experiment

[exptStruct] = createExptStruct_tutorial(iexp); % Load relevant times and directories for this experiment

% I recommend reading through the above function and the
% experiment list it calls as an example of one way to organize your
% collected data for analysis.


%% Extract units from KS output
% This tutorial uses sorted spiking data and stimulus information that is already synced to the neural data. For sorting in Kilosort and Phy2 and syncing using CatGT and TPrime, 
% reference this protocol: https://docs.google.com/document/d/1Wmkkb9TnFrQzwDYZlS97jVEY9kwX42daFpmgGfw0XFE/edit?tab=t.0
%

load(fullfile(baseDir, '\sara\Analysis\Neuropixel', [exptStruct.date], [exptStruct.date '_' exptStruct.mouse '_unitStructs.mat']), 'goodUnitStruct');
% goodUnitStruct is a structure that contains all units that I sorted as
% "good" (as opposed to "noise" or "MUA").

%% Extract information about spiking and spike waveforms
% First, let's look at how to pull and analyze individual waveforms.
%
% Get mean and std waveform over time, calculate peak-to-trough time of the
% max amplitude waveform across contact sites.

% Setting parameters for waveform extraction and inclusion
    refractoryViolationThresh   = 0.002;     % 2 ms

% Initialize and extract meta file info for waveform analysis
    fullDataPath    = fullfile(baseDir, exptStruct.loc, 'Analysis', 'Neuropixel', exptStruct.date); % Navigate to experiment directory
    dirContents     = dir(fullDataPath); % Get names of all files and folders in the experiment directory
    runFolders      = {dirContents([dirContents.isdir] & ~ismember({dirContents.name}, {'.', '..'})).name}; % Get the names of all folders in experiment directory
    metaMask        = startsWith(runFolders, 'catgt', 'IgnoreCase', false) & ~contains(runFolders, 'ret', 'IgnoreCase', true);   % Logical mask for folders starting with 'catgt' and not containing 'ret'
    % ^ Choose catgt folder for the experimental run (not retinotopy run).
    % The catgt folder is created as an output of syncing stimulus
    % information to neural data.    
    metaFolder      = runFolders(metaMask); % Get the name of the folder that matches the above criteria

% Change currenty directory to the 
    cd(fullfile(fullDataPath,cell2mat(metaFolder)))

% Find the waveform file
    binfolder       = dir('*ap.bin');
    binName         = binfolder(1).name;
    path            = binfolder(1).folder;


%% We will use an example unit to look closely interspike intervals and refractory period violations and to generate an autocorrelogram.

% Choose an example cell
    ic = 82;
    fprintf([ 'cell ' num2str(ic) '\n'])

% Get cell info
    timestamps  = goodUnitStruct(ic).timestamps; % List of timestamps of all spikes. Later, we'll use these timestamps to look at stimulus driven activity.
    channel     = goodUnitStruct(ic).channel;    % Center/"best" channel for the unit


% ================
% Computing and plotting interspike intervals 
% ================
%
%  The ISI is the time between consecutive spikes.
%  It tells us about:
%    - Refractory period violations (very short ISIs)
%    - Bursting (peaks at short intervals)
%    - Firing regularity
%
%  IMPORTANT:
%  ISI uses only consecutive spikes.
%  This is different from an autocorrelogram, which uses all spike pairs.


% For the sake of time, we don't need to compute ISIs for the entire
% experimental recording, so we will limit the analysis to 10,000
% consecutive spikes
    if length(timestamps) > 10000 % if there are more than 10,000 spikes, randomly sample 10,0000
        randSpikeTime    = randsample(length(timestamps)-10000,1); % choose a spike index randomly, with room to take the subsequent indices
        spikeTimesForISI = timestamps(randSpikeTime:randSpikeTime+9999); % then take that spike index plus the next 9,999
    else
        spikeTimesForISI = timestamps;
    end

% Get interspike intervals and probabilities
    isi = diff(spikeTimesForISI); % Find the time differences between all spikes
    isiEdges = 0:0.001:0.1;  % 1 ms bins from 0 to 100 ms
    [isiCounts, ~] = histcounts(isi, isiEdges); % count how many spikes in each time bin
    isiProb = isiCounts / sum(isiCounts);  % normalize to probability

% Plot ISI histogram
    figure(1);
        movegui('center')
        sgtitle(['cell ' num2str(ic)])
        subplot(3,1,1)
            isiProb     = isiProb;
            isiEdges    = isiEdges;
            bar(isiEdges(1:end-1), isiProb, 'histc'); hold on
            xlabel('interspike interval (s)');
            ylabel('probability');
            title('Interspike interval');    




% ================
% Computing and plotting an autocorrelogram 
% ================
%
% An autocorrelogram shows how often a neuron fires at different time
% lags relative to one of its own spikes. For each spike, we compute the 
% time difference between that spike and all other spikes. We then build a 
% histogram of those time differences.
%
% Interpretation:
%   - A dip around 0 ms demonstrates the refractory period (the neuron 
%     cannot immediately fire again).
%   - The lack of a dip around 0 ms can indicate a poorly sorted unit
%     (multiunit activity) and a peak can indicate that spikes are being
%     double counted--both of these are undesirable.
%   - A peak at short lags (e.g., 2–5 ms) can indicate bursting.
%   - Periodic peaks suggest rhythmic or oscillatory firing.
%
% Note: Unlike the ISI histogram, which only looks at lag between 
% consecutive spikes, the autocorrelogram looks at lag between all spike 
% pairs within a specified lag window.
%
% Normally, an autocorrelogram would analyze all spikes in the recording
% session, but for the purpose of speed in this tutorial, we are only 
% using the 10,0000 spikes from the ISI analysis.


% Get autocorrelogram and violations
    maxLag  = 0.025;  % +/- 25 ms, for plotting
    binSize = 0.001;  % 1 ms bins, for plotting
    acEdges   = -maxLag:binSize:maxLag;
    lenTimes = 1:length(spikeTimesForISI); % number of spikes used for analysis
    
    % Compute all pairwise time differences
    dt = [];  % to collect all time differences
    for i = lenTimes
        diffs = spikeTimesForISI - spikeTimesForISI(i);
        diffs(i) = [];  % remove zero lag (self-pair)
        dt = [dt; diffs(abs(diffs) <= maxLag)];
    end
    [acCounts, acEdges] = histcounts(dt, acEdges);  % get bin counts
    acBinCenters = acEdges(1:end-1) + binSize/2;
    refractoryCounts = sum(abs(dt) < refractoryViolationThresh)/2;  % Find refractory period violations. Autocorrelogram double counts, so divide by 2
    
    nSpikesUsed = length(spikeTimesForISI);
    refViolationPct = refractoryCounts/nSpikesUsed;

% Plot autocorrelogram
    figure(1);
        movegui('center')
        subplot(3,1,2)
            bar(acBinCenters, acCounts, 'hist'); hold on
            xline(refractoryViolationThresh, 'r')
            xline(-refractoryViolationThresh, 'r')
            xlabel('time from spike');
            ylabel('count');
            title([num2str(refractoryCounts) '/' num2str(nSpikesUsed) ' spike violations'])



% ================
% Getting sample waveforms from the ap.bin file
% ================

% First, initialize how many waveforms to sample and how long before/after
% the spike you want to plot
    num_samples                 = 100;       % How many waveforms do you want to sample for the waveform shape analysis?
    dataLengthPreSpike          = 0.001;     % This is the data length that is subtracted from the spike time in order to see preceding baseline
    dataLengthTotal             = 0.003;     % This is the full data length that is pulled/plotted (x-axis)

    meta = ReadMeta_sg(binName, path);     % Parse the corresponding metafile
    chan = channel +1;     % Convert channel index to MATLAB format (probe channels are 0-based, MATLAB indexing is 1-based)

% We want to sample waveforms evenly across the experimental run, so we
% divide the spike timestamps into chunks based on the number of waveforms
% we want to sample
    step        = floor(length(timestamps)/num_samples);  % Number of spikes per chunk (used to distribute sampling evenly across time)
    sampRate    = SampRate_sg(meta);   % Extract sampling rate (Hz) from metadata
    spikeStart  = (timestamps - dataLengthPreSpike);   % Compute waveform extraction start time (shift back to include baseline)
    nSamp       = int64(floor(dataLengthTotal * sampRate));  % Total number of samples per waveform segment
    timestep    = 1/sampRate;  % Time between consecutive samples
    time        = 0:timestep:dataLengthTotal-1/sampRate;  % Time vector for plotting extracted waveforms
    SampleTS    = zeros(num_samples,1);  % Preallocate array to store sampled spike timestamps

% If there are enough spikes to divide into chunks
    if step > 0
        randIdx_local = zeros(num_samples, 1);  % Preallocate array for randomly selected spike indices
        for i = 1:num_samples
            randIdx_local(i,1) = randi([(((i-1)*step)+1),(i*step)]);  % Randomly select one spike index from each chunk
        end
        TSindex = randIdx_local;   % Indices of spikes that will be used for waveform extraction
    else
        TSindex = (1:length(spikeStart)).';   % If fewer spikes than requested samples, use all available spikes
    end

 % Extract waveforms from neural data file
    waveforms = zeros(nSamp, length(TSindex));  % Preallocate matrix to store extracted waveforms. Rows = time samples, Columns = individual spike waveforms
    for i = 1:length(TSindex)
        samp0           = int64(spikeStart(TSindex(i,1))*sampRate);  % Convert spike start time (seconds) to sample index
        SampleTS(i)     = spikeStart(TSindex(i,1)); % Store the spike timestamp used for this waveform
        dataArray_raw   = ReadBin_sg(samp0, nSamp, meta, binName, path);  % Read raw binary data segment starting at samp0
        dataArray       = GainCorrectIM_sg(dataArray_raw, chan, meta);    % Apply gain correction to convert raw values to physical units (this function is specifically for imec analog channels)
        waveforms(:,i)  = dataArray(chan,:);   % Extract the selected channel and store waveform
    end

 % Now that we have 100 sampled waveforms, find the average waveform
    waveformAvg             = mean(waveforms,2);   % Average across columns (each column = one spike waveform) to get a single mean waveform (time x 1)

 % Find the minimum and maxiumum values of the waveform
    [waveformMin, minIdx]   = min(waveformAvg);
    [waveformMax, maxIdx]   = max(waveformAvg(minIdx:end));     % Look only for peak after trough
    maxIdx                  = (minIdx - 1) + maxIdx;      % Correct index because max() was computed on a truncated vector

 % A common way to identify cell types is through waveform analyses, such
 % as the peak-to-trough distance and ratio as well as slope.
    waveformBaseline        = mean(waveformAvg(1:2*(dataLengthPreSpike*sampRate)/3));  % Estimate baseline using the first ~2/3 of the pre-spike window. This assumes the early part of the waveform represents noise baseline
    
    PtTratio                = (waveformMax-waveformBaseline)/abs(waveformMin-waveformBaseline);  % Ratio of peak amplitude to trough amplitude (relative to baseline)
    % Numerator  = rebound peak height above baseline
    % Denominator = trough depth below baseline
    % abs() ensures positive denominator

    PtTdist                 = (maxIdx-minIdx)/sampRate; % Peak-to-trough time (seconds)

    % Find slope at 0.5 ms after trough
    slopeTime               = floor(0.0005 * sampRate);     % Number of samples corresponding to 0.5 ms after trough
    x_data                  = (minIdx+slopeTime-1 : minIdx+slopeTime+1);  % Take 3 points centered at 0.5 ms after trough
    y_data                  = waveformAvg(x_data);  % Corresponding waveform amplitudes
    pfit                    = polyfit(x_data, y_data, 1);   % Linear regression
    slope                   = pfit(1);  % Extract slope coefficient (rate of voltage change per sample index)

% Plot average waveform
    figure(1);
        movegui('center')
        x = 1:size(waveforms,1);  
        subplot(3,1,3)
            wvStd       = std(waveforms,0,2);
            wvSEM       = wvStd/sqrt(num_samples);
            wvAvg       = waveformAvg;
            plot(wvAvg); hold on
            shadedErrorBar(x,wvAvg,wvSEM)
            xline(minIdx,'b') % blue line at waveform peak
            xline(maxIdx,'r') % red line at waveform trough
            yline(waveformBaseline,'k')
            title(['Peak to Trough dist = ' sprintf('%.2f ms', PtTdist * 1000)])   % I only want 2 decimal places after 0
        



%% Now, do the same, but for all sorted units. 
% This will take about 15 minutes to run. Here, we are using CPU threads to
% parallel process multiple cells at a time so that this analysis runs more quickly.

nCells = size(goodUnitStruct,2);
cellIdx = 1:nCells;

parpool("Threads", 20)   % Start parallel pool processing
tic
parfor ic  = cellIdx
    fprintf([ 'cell ' num2str(ic) '\n'])

% Get cell info
    timestamps  = goodUnitStruct(ic).timestamps;
    channel     = goodUnitStruct(ic).channel;
    rank        = goodUnitStruct(ic).rank;

    if length(timestamps) > 10000
        spikeTimesForISI = timestamps(randsample(length(timestamps),10000));
        spikeTimesForISI = sort(spikeTimesForISI);   % sort into ascending order
    else
        spikeTimesForISI = timestamps;
    end

% Get interspike intervals and probabilities

    isi = diff(spikeTimesForISI);
    isiEdges = 0:0.001:0.1;  % 1 ms bins from 0 to 100 ms
    [isiCounts, ~] = histcounts(isi, isiEdges);
    isiProb = isiCounts / sum(isiCounts);  % normalize to probability


% Get autocorrelogram and violations

    maxLag  = 0.025;  % +/- 25 ms, for plotting
    binSize = 0.001;  % 1 ms bins, for plotting
    acEdges   = -maxLag:binSize:maxLag;
    lenTimes = 1:length(spikeTimesForISI);
    
    % Compute all pairwise time differences
    dt = [];  % to collect all time differences
    for i = lenTimes
        diffs = spikeTimesForISI - spikeTimesForISI(i);
        diffs(i) = [];  % remove zero lag (self-pair)
        dt = [dt; diffs(abs(diffs) <= maxLag)];
    end
    [acCounts, acEdges] = histcounts(dt, acEdges);  % get bin counts
    acBinCenters = acEdges(1:end-1) + binSize/2;
    refractoryCounts = sum(abs(dt) < refractoryViolationThresh)/2;  % Find refractory period violations. Autocorrelogram double counts, so 

 
% Get sample waveforms

    meta = ReadMeta_sg(binName, path);     % Parse the corresponding metafile
    chan = channel +1;  
    step = floor(length(timestamps)/num_samples); % How many spikes in each time duration division so some spikes are chosen from each segement

    sampRate    = SampRate_sg(meta);
    spikeStart  = (timestamps - dataLengthPreSpike);     % This is the data length that is pulled/plotted (x-axis)); % catch the begining of the waveform
    nSamp       = int64(floor(dataLengthTotal * sampRate));
    timestep    = 1/sampRate;
    time        = 0:timestep:dataLengthTotal-1/sampRate;
    SampleTS    = zeros(num_samples,1);

    % Get first one second of data = 1
    if step > 0
        randIdx_local = zeros(num_samples, 1); % preallocate inside iteration
        for i = 1:num_samples
            randIdx_local(i,1) = randi([(((i-1)*step)+1),(i*step)]);
        end
        TSindex = randIdx_local;
    else
        TSindex = (1:length(spikeStart)).';
        if ~isempty(spikeStart)
            fprintf('\nNot enough spikes to perform planned calculation. %i spikes are averaged and plotted\n', length(timestamps))
        end
    end
        
    if ~isempty(spikeStart)
        waveforms = zeros(nSamp, length(TSindex));
        for i = 1:length(TSindex)
            samp0       = int64(spikeStart(TSindex(i,1))*sampRate);
            SampleTS(i) = spikeStart(TSindex(i,1));
            dataArray   = ReadBin_sg(samp0, nSamp, meta, binName, path);
            % % % change y values to volts
            % For an analog channel: gain correct saved channel ch (1-based for MATLAB).
            ch = chan;
            
            % For a digital channel: read this digital word dw in the saved file
            % (1-based). For imec data there is never more than one saved digital word.
            dw = 1;
            
            if strcmp(meta.typeThis, 'imec')
                dataArray = GainCorrectIM_sg(dataArray, [ch], meta);
            else
                dataArray = GainCorrectNI_sg(dataArray, [ch], meta);
            end

            waveforms(:,i) = dataArray(chan,:);
        end
    else
    fprintf('\nNo spikes in window. Avg WF = 0.\n')
    end

    waveformAvg             = mean(waveforms,2);
    waveformBaseline        = mean(waveformAvg(1:2*(dataLengthPreSpike*sampRate)/3));
    [waveformMin, minIdx]   = min(waveformAvg);
    [waveformMax, maxIdx]   = max(waveformAvg(minIdx:end));     % Look only for peak after trough
    maxIdx                  = (minIdx - 1) + maxIdx;      % Correct the max index

% Calculate peak to trough ratio and distance. This can be used for
% identifying fast-spiking v. regular spiking neurons and cell type.
    PtTratio                = (waveformMax-waveformBaseline)/abs(waveformMin-waveformBaseline);
    PtTdist                 = (maxIdx-minIdx)/sampRate;

    slopeTime               = floor(0.0005 * sampRate);     % Find slope at 0.5 ms after trough
    x_data                  = (minIdx+slopeTime-1 : minIdx+slopeTime+1); 
    y_data                  = waveformAvg(x_data);
    pfit                    = polyfit(x_data, y_data, 1);   % Linear regression
    slope                   = pfit(1);


    nSpikesUsed = length(spikeTimesForISI);
    refViolationPct = refractoryCounts/nSpikesUsed;

% Save output into structures
    spikingStruct(ic).isiProb       = isiProb;
    spikingStruct(ic).isiEdges      = isiEdges;
    spikingStruct(ic).acCounts      = acCounts;
    spikingStruct(ic).acBins        = acBinCenters;
    spikingStruct(ic).refViolations = refractoryCounts;
    spikingStruct(ic).nSpikesUsed   = nSpikesUsed;

    waveformStruct(ic).allsamps     = waveforms;
    waveformStruct(ic).average      = waveformAvg;
    waveformStruct(ic).baseline     = waveformBaseline;
    waveformStruct(ic).min          = waveformMin;
    waveformStruct(ic).max          = waveformMax;
    waveformStruct(ic).minIdx       = minIdx;
    waveformStruct(ic).maxIdx       = maxIdx;
    waveformStruct(ic).PtTratio     = PtTratio;
    waveformStruct(ic).PtTdist      = PtTdist;   % in seconds
    waveformStruct(ic).slope        = slope;   
    waveformStruct(ic).samprate     = sampRate;   % in seconds
end
toc
delete(gcp("nocreate"));


%% Now we can plot many cells at one time to compare spiking and waveform features

idxCells = 82:4:110;  % Index of example cells to plot
figure;
x = 1:size(waveformStruct(1).allsamps,1);
i=1;
for ic = idxCells
    subplot(8,3,i)
        isiProb     = spikingStruct(ic).isiProb;
        isiEdges    = spikingStruct(ic).isiEdges;
        bar(isiEdges(1:end-1), isiProb, 'histc'); hold on
        xlabel('interspike interval (s)');
        ylabel('probability');
        title(['cell ' num2str(ic) '- interspike interval']);        
    subplot(8,3,i+1)
        acCounts        = spikingStruct(ic).acCounts;
        acBinCenters    = spikingStruct(ic).acBins;
        bar(acBinCenters, acCounts, 'hist'); hold on
        xline(refractoryViolationThresh)
        xline(-refractoryViolationThresh)
        xlabel('time from spike');
        ylabel('count');
        title('autocorrelogram, no binning');
        title([num2str(spikingStruct(ic).refViolations) '/' num2str(spikingStruct(ic).nSpikesUsed) ' spike violations'])
    subplot(8,3,i+2)
        waveforms   = [waveformStruct(ic).allsamps];
        wvStd       = std(waveforms,0,2);
        wvSEM       = wvStd/sqrt(num_samples);
        wvAvg       = [waveformStruct(ic).average];
        plot(wvAvg); hold on
        shadedErrorBar(x,wvAvg,wvSEM)
        xline([waveformStruct(ic).minIdx],'b')
        xline([waveformStruct(ic).maxIdx],'r')
        yline([waveformStruct(ic).baseline],'k')
        title(['PtT dist = ' sprintf('%.2f ms', waveformStruct(ic).PtTdist * 1000)])   % I only want 2 decimal places after 0
    i=i+3;
end

% Spike waveform shape reflects both biological cell type and recording 
% geometry.
% In cortex (including V1), inhibitory interneurons tend to be 
% "fast-spiking" (FS) and exhibit narrow spike waveforms, while 
% excitatory pyramidal neurons tend to be "regular-spiking" (RS) 
% and exhibit broader waveforms.
%
% Waveform width is influenced by:
%   1) Intrinsic membrane properties (ion channel kinetics)
%   2) Cell morphology (e.g., pyramidal vs interneuron)
%   3) Distance and orientation relative to the electrode
%
% While electrode geometry contributes variability, population-level
% clustering of waveform features often reveals two groups:
%   - Narrow spikes → putative fast-spiking (FS) interneurons
%   - Broad spikes  → putative regular-spiking (RS) pyramidal neurons
%
% Here we examine several waveform features commonly used to 
% classify cell types:
%
%   PtTratio  : peak-to-trough amplitude ratio
%   PtTdist   : peak-to-trough time (waveform width)
%   slope     : repolarization slope (rate of voltage change)
%
% Peak-to-trough distance is especially important:
%   FS cells → short peak-to-trough duration (narrow spikes)
%   RS cells → longer peak-to-trough duration (broad spikes)


% First, access these variables from the waveformStruct that we made
    PtTratio_all    = [waveformStruct.PtTratio];
    PtTdist_all     = [waveformStruct.PtTdist];
    slope_all       = [waveformStruct.slope];


figure;
    subplot(1,2,1)
        scatter(PtTratio_all, PtTdist_all*1000, 10,'filled')
        ylabel('peak to trough dist (ms)')
        ylim([0 1])
        xlabel('peak to trough ratio')
   subplot(1,2,2)
        scatter(PtTratio_all, slope_all*1000, 10, 'filled')
        ylabel('slope')
        xlabel('peak to trough ratio')

% Figure interpretation:
% In both plots, you can see that there are two rough clusters of data. 
% Narrow-spiking (putative FS) neurons tend to cluster at lower 
% peak-to-trough distances (~0.2–0.4 ms). Broad-spiking (putative RS) 
% neurons typically appear above ~0.4–0.5 ms. 
% Moreover, fast-spiking neurons typically show steeper repolarization 
% slopes, reflecting rapid membrane kinetics whereas regular-spiking 
% neurons exhibit slower repolarization.


% Important disclaimer:
% FS ≠ all interneurons (SST and VIP are not always narrow). And some 
% pyramidal neurons can have relatively narrow spikes. Therefore, 
% classification is probabilistic, not absolute.



%% Next, let's organize spike times into stimulus-relevant times to look at stimulus-evoked activity

 
% Load stimulus "on" timestamps

    % I have already synced these stimulus on timestamps to the neural signal
    % using CatGT and TPrime. For the purposes of this tutorial, you will not
    % practice syncing yourself, you will just load the already synced files.

    stimStruct = createStimStruct_tutorial(exptStruct);
    
    % Again, I recommend reading through the above function as an example of 
    % one way to extract relevant stimulus information from the MWorks behavior 
    % file.



% Sort spike times into trials and bins

    b = 1; % What stimulus presentation block to use for RandDirFourPhase analysis?
    % Because I only did one experimental run, I will put 1 here. If the 16dir
    % run was the second of 2 runs, I would put b=2.
    
    [trialStruct, gratingRespMatrix, gratingRespOFFMatrix, resp, base] = createTrialStruct_16dir_tutorial(stimStruct, goodUnitStruct, b);     
    % Outputs
    %   - gratingRespMatrix (cell array), size [nUnits x nDirections], each element contains a cell array of spike times for each trial
    %   - gratingOFFRespMatrix (cell array),  size [nUnits x nDirections], each element is the 0.2s preceding each trial (what I am calling the "baseline" period)
    %   - resp (cell array), size [nUnits x nDirs], each element is then nTrials x Time (in bins of 10 ms)
    %   - base (cell array), size [nUnits x nDirs], same as resp but the baseline period



%% Now that we have trial information, we can get average spiking responses in response to each unique trial and identify cells that are significantly visually responsive.


nCells = size(resp,1);
nDirs = size(resp,2);
nTimeBins = 200; % Stimulus duration in 10 ms bin size -- i.e., 2s / 10ms

resp_cell = cellfun(@(x) x, resp, 'UniformOutput', false); % Response period (0ms - 2s)
base_cell = cellfun(@(x) x, base, 'UniformOutput', false); % Baseline period (-200ms - 0s)

% Convert cell arrays to padded numeric arrays for computations
maxTrials = max(cellfun(@(x) size(x,1), resp_cell(:))); % Find max trial count across conditions

resp_numeric = nan(nCells, nDirs, maxTrials, nTimeBins);
base_numeric = nan(nCells, nDirs, maxTrials, 20);

for ic = 1:nCells
    for id = 1:nDirs
        if ~isempty(resp_cell{ic,id})
            nTrials = size(resp_cell{ic,id},1);
            resp_numeric(ic,id,1:nTrials,:) = resp_cell{ic,id}; % Assign data
        end
        if ~isempty(base_cell{ic,id})
            nTrials = size(base_cell{ic,id},1);
            base_numeric(ic,id,1:nTrials,:) = base_cell{ic,id};
        end
    end
end

% Compute mean and SEM (ignoring NaNs due to different trial counts)
avg_resp_dir(:,:,1) = mean(sum(resp_numeric,4)/2,3,'omitnan'); % Avg across time & trials to get rate in Hz (scalar bc trial is 2s not 1s)
avg_resp_dir(:,:,2) = std(sum(resp_numeric,4)*0.2,0,3,'omitnan') ./ sqrt(size(resp_numeric,3)); % SEM

resp_dir_tc = mean(resp_numeric,3,'omitnan'); % Avg across trials, for time-course
resp_dir_tr = mean(resp_numeric,4,'omitnan'); % Avg across time, for trials

% Find significantly responsive cells
resp_cell_trials = sum(resp_numeric,4) / 200; % convert to spike rate per trial (Hz). Remember, 10 ms bin for 2s stimulus duration
base_cell_trials = sum(base_numeric,4) / 20; % convert to Hz

h_resp = nan(nCells, nDirs);
p_resp = nan(nCells, nDirs);

for id = 1:nDirs
    [h_resp(:,id), p_resp(:,id)] = ttest2(...
        squeeze(resp_cell_trials(:,id,:)),...
        squeeze(base_cell_trials(:,id,:)),...
        'dim', 2, 'tail','right', 'alpha', 0.05./(nDirs));
end

% Make an index of cells significantly responsive to gratings
resp_ind_dir = find(sum(h_resp(:,:),2)); 





%% First, let's look at the subpopulation of visually responsive cells as a function of their average firing rate and depth.

figure;
subplot 221
    depth_all   = exptStruct.depth + [goodUnitStruct.depth];
    depth_resp  = exptStruct.depth + [goodUnitStruct(resp_ind_dir).depth];
    FR_all      = [goodUnitStruct.FR];
    FR_resp   = [goodUnitStruct(resp_ind_dir).FR];
    scatter(FR_all, depth_all, 15, 'filled')
    hold on
    scatter(FR_resp, depth_resp, 15, 'filled')
    xlabel('avg FR'); xlim([-5 50])
    ylabel('depth (um)'); ylim([-5000 0])
    movegui('center')
    sgtitle([exptStruct.mouse ' ' exptStruct.date ', FR by depth'])


% Here, 0 um is the putative surface of the brain (where I zeroed my
% electrode before descent).
%
% We expect visual cortex to be found about 200-1200 in depth. There is a gap of
% ~200 um between the tip of the electrode and where the recording channels
% start.
%
% This visualization very clearly shows visually responsive cells in V1, a
% small gap, then a few more visually responsive cells in hippocampus.
%



%% Plot grating rasters for example neurons

% Let's first plot a grating raster for one cell at one of the 16
% directions.

ic = 110; % example cell
dirIdx = 5; % example direction
depth = exptStruct.depth + goodUnitStruct(ic).depth;

% Get spike times for the specified unit and direction
baselineSpikeTimes  = gratingRespOFFMatrix{ic, dirIdx}; % Spikes in baseline
trialsSpikeTimes    = gratingRespMatrix{ic, dirIdx};    % Spikes in stimulus
    

figure;
    % Loop over each trial and plot the spikes
    for trialIdx = 1:length(trialsSpikeTimes)
        % Get spike times for this trial
        spikeTimes     = trialsSpikeTimes{trialIdx};  % 0 to 1s
        baselineTimes  = baselineSpikeTimes{trialIdx}; % -0.2 to 0s
        
        % Y-axis position for this trial
        yPosition = trialIdx; 
        
        % Plot **baseline spikes** (should already be between -0.5 and 0s)
        plot(baselineTimes, yPosition * ones(size(baselineTimes)), 'k.', 'MarkerSize', 5); hold on
        
        % Plot **stimulus-related spikes** (stimulus duration--0 to 1s)
        plot(spikeTimes, yPosition * ones(size(spikeTimes)), 'k.', 'MarkerSize', 5);
    end
    
    xlabel('Time (s)');
    ylabel('Trial Number');
    title(['direction ' num2str(dirIdx)]);
    ylim([0 length(trialsSpikeTimes) + 1]);
    xlim([-.2 2]); % Shows baseline (-.2 to 0s) and stimulus (0 to 1s)
    
    % Plot stimulus onset line at **0s**
    xline(0, 'r', 'LineWidth', 2); 




% Next, we turn this plotting script into a function, then loop through
% directions to see rasters for a given cell in response to all 16
% directions.

for ic = [110 118 138 136 131]  % These are example cells I handpicked to demonstrate orientation selectivity, direction selectivity, and different F1/F0s
    depth = exptStruct.depth + goodUnitStruct(ic).depth;
    figure;
        for i=1:nDirs
            subplot(6,3,i)
                plotRaster_tutorial(gratingRespMatrix, gratingRespOFFMatrix, ic,i)        
        end
    sgtitle(['unit '  num2str(ic) ', depth=' num2str(depth)])
    movegui('center')
end


% You might notice some oscillation in the example neuron's firing rate
% across the stimulus on duration (2s). This is what we call the "F1" of
% the response--neurons are driven more strongly and/or suppressed as the
% grating drifts across the receptive field.
% I presented drifting gratings at 1hz for 2 seconds, so you see 2 cycles
% of the F1 modulation in the rasters.


%% Calculating the F1/F0

% Let's calculate the F0, F1, and F1/F0 for an example cell, 131, at
% direction 9.

% Hard code some variables
T_stim      = 2;           % stimulus duration (s)
stimFreq    = 1;          % Hz
binSize     = 0.01;       % 10 ms bins
edges       = 0:binSize:T_stim;
Fs          = 1/binSize;        % sampling frequency (Hz)
nBins       = numel(edges)-1;    % number of bins

% Compute F0, F1
ic = 131;  % example cell
id = 9;    % example direction

% Retrieve cell array of spike trains for this unit & direction
trials = gratingRespMatrix{ic, id};
nTrials = numel(trials);

psthCounts = zeros(1, nBins);   % Accumulate PSTH

for t = 1:nTrials
    spikes = trials{t};
    counts = histcounts(spikes, edges);
    psthCounts = psthCounts + counts;
end
 
psthCounts = psthCounts / nTrials;  % Average across trials
psthRate = psthCounts / binSize;    % Convert to firing rate (spikes/s)

F0 = mean(psthRate);    % Compute F0
fftVals = fft(psthRate) / nBins; % FFT
f = (0:nBins-1)*(Fs/nBins);

% Compute F1 amplitude
[~, idx] = min(abs(f - stimFreq));   % Find index closest to 2 Hz
F1 = 2 * abs(fftVals(idx));   % factor 2 for single-sided amplitude (essentially, double so you account for the true amplitude of the sinewave)

% Save results
f0mat       = F0;
f1mat       = F1;
f1overf0mat = F1 / F0;


% Compare this to the f1/f0 of one direction of example cell 136, which
% visually has much less F1 modulation.


%% Calculate the F1/F0 for the population

% Here is the same analysis, coded as a function now.
[f0mat, f1mat, f1overf0mat] = getF1_tutorial(gratingRespMatrix);
% Outputs
%   - f0mat (matrix), size [nUnits x nDirs]
%   - f1mat (matrix), size [nUnits x nDirs]
%   - f1overf0mat (matrix), size [nUnits x nDirs]

% The F1/F0 modulation is normally compared across a population by looking
% at the F1/F0 for the prefferred direction.

% Calculate direction selectivity index and find the prefferred direction
% (DSI_maxInd)

for iCell = 1:nCells
    [max_val max_ind]   = max(avg_resp_dir(iCell,:,1));
    null_ind            = max_ind+(nDirs./2);
    null_ind(find(null_ind>nDirs)) = null_ind(find(null_ind>nDirs))-nDirs;
    min_val     = avg_resp_dir(iCell,null_ind,1,1,1);
    if min_val < 0; min_val = 0; end
    DSI(iCell)          = (max_val-min_val)./(max_val+min_val);
    DSI_maxInd(iCell)   = max_ind; 
end

% Take only the F1/F0 of the preferred direction for all cells.
idx = sub2ind(size(f1overf0mat), (1:size(f1overf0mat,1))', DSI_maxInd(:));
pref_F1F0 = f1overf0mat(idx);

% We can plot the F1/F0 for all cells, but we really only care about the
% F1/F0 for visually responsive cells...
figure;
edges = 0:0.1:2;
    subplot 221
        histogram(pref_F1F0,edges)
        ylabel('nUnits')
        xlabel('F1/F0')
        subtitle('all cells')
    subplot 222
        histogram(pref_F1F0(resp_ind_dir),edges)
        ylabel('nUnits')
        xlabel('F1/F0')
        subtitle('vis resp cells')

% Roughly, this splits into simple and complex cells!