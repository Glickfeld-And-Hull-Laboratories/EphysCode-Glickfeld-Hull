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
        unitGood = readBestChannel_Amplitude_Layer(unit,laserOnsetTimes, laserOffsetTimes); 
    elseif ~isempty(SOME_UNITS_OF_INTEREST)
        [~,~,inds]=intersect(SOME_UNITS_OF_INTEREST,[unitGood.id],'stable');
        units = unitGood(inds);
        unitGood = readBestChannel_Amplitude_Layer(units,laserOnsetTimes, laserOffsetTimes); 
    else
        unitGood = readBestChannel_Amplitude_Layer(unitGood,laserOnsetTimes, laserOffsetTimes);
        success = saveUnits(unitGood,0);
    end

else
    [unitGood, unitMua, unitNoise, recordingLengthSecs] = readUnits();
    success = saveUnits(unitGood,0);
end

% Sort units acc. to depth - from surface to deep
unitGoodSorted = sortStruct(unitGood,'depth');
unitMuaSorted = sortStruct(unitMua,'depth');
unitNoiseSorted = sortStruct(unitNoise,'depth');

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
            if ~isfield(unit,'waveForms')
                [chMatrix, waveForms, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes);
                unit.waveForms = waveForms;
                success = saveUnits(unit,1);
            end
            plotSpikeWaveForm(unit, chMatrix, waveForms, samplingRate, '');            
        else
            logger.info('main', ['No unit found with id=' num2str(UNIT_OF_INTEREST)]);
        end
    else % plot all selected units
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);         
            if ~isfield(unit,'waveForms')
                [chMatrix, waveForms, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes);
                unit.waveForms = waveForms;
                success = saveUnits(unit,1);
            end
            plotSpikeWaveForm(unit, chMatrix, unit.waveForms, samplingRate, '');
            close all;
        end
        logger.info('main', 'Good unit waveforms are plotted!');

        for uid=1:length(unitMuaSorted)
            unit = unitMuaSorted(uid);
            if ~isfield(unit,'waveForms')
                [chMatrix, waveForms, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes);
                unit.waveForms = waveForms;
                success = saveUnits(unit,1);
            end
            plotSpikeWaveForm(unit, chMatrix, unit.waveForms, samplingRate, '');
            close all;
        end
        logger.info('main', 'Multi unit waveforms are plotted!');

        for uid=1:length(unitNoiseSorted)
            unit = unitNoiseSorted(uid);
            if ~isfield(unit,'waveForms')
                [chMatrix, waveForms, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes);
                unit.waveForms = waveForms;
                success = saveUnits(unit,1);
            end
            plotSpikeWaveForm(unit, chMatrix, unit.waveForms, samplingRate, '');
            close all;
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
            if ~isfield(unit,'waveFormsBaseline')
                [chMatrix, waveFormsBaseline, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, 0, MOMENT_OF_1ST_DRUG_PUT_IN);
                unit.waveFormsBaseline = waveFormsBaseline;
                success = saveUnits(unit,1);
            end

%             if ~all(all(cellfun(@isempty,unit.waveFormsBaseline)))
%                 plotSpikeWaveForm(unit, chMatrix, unit.waveFormsBaseline, samplingRate, BASELINE);
%             end
            
            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                if ~isfield(unit,'waveForms1stDrug')
                    [chMatrix, waveForms1stDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN);
                    unit.waveForms1stDrug = waveForms1stDrug;
                    success = saveUnits(unit,1);
                end
%                 if ~all(all(cellfun(@isempty,unit.waveForms1stDrug)))
%                     plotSpikeWaveForm(unit, chMatrix, unit.waveForms1stDrug, samplingRate, FIRST_DRUG);
%                 end

                if ~isfield(unit,'waveForms2ndDrug')
                    [chMatrix, waveForms2ndDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_2ND_DRUG_WASH_IN, Inf);
                    unit.waveForms2ndDrug = waveForms2ndDrug;
                    success = saveUnits(unit,1);
                end
