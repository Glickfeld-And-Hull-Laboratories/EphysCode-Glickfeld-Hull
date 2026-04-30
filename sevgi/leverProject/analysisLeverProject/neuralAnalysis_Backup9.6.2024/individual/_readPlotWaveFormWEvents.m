function [waveFormMean, waveFormMin, waveFormMax, samplingRate]=readPlotWaveFormWEvents(unit, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrStimTurnedOnTrials, arrSelectedTrials, strTrialType)

    globals;
    trialCount = length(leverHoldTimes);
    
    imecBinFiles = dir([pathNpyxFiltered '*imec*300*ap.bin']); % do NOT forget to put its meta file with same name
    npyxFilteredFile = imecBinFiles(1);

    %Parse the corresponding metafile
    %imecBinFiles = dir([pathNpyxOrgDataFolder '*imec*ap.bin']);
    %imecBinFile = imecBinFiles(1);
    imecMeta = readMeta(npyxFilteredFile.name, pathNpyxFiltered); %(imecBinFile.name, pathNpyxOrgDataFolder);
    samplingRate = str2double(imecMeta.imSampRate);
    nSamples = int64(floor((RAW_PRE_SPIKE+RAW_POST_SPIKE)*samplingRate));


    spikeTimesHold = {};
    spikeTimesRelease = {};
    spikeTimesTarget = {};
    spikeTimesBaseline = {};

    logger.info('readPlotWaveFormWEvents', ['readPlotWaveFormWEvents is started for unit=' num2str(unit.id)]);

    for indTrial=1:trialCount
            %get spikeTimes between hold and release
            if isempty(arrSelectedTrials) || (~isempty(arrSelectedTrials) && ismember(indTrial,arrSelectedTrials))
                trSpikeTimesHold = unit.spikeTimesSecs(unit.spikeTimesSecs>(leverHoldTimes(indTrial)-PRE_TIME_HOLD) & unit.spikeTimesSecs<(leverHoldTimes(indTrial)+POST_TIME_HOLD));
                spikeTimesHold(indTrial) = {trSpikeTimesHold};

                trSpikeTimesRelease = unit.spikeTimesSecs(unit.spikeTimesSecs>(leverReleaseTimesGLX(indTrial)-PRE_TIME_RELEASE) & unit.spikeTimesSecs<(leverReleaseTimesGLX(indTrial)+POST_TIME_RELEASE));
                spikeTimesRelease(indTrial) = {trSpikeTimesRelease};

                %get if any visual stim change happened between lever hold and release of this trial    
                if any(arrStimTurnedOnTrials==indTrial) % if target visual stim turned on in this trial
                    indVisStimOnTrial = find(arrStimTurnedOnTrials==indTrial);

                    trSpikeTimesTargetStimChange = unit.spikeTimesSecs(unit.spikeTimesSecs>(targetVisStimChangeTimeGLX(indVisStimOnTrial)-PRE_TIME_VIS_STIM) & unit.spikeTimesSecs<(targetVisStimChangeTimeGLX(indVisStimOnTrial)+POST_TIME_VIS_STIM));
                    spikeTimesTarget(indTrial) = {trSpikeTimesTargetStimChange};

                    trSpikeTimesBaselineStimChange = unit.spikeTimesSecs(unit.spikeTimesSecs>(baselineVisStimChangeTimeGLX(indVisStimOnTrial)-PRE_TIME_VIS_STIM) & unit.spikeTimesSecs<(baselineVisStimChangeTimeGLX(indVisStimOnTrial)+POST_TIME_VIS_STIM));
                    spikeTimesBaseline(indTrial) = {trSpikeTimesBaselineStimChange};
                else
                    spikeTimesTarget(indTrial) = {[]};
                    spikeTimesBaseline(indTrial) = {[]};
                end
            end
    end

    if fixedHoldStartsAtTrial>0 % if session is mixed with random/fixed trials
        spikeTimesRandHold = spikeTimesHold(1:fixedHoldStartsAtTrial-1);
        spikeTimesFixedHold = spikeTimesHold(fixedHoldStartsAtTrial:end);

        spikeTimesRandRelease = spikeTimesRelease(1:fixedHoldStartsAtTrial-1);
        spikeTimesFixedRelease = spikeTimesRelease(fixedHoldStartsAtTrial:end);

        spikeTimesRandTarget = spikeTimesTarget(1:fixedHoldStartsAtTrial-1);
        spikeTimesFixedTarget = spikeTimesTarget(fixedHoldStartsAtTrial:end);

        spikeTimesRandBaseline = spikeTimesBaseline(1:fixedHoldStartsAtTrial-1);
        spikeTimesFixedBaseline = spikeTimesBaseline(fixedHoldStartsAtTrial:end);

    else
        spikeTimesRandHold = spikeTimesHold; % All random trials
        spikeTimesRandRelease = spikeTimesRelease;
        spikeTimesRandTarget = spikeTimesTarget;
        spikeTimesRandBaseline = spikeTimesBaseline;
    end
    
    [spikeTimesRandHold1, spikeTimesRandHold2, spikeTimesRandHold3] = trialDivider(spikeTimesRandHold);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesRandHold1, unit.ch);    
    logger.info('readPlotWaveFormWEvents', ['read RandHold1 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesRandHold1)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['RandHold1' strTrialType]);    
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesRandHold2, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read RandHold2 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesRandHold2)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['RandHold2' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesRandHold3, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read RandHold3 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesRandHold3)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['RandHold3' strTrialType]);

    [spikeTimesFixedHold1, spikeTimesFixedHold2, spikeTimesFixedHold3] = trialDivider(spikeTimesFixedHold);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesFixedHold1, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read FixedHold1 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesFixedHold1)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['FixedHold1' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesFixedHold2, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read FixedHold2 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesFixedHold2)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['FixedHold2' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesFixedHold3, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read FixedHold3 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesFixedHold3)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['FixedHold3' strTrialType]);

    [spikeTimesRandRelease1, spikeTimesRandRelease2, spikeTimesRandRelease3] = trialDivider(spikeTimesRandRelease);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesRandRelease1, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read RandRelease1 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesRandRelease1)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['RandRelease1' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesRandRelease2, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read RandRelease2 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesRandRelease2)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['RandRelease2' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesRandRelease3, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read RandRelease3 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesRandRelease3)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['RandRelease3' strTrialType]);

    [spikeTimesFixedRelease1, spikeTimesFixedRelease2, spikeTimesFixedRelease3] = trialDivider(spikeTimesFixedRelease);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesFixedRelease1, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read FixedRelease1 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesFixedRelease1)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['FixedRelease1' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesFixedRelease2, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read FixedRelease2 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesFixedRelease2)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['FixedRelease2' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesFixedRelease3, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read FixedRelease3 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesFixedRelease3)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['FixedRelease3' strTrialType]);

    [spikeTimesRandTarget1, spikeTimesRandTarget2, spikeTimesRandTarget3] = trialDivider(spikeTimesRandTarget);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesRandTarget1, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read RandTarget1 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesRandTarget1)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['RandTarget1' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesRandTarget2, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read RandTarget2 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesRandTarget2)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['RandTarget2' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesRandTarget3, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read RandTarget3 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesRandTarget3)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['RandTarget3' strTrialType]);

    [spikeTimesFixedTarget1, spikeTimesFixedTarget2, spikeTimesFixedTarget3] = trialDivider(spikeTimesFixedTarget);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesFixedTarget1, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read FixedTarget1 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesFixedTarget1)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['FixedTarget1' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesFixedTarget2, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read FixedTarget2 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesFixedTarget2)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['FixedTarget2' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesFixedTarget3, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read FixedTarget3 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesFixedTarget3)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['FixedTarget3' strTrialType]);

    [spikeTimesRandBaseline1, spikeTimesRandBaseline2, spikeTimesRandBaseline3] = trialDivider(spikeTimesRandBaseline);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesRandBaseline1, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read RandBaseline1 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesRandBaseline1)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['RandBaseline1' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesRandBaseline2, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read RandBaseline2 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesRandBaseline2)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['RandBaseline2' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesRandBaseline3, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read RandBaseline3 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesRandBaseline3)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['RandBaseline3' strTrialType]);

    [spikeTimesFixedBaseline1, spikeTimesFixedBaseline2, spikeTimesFixedBaseline3] = trialDivider(spikeTimesFixedBaseline);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesFixedBaseline1, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read FixedBaseline1 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesFixedBaseline1)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['FixedBaseline1' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesFixedBaseline2, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read FixedBaseline2 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesFixedBaseline2)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['FixedBaseline2' strTrialType]);
    [waveFormMean, waveFormMin, waveFormMax, samplingRate] = readRawWaveFormPerTrial(spikeTimesFixedBaseline3, unit.ch);
    logger.info('readPlotWaveFormWEvents', ['read FixedBaseline3 for unit=' num2str(unit.id) ' for ' num2str(length(spikeTimesFixedBaseline3)) ' trials']);
    plotSpikeWaveForm(unit, waveFormMean, waveFormMin, waveFormMax, samplingRate, ['FixedBaseline3' strTrialType]);
end