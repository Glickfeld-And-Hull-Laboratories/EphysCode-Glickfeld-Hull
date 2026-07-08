clear all; close all; clc
base = '/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/';
iexp = 13; % Choose experiment
exptloc = 'V1';
nboots = 100; %100

[exptStruct] = createExptStruct(iexp,exptloc); % Load relevant times and directories for this experiment

%%

cellsIdx = [68 71 81 93 94 95 107 115 121 123 124 127 130 131 132 133 135 137 139 140];

%% Load unit info

load(fullfile(['/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/sara/Analysis/Neuropixel/', exptStruct.date, '/' exptStruct.date '_' exptStruct.mouse '_unitStructs.mat']))
load(fullfile(['/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/sara/Analysis/Neuropixel/' exptStruct.date '/', exptStruct.mouse '-' exptStruct.date '_spatialRFs.mat']),'bestTimePoint')


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
        minInterval = 0.035; %0.035; % Define a minimum separation threshold (should be longer than a refresh cycle but shorter than ISI)     
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
        if size(stimBlocks{ib},1) > 20  % If stimulus block has at least 10 trials...
            ibRF = ibRF + 1;
            RFstimBlocks{ibRF} = stimBlocks{ib}(1:end-1); % Get rid of abherrant lonely PD signal at end of trial block
        end
    end

    % Load downsampled noise stimuli
    load(fullfile(base, exptStruct.loc, 'Analysis', 'Neuropixel', 'noiseStimuli/', '5min_2deg_4rep_imageMatrix.mat'))

    xDim = size(imageMatrix,3);
    yDim = size(imageMatrix,4);

    % Find an example unit I like
    depths = [goodUnitStruct.depth];
    
    % Get frame timestamps

    timestamps = [];
    for it = 1:size(imageMatrix,1)
         timestamps(it,:) = RFstimBlocks{it}(:);
    end

    beforeSpike = [0.25 0.1 0.07 0.04 0.01]; % I.e., look 40 ms before the spike

%%

nCells  = length(goodUnitStruct);
lastTimestamp = timestamps(end)+10; % Last timestamp plus 10 seconds

totalSpikesUsed = [];
averageImagesAll = [];

parpool("Threads", 40)   % Start parallel pool processing
tic
for ic = 1:length(cellsIdx)
    iCell = cellsIdx(ic);
    fprintf(['cell ' num2str(ic) '/' num2str(length(cellsIdx)) '\n'])
    exCellSpikeTimes = goodUnitStruct(iCell).timestamps(find(goodUnitStruct(iCell).timestamps<lastTimestamp));  % Only take spikes during the RF run (for speed of processing)  
    totalSpikesUsed(ic) = length(exCellSpikeTimes);
    it = bestTimePoint(iCell,1);
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
    averageImagesAll(ic,:,:)  = averageImageAtSpike;  % Put in matrix to use later. Size: [nBoots x nCells x nTimePointsBeforeSpike x xDim x yDim]

end
toc
delete(gcp("nocreate"));


%% Calculate trials for held out data

nChunks = 10; % number of held-out segments, nChunks=10 is 10% held out

nTrials = size(imageMatrix,1);
framesPerTrial = size(imageMatrix,2);
totalFrames = nTrials*framesPerTrial;

nChunks = 10;                  % number of held-out segments
chunkSize = totalFrames / nChunks;   % should be 1200

% Initialize all frames as training frames
heldOutMask = ones(nChunks,nTrials, framesPerTrial);

% Choose chunk start positions (non-overlapping, evenly spaced)
edges = round(linspace(1, totalFrames - chunkSize + 1, nChunks));

for ih = 1:nChunks
    
    startFrame = edges(ih);
    endFrame   = startFrame + chunkSize - 1;

    % Convert continuous indices to trial/frame coordinates
    for f = startFrame:endFrame
        
        trialIdx = ceil(f / framesPerTrial);
        frameIdx = mod(f-1, framesPerTrial) + 1;

        % Mark as held out
        heldOutMask(ih,trialIdx, frameIdx) = 0;
    end
