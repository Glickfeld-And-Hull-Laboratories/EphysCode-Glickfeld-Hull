function readPlotWaveforms(unitID, spikeTimesSecs, ch)

    globals;
   
    imecMetaFiles = dir([pathToFilteredRec '*imec*ap.meta']);
    metaFile = imecMetaFiles(1);    
    imecBinFiles = dir([pathToFilteredRec '*imec*ap.bin']);
    imecRawBinFile = imecBinFiles(1);
    imecBinFiles = dir([pathToFilteredRec '*imec*ap.filtered.bin']); % do NOT forget to put its meta file with same name
    filtFiltedBinFile = imecBinFiles(1);

    % Parse the corresponding metafile
    imecMeta = readMeta(metaFile.name, pathToFilteredRec);
    samplingRate = str2double(imecMeta.imSampRate);
    nSamples = int64(floor((RAW_PRE_SPIKE+RAW_POST_SPIKE)*samplingRate)); 
    nElements = min(length(spikeTimesSecs), RAW_RANDOM_N); % whichever less, take that one
    nRandSpikeTimes = randperm(length(spikeTimesSecs),nElements);
    startSamples = zeros(1,length(nRandSpikeTimes));
    for i=1:length(nRandSpikeTimes)
        % Get 3 ms interval of filtered data around the spike
        startSec = spikeTimesSecs(nRandSpikeTimes(i))-RAW_PRE_SPIKE;
        if startSec<0
            startSec = 0;
        end
        startSamples(i) = int64(floor(startSec*samplingRate));
    end

    waveForm = readBinWRTDataType(startSamples, nSamples, ch, imecRawBinFile.bytes, imecRawBinFile.name, pathToFilteredRec, SIZE_OF_INT16, 'int16=>double');    
    waveFormFiltered = readBinWRTDataType(startSamples, nSamples, ch, filtFiltedBinFile.bytes, filtFiltedBinFile.name, pathToFilteredRec, SIZE_OF_SINGLE, 'single=>double');    

    x=-RAW_PRE_SPIKE:1/samplingRate:RAW_POST_SPIKE-1/samplingRate;
    x=x.*1000; % convert to ms
    %xPlot = x(1:SKIP_TO_PLOT:end); % You don't need that high resolution to plot

    if ~isempty(waveForm)                       

        f = figure;
        f.Position = [globalX globalY globalW globalH];     
        subplot(2,1,1); 
        hold on
        minY = 0;
        maxY = 0;
        for iPlt=1:size(waveForm,1)
            plot(x,waveForm(iPlt,:),'LineWidth',1.3); %, 'color', [0 0 1 .8]);
            minY = min(minY,min(waveForm(iPlt,:)));
            maxY = max(maxY,max(waveForm(iPlt,:)));
        end        
        
        xlim([-RAW_PRE_SPIKE*1000 RAW_POST_SPIKE*1000]);
        ylim([minY*1.5 maxY*1.5]);
        grid on
        title(['Raw Data']);
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)

        subplot(2,1,2); 
        hold on
        minY = 0;
        maxY = 0;           
        for iPlt=1:size(waveFormFiltered,1)
            waveform_uV = waveFormFiltered(iPlt,:)*10^6; % plot in uV
            plot(x, waveform_uV,'LineWidth',1); %, 'color', 'blue'); %, 'color',[.9 .9 .9 0.7]);
            minY = min(minY,min(waveform_uV));
            maxY = max(maxY,max(waveform_uV));                  
        end                
        xlim([-RAW_PRE_SPIKE*1000 RAW_POST_SPIKE*1000]);
        ylim([minY*1.5 maxY*1.5]);
        
        ylabel('uV');
        xlabel('Time from laser onset (ms)')
        grid on
        title(['filtfilt']);
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)                         
        saveas(gcf, [pathToRawVSFilteredWaveFormAlignedToLaser '/' 'spikeWaveForm_RawvsFilteredAlignedToLaser_unit' num2str(unitID) '_' num2str(momentPower) 'mWSecond_' num2str(iPlt) '.fig']);
        %print([pathToRawVSFilteredWaveFormAlignedToLaser '/' 'spikeWaveForm_RawvsFilteredAlignedToLaser_unit' num2str(unitID) '_' num2str(momentPower) 'mW_' num2str(iPlt) '.tif'], '-dtiff', '-r100');
        close all;
        
        logger.info('readRawWaveFormAligned', ['Filtered waveform is plot for unit=' num2str(unitID)]);
    end
    
    %dataArrayGCorr = gainCorrectIM(dataArray, chList, imecMeta); % No need to gainCorrect cos data filtered through NeuroPyxels
        
end