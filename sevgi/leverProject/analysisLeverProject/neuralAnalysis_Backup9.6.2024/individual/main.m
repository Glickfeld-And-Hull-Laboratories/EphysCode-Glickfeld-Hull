% MAIN for neural analyses
clc
clearvars
clearvars -global
close all

globals;

[arrHitTrials, arrFaTrials, arrMissTrials, arrStimTurnedOnTrials, arrReqHoldTimes, arrReactTimes, tooFastTime, reactTime, preHoldTime, fixedHoldStartsAtTrial, ...
    leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, ...
    trialCutIndex, omissionTrials, nonOmissionTrials] = init();
trialCount = length(arrReqHoldTimes);
allTrials = [1:trialCount];
logger.info('main', ['Trial count=' num2str(trialCount) ' Hit count = ' num2str(length(arrHitTrials)) ' Fa count = ' num2str(length(arrFaTrials)) ' Miss count = ' num2str(length(arrMissTrials))]); 

reactHitCount = sum(arrHitTrials<fixedHoldStartsAtTrial);
predictHitCount = sum(arrHitTrials>=fixedHoldStartsAtTrial);
reactFaCount = sum(arrFaTrials<fixedHoldStartsAtTrial);
predictFaCount = sum(arrFaTrials>=fixedHoldStartsAtTrial);
reactMissCount = sum(arrMissTrials<fixedHoldStartsAtTrial);
predictMissCount = sum(arrMissTrials>=fixedHoldStartsAtTrial);
logger.info('main', ['Reaction trial count=' num2str(fixedHoldStartsAtTrial-1) ' Reaction Hit count = ' num2str(reactHitCount) ' Reaction Fa count = ' num2str(reactFaCount) ' Reaction Miss count = ' num2str(reactMissCount)]); 
logger.info('main', ['Prediction trial count=' num2str(trialCount-fixedHoldStartsAtTrial+1) ' Prediction Hit count = ' num2str(predictHitCount) ' Prediction Fa count = ' num2str(predictFaCount) ' Prediction Miss count = ' num2str(predictMissCount)]); 


%%%%%%%%%%%% Read Spikes channels from SpikeGLX %%%%%%%%%%
% Extract units with its properties from only the channels inside the cerebellum
[unitSingle, unitMulti, unitNoise, unitUnprocessed, unitAll] = readUnits(0);

% Sort units acc. to depth - from surface to deep
unitSingleSorted = sortStruct(unitSingle,'depth');
unitMultiSorted = sortStruct(unitMulti,'depth');
unitNoiseSorted = sortStruct(unitNoise,'depth');
unitUnprocessedSorted = sortStruct(unitUnprocessed,'depth');
unitAllSorted = sortStruct(unitAll,'id');

% To help with the curation    
if UNIT_OF_INTEREST~= -1
    unit = [];
    if ~isempty(unitSingleSorted)
        unit = unitSingleSorted(find([unitSingleSorted.id]==UNIT_OF_INTEREST));        
    end
    if isempty(unit)
        if ~isempty(unitMultiSorted)
            unit = unitMultiSorted(find([unitMultiSorted.id]==UNIT_OF_INTEREST));            
        end
        if isempty(unit)
            if ~isempty(unitNoiseSorted)
                unit = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));
            end
            if isempty(unit) && ~isempty(unitUnprocessedSorted)
                unit = unitUnprocessedSorted(find([unitUnprocessedSorted.id]==UNIT_OF_INTEREST));                
            end
        end
    end
    if isempty(unit)
        logger.info('main', ['No unit with id=' num2str(UNIT_OF_INTEREST)]);                     
        return;
    else
        printRefractorinessInterruptionNormalcy(unit, leverHoldTimes, leverReleaseTimesGLX, allTrials, fixedHoldStartsAtTrial);    
    end
