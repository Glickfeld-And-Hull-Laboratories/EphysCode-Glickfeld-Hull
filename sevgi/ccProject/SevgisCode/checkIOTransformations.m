function checkIOTransformations(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, ...
    behavDataForRecordingDays, unitMFs, unitSSs)

    globals;

    MODULATION_RANGE_FOR_REWARD = [-.2 .2]; % To separate them into Inc/Dec in lick aligned version
    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_LICK;

    phases = cell(length(arrTrialOutcomesToIncludeLickAligned), 3);
    radiuses = cell(length(arrTrialOutcomesToIncludeLickAligned), 3);
    inds = cell(length(arrTrialOutcomesToIncludeLickAligned), 3);
    unitIDs = cell(length(arrTrialOutcomesToIncludeLickAligned), 3);

    for i=2:3 %length(arrTrialOutcomesToIncludeLickAligned)
        TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
        TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};
        [unitIDsNaive, phaseNaive, radiusNaive, indTunedAndHasPowerNaive] = ...
          checkIOTransformationsForEachTrainingPhase(MICE_VS_NAIVE_DAYS, behavDataForRecordingDays, unitMFs, unitSSs, ['NaiveDay' TRIALOUTCOMES_TO_INCLUDE_TITLE]);
        [unitIDsInt, phaseInt, radiusInt, indTunedAndHasPowerInt] = ...
          checkIOTransformationsForEachTrainingPhase(MICE_VS_HABITUATION_DAYS, behavDataForRecordingDays, unitMFs, unitSSs, ['IntermediateDay' TRIALOUTCOMES_TO_INCLUDE_TITLE]);
        [unitIDsExpert, phaseExpert, radiusExpert, indTunedAndHasPowerExpert] = ...
            checkIOTransformationsForEachTrainingPhase(MICE_VS_EXPERT_DAYS, behavDataForRecordingDays, unitMFs, unitSSs, ['ExpertDay' TRIALOUTCOMES_TO_INCLUDE_TITLE]);

        unitIDs(i, :) = {unitIDsNaive, unitIDsInt, unitIDsExpert};
        phases(i, :) = {phaseNaive, phaseInt, phaseExpert};
        radiuses(i, :) = {radiusNaive, radiusInt, radiusExpert};
        inds(i, :) = {indTunedAndHasPowerNaive, indTunedAndHasPowerInt, indTunedAndHasPowerExpert};        
    end
end