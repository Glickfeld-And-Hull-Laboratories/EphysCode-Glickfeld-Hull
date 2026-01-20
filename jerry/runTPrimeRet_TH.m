% 
% runTPrime_SG syncs the times of events on nidaq to spike times.
%
% Inputs:
%   date    = date of experiment
% Outputs:
%   _mworksStimOnSync.txt
%   _photodiodeSync.txt
%
% Outputs located in Analysis/Neuropixel/date folder.
%

function runTPrimeRet_SG(date)

% Set base directories
    dataDir     = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\jerry\data\neuropixel\';
    analysisDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\jerry\analysis\neuropixel\';

% Construct full data path
    mkdir(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\jerry\analysis\neuropixel\' date '\retinotopy'])
    fullAnalysisPath    = fullfile(analysisDir, date);

% Get list of folders in the specified date directory
    dirContents   = dir(fullAnalysisPath);
    catgtFolders  = {dirContents([dirContents.isdir] & startsWith({dirContents.name}, 'catgt') & contains({dirContents.name}, 'retinotopy')).name};

% Check if exactly one catgt folder is found
    if isempty(catgtFolders)
        error('No catgt folder found in %s', fullAnalysisPath);
    elseif numel(catgtFolders) > 1
        error('*runTPrime_SG* Multiple catgt folders found in %s. Check analysis folder.', fullAnalysisPath);
    end

% Use the detected catgt folder
    catgtFolder = fullfile(fullAnalysisPath, catgtFolders{1});

% Extract run name from catgt folder
    runName = regexprep(catgtFolders{1}, '^catgt_', ''); % Remove 'catgt_' prefix

% Construct paths for TPrime
    baseFileName        = fullfile(catgtFolder, [runName, '_tcat']);
    spikeSyncFile       = [baseFileName, '.imec0.ap.xd_384_6_500.txt'];
    nidaqSync           = [baseFileName, '.nidq.xd_0_0_500.txt'];   % ndiaq clock signal
    nidaqMWevents       = [baseFileName, '.nidq.xd_0_1_0.txt']; % mworks stim on events
    nidaqPDevents       = [baseFileName, '.nidq.xd_0_5_0.txt']; % photodiode events
    mworksStimOnSync    = fullfile(fullAnalysisPath, '\retinotopy', [date, '_mworksStimOnSync.txt']);   % Output file for MWorks stim on signal
    photodiodeSync      = fullfile(fullAnalysisPath, '\retinotopy',[date, '_photodiodeSync.txt']);   % Output file for photodiode stim on signal

% Construct the TPrime command
    cmd = sprintf(['TPrime -syncperiod=1.000000 ' '-tostream=%s ' '-fromstream=1,%s ' '-events=1,%s,%s ' '-events=1,%s,%s'], spikeSyncFile, nidaqSync, nidaqMWevents, mworksStimOnSync, nidaqPDevents, photodiodeSync);

% Execute the command in the Windows terminal
    cd('C:\Users\th352\Desktop\TPrime-win');
    system(cmd);

end





