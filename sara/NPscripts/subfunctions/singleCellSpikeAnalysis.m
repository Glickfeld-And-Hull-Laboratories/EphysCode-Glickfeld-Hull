

function [spikingStruct, waveformStruct] = singleCellSpikeAnalysis(ic, goodUnitStruct);


% Get cell info
    unitID      = goodUnitStruct(ic).depth;
    timestamps  = goodUnitStruct(ic).timestamps;
    channel     = goodUnitStruct(ic).channel;
    rank        = goodUnitStruct(ic).rank;

    if length(timestamps) > 10000
        spikeTimes = timestamps(randsample(length(timestamps),10000));
        spikeTimes = sort(spikeTimes);   % sort into ascending order
    else
        spikeTimes = timestamps;
    end

% Get interspike intervals and probabilities
    isi = diff(spikeTimes);
    isiEdges = 0:0.001:0.1;  % 1 ms bins from 0 to 100 ms
    [isiCounts, ~] = histcounts(isi, isiEdges);
    isiProb = isiCounts / sum(isiCounts);  % normalize to probability

% Get autocorrelogram and violations
    maxLag  = 0.025;  % +/- 25 ms, for plotting
    binSize = 0.001;  % 1 ms bins, for plotting
    acEdges   = -maxLag:binSize:maxLag;
    lenTimes = 1:length(spikeTimes);
    
    % Compute all pairwise time differences
    dt = [];  % to collect all time differences
    for i = lenTimes
        diffs = spikeTimes - spikeTimes(i);
        diffs(i) = [];  % remove zero lag (self-pair)
        dt = [dt; diffs(abs(diffs) <= maxLag)];
    end
    
    [acCounts, acEdges] = histcounts(dt, acEdges);  % get bin counts
    acBinCenters = acEdges(1:end-1) + binSize/2;
    refractoryViolationThresh = 0.002;  % 2 ms
    refractoryCounts = sum(acCounts(acBinCenters > 0 & acBinCenters < refractoryViolationThresh));  % Find refractory period violations, threshold = 2 ms
    





% Get sample waveforms
    dataLength = 0.006;     % ???
    n = 100;

    if length(dir('*ap.bin')) ~= 1
        [binName,path] = uigetfile('*ap.bin', 'Select Binary File');    % Ask user for binary file
    end
    if length(dir('*ap.bin')) == 1
      binfolder = dir('*ap.bin');
      binName = binfolder(1).name;
      path = binfolder(1).folder;
    end
        
    meta = ReadMeta(binName, path);     % Parse the corresponding metafile
    chan = channel +1;  
    step = floor(length(timestamps)/n); %How many spikes in each time duration division so some spikes are chosen from each segement

    spikeStart = (spikeTimes - .001); % catch the begining of the waveform
    nSamp = floor(dataLength * SampRate(meta));
    nSamp = int64(nSamp);
    timestep = 1/SampRate(meta);
    time = 0:timestep:dataLength-1/SampRate(meta);
    SampleTS = zeros(n,1);


    % Get first one second of data = 1
    if step > 0
        fprintf('\nStep size is %i, %i waveforms plotted and averaged\n', step, n);
    for i = 1:n
      randn(i,1) = randi([(((i-1)*step)+1),(i*step)]); %pick which spike from each 
    end
    TSindex = randn;
    end
    
    if step == 0
        TSindex = [1:length(spikeStart)].';
        if ~isempty(spikeStart)
        %warning('\n Not enough spikes to compute average. All available spikes are used')
        fprintf('\nNot enough spikes to perform planned calculation. %i spikes are averaged and plotted\n', length(timestamps))
        %f = warndlg('Not enough spikes available perform planned mean WF calculation. Available spikes are averaged and plotted');
        end
    end
    
    if ~isempty(spikeStart)
        Waveforms = zeros(nSamp, length(TSindex));
    for i = 1:length(TSindex)
    samp0 = spikeStart(TSindex(i,1))*SampRate(meta);
    samp0 = int64(samp0);
    SampleTS(i) = spikeStart(TSindex(i,1));
    dataArray = ReadBin(samp0, nSamp, meta, binName, path);
    % % % change y values to volts
    % For an analog channel: gain correct saved channel ch (1-based for MATLAB).
    ch = chan;
    
    % For a digital channel: read this digital word dw in the saved file
    % (1-based). For imec data there is never more than one saved digital word.
    dw = 1;
    
        if strcmp(meta.typeThis, 'imec')
            dataArray = GainCorrectIM(dataArray, [ch], meta);
        else
            dataArray = GainCorrectNI(dataArray, [ch], meta);
        end
      % % % 
      
    Waveforms(:,i) = dataArray(chan,:);
    end
    else
    fprintf('\nNo spikes in window. Avg WF = 0.\n')
    %f = warndlg('No spikes in WF mean calculation window. AvgWF = 0');
    end









% Save output into structures
    spikingStruct.isiProb       = isiProb;
    spikingStruct.isiEdges      = isiEdges;
    spikingStruct.acCounts      = acCounts;
    spikingStruct.acBins        = acBinCenters;
    spikingStruct.refViolations = refractoryCounts;


end







% Plot
figure;
    subplot 221
        bar(isiEdges(1:end-1), isiProb, 'histc'); hold on
        xlabel('interspike interval (s)');
        ylabel('probability');
        title('interspike interval probabilities');
        xlim([0 0.1]);  % adjust based on your data
    subplot 222
        bar(acBinCenters, acCounts, 'hist'); hold on
        xline(refractoryViolationThresh)
        xline(-refractoryViolationThresh)
        xlabel('time from spike');
        ylabel('count');
        title('autocorrelogram, no binning');
        xlim([-maxLag, maxLag]);
    sgtitle(['cell ' num2str(ic) ', ' num2str(refractoryCounts) '/' num2str(length(timestamps)) ' spike violations'])
