%                 
%                 if ~all(all(cellfun(@isempty,unit.waveForms2ndDrug)))
%                     plotSpikeWaveForm(unit, chMatrix, unit.waveForms2ndDrug, samplingRate, SECOND_DRUG);
%                 end
                allWaveForms = {unit.waveFormsBaseline, unit.waveForms1stDrug, unit.waveForms2ndDrug};
                plotMultipleSpikeWaveForm(unit, chMatrix, allWaveForms, samplingRate, {BASELINE, FIRST_DRUG, SECOND_DRUG});
            else
                if ~isfield(unit,'waveForms1stDrug')
                    [chMatrix, waveForms1stDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, Inf);
                    unit.waveForms1stDrug = waveForms1stDrug;
                    success = saveUnits(unit,1);
                end
                
%                 if ~all(all(cellfun(@isempty,unit.waveForms1stDrug)))
%                     plotSpikeWaveForm(unit, chMatrix, unit.waveForms1stDrug, samplingRate, FIRST_DRUG);
%                 end
                allWaveForms = {unit.waveFormsBaseline, unit.waveForms1stDrug};
                plotMultipleSpikeWaveForm(unit, chMatrix, allWaveForms, samplingRate, {BASELINE, FIRST_DRUG});
            end
        else
            logger.info('main', ['No unit found with id=' num2str(UNIT_OF_INTEREST)]);
        end
    else % plot all selected units
        readPlotWaveformsWDrugEffects();
        
        for uid=1:length(unitGoodSorted)
            unit = unitGoodSorted(uid);    
            if ~isfield(unit,'waveFormsBaseline')
                [chMatrix, waveFormsBaseline, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, 0, MOMENT_OF_1ST_DRUG_PUT_IN);
                unit.waveFormsBaseline = waveFormsBaseline;
                success = saveUnits(unit,1);
            end
%             if ~all(all(cellfun(@isempty,unit.waveFormsBaseline)))
%                 plotSpikeWaveForm(unit, chMatrix, unit.waveFormsBaseline, samplingRate, BASELINE);
%             end

            if isempty(MOMENT_OF_2ND_DRUG_PUT_IN) % Only one drug applied during recording
                secondMoment = Inf;
            else
                secondMoment = MOMENT_OF_2ND_DRUG_PUT_IN;
            end

            if ~isfield(unit,'waveForms1stDrug')
                [chMatrix, waveForms1stDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, secondMoment);
                unit.waveForms1stDrug = waveForms1stDrug;
                success = saveUnits(unit,1);
            end
%                 if ~all(all(cellfun(@isempty,unit.waveForms1stDrug)))
%                     plotSpikeWaveForm(unit, chMatrix, unit.waveForms1stDrug, samplingRate, FIRST_DRUG);
%                 end            

            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN) && ~isfield(unit,'waveForms2ndDrug')
                [chMatrix, waveForms2ndDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_2ND_DRUG_WASH_IN, Inf);
                unit.waveForms2ndDrug = waveForms2ndDrug;
                success = saveUnits(unit,1);
%                 if ~all(all(cellfun(@isempty,unit.waveForms2ndDrug)))
%                     plotSpikeWaveForm(unit, chMatrix, unit.waveForms2ndDrug, samplingRate, SECOND_DRUG);
%                 end

                allWaveForms = {unit.waveFormsBaseline, unit.waveForms1stDrug, unit.waveForms2ndDrug};
                plotMultipleSpikeWaveForm(unit, chMatrix, allWaveForms, samplingRate, {BASELINE, FIRST_DRUG, SECOND_DRUG});
            elseif isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                allWaveForms = {unit.waveFormsBaseline, unit.waveForms1stDrug};
                plotMultipleSpikeWaveForm(unit, chMatrix, allWaveForms, samplingRate, {BASELINE, FIRST_DRUG});
            end
            