end

%% Compute STAs with held out data


totalSpikesUsed_HO = [];
averageImagesAll_HO = [];

parpool("Threads", 40)   % Start parallel pool processing
tic
for ih = 1:nChunks
    fprintf(['heldOut chunk ' num2str(ih) '/' num2str(nChunks) '\n'])
    for ic = 1:length(cellsIdx)
        iCell = cellsIdx(ic);
        exCellSpikeTimes = goodUnitStruct(iCell).timestamps(find(goodUnitStruct(iCell).timestamps<lastTimestamp));  % Only take spikes during the RF run (for speed of processing)  
        totalSpikesUsed_HO(ih,ic) = length(exCellSpikeTimes);
        it = bestTimePoint(iCell,1);
        timeBeforeSpike = beforeSpike(it); % Look [40 ms, etc.] before the spike
        nSpikes = length(exCellSpikeTimes);
        imagesAtSpikesCell = cell(nSpikes, 1);
        % Parallelize looping over spike times
        parfor is = 1:nSpikes
            spikeTime = exCellSpikeTimes(is);
            [trialIdx, frameIdx] = findNoiseStimAtSpike(spikeTime, timestamps, timeBeforeSpike);
            if ~isnan(trialIdx) && ~isnan(frameIdx) && heldOutMask(ih,trialIdx, frameIdx)
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
        averageImagesAll_HO(ih,ic,:,:)  = averageImageAtSpike;  % Put in matrix to use later. Size: [nBoots x nCells x nTimePointsBeforeSpike x xDim x yDim]
    end
end
toc
delete(gcp("nocreate"));







%% Bootstrap to get null distribution of pixel values

averageImagesAll_shuffled   = NaN(nboots, length(cellsIdx), xDim, yDim);
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
    parfor ic = 1:length(cellsIdx)
        iCell = cellsIdx(ic);
        exCellSpikeTimes = goodUnitStruct(iCell).timestamps(goodUnitStruct(iCell).timestamps < lastTimestamp);
            it = bestTimePoint(iCell,1);
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

            averageImageAtSpike                   = squeeze(nanmean(imagesAtSpikes, 1));
            averageImagesAll_shuffled(ib,ic,:,:)  = averageImageAtSpike;

    end
end
toc
delete(gcp("nocreate"));



%% get spike counts per stimulus

binsize = 0.06;   % 60ms bin, will be centered on the timepoint input to the function
spkCounts = getSpkTimesForRFConvolution_Wiesel(cellsIdx,bestTimePoint(cellsIdx),binsize,iexp);


%% Fitting


% Crop STAs
sideLength = 29;
nSelected = numel(cellsIdx);

STA_cropped = nan(sideLength, sideLength, nSelected);

for k = 1:nSelected
    ic = cellsIdx(k);
    avgImgZscore = squeeze(averageImagesAll(k, :, :, :));
    bestTP = bestTimePoint(ic, 1);
    data = squeeze(avgImgZscore(bestTP, :, :));
    data = medfilt2(imgaussfilt(data, 1));
    [el, az] = getRFcenter(data);
    STA_cropped(:, :, k) = cropRFtoCenter(az, el, data, sideLength);
end


options.visualize = 0;
options.parallel  = 1;
options.shape     = 'equal';
options.runs      = 48;

modelRegistry = [
%     struct( ...
%         'name','Circular DoG', ...
%         'type','standard', ...
%         'fitFcn', @(STA) fitNonConcentricCircularDoG(STA), ...
%         'k',6)
    struct( ...
        'name','Gabor', ...
        'type','sg', ...
        'fitFcn', @(STA) fit2dGabor_JM(STA,options), ...
        'k',10)
     struct( ...
        'name','DoG x cos', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNoncDoGCosineRF_tau(STA), ...
        'k',11)
];

omitCells = [114];
fitIdx = 1:nSelected;

