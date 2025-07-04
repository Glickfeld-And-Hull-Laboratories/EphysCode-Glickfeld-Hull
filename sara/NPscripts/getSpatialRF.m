
%% Run STA at multiple time points


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
    load([noiseDir, '\5min_2deg_4rep_imageMatrix.mat'])

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
        close all
    end   
end


%% Shuffle image matrix to get random distribution of pixel values

nboots = 50;

averageImagesAll_shuffled   = NaN(nboots, nCells, numel(beforeSpike), xDim, yDim);
imageMatrix_list            = reshape(imageMatrix, [], size(imageMatrix,3), size(imageMatrix,4));   % Reshape from nTrials x nFrames to one dimension of all trials (nTrials*nFrames)
frameStarts                 = timestamps;
frameEnds                   = [timestamps(:,2:end), timestamps(:,end)+0.1];
[nTrials, nFrames]          = size(timestamps);

parpool("Threads",20)   % Start parallel pool processing
tic
for ib = 1:nboots
    fprintf(['boot ' num2str(ib) '/' num2str(nboots) '\n'])
    trialOrder          = randperm(size(imageMatrix,1));     % Random permutation of the integers from 1 to number of total trials without repeating elements
    frameOrder          = randperm(size(imageMatrix,2)); 
    imageMatrix_shuf    = imageMatrix(trialOrder, frameOrder, :, :);   % Resample with the random permutation and then reshape into expected matrix size
    for iCell = 1:nCells
        exCellSpikeTimes = goodUnitStruct(iCell).timestamps(goodUnitStruct(iCell).timestamps < lastTimestamp);

        parfor it = 1:length(beforeSpike)
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


%%
% Set zThreshold
zthreshold = 2.5;

% Subtract the mean white noise stimulus, because it is nonzero
wnMean          = mean(mean(imageMatrix,1),2);
wnMeanAvg       = mean(wnMean(:));
wnMeanDiffMat   = wnMean-wnMeanAvg;

averageImagesAll_shuffledMinusMean  = averageImagesAll_shuffled - reshape(reshape(reshape(wnMeanDiffMat,[],xDim,yDim),[],1,xDim,yDim),[],1,1,xDim,yDim);
averageImagesAll_MinusMean          = averageImagesAll - reshape(reshape(wnMeanDiffMat,[],xDim,yDim),[],1,xDim,yDim);

shuffledMean    = squeeze(mean(averageImagesAll_shuffledMinusMean,1));
shuffledStd     = squeeze(std(averageImagesAll_shuffledMinusMean,0,1));

averageImageZscore = (averageImagesAll_MinusMean-shuffledMean)./shuffledStd;   % z-score: subtract mean from the raw value and then divide all by standard deviation

averageImageZscoreThresh = [];
for iCell = 1:nCells
    for it = 1:length(beforeSpike)
        for ix = 1:xDim
            for iy = 1:yDim
               if averageImageZscore(iCell,it,ix,iy) > zthreshold
                   averageImageZscoreThresh(iCell,it,ix,iy) = 1;
               elseif averageImageZscore(iCell,it,ix,iy) < -zthreshold
                   averageImageZscoreThresh(iCell,it,ix,iy) = -1;
               else
                   averageImageZscoreThresh(iCell,it,ix,iy) = 0;
               end
            end
        end
    end
end

% Smooth image
sigma           = 1; % Standard deviation for smoothing (adjust if needed)
avgImageZscoreSmooth  = imgaussfilt(averageImageZscore, sigma);  % 2D Gaussian smoothing; adjust the kernel size (final value, if needed)

%% find index of cells that have a cluster of 3 sig pixels within a 4 pixel square

cells_sigRFbyTime_On   = nan(nCells, length(beforeSpike));
cells_sigRFbyTime_Off   = nan(nCells, length(beforeSpike));

for iCell = 1:nCells
    for it = 1:(length(beforeSpike))
        threshMat = squeeze(averageImageZscoreThresh(iCell,it,:,:));
        foundOn = false;
        foundOff = false;
        for ix = 1:(xDim-2+1)
            for iy = 1:(yDim-2+1)
                patch       = threshMat(ix:ix+1, iy:iy+1);
                numPos = sum(patch(:) == 1);   % count 1s
                numNeg = sum(patch(:) == -1);   % count -1s
                if numPos >= 3
                    foundOn = true;
                end
                if numNeg >= 3
                    foundOff = true;
                end
            end
            if foundOn & foundOff
                break; % Exit ix for loop early
            end
        end
        cells_sigRFbyTime_On(iCell,it)  = foundOn;   % 1 if found, 0 otherwise
        cells_sigRFbyTime_Off(iCell,it) = foundOff;   % 1 if found, 0 otherwise
    end 
