%function [waveFormMean, waveFormMin, waveFormMax, samplingRate]=readRawWaveForm(unit)
    clc
    clearvars
    clearvars -global
    close all
    tic
    gpuDevice(1); % Activate GPU Device

    globals;
    %ntb = 64; % in kilosort: called ntbuff
    NUM_OF_CHANNELS = 385;
                
    imecMetaFiles = dir([pathToFilteredRec '*imec*ap.meta']);
    imecMetaFile = imecMetaFiles(1);
    
    imecMeta = readMeta(imecMetaFile.name, pathToFilteredRec); %(imecBinFile.name, pathNpyxOrgDataFolder);
    samplingRate = str2double(imecMeta.imSampRate);    
    nSamples = floor(str2double(imecMeta.fileSizeBytes)/(2 * NUM_OF_CHANNELS)); % 2 bytes for int16

    imecBinFiles = dir([pathToFilteredRec '*imec*ap.bin']);
    imecBinFile = imecBinFiles(1);
    memoryMapBin = memmapfile([pathToFilteredRec imecBinFile.name], 'Format',{'int16',[nSamples NUM_OF_CHANNELS], 'rawData'});
    inds = strfind(imecBinFile.name,'.');
    imecFileName = imecBinFile.name(1:inds(end));
    filteredBinFileName = [imecFileName 'filtered.bin'];

    imecBinFiles = dir([pathNpyxFiltered '*imec*ap.bin']); % do NOT forget to put its meta file with same name
    npyxFilteredBinFile = imecBinFiles(1);

%     if exist([pathToFilteredRec filteredBinFileName],'file')==2
%         %delete([pathToFilteredRec filteredBinFileName]);
%         fileID = fopen([pathToFilteredRec filteredBinFileName]);
%         fclose(fileID);
%         delete(fileID);
%     end
    
    % Preprocess iteratively, batch by batch
    %NT = 64 * 1024 + ntb;
    %Nbatch = ceil(n_samples / NT); % num of batches
    %NTbuff = NT + 3 * ntb;

    batchSize = 10 * samplingRate; %1024; % 10 KB per channel
    bufferSize = ceil(batchSize/10); % 10% of the mean signal willl be added as buffer
    totalBatchSize = batchSize + 2*bufferSize;
    numOfBatches = ceil(nSamples/batchSize);

    hiPass = 300; % hi pass cutoff
    hi = hiPass*2/samplingRate; % normalized for ADC sampling rate
    [b1,a1] = butter(3,hi,"high");

    randomCh = 6;
    cursor = 1;
    %filteredSignals = zeros(numOfBatches*batchSize,NUM_OF_CHANNELS);
    sizeOfRawData = size(memoryMapBin.Data.rawData,1);
    [filteredFileID, errMes] = fopen([pathToFilteredRec filteredBinFileName],'w');
    
    for i=1:numOfBatches        
        endOfBatch = batchSize+bufferSize;
        endOfBufferedBatch = cursor+totalBatchSize-1;
        if cursor>sizeOfRawData
            error('Cursor is at the end of file!');
        elseif endOfBufferedBatch>sizeOfRawData % if it's the last batch and left over data size is not matching our batch size
            endOfBufferedBatch = sizeOfRawData;
        end
        if i==1 % if this is first batch, add preceeding syntetic buffer
            tempBuffer = memoryMapBin.Data.rawData(1:bufferSize-1,:);
            tempBuffer = mean(tempBuffer,1);
            tempBuffer = repmat(tempBuffer,[bufferSize 1]); % build a syntetic buffer made up of mean signal of the first batch
            rawData = double([tempBuffer; memoryMapBin.Data.rawData(1:batchSize+bufferSize,:)]);

            waveFormNpyxl = readBin(0, batchSize+bufferSize, randomCh, imecMeta, npyxFilteredBinFile.name, pathNpyxFiltered);

            cursor = batchSize-bufferSize; % next cursor should start from an earlier timepoint matching with buffer
        else
            rawData = double(memoryMapBin.Data.rawData(cursor:endOfBufferedBatch,:));

            waveFormNpyxl = readBin(cursor+bufferSize, batchSize, randomCh, imecMeta, npyxFilteredBinFile.name, pathNpyxFiltered);

            cursor = cursor+batchSize; % next cursor should start at the preceeding buffer time point of next batch
        end

        
        

        rawDataGCorr = gainCorrectIM(rawData, 1:NUM_OF_CHANNELS, imecMeta);
