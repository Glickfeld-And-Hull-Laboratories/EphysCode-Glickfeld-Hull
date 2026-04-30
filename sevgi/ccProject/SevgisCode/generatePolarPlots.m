function [unitIDs, powerValues] = generatePolarPlots(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, ...
    behavDataForRecordingDays, unitSSs, sTitle)

    globals;

    MODULATION_RANGE_FOR_REWARD = [-.2 .2]; % To separate them into Inc/Dec in lick aligned version
    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_LICK;

    phases = cell(length(arrTrialOutcomesToIncludeLickAligned), 3);
    radiuses = cell(length(arrTrialOutcomesToIncludeLickAligned), 3);
    inds = cell(length(arrTrialOutcomesToIncludeLickAligned), 3);
    unitIDs = cell(length(arrTrialOutcomesToIncludeLickAligned), 3);
    powerValues = cell(length(arrTrialOutcomesToIncludeLickAligned), 3);

    for i=1:4 %length(arrTrialOutcomesToIncludeLickAligned)
        TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
        TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};
        [unitIDsNaive, phaseNaive, radiusNaive, indTunedAndHasPowerNaive, arrHasPowerRewAlignedNaive] = generatePolarPlotsForEachTrainingPhase(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, ...
            MICE_VS_SELECTED_NAIVE_DAY_N, behavDataForRecordingDays, unitSSs, [sTitle 'NaiveDay'], []);
        [unitIDsInt, phaseInt, radiusInt, indTunedAndHasPowerInt, arrHasPowerRewAlignedInt] = generatePolarPlotsForEachTrainingPhase(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1, ...
            MICE_VS_SELECTED_HABITUATION_DAY_N, behavDataForRecordingDays, unitSSs, [sTitle 'IntermediateDay'], []);
        [unitIDsExpert, phaseExpert, radiusExpert, indTunedAndHasPowerExpert, arrHasPowerRewAlignedExpert] = generatePolarPlotsForEachTrainingPhase(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, ...
            MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitSSs, [sTitle 'ExpertDay'], []);

        unitIDs(i, :) = {unitIDsNaive, unitIDsInt, unitIDsExpert};
        phases(i, :) = {phaseNaive, phaseInt, phaseExpert};
        radiuses(i, :) = {radiusNaive, radiusInt, radiusExpert};
        inds(i, :) = {indTunedAndHasPowerNaive, indTunedAndHasPowerInt, indTunedAndHasPowerExpert};  
        powerValues(i,:) = {arrHasPowerRewAlignedNaive, arrHasPowerRewAlignedInt, arrHasPowerRewAlignedExpert};
    end

    unitIDsPredExpert = unitIDs{2,3};
    unitIDsPredExpertHasPower = unitIDsPredExpert(inds{2,3});
    TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{3};
    TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{3};
    [unitIDsExpert, phaseExpert, radiusExpert, indTunedAndHasPowerExpert] = generatePolarPlotsForEachTrainingPhase(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, ...
            MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitSSs, ...
            [sTitle 'ExpertDayPredwReactTrials'], unitIDsPredExpertHasPower);
    
    TRIALOUTCOMES_TO_INCLUDE = '';
    TRIALOUTCOMES_TO_INCLUDE_TITLE = '';
end