elseif ~isempty(unitUnprocessedSorted)
    logger.info('main', ['Unprocessed units still exist!! So that means you need help with curation :) HERE YOU GO:']);
    printRefractorinessInterruptionNormalcy(unitAllSorted, leverHoldTimes, leverReleaseTimesGLX, allTrials, fixedHoldStartsAtTrial);    
    logger.info('main', 'Do the manual curation and C4 CLASSIFICATION and rerun the code with no unprocessed units! ');
    return;
%     % Read again after curation cos their type and group may have changed
%     [unitSingle, unitMulti, unitNoise, unitUnprocessed, unitAll] = readUnits(1);
%     
%     % Sort units acc. to depth - from surface to deep
%     unitSingleSorted = sortStruct(unitSingle,'depth');
%     unitMultiSorted = sortStruct(unitMulti,'depth');
%     unitNoiseSorted = sortStruct(unitNoise,'depth');
%     unitUnprocessedSorted = sortStruct(unitUnprocessed,'depth');
%     unitAllSorted = sortStruct(unitAll,'id');

end

if ~isempty(unitSingleSorted)
    unitSingleSortedIds = [unitSingleSorted.id];
    unitSingleSortedNeuronTypes = {unitSingleSorted.neuronType};
else
    unitSingleSortedIds = [];
    unitSingleSortedNeuronTypes = {};
end

if ~isempty(unitMultiSorted)
    unitMultiSortedIds = [unitMultiSorted.id];
    unitMultiSortedNeuronTypes = {unitMultiSorted.neuronType};
else
    unitMultiSortedIds = [];
    unitMultiSortedNeuronTypes = {};
end

if ~isempty(unitNoiseSorted)
    unitNoiseSortedIds = [unitNoiseSorted.id];
    unitNoiseSortedNeuronTypes = {unitNoiseSorted.neuronType};
else
    unitNoiseSortedIds = [];
    unitNoiseSortedNeuronTypes = {};
end

if ~isempty(unitUnprocessedSorted)
    unitUnprocessedSortedSortedIds = [unitUnprocessedSorted.id];
    unitUnprocessedSortedNeuronTypes = {unitUnprocessedSorted.neuronType};
else
    unitUnprocessedSortedSortedIds = [];
    unitUnprocessedSortedNeuronTypes = {};
end

