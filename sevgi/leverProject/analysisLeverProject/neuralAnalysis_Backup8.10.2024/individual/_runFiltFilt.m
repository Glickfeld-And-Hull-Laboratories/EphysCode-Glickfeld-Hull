%function [waveFormMean, waveFormMin, waveFormMax, samplingRate]=readRawWaveForm(unit)

    globals;
    
    pathToFilteredRec = ['/mnt/IsilonPerm/Neuropixels/uhd_recordings/20230126_g0/filtered/'];
    
    imecBinFiles = dir([pathToFilteredRec '*imec*ap.bin']); % do NOT forget to put its meta file with same name
    imecBinFile = imecBinFiles(1);

    imecMeta = readMeta(imecBinFile.name, pathToFilteredRec); %(imecBinFile.name, pathNpyxOrgDataFolder);
    samplingRate = str2double(imecMeta.imSampRate);
    nSamples = int64(floor((20)*samplingRate));
    %waveForms = zeros(length(unit.spikeTimesSecs),nSamples);
%     nElements = min(length(unit.spikeTimesSecs), RAW_RANDOM_N); % whichever less, take that one
%     nRandSpikeTimes = randperm(length(unit.spikeTimesSecs),nElements);
     startSamples = zeros(1,1000); %length(nRandSpikeTimes));
%     for i=1:length(nRandSpikeTimes)
%         % Get 3 ms interval of filtered data around the spike
%         startSec = unit.spikeTimesSecs(nRandSpikeTimes(i))-RAW_PRE_SPIKE;
%         if startSec<0
%             startSec = 0;
%         end
%         startSamples(i) = int64(floor(startSec*samplingRate));
%     end

    dataArray = NaN(length(startSamples),nSamples);
    dataArray = readBin(startSamples, nSamples, 3, imecMeta, imecBinFile.name, pathToFilteredRec);    
    dataArrayGCorr = gainCorrectIM(dataArray, [3], imecMeta); % No need to gainCorrect cos data filtered through NeuroPyxels
    

    rawSignal = dataArrayGCorr(1,:);
    %%% Spikes
    hiPass = 300; % hi pass cutoff
    hi = hiPass*2/samplingRate; % normalized for ADC sampling rate
    [b2,a2] = butter(3,hi,"high");
    filteredCh = filtfilt(b2,a2,rawSignal);
    filteredCh = filteredCh - mean(filteredCh); % filtered sensor signal
     
    t = 0:1/samplingRate:length(rawSignal)/samplingRate-1/samplingRate;
    fig = figure('Name', 'FiltFilt'); %, 'pos',[15 50 1500 700]);
    subplot(2,1,1);
    plot(t,rawSignal);
    title(['Raw data from Tip ch=' num2str(i)]);

    subplot(2,1,2);
    plot(t, filteredCh)
    title(['Spike filtering (300-8K Hz) Ring ch=' num2str(i)]);

    logger.info('readRawWaveForm', 'Raw waveform is read!');
%end