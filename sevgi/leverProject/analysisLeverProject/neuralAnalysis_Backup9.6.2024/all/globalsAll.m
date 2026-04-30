
global logger pathToParentRec pathToBehavFolder pathToBehavDataOfRecFolder pathToFigureFolder ALL_RECORDINGS_FILE RECORDING_DAY_OF_INTEREST BEHAV_MEASURES_FOLDER BEHAV_MEASURES_OF_REC_DAYS_FOLDER RESPONSE_TYPES_FOLDER CELL_TYPES_FOLDER REACTION_TIME_FOLDER HEATMAP_FOLDER ...
    RECORDINGS_TO_POOL RECORDINGS_GOOD_RT RECORDINGS_MODERATE_RT RECORDINGS_BAD_RT RECORDINGS_UNPROCESSED ...    
    TRIAL_COUNT_GOOD TRIAL_COUNT_MODERATE TRIAL_COUNT_POOLED CUT_SMOOTHER_EFFECT_ON_EDGES ...
    ANALYSIS_STEP_0 ANALYSIS_STEP_0_0 ANALYSIS_STEP_1 ANALYSIS_STEP_2 ANALYSIS_STEP_3 ANALYSIS_STEP_4 ANALYSIS_STEP_5 ARR_DO_ANALYSES ...
    MEDIAN_RT_POOLED MOUSE_IDS BEHAV_DAYS_FOLDER REC_DAYS_FOLDER BEHAV_DAYS_FILES REC_DAYS_FILES BEHAV_OF_RECORDING_DAYS

% REACT_FAST_BAND = [-4000 750]; % ms
% REACT_SLOW_BAND = [1000 3000]; % ms
CUT_SMOOTHER_EFFECT_ON_EDGES = 0.08;

localPath = fileparts(which(matlab.desktop.editor.getActiveFilename));
if ispc % If the OS is Windows
    pattern = '\';
else
    pattern = '/';
end
inds = strfind(localPath,pattern);
addpath(genpath(localPath(1:inds(length(inds))-1)))

globalsCommon;

if ispc % If the OS is Windows
    pathToParentRec = ['S:/Neuropixels/test_data/'];
else
%     if SAVE_LOCAL
%         pathToRecFolder = ['/mnt/DdriveL/sevgi/Neuropixels/test_data/' dateOfRecording '_g0/']; % to avoid network traffic on NB-LAMBDAHULL
    %pathToParentRec = ['/home/sot5@dhe.duke.edu/IsilonSevgi/Neuropixels/test_data/'];
    pathToParentRec = ['/mnt/IsilonPerm/Neuropixels/test_data/'];
end

if ispc % If the OS is Windows
    pathToBehavFolder = ['S:/Neuropixels/BehavioralDataToCompareWRecordingDay/'];
    pathToBehavDataOfRecFolder = ['S:/Neuropixels/BehavioralDataOfRecordings/'];
else
    pathToBehavFolder = ['/mnt/IsilonPerm/Neuropixels/BehavioralDataToCompareWRecordingDay/'];
    pathToBehavDataOfRecFolder = ['/mnt/IsilonPerm/Neuropixels/BehavioralDataOfRecordings/'];
end

ALL_RECORDINGS_FILE = [pathToParentRec 'pooled/allData/allRecordings.mat'];
pathToFigureFolder = [pathToParentRec 'pooled/analysis_OUT/'];
if ~exist(pathToFigureFolder)
    mkdir(pathToFigureFolder);
end

BEHAV_MEASURES_FOLDER = 'behavioralMeasures/';
if ~exist([pathToFigureFolder BEHAV_MEASURES_FOLDER])
    mkdir([pathToFigureFolder BEHAV_MEASURES_FOLDER]);
end

BEHAV_MEASURES_OF_REC_DAYS_FOLDER = 'behavioralMeasuresOfRecDays/';
if ~exist([pathToFigureFolder BEHAV_MEASURES_OF_REC_DAYS_FOLDER])
    mkdir([pathToFigureFolder BEHAV_MEASURES_OF_REC_DAYS_FOLDER]);
end

RESPONSE_TYPES_FOLDER = 'wrtResponseTypesOfCellTypes/';
if ~exist([pathToFigureFolder RESPONSE_TYPES_FOLDER])
    mkdir([pathToFigureFolder RESPONSE_TYPES_FOLDER]);
end

CELL_TYPES_FOLDER = 'wrtCellTypes/';
if ~exist([pathToFigureFolder CELL_TYPES_FOLDER])
    mkdir([pathToFigureFolder CELL_TYPES_FOLDER]);