createFolders(unitSingleSortedIds,unitSingleSortedNeuronTypes, unitMultiSortedIds,unitMultiSortedNeuronTypes, unitNoiseSortedIds,unitNoiseSortedNeuronTypes, unitUnprocessedSortedSortedIds, unitUnprocessedSortedNeuronTypes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE UNITS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
saveUnitswBehavVars(unitSingleSorted, unitMultiSorted, unitNoiseSorted, unitUnprocessedSorted, unitAllSorted, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, trialCutIndex, ...
    allTrials, arrHitTrials, arrFaTrials, arrMissTrials, arrStimTurnedOnTrials, arrReqHoldTimes, arrReactTimes, tooFastTime, reactTime, preHoldTime, fixedHoldStartsAtTrial);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BEGINNING OF ANALYSES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 0st STEP of ANALYSES :  Plot behavioral-only analyses %%%%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_0,ARR_DO_ANALYSES) % Do behavioral analyses
    plotReactTimes(arrReactTimes, arrHitTrials, arrFaTrials, arrMissTrials, arrStimTurnedOnTrials, arrReqHoldTimes, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1st STEP of ANALYSES :  Plot raster & PSTH (Qualitative) %%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_1,ARR_DO_ANALYSES) 
    unitCategory = '';
    if UNIT_OF_INTEREST~= -1
        unit = unitSingleSorted(find([unitSingleSorted.id]==UNIT_OF_INTEREST));        
        if isempty(unit)
            unit = unitMultiSorted(find([unitMultiSorted.id]==UNIT_OF_INTEREST));            
            if isempty(unit)
                unit = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));
                if isempty(unit) 
                    if ~isempty(unitUnprocessedSorted)
                        unit = unitUnprocessedSorted(find([unitUnprocessedSorted.id]==UNIT_OF_INTEREST));
                    end
                    if isempty(unit)
                        logger.info('main', ['No unit with id=' num2str(UNIT_OF_INTEREST)]); 
                    else
                        unitCategory = UNPROCESSED_UNIT;
                    end                    
                else
                    unitCategory = NOISE_UNIT;
                end
            else
                unitCategory = MULTI_UNIT;
            end
        else
            unitCategory = SINGLE_UNIT;
        end    

        if ~isempty(unit)           
            [spikeRatesHoldRandomAll{1}, spikeRatesHoldFixedAll{1}, spikeRatesHoldRandomHFM{1}, spikeRatesHoldFixedHFM{1}, spikeRatesReleaseRandomAll{1}, spikeRatesReleaseFixedAll{1}, ...
                spikeRatesReleaseRandomHFM{1}, spikeRatesReleaseFixedHFM{1}, spikeRatesTargetRandomAll{1}, spikeRatesTargetFixedAll{1}, spikeRatesTargetRandomHFM{1}, spikeRatesTargetFixedHFM{1}, ...
                responseTypeHoldFixedAll{1}, responseTypeHoldFixedHFM{1}, responseTypeReleaseFixedAll{1}, responseTypeReleaseFixedHFM{1}, responseTypeTargetFixedAll{1}, responseTypeTargetFixedHFM{1}] = ...
            plotRasterPSTH(unit, unitCategory, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials);
        end
    else % plot all selected units
            for uid=1:length(unitSingleSorted)
                unit = unitSingleSorted(uid);
                plotRasterPSTH(unit, SINGLE_UNIT, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials);
            end
    
%             for uid=1:length(unitMultiSorted)
%                 unit = unitMultiSorted(uid);
%                 plotRasterPSTH(unit, MULTI_UNIT, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials);
%             end

        if ~isempty(unitUnprocessedSorted) % If you're still curating, you may need these
            for uid=1:length(unitNoiseSorted)
                unit = unitNoiseSorted(uid);
                plotRasterPSTH(unit, NOISE_UNIT, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials);
            end
        end

        for uid=1:length(unitUnprocessedSorted)
            unit = unitUnprocessedSorted(uid);
            plotRasterPSTH(unit, UNPROCESSED_UNIT, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials);
        end
    end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2_0 st STEP of ANALYSES :  Plot ACGs (Qualitative) %%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_2_0,ARR_DO_ANALYSES) 
    acgAnalyses(unitSingleSorted, unitMultiSorted, unitNoiseSorted, unitUnprocessedSorted, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE ALL UNITS and BEHAV. VARIABLES INTO .mat FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % It only tries to save if the dataset created from Phyllum output (not loaded from previously saved data) and it runs STEP_1 and STEP_2_0 analyses with the whole neurons
% if dataSetNeedsToBeResaved || (~loaded && ismember(ANALYSIS_STEP_1,ARR_DO_ANALYSES) && ismember(ANALYSIS_STEP_2_0,ARR_DO_ANALYSES) && UNIT_OF_INTEREST== -1)
%     saveUnitswBehavVars(unitSingleSorted, unitMultiSorted, unitNoiseSorted, unitUnprocessedSorted, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, trialCutIndex, ...
%     allTrials, arrHitTrials, arrFaTrials, arrMissTrials, arrStimTurnedOnTrials, arrReqHoldTimes, arrReactTimes, tooFastTime, reactTime, preHoldTime, fixedHoldStartsAtTrial);
%     %responseTypeHoldFixedAll, responseTypeHoldFixedHFM, responseTypeReleaseFixedAll, responseTypeReleaseFixedHFM, responseTypeTargetFixedAll, responseTypeTargetFixedHFM
% 
% %         spikeRatesHoldRandomAll, spikeRatesHoldFixedAll, spikeRatesHoldRandomHFM, spikeRatesHoldFixedHFM, spikeRatesReleaseRandomAll, spikeRatesReleaseFixedAll, ...
% %                     spikeRatesReleaseRandomHFM, spikeRatesReleaseFixedHFM, spikeRatesTargetRandomAll, spikeRatesTargetFixedAll, spikeRatesTargetRandomHFM, spikeRatesTargetFixedHFM, ...
% 
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2_1 st STEP of ANALYSES :  Plot CCG pairs (Qualitative) %%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_2_1,ARR_DO_ANALYSES) 
    [suppressedPairs_CS_SS, pairs_CS_SS] = ccgAnalyses(unitSingleSorted, unitMultiSorted, preHoldTime, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials);
