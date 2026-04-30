% MAIN for Classical Conditioning Project Analyses
clc
clearvars -except Rlist CS SS SumSt %clearvars -global
close all

% gpuDevice(1); % Activate GPU Device
globals;
addpath('../MariesCode/originalCode/');

% DEFAULTS for neural analyses
TRIALS_TO_INCLUDE_NAIVE = TRIAL_CLICK_JUICE; % excluded empty click trials after lab presentation, 'eCl'}; %'b', 't_eCl'}; % {'j'};
TRIALS_TO_INCLUDE_NOTNAIVE = TRIAL_TONE_CLICK_JUICE; % {'b', 't', 'j', 'j_s', 'eCl', 't_eCl'}; % {'b'}; %, 'j'};
FLAG_PLOT_INC_DEC = 1;
FLAG_PLOT_CS = 1;
FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS_STD;
FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO;
TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_CLICK_JUICE;
STD_LEVEL_FOR_CS = 4.5;
FLAG_PLOT_ONLY_PAIRED_WCS = 0;
FROM_CS_TO_SS = 1;
EARLY_VS_LATE_LICK = [];
PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_ONSETS;
FLAG_NORM_FR = 0;
FLAG_PLOT_INDIVIDUAL_CELLS = 1;
NORMALIZE_X_AXIS_FOR_EACH_LICK = 0;

if NORMALIZE_X_AXIS_FOR_EACH_LICK == 0
    PRE_BEHAVIORAL_EVENT_PLOT = .85; % cos cue comes around -700 ms %1.5; % (s) Pre-event duration to include in the raster/psth
    POST_BEHAVIORAL_EVENT_PLOT = 0.5; %1.5; %.5; % (s) Post-event duration to include in the raster/psth
end
NEURON_TYPE = NEURON_TYPE_SS;
FLAG_PLOT_INDIVIDUAL_SPECTROGRAMS = 1;

% Load data
if ~exist("Rlist","var")
    load([DATA_PATH DATA_FILE]);
    
    % Manually updated depths in recording days
    depths={2310,2148.8,2499.8,2320,2612,2472.7,2668,2300.8,2666.8,2900,3025,2318.9,1983.4,2192.4,3240,1376,3194,3098,3042,3233,2025,3224,3009,3282,3250,2736,2706,2363,2318,2103,2323,2330,3405,3078,3239.3,2390,2425,2680,2470,2398.8,1184.2,2139.9,-9999,1511.5,2092.3,2540.9,2231.2,2226.3,1725,2500,-9999,-9999,2045,2600,2360.3,2003.2,2200}';
    [Rlist.depth]=deal(depths{:});
end

behavDataForRecordingDays = Rlist;
behavDataForRecordingDays = doubleCheckLicks(behavDataForRecordingDays);
behavDataForRecordingDays = assignEarlyVSLateQuartileLicks(behavDataForRecordingDays);
unitCSs = CS;
unitSSs = SS;

structUnitsPerRecordingDays = SumSt;
cellTypes = {SumSt.CellType};
cellC4Labels = {SumSt.c4_label};
indMFs = find(strcmp({SumSt.c4_label}, 'MFB') & [SumSt.c4_confidence]>2);
unitMFs = SumSt(indMFs);

indMLIs = find(strcmp({SumSt.c4_label}, 'MLI') & [SumSt.c4_confidence]>2);
unitMLIs = SumSt(indMLIs);

TRIALOUTCOMES_ALL_TO_INCLUDE = {'p','r'};
arrTrialOutcomesToIncludeLickAligned = {TRIALOUTCOMES_ALL_TO_INCLUDE; TRIALOUTCOMES_PREDICTIVE_TO_INCLUDE; TRIALOUTCOMES_REACTIVE_TO_INCLUDE; TRIALOUTCOMES_OUTSIDE_TO_INCLUDE; TRIALOUTCOMES_BEFORE_TO_INCLUDE};
arrTrialOutcomesToIncludeTitle = {TRIALOUTCOMES_ALL_TITLE; TRIALOUTCOMES_PREDICTIVE_TITLE; TRIALOUTCOMES_REACTIVE_TITLE; TRIALOUTCOMES_OUTSIDE_TITLE; TRIALOUTCOMES_BEFORE_TITLE};

%%%%%%%%%%%%%%%%%%%%%%%%% 0th STEP of ANALYSES : Licks aligned to the solenoid click %%%%%%%%%
if ismember(ANALYSIS_STEP_0,ARR_DO_ANALYSES) 
    plotLicksAlongSession;
end

if ismember(ANALYSIS_STEP_1,ARR_DO_ANALYSES)
    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
    plotRastersForCSSS(MICE_VS_NAIVE_DAYS, behavDataForRecordingDays, unitCSs, unitSSs);
    plotRastersForCSSS(MICE_VS_HABITUATION_DAYS, behavDataForRecordingDays, unitCSs, unitSSs);
    plotRastersForCSSS(MICE_VS_EXPERT_DAYS, behavDataForRecordingDays, unitCSs, unitSSs);

    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_LICK;
    plotRastersForCSSS(MICE_VS_NAIVE_DAYS, behavDataForRecordingDays, unitCSs, unitSSs);
    plotRastersForCSSS(MICE_VS_HABITUATION_DAYS, behavDataForRecordingDays, unitCSs, unitSSs);
    plotRastersForCSSS(MICE_VS_EXPERT_DAYS, behavDataForRecordingDays, unitCSs, unitSSs);