% %                 if ~all(all(cellfun(@isempty,unit.waveForms1stDrug)))
% %                     plotSpikeWaveForm(unitWaveForm, chMatrix, unit.waveForms1stDrug, samplingRate, FIRST_DRUG);
% %                 end
% 
%             if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
%                 if ~isfield(unit,'waveForms1stDrug')
%                     [chMatrix, waveForms1stDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN);
%                     unit.waveForms1stDrug = waveForms1stDrug;
%                     success = saveUnits(unit,1);
%                 end                
% %                 if ~all(all(cellfun(@isempty,unit.waveForms1stDrug)))
% %                     plotSpikeWaveForm(unit, chMatrix, unit.waveForms1stDrug, samplingRate, FIRST_DRUG);
% %                 end
%     
%                 if ~isfield(unit,'waveForms2ndDrug')
%                     [chMatrix, waveForms2ndDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_2ND_DRUG_WASH_IN, Inf);
%                     unit.waveForms2ndDrug = waveForms2ndDrug;
%                     success = saveUnits(unit,1);
%                 end
%                 
% %                 if ~all(all(cellfun(@isempty,unit.waveForms2ndDrug)))
% %                     plotSpikeWaveForm(unit, chMatrix, unit.waveForms2ndDrug, samplingRate, SECOND_DRUG);
% %                 end
%                 allWaveForms = {unit.waveFormsBaseline, unit.waveForms1stDrug, unit.waveForms2ndDrug};
%                 plotMultipleSpikeWaveForm(unit, chMatrix, allWaveForms, samplingRate, {BASELINE, FIRST_DRUG, SECOND_DRUG});
%             else
%                 if ~isfield(unit,'waveForms1stDrug')
%                     [chMatrix, waveForms1stDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, Inf);
%                     unit.waveForms1stDrug = waveForms1stDrug;
%                     success = saveUnits(unit,1);
%                 end
%                 
% %                 if ~all(all(cellfun(@isempty,unit.waveForms1stDrug)))
% %                     plotSpikeWaveForm(unitWaveForm, chMatrix, unit.waveForms1stDrug, samplingRate, FIRST_DRUG);
% %                 end
%     
%                 allWaveForms = {unit.waveFormsBaseline, unit.waveForms1stDrug};
%                 plotMultipleSpikeWaveForm(unit, chMatrix, allWaveForms, samplingRate, {BASELINE, FIRST_DRUG});
%             end
            close all;
        end
        logger.info('main', 'Good unit waveforms are plotted!');

        for uid=1:length(unitMuaSorted)
            unit = unitMuaSorted(uid);
            [chMatrix, waveFormsBaseline, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, 0, MOMENT_OF_1ST_DRUG_PUT_IN);
            
            if ~all(all(cellfun(@isempty,waveFormsBaseline)))
                plotSpikeWaveForm(unit, chMatrix, waveFormsBaseline, samplingRate, BASELINE);
            end
            
            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                [chMatrix, waveForms1stDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN);
                
                if ~all(all(cellfun(@isempty,waveForms1stDrug)))
                    plotSpikeWaveForm(unit, chMatrix, waveForms1stDrug, samplingRate, FIRST_DRUG);
                end
    
                [chMatrix, waveForms2ndDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_2ND_DRUG_WASH_IN, Inf);
                
                if ~all(all(cellfun(@isempty,waveForms2ndDrug)))
                    plotSpikeWaveForm(unit, chMatrix, waveForms2ndDrug, samplingRate, SECOND_DRUG);
                end
                allWaveForms = {waveFormsBaseline, waveForms1stDrug, waveForms2ndDrug};
                plotMultipleSpikeWaveForm(unit, chMatrix, allWaveForms, samplingRate, {BASELINE, FIRST_DRUG, SECOND_DRUG});
            else
                [chMatrix, waveForms1stDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, Inf);
                
                if ~all(all(cellfun(@isempty,waveForms1stDrug)))
                    plotSpikeWaveForm(unit, chMatrix, waveForms1stDrug, samplingRate, FIRST_DRUG);
                end
                allWaveForms = {waveFormsBaseline, waveForms1stDrug};
                plotMultipleSpikeWaveForm(unit, chMatrix, allWaveForms, samplingRate, {BASELINE, FIRST_DRUG});
            end
            close all;
        end
        logger.info('main', 'Multi unit waveforms are plotted!');

        for uid=1:length(unitNoiseSorted)
            unit = unitNoiseSorted(uid);
            [chMatrix, waveFormsBaseline, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, 0, MOMENT_OF_1ST_DRUG_PUT_IN);
            
            if ~all(all(cellfun(@isempty,waveFormsBaseline)))
                plotSpikeWaveForm(unit, chMatrix, waveFormsBaseline, samplingRate, BASELINE);
            end
            if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
                [chMatrix, waveForms1stDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, MOMENT_OF_2ND_DRUG_PUT_IN);
                if ~all(all(cellfun(@isempty,waveForms1stDrug)))
                    plotSpikeWaveForm(unit, chMatrix, waveForms1stDrug, samplingRate, FIRST_DRUG);
                end
    
                [chMatrix, waveForms2ndDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_2ND_DRUG_WASH_IN, Inf);
                if ~all(all(cellfun(@isempty,waveForms2ndDrug)))
                    plotSpikeWaveForm(unit, chMatrix, waveForms2ndDrug, samplingRate, SECOND_DRUG);
                end
                allWaveForms = {waveFormsBaseline, waveForms1stDrug, waveForms2ndDrug};
                plotMultipleSpikeWaveForm(unit, chMatrix, allWaveForms, samplingRate, {BASELINE, FIRST_DRUG, SECOND_DRUG});
            else
                [chMatrix, waveForms1stDrug, samplingRate] = readWaveForm(unit, laserOnsetTimes, laserOffsetTimes, MOMENT_OF_1ST_DRUG_WASH_IN, Inf);
                
                if ~all(all(cellfun(@isempty,waveForms1stDrug)))
                    plotSpikeWaveForm(unit, chMatrix, waveForms1stDrug, samplingRate, FIRST_DRUG);
                end    
                allWaveForms = {waveFormsBaseline, waveForms1stDrug};
                plotMultipleSpikeWaveForm(unit, chMatrix, allWaveForms, samplingRate, {BASELINE, FIRST_DRUG});
            end
            close all;
        end
        logger.info('main', 'Noisy unit waveforms are plotted!');
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
            unitGoodSorted(uid).singleUnit = singleUnit;
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
            unitMuaSorted(uid).singleUnit = singleUnit;
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
            unitNoiseSorted(uid).singleUnit = singleUnit;
        end
        logger.info('main', 'Noisy unit ACGs are plotted!');

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

        for uid=1:length(unitMuaSorted)
            unit = unitMuaSorted(uid);
            if ~isempty(unit)
                plotAmplitudeHeatMap(unit);
            end
        end
        logger.info('main', 'Multi unit amplitude distibutions are plotted!');

        for uid=1:length(unitNoiseSorted)
            unit = unitNoiseSorted(uid);
            if ~isempty(unit)
                plotAmplitudeHeatMap(unit);
            end
        end
        logger.info('main', 'Noise unit amplitude distibutions are plotted!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%% 100th STEP of ANALYSES : Generate PDF report for all cells %%%%%%%%%
if ismember(ANALYSIS_STEP_100,ARR_DO_ANALYSES) 
    if exist([pathToFigureFolder '/reportById.pdf'])==2
        delete([pathToFigureFolder '/reportById.pdf']);
    end
    if exist([pathToFigureFolder '/reportByDepth.pdf'])==2
        delete([pathToFigureFolder '/reportByDepth.pdf']);
    end
    if exist([pathToFigureFolder '/reportForSpecialUnits.pdf'])==2
        delete([pathToFigureFolder '/reportForSpecialUnits.pdf']);
    end

    if UNIT_OF_INTEREST~= -1
        unitOfInterest = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
        if isempty(unitOfInterest) % If UOI cannot be found in GOOD units, it may be in MUA            
            unitOfInterest = unitMuaSorted(find([unitMuaSorted.id]==UNIT_OF_INTEREST));
            if isempty(unitOfInterest) % If UOI cannot be found in MUA units, it may be in Noise
                unitOfInterest = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));                
            end
        end
        if ~isempty(unitOfInterest)    
            generatePdfReport(unitOfInterest.id, unitOfInterest.layer, unitOfInterest.depth, 'reportById.pdf');
            logger.info('main', ['Pdf report generated for unit=' num2str(unitOfInterest.id)]);
        end
    elseif ~isempty(SOME_UNITS_OF_INTEREST)
        for indNMF=1:length(SOME_UNITS_OF_INTEREST)
            unitOfInterest = unitGoodSorted(find([unitGoodSorted.id]==SOME_UNITS_OF_INTEREST(indNMF)));
            generatePdfReport(unitOfInterest.id, unitOfInterest.layer, unitOfInterest.depth, 'reportForSpecialUnits.pdf');
            logger.info('main', ['Pdf report generated for unit=' num2str(unitOfInterest.id)]);
        end
        logger.info('main', ['reportForSpecialUnits.pdf report generated for units ']);
    else % plot all selected units
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

