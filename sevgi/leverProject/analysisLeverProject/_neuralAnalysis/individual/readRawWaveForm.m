function [waveFormMean, waveFormMin, waveFormMax, samplingRate]=readRawWaveForm(unit)

    globals;
    
    imecBinFiles = dir([pathNpyxFiltered '*imec*300*ap.bin']); % do NOT forget to put its meta file with same name
    npyxFilteredFile = imecBinFiles(1);

    % Parse the corresponding metafile
    %imecBinFiles = dir([pathNpyxOrgDataFolder '*imec*ap.bin']);
    %imecBinFile = imecBinFiles(1);
    imecMeta = readMeta(npyxFilteredFile.name, pathNpyxFiltered); %(imecBinFile.name, pathNpyxOrgDataFolder);
    samplingRate = str2double(imecMeta.imSampRate);
    nSamples = int64(floor((RAW_PRE_SPIKE+RAW_POST_SPIKE)*samplingRate));
    %waveForms = zeros(length(unit.spikeTimesSecs),nSamples);
    nElements = min(length(unit.spikeTimesSecs), RAW_RANDOM_N); % whichever less, take that one
    nRandSpikeTimes = randperm(length(unit.spikeTimesSecs),nElements);
    startSamples = zeros(1,length(nRandSpikeTimes));
    for i=1:length(nRandSpikeTimes)
        % Get 3 ms interval of filtered data around the spike
        startSec = unit.spikeTimesSecs(nRandSpikeTimes(i))-RAW_PRE_SPIKE;
        if startSec<0
            startSec = 0;
        end
        startSamples(i) = int64(floor(startSec*samplingRate));
    end

    waveForms = readBin(startSamples, nSamples, unit.ch, imecMeta, npyxFilteredFile.name, pathNpyxFiltered);    
    %dataArrayGCorr = gainCorrectIM(dataArray, chList, imecMeta); % No need to gainCorrect cos data filtered through NeuroPyxels
    
    waveFormMean = mean(waveForms,1);
    waveFormMin = waveFormMean-std(waveForms,1);
    waveFormMax = waveFormMean+std(waveForms,1);
    logger.info('readRawWaveForm', 'Raw waveform is read!');
end