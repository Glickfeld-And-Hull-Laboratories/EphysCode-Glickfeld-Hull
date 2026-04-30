function [samplingRate]=readFilteredWaveFormWithOtherUnits(unit, units, laserOnsetTimes, laserOffsetTimes)

    globals;
    alpha = 0.3;
    alphaPlot = 0.03;
    alphaLower = 0.1;
    maxSweepToPlotConstant = 100;
    maxSweepToPlot = maxSweepToPlotConstant;
    
    imecMetaFiles = dir([pathNpyxFiltered '*.imec*ap.meta']);
    metaFile = imecMetaFiles(1);
    imecBinFiles = dir([pathNpyxFiltered '*tempfilt*ap.bin']);
    npyxFilteredBinFile = imecBinFiles(1);
    

    % Parse the corresponding metafile
    %imecBinFiles = dir([pathNpyxOrgDataFolder '*imec*ap.bin']);
    %imecBinFile = imecBinFiles(1);
    imecMeta = readMeta(metaFile.name, pathNpyxFiltered); %(imecBinFile.name, pathNpyxOrgDataFolder);
    samplingRate = str2double(imecMeta.imSampRate);
    nSamples = int64(floor((RAW_PRE_SPIKE_WOTHERS+RAW_POST_SPIKE_WOTHERS)*samplingRate));
    
    %nElements = min(length(unit.spikeTimesSecs), RAW_RANDOM_N); % whichever less, take that one
    %nRandSpikeTimes = randperm(length(unit.spikeTimesSecs),nElements);
    [unitVSSpikeTimes, ~] = selectSpikesWithNeighboringUnits(unit.id, unit.spikeTimesSecs, unit.ch, units, 1, 0, RAW_POST_SPIKE_WOTHERS, 0, laserOnsetTimes, laserOffsetTimes);

    if ~isempty(unitVSSpikeTimes)
        slaveUnits = unique([unitVSSpikeTimes{:,1}]);
        if UNIT_OF_INTEREST2==-1 || ismember(UNIT_OF_INTEREST2, slaveUnits)
            for iSU = 1:length(slaveUnits)
                if UNIT_OF_INTEREST2==-1 || UNIT_OF_INTEREST2==slaveUnits(iSU)
                    indSlaveUnit = find([unitVSSpikeTimes{:,1}]==slaveUnits(iSU));
                    slaveUnitVSSpikeTimes = unitVSSpikeTimes(indSlaveUnit,:);
                    slaveNeuronType = slaveUnitVSSpikeTimes{1,2};

                    startSamples = zeros(1,size(slaveUnitVSSpikeTimes,1));
                    for i=1:size(slaveUnitVSSpikeTimes,1)
                        % Get 3 ms interval of filtered data around the Master spike
                        startSec = slaveUnitVSSpikeTimes{i,3}-RAW_PRE_SPIKE_WOTHERS;
                        if startSec<0
                            startSec = 0;
                        end
                        startSamples(i) = int64(floor(startSec*samplingRate));
                    end
            
                    indsBaseline = find(startSamples<(MOMENT_OF_1ST_DRUG_PUT_IN*samplingRate));
                    if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                        indsFirstDrug = find(startSamples>(MOMENT_OF_1ST_DRUG_WASH_IN*samplingRate) & startSamples<(MOMENT_OF_2ND_DRUG_PUT_IN*samplingRate));
                        indsSecondDrug = find(startSamples>(MOMENT_OF_2ND_DRUG_WASH_IN*samplingRate));
                    else
                        indsFirstDrug = find(startSamples>(MOMENT_OF_1ST_DRUG_WASH_IN*samplingRate));
                        indsSecondDrug = [];
                    end                    
        
                    samplesBaseline = startSamples(indsBaseline);
                    samplesFirstDrug = startSamples(indsFirstDrug);
                    if ~isempty(indsSecondDrug)
                        samplesSecondDrug = startSamples(indsSecondDrug);
                    else
                        samplesSecondDrug = [];
                    end

                    % If NBQX cut out the connectivity of these two Master-Slave pairs (-or diminished), check Master unit's raw traces during NBQX time
                    samplesMasterSecondDrug = [];
                    if ~isempty(samplesSecondDrug) && length(samplesSecondDrug)<length(samplesFirstDrug)
                        masterUnitSpikeTimesSecondDrug = unit.spikeTimesSecs(unit.spikeTimesSecs>secondDrugWashIn);
                        indsToExc = find(ismember(masterUnitSpikeTimesSecondDrug, slaveUnitVSSpikeTimes{i,3})); % Find and exclude paired raw traces-slave still followed during NBQX
                        masterUnitSpikeTimesSecondDrug = masterUnitSpikeTimesSecondDrug(setdiff(1:end,indsToExc));
                        startSec = masterUnitSpikeTimesSecondDrug-RAW_PRE_SPIKE_WOTHERS;
                        startSec(startSec<0) = 0;
                        samplesMasterSecondDrug = int64(floor(startSec*samplingRate));
                    end
        