end

if ismember(ANALYSIS_STEP_2,ARR_DO_ANALYSES)
    FLAG_PLOT_INC_DEC = 0;
    FLAG_CS_RESP_NONRESP = 0; % Do not divide CSs based on their responsiveness around the click
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 1;

    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
    for i=1:length(arrTrialOutcomesToIncludeLickAligned)
        TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
        TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};
        checkCSResponsesAndPlotPSTHs(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, MICE_VS_SELECTED_NAIVE_DAY_N, behavDataForRecordingDays, unitCSs, 'NaiveDay');
        checkCSResponsesAndPlotPSTHs(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1, MICE_VS_SELECTED_HABITUATION_DAY_N, behavDataForRecordingDays, unitCSs, 'HabitDay');
        checkCSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitCSs, 'ExpertDay');
    end

    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_LICK;
    for i=1:length(arrTrialOutcomesToIncludeLickAligned)
        TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{i};
        TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{i};
        checkCSResponsesAndPlotPSTHs(MICE_VS_NAIVE_DAYS, MICE_VS_SELECTED_NAIVE_DAY_1, MICE_VS_SELECTED_NAIVE_DAY_N, behavDataForRecordingDays, unitCSs, 'NaiveDay');
        checkCSResponsesAndPlotPSTHs(MICE_VS_HABITUATION_DAYS, MICE_VS_SELECTED_HABITUATION_DAY_1, MICE_VS_SELECTED_HABITUATION_DAY_N, behavDataForRecordingDays, unitCSs, 'HabitDay');
        checkCSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitCSs, 'ExpertDay');
    end    
end

if ismember(ANALYSIS_STEP_21,ARR_DO_ANALYSES)
    FLAG_PLOT_INC_DEC = 0;
    FLAG_CS_RESP_NONRESP = 0; % Do not divide CSs based on their responsiveness around the click
    FIRST_VS_LAST = 1; % Within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 1;

    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
    checkCSSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, unitSSs, '', 0);
end

if ismember(ANALYSIS_STEP_3,ARR_DO_ANALYSES) % for resp/nonresp CS responses
    FLAG_PLOT_INC_DEC = 0;
    FLAG_PLOT_SEPERATELY = 0;
    FLAG_CS_RESP_NONRESP = 1;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 1;
    STD_LEVEL_FOR_CS = 4.5; %6;
    FLAG_NORM_FR = 0;
    
    TRIALS_TO_INCLUDE_NAIVE = TRIAL_CLICK_JUICE; % excluded empty click trials after lab presentation, 'eCl'}; %'b', 't_eCl'}; % {'j'};
    TRIALS_TO_INCLUDE_NOTNAIVE = TRIAL_TONE_CLICK_JUICE;

    % Check one trial type
    FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO;
    % If CS responsiveness bigger then 4.5 STD, that's enough to mark it 'responsive'
    FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS_STD;    
    TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_CLICK_JUICE; 
    checkCSSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, [], '', 0);
end

if ismember(ANALYSIS_STEP_30,ARR_DO_ANALYSES) % for Omission resp/nonresp CS responses
    FLAG_PLOT_INC_DEC = 0;
    FLAG_PLOT_SEPERATELY = 0;
    FLAG_CS_RESP_NONRESP = 1;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 1;
    STD_LEVEL_FOR_CS = 4.5; %6;
    FLAG_NORM_FR = 0;
    
    TRIALS_TO_INCLUDE_NAIVE = {TRIAL_CLICK TRIAL_TONE_CLICK}; % empty click trials mean omission
    TRIALS_TO_INCLUDE_NOTNAIVE = {TRIAL_CLICK TRIAL_TONE_CLICK};

    % update ALL_TO_INCLUDE to include all trial outcomes cos for omission trials it does not matter, we just want to see CS responses to cue in case of omitted reward
    TRIALOUTCOMES_ALL_TO_INCLUDE = {'p','r','b','o'};
    arrTrialOutcomesToIncludeLickAligned = {TRIALOUTCOMES_ALL_TO_INCLUDE; TRIALOUTCOMES_PREDICTIVE_TO_INCLUDE; TRIALOUTCOMES_REACTIVE_TO_INCLUDE; TRIALOUTCOMES_OUTSIDE_TO_INCLUDE; TRIALOUTCOMES_BEFORE_TO_INCLUDE};


    % Check one trial type
    FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO;
    % If CS responsiveness bigger then 4.5 STD, that's enough to mark it 'responsive'
    FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS_STD;    
    TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = {TRIAL_CLICK, TRIAL_TONE_CLICK} ; 
    checkCSSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, [], '', 0);
