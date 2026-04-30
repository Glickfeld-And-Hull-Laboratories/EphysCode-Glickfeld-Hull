function amplitudes = readAmplitudes(unit, laserOnsetTimes, laserOffsetTimes)

    globals;
    imecMetaFiles = dir([pathNpyxFiltered '*.imec*ap.meta']);
    imecMetaFile = imecMetaFiles(1);
    imecBinFiles = dir([pathToRecFolder '*imec*ap.bin']);
    imecRawBinFile = imecBinFiles(1);
    imecBinFiles = dir([pathNpyxFiltered '*tempfilt*ap.bin']);
    npyxFilteredBinFile = imecBinFiles(1);

     % Parse the corresponding metafile
    imecMeta = readMeta(imecMetaFile.name, imecMetaFile.folder);
    samplingRate = str2double(imecMeta.imSampRate);
    nSamples = int64(floor((RAW_PRE_SPIKE+RAW_POST_SPIKE)*samplingRate)); 

    spikeTimesWhole = unit.spikeTimesSecs;

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

    % Make sure first there is best channel info
    if isempty(unit.ch) % This unit comes from DartSort, you should find the best channel
        
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

        if READ_RAW_OR_FILTERED_SIGNAL % Read from CatGT'd raw data
            [ch, depth] = findBestChannel(startSamples, nSamples, imecRawBinFile.bytes, imecRawBinFile.name, pathToRecFolder, SIZE_OF_INT16, 'int16=>double');
            unit.ch = ch;
            unit.depth = depth;
        else
            [ch, depth] = findBestChannel(startSamples, nSamples, npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double');
            unit.ch = ch;
            unit.depth = depth;
        end
    end
    
    startSamples = spikeTimes-RAW_PRE_SPIKE;
    if READ_RAW_OR_FILTERED_SIGNAL % Read from CatGT'd raw data
        waveForm = readBinWRTDataType(startSamples, nSamples, unit.ch, imecRawBinFile.bytes, imecRawBinFile.name, pathToRecFolder, SIZE_OF_INT16, 'int16=>double');    
    else % Read from CatGT'd filtered data
        %waveForm = readBinWRTDataType(startSamples, nSamples, chMatrix(row,col), filtFiltedBinFile.bytes, filtFiltedBinFile.name, pathToFilteredRec, SIZE_OF_SINGLE, 'single=>double');
        waveForm = readBinWRTDataType(startSamples, nSamples, unit.ch, npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double');
    end
    
    maxs = max(waveForm,[], 2);
    mins = min(waveForm,[], 2);
    absDiff = abs(maxs-mins);
    amplitudes = absDiff;
end