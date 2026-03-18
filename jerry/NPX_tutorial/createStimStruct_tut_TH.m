
function [stimStruct] = createStimStruct_tutorial(exptStruct)

    mwtime = exptStruct.exptTime;
    mouse = exptStruct.mouse;
    date = exptStruct.date;

    % Load MWorks stimulus information
        bName = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\Behavior\Data\data-' mouse '-' date '-' mwtime '.mat'];
        load(bName);
    
        stimElevation       = double(cell2mat(input.tGratingElevationDeg));
        stimAzimuth         = double(cell2mat(input.tGratingAzimuthDeg));
        stimDirections      = cell2mat(input.tGratingDirectionDeg);
        stimSpatialFreq     = double(input.gratingSpatialFreqCPD);
        stimTemporalFreq    = double(input.gratingTemporalFreqCPS);

    % Load stim on information (both MWorks signal and photodiode)
        cd (['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\' exptStruct.loc '\Analysis\Neuropixel\' exptStruct.date])        % Move from KS_Output folder to ...\Analysis\neuropixel\date folder, where TPrime output is saved
        stimOnTimestampsMW  = table2array(readtable([date '_mworksStimOnSync.txt']));
        stimOnTimestampsPD  = table2array(readtable([date '_photodiodeSync.txt']));

    % Lonely TTL removal
        lonelyThreshold = 0.05; % 50 ms
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
 
    % Create stimStruct
        stimStruct.timestamps       = stimBlocks;   % Cell array (number of stim blocks long) containing all stim on timestamps within each block
        stimStruct.stimElevation    = stimElevation;
        stimStruct.stimAzimuth      = stimAzimuth;
        stimStruct.stimDirection    = stimDirections;
        stimStruct.stimSpatialFreq  = stimSpatialFreq;
        stimStruct.stimTemporalFreq = stimTemporalFreq;
        stimStruct.stimDuration     = 2;    % Stimulus duration in seconds

    warning('*createStimStruct* I am hard coding stimulus duration for now. Assumes 2s on.')
end