end

% find CSpks responding more to unexpected (j trials) reward trials than expected (b) trials - Lindsey's idea (she's genious!)
if ismember(ANALYSIS_STEP_31,ARR_DO_ANALYSES) 
    FLAG_PLOT_INC_DEC = 0;
    FLAG_PLOT_SEPERATELY = 0;
    FLAG_CS_RESP_NONRESP = 1;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 1;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;

    % These trials will be plotted
    TRIALS_TO_INCLUDE_NAIVE = TRIAL_CLICK_JUICE; % excluded empty click trials after lab presentation, 'eCl'}; %'b', 't_eCl'}; % {'j'};
    TRIALS_TO_INCLUDE_NOTNAIVE = TRIAL_TONE_CLICK_JUICE;

    % Compare two different trial types
    FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_DUAL;
    TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_CLICK_JUICE; 
    TRIAL_TYPE_2_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_TONE_CLICK_JUICE;

    checkCSSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, unitSSs, '', 0);
end

% Plot Unexpected trials
if ismember(ANALYSIS_STEP_32,ARR_DO_ANALYSES) % find CSpks responding more to unexpected (j trials) reward trials than expected (b) trials - Lindsey's idea (she's genious!)
    FLAG_PLOT_INC_DEC = 0;
    FLAG_PLOT_SEPERATELY = 0;
    FLAG_CS_RESP_NONRESP = 1;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 1;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    STD_LEVEL_FOR_CS = 4.5; %6;
    FLAG_NORM_FR = 0;
    
    TRIALS_TO_INCLUDE_NAIVE = TRIAL_CLICK_JUICE; % excluded empty click trials after lab presentation, 'eCl'}; %'b', 't_eCl'}; % {'j'};
    TRIALS_TO_INCLUDE_NOTNAIVE = TRIAL_TONE_CLICK_JUICE;
    TRIALS_TO_INCLUDE_NAIVE_LEVEL_TWO = TRIAL_CLICK_JUICE;
    TRIALS_TO_INCLUDE_NOTNAIVE_LEVEL_TWO = TRIAL_CLICK_JUICE;

    % Check one trial type
    FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO;
    % If CS responsiveness bigger then 4.5 STD, that's enough to mark it 'responsive'
    FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS_STD;    
    TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_CLICK_JUICE; 
    checkCSSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, [], 'Unexpected', 1);
end

% find CSpks aligned to the tone, no division of Resp/NonResp - just get all of the CSs
if ismember(ANALYSIS_STEP_33,ARR_DO_ANALYSES) 
    FLAG_PLOT_INC_DEC = 0;
    FLAG_PLOT_SEPERATELY = 0;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 1;
    FLAG_PLOT_ONLY_PAIRED_WCS = 1;

    % These trials will be plotted
    TRIALS_TO_INCLUDE_NAIVE = TRIAL_TONE_CLICK_JUICE; % excluded empty click trials after lab presentation, 'eCl'}; %'b', 't_eCl'}; % {'j'};
    TRIALS_TO_INCLUDE_NOTNAIVE = TRIAL_TONE_CLICK_JUICE;

    FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS_STD;
    FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO;
    TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_TONE_CLICK_JUICE;

    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_TONE;
    checkCS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, unitSSs);
end

% find CSpks aligned to the cue, divide them Resp/NonResp
if ismember(ANALYSIS_STEP_34,ARR_DO_ANALYSES) 
    FLAG_PLOT_INC_DEC = 0;
    FLAG_PLOT_SEPERATELY = 0;
    FLAG_CS_RESP_NONRESP = 1;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 1;
    STD_LEVEL_FOR_CS = 5;

    % These trials will be plotted
    TRIALS_TO_INCLUDE_NAIVE = TRIAL_TONE_CLICK_JUICE; % excluded empty click trials after lab presentation, 'eCl'}; %'b', 't_eCl'}; % {'j'};
    TRIALS_TO_INCLUDE_NOTNAIVE = TRIAL_TONE_CLICK_JUICE;

    FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS_STD;
    FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO;
    TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_TONE_CLICK_JUICE;

    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_TONE;
    checkCS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, unitSSs);
end

% MONO trial response - find SSpks paired with CSpks responding either strongly or weakly to click
if ismember(ANALYSIS_STEP_4,ARR_DO_ANALYSES) 

    % All days including Naive+Habituated+Expert
%     allMiceAllDays = [MICE_VS_NAIVE_DAYS; MICE_VS_HABITUATION_DAYS; MICE_VS_EXPERT_DAYS];
%     checkCSSSResponsesAndPlotPSTHs(allMiceAllDays, [], [], behavDataForRecordingDays, unitCSs, unitSSs, 'AllTrainingDays', MODE_ALIGNMENT_TO_CLICK);

    FLAG_CS_RESP_NONRESP = 1;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_INC_DEC = 0;
    FLAG_PLOT_SEPERATELY = 0;
    FLAG_PLOT_CS = 0;
    STD_LEVEL_FOR_CS = 6;

    % These trials will be plotted
    TRIALS_TO_INCLUDE_NAIVE = TRIAL_CLICK_JUICE; % excluded empty click trials after lab presentation, 'eCl'}; %'b', 't_eCl'}; % {'j'};
    TRIALS_TO_INCLUDE_NOTNAIVE = TRIAL_TONE_CLICK_JUICE;
    
    FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS_STD;
    FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO;
    TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_CLICK_JUICE;
    
    checkCSSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, unitSSs, '', 0);
