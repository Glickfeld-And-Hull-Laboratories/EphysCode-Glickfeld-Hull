% MAIN for neural analyses
clc
clearvars
clearvars -global
close all

gpuDevice(1); % Activate GPU Device
globals;

[laserOnsetTimes, laserOffsetTimes] = init();
%%%%%%%%%%%% Read Spikes channels from SpikeGLX %%%%%%%%%%
% Extract units with its properties from only the channels inside the cerebellum
if DART_SORTED
    [unitGood, unitMua, unitNoise, recordingLengthSecs] = readDartSortedUnits();
    if UNIT_OF_INTEREST~= -1    
        uid = find([unitGood.id]==UNIT_OF_INTEREST);
        unit = unitGood(uid);
        [unit, needToSave] = readAmplitude_Layer(unit,laserOnsetTimes, laserOffsetTimes);  % No Need for this, it's gonna get for the first time of running for the whole dataset
        unitGood(uid) = unit;
    elseif ~isempty(SOME_UNITS_OF_INTEREST)
        [~,~,inds]=intersect(SOME_UNITS_OF_INTEREST,[unitGood.id],'stable');
        units = unitGood(inds);
        %units = readAmplitude_Layer(units,laserOnsetTimes, laserOffsetTimes); % No Need for this, it's gonna get for the first time of running for the whole dataset 
    else
        [unitGood, needToSave] = readAmplitude_Layer(unitGood,laserOnsetTimes, laserOffsetTimes);        
    end

else
    [unitGood, unitMua, unitNoise, recordingLengthSecs] = readUnits();    
    % TODO: Uncomment this to plot heatMap, otherwise it'll explode saying no amplitudePerChannel field!!!
    [unitGood, needToSave] = readAmplitude_Layer(unitGood,laserOnsetTimes, laserOffsetTimes);  
end