end

if ismember(ANALYSIS_STEP_2_1,ARR_DO_ANALYSES) && ismember(ANALYSIS_STEP_2_A,ARR_DO_ANALYSES)
    checkTwoConseqTrialsforCSSS(suppressedPairs_CS_SS, pairs_CS_SS,unitSingleSorted,'CS','SS',CS_SS,preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrMissTrials, arrFaTrials);
end

if ismember(ANALYSIS_STEP_2_1,ARR_DO_ANALYSES) && ismember(ANALYSIS_STEP_2_B,ARR_DO_ANALYSES)
    checkCSSSandBehavEventTimes(suppressedPairs_CS_SS, pairs_CS_SS,unitSingleSorted,'CS','SS',CS_SS,preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrReactTimes, arrStimTurnedOnTrials, allTrials, 'All');
    checkCSSSandBehavEventTimes(suppressedPairs_CS_SS, pairs_CS_SS,unitSingleSorted,'CS','SS',CS_SS,preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrReactTimes, arrStimTurnedOnTrials, arrHitTrials, 'Hit');
    checkCSSSandBehavEventTimes(suppressedPairs_CS_SS, pairs_CS_SS,unitSingleSorted,'CS','SS',CS_SS,preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrReactTimes, arrStimTurnedOnTrials, arrFaTrials, 'Fa');
    checkCSSSandBehavEventTimes(suppressedPairs_CS_SS, pairs_CS_SS,unitSingleSorted,'CS','SS',CS_SS,preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrReactTimes, arrStimTurnedOnTrials, arrMissTrials, 'Miss');
end

if ismember(ANALYSIS_STEP_2_1,ARR_DO_ANALYSES) && ismember(ANALYSIS_STEP_2_C,ARR_DO_ANALYSES)
    plotPairedRaster(suppressedPairs_CS_SS, pairs_CS_SS,unitSingleSorted,'CS','SS',CS_SS,preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials, 'All');
    plotPairedRaster(suppressedPairs_CS_SS, pairs_CS_SS,unitSingleSorted,'CS','SS',CS_SS,preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrHitTrials, 'Hit');
    plotPairedRaster(suppressedPairs_CS_SS, pairs_CS_SS,unitSingleSorted,'CS','SS',CS_SS,preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrFaTrials, 'Fa');
    plotPairedRaster(suppressedPairs_CS_SS, pairs_CS_SS,unitSingleSorted,'CS','SS',CS_SS,preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrMissTrials, 'Miss');    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3rd STEP of ANALYSES :  Compare FR & ISI (Quantitative) %%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_3,ARR_DO_ANALYSES) 
    if UNIT_OF_INTEREST~= -1
        unit = unitSingleSorted(find([unitSingleSorted.id]==UNIT_OF_INTEREST));
        if ~isempty(unit) 
            compareFR_ISI(unit.id, unit.neuronType, unit.layer, unit.ch, unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials, '');
            compareFR_ISI(unit.id, unit.neuronType, unit.layer, unit.ch, unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrHitTrials, 'Hit');
            compareFR_ISI(unit.id, unit.neuronType, unit.layer, unit.ch, unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrFaTrials, 'Fa');
            compareFR_ISI(unit.id, unit.neuronType, unit.layer, unit.ch, unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrMissTrials, 'Miss');
        else
            unit = unitMultiSorted(indUnit);
            if ~isempty(unit)           
                compareFR_ISI(unit.id, unit.neuronType, unit.layer, unit.ch, unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials, '');
                compareFR_ISI(unit.id, unit.neuronType, unit.layer, unit.ch, unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrHitTrials, 'Hit');
                compareFR_ISI(unit.id, unit.neuronType, unit.layer, unit.ch, unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrFaTrials, 'Fa');
                compareFR_ISI(unit.id, unit.neuronType, unit.layer, unit.ch, unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrMissTrials, 'Miss');
            else
                disp('No unit info!')
            end
        end
    else % plot all selected units
        for uid=1:length(unitSingleSorted)
            unit = unitSingleSorted(uid);
            compareFR_ISI(unit.id, unit.neuronType, unit.layer, unit.ch, unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials, '');
            compareFR_ISI(unit.id, unit.neuronType, unit.layer, unit.ch, unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrHitTrials, 'Hit');
            compareFR_ISI(unit.id, unit.neuronType, unit.layer, unit.ch, unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrFaTrials, 'Fa');
            compareFR_ISI(unit.id, unit.neuronType, unit.layer, unit.ch, unit.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrMissTrials, 'Miss');
            close all;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 4th STEP of ANALYSES : Read & plot waveform acc.to behavioral events (Qualitative) %%%%%%%%%%%%%%%%%%%%

