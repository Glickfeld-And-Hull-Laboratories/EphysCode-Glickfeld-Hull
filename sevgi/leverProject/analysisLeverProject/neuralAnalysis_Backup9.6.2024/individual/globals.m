% GLOBAL variables
global pathToParentRec pathToRecFolder pathToUnitsDataFolder pathToFigureFolder pathToCurationHelperFolder UNITS_FILE_NAME UNITS_AND_VARS_FILE_NAME pathKS pathTPrime chList tipLength depthDuringRecording dw digitalChList ...
HOLD_LEVER_TXT RELEASE_LEVER_TXT UNIT_OF_INTEREST VIS_STIM_ON_TXT VIS_STIM_OFF_TXT LICK_ONSET_TXT LICK_OFFSET_TXT REWARD_ONSET_TXT REWARD_OFFSET_TXT ...
MOUSE_ID dateOfRecording pathNpyxFiltered pathNpyxOrgDataFolder LAG_SGLX PAIRED_CS_SS PAIRED_MF_SS PAIRED_MF_GO PAIRED_GO_SS PAIRED_MLI_SS PAIRED_SS_DCN ...
RAW_PRE_SPIKE RAW_POST_SPIKE RAW_RANDOM_N RAW_RANDOM_PER_TRIAL_N SAVE_LOCAL ...
PAIR_TYPE_ACG PAIR_TYPE_CS_SS PAIR_TYPE_MF_SS PAIR_TYPE_MF_GO PAIR_TYPE_GO_SS PAIR_TYPE_MLI_SS PAIR_TYPE_SS_SS PAIR_TYPE_MLI_MLI PAIR_TYPE_GO_GO PAIR_TYPE_SS_DCN ...
PAIR_TYPE_OTHER_SS PAIR_TYPE_OTHER_CS PAIR_TYPE_OTHER_MF PAIR_TYPE_OTHER_GO PAIR_TYPE_OTHER_MLI PAIR_TYPE_OTHER_OTHER...
PAIR_CS_SS_MAX_LAYER_DISTANCE PAIR_MF_SS_MAX_LAYER_DISTANCE PAIR_MF_GO_MAX_LAYER_DISTANCE PAIR_GO_SS_MAX_LAYER_DISTANCE PAIR_MLI_SS_MAX_LAYER_DISTANCE PAIR_SS_DCN_MAX_LAYER_DISTANCE PAIR_SS_SS_MAX_LAYER_DISTANCE PAIR_MLI_MLI_MAX_LAYER_DISTANCE PAIR_GO_GO_MAX_LAYER_DISTANCE PAIR_OTHER_MAX_LAYER_DISTANCE...
ACG CS_SS MF_SS MF_GO GO_SS MLI_SS SS_DCN SS_SS MLI_MLI GO_GO OTHER_SS OTHER_CS OTHER_MF OTHER_GO OTHER_MLI OTHER_OTHER ...
UNDEFINED P_VALUE_THRESHOLD X_LIM_ISI CCG_DEVIATION_RANGE CCG_DEVIATION_CRITERION ...
SS_ANALYSIS_RANGE CS_ANALYSIS_RANGE CHUNK_OF_REACTION_TIMES CHUNK_NAMES ...
ARR_DO_ANALYSES ANALYSIS_STEP_0 ANALYSIS_STEP_1 ANALYSIS_STEP_2_0 ANALYSIS_STEP_2_1 ANALYSIS_STEP_2_A ANALYSIS_STEP_2_B ANALYSIS_STEP_2_C ANALYSIS_STEP_3 ANALYSIS_STEP_4 ANALYSIS_STEP_5 ANALYSIS_STEP_6 ANALYSIS_STEP_7 ...
PLOT_00 PLOT_01 PLOT_10 PLOT_11 MIN_SAMPLE_SIZE TRIAL_CUT SOFT_CUT SOFT_CUT_PARTITION HARD_CUT HARD_CUT_PARTITION EXPERT_LABELS_TXT ...
SINGLE_UNIT MULTI_UNIT NOISE_UNIT UNPROCESSED_UNIT BIN_SIZE_CONTINUITY

localPath = fileparts(which(matlab.desktop.editor.getActiveFilename));
if ispc % If the OS is Windows
    pattern = '\';
else
    pattern = '/';
