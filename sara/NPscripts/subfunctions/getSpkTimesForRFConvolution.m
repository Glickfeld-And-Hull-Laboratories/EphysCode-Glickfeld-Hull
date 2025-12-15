
%
%
%  Inputs:
%       cells (nCells x 1)  - cell indices (from 1:end for iexp)
%       times (nCells x 1)  - best it of the STA times (i.e., what lag time from new stim)
%       binsize (1 x 1)     - timescale of bin to average over (in seconds). Will be centered around times(nCell)
%
%

function [spikeCounts] = getSpkTimesForRFConvolution(cells,times,binsize,iexp)
    
    base = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
    [exptStruct] = createExptStruct(iexp,'V1'); % Load relevant times and directories for this experiment
    
    % Extract units from KS output
        load(fullfile(base, '\sara\Analysis\Neuropixel', [exptStruct.date], [exptStruct.date '_' exptStruct.mouse '_unitStructs.mat']), 'allUnitStruct', 'goodUnitStruct');
    
    % Load timestamps and downsampled white noise stimulus
        mouse = exptStruct.mouse;
        date = exptStruct.date;

    % Load stim on information (both MWorks signal and photodiode)
        cd (fullfile(base, exptStruct.loc, 'Analysis', 'Neuropixel', exptStruct.date))        % Move from KS_Output folder to ...\Analysis\neuropixel\date folder, where TPrime output is saved
        stimOnTimestampsMW  = table2array(readtable([date '_mworksStimOnSync.txt']));
        stimOnTimestampsPD  = table2array(readtable([date '_photodiodeSync.txt']));

    % Lonely TTL removal
        lonelyThreshold = 0.1; % 100 ms
        timeDiffs       = abs(diff(stimOnTimestampsPD));  % Compute pairwise differences efficiently
        hasNeighbor = [false; timeDiffs < lonelyThreshold] | [timeDiffs < lonelyThreshold; false]; % Identify indices where a close neighbor exists
        filteredPD = stimOnTimestampsPD(hasNeighbor);   % Keep only timestamps that have a neighbor within 100 ms
        filteredPD = stimOnTimestampsPD;

    % Account for report of the monitor's refresh rate in the photodiode signal
        minInterval = 0.035; % Define a minimum separation threshold (should be longer than a refresh cycle but shorter than ISI)     
        leadingEdgesPD = filteredPD([true; diff(filteredPD) > minInterval]); % Extract the leading edges (first timestamp of each stimulus period)
        % [true; ...] ensures that the very first timestamp is always included because otherwise diff() returns an array that is one element shorter than the original.

    % Find stimulus blocks and separate stim on timestamps
        threshold       = 5; % Time gap to define a break (in seconds)
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
        stimStruct.stimDuration     = 0.1;    % Stimulus duration in seconds

    warning('*createStimStruct* I am hard coding stimulus duration for now. Assumes 10hz presentation.')


    % Make sure all PD are stim-associated
    ibRF = 0;
    for ib = 1:length(stimBlocks)
        if size(stimBlocks{ib},1) > 10  % If stimulus block has at least 10 trials...
            ibRF = ibRF + 1;
            RFstimBlocks{ibRF} = stimBlocks{ib}(1:end-1); % Get rid of abherrant lonely PD signal at end of trial block
        end
    end

    % Load downsampled noise stimuli
    if iexp == 11
        load(fullfile(base, exptStruct.loc, 'Analysis', 'Neuropixel', 'noiseStimuli/', '5min_2deg_3rep_imageMatrix.mat'))
    else
        load(fullfile(base, exptStruct.loc, 'Analysis', 'Neuropixel', 'noiseStimuli/', '5min_2deg_4rep_imageMatrix.mat'))
    end

    xDim = size(imageMatrix,3);
    yDim = size(imageMatrix,4);

    % Find an example unit I like
    depths = [goodUnitStruct.depth];
    
    % Get frame timestamps

    timestamps = [];
    for it = 1:size(imageMatrix,1)
        timestamps(it,:) = RFstimBlocks{it}(:);
    end

    lastTimestamp = timestamps(end)+10; % Last timestamp plus 10 seconds



    % Initialize
    nCells = length(cells);
    timestamps_flat = timestamps(:);   % 9000×1
    spikeCounts = zeros(length(timestamps_flat), nCells);  % 9000×nCells
    
    for ic = 1:nCells
        edges = [timestamps(:)+times(ic)-binsize*0.5, timestamps(:)++times(ic)+binsize*0.5];   % (9000 x 2)

        % Get spike times for this cell
        celln = cells(ic);
        spk = goodUnitStruct(celln).timestamps;
        spk = spk(spk < lastTimestamp);   % keep only in range
        
        % For each bin, count spikes
        for it = 1:length(timestamps_flat)
            spikeCounts(it, ic) = sum(spk >= edges(it,1) & spk < edges(it,2)); 
        end
    end

end