if ismember(ANALYSIS_STEP_4,ARR_DO_ANALYSES) 
    %Read raw data and waveforms
    if UNIT_OF_INTEREST~= -1    
        unit = unitSingleSorted(find([unitSingleSorted.id]==UNIT_OF_INTEREST));
        if isempty(unit)
            unit = unitMultiSorted(find([unitMultiSorted.id]==UNIT_OF_INTEREST));            
            if isempty(unit)
                unit = unitNoiseSorted(find([unitNoiseSorted.id]==UNIT_OF_INTEREST));
                if isempty(unit)
                    unit = unitUnprocessedSorted(find([unitUnprocessedSorted.id]==UNIT_OF_INTEREST));
                    if isempty(unit)
                        logger.info('main', ['No unit with id=' num2str(UNIT_OF_INTEREST)]);
                    else
                        unitCategory = UNPROCESSED_UNIT;
                    end
                else
                    unitCategory = NOISE_UNIT;
                end
            else
                unitCategory = MULTI_UNIT;
            end
        else
            unitCategory = SINGLE_UNIT;
        end         

        if ~isempty(unit)
            [waveForms, waveFormMean, waveFormStd, samplingRate] = readRawWaveForm(unit);
            plotSpikeWaveForm(unit, unitCategory, waveForms, waveFormMean, waveFormStd, samplingRate, '');
%         readPlotWaveFormWEvents(unitWaveForm, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, allTrials, '');
%         readPlotWaveFormWEvents(unitWaveForm, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrHitTrials, 'Hit');
%         readPlotWaveFormWEvents(unitWaveForm, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrFaTrials, 'Fa');
%         readPlotWaveFormWEvents(unitWaveForm, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, arrStimTurnedOnTrials, arrMissTrials, 'Miss');
        end
    else % plot all selected units