end
inds = strfind(localPath,pattern);
addpath(genpath(localPath(1:inds(length(inds))-1)))

globalsCommon;

UNDEFINED = -99; % For some data points that are undefined, not to be processed
SOFT_CUT = Inf;
SOFT_CUT_PARTITION = 1;
HARD_CUT = Inf;
HARD_CUT_PARTITION = 1;

BIN_SIZE_CONTINUITY = 20; % sec

SAVE_LOCAL = 1;

P_VALUE_THRESHOLD = 0.05;
X_LIM_ISI = 75;

SS_ANALYSIS_RANGE = [-.5 .5]; %[-.05 .05];
CS_ANALYSIS_RANGE = [-.075 .175];
CHUNK_OF_REACTION_TIMES = [-200 0 200 400 600 800]; % ms
CHUNK_NAMES = {'<=0','<=200','<=400','<=600','<=800'};

%MAX_PRE_RELEASE = 4; % There could be spikes at most 4 s (max randHold parameter in behavioral task)before the lever release

CCG_DEVIATION_RANGE = 0.01;
CCG_DEVIATION_CRITERION = 8;

RAW_PRE_SPIKE = 0.001; % sec before spike peak while reading raw data
RAW_POST_SPIKE = 0.003; % sec after spike peak while reading raw data
RAW_RANDOM_N = 2000;
RAW_RANDOM_PER_TRIAL_N = 200;

PAIR_TYPE_ACG = 0;
PAIR_TYPE_CS_SS = 1;
PAIR_TYPE_MF_SS = 2;
PAIR_TYPE_MF_GO = 3;
PAIR_TYPE_GO_SS = 4;
PAIR_TYPE_MLI_SS = 5;
PAIR_TYPE_SS_SS = 6;
PAIR_TYPE_MLI_MLI = 7;
PAIR_TYPE_GO_GO = 8;
PAIR_TYPE_SS_DCN = 9;

PAIR_TYPE_OTHER_SS = 10;
PAIR_TYPE_OTHER_CS = 11;
PAIR_TYPE_OTHER_MF = 12;
PAIR_TYPE_OTHER_GO = 13;
PAIR_TYPE_OTHER_MLI = 14;
PAIR_TYPE_OTHER_OTHER = 20;

ACG = 'ACG';
CS_SS = 'CS_SS';
MF_SS = 'MFB_SS';
MF_GO = 'MFB_GoC';
GO_SS = 'GoC_SS';
MLI_SS = 'MLI_SS';
SS_DCN = 'SS_DCN';
SS_SS = 'SS_SS';
MLI_MLI = 'MLI_MLI';
GO_GO = 'GoC_GoC';
OTHER_SS = 'Other_SS';
OTHER_CS = 'Other_CS';
OTHER_MF = 'Other_MFB';
OTHER_GO = 'Other_GoC';
OTHER_MLI = 'Other_MLI';
OTHER_OTHER = 'Other_Other';

PAIR_CS_SS_MAX_LAYER_DISTANCE = 1500; % (um) max layer distance between CS and SS
PAIR_MF_SS_MAX_LAYER_DISTANCE = 3000;
PAIR_MF_GO_MAX_LAYER_DISTANCE = 1500;
PAIR_GO_SS_MAX_LAYER_DISTANCE = 1500;
PAIR_MLI_SS_MAX_LAYER_DISTANCE = 1000;
PAIR_SS_DCN_MAX_LAYER_DISTANCE = 3000;
PAIR_SS_SS_MAX_LAYER_DISTANCE = 2000;
PAIR_MLI_MLI_MAX_LAYER_DISTANCE = 2000;
PAIR_GO_GO_MAX_LAYER_DISTANCE = 2000;
PAIR_OTHER_MAX_LAYER_DISTANCE = 2000;

PLOT_00 = 1;
PLOT_01 = 0;
PLOT_10 = 1;
PLOT_11 = 0;

MIN_SAMPLE_SIZE = 5;
PAIRED_CS_SS = [];
LAG_SGLX = 21; %ms
UNIT_OF_INTEREST = -1;

SINGLE_UNIT = 'unitSingle';
MULTI_UNIT = 'unitMulti';
NOISE_UNIT = 'unitNoise';
UNPROCESSED_UNIT = 'unitUnprocessed';

