% MAIN for neural analyses
clc
clearvars
clearvars -global
close all

gpuDevice(1); % Activate GPU Device
globals;

needToSave = 0;
FLAG_STATIONARY_VS_RUNNING = 0; % 0-Stationary 1-Running

movingTimes = init();
%%%%%%%%%%%% Read Spikes channels from SpikeGLX %%%%%%%%%%
% Extract units with its properties from only the channels inside the cerebellum

[unitGood, unitMua, unitNoise, unitUnprocessed, unitAll, recordingLengthSecs] = readUnits();    

% TODO: Uncomment this to plot heatMap, otherwise it'll explode saying no amplitudePerChannel field!!!
% [unitGood, needToSave] = readAmplitude_Layer(unitGood); %,laserOnsetTimes, laserOffsetTimes);  

% Sort units acc. to depth - from surface to deep
unitGoodSorted = sortStruct(unitGood,'depth');
unitMuaSorted = sortStruct(unitMua,'depth');
unitNoiseSorted = sortStruct(unitNoise,'depth');
unitUnprocessedSorted = sortStruct(unitUnprocessed,'depth');
unitAllSorted = sortStruct(unitAll,'id');

clearvars unitGood unitMua unitNoise
if ~isempty(unitUnprocessedSorted)
    logger.info('main', ['Unprocessed units still exist!! So that means you need help with curation :) HERE YOU GO:']);
    printRefractorinessInterruptionNormalcy(unitAllSorted);
    logger.info('main', 'Do the manual curation and C4 CLASSIFICATION and rerun the code with no unprocessed units! ');
    return;
end

if needToSave
    [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = saveUnits({unitGoodSorted, unitMuaSorted, unitNoiseSorted});
end

createFolders([unitGoodSorted.id]);

if ~isempty(unitMuaSorted)
    createFolders([unitMuaSorted.id]);
end

if ~isempty(unitNoiseSorted)
    createFolders([unitNoiseSorted.id]);
end
%%%%%%%%%%%%%%%%%%%%%%%%% BEGINNING OF ANALYSES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%% 0th STEP of ANALYSES : Read & plot all waveforms %%%%%%%%%
if ismember(ANALYSIS_STEP_0,ARR_DO_ANALYSES) 
    samplingRate = str2double(getMetaFile().imSampRate);
    %Read raw data and waveforms
    if UNIT_OF_INTEREST~= -1    
        unit = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        if isempty(unit) && ~isempty(unitMuaSorted)
            unit = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
        end
        if isempty(unit) && ~isempty(unitNoiseSorted)
            unit = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));
        end
        if ~isempty(unit)
            if ~iscell(unit.waveForms) && unit.waveForms == UNDEFINED
                [waveForms, samplingRate, cv2] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes);
                unit.waveForms = waveForms;
                unit.cv2 = cv2;
                [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = saveUnits(unit);
            end
            plotSpikeWaveForm(unit, unit.waveForms, samplingRate, '');            
        else
            logger.info('main', ['No unit found with id=' num2str(UNIT_OF_INTEREST)]);
        end
    else % plot all selected units
        readForTheFirstTime = 0;
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);         
            if ~iscell(unit.waveForms) && unit.waveForms == UNDEFINED
                [waveForms, samplingRate, cv2] = readWaveForm(unit, [], []); %laserOnsetTimes, laserOffsetTimes);
                unitGoodSorted(uid).waveForms = waveForms;   
                unitGoodSorted(uid).cv2 = cv2;
                readForTheFirstTime = 1;
            end
            plotSpikeWaveForm(unitGoodSorted(uid), unitGoodSorted(uid).waveForms, samplingRate, '');
            close all;
        end
        logger.info('main', 'Good unit waveforms are plotted!');

