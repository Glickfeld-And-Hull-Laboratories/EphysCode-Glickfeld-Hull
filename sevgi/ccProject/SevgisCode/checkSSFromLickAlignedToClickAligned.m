function [arrModulationMagnitudeRewRespSSNaiveDayAll, arrModulationMagnitudeRewRespSSHabDayAll, arrModulationMagnitudeRewRespSSExpertDayAll, onsetPoint] = ...
    checkSSFromLickAlignedToClickAligned(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, ...
    behavDataForRecordingDays, unitSSs, sTitle)

    globals;
    
    MODULATION_RANGE_FOR_REWARD = [-.2 .2]; % To separate them into Inc/Dec in lick aligned version
    
    for i=1:1 % 4 %length(arrTrialOutcomesToIncludeLickAligned)
        TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
        TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};

        % Find modulated responses from lick-cyle-aligned population
        % Check their cue-aligned responses
        % MODE_ALIGNMENT = MODE_ALIGNMENT_TO_LICK;
        % [arrModulationsNaive, isSinusoidalNaive] = checkSSResponsesAndPlotPSTHs(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, ...
        %     MICE_VS_SELECTED_NAIVE_DAY_N, behavDataForRecordingDays, unitSSs, [sTitle 'NaiveDay'], 0, [], []);
        % MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
        % checkSSResponsesAndPlotPSTHs(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, MICE_VS_SELECTED_NAIVE_DAY_N, ...
        %     behavDataForRecordingDays, unitSSs, [sTitle 'NaiveDay'], 1, arrModulationsNaive, isSinusoidalNaive);
        
        % NORMALIZE_X_AXIS_FOR_EACH_LICK = 1;
        % MODE_ALIGNMENT = MODE_ALIGNMENT_TO_LICK;
        % [arrModulationsInt, isSinusoidalInt] = checkSSResponsesAndPlotPSTHs(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1,...
        %     MICE_VS_SELECTED_HABITUATION_DAY_N, behavDataForRecordingDays, unitSSs, [sTitle 'HabitDay'], 0, [], []);
        % NORMALIZE_X_AXIS_FOR_EACH_LICK = 0;
        % MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
        % checkSSResponsesAndPlotPSTHs(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1, MICE_VS_SELECTED_HABITUATION_DAY_N, ...
        %     behavDataForRecordingDays, unitSSs, [sTitle 'HabitDay'], 1, arrModulationsInt, isSinusoidalInt);

        NORMALIZE_X_AXIS_FOR_EACH_LICK = 1;
        FLAG_PLOT_INC_DEC = 0; % Do not seperate into Inc/Dec
        MODE_ALIGNMENT = MODE_ALIGNMENT_TO_LICK;
        PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE; % PLOT_CUE_TIMES;
        [dayAllSSIDsAllMice, arrModulationsExpert, isSinusoidalExpert] = checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, ...
            behavDataForRecordingDays, unitSSs, [sTitle 'ExpertDay'], 1, []);

        EARLY_VS_LATE_LICK = EARLY_LICK;
        [dayAllSSIDsAllMiceEarlyLicks, arrModulationsExpertEarlyLicks, isSinusoidalExpertEarlyLicks] = checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, ...
            behavDataForRecordingDays, unitSSs, [sTitle 'ExpertDay-LateCue'], 1, []);

        EARLY_VS_LATE_LICK = LATE_LICK;
        [dayAllSSIDsAllMiceLateLicks, arrModulationsExpertLateLicks, isSinusoidalExpertLateLicks] = checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, ...
            behavDataForRecordingDays, unitSSs, [sTitle 'ExpertDay-EarlyCue'], 1, []);
        
        %%%*********************** CLICK-ALIGNED version of same cells ********************%%
        NORMALIZE_X_AXIS_FOR_EACH_LICK = 0;
        MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
        PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_ONSETS;
        EARLY_VS_LATE_LICK = [];
        
        modulated = arrModulationsExpert~=0 & isSinusoidalExpert'==1;
        idsSSSin = dayAllSSIDsAllMice(modulated);
        checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, ...
            behavDataForRecordingDays, unitSSs, [sTitle 'ExpertDay-Sin'], 1, idsSSSin);

        modulated = arrModulationsExpert~=0 & isSinusoidalExpert'==-1;
        idsSSRamp = dayAllSSIDsAllMice(modulated);
        checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, ...
            behavDataForRecordingDays, unitSSs, [sTitle 'ExpertDay-Ramp'], 1, idsSSRamp);
        
        EARLY_VS_LATE_LICK = EARLY_LICK;    
        modulated = arrModulationsExpert~=0 & isSinusoidalExpert'==1;
        idsSSSin = dayAllSSIDsAllMice(modulated);
        checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, ...
            behavDataForRecordingDays, unitSSs, [sTitle 'ExpertDay-Sin-EarlyLicks'], 1, idsSSSin);

        modulated = arrModulationsExpert~=0 & isSinusoidalExpert'==-1;
        idsSSRamp = dayAllSSIDsAllMice(modulated);
        checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, ...
            behavDataForRecordingDays, unitSSs, [sTitle 'ExpertDay-Ramp-EarlyLicks'], 1, idsSSRamp);

        EARLY_VS_LATE_LICK = LATE_LICK;    
        modulated = arrModulationsExpert~=0 & isSinusoidalExpert'==1;
        idsSSSin = dayAllSSIDsAllMice(modulated);
        checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, ...
            behavDataForRecordingDays, unitSSs, [sTitle 'ExpertDay-Sin-LateLicks'], 1, idsSSSin);

        modulated = arrModulationsExpert~=0 & isSinusoidalExpert'==-1;
        idsSSRamp = dayAllSSIDsAllMice(modulated);
        checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, ...
            behavDataForRecordingDays, unitSSs, [sTitle 'ExpertDay-Ramp-LateLicks'], 1, idsSSRamp);
        EARLY_VS_LATE_LICK = [];
    end
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE; % revert back to the original lick rate plotting
end