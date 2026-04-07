clear all; close all; clc; clear global;

iexp = 4; % Choose experiment
refractoryViolationThresh   = 0.002;     % 2 ms

%% read data from ks4 and phy2 output

[exptStruct] = iniExptStruct(iexp); % get exptStruct

baseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
fPathBaseIn = fullfile(baseDir, '\jerry\analysis\neuropixel',exptStruct.mouse,exptStruct.date,'kilosort4');
cd(fPathBaseIn);

[cluster_struct,~,~,~,~,~,goodUnitStruct,~,~] = ImportKSdataNew();  % Marie's function to tidy up ks4 and phy2 outputs for further analysis

%% Stimulus info

% Load stimulus "on" timestamps
% I have already synced these stimulus on timestamps to the neural signal
% using CatGT and TPrime. Syncing needs to be done before this step.

stimStruct = NPXcreateStimStruct(exptStruct);

% Again, I recommend reading through the above function as an example of 
% one way to extract relevant stimulus information from the MWorks behavior 
% file.

% Sort spike times into trials and bins

[trialStruct, gratingRespMatrix, gratingRespOFFMatrix, resp, base, uniqueStims] = NPXcreateTrialStruct(stimStruct, goodUnitStruct);     
% Outputs
%   - gratingRespMatrix (cell array), size [nUnits x nDirections], each element contains a cell array of spike times for each trial
%   - gratingOFFRespMatrix (cell array),  size [nUnits x nDirections], each element is the 0.2s preceding each trial (what I am calling the "baseline" period)
%   - resp (cell array), size [nUnits x nStimTypes], each element is then nTrials x Time (in bins of 10 ms)
%   - base (cell array), size [nUnits x nStimTypes], same as resp but the baseline period


%% find neural data metadata

% Initialize and extract meta file info for waveform analysis
fullDataPath    = fullfile(baseDir, exptStruct.loc, 'analysis', 'neuropixel', exptStruct.mouse,exptStruct.date); % Navigate to experiment directory
dirContents     = dir(fullDataPath); % Get names of all files and folders in the experiment directory
runFolders      = {dirContents([dirContents.isdir] & ~ismember({dirContents.name}, {'.', '..'})).name}; % Get the names of all folders in experiment directory
metaMask        = startsWith(runFolders, 'catgt', 'IgnoreCase', false) & ~contains(runFolders, 'ret', 'IgnoreCase', true);   % Logical mask for folders starting with 'catgt' and not containing 'ret'
% ^ Choose catgt folder for the experimental run (not retinotopy run).
% The catgt folder is created as an output of syncing stimulus
% information to neural data.    
metaFolder      = runFolders(metaMask); % Get the name of the folder that matches the above criteria
if length(metaFolder) > 1
    for i = 1:length(metaFolder)
        disp([num2str(i) ': ' metaFolder{i}])
    end
    runChoice = input('Multiple run folders detected, choose the one to analyze: ');
    metaFolder = metaFolder(runChoice); 
end

runFolderName = cell2mat(metaFolder);

% Change currenty directory to the 
cd(fullfile(fullDataPath,runFolderName))

% Find the waveform file
binfolder       = dir('*ap.bin');
binName         = binfolder.name;
path            = binfolder.folder;

%% Sample waveforms from raw data to calculate waveform stats


nCells = size(goodUnitStruct,2);
cellIdx = 1:nCells;
num_samples                 = 2000;       % How many waveforms do you want to sample for the waveform shape analysis?
dataLengthPreSpike          = 0.001;     % This is the data length that is subtracted from the spike time in order to see preceding baseline
dataLengthTotal             = 0.003;     % This is the full data length that is pulled/plotted (x-axis)

parpool("Threads", 20)   % Start parallel pool processing
tic
parfor ic  = cellIdx
    fprintf([ 'cell ' num2str(ic) '\n'])

