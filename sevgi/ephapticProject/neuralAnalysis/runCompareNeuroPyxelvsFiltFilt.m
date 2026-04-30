        clc
        clearvars
        clearvars -global
        close all
        gpuDevice(1);
        globals;
        
        imecMetaFiles = dir([pathToFilteredRec '*imec*ap.meta']); % do NOT forget to put its meta file with same name
        metaFile = imecMetaFiles(1);
        imecBinFiles = dir([pathToFilteredRec '*imec*ap.filtered.bin']); % do NOT forget to put its meta file with same name
        filtFiltedBinFile = imecBinFiles(1);
        imecBinFiles = dir([pathNpyxFiltered '*imec*ap.bin']); % do NOT forget to put its meta file with same name
        npyxFilteredBinFile = imecBinFiles(1);
    
        % Parse the corresponding metafile
        %imecBinFiles = dir([pathNpyxOrgDataFolder '*imec*ap.bin']);
        %imecBinFile = imecBinFiles(1);
        imecMeta = readMeta(metaFile.name, pathToFilteredRec); %(imecBinFile.name, pathNpyxOrgDataFolder);
        samplingRate = str2double(imecMeta.imSampRate);
        %nSamples = int64(floor((RAW_PRE_SPIKE+RAW_POST_SPIKE)*samplingRate));
        nSamples = int64(1 * samplingRate);
        %unitVSSpikeTimes = selectSpikesWithNeighboringUnits(unit.id, unit.spikeTimesSecs, unit.ch, units);
    
        trialCount = 100;
        startSec = 0;
        startSamples = int64(floor(startSec*samplingRate));
        ch = 6;

        %startSamples = zeros(1,trialCount);
        for i=1:trialCount                        
            waveForm = readBinWRTDataType(startSamples, nSamples, ch, filtFiltedBinFile.bytes, filtFiltedBinFile.name, pathToFilteredRec, SIZE_OF_SINGLE, 'single=>double');    
            waveFormNpyxl = readBinWRTDataType(startSamples, nSamples, ch, npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double');    
            startSamples = startSamples + nSamples + 1;

            SKIP_TO_PLOT = 4;
                        
            x = 0:1/samplingRate:double(nSamples)/samplingRate-1/samplingRate;
            %xPlot = x(1:SKIP_TO_PLOT:end); % You don't need that high resolution to plot
    
            if ~isempty(waveForm)      
                
                %for iPlt=1:size(waveForm,1)
                    f = figure;
                    f.Position = [globalX globalY globalW globalH];     
    
                    subplot(2,1,1);
                    plot(x,waveForm,'LineWidth',1.5, 'color', 'blue'); %, 'color',[.9 .9 .9 0.7]);
                    hold on
                    
                    minY = min(waveForm);
                    maxY = max(waveForm);
                    ylim([minY*1.5 maxY*1.5]);
    
                    subplot(2,1,2);
                    plot(x,waveFormNpyxl,'LineWidth',1.5, 'color', 'blue'); %, 'color',[.9 .9 .9 0.7]);
                    hold on                
                    minY = min(waveFormNpyxl);
                    maxY = max(waveFormNpyxl);
                    
                    ylim([minY*1.5 maxY*1.5]);
                    title(['Ch=' num2str(ch)]);
                    set(gca,'TickDir','out');
                    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)
        
                    sgtitle(['ch=' num2str(ch) ') ']); % sLocalTitle
        
                    han=axes(f,'visible','off'); 
                    han.Title.Visible='on';
                    han.XLabel.Visible='on';
                    han.YLabel.Visible='on';
                    ylabel(han,'uV');
                    xlabel(han,'Time (s)');
        
                    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)
                    %sFolder = [pathToFigureFolder num2str(unit.id)];
                    %print([sFolder '/' 'spikeWaveForm_FilteredVSNeuroPyxels.tif'], '-dtiff', '-r100');
                %end
                close all;
                logger.info('readFilteredWaveFormWithOtherUnits', ['Filtered waveform is plot']);
            end
        end
