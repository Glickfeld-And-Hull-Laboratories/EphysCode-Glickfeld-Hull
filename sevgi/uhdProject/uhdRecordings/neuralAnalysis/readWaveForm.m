function [waveForms, samplingRate]=readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, startTimeSecs, endTimeSecs)

    globals;
    chMatrix = getChannelMatrix(unit.ch); 
        
    imecMetaFiles = dir([pathToRecFolder '*imec*ap.meta']);
    imecMetaFile = imecMetaFiles(1);    
    imecMeta = readMeta(imecMetaFile.name, pathToRecFolder);

    imecBinFiles = dir([pathToRecFolder '*imec*ap.bin']);
    imecRawBinFile = imecBinFiles(1);
    
    
%     imecBinFiles = dir([pathCatGT_filtered '*tcat.imec*ap.bin']); % filtered.bin % do NOT forget to put its meta file with same name    
%     catGTFilteredBinFile = imecBinFiles(1);

%     imecMetaFiles = dir([pathCatGT '*' KS_FILTERED '.imec*ap.meta']);
%      = imecMetaFiles(1);
%     imecBinFiles = dir([pathCatGT '*' KS_FILTERED '.imec*ap.bin']);
%     ksFilteredBinFile = imecBinFiles(1);
    
    imecMetaFilteredFiles = dir([pathNpyxFiltered '*imec*ap.meta']);
    imecMetaFilteredFile = imecMetaFilteredFiles(1);    
    imecMetaFiltered = readMeta(imecMetaFilteredFile.name, pathNpyxFiltered);

    imecBinFiles = dir([pathNpyxFiltered '*tempfilt*ap.bin']);
    npyxFilteredBinFile = imecBinFiles(1);

    % Parse the corresponding metafile    
    samplingRate = str2double(getMetaFile().imSampRate);
    nSamples = int64(floor((RAW_PRE_SPIKE+RAW_POST_SPIKE)*samplingRate));    
    
    waveForms = cell(CHANNEL_MATRIX_ROWS, CHANNEL_MATRIX_COLUMNS);
    
    % Read waveforms within a pre-defined interval
    if nargin>3 && ~isempty(startTimeSecs) && ~isempty(endTimeSecs)
        spikeTimesWhole = unit.spikeTimesSecs(startTimeSecs<unit.spikeTimesSecs & unit.spikeTimesSecs<endTimeSecs);
    else
        spikeTimesWhole = unit.spikeTimesSecs;
    end

    if ~isempty(spikeTimesWhole)
        startTimesSecLaser = [0 laserOffsetTimes+EXCLUDE_POST_LASER_EFFECT_DUR];
        endTimesSecLaser = [laserOnsetTimes-EXCLUDE_PRE_LASER_EFFECT_DUR Inf];
        limits = [startTimesSecLaser' endTimesSecLaser'];

        spikeTimes = [];        
        for indLaser = 1:size(limits,1)
            idMaster = find(limits(indLaser,1)<spikeTimesWhole & limits(indLaser,2)>spikeTimesWhole);
            if ~isempty(idMaster)
                spikeTimes = [spikeTimes;spikeTimesWhole(idMaster)];
            end
        end

        if ~isempty(spikeTimes)
            nElements = min(length(spikeTimes), RAW_RANDOM_N); % whichever less, take that one
            nRandSpikeTimes = randperm(length(spikeTimes),nElements);
            startSamples = zeros(1,length(nRandSpikeTimes));
            for i=1:length(nRandSpikeTimes)
                % Get 3 ms interval of filtered data around the spike
                startSec = spikeTimes(nRandSpikeTimes(i))-RAW_PRE_SPIKE;
                if startSec<0
                    startSec = 0;
                end
                startSamples(i) = int64(floor(startSec*samplingRate));
            end
            
            for row = 1:CHANNEL_MATRIX_ROWS
                for col = 1:CHANNEL_MATRIX_COLUMNS
                    if chMatrix(row,col)~=UNDEFINED
                        if READ_RAW_OR_FILTERED_SIGNAL % Read from CatGT'd raw data
                            waveForm = readBinWRTDataType(startSamples, nSamples, chMatrix(row,col), imecRawBinFile.bytes, imecRawBinFile.name, pathToRecFolder, SIZE_OF_INT16, 'int16=>double');    
                            waveForm = gainCorrectIM(waveForm, imecMeta);
                        else % Read from filtered data
                            %waveForm = readBinWRTDataType(startSamples, nSamples, chMatrix(row,col), filtFiltedBinFile.bytes, filtFiltedBinFile.name, pathToFilteredRec, SIZE_OF_SINGLE, 'single=>double');
                            waveForm = readBinWRTDataType(startSamples, nSamples, chMatrix(row,col), npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double');
                            waveForm = gainCorrectIM(waveForm, imecMetaFiltered); % No need to gainCorrect cos data filtered through NeuroPyxels
                        end
        
                        waveForms{row, col} = waveForm;
                    end
                end
            end
        end
        
%         if READ_RAW_OR_FILTERED_SIGNAL % Read from CatGT'd raw data
%             dataArrayGCorr = gainCorrectIM(dataArray, chList, imecMeta); % No need to gainCorrect if data filtered through NeuroPyxels
%         end
            
        logger.info('readRawWaveForm', 'Raw waveform is read!');
    else
        logger.info('readRawWaveForm', 'Raw waveform has NO spikes!');
    end
end