%         for uid=1:length(unitSingleSorted)
%             unit = unitSingleSorted(uid);
%             [waveForms, waveFormMean, waveFormStd, samplingRate] = readRawWaveForm(unit);
%             plotSpikeWaveForm(unit, SINGLE_UNIT, waveForms, waveFormMean, waveFormStd, samplingRate, '');
%             close all;
%         end

        for uid=365:length(unitMultiSorted)
            unit = unitMultiSorted(uid);
            [waveForms, waveFormMean, waveFormStd, samplingRate] = readRawWaveForm(unit);
            plotSpikeWaveForm(unit, MULTI_UNIT, waveForms, waveFormMean, waveFormStd, samplingRate, '');
            close all;
        end

        if ~isempty(unitUnprocessedSorted) % If you're still curating, you may need these    
            for uid=1:length(unitNoiseSorted)
                unit = unitNoiseSorted(uid);
                [waveForms, waveFormMean, waveFormStd, samplingRate] = readRawWaveForm(unit);
                plotSpikeWaveForm(unit, NOISE_UNIT, waveForms, waveFormMean, waveFormStd, samplingRate, '');
            end
        end

        for uid=1:length(unitUnprocessedSorted)
            unit = unitUnprocessedSorted(uid);
            [waveForms, waveFormMean, waveFormStd, samplingRate] = readRawWaveForm(unit);
            plotSpikeWaveForm(unit, UNPROCESSED_UNIT, waveForms, waveFormMean, waveFormStd, samplingRate, '');
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5th STEP of ANALYSES : Reaction time based analyses %%%%%%%%%%%%%%%%%%%%
% Carried under 'all' analyses
% if ismember(ANALYSIS_STEP_5,ARR_DO_ANALYSES)
%     if UNIT_OF_INTEREST~= -1
%         unit = unitGoodSorted(find([unitGoodSorted.id]==UNIT_OF_INTEREST));
%         if ~isempty(unit) 
%             checkNeuralChangeswrtReactionTime(unit, arrReactTimes, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials);        
%         else
%             unit = unitMuaSorted(indUnit);
%             if ~isempty(unit)           
%                 checkNeuralChangeswrtReactionTime(unit, arrReactTimes, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials);
%             else
%                 disp('No unit info!')
%             end
%         end
%     else % plot all selected units
%         checkNeuralChangeswrtReactionTime(unitGoodSorted, arrReactTimes, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials);
%     end
%     
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 6th STEP of ANALYSES : Lick related activity analyses %%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_6,ARR_DO_ANALYSES)
    if UNIT_OF_INTEREST~= -1
        unit = unitSingleSorted(find([unitSingleSorted.id]==UNIT_OF_INTEREST));
        if ~isempty(unit) 
            checkNeuralChangeswrtLicks(unit, arrReactTimes, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials, omissionTrials, nonOmissionTrials);
        else
            unit = unitMultiSorted(indUnit);
            if ~isempty(unit)
                checkNeuralChangeswrtLicks(unit, arrReactTimes, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials, omissionTrials, nonOmissionTrials);
            else
                disp('No unit info!')
            end
        end
    else % plot all selected units
        for uid=1:length(unitSingleSorted)
            unit = unitSingleSorted(uid);
            checkNeuralChangeswrtLicks(unit, arrReactTimes, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials, omissionTrials, nonOmissionTrials);
            close all;
        end
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 7th STEP of ANALYSES : Omission vs Rewarded Trials and related activity change %%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_7,ARR_DO_ANALYSES)
    if UNIT_OF_INTEREST~= -1
        unit = unitSingleSorted(find([unitSingleSorted.id]==UNIT_OF_INTEREST));
        if ~isempty(unit) 
            checkNeuralChangeswrtRewardedVsOmissionTrials(unit, arrReactTimes, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials, omissionTrials, nonOmissionTrials);
        else
            unit = unitMultiSorted(indUnit);
            if ~isempty(unit)
                checkNeuralChangeswrtRewardedVsOmissionTrials(unit, arrReactTimes, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials, omissionTrials, nonOmissionTrials);
            else
                disp('No unit info!')
            end
        end
    else % plot all selected units
        for uid=1:length(unitSingleSorted)
            unit = unitSingleSorted(uid);
            checkNeuralChangeswrtRewardedVsOmissionTrials(unit, arrReactTimes, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials, omissionTrials, nonOmissionTrials);
            close all;
        end
    end    
end