%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
%%%% DON'T FORGET TO RUN run1_getLickingData.m before TPrimeing *******
%************************************
% MOUSE_ID = '2829';
% depthDuringRecording = 3000;
% dateOfRecording = '20240320';
% SOFT_CUT = 2500; % sec. Get first N trials cos the mouse generated many misses
% SOFT_CUT_PARTITION = 1; % 1=Analyze between [0-SOFT_CUT] 2=Analyze between [SOFT_CUT-Inf]
% %UNIT_OF_INTEREST = -1;
% %************************************
% MOUSE_ID = '2829';
% depthDuringRecording = 3400;
% dateOfRecording = '20240326';
% SOFT_CUT = 1300; % sec. Get first N trials cos the mouse generated many misses
% SOFT_CUT_PARTITION = 1; % 1=Analyze between [0-SOFT_CUT] 2=Analyze between [SOFT_CUT-Inf]
% UNIT_OF_INTEREST = -1;
%************************************
% MOUSE_ID = '2829';
% depthDuringRecording = 3213;
% dateOfRecording = '20240327';
% SOFT_CUT = 1014; % sec. Get first 107 trials cos the mouse generated many misses
% SOFT_CUT_PARTITION = 1; % 1=Analyze between [0-SOFT_CUT] 2=Analyze between [SOFT_CUT-Inf]
%************************************
% MOUSE_ID = '2829';
% depthDuringRecording = 3200;
% dateOfRecording = '20240328';
% SOFT_CUT = 920; % Get first 100 trials cos rest is messed up with timing between two systems and the mouse already generated many misses
% SOFT_CUT_PARTITION = 1; % 1=Analyze between [0-SOFT_CUT] 2=Analyze between [SOFT_CUT-Inf]
%************************************
% MOUSE_ID = '2829';
% depthDuringRecording = 3200;
% dateOfRecording = '20240329';
% %UNIT_OF_INTEREST = 500; % 221; %

% %************************************
% MOUSE_ID = '2829';
% depthDuringRecording = 3300;
% dateOfRecording = '20240404';
% %UNIT_OF_INTEREST = 130; % 221; %
% %************************************
MOUSE_ID = '2829';
depthDuringRecording = 2500;
dateOfRecording = '20240403';
SOFT_CUT = 2005; % sec. Get first N trials cos the mouse generated many misses
%UNIT_OF_INTEREST = 130; % 221; %

%************************************
%%%%%%%%%%%%%%%%%%%%%%% PREVIOUS RECORDINGS %%%%%%%%%%%%%%%%%%%
%************************************
% MOUSE_ID = '2823';
% depthDuringRecording = 1361;
% dateOfRecording = '20231115';
% UNIT_OF_INTEREST = -1; %71; %331;
% LAG_SGLX = 21; %ms
% PAIRED_CS_SS = []; % the only good pair is [291 285]
% %SOFT_CUT = 1185; % (sec) Divide the recording into two from this point and analyze seperately
% %SOFT_CUT_PARTITION = 1; % 1=Analyze between [0-SOFT_CUT] 2=Analyze between [SOFT_CUT-Inf] 
%************************************

