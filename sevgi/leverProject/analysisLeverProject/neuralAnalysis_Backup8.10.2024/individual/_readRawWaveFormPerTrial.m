function [waveFormMean, waveFormMin, waveFormMax, samplingRate]=readRawWaveFormPerTrial(spikeTimesPerTrial, channel)
    globals;
    
    imecBinFiles = dir([pathNpyxFiltered '*imec*300*ap.bin']); % do NOT forget to put its meta file with same name
    npyxFilteredFile = imecBinFiles(1);

    % Parse the corresponding metafile
    imecMeta = readMeta(npyxFilteredFile.name, pathNpyxFiltered); % don't forget to put meta file into the NeuroPyxels folder with same name
    samplingRate = str2double(imecMeta.imSampRate);
    nSamples = int64(floor((RAW_PRE_SPIKE+RAW_POST_SPIKE)*samplingRate));
    
    startSamples = [];
    for indTrial=1:length(spikeTimesPerTrial)
        spikeTimes = cell2mat(spikeTimesPerTrial(indTrial))';
        if ~isempty(spikeTimes)
            nElements = min(length(spikeTimes), RAW_RANDOM_PER_TRIAL_N); % whichever less, take that one
            nRandSpikeTimes = randperm(length(spikeTimes),nElements);
            startSec = spikeTimes(nRandSpikeTimes)-RAW_PRE_SPIKE; % Start 1 ms before the spike time, to get the full waveform
            startSec(startSamples<0) = 0;
            startSamples = [startSamples int64(floor(startSec*samplingRate))];
        end
    end

    waveForms = readBin(startSamples, nSamples, channel, imecMeta, npyxFilteredFile.name, pathNpyxFiltered);    
    %dataArrayGCorr = gainCorrectIM(dataArray, chList, imecMeta); % No need to gainCorrect cos data filtered through NeuroPyxels
    
    waveFormMean = mean(waveForms,1);
    waveFormMin = waveFormMean-std(waveForms,1);
    waveFormMax = waveFormMean+std(waveForms,1);
end