end

REACTION_TIME_FOLDER = 'wrtReactionTime/';
if ~exist([pathToFigureFolder REACTION_TIME_FOLDER])
    mkdir([pathToFigureFolder REACTION_TIME_FOLDER]);
end

HEATMAP_FOLDER = 'heatMap/';
if ~exist([pathToFigureFolder HEATMAP_FOLDER])
    mkdir([pathToFigureFolder HEATMAP_FOLDER]);
end

RECORDING_DAY_OF_INTEREST = -1;

ANALYSIS_STEP_0 = 0; % Behavioral Analyses
ANALYSIS_STEP_0_0 = 0.1; % Compare ReactionTimes of previous day's behavioral data VS behavioral data of next day(s)' Recording
ANALYSIS_STEP_1 = 1; % Plot raster & PSTH (Qualitative)
ANALYSIS_STEP_2 = 2; % Plot raster & PSTH WRT Response Type (Facilitation or suppression)
ANALYSIS_STEP_3 = 3; % Slow vs Fast Reaction Time Analyses
ANALYSIS_STEP_4 = 4; % Slow vs Fast Reaction Time Analyses WRT Response types (Facilitation or suppression)
ANALYSIS_STEP_5 = 5; % Heatmap analysis

ARR_DO_ANALYSES = [1]; %[0,1,2,3,4];

logger = log4m.getLogger([pathToFigureFolder 'neuralAnalysis.log']);
logger.setCommandWindowLevel(logger.ALL); 
logger.setLogLevel(logger.ALL);

RECORDINGS_GOOD_RT = {'20240329_g0','20240328_g0','20240327_g0','20240326_g0'}; % recordings with reaction time has a decreasing trend
RECORDINGS_MODERATE_RT = {}; %'20230201_1_g0', '20231104_g0', '20231115_g0'}; % recordings with slow vs fast RTs
RECORDINGS_BAD_RT = {'20230210_1_g0', '20231018_g0'}; % no prediction happened during the recording based on RT - no difference with reaction (random) task
RECORDINGS_TO_POOL = {RECORDINGS_GOOD_RT{:}, RECORDINGS_MODERATE_RT{:}};
RECORDINGS_UNPROCESSED = {'20231121_g0', '20231206_g0', '20231211_g0', '20231213_g0', '20231215_g0', '20240111_g0'};
% {'20231116_g0', '20231118_g0', '20231121_g0', '20231124_g0', '20231130_g0', '20231206_g0', '20231207_g0', '20231208_g0', '20231211_g0', '20231213_g0', '20231215_g0', '20240111_g0', '20240112_g0'};

TRIAL_COUNT_GOOD = [250];
TRIAL_COUNT_MODERATE = [342, 120, 379];
TRIAL_COUNT_POOLED = [TRIAL_COUNT_GOOD, TRIAL_COUNT_MODERATE];

MEDIAN_RT_POOLED = [347, 315, 736, 411];

%%%%%%%%%%% For Behavioral Analysis %%%%%%%%%%%%%%
MOUSE_IDS = {'2823'};
BEHAV_DAYS_FOLDER = 'BehavDays';
REC_DAYS_FOLDER = 'RecordingDays';
BEHAV_DAYS_FILES = {'data-i2823-231018-1729.mat', 'data-i2823-231027-1609.mat', 'data-i2823-231102-1432.mat', 'data-i2823-231114-1434.mat', 'data-i2823-231117-1717.mat', 'data-i2823-231120-1611.mat', 'data-i2823-231128-1613.mat', 'data-i2823-231204-1604.mat', 'data-i2823-240110-1613.mat'};
REC_DAYS_FILES = {{'data-i2823-231019-1750.mat'}, {'data-i2823-231028-1957.mat'}, {'data-i2823-231103-1410.mat', 'data-i2823-231104-1737.mat'}, {'data-i2823-231115-1559.mat', 'data-i2823-231116-1811.mat'}, {'data-i2823-231118-1852.mat'}, {'data-i2823-231121-1737.mat', 'data-i2823-231123-1712.mat', 'data-i2823-231124-1658.mat'}, {'data-i2823-231130-1700.mat'}, {'data-i2823-231206-1640.mat', 'data-i2823-231207-1645.mat', 'data-i2823-231208-1648.mat'}, {'data-i2823-240111-1623.mat'}};

BEHAV_OF_RECORDING_DAYS = {};