% Get cell info
    timestamps  = goodUnitStruct(ic).timestamps;
    channel     = goodUnitStruct(ic).channel;
    % rank        = goodUnitStruct(ic).rank;

    spikeTimesForISI = timestamps;

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

    meta = readMeta_npx(binName, path);     % Parse the corresponding metafile
    chan = channel +1;  
    step = floor(length(timestamps)/num_samples); % How many spikes in each time duration division so some spikes are chosen from each segement

    sampRate    = sampRate_npx(meta);
    spikeStart  = (timestamps - dataLengthPreSpike);     % This is the data length that is pulled/plotted (x-axis)); % catch the begining of the waveform
    nSamp       = int64(floor(dataLengthTotal * sampRate)); % number of continuous timestamps used
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
     
    fid = fopen(fullfile(path, binName), 'rb');

    if ~isempty(spikeStart)
        waveforms = zeros(nSamp, length(TSindex));
        for i = 1:length(TSindex)
            samp0       = int64(spikeStart(TSindex(i,1))*sampRate); % sample start (
            SampleTS(i) = spikeStart(TSindex(i,1));
            dataArray   = readBin_TH(fid, samp0, nSamp, meta);
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
timer = toc;
delete(gcp("nocreate"));


%% plot example waveform stats
nCells = length(waveformStruct);
idxCells = nCells-15:3:nCells;  % Index of example cells to plot
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
% Here we examine a couple waveform features commonly used to 
% classify cell types:
%
%   PtTdist   : peak-to-trough time (waveform width)
%   slope     : repolarization slope (rate of voltage change)
%
% Peak-to-trough distance is especially important:
%   FS cells → short peak-to-trough duration (narrow spikes)
%   RS cells → longer peak-to-trough duration (broad spikes)


% Access these variables from the waveformStruct that we made
    PtTdist_all     = [waveformStruct.PtTdist];
    slope_all       = [waveformStruct.slope];

figure;
    scatter(PtTdist_all*1000, slope_all*1000, 10, 'm', 'filled')
    xlabel('peak to trough dist (ms)')
    ylabel('slope at 0.5ms')
    sgtitle('Identifying fast-spiking v. regular-spiking neurons')
    set(gca,'TickDir','out');
    movegui('center')
    

% Figure interpretation:
% In this plot, you can see that there are roughly two clusters of data. 
% Narrow-spiking (putative FS) neurons tend to cluster at lower 
% peak-to-trough distances (~0.2–0.4 ms). Broad-spiking (putative RS) 
% neurons typically appear above ~0.4–0.5 ms. 
% Moreover, FS neurons typically show steeper repolarization slopes, 
% reflecting rapid membrane kinetics whereas RS neurons exhibit slower 
% repolarization. So at 0.5ms after the initial trough, FS cells are often 
% already repolarizing (negative slope), whereas RS cells are are still 
% depolarizing (positive slope).


% Next, we see how well the units are sorted by looking at the refractory
% period violations.

    refViolations_all = [spikingStruct.refViolations];
    nSpikesUsed_all = [spikingStruct.nSpikesUsed];

    refFrac = refViolations_all ./ nSpikesUsed_all * 100;  % fraction of refractory period violations

    floorVal = 1e-5; % corresponds to 0.001% in percent units
    refFrac(refFrac == 0) = floorVal;
    edges = logspace(log10(floorVal), 1, 40);   % Log-spaced bins for histogram (fraction units) from 0.001% to 100%

figure; hold on
    subplot(2,1,1)
        histogram(refFrac, edges, 'FaceColor',[0.5 0.5 0.5], 'EdgeColor','none');
        set(gca, 'XScale', 'log','tickdir','out');
        xlim([floorVal, 10]); % up to 10 (1000%) or adjust if needed
        xlabel('Refractory period violations (%)');
        ylabel('Number of units');
        meanVal = mean(refFrac);
        xline(meanVal, '--k', sprintf('Mean = %.2f%%', meanVal), 'LabelOrientation','horizontal');
        xline(1, '--r', '1% Threshold', 'LabelOrientation','horizontal');
        xticks([floorVal, 1e-2, 1e-1, 1, 10]);
        xticklabels({'0.001', '0.01', '0.1', '1', '10'});
        refFracInc = length(find(refFrac<1));
        subtitle(['All cells. ' num2str(refFracInc) '/' num2str(length(refFrac)) ' < 1%'])
    sgtitle('Refractory period violations')

%% find visually responsive cells
nCells = size(resp,1);
nStimTypes = size(resp,2);
nTimeBins = 10; % Stimulus duration in 10 ms bin size -- i.e., 100ms / 10ms

resp_cell = cellfun(@(x) x, resp, 'UniformOutput', false); % Response period (0ms - 100ms)
base_cell = cellfun(@(x) x, base, 'UniformOutput', false); % Baseline period (-100ms - 0ms)

% Convert cell arrays to padded numeric arrays for computations
maxTrials = max(cellfun(@(x) size(x,1), resp_cell(:))); % Find max trial count across conditions

resp_numeric = nan(nCells, nStimTypes, maxTrials, nTimeBins);
base_numeric = nan(nCells, nStimTypes, maxTrials, nTimeBins);

for ic = 1:nCells
    for id = 1:nStimTypes
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
avg_resp_stim(:,:,1) = mean(sum(resp_numeric,4)/0.1,3,'omitnan'); % Avg across time & trials to get rate in Hz (scalar bc trial is 2s not 1s)
avg_resp_stim(:,:,2) = std(sum(resp_numeric,4)*0.2,0,3,'omitnan') ./ sqrt(size(resp_numeric,3)); % SEM

resp_stim_tc = squeeze(mean(resp_numeric,3,'omitnan')); % Avg across trials, for time-course
resp_stim_tr = mean(resp_numeric,4,'omitnan'); % Avg across time, for trials

% Find significantly responsive cells
resp_cell_trials = sum(resp_numeric,4) / 0.1; % convert to spike rate per trial (Hz). Remember, 10 ms bin for 100ms stimulus duration
base_cell_trials = sum(base_numeric,4) / 0.1; % convert to Hz

h_resp = nan(nCells, nStimTypes);
p_resp = nan(nCells, nStimTypes);

for id = 1:nStimTypes
    [h_resp(:,id), p_resp(:,id)] = ttest2(...
        squeeze(resp_cell_trials(:,id,:)),...
        squeeze(base_cell_trials(:,id,:)),...
        'dim', 2, 'tail','right', 'alpha', 0.05./(nStimTypes));
end

% Make an index of cells significantly responsive to gratings
resp_ind_dir = find(sum(h_resp(:,:),2)); 


%% Extract waveform during stimon
% loop through every trial to find the cells' waveforms during only stim on

nTrials = length(trialStruct);
cort_cells_ind = find([goodUnitStruct.depth] >= 1200);
resp_cort_ind = intersect(resp_ind_dir,cort_cells_ind);
wfAllTrialsCells = cell(1,length(resp_cort_ind));
meta = readMeta_npx(binName, path); 

dataLengthPreSpike          = 0.001;     % This is the data length that is subtracted from the spike time in order to see preceding baseline
dataLengthTotal             = 0.003;     % This is the full data length that is pulled/plotted (x-axis)
sampRate = sampRate_npx(meta);
timestep = 1/sampRate;
nSamp = dataLengthTotal * sampRate;
onsets = [trialStruct.onset];
offsets = [trialStruct.offset];

tic
parpool("Threads", 20)   % Start parallel pool processing
for ic = 1:length(resp_cort_ind)
    thisCellind = resp_cort_ind(ic);
    fprintf(['\nCell ' num2str(thisCellind) '\n']);
    channel = goodUnitStruct(thisCellind).channel + 1;
    % find sample timing samp0 and sample
    thisCellTS = goodUnitStruct(thisCellind).timestamps;
    % The actual timestamps ('thisCellTS') determines whether a
    % spike is to be pulled
    trialWaveforms = cell(1,nTrials);
    for iTrial = 1:nTrials
        thisTrialSpikes = thisCellTS(thisCellTS > onsets(iTrial) & thisCellTS < offsets(iTrial));
        if ~isempty(thisTrialSpikes)
            spkStartTS_thisTrial = thisTrialSpikes - dataLengthPreSpike;
            waveforms = zeros(nSamp, length(spkStartTS_thisTrial));
            nSpikesThisTrial = length(spkStartTS_thisTrial);
            fid = fopen(fullfile(path, binName), 'rb');
            for i = 1:nSpikesThisTrial
                samp0       = int64(spkStartTS_thisTrial(i)*sampRate); 
                dataArray   = readBin_TH(fid, samp0, nSamp, meta);
                % change y values to volts
                % For an analog channel: gain correct saved channel ch (1-based for MATLAB).
                ch = channel;
                % For a digital channel: read this digital word dw in the saved file
                % (1-based). For imec data there is never more than one saved digital word.
                dw = 1;
                
                if strcmp(meta.typeThis, 'imec')
                    dataArray = GainCorrectIM_sg(dataArray, [ch], meta);
                else
                    dataArray = GainCorrectNI_sg(dataArray, [ch], meta);
                end
                waveforms(:,i) = dataArray(channel,:);
            end
            trialWaveforms{iTrial} = waveforms;
        end
    end
    wfAllTrialsCells{ic} = trialWaveforms;
end

testTimer = toc;
delete(gcp("nocreate"));