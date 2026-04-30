function [samplingRate]=readFilteredWaveFormWithOtherUnits(unit, units)

    globals;
    alpha = 0.3;
    alphaLower = 0.1;
    maxSweepToPlotConstant = 100;
    maxSweepToPlot = maxSweepToPlotConstant;
    
    imecMetaFiles = dir([pathToRecFolder '*imec*ap.meta']); % do NOT forget to put its meta file with same name
    metaFile = imecMetaFiles(1);

    imecBinFiles = dir([pathToRecFolder '*imec*ap.bin']);
    imecRawBinFile = imecBinFiles(1);

    imecBinFiles = dir([pathCatGT_loccar28 '*tcat.imec*ap.bin']); % filtered.bin % do NOT forget to put its meta file with same name
    catGT_loccar28_BinFile = imecBinFiles(1);

    imecBinFiles = dir([pathCatGT '*tcat.imec*ap.bin']); % filtered.bin % do NOT forget to put its meta file with same name
    catGTFilteredBinFile = imecBinFiles(1);
%     imecBinFiles = dir([pathToFilteredRec '*imec*ap.filtered.bin']); % do NOT forget to put its meta file with same name
%     filtFiltedBinFile = imecBinFiles(1);

%     imecBinFiles = dir([pathNpyxFiltered '*imec*ap.bin']); % do NOT forget to put its meta file with same name
%     npyxFilteredBinFile = imecBinFiles(1);

    % Parse the corresponding metafile
    %imecBinFiles = dir([pathNpyxOrgDataFolder '*imec*ap.bin']);
    %imecBinFile = imecBinFiles(1);
    imecMeta = readMeta(metaFile.name, pathToRecFolder); %(imecBinFile.name, pathNpyxOrgDataFolder);
    samplingRate = str2double(imecMeta.imSampRate);
    nSamples = int64(floor((RAW_PRE_SPIKE_WOTHERS+RAW_POST_SPIKE_WOTHERS)*samplingRate));
    
    %nElements = min(length(unit.spikeTimesSecs), RAW_RANDOM_N); % whichever less, take that one
    %nRandSpikeTimes = randperm(length(unit.spikeTimesSecs),nElements);
    [unitVSSpikeTimes, ~] = selectSpikesWithNeighboringUnits(unit.id, unit.spikeTimesSecs, unit.ch, units, 1, 0, RAW_POST_SPIKE_WOTHERS, 0);

    if ~isempty(unitVSSpikeTimes)
        slaveUnits = unique([unitVSSpikeTimes{:,1}]);
        if UNIT_OF_INTEREST2==-1 || ismember(UNIT_OF_INTEREST2, slaveUnits)
            for iSU = 1:length(slaveUnits)
                if UNIT_OF_INTEREST2==-1 || UNIT_OF_INTEREST2==slaveUnits(iSU)
                    indSlaveUnit = find([unitVSSpikeTimes{:,1}]==slaveUnits(iSU));
                    slaveUnitVSSpikeTimes = unitVSSpikeTimes(indSlaveUnit,:);
                    
                    startSamples = zeros(1,size(slaveUnitVSSpikeTimes,1));
                    for i=1:size(slaveUnitVSSpikeTimes,1)
                        % Get 3 ms interval of filtered data around the spike
                        startSec = slaveUnitVSSpikeTimes{i,3}-RAW_PRE_SPIKE_WOTHERS;
                        if startSec<0
                            startSec = 0;
                        end
                        startSamples(i) = int64(floor(startSec*samplingRate));
                    end
            
                    gabazineWashIn = GAIN_CHANGE_MOMENTS_GABAZINE(1,3);
                    nbqxWashIn = GAIN_CHANGE_MOMENTS_NBQX(1,3);
                    indsBaseline = find(startSamples<(MOMENT_OF_GABAZINE_PUT_IN*samplingRate));
                    indsGabazine = find(startSamples>(gabazineWashIn*samplingRate) & startSamples<(MOMENT_OF_NBQX_PUT_IN*samplingRate));
                    indsNBQX = find(startSamples>(nbqxWashIn*samplingRate));
        
                    samplesBaseline = startSamples(indsBaseline);
                    samplesGabazine = startSamples(indsGabazine);
                    samplesNBQX = startSamples(indsNBQX);
        
                    waveFormRaw = readBinWRTDataType(startSamples, nSamples, unit.ch, imecRawBinFile.bytes, imecRawBinFile.name, pathToRecFolder, SIZE_OF_INT16, 'int16=>double');            
                    waveFormDmx = readBinWRTDataType(startSamples, nSamples, unit.ch, catGT_loccar28_BinFile.bytes, catGT_loccar28_BinFile.name, pathCatGT_loccar28, SIZE_OF_INT16, 'int16=>double');                 
            %         waveForm = readBinWRTDataType(startSamples, nSamples, unit.ch, catGTFilteredBinFile.bytes, catGTFilteredBinFile.name, pathCatGT, SIZE_OF_INT16, 'int16=>double');         
                    %waveForm = readBinWRTDataType(startSamples, nSamples, unit.ch, filtFiltedBinFile.bytes, filtFiltedBinFile.name, pathToFilteredRec, SIZE_OF_SINGLE, 'single=>double');    
                    %waveFormNpyxl = readBinWRTDataType(startSamples, nSamples, unit.ch, npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double');    
                    
                    waveFormBaseline =[];
                    waveFormGabazine = [];
                    waveFormNBQX = [];
                    if ~isempty(samplesBaseline)
                        waveFormBaseline = readBinWRTDataType(samplesBaseline, nSamples, unit.ch, catGT_loccar28_BinFile.bytes, catGT_loccar28_BinFile.name, pathCatGT_loccar28, SIZE_OF_INT16, 'int16=>double');
                    end
                    if ~isempty(samplesGabazine)
                        waveFormGabazine = readBinWRTDataType(samplesGabazine, nSamples, unit.ch, catGT_loccar28_BinFile.bytes, catGT_loccar28_BinFile.name, pathCatGT_loccar28, SIZE_OF_INT16, 'int16=>double');
                    end
                    if ~isempty(samplesNBQX)
                        waveFormNBQX = readBinWRTDataType(samplesNBQX, nSamples, unit.ch, catGT_loccar28_BinFile.bytes, catGT_loccar28_BinFile.name, pathCatGT_loccar28, SIZE_OF_INT16, 'int16=>double');
                    end
        
        
                    SKIP_TO_PLOT = 1;
                    
                    x=-RAW_PRE_SPIKE_WOTHERS:1/samplingRate:RAW_POST_SPIKE_WOTHERS-1/samplingRate;
                    x=x.*1000; % convert to ms
                    %xPlot = x(1:SKIP_TO_PLOT:end); % You don't need that high resolution to plot
            
                    if ~isempty(waveFormDmx)        
                        
                        f = figure;
                        f.Position = [globalX globalY globalW globalH];     
                        
                        maxSweepToPlot = maxSweepToPlotConstant;
                        maxSweepToPlot = min(size(waveFormDmx,1),maxSweepToPlot);
                        indsSweeps = randperm(size(waveFormDmx,1), maxSweepToPlot);
                            
                        subplot(2,1,1);                    
                        plot(x,waveFormRaw(indsSweeps,:),'LineWidth',1.5, 'color', [0 0 1 alpha]); %, 'color',[.9 .9 .9 0.7]);
                        hold on          
                        minY = min(min(waveFormRaw(indsSweeps,:)));
                        maxY = max(max(waveFormRaw(indsSweeps,:)));
                        scatter(0,maxY*1.1, 40, 'filled', 'MarkerFaceColor', 'black', 'MarkerFaceAlpha',alpha, 'MarkerEdgeAlpha',alpha);
                        xline(0);
                        xlim([-RAW_PRE_SPIKE_WOTHERS*1000 RAW_POST_SPIKE_WOTHERS*1000]);
                        ylim([minY*1.02 maxY*1.02]);
        
                        for iPlt=1:maxSweepToPlot
                            slaveNeuronId = slaveUnitVSSpikeTimes{indsSweeps(iPlt),1};
                            slaveNeuronType = slaveUnitVSSpikeTimes{indsSweeps(iPlt),2};
                            slaveSpikeTimes = (slaveUnitVSSpikeTimes{indsSweeps(iPlt),4} - slaveUnitVSSpikeTimes{indsSweeps(iPlt),3})*1000; % convert to ms                                       
                            scatter(slaveSpikeTimes,maxY, 40, 'filled', 'MarkerFaceColor', 'black', 'MarkerFaceAlpha',alpha, 'MarkerEdgeAlpha',alpha);                    
                            xline(slaveSpikeTimes);
                        end
        
                        grid on
                        title(['Raw Data']);
                        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)
        
                        subplot(2,1,2); 
                        waveform_uV = waveFormDmx(indsSweeps,:)*10^6; % plot in uV
                        plot(x, waveform_uV,'LineWidth',1.5, 'color', [0 0 1 alpha]); %, 'color',[.9 .9 .9 0.7]);
                        hold on         
                        minY = min(min(waveform_uV));
                        maxY = max(max(waveform_uV));
                        indType = find(ismember(NEURON_TYPES,unit.neuronType));                
                        scatter(0,maxY, 40, 'filled', 'MarkerFaceColor', COLOR_CODES{indType}, 'MarkerFaceAlpha',alpha, 'MarkerEdgeAlpha',alpha);
                        xline(0);
                        
                        for iPlt=1:maxSweepToPlot
                            slaveNeuronId = slaveUnitVSSpikeTimes{indsSweeps(iPlt),1};
                            slaveNeuronType = slaveUnitVSSpikeTimes{indsSweeps(iPlt),2};
                            slaveSpikeTimes = (slaveUnitVSSpikeTimes{indsSweeps(iPlt),4} - slaveUnitVSSpikeTimes{indsSweeps(iPlt),3})*1000; % convert to ms 
                            indType = find(ismember(NEURON_TYPES,slaveNeuronType));
                            scatter(slaveSpikeTimes,maxY, 40, 'filled', 'MarkerFaceColor', COLOR_CODES{indType}, 'MarkerFaceAlpha',alpha, 'MarkerEdgeAlpha',alpha);
                            xline(slaveSpikeTimes);
                        end
            
                        xlim([-RAW_PRE_SPIKE_WOTHERS*1000 RAW_POST_SPIKE_WOTHERS*1000]);
                        ylim([minY*1.02 maxY*1.02]);                
                        legend(['id=' num2str(slaveNeuronId) ' type=' slaveNeuronType],'Color','none','Location','SouthEast');
                        ylabel('uV');
                        grid on
                        title(['Demuxed Raw Data']);
                        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)    
                        sgtitle(['Unit=' num2str(unit.id) ' (' unit.neuronType ' ch=' num2str(unit.ch) ')  vs Slave Unit=' num2str(slaveNeuronId) ' type=' slaveNeuronType ')']); % sLocalTitle
            
                        han=axes(f,'visible','off'); 
                        han.Title.Visible='on';
                        han.XLabel.Visible='on';
                        han.YLabel.Visible='on';
                        ylabel(han,'uV');
                        xlabel(han,'Time (ms)');    
                        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5); 
            
                        print([pathToWaveFormWithOtherUnits '/' 'spikeWaveForm_RawVSFiltered_' num2str(unit.id) 'VS' num2str(slaveNeuronId) '.tif'], '-dtiff', '-r100');
                        %savefig(f,[pathToWaveFormWithOtherUnits '/' 'spikeWaveForm_RawVSFiltered_' num2str(unit.id) 'VS' num2str(slaveNeuronId) '.fig']);
                        close all;
            
                        %logger.info('readFilteredWaveFormWithOtherUnits', ['Filtered waveform is plot for unit=' num2str(unit.id) ' VS ' num2str(slaveNeuronId)]);
                    end
        
                    % Now, plot DRUG EFFECTS! Baseline VS Gabazine VS NBQX
        
                    if ~isempty(waveFormBaseline) || ~isempty(waveFormGabazine) || ~isempty(waveFormNBQX)
                        
                        f = figure;
                        f.Position = [globalX globalY globalW globalH];     
                        hold on
                        maxY = 0;
                        minY = 0;
        
                        if ~isempty(waveFormBaseline)
                            meanBaseline = mean(waveFormBaseline,1);
                            maxY = max(max(meanBaseline),maxY);
                            minY = min(min(meanBaseline),minY);                    
                        end
                        if ~isempty(waveFormGabazine)
                            meanGabazine = mean(waveFormGabazine,1);
                            maxY = max(max(meanGabazine),maxY);
                            minY = min(min(meanGabazine),minY);                    
                        end
                        if ~isempty(waveFormNBQX)
                            meanNBQX = mean(waveFormNBQX,1);
                            maxY = max(max(meanNBQX),maxY);
                            minY = min(min(meanNBQX),minY);                    
                        end
        
                        maxSweepToPlot = maxSweepToPlotConstant;
                        maxSweepToPlot = min(size(waveFormBaseline,1),maxSweepToPlot);
                        indsSweeps = randperm(size(waveFormBaseline,1), maxSweepToPlot);
                        for iBsln=1:maxSweepToPlot
                            plot(x,waveFormBaseline(indsSweeps(iBsln),:),'LineWidth',0.3, 'color', [0 0 0 0.1]);
                            slaveSpikeTimes = (slaveUnitVSSpikeTimes{indsBaseline(indsSweeps(iBsln)),4} - slaveUnitVSSpikeTimes{indsBaseline(indsSweeps(iBsln)),3})*1000; % convert to ms 
                            scatter(slaveSpikeTimes,maxY*1.05, 40, 'filled', 'MarkerFaceColor', 'black', 'MarkerFaceAlpha',alpha, 'MarkerEdgeAlpha',alpha);
                        end
        
                        maxSweepToPlot = maxSweepToPlotConstant;
                        maxSweepToPlot = min(size(waveFormGabazine,1),maxSweepToPlot);
                        indsSweeps = randperm(size(waveFormGabazine,1), maxSweepToPlot);
                        for iGab=1:maxSweepToPlot %size(waveFormGabazine,1)
                            plot(x,waveFormGabazine(indsSweeps(iGab),:),'LineWidth',0.3, 'color', [1 0 0 0.1]);
                            slaveSpikeTimes = (slaveUnitVSSpikeTimes{indsGabazine(indsSweeps(iGab)),4} - slaveUnitVSSpikeTimes{indsGabazine(indsSweeps(iGab)),3})*1000; % convert to ms 
                            scatter(slaveSpikeTimes,maxY*1.1, 40, 'filled', 'MarkerFaceColor', 'red', 'MarkerFaceAlpha',alpha, 'MarkerEdgeAlpha',alpha);
                        end
        
                        maxSweepToPlot = maxSweepToPlotConstant;
                        maxSweepToPlot = min(size(waveFormNBQX,1),maxSweepToPlot);
                        if ~maxSweepToPlot % Good way to catch MF-GrC pairs if slave unit doesn't follow master unit anymore during NBQX
                            logger.info('readFilteredWaveFormWithOtherUnits', ['Master unit=' num2str(unit.id) ' is NOT followed by slave unit=' num2str(slaveNeuronId) ' during NBQX']);
                        end
        
                        indsSweeps = randperm(size(waveFormNBQX,1), maxSweepToPlot);
                        for iNBQX=1:maxSweepToPlot %size(waveFormNBQX,1)
                            plot(x,waveFormNBQX(indsSweeps(iNBQX),:),'LineWidth',0.3, 'color', [0 0 1 0.1]);
                            slaveSpikeTimes = (slaveUnitVSSpikeTimes{indsNBQX(indsSweeps(iNBQX)),4} - slaveUnitVSSpikeTimes{indsNBQX(indsSweeps(iNBQX)),3})*1000; % convert to ms 
                            scatter(slaveSpikeTimes,maxY*1.15, 40, 'filled', 'MarkerFaceColor', 'blue', 'MarkerFaceAlpha',alpha, 'MarkerEdgeAlpha',alpha);
                        end
        
                        if ~isempty(waveFormBaseline)                    
                            plot(x,meanBaseline,'LineWidth',4, 'color', [0 0 0 0.6]);
                        end
                        if ~isempty(waveFormGabazine)
                            plot(x,meanGabazine,'LineWidth',4, 'color', [1 0 0 0.6]);
                        end
                        if ~isempty(waveFormNBQX)
                            plot(x,meanNBQX,'LineWidth',4, 'color', [0 0 1 0.6]);
                        end
                        
                        scatter(0,maxY*1.1, 40, 'filled', 'MarkerFaceColor', 'black', 'MarkerFaceAlpha',alpha, 'MarkerEdgeAlpha',alpha);
                        xline(0);
                        xlim([-RAW_PRE_SPIKE_WOTHERS*1000 RAW_POST_SPIKE_WOTHERS*1000]);
                        ylim([minY*1.5 maxY*1.5]);
                        
                        legend(['id=' num2str(slaveNeuronId) ' type=' slaveNeuronType],'Color','none','Location','SouthEast');
                        ylabel('uV');
                        xlabel('Time (ms)');    
                        grid on
                        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)    
                        sgtitle(['Unit=' num2str(unit.id) ' (' unit.neuronType ' ch=' num2str(unit.ch) ')  vs Slave Unit=' num2str(slaveNeuronId) ' type=' slaveNeuronType ' Baseline(black) vs Gabazine(red) vs NBQX(blue)']); % sLocalTitle
            
                        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5); 
            
                        print([pathToWaveFormWithOtherUnits '/' 'spikeWaveForm_Bsln_Gab_NBQX_' num2str(unit.id) 'VS' num2str(slaveNeuronId) '.tif'], '-dtiff', '-r100');
                        %savefig(f,[pathToWaveFormWithOtherUnits '/' 'spikeWaveForm_RawVSFiltered_' num2str(unit.id) 'VS' num2str(slaveNeuronId) '.fig']);
                        close all;
            
                        %logger.info('readFilteredWaveFormWithOtherUnits', ['Filtered waveform Bsln_Gab_NBQX is plot for unit=' num2str(unit.id) ' VS ' num2str(slaveNeuronId)]);
                    end
                end
            end 
            logger.info('readFilteredWaveFormWithOtherUnits', ['Filtered waveform Bsln_Gab_NBQX is plot for unit=' num2str(unit.id) ' VS all its slave units']);
        else
            logger.info('readFilteredWaveFormWithOtherUnits', ['No interaction between unit=' num2str(unit.id) ' and ' num2str(UNIT_OF_INTEREST2)]);
        end
    end
end