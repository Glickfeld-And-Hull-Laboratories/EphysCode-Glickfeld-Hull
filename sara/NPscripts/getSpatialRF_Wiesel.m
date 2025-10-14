clear all; close all; clc
base = '/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/';
iexp = 25; % Choose experiment

[exptStruct] = createExptStruct(iexp); % Load relevant times and directories for this experiment

%% Extract units from KS output

cd(fullfile(base, exptStruct.loc, 'Analysis', 'Neuropixel', exptStruct.date, 'KS_Output/')) % Navigate to KS_Output folder

% Choose imec0.ap.bin file (I just choose the CatGT bin file)
[allUnitStruct, goodUnitStruct] = importKSdata_SG();


%% Load timestamps and downsampled white noise stimulus

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

    beforeSpike = [0.25 0.1 0.07 0.04 0.01]; % Look 40 ms before the spike

%%

nCells  = length(goodUnitStruct);
lastTimestamp = timestamps(end)+10; % Last timestamp plus 10 seconds

totalSpikesUsed = [];
averageImagesAll = [];

parpool("Threads", 40)   % Start parallel pool processing
tic
for iCell = 1:nCells
    fprintf(['cell ' num2str(iCell) '/' num2str(nCells) '\n'])
    exCellSpikeTimes = goodUnitStruct(iCell).timestamps(find(goodUnitStruct(iCell).timestamps<lastTimestamp));  % Only take spikes during the RF run (for speed of processing)  
    totalSpikesUsed(iCell) = length(exCellSpikeTimes);
        for it = 1:length(beforeSpike)
            timeBeforeSpike = beforeSpike(it); % Look [40 ms, etc.] before the spike
            nSpikes = length(exCellSpikeTimes);
            imagesAtSpikesCell = cell(nSpikes, 1);
            % Parallelize looping over spike times
            parfor is = 1:nSpikes
                spikeTime = exCellSpikeTimes(is);
                [trialIdx, frameIdx] = findNoiseStimAtSpike(spikeTime, timestamps, timeBeforeSpike);
                if ~isnan(trialIdx) && ~isnan(frameIdx)
                    frameAtSpike = squeeze(imageMatrix(trialIdx, frameIdx, :, :));
                    imagesAtSpikesCell{is} = frameAtSpike;
                else
                    imagesAtSpikesCell{is} = NaN(xDim, yDim);
                end
            end
            % Convert back to 3D array
            imagesAtSpikes = NaN(nSpikes, xDim, yDim);
            for is = 1:nSpikes
                imagesAtSpikes(is, :, :) = imagesAtSpikesCell{is};
            end
            averageImageAtSpike = squeeze(nanmean(imagesAtSpikes, 1));
            averageImagesAll(iCell,it,:,:)  = averageImageAtSpike;  % Put in matrix to use later. Size: [nBoots x nCells x nTimePointsBeforeSpike x xDim x yDim]
        end
end
toc
delete(gcp("nocreate"));


%% Bootstrap to get null distribution of pixel values

nboots = 100;

averageImagesAll_shuffled   = NaN(nboots, nCells, numel(beforeSpike), xDim, yDim);
imageMatrix_list            = reshape(imageMatrix, [], size(imageMatrix,3), size(imageMatrix,4));   % Reshape from nTrials x nFrames to one dimension of all trials (nTrials*nFrames)
frameStarts                 = timestamps;
frameEnds                   = [timestamps(:,2:end), timestamps(:,end)+0.1];
[nTrials, nFrames]          = size(timestamps);
timeOffsets                 = 1:numel(beforeSpike);

parpool("Threads", 40)   % Start parallel pool processing
tic
for ib = 1:nboots
    fprintf(['boot ' num2str(ib) '/' num2str(nboots) '\n'])
    trialOrder          = randperm(size(imageMatrix,1));     % Random permutation of the integers from 1 to number of total trials without repeating elements
    frameOrder          = randperm(size(imageMatrix,2)); 
    imageMatrix_shuf    = imageMatrix(trialOrder, frameOrder, :, :);   % Resample with the random permutation and then reshape into expected matrix size
    parfor iCell = 1:nCells
        exCellSpikeTimes = goodUnitStruct(iCell).timestamps(goodUnitStruct(iCell).timestamps < lastTimestamp);
        for it = timeOffsets
            timeBeforeSpike = beforeSpike(it);
            shiftedSpikes   = exCellSpikeTimes - timeBeforeSpike;
            nSpikes         = length(shiftedSpikes);
            trialIdx = NaN(1, nSpikes);                                 
            frameIdx = NaN(1, nSpikes);
    
            % Expand dims
            frameStartsExp      = reshape(frameStarts, [nTrials, nFrames, 1]);
            frameEndsExp        = reshape(frameEnds,   [nTrials, nFrames, 1]);
            shiftedSpikesExp    = reshape(shiftedSpikes, [1, 1, nSpikes]);

            % Get frame for each spike
            isInFrame = (shiftedSpikesExp >= frameStartsExp) & (shiftedSpikesExp < frameEndsExp);
    
            % Collapse trials & frames
            isInFrame2D             = reshape(isInFrame, nTrials * nFrames, nSpikes);
            [linearIdx, spikeIdx]   = find(isInFrame2D);
    
            if ~isempty(linearIdx)
                [trialInds, frameInds]      = ind2sub([nTrials, nFrames], linearIdx);
                [uniqueSpikes, firstIdx]    = unique(spikeIdx, 'first');   % Keep only the first match if multiple
                trialIdx(uniqueSpikes)      = trialInds(firstIdx);
                frameIdx(uniqueSpikes)      = frameInds(firstIdx);
            end
    
            valid = ~isnan(trialIdx);    % Find valid spikes
            imagesAtSpikes = NaN(nSpikes, xDim, yDim);    % Preallocate
                
            % Convert valid indices to linear indices
            if any(valid)
                ind                         = sub2ind([size(imageMatrix_shuf,1), size(imageMatrix_shuf,2)], trialIdx(valid), frameIdx(valid));    % Compute linear indices into imageMatrix_shuf
                frames                      = reshape(imageMatrix_shuf, [], xDim, yDim);    % Extract all frames at once
                imagesAtSpikes(valid,:,:)   = frames(ind, :, :);
            end

            averageImageAtSpike                         = squeeze(nanmean(imagesAtSpikes, 1));
            averageImagesAll_shuffled(ib,iCell,it,:,:)  = averageImageAtSpike;
        end
    end
end
toc
delete(gcp("nocreate"));

save( ...
    fullfile( ...
        base, ...
        exptStruct.loc, ...
        'Analysis', ...
        'Neuropixel', ...
        exptStruct.date, ...
        [mouse '-' date '_spatialRFs_Wiesel.mat']), ...
    'totalSpikesUsed', ...
    'averageImagesAll', ...
    'averageImagesAll_shuffled', ...
    'nboots', ...
    'beforeSpike');
