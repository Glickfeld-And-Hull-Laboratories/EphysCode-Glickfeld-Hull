
function [stimStruct] = NPXcreateStimStructMulti(exptStruct)

    mwtime = exptStruct.exptTime;
    mouse = exptStruct.mouse;
    date = exptStruct.date;
    sessions = exptStruct.exptType;

    % Load MWorks stimulus information
    if class(mwtime) == "char"
        mwtime2use = 1;
        bName = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\Behavior\Data\data-' mouse '-' date '-' mwtime '.mat'];
        S = load(bName); %#ok<LOAD>
        inputStruct = S.input;
    elseif class(mwtime) == "cell" & size(mwtime,2) == 1
        mwtime2use = 1;
        bName = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\Behavior\Data\data-' mouse '-' date '-' mwtime{1,1} '.mat'];
        S = load(bName); %#ok<LOAD>
        inputStruct = S.input;
    elseif class(mwtime) == "cell" & size(mwtime,2) > 1
        exptStr = string(sessions);
        mwtimeStr = string(mwtime);
        exptANDmwtime = {exptStr;mwtimeStr};
        warning('Multiple times exist, inspect all experiments and times in this session here.');
        exptANDmwtime
        nMWs = length(mwtimeStr);
        for t = 1:nMWs
            disp([num2str(t) ': ' char(mwtimeStr(t))]);
        end
        mwtime2use = input('Select mWorks time to use (enter 1 number or multiple in brackets. e.g, [3 4]): ');
        if isscalar(mwtime2use) % concat multiple structs if needed
            bName = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\Behavior\Data\data-' mouse '-' date '-' char(mwtimeStr(mwtime2use)) '.mat'];
            S = load(bName); %#ok<LOAD>
            inputStruct = S.input;
        else
            nMWtimes = length(mwtime2use);
            for i = 1:nMWtimes
                bName = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\Behavior\Data\data-' mouse '-' date '-' char(mwtimeStr(mwtime2use(i))) '.mat'];
                S = load(bName);
                if i == 1
                    inputStruct = S.input;
                else
                    inputStruct(i) = S.input;
                end
            end
        end
    end
        
    % S = load(bName); %#ok<LOAD>
    % inputStruct = S.input;
    
    
    for i = 1:length(mwtime2use)
        stimStruct(i).stimElevation    = cell2mat_doubles(inputStruct(i).tGratingElevationDeg);
        stimStruct(i).stimAzimuth      = cell2mat_doubles(inputStruct(i).tGratingAzimuthDeg);
        stimStruct(i).centerDirs       = cell2mat(inputStruct(i).tGratingDirectionDeg);
        stimStruct(i).stimSpatialFreq  = double(inputStruct(i).gratingSpatialFreqCPD);
        stimStruct(i).stimDuration     = str2double(exptStruct.stimDur{mwtime2use(i)});    % Stimulus duration in seconds
        if isfield(inputStruct,'tSurroundGratingDirectionDeg')
            tSurroundDirs       = cell2mat(inputStruct(i).tSurroundGratingDirectionDeg);
            tDoCenter           = cell2mat(inputStruct(i).tDoCenterGrating);
            tDoSurround         = cell2mat(inputStruct(i).tDoSurroundGrating);
            tCenterDirs         = cell2mat(inputStruct(i).tGratingDirectionDeg);
            trialTypes          = getIsoCrossTrialType(tCenterDirs,tSurroundDirs,tDoCenter,tDoSurround);
            stimStruct(i).surroundDirs     = tSurroundDirs;
            stimStruct(i).trialTypes       = trialTypes;
        end
    end