end

% DUAL trial response comparison - find SSpks paired with CSpks responding more to unexpected (j trials) reward trials than expected (b trials) - Lindsey's idea (she's genious!)
if ismember(ANALYSIS_STEP_41,ARR_DO_ANALYSES) 

    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 1;
    FLAG_PLOT_ONLY_PAIRED_WCS = 1;

    % These trials will be plotted
    TRIALS_TO_INCLUDE_NAIVE = TRIAL_CLICK_JUICE; % excluded empty click trials after lab presentation, 'eCl'}; %'b', 't_eCl'}; % {'j'};
    TRIALS_TO_INCLUDE_NOTNAIVE = TRIAL_TONE_CLICK_JUICE;

    % Compare two different trial types
    FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_DUAL;
    TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_CLICK_JUICE; 
    TRIAL_TYPE_2_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_TONE_CLICK_JUICE;
    
    checkCSSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, unitSSs, 'DualTrial', 0);
end

% MONO trial response - find SSpks paired with CSpks responding either strongly or weakly to click
if ismember(ANALYSIS_STEP_44,ARR_DO_ANALYSES) 

    % All days including Naive+Habituated+Expert
%     allMiceAllDays = [MICE_VS_NAIVE_DAYS; MICE_VS_HABITUATION_DAYS; MICE_VS_EXPERT_DAYS];
%     checkCSSSResponsesAndPlotPSTHs(allMiceAllDays, [], [], behavDataForRecordingDays, unitCSs, unitSSs, 'AllTrainingDays', MODE_ALIGNMENT_TO_CLICK);

    FLAG_CS_RESP_NONRESP = 1;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_PLOT_CS = 0;
    STD_LEVEL_FOR_CS = 5;

%     FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS_STD;
%     FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO;
%     TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_CLICK_JUICE;

    FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS_STD;
    FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO;
    TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_TONE_CLICK_JUICE;
    
    checkCSSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, unitSSs, 'MonoTrial', 0);
end

if ismember(ANALYSIS_STEP_5,ARR_DO_ANALYSES) % for All SS
    FLAG_PLOT_INC_DEC = 0;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_NORM_FR = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;

    [arrModulationMagnitudeNaive, arrModulationMagnitudeHab, arrModulationMagnitudeExpert] = ...
        checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitSSs, []);    

%     fullArray = [arrModulationMagnitudeNaive arrModulationMagnitudeHab arrModulationMagnitudeExpert];
%     minChange = min(fullArray);
%     maxChange = max(fullArray);
% 
% 
%     naive = nonzeros(arrModulationMagnitudeNaive);
%     hab = nonzeros(arrModulationMagnitudeHab);
%     expert = nonzeros(arrModulationMagnitudeExpert);
% 
%     edges = [minChange:1:maxChange];
%     
%     figure;histogram(naive,edges,'Normalization','probability');
%     figure;histogram(hab,edges,'Normalization','probability');
%     figure;histogram(expert,edges,'Normalization','probability');
%     xlabel('Change in spk/s');
% 
%     decNaive = naive(naive<0);
%     decHab = hab(hab<0);
%     decExpert = expert(expert<0);
% 
%     incNaive = naive(naive>0);
%     incHab = hab(hab>0);
%     incExpert = expert(expert>0);
% 
%     % Mann-Whitney U-test (Equivalent to unpaired t-test)
%     [p11,h11] = ranksum(hab, naive)
%     [p22,h22] = ranksum(hab, expert)
%     [p33,h33] = ranksum(expert, naive)
% 
%     [p1,h1] = ranksum(decHab, decNaive, "tail","left","alpha",0.025)
%     [p2,h2] = ranksum(decExpert, decHab) %,  "tail","left","alpha",0.025)
%     [p3,h3] = ranksum(decExpert, decNaive, "tail","left","alpha",0.025)
% 
%     [p4,h4] = ranksum(incHab, incNaive, "tail","right","alpha",0.025)
%     [p5,h5] = ranksum(incExpert,incHab)
%     [p6,h6] = ranksum(incExpert, incNaive, "tail","right","alpha",0.025)
% 
%     figure;
%     cellData = {naive, hab, expert};
%     catNames = ["Naive","Hab","Expert"];
%     vs1 = violin(cellData,'xlabel',catNames,'facecolor',[.3 .3 .3; 0 1 0; 1 1 0],'edgecolor','b');
%     ylabel('Change in spk/s');
% %     xLabelCatNames = {"","Naive","","Hab","","Expert"};
% %     set(gca,'XtickLabel',xLabelCatNames);
% 
%     figure;
%     cellData = {decNaive, decHab, decExpert};
%     vs1 = violin(cellData,'xlabel',catNames,'facecolor',[.3 .3 .3; 0 1 0; 1 1 0],'edgecolor','b');
%     ylabel('Change in spk/s');
% 
%     figure;
%     cellData = {incNaive, incHab, incExpert};
%     vs1 = violin(cellData,'xlabel',catNames,'facecolor',[.3 .3 .3; 0 1 0; 1 1 0],'edgecolor','b');
%     ylabel('Change in spk/s');

