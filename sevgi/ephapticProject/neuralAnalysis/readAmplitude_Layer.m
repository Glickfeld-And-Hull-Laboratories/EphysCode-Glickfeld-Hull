function [unitGood, needToSave] = readAmplitude_Layer(unitGood) %, laserOnsetTimes, laserOffsetTimes)

    globals; 

    needToSave = 0;

    imecMetaFiles = dir([pathNpyxFiltered '*.imec*ap.meta']);
    if isempty(imecMetaFiles)
        imecMetaFiles = dir([pathToRecFolder '*.imec*ap.meta']);
    end

    imecMetaFile = imecMetaFiles(1);
%     imecBinFiles = dir([pathToRecFolder '*imec*ap.bin']);
%     imecRawBinFile = imecBinFiles(1);
    imecBinFiles = dir([pathNpyxFiltered '*tempfilt*ap.bin']);
    npyxFilteredBinFile = imecBinFiles(1);

    % Parse the corresponding metafile
    imecMeta = readMeta(imecMetaFile.name, imecMetaFile.folder);
    samplingRate = str2double(imecMeta.imSampRate);
    nSamples = int64(floor((RAW_PRE_SPIKE+RAW_POST_SPIKE)*samplingRate));

    for uid=1:length(unitGood)
        unit = unitGood(uid);
        spikeTimesWhole = unit.spikeTimesSecs;
        if ~isempty(spikeTimesWhole)
            nElements = min(length(spikeTimesWhole), RAW_RANDOM_N); % whichever less, take that one
            nRandSpikeTimes = randperm(length(spikeTimesWhole),nElements);
            startSamples = zeros(1,length(nRandSpikeTimes));
            spikeTimesOfRand = spikeTimesWhole(nRandSpikeTimes);
            for i=1:length(nRandSpikeTimes)
                % Get 3 ms interval of filtered data around the spike
                startSec = spikeTimesOfRand(i)-RAW_PRE_SPIKE;
                if startSec<0
                    startSec = 0;
                end
                startSamples(i) = int64(floor(startSec*samplingRate));
            end                
        
            if READ_RAW_OR_FILTERED_SIGNAL % Read from CatGT'd raw data
                if ~isfield(unitGood(uid),'amplitudePerChannel') || isempty(unitGood(uid).amplitudePerChannel)
                    [ch, depth, amplitudes, amplitudePerChannel] = findBestChannel_Amplitudes(startSamples, nSamples, imecRawBinFile.bytes, imecRawBinFile.name, pathToRecFolder, SIZE_OF_INT16, 'int16=>double', imecMeta);
                    if ch~=unitGood(uid).ch
                        logger.info('readAmplitude_Layer', ['Channel info for unit=' num2str(unit.id) ' in Raw data ch=' num2str(ch) ' is different than Kilosort ch with biggest amplitude =' num2str(unitGood(uid).ch)]);
                    end
    
                    unitGood(uid).amplitudePerChannel = amplitudePerChannel;
                    unitGood(uid).amplitudes = amplitudes;
                    needToSave = 1;
                end
            else
                if ~isfield(unitGood(uid),'amplitudePerChannel') || isempty(unitGood(uid).amplitudePerChannel)
                    [ch, depth, amplitudes, amplitudePerChannel] = findBestChannel_Amplitudes(startSamples, nSamples, npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double', imecMeta);
                    if ch~=unitGood(uid).ch
                        logger.info('readAmplitude_Layer', ['Channel info for unit=' num2str(unit.id) ' in Raw data ch=' num2str(ch) ' is different than Kilosort ch with biggest amplitude =' num2str(unitGood(uid).ch)]);
                    end                    
                    unitGood(uid).amplitudePerChannel = amplitudePerChannel;
                    unitGood(uid).amplitudes = amplitudes;
                    needToSave = 1;
                end
            end
        end        
    end
end
        