% Sort units acc. to depth - from surface to deep
unitGoodSorted = sortStruct(unitGood,'depth');
unitMuaSorted = sortStruct(unitMua,'depth');
unitNoiseSorted = sortStruct(unitNoise,'depth');
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
%unitGoodSorted = unitGoodSorted(1:5);

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
                [waveForms, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes);
                unit.waveForms = waveForms;
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
                [waveForms, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes);
                unitGoodSorted(uid).waveForms = waveForms;                
                readForTheFirstTime = 1;
            end
            plotSpikeWaveForm(unitGoodSorted(uid), unitGoodSorted(uid).waveForms, samplingRate, '');
            close all;
        end
        logger.info('main', 'Good unit waveforms are plotted!');

        for uid=1:length(unitMuaSorted)
            unit = unitMuaSorted(uid);
            if ~iscell(unit.waveForms) && unit.waveForms == UNDEFINED
                [waveForms, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes);
                unitMuaSorted(uid).waveForms = waveForms;
                readForTheFirstTime = 1;
            end
            plotSpikeWaveForm(unitMuaSorted(uid), unitMuaSorted(uid).waveForms, samplingRate, '');
            close all;
        end
        logger.info('main', 'Multi unit waveforms are plotted!');

        for uid=1:length(unitNoiseSorted)
            unit = unitNoiseSorted(uid);
            if ~iscell(unit.waveForms) && unit.waveForms == UNDEFINED
                [waveForms, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes);
                unitNoiseSorted(uid).waveForms = waveForms;
                readForTheFirstTime = 1;
            end
            plotSpikeWaveForm(unitNoiseSorted(uid), unitNoiseSorted(uid).waveForms, samplingRate, '');
            close all;
        end

        if readForTheFirstTime % If any new data appears, save it to the dataset
            [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = saveUnits({unitGoodSorted, unitMuaSorted, unitNoiseSorted});
        end
        logger.info('main', 'Noisy unit waveforms are plotted!');
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
            [unitGoodSortedTemp,unitMuaSortedTemp,unitNoiseSortedTemp] = readPlotWaveformsWDrugEffects({[unit]}, laserOnsetTimes, laserOffsetTimes);
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
        [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = readPlotWaveformsWDrugEffects({unitGoodSorted}, laserOnsetTimes, laserOffsetTimes);
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
            [singleUnit] = correlogram([unitOfInterest.id unitOfInterest.id], PAIR_TYPE_ACG, units, units, laserOnsetTimes, laserOffsetTimes);
            correlogram([unitOfInterest.id unitOfInterest.id], PAIR_TYPE_ACG, units, units, laserOnsetTimes, laserOffsetTimes, 0, MOMENT_OF_1ST_DRUG_PUT_IN, BASELINE);
            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                correlogram([unitOfInterest.id unitOfInterest.id], PAIR_TYPE_ACG, units, units, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, FIRST_DRUG);
                correlogram([unitOfInterest.id unitOfInterest.id], PAIR_TYPE_ACG, units, units, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, SECOND_DRUG);
            else
                correlogram([unitOfInterest.id unitOfInterest.id], PAIR_TYPE_ACG, units, units, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, FIRST_DRUG);
            end
            unitOfInterest.singleUnit = singleUnit;
        end

    else % plot all selected units
        readForTheFirstTime = 0;
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            [singleUnit] = correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitGoodSorted, unitGoodSorted, laserOnsetTimes, laserOffsetTimes);
            correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitGoodSorted, unitGoodSorted, laserOnsetTimes, laserOffsetTimes, 0, MOMENT_OF_1ST_DRUG_PUT_IN, BASELINE);
            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitGoodSorted, unitGoodSorted, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, FIRST_DRUG);
                correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitGoodSorted, unitGoodSorted, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, SECOND_DRUG);
            else
                correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitGoodSorted, unitGoodSorted, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, FIRST_DRUG);
            end
            if ~isfield(unitGoodSorted(uid),'singleUnit')
                readForTheFirstTime = 1;
                unitGoodSorted(uid).singleUnit = singleUnit;
            end
        end 
        logger.info('main', 'Good unit ACGs are plotted!');

        for uid=1:length(unitMuaSorted)
            unit = unitMuaSorted(uid);
            [singleUnit] = correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitMuaSorted, unitMuaSorted, laserOnsetTimes, laserOffsetTimes);
            correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitMuaSorted, unitMuaSorted, laserOnsetTimes, laserOffsetTimes, 0, MOMENT_OF_1ST_DRUG_PUT_IN, BASELINE);
            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitMuaSorted, unitMuaSorted, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, FIRST_DRUG);
                correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitMuaSorted, unitMuaSorted, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, SECOND_DRUG);
            else
                correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitMuaSorted, unitMuaSorted, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, FIRST_DRUG);
            end
            if ~isfield(unitMuaSorted(uid),'singleUnit')
                readForTheFirstTime = 1;
                unitMuaSorted(uid).singleUnit = singleUnit;
            end
        end
        logger.info('main', 'Multi unit ACGs are plotted!');

        for uid=1:length(unitNoiseSorted)
            unit = unitNoiseSorted(uid);
            [singleUnit] = correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitNoiseSorted, unitNoiseSorted, laserOnsetTimes, laserOffsetTimes);
            correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitNoiseSorted, unitNoiseSorted, laserOnsetTimes, laserOffsetTimes, 0, MOMENT_OF_1ST_DRUG_PUT_IN, BASELINE);
            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitNoiseSorted, unitNoiseSorted, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN, FIRST_DRUG);
                correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitNoiseSorted, unitNoiseSorted, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_2ND_DRUG_WASH_IN, Inf, SECOND_DRUG);
            else
                correlogram([unit.id unit.id], PAIR_TYPE_ACG, unitNoiseSorted, unitNoiseSorted, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, Inf, FIRST_DRUG);
            end
            if ~isfield(unitNoiseSorted(uid),'singleUnit')
                readForTheFirstTime = 1;
                unitNoiseSorted(uid).singleUnit = singleUnit;
            end
        end
        logger.info('main', 'Noisy unit ACGs are plotted!');

        if readForTheFirstTime % If any new data appears, save it to the dataset
            [unitGoodSorted,unitMuaSorted,unitNoiseSorted] = saveUnits({unitGoodSorted, unitMuaSorted, unitNoiseSorted});
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 4th STEP of ANALYSES : CCG %%%%%%%%%
if ismember(ANALYSIS_STEP_4,ARR_DO_ANALYSES) 
    ccgAnalyses(unitGoodSorted, unitMuaSorted, laserOnsetTimes, laserOffsetTimes);    
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

        unitGoodSorted = sortStruct(unitGood,'id');
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);
            generatePdfReport(unit.id, unit.layer, unit.depth, 'reportById.pdf');
            logger.info('main', ['Id sorted pdf report generated for good unit=' num2str(unit.id)]);
        end
        logger.info('main', 'Pdf report generated for good units sorted by Id!');
    end
end