%                     waveFormRaw = readBinWRTDataType(startSamples, nSamples, unit.ch, imecRawBinFile.bytes, imecRawBinFile.name, pathToRecFolder, SIZE_OF_INT16, 'int16=>double');            
%                     waveFormDmx = readBinWRTDataType(startSamples, nSamples, unit.ch, catGT_loccar28_BinFile.bytes, catGT_loccar28_BinFile.name, pathCatGT_loccar28, SIZE_OF_INT16, 'int16=>double');                 
%             %         waveForm = readBinWRTDataType(startSamples, nSamples, unit.ch, catGTFilteredBinFile.bytes, catGTFilteredBinFile.name, pathCatGT, SIZE_OF_INT16, 'int16=>double');         
%                     %waveForm = readBinWRTDataType(startSamples, nSamples, unit.ch, filtFiltedBinFile.bytes, filtFiltedBinFile.name, pathToFilteredRec, SIZE_OF_SINGLE, 'single=>double');    
%                     %waveFormNpyxl = readBinWRTDataType(startSamples, nSamples, unit.ch, npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double');    
                    
                    waveFormBaseline =[];
                    waveFormFirstDrug = [];
                    waveFormSecondDrug = [];
                    waveFormMasterSecondDrug = [];
                    if ~isempty(samplesBaseline)
                        waveFormBaseline = readBinWRTDataType(samplesBaseline, nSamples, unit.ch, npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double');
                    end
                    if ~isempty(samplesFirstDrug)
                        waveFormFirstDrug = readBinWRTDataType(samplesFirstDrug, nSamples, unit.ch, npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double');
                    end
                    if ~isempty(samplesSecondDrug)
                        waveFormSecondDrug = readBinWRTDataType(samplesSecondDrug, nSamples, unit.ch, npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double');
                    end
                    if ~isempty(samplesMasterSecondDrug)
                        waveFormMasterSecondDrug = readBinWRTDataType(samplesMasterSecondDrug, nSamples, unit.ch, npyxFilteredBinFile.bytes, npyxFilteredBinFile.name, pathNpyxFiltered, SIZE_OF_INT16, 'int16=>double');
                    end
                            
                    x=-RAW_PRE_SPIKE_WOTHERS:1/samplingRate:RAW_POST_SPIKE_WOTHERS-1/samplingRate;
                    x=x.*1000; % convert to ms
                    
                    % Now, plot DRUG EFFECTS! Baseline VS First Drug VS Second Drug
        
                    if ~isempty(waveFormBaseline) || ~isempty(waveFormFirstDrug) || ~isempty(waveFormSecondDrug) || ~isempty(waveFormMasterSecondDrug)
                        
                        f = figure;
                        f.Position = [globalX globalY globalW globalH];     
                        hold on
                        maxY = 1;
                        minY = 300;
        
                        if ~isempty(waveFormBaseline)
                            meanBaseline = nanmean(waveFormBaseline,1);
                            baselineSample = meanBaseline(1:floor(RAW_PRE_SPIKE_WOTHERS/3*samplingRate)); % get 1/6th of the whole waveform as baseline
                            meanBaselineSample = mean(baselineSample);
                            meanBaseline = meanBaseline-meanBaselineSample;
                            maxY = max(max(meanBaseline),maxY);
                            minY = min(min(meanBaseline),minY);                    
                        end
                        if ~isempty(waveFormFirstDrug)
                            meanFirstDrug = nanmean(waveFormFirstDrug,1);
                            baselineSample = meanFirstDrug(1:floor(RAW_PRE_SPIKE_WOTHERS/3*samplingRate)); % get 1/6th of the whole waveform as baseline
                            meanBaselineSample = mean(baselineSample);
                            meanFirstDrug = meanFirstDrug-meanBaselineSample;
                            maxY = max(max(meanFirstDrug),maxY);
                            minY = min(min(meanFirstDrug),minY);                    
                        end
                        if ~isempty(waveFormSecondDrug)
                            meanSecondDrug = nanmean(waveFormSecondDrug,1);
                            baselineSample = meanSecondDrug(1:floor(RAW_PRE_SPIKE_WOTHERS/3*samplingRate)); % get 1/6th of the whole waveform as baseline
                            meanBaselineSample = mean(baselineSample);
                            meanSecondDrug = meanSecondDrug-meanBaselineSample;
                            maxY = max(max(meanSecondDrug),maxY);
                            minY = min(min(meanSecondDrug),minY);                    
                        end
                        if ~isempty(waveFormMasterSecondDrug)
                            meanMasterSecondDrug = nanmean(waveFormMasterSecondDrug,1);
                            baselineSample = meanMasterSecondDrug(1:floor(RAW_PRE_SPIKE_WOTHERS/3*samplingRate)); % get 1/6th of the whole waveform as baseline
                            meanBaselineSample = mean(baselineSample);
                            meanMasterSecondDrug = meanMasterSecondDrug-meanBaselineSample;
                            maxY = max(max(meanMasterSecondDrug),maxY);
                            minY = min(min(meanMasterSecondDrug),minY);                    
                        end
        
                        maxSweepToPlot = maxSweepToPlotConstant;
                        maxSweepToPlot = min(size(waveFormBaseline,1),maxSweepToPlot);
                        indsSweeps = randperm(size(waveFormBaseline,1), maxSweepToPlot);
                        for iBsln=1:maxSweepToPlot
                            plot(x,waveFormBaseline(indsSweeps(iBsln),:),'LineWidth',0.1, 'color', [0 0 0 alphaPlot]);
                            slaveSpikeTimes = (slaveUnitVSSpikeTimes{indsBaseline(indsSweeps(iBsln)),4} - slaveUnitVSSpikeTimes{indsBaseline(indsSweeps(iBsln)),3})*1000; % convert to ms 
                            scatter(slaveSpikeTimes,maxY*1, 40, 'filled', 'MarkerFaceColor', 'black', 'MarkerFaceAlpha',alpha, 'MarkerEdgeAlpha',alpha);
                        end
        
                        maxSweepToPlot = maxSweepToPlotConstant;
                        maxSweepToPlot = min(size(waveFormFirstDrug,1),maxSweepToPlot);
                        indsSweeps = randperm(size(waveFormFirstDrug,1), maxSweepToPlot);
                        for iGab=1:maxSweepToPlot
                            plot(x,waveFormFirstDrug(indsSweeps(iGab),:),'LineWidth',0.1, 'color', [1 0 0 alphaPlot]);
                            slaveSpikeTimes = (slaveUnitVSSpikeTimes{indsFirstDrug(indsSweeps(iGab)),4} - slaveUnitVSSpikeTimes{indsFirstDrug(indsSweeps(iGab)),3})*1000; % convert to ms 
                            scatter(slaveSpikeTimes,maxY*1.2, 40, 'filled', 'MarkerFaceColor', 'red', 'MarkerFaceAlpha',alpha, 'MarkerEdgeAlpha',alpha);
                        end
        
                        maxSweepToPlot = maxSweepToPlotConstant;
                        maxSweepToPlot = min(size(waveFormSecondDrug,1),maxSweepToPlot);
                        if ~maxSweepToPlot % Good way to catch MF-GrC pairs if slave unit doesn't follow master unit anymore during NBQX
                            logger.info('readFilteredWaveFormWithOtherUnits', ['Master unit=' num2str(unit.id) ' is NOT followed by slave unit=' num2str(slaveUnits(iSU)) ' during ' SECOND_DRUG]);
                        end        
                        indsSweeps = randperm(size(waveFormSecondDrug,1), maxSweepToPlot);
                        for iSecondDrug=1:maxSweepToPlot %size(waveFormNBQX,1)
                            plot(x,waveFormSecondDrug(indsSweeps(iSecondDrug),:),'LineWidth',0.1, 'color', [0 0 1 alphaPlot]);
                            slaveSpikeTimes = (slaveUnitVSSpikeTimes{indsSecondDrug(indsSweeps(iSecondDrug)),4} - slaveUnitVSSpikeTimes{indsSecondDrug(indsSweeps(iSecondDrug)),3})*1000; % convert to ms 
                            scatter(slaveSpikeTimes,maxY*1.4, 40, 'filled', 'MarkerFaceColor', 'blue', 'MarkerFaceAlpha',alpha, 'MarkerEdgeAlpha',alpha);
                        end
        
                        maxSweepToPlot = maxSweepToPlotConstant;
                        maxSweepToPlot = min(size(waveFormMasterSecondDrug,1),maxSweepToPlot);
                        indsSweeps = randperm(size(waveFormMasterSecondDrug,1), maxSweepToPlot);
                        for iMas=1:maxSweepToPlot
                            plot(x,waveFormMasterSecondDrug(indsSweeps(iMas),:),'LineWidth',0.1, 'color', [1 0 1 alphaPlot]);
                        end

                        plt = zeros(1,4);
                        legends = cell(1,4);
                        legendCount=1;
                        if ~isempty(waveFormBaseline)                    
                            plt(legendCount) = plot(x,meanBaseline,'LineWidth',4, 'color', [0 0 0 0.6]);
                            legends{legendCount} = ['Baseline n=' num2str(size(waveFormBaseline,1))];
                            legendCount=legendCount+1;
                        end
                        if ~isempty(waveFormFirstDrug)
                            plt(legendCount) = plot(x,meanFirstDrug,'LineWidth',4, 'color', [1 0 0 0.6]);
                            legends{legendCount} = [FIRST_DRUG ' n=' num2str(size(waveFormFirstDrug,1))];
                            legendCount=legendCount+1;
                        end
                        if ~isempty(waveFormSecondDrug)
                            plt(legendCount) = plot(x,meanSecondDrug,'LineWidth',4, 'color', [0 0 1 0.6]);
                            legends{legendCount} = [SECOND_DRUG ' n=' num2str(size(waveFormSecondDrug,1))];
                            legendCount=legendCount+1;
                        end
                        if ~isempty(waveFormMasterSecondDrug)
                            plt(legendCount) = plot(x,meanMasterSecondDrug,'LineWidth',4, 'color', [.5 0 1 0.6]);
                            legends{legendCount} = [SECOND_DRUG ' (Master unit without slave) n=' num2str(size(waveFormMasterSecondDrug,1))];                            
                            legendCount=legendCount+1;
                        end
                        plt = plt(1:legendCount-1);
                        legends=legends(1:legendCount-1);
                        
                        scatter(0,maxY*1.1, 40, 'filled', 'MarkerFaceColor', 'black');
                        xline(0);
                        xlim([-RAW_PRE_SPIKE_WOTHERS*1000 RAW_POST_SPIKE_WOTHERS*1000]);
                        ylim([minY*1.5 maxY*2.5]);
                        
                        %legend(['id=' num2str(slaveUnits(iSU)) ' type=' slaveNeuronType],'Color','none','Location','SouthEast');
                        legend(plt, legends{:},'Color','none','Location','SouthEast');
                        %ylabel('uV');
                        xlabel('Time (ms)');  
                        yticks([]);
                        set(gca,'YColor','none');
                        grid on
                        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)    
                        sgtitle(['Unit=' num2str(unit.id) ' (' unit.neuronType ' ch=' num2str(unit.ch) ')  vs Slave Unit=' num2str(slaveUnits(iSU)) ' type=' slaveNeuronType ' Baseline(black) vs ' FIRST_DRUG '(red) vs ' SECOND_DRUG '(blue)']); % sLocalTitle
            
                        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5); 
            
                        print([pathToWaveFormWithOtherUnits '/' 'spikeWaveForm_NpyxFiltered_Bsln_' FIRST_DRUG '_' SECOND_DRUG '_' num2str(unit.id) 'VS' num2str(slaveUnits(iSU)) '.tif'], '-dtiff', '-r100');
                        %savefig(f,[pathToWaveFormWithOtherUnits '/' 'spikeWaveForm_RawVSFiltered_' num2str(unit.id) 'VS' num2str(slaveUnits(iSU)) '.fig']);
                        close all;
            
                        %logger.info('readFilteredWaveFormWithOtherUnits', ['Filtered waveform Bsln_Gab_NBQX is plot for unit=' num2str(unit.id) ' VS ' num2str(slaveUnits(iSU))]);
                    end
                end
            end 
            logger.info('readFilteredWaveFormWithOtherUnits', ['Filtered waveform Bsln_' FIRST_DRUG '_' SECOND_DRUG ' is plot for unit=' num2str(unit.id) ' VS all its slave units']);
        else
            logger.info('readFilteredWaveFormWithOtherUnits', ['No interaction between unit=' num2str(unit.id) ' and ' num2str(UNIT_OF_INTEREST2)]);
        end
    end
end