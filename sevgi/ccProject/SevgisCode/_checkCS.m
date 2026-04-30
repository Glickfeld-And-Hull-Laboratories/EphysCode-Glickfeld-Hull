function checkCS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, ...
    behavDataForRecordingDays, unitCSs, unitSSs, modeAlignment)

    globals;

    for i=1:1%length(arrTrialOutcomesToIncludeLickAligned)
        TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
        TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};
        checkCSSSResponsesAndPlotPSTHs(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, MICE_VS_SELECTED_NAIVE_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, 'NaiveDay', modeAlignment);
        checkCSSSResponsesAndPlotPSTHs(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1, MICE_VS_SELECTED_HABITUATION_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, 'HabitDay', modeAlignment);
        checkCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, 'ExpertDay', modeAlignment);
    end

    for i=1:length(arrTrialOutcomesToIncludeLickAligned)
        TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
        TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};
        checkCSSSResponsesAndPlotPSTHs(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, MICE_VS_SELECTED_NAIVE_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, 'NaiveDay', MODE_ALIGNMENT_TO_LICK);
        checkCSSSResponsesAndPlotPSTHs(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1, MICE_VS_SELECTED_HABITUATION_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, 'HabitDay', MODE_ALIGNMENT_TO_LICK);
        checkCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, 'ExpertDay', MODE_ALIGNMENT_TO_LICK);    
    end
end