function [unitGood, needToSave] = readAmplitude_Layer(unitGood, laserOnsetTimes, laserOffsetTimes)

    globals; 

    needToSave = 0;

    imecMetaFiles = dir([pathNpyxFiltered '*.imec*ap.meta']);
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
        if DART_SORTED && isempty(unit.amplitudes) % This unit comes from DartSort, you should find the best channel
            spikeTimesWhole = unit.spikeTimesSecs;
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
        
                nElements = min(length(spikeTimes), RAW_RANDOM_N); % whichever less, take that one
                nRandSpikeTimes = randperm(length(spikeTimes),nElements);
                startSamples = zeros(1,length(nRandSpikeTimes));
                spikeTimesOfRand = spikeTimes(nRandSpikeTimes);
                for i=1:length(nRandSpikeTimes)
                    % Get 3 ms interval of filtered data around the spike
                    startSec = spikeTimesOfRand(i)-RAW_PRE_SPIKE;
                    if startSec<0
                        startSec = 0;
                    end
                    startSamples(i) = int64(floor(startSec*samplingRate));
                end                
            
                if READ_RAW_OR_FILTERED_SIGNAL % Read from CatGT'd raw data
                    [ch, depth, amplitudes, amplitudePerChannel] = findBestChannel_Amplitudes(startSamples, nSamples, imecRawBinFile.bytes, imecRawBinFile.name, pathToRecFolder, SIZE_OF_INT16, 'int16=>double', imecMeta);
                    if ch~=unitGood(uid).ch
                        logger.info('readAmplitude_Layer', ['Channel info for unit=' num2str(unit.id) ' in Kilosort with biggest amplitude ch=' num2str(ch) ' is different than DartSort ch=' num2str(unitGood(uid).ch)]);
                    end

                    if ~isempty(amplitudes)
                        needToSave = 1;
                    end
                    unitGood(uid).ch = ch;
                    unitGood(uid).depth = depth;
                    unitGood(uid).amplitudes = amplitudes;
                    unitGood(uid).spikeTimesOfAmplitudes = spikeTimesOfRand;
                    unitGood(uid).amplitudePerChannel = amplitudePerChannel;

                    clusterInfo = tdfread([pathKS 'cluster_info.tsv'],'\t'); 
                    bestChInd = find(clusterInfo.custom_best_ch==unitGood(uid).ch);
                    if ~isempty(bestChInd)
                        allMatchingLayers = clusterInfo.final_neuron_layer(bestChInd,:);
                        unitGood(uid).layer = replace(strtrim(allMatchingLayers(1,:)),'_',' ');
                        logger.info('readAmplitude_Layer', ['BestChannel, Amplitudes and Layer info extracted from Kilosort results for unit=' num2str(unit.id)]);
                    else
                        logger.error('readAmplitude_Layer', ['Layer info couldnt found from ch=' num2str(unitGood(uid).ch) ' for unit=' num2str(unit.id)]);
                    end
                else
                    [ch, depth, amplitudes, amplitudePerChannel] = findBestChannel_Amplitudes(startSamples, nSamples, npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double', imecMeta);                    
                    if ch~=unitGood(uid).ch
                        logger.info('readAmplitude_Layer', ['Channel info for unit=' num2str(unit.id) ' in Kilosort with biggest amplitude ch=' num2str(ch) ' is different than DartSort ch=' num2str(unitGood(uid).ch)]);
                    end

                    if ~isempty(amplitudes)
                        needToSave = 1;
                    end
                    unitGood(uid).ch = ch;
                    unitGood(uid).depth = depth;
                    unitGood(uid).amplitudes = amplitudes;
                    unitGood(uid).spikeTimesOfAmplitudes = spikeTimesOfRand;
                    unitGood(uid).amplitudePerChannel = amplitudePerChannel;

                    clusterInfo = tdfread([pathKS 'cluster_info.tsv'],'\t'); 
                    bestChInd = find(clusterInfo.custom_best_ch==unitGood(uid).ch);
                    if ~isempty(bestChInd)
                        allMatchingLayers = clusterInfo.final_neuron_layer(bestChInd,:);
                        unitGood(uid).layer = replace(strtrim(allMatchingLayers(1,:)),'_',' ');
                        logger.info('readAmplitude_Layer', ['BestChannel, Amplitudes and Layer info extracted from Kilosort results for unit=' num2str(unit.id)]);
                    else
                        logger.error('readAmplitude_Layer', ['Layer info couldnt found from ch=' num2str(unitGood(uid).ch) ' for unit=' num2str(unit.id)]);
                    end
                end
            end
        elseif ~DART_SORTED %~isempty(unit.amplitudes) && ~isfield(unit,'amplitudePerChannel')% This unit comes from Kilosort, you should find amplitudePerChannel
            spikeTimesWhole = unit.spikeTimesSecs;
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
        
                nElements = min(length(spikeTimes), RAW_RANDOM_N); % whichever less, take that one
                nRandSpikeTimes = randperm(length(spikeTimes),nElements);
                startSamples = zeros(1,length(nRandSpikeTimes));
                spikeTimesOfRand = spikeTimes(nRandSpikeTimes);
                for i=1:length(nRandSpikeTimes)
                    % Get 3 ms interval of filtered data around the spike
                    startSec = spikeTimesOfRand(i)-RAW_PRE_SPIKE;
                    if startSec<0
                        startSec = 0;
                    end
                    startSamples(i) = int64(floor(startSec*samplingRate));
                end                
            
                if READ_RAW_OR_FILTERED_SIGNAL % Read from CatGT'd raw data
                    [ch, depth, amplitudes, amplitudePerChannel] = findBestChannel_Amplitudes(startSamples, nSamples, imecRawBinFile.bytes, imecRawBinFile.name, pathToRecFolder, SIZE_OF_INT16, 'int16=>double', imecMeta);
                    if ch~=unitGood(uid).ch
                        logger.info('readAmplitude_Layer', ['Channel info for unit=' num2str(unit.id) ' in Raw data ch=' num2str(ch) ' is different than Kilosort ch with biggest amplitude =' num2str(unitGood(uid).ch)]);
                    end

                    unitGood(uid).amplitudePerChannel = amplitudePerChannel;
                else
                    if ~isfield(unitGood(uid),'amplitudePerChannel') || isempty(unitGood(uid).amplitudePerChannel)
                        [ch, depth, amplitudes, amplitudePerChannel] = findBestChannel_Amplitudes(startSamples, nSamples, npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double', imecMeta);
                        if ch~=unitGood(uid).ch
                            logger.info('readAmplitude_Layer', ['Channel info for unit=' num2str(unit.id) ' in Raw data ch=' num2str(ch) ' is different than Kilosort ch with biggest amplitude =' num2str(unitGood(uid).ch)]);
                        end                    
                        unitGood(uid).amplitudePerChannel = amplitudePerChannel;
                    end
                end
            end
        end
    end
end
        