function checkCSSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, ...
    behavDataForRecordingDays, unitCSs, unitSSs, sTitle, isMultiLevel)

    globals;

    if ~isMultiLevel
        MODULATION_RANGE_FOR_REWARD = [-.2 .2]; % To separate them into Inc/Dec in click aligned version
        MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
        for i=1:1%length(arrTrialOutcomesToIncludeLickAligned)
            TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
            TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};
            [arrModulationMagnitudeRewRespCSNaiveDay1, arrModulationMagnitudeCueRespCSNaiveDay1, ~, ~, ~, ~] = ...
                checkCSSSResponsesAndPlotPSTHs(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, MICE_VS_SELECTED_NAIVE_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, [sTitle 'NaiveDay']);
            [arrModulationMagnitudeRewRespCSHabDay1, arrModulationMagnitudeCueRespCSHabDay1, ...
             arrModulationMagnitudeRewRespCSHabDayN, arrModulationMagnitudeCueRespCSHabDayN, ~, ~] = ...
                checkCSSSResponsesAndPlotPSTHs(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1, MICE_VS_SELECTED_HABITUATION_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, [sTitle 'HabitDay']);
            [~, ~, ~, ~, ...
             arrModulationMagnitudeRewRespCSExpertDayAll, arrModulationMagnitudeCueRespCSExpertDayAll] = ...
                checkCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, [sTitle 'ExpertDay']);
            plotViolins(arrModulationMagnitudeRewRespCSNaiveDay1, arrModulationMagnitudeCueRespCSNaiveDay1, ...
                arrModulationMagnitudeRewRespCSHabDay1, arrModulationMagnitudeCueRespCSHabDay1, ...
                arrModulationMagnitudeRewRespCSHabDayN, arrModulationMagnitudeCueRespCSHabDayN, ...
                arrModulationMagnitudeRewRespCSExpertDayAll, arrModulationMagnitudeCueRespCSExpertDayAll, ['CSpks' TRIALOUTCOMES_TO_INCLUDE_TITLE]);
        end
    
    %     MODULATION_RANGE_FOR_REWARD = [-0.7 0.2];
        MODULATION_RANGE_FOR_REWARD = [-.2 0.2]; % To separate them into Inc/Dec in lick aligned version
        MODE_ALIGNMENT = MODE_ALIGNMENT_TO_LICK;
        for i=1:1%length(arrTrialOutcomesToIncludeLickAligned)
            TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
            TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};
            checkCSSSResponsesAndPlotPSTHs(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, MICE_VS_SELECTED_NAIVE_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, [sTitle 'NaiveDay']);
            checkCSSSResponsesAndPlotPSTHs(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1, MICE_VS_SELECTED_HABITUATION_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, [sTitle 'HabitDay']);
            checkCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, [sTitle 'ExpertDay']);    
        end

    else
        MODULATION_RANGE_FOR_REWARD = [-.2 .2]; % To separate them into Inc/Dec in click aligned version
        for i=1:1%length(arrTrialOutcomesToIncludeLickAligned)
            TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
            TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};
            checkTwoLevelCSSSResponsesAndPlotPSTHs(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, MICE_VS_SELECTED_NAIVE_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, [sTitle 'NaiveDay'], MODE_ALIGNMENT_TO_CLICK);
            checkTwoLevelCSSSResponsesAndPlotPSTHs(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1, MICE_VS_SELECTED_HABITUATION_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, [sTitle 'HabitDay'], MODE_ALIGNMENT_TO_CLICK);
            checkTwoLevelCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, [sTitle 'ExpertDay'], MODE_ALIGNMENT_TO_CLICK);
        end
    
    %     MODULATION_RANGE_FOR_REWARD = [-0.7 0.2];
        MODULATION_RANGE_FOR_REWARD = [-.2 0.2]; % To separate them into Inc/Dec in lick aligned version
        for i=1:1%length(arrTrialOutcomesToIncludeLickAligned)
            TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
            TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};
            checkTwoLevelCSSSResponsesAndPlotPSTHs(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, MICE_VS_SELECTED_NAIVE_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, [sTitle 'NaiveDay'], MODE_ALIGNMENT_TO_LICK);
            checkTwoLevelCSSSResponsesAndPlotPSTHs(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1, MICE_VS_SELECTED_HABITUATION_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, [sTitle 'HabitDay'], MODE_ALIGNMENT_TO_LICK);
            checkTwoLevelCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, [sTitle 'ExpertDay'], MODE_ALIGNMENT_TO_LICK);    
        end
    end
end