results = runRFModelComparison( ...
    fitIdx, ...
    cellsIdx, ...
    STA_cropped, ...
    modelRegistry, ...
    omitCells, ...
    'pdf', ...
    'test_all_fit.pdf');

modelNames = {results.modelRegistry.name};




%% Plot STAs

averageImagesAll_reshaped   = reshape(averageImagesAll, [1, size(averageImagesAll)]);
STAs_all                    = cat(1, averageImagesAll_reshaped, averageImagesAll_HO);

wnMean          = mean(mean(imageMatrix,1),2);
wnMeanAvg       = mean(wnMean(:));
wnMeanDiffMat   = wnMean-wnMeanAvg;

averageImagesAll_MinusMean          = STAs_all - reshape(reshape(wnMeanDiffMat,[],xDim,yDim),[],1,xDim,yDim);


data_all                    =  averageImagesAll_MinusMean;


maxSmth = max(max(max(max(abs(data_all)))));
minSmth = min(min(min(min(abs(data_all)))));


% Print STA time point choices
pdfFile = fullfile(fullfile(['/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/sara/Analysis/Neuropixel/' exptStruct.date '/spatialRFs_heldOut/', 'spatialRFs_heldOut.pdf']));

for ic = 1:length(cellsIdx)
    iCell = cellsIdx(ic);

    figure();
    sgtitle(['cell ' num2str(iCell)])

        data = medfilt2(imgaussfilt(squeeze(data_all(1,ic,:,:)),1));

        subplot(3,5,1)
            imagesc(data); hold on
            pbaspect([16 9 1])
            colormap(gray)
            clim([floor(minSmth) ceil(maxSmth)])
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            subtitle('STA')

    for ih = 1:nChunks

        data = medfilt2(imgaussfilt(squeeze(data_all(ih+1,ic,:,:)),1));

        subplot(3,5,ih+5)
            imagesc(data); hold on
            pbaspect([16 9 1])
            colormap(gray)
            clim([floor(minSmth) ceil(maxSmth)])
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])

    end

    % Append current figure as a new page in the PDF
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);

    close(gcf)
end









%% Compute bootstrap for held out data

% === NOT working ====

averageImagesAll_shuffled   = NaN(nChunks, nboots, length(cellsIdx), xDim, yDim);
frameStarts                 = timestamps;
frameEnds                   = [timestamps(:,2:end), timestamps(:,end)+0.1];
[nTrials, nFrames]          = size(timestamps);
timeOffsets                 = 1:numel(beforeSpike);

parpool("Threads", 40)   % Start parallel pool processing
tic
for ih = 1:nChunks
    
    mask = squeeze(heldOutMask(ih,:,:));   % nTrials x framesPerTrial
    
    trainingIdx = find(mask(:)==1);        % 10800 frames
    
    imageMatrix_trainList = reshape(imageMatrix, [], size(imageMatrix,3), size(imageMatrix,4));  % Reshape from nTrials x nFrames to one dimension of all trials (nTrials*nFrames)
    imageMatrix_train = imageMatrix_trainList(trainingIdx,:,:);

    for ib = 1:nboots
        fprintf(['boot ' num2str(ib) '/' num2str(nboots) '\n'])

        bootIdx = randi(size(imageMatrix_train,1), size(imageMatrix_train,1), 1);
        imageMatrix_shuf = imageMatrix_train(bootIdx,:,:);

        parfor ic = 1:length(cellsIdx)
            iCell = cellsIdx(ic);
            exCellSpikeTimes = goodUnitStruct(iCell).timestamps(goodUnitStruct(iCell).timestamps < lastTimestamp);
                it = bestTimePoint(iCell,1);
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
    
                averageImageAtSpike                   = squeeze(nanmean(imagesAtSpikes, 1));
                averageImagesAll_shuffled(ih,ib,ic,:,:)  = averageImageAtSpike;
    
        end
    end
end
toc
delete(gcp("nocreate"));


%%
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