%         meanRawDataGCorr = mean(rawDataGCorr,1);
%         buffer = repmat(meanRawDataGCorr,[bufferSize 1]); % 10% of the signal will be added to the front and back to get rid of edge distortions of filtfilt
%         bufferedRawDataGCorr = [buffer;rawDataGCorr;buffer];
        filteredBufferedRawData = filtfilt(b1,a1,rawDataGCorr);
        filteredBufferedRawData = filteredBufferedRawData - mean(filteredBufferedRawData,1); % filtered sensor signal
        
        if size(filteredBufferedRawData,1)<endOfBatch
            endOfBatch = size(filteredBufferedRawData,1);
        end
        filteredSignal = filteredBufferedRawData(bufferSize+1:endOfBatch,:);
        
        %filteredSignals = [filteredSignals;filteredSignal];
        filteredSignalSingle = single(filteredSignal); % convert it to 32-bit-single instead of 64-bit-double for resource management
        fwrite(filteredFileID,filteredSignalSingle,'single');
        logger.info('runFiltFilt', [num2str(i) '/' num2str(numOfBatches) ' of batches filtered and written in ' num2str(toc,'%.2f') ' sec.!']);
        
        fig = figure('Name', 'FiltFilt', 'pos',[15 50 1500 700]);
        rawDataSample = rawData(bufferSize:bufferSize+batchSize,randomCh);      
        t = 0:1/samplingRate:length(rawDataSample)/samplingRate-1/samplingRate;    
        subplot(3,1,1);
        plot(t,rawDataSample);
        title(['Raw data']);
        
        t = 0:1/samplingRate:length(filteredSignalSingle(:,randomCh))/samplingRate-1/samplingRate;
        filteredSample = filteredSignalSingle(:,randomCh);
        subplot(3,1,2);
        plot(t,filteredSample)
        title(['Spike filtering (Hi Pass=300K)']);
    
        t = 0:1/samplingRate:length(waveFormNpyxl)/samplingRate-1/samplingRate;
        subplot(3,1,3);
        plot(t,waveFormNpyxl)
        title(['waveFormNpyxl' num2str(i)]);
        a=0;
    end
    fclose(filteredFileID);
        



%     startSamples = zeros(1,1000);
% 
%     dataArray = NaN(length(startSamples),nSamples);
%     dataArray = readBin(startSamples, nSamples, 3, imecMeta, imecBinFile.name, pathToFilteredRec);    
%     dataArrayGCorr = gainCorrectIM(dataArray, [3], imecMeta); % No need to gainCorrect cos data filtered through NeuroPyxels
%     
% 
%     rawSignal = dataArrayGCorr(1,:);
%     %%% Spikes
%     hiPass = 300; % hi pass cutoff
%     hi = hiPass*2/samplingRate; % normalized for ADC sampling rate
%     [b2,a2] = butter(3,hi,"high");
%     filteredCh = filtfilt(b2,a2,rawSignal);
%     filteredCh = filteredCh - mean(filteredCh); % filtered sensor signal
%      
%     t = 0:1/samplingRate:length(rawSignal)/samplingRate-1/samplingRate;
%     fig = figure('Name', 'FiltFilt'); %, 'pos',[15 50 1500 700]);
%     subplot(2,1,1);
%     plot(t,rawSignal);
%     title(['Raw data from Tip ch=' num2str(i)]);
% 
%     subplot(2,1,2);
%     plot(t, filteredCh)
%     title(['Spike filtering (300-8K Hz) Ring ch=' num2str(i)]);

    
%end