end

if ismember(ANALYSIS_STEP_50,ARR_DO_ANALYSES) % for All SS
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    FLAG_NORM_FR = 0;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;

    [arrModulationMagnitudeNaive, arrModulationMagnitudeHab, arrModulationMagnitudeExpert] = ...
        checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitSSs, []);    
end

if ismember(ANALYSIS_STEP_500,ARR_DO_ANALYSES) % Z-scored for All SS
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    FLAG_NORM_FR = 1;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;

    [arrModulationMagnitudeNaive, arrModulationMagnitudeHab, arrModulationMagnitudeExpert] = ...
        checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitSSs, []);    
end

if ismember(ANALYSIS_STEP_51,ARR_DO_ANALYSES) % for All SS - Early Licks only
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    EARLY_VS_LATE_LICK = EARLY_LICK;
    FLAG_NORM_FR = 1;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_ONSETS;

    [arrModulationMagnitudeNaive, arrModulationMagnitudeHab, arrModulationMagnitudeExpert, onsetPointEarly] = checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitSSs, 'AllSS');    
    EARLY_VS_LATE_LICK = [];
end

if ismember(ANALYSIS_STEP_52,ARR_DO_ANALYSES) % for All SS - Late Licks only
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    EARLY_VS_LATE_LICK = LATE_LICK;
    FLAG_NORM_FR = 1;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_ONSETS;

    [arrModulationMagnitudeNaive, arrModulationMagnitudeHab, arrModulationMagnitudeExpert, onsetPointLate] = checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitSSs, 'AllSS');    
%     [p, h]=ranksum(onsetPointEarly,onsetPointLate)
%     [h, p]=ttest2(onsetPointEarly,onsetPointLate)
    EARLY_VS_LATE_LICK = [];
end

if ismember(ANALYSIS_STEP_53,ARR_DO_ANALYSES) % find SSpks for unexpected (j trials) trials
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;

    % Plot SS responses for unexpected trials
    TRIALS_TO_INCLUDE_NAIVE = TRIAL_CLICK_JUICE; % excluded empty click trials after lab presentation, 'eCl'}; %'b', 't_eCl'}; % {'j'};
    TRIALS_TO_INCLUDE_NOTNAIVE = TRIAL_CLICK_JUICE;
    checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitSSs, 'Unexpected_AllSS');
end

if ismember(ANALYSIS_STEP_54,ARR_DO_ANALYSES) % find SSpks for expected (b trials) trials
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;

    % Plot SS responses for expected trials
    TRIALS_TO_INCLUDE_NAIVE = TRIAL_CLICK_JUICE; % excluded empty click trials after lab presentation, 'eCl'}; %'b', 't_eCl'}; % {'j'};
    TRIALS_TO_INCLUDE_NOTNAIVE = TRIAL_TONE_CLICK_JUICE; %TRIAL_TONE_CLICK_JUICE; %TRIAL_CLICK_JUICE;
    checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitSSs, 'Expected_AllSS');
end

if ismember(ANALYSIS_STEP_6,ARR_DO_ANALYSES) % find CSpk response distributions 
    FROM_CS_TO_SS = 1; % Find CSs and segragate them based on their response, then plot their paired SSs
    FLAG_PLOT_INC_DEC = 0;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_PLOT_ONLY_PAIRED_WCS = 1;

    % I don't think we need this 
    FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO;
    TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_CLICK_JUICE;
    
    TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{1};
    TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{1};
    % find CS response magnitude distribution extremities
    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
    [lowerCSinds, upperCSinds] = buildDistOfResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, 'ExpertDay');

    lowerCSs = unitCSs(lowerCSinds);
    checkCSSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, lowerCSs, unitSSs, 'LowestZscore', 0);
%     checkCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, lowerCSs, unitSSs, 'ExpertDayLowResp', MODE_ALIGNMENT_TO_CLICK);

    upperCSs = unitCSs(upperCSinds);
    checkCSSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, upperCSs, unitSSs, 'HighestZscore', 0);
%     checkCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, upperCSs, unitSSs, 'ExpertDayHighResp', MODE_ALIGNMENT_TO_CLICK);

end