end

ind_sigRF = sum(cells_sigRFbyTime_On,2)+sum(cells_sigRFbyTime_Off,2);

%% Plot cell zscore image, threshold, and result of 4x4 pixel test

figure;
sp      = 1;   % subplot count
start   = 1;    % cell count
n       = 1;    % page count

for iCell = 1:nCells
    for ii = 1:2
        for it = 1:length(beforeSpike)
            timeBeforeSpike = beforeSpike(it);
            if ii == 1
                imageToPlot = squeeze(averageImageZscore(iCell,it,:,:));
            elseif ii == 2
                imageToPlot = squeeze(averageImageZscoreThresh(iCell,it,:,:));
            end
            subplot(8,5,sp)
                imagesc(imageToPlot)
                colormap('gray')
                if ii == 1
                    clim([-10 10])
                    if it == 1 
                       subtitle(['cell ' num2str(iCell) ',' num2str(totalSpikesUsed(iCell)) ', -' num2str(timeBeforeSpike) ' s'])
                    else
                       subtitle(['-' num2str(timeBeforeSpike) ' s'])
                    end
                end
                sp=sp+1;
        end
        start=start+1;
    end
   if start > 8
        sgtitle('zcore image, clim ([-10 10])')
        print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs'], [mouse '-' date '_RFs_ZscoreAverageAndThreshold_cell' num2str(iCell-3) 'to' num2str(iCell) '.pdf']),'-dpdf', '-fillpage')       
        figure;
        movegui('center')
        start   = 1;
        n       = n+1;
        sp      = 1;
        close all
    end
    if iCell == nCells
        sgtitle(['noise trials = ' num2str(size(timestamps,1))])
        print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs'], [mouse '-' date '_RFs_ZscoreAverageAndThreshold_untilcell' num2str(iCell) '.pdf']), '-dpdf','-fillpage')
        close all
    end   
end



 %% Get 2D gaussian fit of subunits
close all

listnc  = 1:nCells;
ind     = listnc(ind_sigRF>0);

for ic = 1:length(ind)
    iCell = ind(ic);
    figure;
    for it = 1:length(beforeSpike)
        timeBeforeSpike = beforeSpike(it);

        subunitOnFound  = cells_sigRFbyTime_On(iCell,it);
        subunitOffFound = cells_sigRFbyTime_Off(iCell,it);

        if subunitOnFound
            dataOn      = squeeze(averageImageZscore(iCell,it,:,:));
            gStructOn   = get2DgaussfitRF_SG(dataOn);
            plot = 1;
        end
        if subunitOffFound
            dataOff     = squeeze(averageImageZscore(iCell,it,:,:))*-1;
            gStructOff  = get2DgaussfitRF_SG(dataOff);
            plot = 1;
        end
        
        if xor(subunitOnFound, subunitOffFound)     % Exclusive 'or' (i.e., if exactly one is true...)
            if subunitOnFound
                gaussFit            = gStructOn.k2b_plot; 
                gaussFitoversamp    = gStructOn.k2_plot_oversamp;
            else 
                gaussFit            = gStructOff.k2b_plot*-1; 
                gaussFitoversamp    = gStructOff.k2_plot_oversamp*-1;
            end
        elseif subunitOnFound && subunitOffFound      % Both true
            gaussFit            = gStructOff.k2b_plot*-1 + gStructOn.k2b_plot; 
            gaussFitoversamp    = gStructOff.k2_plot_oversamp*-1 + gStructOn.k2_plot_oversamp;
        else 
            plot = 0;    % Only plot if passes 4x4 pixel test   
        end

            subplot(4,5,it)
                imagesc(squeeze(averageImageZscore(iCell,it,:,:)))
                colormap('gray'); clim([-10 10]); axis image
                subtitle([num2str(timeBeforeSpike) 's'])
            subplot(4,5,5+it)
                imagesc(squeeze(averageImageZscoreThresh(iCell,it,:,:)))  
                colormap('gray'); axis image
        if plot == 1
            subplot(4,5,10+it)
                imagesc(gaussFit)
                colormap('gray'); clim([-5 5]);axis image
            subplot(4,5,15+it)
                imagesc(gaussFitoversamp); 
                colormap('gray'); clim([-5 5]);axis image
        end
    end    
    sgtitle(['cell ' num2str(iCell) ', ' num2str(totalSpikesUsed(iCell)) ' spikes'])
    movegui('center')
    print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs'], [mouse '-' date '_RFs_2dGaussianFits_cell' num2str(iCell) '.pdf']), '-dpdf','-fillpage')
