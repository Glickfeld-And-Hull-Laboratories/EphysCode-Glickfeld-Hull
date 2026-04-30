global logger RECORDING_DAY_OF_INTEREST pathToParentRec ALL_RECORDINGS_FILE pathToFigureFolder...
    DO_RATE_CORRECTED RECORDINGS_TO_POOL STRONGLY_COUPLED_PAIRS WEAKLY_COUPLED_PAIRS...
    PLOT_INDIVIDUAL_PAIRS ANALYSIS_STEP_0 ANALYSIS_STEP_4 ARR_DO_ANALYSES


localPath = fileparts(which(matlab.desktop.editor.getActiveFilename));
if ispc % If the OS is Windows
    pattern = '\';
else
    pattern = '/';
end
inds = strfind(localPath,pattern);
addpath(genpath(localPath(1:inds(length(inds))-1))); % Adds one-level-up directory into the path to reach shared functions

if ispc % If the OS is Windows
    pathToParentRec = ['S:/Neuropixels/ephapticRecordings/'];
else
    pathToParentRec = ['/mnt/IsilonPerm/Neuropixels/ephapticRecordings/'];   
end

ALL_RECORDINGS_FILE = [pathToParentRec 'pooled/allData/allRecordings.mat'];
pathToFigureFolder = [pathToParentRec 'pooled/analysis_OUT/'];
if ~exist(pathToFigureFolder)
    mkdir(pathToFigureFolder);
end

DO_RATE_CORRECTED = 1;
RECORDING_DAY_OF_INTEREST = -1;

ANALYSIS_STEP_0 = 0; 
ANALYSIS_STEP_4 = 4; % CCGs
ARR_DO_ANALYSES = [4]; %[0,1,2,3,4,5];

logger = log4m.getLogger([pathToFigureFolder 'neuralAnalysis.log']);
logger.setCommandWindowLevel(logger.ALL); 
logger.setLogLevel(logger.ALL);

RECORDINGS_TO_POOL = {'20250220_ephaptic_3606_g0', '20250226_ephaptic_3606_g0', ...
    '202503014_ephaptic_3610_g0', '20250320_ephaptic_3610_g0', '20250612_ephaptic_3611_g0', ...
    '20250613_ephaptic_3613_g0', '20250625_ephaptic_3615_g0'};
                          % Recording Day               MLIs                        SSs
STRONGLY_COUPLED_PAIRS = {'20250220_ephaptic_3606_g0', [317, 338, 317, 338, 317], [307, 307, 315, 315, 316];
'20250226_ephaptic_3606_g0', [743, 743, 736, 743, 736, 743, 736, 743, 750, 758, 820, 831, 820, 831, 846, 831, 820, 846, 846, 846, 846], ...
[701, 710, 711, 711, 716, 716, 735, 735, 735, 735, 862, 862, 863, 863, 863, 866, 866, 866, 877, 882, 893];
'20250320_ephaptic_3610_g0', [262, 262, 293, 293, 293, 293], [265, 279, 285, 286, 294, 304];
'20250612_ephaptic_3611_g0', [514, 514, 514, 527, 555], [515, 517, 529, 529, 529];
'20250613_ephaptic_3613_g0', [541, 541, 541, 541, 599, 599, 599, 599, 599, 599], [538, 848, 849, 573, 848, 573, 849, 594, 610, 615];
'20250625_ephaptic_3615_g0', [108, 112], [122, 122]
};
                        % Recording Day               MLIs                        SSs
WEAKLY_COUPLED_PAIRS = {%'20250220_ephaptic_3606_g0', [338], [316]; %[93, 338], [122, 316];
'20250226_ephaptic_3606_g0', [699, 736, 736, 758, 750, 758, 750, 758, 829, 846, 829, 820, 831], ... % [282, 699, 736, 736, 758, 750, 758, 750, 758, 829, 846, 829, 820, 831], ...
[701, 701, 710, 710, 711, 711, 716, 716, 862, 862, 863, 882, 882]; % [286, 701, 701, 710, 710, 711, 711, 716, 716, 862, 862, 863, 882, 882];
%'202503014_ephaptic_3610_g0', [357, 357, 357], [373, 374, 392];
'20250320_ephaptic_3610_g0', [232, 248], ... % [213, 232, 248, 232, 248, 248, 262, 262, 298, 298, 298], ...
[238, 238]; % [238, 238, 238, 251, 251, 265, 251, 285, 286, 294, 304];
%'20250612_ephaptic_3611_g0', [560], [529];
'20250613_ephaptic_3613_g0', [599, 599, 599], [588, 636, 652]
};