if ismember(ANALYSIS_STEP_7,ARR_DO_ANALYSES) % find SSpks and then their CSpk response distributions 
    FROM_CS_TO_SS = 0; % From SS to CS
    FLAG_PLOT_INC_DEC = 0;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_PLOT_ONLY_PAIRED_WCS = 1;
    
    TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{1};
    TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{1};
    
    % find SS response magnitude distribution extremities
    % either MODE_ALIGNMENT_TO_CLICK or MODE_ALIGNMENT_TO_LICK
    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
    [decCellInds, nonModCellInds, incCellInds] = buildDistOfResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, 'ExpertDay');
    
    decreasingSSs = unitSSs(decCellInds);
    checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, decreasingSSs,'Decreasing');    

    nonModSSs = unitSSs(nonModCellInds);
    checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, nonModSSs,'NonModulated');    

    increasingSSs = unitSSs(incCellInds);
    checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, increasingSSs,'Increasing');

    %%%%%%%%%%%%%%%% CSs %%%%%%%%%%%%%%
    FLAG_PLOT_CS = 1;
    MODULATION_RANGE_FOR_REWARD = [0 .2]; %[-.2 .2];
    TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{1};
    TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{1};
    lowerCSs = [];
    for i=1:length(decreasingSSs)
        unitMaster = decreasingSSs(i);
        recordingDayInd = unitMaster.RecorNum;
        [unitSlave, ~] = findPair(unitCSs, recordingDayInd, unitMaster, [], []);
        lowerCSs = [lowerCSs unitSlave];
    end
    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
    [~, ~,~, ~, arrModulationMagnitudeRewRespCSDayAllLower, arrModulationMagnitudeCueRespCSDayAllLower, integralValuesAfterRewLower] = ...
    checkCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, lowerCSs, [], 'ExpertDayDecRespCS');
%     MODE_ALIGNMENT = MODE_ALIGNMENT_TO_LICK;
%     checkCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, lowerCSs, [], 'ExpertDayDecRespCS');

%     middleCSs = [];
%     for i=1:length(nonModSSs)
%         unitMaster = nonModSSs(i);
%         recordingDayInd = unitMaster.RecorNum;
%         [unitSlave, ~] = findPair(unitCSs, recordingDayInd, unitMaster, [], []);
%         middleCSs = [middleCSs unitSlave];
%     end
%     checkCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, middleCSs, [], 'ExpertDayMiddleRespCS', MODE_ALIGNMENT_TO_CLICK);
%     checkCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, middleCSs, [], 'ExpertDayMiddleRespCS', MODE_ALIGNMENT_TO_LICK);

    higherCSs = [];
    for i=1:length(increasingSSs)
        unitMaster = increasingSSs(i);
        recordingDayInd = unitMaster.RecorNum;
        [unitSlave, ~] = findPair(unitCSs, recordingDayInd, unitMaster, [], []);
        higherCSs = [higherCSs unitSlave];
    end
    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
    [~, ~,~, ~, arrModulationMagnitudeRewRespCSDayAllHigher, arrModulationMagnitudeCueRespCSDayAllHigher, integralValuesAfterRewHigher] = ...
        checkCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, higherCSs, [], 'ExpertDayIncRespCS');
    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_LICK;
%     checkCSSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, higherCSs, [], 'ExpertDayIncRespCS');

    if ~isempty(arrModulationMagnitudeRewRespCSDayAllLower) && ~isempty(arrModulationMagnitudeRewRespCSDayAllHigher)
        [p,h] = ranksum(arrModulationMagnitudeRewRespCSDayAllLower,arrModulationMagnitudeRewRespCSDayAllHigher);
        logger.info('main', ['CS pairs of Incs vs Decs h=' num2str(h) ' p=' num2str(p)]);
    end

    low = arrModulationMagnitudeRewRespCSDayAllLower(arrModulationMagnitudeRewRespCSDayAllLower>0);
    high = arrModulationMagnitudeRewRespCSDayAllHigher(arrModulationMagnitudeRewRespCSDayAllHigher>0);
    [p,h] = ranksum(low, high)
    [h,p] = ttest2(low,high)

    [p,h] = ranksum(integralValuesAfterRewLower,integralValuesAfterRewHigher)
    [h,p] = ttest2(integralValuesAfterRewLower,integralValuesAfterRewHigher)

end

if ismember(ANALYSIS_STEP_8,ARR_DO_ANALYSES) % find Upbound/Downbound SSpks
    FROM_CS_TO_SS = 2; % Check only Upbound Downbound SSs
    FLAG_PLOT_INC_DEC = 0;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_PLOT_ONLY_PAIRED_WCS = 1;
    
    TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{1};
    TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{1};
    
    % find SS response magnitude distribution extremities
    % either MODE_ALIGNMENT_TO_CLICK or MODE_ALIGNMENT_TO_LICK
    MODE_ALIGNMENT = MODE_ALIGNMENT_TO_CLICK;
    [downBoundCellInds, upBoundCellInds] = checkUpboundDownboundSS(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitCSs, unitSSs, 'ExpertDay');
    
    downBoundSSs = unitSSs(downBoundCellInds);
    checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, downBoundSSs,'downBoundSSs');
    
    upBoundSSs = unitSSs(upBoundCellInds);
    checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, upBoundSSs,'upBoundSSs');