end        


%% Fit 2D gabor using FFT via fit()

listnc  = 1:nCells;
ind     = listnc(ind_sigRF>0);

RFpatch = [];
RFrsq = [];

options.shape   = 'elliptical';
options.runs    = 48;

for ic = 1:length(ind)
    iCell   = ind(ic);
    data    = squeeze(averageImageZscore(iCell,4,:,:));
    results         = fit2dGabor_SG(data,options);
    RFpatch(ic,:,:) = results.patch;
    RFrsq(ic)       = results.r2;
end




%% save

save(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\', [mouse '-' date '_spatialRFs.mat']]), 'totalSpikesUsed', 'averageImagesAll', 'averageImagesAll_shuffled', 'nboots', 'zthreshold', 'cells_sigRFbyTime_On', 'cells_sigRFbyTime_Off', 'ind_sigRF');

%% old bootstrap code
% nboots = 2;
% 
% averageImagesAll_shuffled = [];
% imageMatrix_list    = reshape(imageMatrix, [], size(imageMatrix,3), size(imageMatrix,4));   % Reshape from nTrials x nFrames to one dimension of all trials (nTrials*nFrames)
% 
% parpool("Threads",20)   % Start parallel pool processing
% tic
% for ib = 1:nboots
%     fprintf(['boot ' num2str(ib) '/' num2str(nboots) '\n'])
%     randOrder           = randperm(size(imageMatrix,1)*size(imageMatrix,2));  % Random permutation of the integers from 1 to number of total trials without repeating elements
%     imageMatrix_shuf    = reshape(imageMatrix_list(randOrder,:,:), [], size(imageMatrix,2), size(imageMatrix,3), size(imageMatrix,4));   % Resample with the random permutation and then reshape into expected matrix size
%     for iCell = 1:nCells
%         exCellSpikeTimes = goodUnitStruct(iCell).timestamps(find(goodUnitStruct(iCell).timestamps<lastTimestamp));  % Only take spikes during the RF run (for speed of processing)  
%             for it = 1:length(beforeSpike)
%                 timeBeforeSpike = beforeSpike(it); % Look [40 ms, etc.] before the spike
%                 nSpikes = length(exCellSpikeTimes);
%                 imagesAtSpikesCell = cell(nSpikes, 1);
%                 % Parallelize looping over spike times
%                 parfor is = 1:nSpikes
%                     spikeTime = exCellSpikeTimes(is);
%                     [trialIdx, frameIdx] = findNoiseStimAtSpike(spikeTime, timestamps, timeBeforeSpike);
%                     if ~isnan(trialIdx) && ~isnan(frameIdx)
%                         frameAtSpike = squeeze(imageMatrix_shuf(trialIdx, frameIdx, :, :));
%                         imagesAtSpikesCell{is} = frameAtSpike;
%                     else
%                         imagesAtSpikesCell{is} = NaN(xDim, yDim);
%                     end
%                 end
%                 % Convert back to 3D array
%                 imagesAtSpikes = NaN(nSpikes, xDim, yDim);
%                 for is = 1:nSpikes
%                     imagesAtSpikes(is, :, :) = imagesAtSpikesCell{is};
%                 end
%                 averageImageAtSpike = squeeze(nanmean(imagesAtSpikes, 1));
%                 averageImagesAll_shuffled(ib,iCell,it,:,:)  = averageImageAtSpike;  % Put in matrix to use later. Size: [nBoots x nCells x nTimePointsBeforeSpike x xDim x yDim]
%             end
%     end
% end
% toc
% delete(gcp("nocreate"));    % Stop parallel pool processing
