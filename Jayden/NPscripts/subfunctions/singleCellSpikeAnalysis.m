% waveform extraction adapted from Marie's SampleWaveformsTimeLimTGzergo.m

function [spikingStruct, waveformStruct] = singleCellSpikeAnalysis(exptStruct, goodUnitStruct, refractoryViolationThresh, num_samples)
    
    base = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\';
    date = exptStruct.date;
    fullDataPath = fullfile(base, date);
    
    % Initialize and extract meta file info for waveform analysis
    dataLengthPreSpike = 0.001;     % This is the data length that is subtracted from the spike time in order to see preceding baseline
    dataLengthTotal = 0.003;     % This is the full data length that is pulled/plotted (x-axis)

    dirContents = dir(fullDataPath);
    runFolders  = {dirContents([dirContents.isdir] & ~ismember({dirContents.name}, {'.', '..'})).name};
    metaMask    = startsWith(runFolders, 'catgt', 'IgnoreCase', false) & ~contains(runFolders, 'ret', 'IgnoreCase', true);   % Logical mask for folders starting with 'catgt' and not containing 'ret'
    metaFolder  = runFolders(metaMask);      % Extract matching folder name(s)
    if numel(metaFolder) ~= 1   % Sanity check that there is exactly one match
        error('Expected exactly 1 matching folder, but found %d.', numel(metaFolder));
    end
    cd(fullfile(fullDataPath,cell2mat(metaFolder)))
    if length(dir('*ap.bin')) ~= 1
        [binName,path] = uigetfile('*ap.bin', 'Select Binary File');    % Ask user for binary file
    end
    if length(dir('*ap.bin')) == 1
      binfolder = dir('*ap.bin');
      binName   = binfolder(1).name;
      path      = binfolder(1).folder;
    end

    nCells = size(goodUnitStruct,2);
    cellIdx = 1:nCells;

    parpool("Threads", 20)   % Start parallel pool processing
    tic
    parfor ic  = cellIdx
        fprintf([ 'cell ' num2str(ic) '\n'])
    % Get cell info
        unitID      = goodUnitStruct(ic).depth;
        timestamps  = goodUnitStruct(ic).timestamps;
        channel     = goodUnitStruct(ic).channel;
        rank        = goodUnitStruct(ic).rank;
    
        if length(timestamps) > 10000
            spikeTimesISI = timestamps(randsample(length(timestamps),10000));
            spikeTimesISI = sort(spikeTimesISI);   % sort into ascending order
        else
            spikeTimesISI = timestamps;
        end

    %
    % ========================================================
    % Get interspike intervals and probabilities
        isi = diff(spikeTimesISI);
        isiEdges = 0:0.001:0.1;  % 1 ms bins from 0 to 100 ms
        [isiCounts, ~] = histcounts(isi, isiEdges);
        isiProb = isiCounts / sum(isiCounts);  % normalize to probability

    %
    % ========================================================
    % Get autocorrelogram and violations
    %
        maxLag  = 0.025;  % +/- 25 ms, for plotting
        binSize = 0.001;  % 1 ms bins, for plotting
        acEdges   = -maxLag:binSize:maxLag;
        lenTimes = 1:length(spikeTimesISI);
        
        % Compute all pairwise time differences
        dt = [];  % to collect all time differences
        for i = lenTimes
            diffs = spikeTimesISI - spikeTimesISI(i);
            diffs(i) = [];  % remove zero lag (self-pair)
            dt = [dt; diffs(abs(diffs) <= maxLag)];
        end
        [acCounts, acEdges] = histcounts(dt, acEdges);  % get bin counts
        acBinCenters = acEdges(1:end-1) + binSize/2;
        refractoryCounts = sum(abs(dt) < refractoryViolationThresh)/2;  % Find refractory period violations. Autocorrelogram double counts, so 

     
    %
    % =======================================================
    % Get sample waveforms
    %
        spikeTimes = timestamps;
            
        meta = ReadMeta_sg(binName, path);     % Parse the corresponding metafile
        chan = channel +1;  
        step = floor(length(timestamps)/num_samples); % How many spikes in each time duration division so some spikes are chosen from each segement
    
        sampRate    = SampRate_sg(meta);
        spikeStart  = (spikeTimes - dataLengthPreSpike);     % This is the data length that is pulled/plotted (x-axis)); % catch the begining of the waveform
        nSamp       = floor(dataLengthTotal * sampRate);
        nSamp       = int64(nSamp);
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
                samp0       = spikeStart(TSindex(i,1))*sampRate;
                samp0       = int64(samp0);
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
        PtTratio                = (waveformMax-waveformBaseline)/abs(waveformMin-waveformBaseline);
        PtTdist                 = (maxIdx-minIdx)/sampRate;

        slopeTime               = floor(0.0005 * sampRate);     % Find slope at 0.5 ms after trough
        x_data                  = (minIdx+slopeTime-1 : minIdx+slopeTime+1); 
        y_data                  = waveformAvg(x_data);
        pfit                    = polyfit(x_data, y_data, 1);   % Linear regression
        slope                   = pfit(1);


        nSpikesUsed = length(spikeTimesISI);
        refViolationPct = refractoryCounts/nSpikesUsed;

        % if refViolationPct >= 0.01
        %     violPairs = [];
        %     for i = 1:length(spikeTimesISI)
        %         diffs = spikeTimesISI - spikeTimesISI(i);
        %         % Find spikes within threshold (exclude self, >0 means later spikes only)
        %         closeIdx = find(diffs > 0 & diffs < refractoryViolationThresh);
        %         if ~isempty(closeIdx)
        %             violPairs = [violPairs; [repmat(i, numel(closeIdx), 1), closeIdx(:)]];
        %         end
        %     end
        %     violTimes = spikeTimesISI(violPairs); % Convert to original spike times
        % 
        %     % violPairs → indices of violating pairs (in spikeTimesISI)
        %     % violTimes → actual timestamps of the two spikes in each violation
        % 
        %     if ~isempty(violTimes) 
        %         nViol = size(violTimes,1);   % number of violation pairs
        %         violWaveforms = zeros(nSamp, nViol, 2);
        %         for v = 1:nViol
        %             for s = 1:2   % two spikes in each pair
        %                 samp0     = (violTimes(v,s) - dataLengthPreSpike) * sampRate;
        %                 samp0     = int64(samp0);
        %                 dataArray = ReadBin_sg(samp0, nSamp, meta, binName, path);
        % 
        %                 if strcmp(meta.typeThis, 'imec')
        %                     dataArray = GainCorrectIM_sg(dataArray, [chan], meta);
        %                 else
        %                     dataArray = GainCorrectNI_sg(dataArray, [chan], meta);
        %                 end
        % 
        %                 violWaveforms(:,v,s) = dataArray(chan,:);
        %             end
        %         end
        %     else
        %         violWaveforms = [];
        %     end
        % end
        % 

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
end