end

if ismember(ANALYSIS_STEP_9,ARR_DO_ANALYSES) % Z-scored for All MFs
    FLAG_PLOT_INDIVIDUAL_CELLS = 0;
    NEURON_TYPE = NEURON_TYPE_MFB;
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    FLAG_NORM_FR = 1;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;
    NORMALIZE_X_AXIS_FOR_EACH_LICK = 0;
    FLAG_PLOT_INDIVIDUAL_SPECTROGRAMS = 0;

    [arrModulationMagnitudeNaive, arrModulationMagnitudeHab, arrModulationMagnitudeExpert] = ...
        checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitMFs, []);    
end

if ismember(ANALYSIS_STEP_91,ARR_DO_ANALYSES) % Z-scored MF analyses (how lick-cycle aligned population respond to cue when we cue-align them)
    FLAG_PLOT_INDIVIDUAL_CELLS = 0;
    NEURON_TYPE = NEURON_TYPE_MFB;
    FLAG_PLOT_INC_DEC = 0;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    FLAG_NORM_FR = 1;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;
    NORMALIZE_X_AXIS_FOR_EACH_LICK = 1;
    FLAG_PLOT_INDIVIDUAL_SPECTROGRAMS = 0;

    checkSSFromLickAlignedToClickAligned(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitMFs, []);    
end

if ismember(ANALYSIS_STEP_99,ARR_DO_ANALYSES) % Z-scored for All SSs
    FLAG_PLOT_INDIVIDUAL_CELLS = 0;
    NEURON_TYPE = NEURON_TYPE_SS;
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    FLAG_NORM_FR = 1;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;
    NORMALIZE_X_AXIS_FOR_EACH_LICK = 0;
    FLAG_PLOT_INDIVIDUAL_SPECTROGRAMS = 0;

    [arrModulationMagnitudeNaive, arrModulationMagnitudeHab, arrModulationMagnitudeExpert] = ...
        checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitSSs, []);    
end

if ismember(ANALYSIS_STEP_991,ARR_DO_ANALYSES) % Z-scored SS analyses (how lick-cycle aligned population respond to cue when we cue-align them)
    FLAG_PLOT_INDIVIDUAL_CELLS = 0;
    NEURON_TYPE = NEURON_TYPE_SS;
    FLAG_PLOT_INC_DEC = 0;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    FLAG_NORM_FR = 1;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;
    NORMALIZE_X_AXIS_FOR_EACH_LICK = 1;
    FLAG_PLOT_INDIVIDUAL_SPECTROGRAMS = 0;
    
    checkSSFromLickAlignedToClickAligned(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitSSs, []);    
end

if ismember(ANALYSIS_STEP_10,ARR_DO_ANALYSES) % Z-scored for All MLIs
    FLAG_PLOT_INDIVIDUAL_CELLS = 0;
    NEURON_TYPE = NEURON_TYPE_MLI;
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    FLAG_NORM_FR = 1;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;
    NORMALIZE_X_AXIS_FOR_EACH_LICK = 1;

    [arrModulationMagnitudeNaive, arrModulationMagnitudeHab, arrModulationMagnitudeExpert] = ...
        checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitMLIs, []);    
end

if ismember(ANALYSIS_STEP_11,ARR_DO_ANALYSES) % Z-scored for All CSs
    FLAG_PLOT_INDIVIDUAL_CELLS = 0;
    NEURON_TYPE = NEURON_TYPE_CS;
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    FLAG_NORM_FR = 1;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;
    NORMALIZE_X_AXIS_FOR_EACH_LICK = 1;
    FLAG_PLOT_INDIVIDUAL_SPECTROGRAMS = 0;

    %%% How other CSs are generated above
    % FLAG_PLOT_INC_DEC = 0;
    % FLAG_PLOT_SEPERATELY = 0;
    % FLAG_CS_RESP_NONRESP = 1;
    % FLAG_PLOT_CS = 1;
    % STD_LEVEL_FOR_CS = 4.5; %6;
    % FLAG_NORM_FR = 0;    
    % TRIALS_TO_INCLUDE_NAIVE = TRIAL_CLICK_JUICE; % excluded empty click trials after lab presentation, 'eCl'}; %'b', 't_eCl'}; % {'j'};
    % TRIALS_TO_INCLUDE_NOTNAIVE = TRIAL_TONE_CLICK_JUICE;

    % % Check one trial type
    % FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO;
    % % If CS responsiveness bigger then 4.5 STD, that's enough to mark it 'responsive'
    % FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS_STD;    
    % TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS = TRIAL_CLICK_JUICE; 
    % checkCSSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, [], '', 0);

    [arrModulationMagnitudeNaive, arrModulationMagnitudeHab, arrModulationMagnitudeExpert] = ...
        checkSS(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, []);    
end