%         for uid=1:length(unitMuaSorted)
%             unit = unitMuaSorted(uid);
%             if ~iscell(unit.waveForms) && unit.waveForms == UNDEFINED
%                 [waveForms, samplingRate, cv2] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes);
%                 unitMuaSorted(uid).waveForms = waveForms;
%                 unitMuaSorted(uid).cv2 = cv2;
%                 readForTheFirstTime = 1;
%             end
%             plotSpikeWaveForm(unitMuaSorted(uid), unitMuaSorted(uid).waveForms, samplingRate, '');
%             close all;
%         end
%         logger.info('main', 'Multi unit waveforms are plotted!');
% 
%         for uid=1:length(unitNoiseSorted)
%             unit = unitNoiseSorted(uid);
%             if ~iscell(unit.waveForms) && unit.waveForms == UNDEFINED
%                 [waveForms, samplingRate, cv2] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes);
%                 unitNoiseSorted(uid).waveForms = waveForms;
%                 unitNoiseSorted(uid).cv2 = cv2;
%                 readForTheFirstTime = 1;
%             end
%             plotSpikeWaveForm(unitNoiseSorted(uid), unitNoiseSorted(uid).waveForms, samplingRate, '');
%             close all;
%         end
%         logger.info('main', 'Noisy unit waveforms are plotted!');

        if readForTheFirstTime % If any new data appears, save it to the dataset
            [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = saveUnits({unitGoodSorted, unitMuaSorted, unitNoiseSorted});
        end
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 10th STEP of ANALYSES : Plot waveforms with DRUG EFFECTS %%%%%%%%%
if ismember(ANALYSIS_STEP_10,ARR_DO_ANALYSES) 
    
    %Read raw data and waveforms
    if UNIT_OF_INTEREST~= -1    
        unit = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        if isempty(unit) && ~isempty(unitMuaSorted)
            unit = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
        end
        if isempty(unit) && ~isempty(unitNoiseSorted)
            unit = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));
        end
        if ~isempty(unit)     
            [unitGoodSortedTemp,unitMuaSortedTemp,unitNoiseSortedTemp] = readPlotWaveformsWDrugEffects({[unit]});
            if ~isempty(unitGoodSortedTemp)
                unitGoodSorted = unitGoodSortedTemp;
            end
            if ~isempty(unitMuaSortedTemp)
                unitMuaSorted = unitMuaSortedTemp;
            end
            if ~isempty(unitNoiseSortedTemp)
                unitNoiseSorted = unitNoiseSortedTemp;
            end
        else
            logger.info('main', ['No unit found with id=' num2str(UNIT_OF_INTEREST)]);
        end
    else % plot all selected units                                                      unitGoodSorted,unitMuaSorted, unitNoiseSorted
        [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = readPlotWaveformsWDrugEffects({unitGoodSorted,unitMuaSorted, unitNoiseSorted});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 1st STEP of ANALYSES : Read & plot COLORED waveforms timed with other cells' spikes %%%%%%%%%
if ismember(ANALYSIS_STEP_1,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST~= -1    
        unit = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        if ~isempty(unit)
            readFilteredWaveFormWithOtherUnits(unit, unitGoodSorted, laserOnsetTimes, laserOffsetTimes);
            readFilteredWaveFormWithOtherUnits(unit, unitMuaSorted, laserOnsetTimes, laserOffsetTimes);
            readFilteredWaveFormWithOtherUnits(unit, unitNoiseSorted, laserOnsetTimes, laserOffsetTimes);
        else
            unit = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
            if ~isempty(unit)
                readFilteredWaveFormWithOtherUnits(unit, unitGoodSorted, laserOnsetTimes, laserOffsetTimes);
                readFilteredWaveFormWithOtherUnits(unit, unitMuaSorted, laserOnsetTimes, laserOffsetTimes);
                readFilteredWaveFormWithOtherUnits(unit, unitNoiseSorted, laserOnsetTimes, laserOffsetTimes);
            else
                unit = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));
                if ~isempty(unit)
                    readFilteredWaveFormWithOtherUnits(unit, unitGoodSorted, laserOnsetTimes, laserOffsetTimes);
                    readFilteredWaveFormWithOtherUnits(unit, unitMuaSorted, laserOnsetTimes, laserOffsetTimes);
                    readFilteredWaveFormWithOtherUnits(unit, unitNoiseSorted, laserOnsetTimes, laserOffsetTimes);
                end
            end
        end

    else % plot all selected units
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            %if strcmp(NEURON_TYPE_MF,unit.neuronType)
                readFilteredWaveFormWithOtherUnits(unit, unitGoodSorted, laserOnsetTimes, laserOffsetTimes);
                readFilteredWaveFormWithOtherUnits(unit, unitMuaSorted, laserOnsetTimes, laserOffsetTimes);                
