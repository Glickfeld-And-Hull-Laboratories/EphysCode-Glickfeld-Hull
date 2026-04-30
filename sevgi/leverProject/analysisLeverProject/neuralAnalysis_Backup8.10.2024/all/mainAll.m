% MAIN ALL for neural analyses of all units from all recordings
clc
clearvars
clearvars -global
close all

globalsAll;


%readPlotBehavioralDataForRecordings();

collectAndSaveAllRecordings();
arrRecordings = readRecordings();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 0.1 st STEP of ANALYSES :  Plot behavioral-only analyses %%%%%%%%%%%%%%%%%%%%  
if ismember(ANALYSIS_STEP_0_0,ARR_DO_ANALYSES)
    plotReactTimesAlongTrials();
    compareReactionTime_BehaviorVSRecording();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 0st STEP of ANALYSES :  Plot behavioral-only analyses %%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_0,ARR_DO_ANALYSES)
    plotReactTimesOfAllRecordings(arrRecordings);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1st STEP of ANALYSES :  Plot raster & PSTH (Qualitative) %%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_1,ARR_DO_ANALYSES) 
    plotPSTH_WRTCellTypes(arrRecordings); % plot PSTHs of different cell types joined
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2nd STEP of ANALYSES :  Plot raster & PSTH WRT Response Type (Qualitative) %%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_2,ARR_DO_ANALYSES)
    plotPSTH_WRTResponseTypes(arrRecordings); % plot PSTHs of inc/dec/noCh response types joined of different cell types 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3rd STEP of ANALYSES :  Plot PSTH based on fast vs slow reaction times (Qualitative) %%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_3,ARR_DO_ANALYSES) 
    checkPSTHActivityWRTReactionTime(arrRecordings);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 4th STEP of ANALYSES :  Plot raster & PSTH (Qualitative) %%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_4,ARR_DO_ANALYSES) 
    checkPSTHActivityWRTReactionTimeandResponseTypes(arrRecordings); % plot PSTH based on fast vs slow reaction times based on inc/dec response types
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5th STEP of ANALYSES :  Heatmaps aligned with behavioral parameters %%%%%%%%%%%%%%%%%%%%
if ismember(ANALYSIS_STEP_5,ARR_DO_ANALYSES) 
    plotHeatMapsWRTBehavior(arrRecordings);
end
