function readRawData(unitID, spikeTimesSecs, ch, csID, csTriggerTimes)

    globals;

    uVCoeff = 10^6;
  
    imecMetaFiles = dir([pathToRecFolder '*imec*ap.meta']);
    metaFile = imecMetaFiles(1);    
    imecBinFiles = dir([pathToRecFolder '*imec*ap.bin']);
    imecRawBinFile = imecBinFiles(1);

    % Parse the corresponding metafile
    imecMeta = readMeta(metaFile.name, pathToRecFolder);
    samplingRate = str2double(imecMeta.imSampRate);
    nSamples = int64(floor((PRE_TIME_RAW_DATA_TRACE+POST_TIME_RAW_DATA_TRACE)*samplingRate)); 
    
    startSamples = zeros(1,length(csTriggerTimes));
    for i=1:length(csTriggerTimes)
        % Get 3 ms interval of filtered data around the spike
        startSec = csTriggerTimes(i)-PRE_TIME_RAW_DATA_TRACE;
        if startSec<0
            startSec = 0;
        end
        startSamples(i) = int64(floor(startSec*samplingRate));                   
    end


    waveForm = readBinWRTDataType(startSamples, nSamples, ch, imecRawBinFile.bytes, imecRawBinFile.name, pathToRecFolder, SIZE_OF_INT16, 'int16=>double');               
    waveForm = gainCorrectIM(waveForm, imecMeta);


    x=-PRE_TIME_RAW_DATA_TRACE:1/samplingRate:POST_TIME_RAW_DATA_TRACE-1/samplingRate;
    x=x.*1000; % convert to ms
    %xPlot = x(1:SKIP_TO_PLOT:end); % You don't need that high resolution to plot

    if ~isempty(waveForm)        
        
        for iPlt=1:50 %size(waveForm,1)
    
            spikeTimesSecsPerTrial = spikeTimesSecs(spikeTimesSecs>csTriggerTimes(iPlt)-PRE_TIME_RAW_DATA_TRACE&spikeTimesSecs<csTriggerTimes(iPlt)+POST_TIME_RAW_DATA_TRACE);
            if ~isempty(spikeTimesSecsPerTrial)
                spikeTimesSecsPerTrialAligned = spikeTimesSecsPerTrial - csTriggerTimes(iPlt);
                spikeTimesMSecsPerTrialAligned = spikeTimesSecsPerTrialAligned*1000;
    
                iWaveForm = waveForm(iPlt,:)*uVCoeff;
                f = figure;
                f.Position = [globalX globalY globalW globalH];    
                hold on
                plot(x,iWaveForm,'LineWidth',1.5, 'color', 'k');
                            
                minY = min(iWaveForm);
                maxY = max(iWaveForm);
%                 scatter(spikeTimesMSecsPerTrialAligned,maxY*1.1, 60, 'filled', 'MarkerFaceColor', 'black','MarkerFaceAlpha','0.5');            
%                 xline(spikeTimesMSecsPerTrialAligned,'--');
                xline(0,'--');
                xlim([-PRE_TIME_RAW_DATA_TRACE*1000 POST_TIME_RAW_DATA_TRACE*1000]);
                ylim([minY*1.5 maxY*1.5]);
                ylabel('Amplitude (uV)');
                xlabel('Time (ms)');
%                 grid on
%                 title(['Raw trace']); % of Unit=' num2str(unitID)]);
                set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5);        
                                        
                print([pathToFigureFolder num2str(csID) '/rawData' num2str(iPlt) '.tif'], '-dtiff', '-r120');
                exportgraphics(f,[pathToFigureFolder num2str(csID) '/rawData' num2str(iPlt) '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
            
                close all;
            end
        end
        
        logger.info('readRawWaveFormAligned', ['Filtered waveform is plot for unit=' num2str(unitID)]);
    end
    
    %dataArrayGCorr = gainCorrectIM(dataArray, chList, imecMeta); % No need to gainCorrect cos data filtered through NeuroPyxels
        
end