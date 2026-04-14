
function [stimStruct] = NPXcreateStimStruct(exptStruct)

    mwtime = exptStruct.exptTime;
    mouse = exptStruct.mouse;
    date = exptStruct.date;
    sessions = exptStruct.exptType;

    % Load MWorks stimulus information
        if class(mwtime) == "char"
            mwtime2use = 1;
            bName = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\Behavior\Data\data-' mouse '-' date '-' mwtime '.mat'];
        elseif class(mwtime) == "cell" & size(mwtime,2) == 1
            mwtime2use = 1;
            bName = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\Behavior\Data\data-' mouse '-' date '-' mwtime{1,1} '.mat'];
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
            mwtime2use = input('Select mWorks time to use (enter number): ');
            bName = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\Behavior\Data\data-' mouse '-' date '-' char(mwtimeStr(mwtime2use)) '.mat'];
        end
        
        S = load(bName); %#ok<LOAD>
        inputStruct = S.input;
        
        stimElevation       = double(cell2mat(inputStruct.tGratingElevationDeg));
        stimAzimuth         = double(cell2mat(inputStruct.tGratingAzimuthDeg));
        tCenterDirs         = cell2mat(inputStruct.tGratingDirectionDeg);
        tSurroundDirs       = cell2mat(inputStruct.tSurroundGratingDirectionDeg);
        tDoCenter           = cell2mat(inputStruct.tDoCenterGrating);
        tDoSurround         = cell2mat(inputStruct.tDoSurroundGrating);
        stimSpatialFreq     = double(inputStruct.gratingSpatialFreqCPD);
        % stimTemporalFreq    = double(inputStruct.gratingTemporalFreqCPS);

        trialTypes          = getIsoCrossTrialType(tCenterDirs,tSurroundDirs,tDoCenter,tDoSurround);

    % Load stim on information (both MWorks signal and photodiode)
        cd (fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\',exptStruct.loc,'\analysis\Neuropixel\',exptStruct.mouse,exptStruct.date))        % Move from KS_Output folder to ...\Analysis\neuropixel\date folder, where TPrime output is saved
        
        nSesh = length(sessions);
        disp(['This session had ' num2str(nSesh) ' experiments:'])
        for sesh = 1:nSesh
            disp([num2str(sesh) '. ' sessions{sesh}]);
        end
        currentExptNum = input('Enter number of experiment to pull mWorks and photodiode signal from: ');
        currentExpt = sessions{currentExptNum};
        
        CGTFolder = ['catgt_' exptStruct.mouse '-' exptStruct.date '-CrossOriContrast-' currentExpt '_g0'];

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
            stimBlock2use = input('Stim on timing cell array has multiple blocks, choose the one to use: ');
            stimBlockFinal = stimBlocksClean{stimBlock2use};
        else
            stimBlockFinal = stimBlocksClean{1};
        end
    % Create stimStruct
        stimStruct.timestamps       = stimBlockFinal;   % Cell array (number of stim blocks long) containing all stim on timestamps within each block
        stimStruct.stimElevation    = stimElevation;
        stimStruct.stimAzimuth      = stimAzimuth;
        stimStruct.centerDirs       = tCenterDirs;
        stimStruct.surroundDirs     = tSurroundDirs;
        stimStruct.stimSpatialFreq  = stimSpatialFreq;
        % stimStruct.stimTemporalFreq = stimTemporalFreq;
        stimStruct.stimDuration     = str2double(exptStruct.stimDur{mwtime2use});    % Stimulus duration in seconds
        stimStruct.trialTypes       = trialTypes;

end

