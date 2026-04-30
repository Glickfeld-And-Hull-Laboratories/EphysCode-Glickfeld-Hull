function [arrModulationMagnitudeRewRespSSNaiveDayAll, arrModulationMagnitudeRewRespSSHabDayAll, arrModulationMagnitudeRewRespSSExpertDayAll, onsetPoint] = ...
    checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, ...
    behavDataForRecordingDays, unitSSs, sTitle)

    globals;

    arrModulationMagnitudeRewRespSSNaiveDayAll = [];
    arrModulationMagnitudeRewRespSSHabDayAll = [];
    arrModulationMagnitudeRewRespSSExpertDayAll = [];
    MODULATION_RANGE_FOR_REWARD = [-.2 .2]; % To separate them into Inc/Dec in click aligned version
    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
    for i=1:length(arrTrialOutcomesToIncludeLickAligned)
        TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
        TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};
        checkSSResponsesAndPlotPSTHs(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, ...
            MICE_VS_SELECTED_NAIVE_DAY_N, behavDataForRecordingDays, unitSSs, [sTitle 'NaiveDay'], 1, []);
        checkSSResponsesAndPlotPSTHs(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1, ...
            MICE_VS_SELECTED_HABITUATION_DAY_N, behavDataForRecordingDays, unitSSs, [sTitle 'HabitDay'], 1, []);
        checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, ...
            MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitSSs, [sTitle 'ExpertDay'], 1, []);
    end

%     MODULATION_RANGE_FOR_REWARD = [-0.7 0.2];
    MODULATION_RANGE_FOR_REWARD = [-.2 .2]; % To separate them into Inc/Dec in lick aligned version
    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_LICK;
    % NORMALIZE_X_AXIS_FOR_EACH_LICK = 0;
%     PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_CUE_TIMES;
    for i=1:length(arrTrialOutcomesToIncludeLickAligned)
        TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
        TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};
        checkSSResponsesAndPlotPSTHs(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, ...
            MICE_VS_SELECTED_NAIVE_DAY_N, behavDataForRecordingDays, unitSSs, [sTitle 'NaiveDay'], 1, []);
        checkSSResponsesAndPlotPSTHs(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1, ...
            MICE_VS_SELECTED_HABITUATION_DAY_N, behavDataForRecordingDays, unitSSs, [sTitle 'HabitDay'], 1, []);
        checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, ...
            MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitSSs, [sTitle 'ExpertDay'], 1, []);

%         plotViolinsSS(arrModulationMagnitudeRewRespSSNaiveDayAll, arrModulationMagnitudeRewRespSSHabDayAll, ...
%             arrModulationMagnitudeRewRespSSExpertDayAll, ['SSpks' TRIALOUTCOMES_TO_INCLUDE_TITLE]);


%         if i==2
%             predMag=arrModulationMagnitudeRewRespSSExpertDayAll;
%         elseif i==3
%             reactMag=arrModulationMagnitudeRewRespSSExpertDayAll;
%         end
    end
%     plotViolinsSS(predMag, reactMag, 'SSpksPredVSReact');

end