%                 readFilteredWaveFormWithOtherUnits(unit, unitNoiseSorted); 
            %end
        end
        logger.info('main', 'Good units filtered waveforms are plotted!');

        for uid=1:length(unitMuaSorted)
            unit = unitMuaSorted(uid);
            readFilteredWaveFormWithOtherUnits(unit, unitGoodSorted, laserOnsetTimes, laserOffsetTimes);
            readFilteredWaveFormWithOtherUnits(unit, unitMuaSorted, laserOnsetTimes, laserOffsetTimes);
            %readFilteredWaveFormWithOtherUnits(unit, unitNoiseSorted); 
        end
        logger.info('main', 'Multi units filtered waveforms are plotted!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 1.1st STEP of ANALYSES : Read & plot & GROUP waveforms timed with other cells' spikes %%%%%%%%%
if ismember(ANALYSIS_STEP_11,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST~= -1    
        unit = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        groupFilteredWaveFormWithOtherUnits(unit, unitGoodSorted, unitMuaSorted, unitNoiseSorted);

    else % plot all selected units
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            if strcmp(NEURON_TYPE_MF,unit.neuronType)
                groupFilteredWaveFormWithOtherUnits(unit, unitGoodSorted, unitMuaSorted, unitNoiseSorted);
            end
        end
        logger.info('main', 'Good unit filtered waveforms are plotted!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 2nd STEP of ANALYSES : Another type of CCG - Raster/PSTH of main cell type timed with other slave cell type's spikes %%%%%%%%%
if ismember(ANALYSIS_STEP_2,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST~= -1    
        unit = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        [unitVSSpikeTimesForward, unitVSSpikeTimesBackward] = selectSpikesWithNeighboringUnits(unit.id, unit.spikeTimesSecs, unit.ch, unitGoodSorted, 1, 1, POST_TIME_RASTER, PRE_TIME_RASTER, laserOnsetTimes, laserOffsetTimes);
         slaveUnitForward = [unitVSSpikeTimesForward{:,1}];
         slaveUnitBackward = [unitVSSpikeTimesBackward{:,1}];
         if unique(slaveUnitForward) == unique(slaveUnitBackward)
            plotCCGwRasterPSTH(unit, unitVSSpikeTimesForward, unitVSSpikeTimesBackward);
         else
             logger.info('main', ['Found different units on forward and backward search for unit=' numstr(unit.id)]);
         end

    else % plot all selected units
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            if strcmp(NEURON_TYPE_MF,unit.neuronType)
                [unitVSSpikeTimesForward, unitVSSpikeTimesBackward] = selectSpikesWithNeighboringUnits(unit.id, unit.spikeTimesSecs, unit.ch, unitGoodSorted, 1, 1, POST_TIME_RASTER, PRE_TIME_RASTER, laserOnsetTimes, laserOffsetTimes);
                if ~isempty(unitVSSpikeTimesForward) && ~isempty(unitVSSpikeTimesBackward)
                    slaveUnitForward = [unitVSSpikeTimesForward{:,1}];
                    slaveUnitBackward = [unitVSSpikeTimesBackward{:,1}];
                    if unique(slaveUnitForward) == unique(slaveUnitBackward)
                        plotCCGwRasterPSTH(unit, unitVSSpikeTimesForward, unitVSSpikeTimesBackward);
                    else
                        logger.info('main', ['Found different units on forward and backward search for unit=' numstr(unit.id)]);
                    end
                end
            end
        end
        logger.info('main', 'Good unit filtered waveforms are plotted!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 2.1st STEP of ANALYSES : With MF and Without MF of this type of CCG - Raster/PSTH of main cell type timed with other slave cell type's spikes %%%%%%%%%
if ismember(ANALYSIS_STEP_21,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST~= -1    
        unitMaster = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        [unitVSSpikeTimesWithMaster, unitVSSpikeTimesWithoutMaster] = selectSlaveSpikesWRTMasterSpikes(unitMaster.id, unitMaster.spikeTimesSecs, unitMaster.ch, unitGoodSorted, 1, 1, POST_TIME_RASTER, PRE_TIME_RASTER);
        slaveUnitWithMaster = [unitVSSpikeTimesWithMaster{:,1}];
        if length(unique(slaveUnitWithMaster))==1
           plotCCGwRasterPSTHWMaster(unitMaster, unitVSSpikeTimesWithMaster, unitVSSpikeTimesWithoutMaster);
        else
            logger.info('main', ['ERROR: Found different units on forward and backward search for unit=' numstr(unitMaster.id)]);
        end

    else % plot all selected units
        for uid=1:length(unitGoodSorted)
            unitMaster = unitGoodSorted(uid);
            if strcmp(NEURON_TYPE_MF,unitMaster.neuronType)
                [unitVSSpikeTimesForward, unitVSSpikeTimesBackward] = selectSpikesWithNeighboringUnits(unitMaster.id, unitMaster.spikeTimesSecs, unitMaster.ch, unitGoodSorted, 1, 1, POST_TIME_RASTER, PRE_TIME_RASTER, laserOnsetTimes, laserOffsetTimes);
                if ~isempty(unitVSSpikeTimesForward) && ~isempty(unitVSSpikeTimesBackward)
                    slaveUnitForward = [unitVSSpikeTimesForward{:,1}];
                    slaveUnitBackward = [unitVSSpikeTimesBackward{:,1}];
                    if unique(slaveUnitForward) == unique(slaveUnitBackward)
                        plotCCGwRasterPSTH(unitMaster, unitVSSpikeTimesForward, unitVSSpikeTimesBackward);
                    else
                        logger.info('main', ['ERROR: Found different units on forward and backward search for unit=' numstr(unit.id)]);
                    end
                end
            end
        end
        logger.info('main', 'Good unit filtered waveforms are plotted!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 2.2nd STEP of ANALYSES : Raster & PSTH of all cells %%%%%%%%%
if ismember(ANALYSIS_STEP_22,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST~= -1    
        unit = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        if ~isempty(unit)
            [spikeTimeAlignedToLaserOn] = chunkAlignSpikeTimes(unit.spikeTimesSecs, laserOnsetTimes, laserOffsetTimes);
            plotRaster(unit, spikeTimeAlignedToLaserOn, laserOnsetTimes);
            logger.info('main', ['Good unit ' num2str(unit.id) ' raster is plotted!']);
        else
            unit = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
            if ~isempty(unit)
                [spikeTimeAlignedToLaserOn] = chunkAlignSpikeTimes(unit.spikeTimesSecs, laserOnsetTimes, laserOffsetTimes);
                plotRaster(unit, spikeTimeAlignedToLaserOn, laserOnsetTimes);
                logger.info('main', ['Multi unit ' num2str(unit.id) ' raster is plotted!']);
            else                
                unit = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));
                if ~isempty(unit)
                    [spikeTimeAlignedToLaserOn] = chunkAlignSpikeTimes(unit.spikeTimesSecs, laserOnsetTimes, laserOffsetTimes);
                    plotRaster(unit, spikeTimeAlignedToLaserOn, laserOnsetTimes);
                    logger.info('main', ['Noise unit ' num2str(unit.id) ' raster is plotted!']);
                end
            end
        end
    elseif ~isempty(SOME_UNITS_OF_INTEREST)
        for indSomeUnit=1:length(SOME_UNITS_OF_INTEREST)
            unit = unitGoodSorted(find([unitGoodSorted.id]==SOME_UNITS_OF_INTEREST(indSomeUnit)));
            if ~isempty(unit)
                [spikeTimeAlignedToLaserOn] = chunkAlignSpikeTimes(unit.spikeTimesSecs, laserOnsetTimes, laserOffsetTimes);
                plotRaster(unit, spikeTimeAlignedToLaserOn, laserOnsetTimes);
                logger.info('main', ['Good unit ' num2str(unit.id) ' raster is plotted!']);
            else
                unit = unitMuaSorted(find([unitMuaSorted.id]==SOME_UNITS_OF_INTEREST(indSomeUnit)));
                if ~isempty(unit)
                    [spikeTimeAlignedToLaserOn] = chunkAlignSpikeTimes(unit.spikeTimesSecs, laserOnsetTimes, laserOffsetTimes);
                    plotRaster(unit, spikeTimeAlignedToLaserOn, laserOnsetTimes);
                    logger.info('main', ['Multi unit ' num2str(unit.id) ' raster is plotted!']);
                else                
                    unit = unitNoiseSorted(find([unitNoiseSorted.id]==SOME_UNITS_OF_INTEREST(indSomeUnit)));
                    if ~isempty(unit)
                        [spikeTimeAlignedToLaserOn] = chunkAlignSpikeTimes(unit.spikeTimesSecs, laserOnsetTimes, laserOffsetTimes);
                        plotRaster(unit, spikeTimeAlignedToLaserOn, laserOnsetTimes);
                        logger.info('main', ['Noise unit ' num2str(unit.id) ' raster is plotted!']);
                    end
                end
            end
        end
    else % plot all selected units
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            if ~isempty(unit)
                [spikeTimeAlignedToLaserOn] = chunkAlignSpikeTimes(unit.spikeTimesSecs, laserOnsetTimes, laserOffsetTimes);
                plotRaster(unit, spikeTimeAlignedToLaserOn, laserOnsetTimes);
            end
        end
        logger.info('main', 'Good unit rasters are plotted!');

        for uid=1:length(unitMuaSorted)
            unit = unitMuaSorted(uid);
            if ~isempty(unit)
                [spikeTimeAlignedToLaserOn] = chunkAlignSpikeTimes(unit.spikeTimesSecs, laserOnsetTimes, laserOffsetTimes);
                plotRaster(unit, spikeTimeAlignedToLaserOn, laserOnsetTimes);
            end
        end
        logger.info('main', 'Multi unit rasters are plotted!');

        for uid=1:length(unitNoiseSorted)
            unit = unitNoiseSorted(uid);
            if ~isempty(unit)
                [spikeTimeAlignedToLaserOn] = chunkAlignSpikeTimes(unit.spikeTimesSecs, laserOnsetTimes, laserOffsetTimes);
                plotRaster(unit, spikeTimeAlignedToLaserOn, laserOnsetTimes);
            end
        end
        logger.info('main', 'Noise unit rasters are plotted!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 3rd STEP of ANALYSES : ACG %%%%%%%%%
if ismember(ANALYSIS_STEP_3,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST~= -1    
        unitOfInterest = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        if ~isempty(unitOfInterest) 
            units = unitGoodSorted;            
        else % If UOI cannot be found in GOOD units, it may be in MUA
            unitOfInterest = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
            if ~isempty(unitOfInterest) 
                units = unitMuaSorted;
            else % If UOI cannot be found in MUA units, it may be in Noise
                unitOfInterest = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));
                if ~isempty(unitOfInterest) 
                    units = unitNoiseSorted;
                end
            end
        end
        if ~isempty(unitOfInterest)            

            logger.info('main', ['Will plot ACG for ' unitOfInterest.neuronType '_' num2str(unitOfInterest.id) '(' num2str(unitOfInterest.depth) 'um) ']);
            
            f = figure;    
            f.Position = [globalX globalY globalW globalH]; 
            hold on;

            [singleUnit, ~, ~, ~, ~, ~, ~, refractoryViolationRate, meanRateClassic] = correlogramRateCorrected([unitOfInterest.id unitOfInterest.id], ACG, units, [], [], [], 'Classic', 'g', 1, 0);
            if ~isempty(MOMENT_OF_1ST_DRUG_PUT_IN)
                [singleUnitBsl, ~, ~, ~, ~, ~, ~, refractoryViolationRateBsl, meanRateBaseline] = correlogramRateCorrected([unitOfInterest.id unitOfInterest.id], ACG, units, 0, MOMENT_OF_1ST_DRUG_PUT_IN, [], BASELINE, 'k', 1, 0);
                % Just from out of curiosity if any single unit ACGs changing
                [singleUnitWQuiescent, ~, ~, ~, ~, ~, ~, ~, meanRateQuiescentBaseline] = correlogramRateCorrected([unitOfInterest.id unitOfInterest.id], ACG, units, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimes, 'Quiescent', 'm', 1, 0);
                if singleUnitBsl ~= singleUnitWQuiescent
                    logger.info('main', ['WOW! WHAT YOU WILL DO ABOUT IT! isolation changes with MOVING TIMES for ' unitOfInterest.neuronType '_' unitOfInterest.id '(' num2str(unitOfInterest.depth) 'um) baselineSingleUnit = ' num2str(singleUnit) ' singleUnitWQuiescent = ' num2str(singleUnitWQuiescent)]);
                end
            end
            if isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                [~, ~, ~, ~, ~, ~, ~, ~, meanRateDrug1] = correlogramRateCorrected([unitOfInterest.id unitOfInterest.id], ACG, units, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, [], FIRST_DRUG, 'r', 1, 0);
            else
                [~, ~, ~, ~, ~, ~, ~, ~, meanRateDrug1] = correlogramRateCorrected([unitOfInterest.id unitOfInterest.id], ACG, units, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, [], FIRST_DRUG, 'r', 1, 0);
                [~, ~, ~, ~, ~, ~, ~, ~, meanRateDrug2] = correlogramRateCorrected([unitOfInterest.id unitOfInterest.id], ACG, units, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, [], SECOND_DRUG, 'b', 1, 0);                
            end

            sSingle = 'Multi';
            if singleUnit
                sSingle = 'Single';
            end
            sHeader = ['ACG for ' sSingle ' Unit ' num2str(unitOfInterest.id) ' (' unitOfInterest.neuronType ') ContamRate=' num2str(refractoryViolationRate*100,'%.2f') ' %'];
            sFRs = [' FRWholeDur=' num2str(meanRateClassic,'%.0f') ' FRBsln=' num2str(meanRateBaseline,'%.0f') ' FRQBsln=' num2str(meanRateQuiescentBaseline,'%.0f') ' FRDrug=' num2str(meanRateDrug1,'%.0f')];
            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                sFRs = [sFRs ' FRDrug2=' num2str(meanRateDrug2,'%.0f')];
            end
            sFRs = [sFRs ' spk/s'];
            set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE);
            title([sHeader sFRs]);

            h = findobj(gca,'Type','line');
            yData=get(h,'Ydata');
            yMax = max([cellfun(@max,yData,UniformOutput=true)]);
            yMin = min([cellfun(@min,yData,UniformOutput=true)]);
            if ~isempty(yMin) && ~isempty(yMax) && (yMin-yMin/10)<(yMax+yMax/10)
                ylim([yMin-yMin/10 yMax+yMax/10]);
            end
            legend('All','Baseline','QuiescentBaseline','Drug');

            unitOfInterest.singleUnit = singleUnit;
            print([pathToFigureFolder num2str(unitOfInterest.id) '/ACG_' num2str(unitOfInterest.id) '.tif'], '-dtiff', '-r120');
            exportgraphics(f,[pathToFigureFolder num2str(unitOfInterest.id) '/ACG_' num2str(unitOfInterest.id) '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
            savefig([pathToFigureFolder num2str(unitOfInterest.id) '/ACG_' num2str(unitOfInterest.id) '.fig']);
            logger.info('main',[ACG ' for unit ' num2str(unitOfInterest.id) ' ContamRate=' num2str(refractoryViolationRate*100,'%.2f')  '% plotted for ' CLASSIC '/ACG_' num2str(unitOfInterest.id) '.tif']);
            close all;
        end

    else % plot all selected units
        readForTheFirstTime = 0;
        uid = 1;
        for iTemp=1:length(unitGoodSorted)
            if uid<=length(unitGoodSorted)
                unit = unitGoodSorted(uid);
    
                logger.info('main', ['Will plot ACG for ' unit.neuronType '_' num2str(unit.id) '(' num2str(unit.depth) 'um) ']);
                
                f = figure;    
                f.Position = [globalX globalY globalW globalH]; 
                hold on;
                                    
                % Update 8/13/2025: Isolation criteria changed from Baseline to All recording. Now single unit comes from all duration of recording, previously
                % it was returned from Baseline ACG function
                [singleUnit, ~, ~, ~, ~, ~, ~, refractoryViolationRate, meanRateClassic] = correlogramRateCorrected([unit.id unit.id], ACG, unitGoodSorted, [], [], [], CLASSIC, 'g', 1, 0);
                if ~isempty(MOMENT_OF_1ST_DRUG_PUT_IN)                
                    [singleUnitBsl, ~, ~, ~, ~, unitGoodSorted, readForTheFirstTime, refractoryViolationRateBsl, meanRateBaseline] = correlogramRateCorrected([unit.id unit.id], ACG, unitGoodSorted, 0, MOMENT_OF_1ST_DRUG_PUT_IN, [], BASELINE, 'k', 1, 0);
                    if readForTheFirstTime
                        needToSave = 1;
                    end
                    % Just from out of curiosity if any single unit ACGs changing
                    [singleUnitWQuiescent, ~, ~, ~, ~, ~, ~, ~, meanRateQuiescentBaseline] = correlogramRateCorrected([unit.id unit.id], ACG, unitGoodSorted, 0, MOMENT_OF_1ST_DRUG_PUT_IN, movingTimes, 'Quiescent', 'm', 1, 0);
                    if singleUnit ~= singleUnitWQuiescent
                        logger.info('main', ['WOW! WHAT YOU WILL DO ABOUT IT! isolation changes with MOVING TIMES for ' unit.neuronType '_' num2str(unit.id) '(' num2str(unit.depth) 'um) singleUnitBaseline = ' num2str(singleUnit) ' singleUnitQuiescent = ' num2str(singleUnitWQuiescent)]);
                    end
                end
                if isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                    [~, ~, ~, ~, ~, unitGoodSorted, readForTheFirstTime, ~, meanRateDrug1] = correlogramRateCorrected([unit.id unit.id], ACG, unitGoodSorted, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, [], FIRST_DRUG, 'r', 1, 0);
                    if readForTheFirstTime
                        needToSave = 1;
                    end                
                    cellLegend = {CLASSIC, BASELINE,'Quiescent',FIRST_DRUG};
                else
                    [~, ~, ~, ~, ~, unitGoodSorted, readForTheFirstTime, ~, meanRateDrug1] = correlogramRateCorrected([unit.id unit.id], ACG, unitGoodSorted, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, [], FIRST_DRUG, 'r', 1, 0);
                    if readForTheFirstTime
                        needToSave = 1;
                    end                
                    [~, ~, ~, ~, ~, unitGoodSorted, readForTheFirstTime, ~, meanRateDrug2] = correlogramRateCorrected([unit.id unit.id], ACG, unitGoodSorted, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, [], SECOND_DRUG, 'b', 1, 0);
                    if readForTheFirstTime
                        needToSave = 1;
                    end                                
                    cellLegend = {CLASSIC, BASELINE,'Quiescent',FIRST_DRUG,SECOND_DRUG};
                end

                sSingle = 'Multi';
                if singleUnit
                    sSingle = 'Single';
                end
                sHeader = ['ACG for ' sSingle ' Unit ' num2str(unit.id) ' (' unit.neuronType ') ContamRate=' num2str(refractoryViolationRate*100,'%.2f') ' %'];
                sFRs = [' FRWholeDur=' num2str(meanRateClassic,'%.0f') ' FRBsln=' num2str(meanRateBaseline,'%.0f') ' FRQBsln=' num2str(meanRateQuiescentBaseline,'%.0f') ' FRDrug=' num2str(meanRateDrug1,'%.0f')];
                if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                    sFRs = [sFRs ' FRDrug2=' num2str(meanRateDrug2,'%.0f')];
                end
                sFRs = [sFRs ' spk/s'];
                set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE);
                title([sHeader sFRs]);

                h = findobj(gca,'Type','line');
                yData=get(h,'Ydata');
                yMax = max([cellfun(@max,yData,UniformOutput=true)]);
                yMin = min([cellfun(@min,yData,UniformOutput=true)]);
                if ~isempty(yMin) && ~isempty(yMax) && (yMin-yMin/10)<(yMax+yMax/10)
                    ylim([yMin-yMin/10 yMax+yMax/10]);
                end                
                legend(cellLegend);
    
                print([pathToFigureFolder num2str(unit.id) '/ACG_' num2str(unit.id) '.tif'], '-dtiff', '-r120');
                exportgraphics(f,[pathToFigureFolder num2str(unit.id) '/ACG_' num2str(unit.id) '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
                savefig([pathToFigureFolder num2str(unit.id) '/ACG_' num2str(unit.id) '.fig']);

                logger.info('main',[ACG ' for unit ' num2str(unit.id) ' ContamRate=' num2str(refractoryViolationRate*100,'%.2f')  '% plotted for ' CLASSIC '/ACG_' num2str(unit.id) '.tif']);
                close all;
    
                if ~isfield(unitGoodSorted(uid),'singleUnit') || isempty(unitGoodSorted(uid).singleUnit) || unitGoodSorted(uid).singleUnit ~= singleUnit
                    readForTheFirstTime = 1;
                    unitGoodSorted(uid).singleUnit = singleUnit;
    
                    if singleUnit==0 % If it is not single unit - Phyllum said it was during manual curation but then you realized from its ACG it is not isolated well!
                        unitToBeRemoved = unitGoodSorted(uid); % add it into multi units
                        unitToBeRemoved = removeUnrelatedFields(unitToBeRemoved);
                        unitMuaSorted(length(unitMuaSorted)+1) = unitToBeRemoved;
                        unitGoodSorted(uid) = [];
                        uid = uid - 1;
                        logger.info('main', ['Unit ' num2str(unitToBeRemoved.id) ' removed since it was NOT a single unit!']);
                    end
                end
            end
            uid = uid + 1;
        end 
        logger.info('main', 'Good unit ACGs are plotted!');

        if readForTheFirstTime % If any new data appears, save it to the dataset
            [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = saveUnits({unitGoodSorted, unitMuaSorted, unitNoiseSorted});
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 31st STEP of ANALYSES : IDENTIFY MLIs %%%%%%%%%
if ismember(ANALYSIS_STEP_31,ARR_DO_ANALYSES) 
    [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = identifyMLIsFaster(unitGoodSorted,unitMuaSorted,unitNoiseSorted, movingTimes);
end

%%%%%%%%%%%%%%%%%%%%%%%%% 4th STEP of ANALYSES : CCG %%%%%%%%%
if ismember(ANALYSIS_STEP_4,ARR_DO_ANALYSES) 
    [needToSave, unitGoodSorted] = ccgAnalyses(unitGoodSorted, unitMuaSorted, unitNoiseSorted, movingTimes, 'Stationary');
    if needToSave % If any new data appears, save it to the dataset
            [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = saveUnits({unitGoodSorted, unitMuaSorted, unitNoiseSorted});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 40th STEP of ANALYSES : CCG with STATIONARY VS RUNNING %%%%%%%%%
if ismember(ANALYSIS_STEP_40,ARR_DO_ANALYSES) 
    FLAG_STATIONARY_VS_RUNNING = 1; % 0-Stationary 1-Running
    [needToSave, unitGoodSorted] = ccgAnalysesForStationaryVSRunning(unitGoodSorted, unitMuaSorted, unitNoiseSorted, movingTimes, 'Running');
    if needToSave % If any new data appears, save it to the dataset
            [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = saveUnits({unitGoodSorted, unitMuaSorted, unitNoiseSorted});
    end
    FLAG_STATIONARY_VS_RUNNING = 0; % 0-Stationary 1-Running
end

%%%%%%%%%%%%%%%%%%%%%%%%% 5th STEP of ANALYSES : Raster & PSTH of Master-Slave cells aligned to the laser %%%%%%%%%
if ismember(ANALYSIS_STEP_5,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST~= -1    
        unitMaster = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        [spikeTimeMasterAlignedToLaserOn] = chunkAlignSpikeTimes(unitMaster.spikeTimesSecs, laserOnsetTimes, laserOffsetTimes);        

        unit = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST2));
        [spikeTimeAlignedToLaserOn] = chunkAlignSpikeTimes(unit.spikeTimesSecs, laserOnsetTimes, laserOffsetTimes);        
        plotRasterPreTimeNoMaster(unit, spikeTimeAlignedToLaserOn, laserOnsetTimes, unitMaster, spikeTimeMasterAlignedToLaserOn)
    else % plot all selected units
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            %%%% DO STUFF 
        end
        logger.info('main', 'Good unit filtered waveforms are plotted!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 6th STEP of ANALYSES : Plot raw traces aligned to the laser onset %%%%%%%%%
if ismember(ANALYSIS_STEP_6,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST~= -1    
        unit = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        %[spikeTimesAlignedToLaserOn] = chunkAlignSpikeTimes(unit.spikeTimesSecs, laserOnsetTimesGLX, laserOffsetTimesGLX);        
       
        %plotRasterPreTimeNoMaster(unit, spikeTimeAlignedToLaserOn, laserOnsetTimesGLX, unitMaster, spikeTimeMasterAlignedToLaserOn)
        [waveForm, laserOnsetTimesPartial, samplingRate]=readRawWaveFormAligned(unit.id, unit.spikeTimesSecs, laserOnsetTimes, unit.ch, 0, MOMENT_OF_1ST_DRUG_PUT_IN, BASELINE);
        if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
            [waveForm, laserOnsetTimesPartial, samplingRate]=readRawWaveFormAligned(unit.id, unit.spikeTimesSecs, laserOnsetTimes, unit.ch, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, FIRST_DRUG);
            [waveForm, laserOnsetTimesPartial, samplingRate]=readRawWaveFormAligned(unit.id, unit.spikeTimesSecs, laserOnsetTimes, unit.ch, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, SECOND_DRUG);
        else
            [waveForm, laserOnsetTimesPartial, samplingRate]=readRawWaveFormAligned(unit.id, unit.spikeTimesSecs, laserOnsetTimes, unit.ch, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, FIRST_DRUG);
        end
    else % plot all selected units
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            [waveForm, laserOnsetTimesPartial, samplingRate]=readRawWaveFormAligned(unit.id, unit.spikeTimesSecs, laserOnsetTimes, unit.ch, 0, MOMENT_OF_1ST_DRUG_PUT_IN, BASELINE);
            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                [waveForm, laserOnsetTimesPartial, samplingRate]=readRawWaveFormAligned(unit.id, unit.spikeTimesSecs, laserOnsetTimes, unit.ch, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, FIRST_DRUG);
                [waveForm, laserOnsetTimesPartial, samplingRate]=readRawWaveFormAligned(unit.id, unit.spikeTimesSecs, laserOnsetTimes, unit.ch, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, SECOND_DRUG);
            else
                [waveForm, laserOnsetTimesPartial, samplingRate]=readRawWaveFormAligned(unit.id, unit.spikeTimesSecs, laserOnsetTimes, unit.ch, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, FIRST_DRUG);
            end
        end
        logger.info('main', 'Good unit filtered waveforms are plotted!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 7th STEP of ANALYSES : Plot raw traces aligned to the laser onset %%%%%%%%%
if ismember(ANALYSIS_STEP_7,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST~= -1    
        unit = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        readPlotWaveforms(unit.id, unit.spikeTimesSecs, unit.ch);        
    else % plot all selected units
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            if strcmp(NEURON_TYPE_MF,unit.neuronType) % Plot only MF for now!
                readPlotWaveforms(unit.id, unit.spikeTimesSecs, unit.ch);
            end
        end
        logger.info('main', 'Good unit filtered waveforms are plotted!');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%% 8th STEP of ANALYSES : Plot amplitude distribution %%%%%%%%%
if ismember(ANALYSIS_STEP_8,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST~= -1    
        unit = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        if isempty(unit)
            unit = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
            if isempty(unit)
                unit = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));                
            end
        end
        if ~isempty(unit)
            plotAmplitudeDistribution(unit, recordingLengthSecs, laserOnsetTimes, laserOffsetTimes);
            logger.info('main', ['Amplitude distribution for unit=' num2str(unit.id) ' is plotted!']);
        end
    else % plot all selected units
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            if ~isempty(unit)
                plotAmplitudeDistribution(unit, recordingLengthSecs, laserOnsetTimes, laserOffsetTimes);
            end
        end
        logger.info('main', 'Good unit amplitude distibutions are plotted!');

        for uid=1:length(unitMuaSorted)
            unit = unitMuaSorted(uid);
            if ~isempty(unit)
                plotAmplitudeDistribution(unit, recordingLengthSecs, laserOnsetTimes, laserOffsetTimes);
            end
        end
        logger.info('main', 'Multi unit amplitude distibutions are plotted!');

        for uid=1:length(unitNoiseSorted)
            unit = unitNoiseSorted(uid);
            if ~isempty(unit)
                plotAmplitudeDistribution(unit, recordingLengthSecs, laserOnsetTimes, laserOffsetTimes);
            end
        end
        logger.info('main', 'Noise unit amplitude distibutions are plotted!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 9th STEP of ANALYSES : Plot amplitude heatmap %%%%%%%%%
if ismember(ANALYSIS_STEP_9,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST~= -1    
        unit = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        if isempty(unit)
            unit = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
            if isempty(unit)
                unit = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));                
            end
        end
        if ~isempty(unit)
            plotAmplitudeHeatMap(unit);
            logger.info('main', ['Amplitude heatmap for unit=' num2str(unit.id) ' is plotted!']);
        end
    else % plot all selected units
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            if ~isempty(unit)
                plotAmplitudeHeatMap(unit);
            end
        end
        logger.info('main', 'Good unit amplitude distibutions are plotted!');

%         for uid=1:length(unitMuaSorted)
%             unit = unitMuaSorted(uid);
%             if ~isempty(unit)
%                 plotAmplitudeHeatMap(unit);
%             end
%         end
%         logger.info('main', 'Multi unit amplitude distibutions are plotted!');
% 
%         for uid=1:length(unitNoiseSorted)
%             unit = unitNoiseSorted(uid);
%             if ~isempty(unit)
%                 plotAmplitudeHeatMap(unit);
%             end
%         end
%         logger.info('main', 'Noise unit amplitude distibutions are plotted!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 97th STEP of ANALYSES : Calculate refractoriness based on Llobet 2022 %%%%%%%%%
if ismember(ANALYSIS_STEP_97,ARR_DO_ANALYSES)     
    printRefractorinessWLlobet(unitAllSorted);
end

%%%%%%%%%%%%%%%%%%%%%%%%% 98th STEP of ANALYSES : Write spike times into .mat for Wade %%%%%%%%%
if ismember(ANALYSIS_STEP_98,ARR_DO_ANALYSES) 
    if ~isempty(SOME_UNITS_OF_INTEREST)   
        indUOI = 1;
        for ind=1:length(SOME_UNITS_OF_INTEREST)
            unitOfInterest = unitGoodSorted(find([unitGoodSorted.id]==SOME_UNITS_OF_INTEREST(ind)));
            unitsOfInterest(indUOI) = unitOfInterest;            
            indUOI = indUOI+1;
        end        
        saveSpikeTimesForCollaborators(unitsOfInterest);
    else % save all selected good units        
        saveSpikeTimesForCollaborators(unitGoodSorted);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 101st STEP of ANALYSES : CCGs of SSs for Coincident vs non-coincident spiking MLIs %%%%%%%%%
if ismember(ANALYSIS_STEP_101,ARR_DO_ANALYSES)
    findTwoMLIsOnePC(unitGoodSorted);
end

%%%%%%%%%%%%%%%%%%%%%%%%% 99th STEP of ANALYSES : Write CCG data into .mat for Wade %%%%%%%%%
if ismember(ANALYSIS_STEP_99,ARR_DO_ANALYSES) 
    if ~isempty(SOME_UNITS_OF_INTEREST)   
        indUOI = 1;
        for ind=1:length(SOME_UNITS_OF_INTEREST)
            unitOfInterest = unitGoodSorted(find([unitGoodSorted.id]==SOME_UNITS_OF_INTEREST(ind)));
            unitsOfInterest(indUOI) = unitOfInterest;            
            indUOI = indUOI+1;
        end        
        [needToSave, unitGoodSorted] = saveCCGDataForCollaborators(unitsOfInterest, unitGoodSorted, movingTimes);
        if needToSave % If any new data appears, save it to the dataset
            [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = saveUnits({unitGoodSorted, unitMuaSorted, unitNoiseSorted});
        end
    else % plot all selected good units        
        [needToSave, unitGoodSorted] = saveCCGDataForCollaborators(unitGoodSorted, unitGoodSorted, movingTimes);
        if needToSave % If any new data appears, save it to the dataset
            [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = saveUnits({unitGoodSorted, unitMuaSorted, unitNoiseSorted});
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 100th STEP of ANALYSES : Generate PDF report for all cells %%%%%%%%%
if ismember(ANALYSIS_STEP_100,ARR_DO_ANALYSES) 
    
    if UNIT_OF_INTEREST~= -1
        unitOfInterest = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        if isempty(unitOfInterest) % If UOI cannot be found in GOOD units, it may be in MUA            
            unitOfInterest = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
            if isempty(unitOfInterest) % If UOI cannot be found in MUA units, it may be in Noise
                unitOfInterest = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));                
            end
        end
        if ~isempty(unitOfInterest)    
            if exist([pathToFigureFolder '/reportById_' num2str(unitOfInterest.id) '.pdf'])==2
                delete([pathToFigureFolder '/reportById_' num2str(unitOfInterest.id) '.pdf']);
            end
            generatePdfReport(unitOfInterest.id, unitOfInterest.layer, unitOfInterest.depth, ['reportById_' num2str(unitOfInterest.id) '.pdf']);
            logger.info('main', ['Pdf report generated for unit=' num2str(unitOfInterest.id)]);
        end
    elseif ~isempty(SOME_UNITS_OF_INTEREST)
        if exist([pathToFigureFolder '/reportForSpecialUnits.pdf'])==2
            delete([pathToFigureFolder '/reportForSpecialUnits.pdf']);
        end
        for indNMF=1:length(SOME_UNITS_OF_INTEREST)
            unitOfInterest = unitGoodSorted(find([unitGoodSorted.id]==SOME_UNITS_OF_INTEREST(indNMF)));
            generatePdfReport(unitOfInterest.id, unitOfInterest.layer, unitOfInterest.depth, 'reportForSpecialUnits.pdf');
            logger.info('main', ['Pdf report generated for unit=' num2str(unitOfInterest.id)]);
        end
        logger.info('main', ['reportForSpecialUnits.pdf report generated for units ']);
    else % plot all selected units
        if exist([pathToFigureFolder '/reportById.pdf'])==2
            delete([pathToFigureFolder '/reportById.pdf']);
        end
        if exist([pathToFigureFolder '/reportByDepth.pdf'])==2
            delete([pathToFigureFolder '/reportByDepth.pdf']);
        end

        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            generatePdfReport(unit.id, unit.layer, unit.depth, 'reportByDepth.pdf');
        end
        logger.info('main', 'Pdf report generated for good units sorted by depth!');

        unitGoodSorted = sortStruct(unitGoodSorted,'id');
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            generatePdfReport(unit.id, unit.layer, unit.depth, 'reportById.pdf');
            logger.info('main', ['Id sorted pdf report generated for good unit=' num2str(unit.id)]);
        end
        logger.info('main', 'Pdf report generated for good units sorted by Id!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% 41st STEP of ANALYSES : ASTN : CCGs between SS and CS %%%%%%%%%
if ismember(ANALYSIS_STEP_41,ARR_DO_ANALYSES)  % SS-CS pairs for ASTN project
    ccgAnalysesOnlySSCS(unitGoodSorted, unitMuaSorted, unitNoiseSorted);
end
%%%%%%%%%%%%%%%%%%%%%%%%% 42nd STEP of ANALYSES : ASTN : Plot raw traces aligned to the CS onset %%%%%%%%%
if ismember(ANALYSIS_STEP_42,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST_SS~=-1 && UNIT_OF_INTEREST_CS~=-1
        if UNIT_OF_INTEREST_SS~= -1    
            unitOfInterestSS = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST_SS));
            if isempty(unitOfInterestSS)
                unitOfInterestSS = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST_SS));
                if isempty(unitOfInterestSS)
                    unitOfInterestSS = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST_SS));
                    if isempty(unitOfInterestSS)
                        logger.info('ccgAnalyses', ['No unit info for UNIT_OF_INTEREST_SS id=' numstr(UNIT_OF_INTEREST_SS)]);
                        return;
                    end
                end
            end  
        end
        
        if UNIT_OF_INTEREST_CS~= -1    
            unitOfInterestCS = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST_CS));
            if isempty(unitOfInterestCS)                 
                unitOfInterestCS = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST_CS));
                if isempty(unitOfInterestCS) 
                    unitOfInterestCS = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST_CS));
                    if isempty(unitOfInterestCS)                        
                        logger.info('ccgAnalyses', ['No unit info for UNIT_OF_INTEREST_CS id=' numstr(UNIT_OF_INTEREST_CS)]);
                        return;
                    end
                end
            end
        end
        if ~isempty(unitOfInterestSS) && ~isempty(unitOfInterestCS)
            readRawData(unitOfInterestSS.id, unitOfInterestSS.spikeTimesSecs, unitOfInterestSS.ch, unitOfInterestCS.id, unitOfInterestCS.spikeTimesSecs);
            logger.info('main', 'Good unit raw waveforms are plotted!');
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 43rd STEP of ANALYSES : ASTN : Plot CV2 and FRs  %%%%%%%%%
if ismember(ANALYSIS_STEP_43,ARR_DO_ANALYSES) 
    plotCV2andFR(unitGoodSorted);
end