%************************************
% MOUSE_ID = '2823';
% depthDuringRecording = 3387;
% dateOfRecording = '20231104';
% UNIT_OF_INTEREST = -1; %71; %331;
% LAG_SGLX = 21; %ms
% PAIRED_CS_SS = []; % the only good pair is [291 285]
% TRIAL_CUT = 120; % Get all (-1 means don't cut) trials [1..TRIAL_CUT];
% SOFT_CUT = 1185; % (sec) Divide the recording into two from this point and analyze seperately
% SOFT_CUT_PARTITION = 1; % 1=Analyze between [0-SOFT_CUT] 2=Analyze between [SOFT_CUT-Inf] 
%************************************

%************************************
% MOUSE_ID = '2824';
% depthDuringRecording = 3009;
% dateOfRecording = '20231018';
% UNIT_OF_INTEREST = -1; %71; %331;
% LAG_SGLX = 21; %ms
% PAIRED_CS_SS = []; % the only good pair is [291 285]
% TRIAL_CUT = 50; % Get the trials [1..TRIAL_CUT];
% SOFT_CUT = 475; % (sec) Divide the recording into two from this point and analyze seperately
% SOFT_CUT_PARTITION = 1; % 1=Analyze between [0-SOFT_CUT] 2=Analyze between [SOFT_CUT-Inf] 
%************************************

%************************************
% MOUSE_ID = '2811';
% depthDuringRecording = 3795;
% dateOfRecording = '20230210_1';
% UNIT_OF_INTEREST = -1; %71; %331;
% LAG_SGLX = 21; %ms
% PAIRED_CS_SS = [[297 279]; [650 279]; [291 285]]; % the only good pair is [291 285]
% TRIAL_CUT = 150; % Get the trials [1..TRIAL_CUT];
% SOFT_CUT = 1540; % (sec) Divide the recording into two from this point and analyze seperately
% SOFT_CUT_PARTITION = 1; % 1=Analyze between [0-SOFT_CUT] 2=Analyze between [SOFT_CUT-Inf] 
%************************************

%************************************
% MOUSE_ID = '2811';
% depthDuringRecording = 3345;
% dateOfRecording = '20230201_1';
% UNIT_OF_INTEREST = 448; %132;
% LAG_SGLX = 21; %ms
% pathKS = [pathToRecFolder 'KS_OUT_3000/']; % Hard-Cut the recording in KS, got only between [0-3000 sec]
% PAIRED_CS_SS = [[441 439]; [441 440]];
% TRIAL_CUT = 342; % Get the trials [1..TRIAL_CUT];
% HARD_CUT = 3000; % (sec) Divide the recording into two from this point in Kilosort and analyze seperately
% HARD_CUT_PARTITION = 1; % 1=Analyze between [0-HARD_CUT] 2=Analyze between [HARD_CUT-Inf]
%************************************

%************************************
% MOUSE_ID = '2811';
% depthDuringRecording = 3195;
% dateOfRecording = '20230131_1';
% UNIT_OF_INTEREST = 116;
% LAG_SGLX = 21; %ms
% PAIRED_CS_SS = [[460 364]]; 
% TRIAL_CUT = 250; % Get the trials [1..TRIAL_CUT];
% SOFT_CUT = 2070; % (sec) Divide the recording into two from this point and analyze seperately
% SOFT_CUT_PARTITION = 1; % 1=Analyze between [0-SOFT_CUT] 2=Analyze between [SOFT_CUT-Inf] 
%************************************

% depthDuringRecording = 3200;
% dateOfRecording = '20221221_1';
% LAG_SGLX = 21; %ms
% UNIT_OF_INTEREST = -1; %173; %-1; % 11-MF [20-SS 23-CS]
% PAIRED_CS_SS = [[21 22]; [304 69]; [45 66]; [45 69]; [523 74]; [524 74]; [310 74]; [310 307]; [310 308]];
% PAIRED_MF_SS = []; % Compare MF vs SS in CCG to see if any interaction
% PAIRED_MF_GO = []; % Compare MF vs GO in CCG to see if any interaction
% PAIRED_GO_SS = [];% Compare GO vs SS in CCG to see if any interaction
%************************************
% depthDuringRecording = 2395;
% dateOfRecording = '20221222_1';
% FIXED_HOLD_START_TRIAL = 0;
% LAG_SGLX = 21; %ms
% UNIT_OF_INTEREST = -1; % 11-MF [20-SS 23-CS]
% PAIRED_SS_CS = [[];];    
%************************************
% depthDuringRecording = 2760; 
% dateOfRecording = '20221223_1';
% FIXED_HOLD_START_TRIAL = 4;
%LAG_SGLX = 12; %ms
%************************************
% depthDuringRecording = 2265; %1795;
% dateOfRecording = '20221201_2'; %'20221104';
% FIXED_HOLD_START_TRIAL = 124;

%LAG_HIT_SGLX = 76.1; % ms
%LAG_MISS_SGLX = 2164; % ms
%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%

if ispc % If the OS is Windows
    pathToParentRec = ['S:/Neuropixels/test_data/'];
    pathToRecFolder = [pathToParentRec dateOfRecording '_g0/'];
else
    if SAVE_LOCAL
        pathToParentRec = ['/mnt/DriveG/sevgi/Neuropixels/test_data/']; % to avoid network traffic on NB-LAMBDAHULL
    else
        pathToParentRec = ['/mnt/IsilonPerm/Neuropixels/test_data/'];
    end
    pathToRecFolder = [pathToParentRec dateOfRecording '_g0/'];
end

%if atLab
    pathToUnitsDataFolder = [pathToRecFolder 'data/'];    
% else
%     pathToUnitsDataFolder = ['C:/sevgi/Neuropixels/test_data/' dateOfRecording '_g0/data/'];
% end
if ~exist(pathToUnitsDataFolder)
    mkdir(pathToUnitsDataFolder);
end

if isempty(pathKS) % if it is not defined yet within one of the recordings
    pathKS = [pathToRecFolder 'KS_OUT/']; % KS_OUT_stagg
end
pathTPrime = [pathToRecFolder 'TPrime_OUT/']; % TPrime_OUT2D/
%pathNpyxFiltered = [pathToRecFolder 'NeuroPyxels/'];
pathNpyxOrgDataFolder = [pathNpyxFiltered 'original_data/'];

chList = 1:384;
tipLength = 195;

HOLD_LEVER_TXT = 'holdLever.txt';
RELEASE_LEVER_TXT = 'releaseLever.txt';
VIS_STIM_ON_TXT = 'visStimOn.txt';
VIS_STIM_OFF_TXT = 'visStimOff.txt';
LICK_ONSET_TXT = 'lickOnsetTimes.txt';
LICK_OFFSET_TXT = 'lickOffsetTimes.txt';
REWARD_ONSET_TXT = 'rewardOn.txt';
REWARD_OFFSET_TXT = 'rewardOff.txt';

EXPERT_LABELS_TXT = 'expertLabels.txt';

UNITS_FILE_NAME = ['units_' dateOfRecording '_' num2str(SOFT_CUT) '_part' num2str(SOFT_CUT_PARTITION) '.mat'];
UNITS_AND_VARS_FILE_NAME = ['unitsAndVars_' dateOfRecording '_' num2str(SOFT_CUT) '_part' num2str(SOFT_CUT_PARTITION) '.mat'];

pathToFigureFolder = [pathToRecFolder 'analysis_OUT_' num2str(SOFT_CUT) '_part' num2str(SOFT_CUT_PARTITION) '/'];
if ~exist(pathToFigureFolder)
    mkdir(pathToFigureFolder);
end

pathToCurationHelperFolder = [pathToFigureFolder 'curationHelper/'];
if ~exist(pathToCurationHelperFolder)
    mkdir(pathToCurationHelperFolder);
end

% Which digital word to read. 
% For imec, there is only 1 digital word, dw = 0.
% For NI, digital lines 0-15 are in word 1, lines 16-31 are in word 2, etc.
% (1-based for MATLAB)
dw = 1;

% Read these lines in dw (0-based). For 3B2 imec data: the sync pulse is stored in line 6.
% Which lines within the digital word, zero-based 
digitalChList = [0,5,6]; % 0 synch, 5 trial start/stop (hold/release lever), 6 Visual Stim ON/OFF

ANALYSIS_STEP_0 = 0; % Behavioral Analyses
ANALYSIS_STEP_1 = 1; % Plot raster & PSTH (Qualitative)
ANALYSIS_STEP_2_0 = 2; % Plot ACGs (Qualitative)
ANALYSIS_STEP_2_1 = 20; % Plot CCG pairs (Qualitative)
ANALYSIS_STEP_2_A = 21; % Check Two Conseq Trials for CS-SS
ANALYSIS_STEP_2_B = 22; % Check CS-SS and BehavEventTimes
ANALYSIS_STEP_2_C = 23; % plotPairedRaster
ANALYSIS_STEP_3 = 3; % Compare FR & ISI (Quantitative)
ANALYSIS_STEP_4 = 4; % Read & plot waveform
%ANALYSIS_STEP_5 = 5; % Reaction time based analyses
ANALYSIS_STEP_6 = 6; % Lick related activity analyses
ANALYSIS_STEP_7 = 7; % Omission trials activity analyses

ARR_DO_ANALYSES = [1,2,4]; %[0,1,2,20,4];

logger = log4m.getLogger([pathToFigureFolder 'neuralAnalysis.log']);
logger.setCommandWindowLevel(logger.ALL); 
logger.setLogLevel(logger.ALL);