% Load sync'd stim on timing information (both MWorks signal and photodiode)
    cd (fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\',exptStruct.loc,'\analysis\Neuropixel\',exptStruct.mouse,exptStruct.date))        % Move from KS_Output folder to ...\Analysis\neuropixel\date folder, where TPrime output is saved
    
    nSesh = length(sessions);
    disp(['This session had ' num2str(nSesh) ' experiments:'])
    for sesh = 1:nSesh
        disp([num2str(sesh) '. ' sessions{sesh}]);
    end
    currentExptNum = input('Enter session number corresponding to the NAME OF NEURAL RECORDING to pull mWorks and photodiode signal from (0 to use "runName" from struct): ');
    if currentExptNum == 0
        currentExptName = exptStruct.runName;
    else
        currentExpt = sessions{currentExptNum};
        currentExptName = currentExpt;
    end
    CGTFolder = ['catgt_' exptStruct.mouse '-' exptStruct.date '-CrossOriContrast-' currentExptName '_g0'];

    stimOnTimestampsMW  = table2array(readtable(fullfile(CGTFolder,[mouse '_' date '_mworksStimOnSync.txt'])));
    stimOnTimestampsPD  = table2array(readtable(fullfile(CGTFolder,[mouse '_' date '_photodiodeSync.txt'])));

% Lonely TTL removal
    lonelyThreshold = 0.050; % 50 ms
    timeDiffs       = abs(diff(stimOnTimestampsPD));  % Compute pairwise differences efficiently
    hasNeighbor = [false; timeDiffs < lonelyThreshold] | [timeDiffs < lonelyThreshold; false]; % Identify indices where a close neighbor exists
    filteredPD = stimOnTimestampsPD(hasNeighbor);   % Keep only timestamps that have a neighbor within 50 ms

% Account for report of the monitor's refresh rate in the photodiode signal
    minInterval = 0.4; % Define a minimum separation threshold (should be longer than a refresh cycle but shorter than ISI)     
    leadingEdgesPD = filteredPD([true; diff(filteredPD) > minInterval]); % Extract the leading edges (first timestamp of each stimulus period)
    % [true; ...] ensures that the very first timestamp is always included because otherwise diff() returns an array that is one element shorter than the original.

% Check that PD signal starts at same time as MW signal; sometimes there are errant PD signals 
    firstMW = stimOnTimestampsMW(1); % Get the first MW timestamp
    leadingEdgesPD = leadingEdgesPD(leadingEdgesPD >= firstMW); % Remove any PD timestamps that occur before the first MW timestamp

% Find stimulus blocks and separate stim on timestamps
    threshold       = 30; % Time gap to define a break (in seconds)
    breakIndices    = find(diff(leadingEdgesPD) > threshold); % Find the indices where the gap between timestamps exceeds the threshold
    stimBlocks      = cell(length(breakIndices) + 1, 1); % Initialize a cell array to store stimulus blocks
 
    startIdx = 1;
    for i = 1:length(breakIndices) % Extract stimulus blocks
        endIdx          = breakIndices(i);
        stimBlocks{i}   = leadingEdgesPD(startIdx:endIdx);
        startIdx        = endIdx + 1;
    end
    stimBlocks{end} = leadingEdgesPD(startIdx:end); % Store the last block
    for block = 1:length(stimBlocks)
        if length(stimBlocks{block}) < 20
            stimBlocks{block} = [];
        end
    end
    stimBlocksClean = stimBlocks(~cellfun('isempty',stimBlocks));
    if length(stimBlocksClean) > 1
        for i = 1:length(stimBlocksClean)
            disp([num2str(i) ': ' num2str(length(stimBlocksClean{i})) ' trials'])
        end
        stimBlock2use = input('Stim on timing cell array has multiple blocks, choose the ones to save: ');
        stimBlockFinal = stimBlocksClean(stimBlock2use);
    else
        stimBlockFinal = stimBlocksClean{1};
    end
% Create stimStruct
    for i = 1:length(stimBlockFinal)
        stimStruct(i).timestamps       = stimBlockFinal{i};   % Cell array (number of stim blocks long) containing all stim on timestamps within each block
        % stimStruct.stimTemporalFreq = stimTemporalFreq;
    end
    fields = fieldnames(stimStruct);
    nTrials = length(stimStruct(1).timestamps);
    for i = 1:numel(fields)
        fieldName = fields{i};
        fieldValue = stimStruct.(fieldName);
        if length(fieldValue) > nTrials
            stimStruct.(fieldName) = fieldValue(1:nTrials);
        end
    end


end

