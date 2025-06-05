


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
        filteredPD = stimOnTimestampsPD(hasNeighbor);   % Keep only timestamps that have a neighbor within 50 ms

    % Account for report of the monitor's refresh rate in the photodiode signal
        minInterval = 0.045; % Define a minimum separation threshold (should be longer than a refresh cycle but shorter than ISI)     
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


    % For now, I think the first frame is abherrant 

    % RFstimBlocks{1} = stimBlocks{1}(2:end);
    % RFstimBlocks{2} = stimBlocks{2}(2:end);
    % RFstimBlocks{3} = stimBlocks{3}(2:end);
    RFstimBlocks{1} = stimBlocks{1}(1:end-1);
    RFstimBlocks{2} = stimBlocks{2}(1:end-1);
    RFstimBlocks{3} = stimBlocks{3}(1:end-1);

    % Load downsampled noise stimuli
    noiseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\\home\sara\Analysis\Neuropixel\noiseStimuli';
    load([noiseDir, '\5min_2deg_3rep_imageMatrix.mat'])
    xDim = size(imageMatrix,3);
    yDim = size(imageMatrix,4);

    % Find an example unit I like
    depths = [goodUnitStruct.depth];
    
    % Get frame timestamps

    timestamps = [];
    for it = 1:3
        timestamps(it,:) = RFstimBlocks{it}(:);
    end

    beforeSpike = [0.25 0.1 0.07 0.04 0.01]; % Look 40 ms before the spike
%%
    figure;
    s=1;
    for iCell = [56:60] %65 60
        exCellSpikeTimes = goodUnitStruct(iCell).timestamps;
        
        for it = 1:length(beforeSpike)
            timeBeforeSpike = beforeSpike(it); % Look 40 ms before the spike

            imagesAtSpikes = NaN(length(exCellSpikeTimes),xDim, yDim);
        
            for is = 1:length(exCellSpikeTimes)
                spikeTime = exCellSpikeTimes(is);
                [trialIdx, frameIdx] = findNoiseStimAtSpike(spikeTime, timestamps, timeBeforeSpike);
                if ~isnan(trialIdx) && ~isnan(frameIdx)
                    frameAtSpike = squeeze(imageMatrix(trialIdx,frameIdx,:,:));
                    imagesAtSpikes(is,:,:) = frameAtSpike;
                end   
            end
        
            averageImageAtSpike = squeeze(nanmean(imagesAtSpikes, 1));  % Average across spikes


            % Smooth image
            sigma       = 2; % Standard deviation for smoothing (adjust if needed)
            avgImageSmooth  = imgaussfilt(averageImageAtSpike, sigma);  % 2D Gaussian smoothing; adjust the kernel size (final value, if needed)
    
           subplot(5,5,s) 
               
                %imagesc(averageImageAtSpike)
                imagesc(avgImageSmooth)
                colormap('gray')
                if it == 1
                   subtitle(['cell ' num2str(iCell) ', -' num2str(timeBeforeSpike) ' s'])
                else
                    subtitle(['-' num2str(timeBeforeSpike) ' s'])
                end
           s=s+1;
        end
    end
    movegui('center')

stop
    print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date], ['spatialRFs_examplecells.pdf']), '-dpdf','-fillpage')
