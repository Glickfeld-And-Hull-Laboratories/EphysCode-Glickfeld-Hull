% 
% runCatGT_SG runs two commands that pull the timestamps of events from the 
% nidaq stream (stimulus on events) and the imec stream (chassis pulse
% aligned to spike times)
%
% Inputs:
%   date    = date of experiment
% Outputs:
%   catgt_ folder
%
% Outputs located in Analysis/Neuropixel/date folder.
%

function runCatGTret_SG(date)

% Set base directories
    dataDir     = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\jerry\data\neuropixel\';
    analysisDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\jerry\analysis\neuropixel\';

% Construct full data path
    fullDataPath = fullfile(dataDir, date);

% Get list of folders in the specified date directory
    dirContents = dir(fullDataPath);
    runFolders  = {dirContents([dirContents.isdir] & ~ismember({dirContents.name}, {'.', '..'})).name};

% Check if exactly one folder is found
    if isempty(runFolders)
        error('No run folder found in %s', fullDataPath);
    elseif numel(runFolders) > 1
        error('  *runCatGT_SG* Multiple run folders found in %s. Please check the data and experiment structure.', fullDataPath);
    end

% Get full run folder and name
    runFolder = fullfile(fullDataPath, runFolders{1});

% Get run name minus experimental run digits
    runName = runFolders{1};
    runName = regexprep(runName, '(_imec0)$', '');    % Remove _imec0 ending on file name
    runName = regexprep(runName, '(_[gt]\d+)$', '');    % Remove '_gN' or '_tN' at the end if present
        % _ matches underscore
        % [gt] matches either g or t
        % \d+ matches one or more digits (i.e., any number after g or t)
        % $ ensures this pattern is only removed if it's at the end of
        % runNAme
    runName = regexprep(runName, '(_[gt]\d+)$', '');    % Run twice, in case there is _gN_tN

% Extract gN and tN from the .bin filename
    binFiles = dir(fullfile(runFolder, '*.imec0.ap.bin'));  % Locate .bin file inside runFolder
    if isempty(binFiles)
        error('No .bin file found in %s', runFolder);
    elseif numel(binFiles) > 1
        error('Multiple .bin files found in %s. Check data folder.', runFolder);
    end
    binFileName = binFiles(1).name;
    exptdigits  = regexp(binFileName, '_g(\d+)_t(\d+)', 'tokens');   % Find digits associated with gN and tN
    if isempty(exptdigits)
        error('Could not extract gN and tN from %s', binFileName);
    end    
    gNum = exptdigits{1}{1}; % Extract gN
    tNum = exptdigits{1}{2}; % Extract tN

% Construct terminal commands with detected gNum and tNum
    cmd1 = sprintf('CatGT -dir=%s -run=%s -g=%s -t=%s -prb=0 -ni -xd=0,0,0,0,0 -xd=0,0,0,1,0 -xd=0,0,0,2,0 -xd=0,0,0,5,0 -dest=%s', fullDataPath, runName, gNum, tNum, fullfile(analysisDir, date));   % Pull nidaq channel timestamps
        % channel 0 is chassis
        % channel 1 is mworks stim on signal
        % channel 2 is multiclamp protocol
        % channel 5 is photodiode
    cmd2 = sprintf('CatGT -dir=%s -run=%s -g=%s -t=%s -prb=0 -ap -xd=2,0,-1,6,500 -no_auto_sync -dest=%s', fullDataPath, runName, gNum, tNum, fullfile(analysisDir, date));    % Pull neural data sync pulse timestamps
        % We expect it to be 500 ms long, on the last (i.e., -1) channel and on bit 6 (7th input) of that channel

% Execute commands
    cd('C:\Users\smg92\Desktop\CatGTWinApp4.3\CatGT-win');
    system(cmd1);
    system(cmd2);

end