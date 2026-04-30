
global logger pathToParentRec pathToFigureFolder ALL_RECORDINGS_FILE RECORDING_DAY_OF_INTEREST RESPONSE_TYPES_FOLDER CELL_TYPES_FOLDER REACTION_TIME_FOLDER RECORDINGS_TO_POOL

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

ALL_RECORDINGS_FILE = [pathToParentRec 'pooled/allData/allRecordings.mat'];
pathToFigureFolder = [pathToParentRec 'pooled/analysis_OUT/'];
if ~exist(pathToFigureFolder)
    mkdir(pathToFigureFolder);
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

RECORDING_DAY_OF_INTEREST = -1;

ANALYSIS_STEP_0 = 0; % Behavioral Analyses
ANALYSIS_STEP_1 = 1; % Plot raster & PSTH (Qualitative)
ANALYSIS_STEP_2 = 2; % Plot raster & PSTH WRT Response Type (Facilitation or suppression)
ANALYSIS_STEP_3 = 3; % Reaction Time Analyses

ARR_DO_ANALYSES = [3]; %[0,1,2,3,4];

logger = log4m.getLogger([pathToFigureFolder 'neuralAnalysis.log']);
logger.setCommandWindowLevel(logger.ALL); 
logger.setLogLevel(logger.ALL);

RECORDINGS_TO_POOL = {'20230131_1_g0', '20230201_1_g0', '20230210_1_g0', '20231104_g0', '20231115_g0'};