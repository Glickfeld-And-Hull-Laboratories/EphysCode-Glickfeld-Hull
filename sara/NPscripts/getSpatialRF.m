


    mouse = exptStruct.mouse;
    date = exptStruct.date;

 
    % Load stim on information (both MWorks signal and photodiode)
        cd (['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\' exptStruct.loc '\Analysis\Neuropixel\' exptStruct.date])        % Move from KS_Output folder to ...\Analysis\neuropixel\date folder, where TPrime output is saved
        stimOnTimestampsMW  = table2array(readtable([date '_mworksStimOnSync.txt']));
        stimOnTimestampsPD  = table2array(readtable([date '_photodiodeSync.txt']));

    % Lonely TTL removal
        lonelyThreshold = 0.1; % 100 ms
        timeDiffs       = abs(diff(stimOnTimestampsPD));  % Compute pairwise differences efficiently
        hasNeighbor = [false; timeDiffs < lonelyThreshold] | [timeDiffs < lonelyThreshold; false]; % Identify indices where a close neighbor exists
        filteredPD = stimOnTimestampsPD(hasNeighbor);   % Keep only timestamps that have a neighbor within 100 ms

        filteredPD = stimOnTimestampsPD;

    % Account for report of the monitor's refresh rate in the photodiode signal
        minInterval = 0.03; % Define a minimum separation threshold (should be longer than a refresh cycle but shorter than ISI)     
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
    noiseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\\home\sara\Analysis\Neuropixel\noiseStimuli';
    load([noiseDir, '\5min_2deg_3rep_imageMatrix.mat'])
    xDim = size(imageMatrix,3);
    yDim = size(imageMatrix,4);
   
    if length(RFstimBlocks) == 6
        imageMatrix = repmat(imageMatrix,2,2,1,1);
    end

    % Find an example unit I like
    depths = [goodUnitStruct.depth];
    
    % Get frame timestamps

    timestamps = [];
    for it = 1:3
        timestamps(it,:) = RFstimBlocks{it}(:);
    end

    beforeSpike = [0.25 0.1 0.07 0.04 0.01]; % Look 40 ms before the spike
%% plot spatial RFs

    if ~exist(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs']), 'dir')
        mkdir(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs']));
    end
    
    nCells  = length(goodUnitStruct);
    lastTimestamp = timestamps(end)+10; % Last timestamp plus 10 seconds
    
    totalSpikesUsed = [];
    averageImagesAll = [];

    figure;
    sp      = 1;   % subplot count
    start   = 1;    % cell count
    n       = 1;    % page count

    for iCell = 1:nCells
        exCellSpikeTimes = goodUnitStruct(iCell).timestamps(find(goodUnitStruct(iCell).timestamps<lastTimestamp));  % Only take spikes during the RF run (for speed of processing)  

        for it = 1:length(beforeSpike)
            timeBeforeSpike = beforeSpike(it); % Look [40 ms, etc.] before the spike
            imagesAtSpikes  = NaN(length(exCellSpikeTimes),xDim, yDim);

            for is = 1:length(exCellSpikeTimes)
                spikeTime               = exCellSpikeTimes(is);
                [trialIdx, frameIdx]    = findNoiseStimAtSpike(spikeTime, timestamps, timeBeforeSpike);

                if ~isnan(trialIdx) && ~isnan(frameIdx)
                    frameAtSpike            = squeeze(imageMatrix(trialIdx,frameIdx,:,:));
                    imagesAtSpikes(is,:,:)  = frameAtSpike;
                    totalSpikesUsed(iCell)  =   nnz(~isnan(imagesAtSpikes(:,1,1)));
                end   
            end
            averageImageAtSpike             = squeeze(nanmean(imagesAtSpikes, 1));  % Average across spikes
            averageImagesAll(iCell,it,:,:)  = averageImageAtSpike;  % Put in matrix to save later. Size: [nCells x nTimePointsBeforeSpike x xDim x yDim]
    
            % Smooth image
            sigma           = 2; % Standard deviation for smoothing (adjust if needed)
            avgImageSmooth  = imgaussfilt(averageImageAtSpike, sigma);  % 2D Gaussian smoothing; adjust the kernel size (final value, if needed)


           subplot(8,5,sp)
                imagesc(averageImageAtSpike)
                %imagesc(avgImageSmooth)
                colormap('gray')
                if it == 1
                   subtitle(['cell ' num2str(iCell) ',' num2str(totalSpikesUsed(iCell)) ', -' num2str(timeBeforeSpike) ' s'])
                else
                    subtitle(['-' num2str(timeBeforeSpike) ' s'])
                end
                sp=sp+1;
        end
       start=start+1;
       if start > 8
            sgtitle(['noise trials = ' num2str(size(timestamps,1))])
            print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs'], [mouse '-' date '_spatialRFs_cell' num2str(iCell-7) 'to' num2str(iCell) '.pdf']),'-dpdf', '-fillpage')       
            figure;
            movegui('center')
            start   = 1;
            n       = n+1;
            sp      = 1;
            close all
        end
        if iCell == nCells
            sgtitle(['noise trials = ' num2str(size(timestamps,1))])
            print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs'], [mouse '-' date '_spatialRFs_untilcell' num2str(iCell) '.pdf']), '-dpdf','-fillpage')
        end   
    end

    save(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\', [mouse '-' date '_spatialRFs.mat']]), 'totalSpikesUsed', 'averageImagesAll');
