function [waveForm, laserOnsetTimesPartial, samplingRate]=readRawWaveFormAligned(unitID, spikeTimesSecs, laserOnsetTimesGLX, ch, startTimeSecs, endTimeSecs, sFileName)

    globals;
  
    imecMetaFiles = dir([pathToRecFolder '*imec*ap.meta']);
    metaFile = imecMetaFiles(1);    
    imecBinFiles = dir([pathToRecFolder '*imec*ap.bin']);
    imecRawBinFile = imecBinFiles(1);
%     imecBinFiles = dir([pathToFilteredRec '*imec*ap.filtered.bin']); % do NOT forget to put its meta file with same name
%     filtFiltedBinFile = imecBinFiles(1);
    imecBinFiles = dir([pathCatGT_filtered '*tcat.imec*ap.bin']); % filtered.bin % do NOT forget to put its meta file with same name
    catGT_filtered_BinFile = imecBinFiles(1);

    % Parse the corresponding metafile
    imecMeta = readMeta(metaFile.name, pathToRecFolder);
    samplingRate = str2double(imecMeta.imSampRate);
    nSamples = int64(floor((PRE_TIME_LASER+POST_TIME_LASER)*samplingRate)); 
    laserOnsetTimesPartial = laserOnsetTimesGLX(laserOnsetTimesGLX>startTimeSecs & laserOnsetTimesGLX<endTimeSecs);    
    spikeTimesSecsPartial = spikeTimesSecs(spikeTimesSecs>startTimeSecs & spikeTimesSecs<endTimeSecs);
    
    startSamples = zeros(1,length(laserOnsetTimesPartial));
    for i=1:length(laserOnsetTimesPartial)
        % Get 3 ms interval of filtered data around the spike
        startSec = laserOnsetTimesPartial(i)-PRE_TIME_LASER;
        if startSec<0
            startSec = 0;
        end
        startSamples(i) = int64(floor(startSec*samplingRate));                   
    end

    waveForm = readBinWRTDataType(startSamples, nSamples, ch, imecRawBinFile.bytes, imecRawBinFile.name, pathToRecFolder, SIZE_OF_INT16, 'int16=>double');    
    %waveFormFiltered = readBinWRTDataType(startSamples, nSamples, ch, filtFiltedBinFile.bytes, filtFiltedBinFile.name, pathToFilteredRec, SIZE_OF_SINGLE, 'single=>double');    
    waveFormFiltered = readBinWRTDataType(startSamples, nSamples, ch, catGT_filtered_BinFile.bytes, catGT_filtered_BinFile.name, pathCatGT_filtered, SIZE_OF_INT16, 'int16=>double');                 

    x=-PRE_TIME_LASER:1/samplingRate:POST_TIME_LASER-1/samplingRate;
    x=x.*1000; % convert to ms
    %xPlot = x(1:SKIP_TO_PLOT:end); % You don't need that high resolution to plot

    if ~isempty(waveForm)        
        
        for iPlt=1:size(waveForm,1)

            if (laserOnsetTimesPartial(iPlt)+POST_TIME_LASER)>endTimeSecs
                endTime = endTimeSecs;
            else
                endTime = laserOnsetTimesPartial(iPlt)+POST_TIME_LASER;
            end
            spikeTimesSecsPerTrial = spikeTimesSecsPartial(spikeTimesSecsPartial>laserOnsetTimesPartial(iPlt)&spikeTimesSecsPartial<endTime);

            if ~isempty(spikeTimesSecsPerTrial)
                spikeTimesSecsPerTrialAligned = spikeTimesSecsPerTrial - laserOnsetTimesPartial(iPlt);
                spikeTimesMSecsPerTrialAligned = spikeTimesSecsPerTrialAligned*1000;
    
                f = figure;
                f.Position = [globalX globalY globalW globalH];     
                subplot(2,1,1); 
                hold on
                minY = 0;
                maxY = 0;
                plot(x,waveForm(iPlt,:),'LineWidth',1, 'color', [0 0 1 .8]);
                            
                minY = min(minY,min(waveForm(iPlt,:)));
                maxY = max(maxY,max(waveForm(iPlt,:)));
                scatter(spikeTimesMSecsPerTrialAligned,maxY*1.1, 60, 'filled', 'MarkerFaceColor', 'black');            
                xline(spikeTimesMSecsPerTrialAligned,'--');
                xlim([-PRE_TIME_LASER*1000 POST_TIME_LASER*1000]);
                ylim([minY*1.5 maxY*1.5]);
                grid on
                title(['Raw Data']);
                set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)
        
                subplot(2,1,2); 
                hold on
                minY = 0;
                maxY = 0;           
                waveform_uV = waveFormFiltered(iPlt,:)*10^6; % plot in uV
                plot(x, waveform_uV,'LineWidth',1, 'color', 'blue'); %, 'color',[.9 .9 .9 0.7]);
                         
                minY = min(minY,min(waveform_uV));
                maxY = max(maxY,max(waveform_uV));  
                scatter(spikeTimesMSecsPerTrialAligned,maxY*1.1, 60, 'filled', 'MarkerFaceColor', 'black');            
                xline(spikeTimesMSecsPerTrialAligned,'--');
                xlim([-PRE_TIME_LASER*1000 POST_TIME_LASER*1000]);
                ylim([minY*1.5 maxY*1.5]);
                
                ylabel('uV');
                xlabel('Time from laser onset (ms)')
                grid on
                title(['CatGT filtered']);
                set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)                         
                saveas(gcf, [pathToRawVSFilteredWaveFormAlignedToLaser '/' 'spikeWaveForm_RawvsFilteredAlignedToLaser_unit' num2str(unitID) '_' sFileName '_' num2str(iPlt) '.fig']);
                %print([pathToRawVSFilteredWaveFormAlignedToLaser '/' 'spikeWaveForm_RawvsFilteredAlignedToLaser_unit' num2str(unitID) '_' num2str(momentPower) 'mW_' num2str(iPlt) '.tif'], '-dtiff', '-r100');
                close all;
            end
        end
        
        logger.info('readRawWaveFormAligned', ['Filtered waveform is plot for unit=' num2str(unitID)]);
    end
    
    %dataArrayGCorr = gainCorrectIM(dataArray, chList, imecMeta); % No need to gainCorrect cos data filtered through NeuroPyxels
        
end