if ismember(ANALYSIS_STEP_12_MF, ARR_DO_ANALYSES) % Polar plots for MFs
    FLAG_PLOT_INDIVIDUAL_CELLS = 0;
    NEURON_TYPE = NEURON_TYPE_MFB;
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    FLAG_NORM_FR = 0;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;
    NORMALIZE_X_AXIS_FOR_EACH_LICK = 1;
    FLAG_PLOT_INDIVIDUAL_SPECTROGRAMS = 0;

    [unitIDs, powerValues] = generatePolarPlots(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitMFs, []);    
    structUnitIDvsPow = powerScatterPredvsReact(unitIDs, powerValues, []);
end

if ismember(ANALYSIS_STEP_12_SS, ARR_DO_ANALYSES) % Polar plots for SSs
    FLAG_PLOT_INDIVIDUAL_CELLS = 0;
    NEURON_TYPE = NEURON_TYPE_SS;
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    FLAG_NORM_FR = 0;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;
    NORMALIZE_X_AXIS_FOR_EACH_LICK = 1;
    FLAG_PLOT_INDIVIDUAL_SPECTROGRAMS = 0;

    [unitIDs, powerValues] = generatePolarPlots(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitSSs, []);    
    structUnitIDvsPow = powerScatterPredvsReact(unitIDs, powerValues, []);

    %%%%%%%%%%% Find the cells have only predictive or only reactive power %%%%%%%%%%%%%%%%%%
    ind=3; % EXPERT
    indPred = find(structUnitIDvsPow(ind).arrPredPow>0 & structUnitIDvsPow(ind).arrReactPow==0);
    predPowUnitIDs = structUnitIDvsPow(ind).unitIDs(indPred);
    TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{2};
    TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{2};
    checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, ...
            MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitSSs, ...
            ['SS_ExpertDayPredPoweredwPredTrials'], 1, predPowUnitIDs);

    TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{3};
    TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{3};
    checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, ...
            MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitSSs, ...
            ['SS_ExpertDayPredPoweredwReactTrials'], 1, predPowUnitIDs);

    % Find corresponding paired CSs for these SSs
    unitCSsPairedPred = findMultiPairs(unitCSs, predPowUnitIDs);

    indReact = find(structUnitIDvsPow(ind).arrPredPow==0 & structUnitIDvsPow(ind).arrReactPow>0);
    reactPowUnitIDs = structUnitIDvsPow(ind).unitIDs(indReact);
    TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{3};
    TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{3};
    checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, ...
            MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitSSs, ...
            ['SS_ExpertDayReactPoweredwReactTrials'], 1, reactPowUnitIDs);

    TRIALOUTCOMES_TO_INCLUDE = arrTrialOutcomesToIncludeLickAligned{2};
    TRIALOUTCOMES_TO_INCLUDE_TITLE = arrTrialOutcomesToIncludeTitle{2};
    checkSSResponsesAndPlotPSTHs(MICE_VS_EXPERT_DAYS, MICE_VS_SELECTED_EXPERT_DAY_1, ...
            MICE_VS_SELECTED_EXPERT_DAY_N, behavDataForRecordingDays, unitSSs, ...
            ['SS_ExpertDayReactPoweredwPredTrials'], 1, reactPowUnitIDs);

    % Find corresponding paired CSs for these SSs
    unitCSsPairedReact = findMultiPairs(unitCSs, reactPowUnitIDs);
end

if ismember(ANALYSIS_STEP_12_CS_SS, ARR_DO_ANALYSES) % Polar plots for CS-SS pairs
    FLAG_PLOT_INDIVIDUAL_CELLS = 0;
    NEURON_TYPE = NEURON_TYPE_CS;
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 1;
    FLAG_NORM_FR = 0;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;
    NORMALIZE_X_AXIS_FOR_EACH_LICK = 1;
    FLAG_PLOT_INDIVIDUAL_SPECTROGRAMS = 0;
    FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS = FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO;

    generatePairedPolarPlots(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, unitCSs, unitSSs, []);    
end

if ismember(ANALYSIS_STEP_13, ARR_DO_ANALYSES) % Input-Output Transformations
    FLAG_PLOT_INDIVIDUAL_CELLS = 0;
    NEURON_TYPE = NEURON_TYPE_MFB;
    FLAG_PLOT_INC_DEC = 1;
    FLAG_PLOT_SEPERATELY = 1;
    FLAG_CS_RESP_NONRESP = 0;
    FIRST_VS_LAST = 0; % No within session analysis - Do not divide first vs last trials
    FLAG_PLOT_CS = 0;
    FLAG_PLOT_ONLY_PAIRED_WCS = 0;
    FLAG_NORM_FR = 0;
    PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES = PLOT_LICK_RATE;
    NORMALIZE_X_AXIS_FOR_EACH_LICK = 1;
    FLAG_PLOT_INDIVIDUAL_SPECTROGRAMS = 0;

    checkIOTransformations(arrTrialOutcomesToIncludeLickAligned, arrTrialOutcomesToIncludeTitle, behavDataForRecordingDays, ...
        unitMFs, unitSSs);    

end