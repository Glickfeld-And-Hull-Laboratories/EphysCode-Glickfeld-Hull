%% Compute STAs for marmoset data
% Script 1 of 2:
%     getSpatialRF_Marmoset_computeSTAs
%     getSpatialRF_Marmoset_plotSTAs

%%
clear all; close all; clc

runloc = 1;   % Where is this script being run? 1 == Hubel, 2 == Wiesel
res = 'LR';

nboots = 1;
beforeSpike = [0.15 0.12 0.09 0.07 0.04]; % Look 40 ms before the spike

%%
if runloc == 1    % Hubel
    dirBase = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home';
    nThreads = 20;
elseif runloc == 2    % Wiesel
    dirBase = 'home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home';
    nThreads = 40;
else
    error('Location not valid. 1 == Hubel, 2 == Wiesel.')
end

%% load RF experiment data

load(fullfile(dirBase,'sara','Data','fromNicholas','CrossOri_randDirFourPhase_V1_marmoset_LFP','elf1','elfrfdata.mat'))
% Variables loaded:
%   dgspikes        nCells x nBins (matrix) - 1ms bins with spike counts (0/1)
%   onstimmatlr     1 x nTrials (cell array) containing [nPixels x nFrames]  - "on" stim image for low resolution experiment
%   offstimmatlr
%   onstimmathr
%   offstimmathr
%   stimstlr        1 x nTrials (matrix) -  trial start time (in seconds) for low resolution experiment
%   stimsthr

refRate = 99.9726324918554; % refresh rate of monitor, from Nicholas (in Hz)


%% get spike times 

dt = 0.001; % 1 ms bins

nCells = size(dgspikes,1);
spikeTimes = cell(nCells,1);

for i = 1:nCells
    spikeTimesCell{i} = find(dgspikes(i,:)) * dt; % find indices of spikes and convert to seconds
end

%% make imageMatrix

if res == 'LR'
    OnStim_list = cat(3,onstimmatlr{:});
    OffStim_list = cat(3,offstimmatlr{:});
elseif res == 'HR'
    OnStim_list = cat(3,onstimmathr{:});
    OffStim_list = cat(3,offstimmathr{:});
else
    error('*res* variable is not interpretable. Set to low resolution (LR) or high resolution (HR)')
end

stim_list = OnStim_list - OffStim_list; % nPixels x nFrames x nTrials

nTrials = size(stim_list,3);
nFramesPerTrial = size(stim_list,2);
nSizeStimSide = sqrt(size(stim_list,1));

% reshape into imageMatrix
stim_list_reorder = permute(stim_list, [3 2 1]);     % change order to nTrials x nFrames x nPixels
imageMatrix = reshape(stim_list_reorder, nTrials, nFramesPerTrial, nSizeStimSide, nSizeStimSide);       % nPixels -> 2D stimulus square



%% get stimulus on times

if res == 'LR'
    trialOnsets = stimstlr; % load the start of each stimulus presentation from .mat file from Nicholas
elseif res == 'HR'
    trialOnsets = stimsthr; 
else
    error('*res* variable is not interpretable. Set to low resolution (LR) or high resolution (HR)')
end


fr = 1/refRate;

for it = 1:nTrials
    timestamps(it,:) = trialOnsets(it) + (0:(nFramesPerTrial-1))*fr;  
end


%%
nCells  = size(dgspikes,1);
lastTimestamp = timestamps(end)+10; % Last timestamp plus 10 seconds

totalSpikesUsed = [];
averageImagesAll = [];

parpool("Threads", nThreads)   % Start parallel pool processing
tic
for iCell = 170:179
    fprintf(['cell ' num2str(iCell) '/' num2str(nCells) '\n'])
    exCellSpikeTimes = spikeTimesCell{iCell};  % Not continuous recording, there are no spikes after lastTimestamp
    totalSpikesUsed(iCell) = length(exCellSpikeTimes);
        for it = 1:length(beforeSpike)
            timeBeforeSpike = beforeSpike(it); % Look [40 ms, etc.] before the spike
            nSpikes = length(exCellSpikeTimes);
            imagesAtSpikesCell = cell(nSpikes, 1);
            % Parallelize looping over spike times
            parfor is = 1:nSpikes
                spikeTime = exCellSpikeTimes(is);
                [trialIdx, frameIdx] = findNoiseStimAtSpike_marmoset(spikeTime, timestamps, timeBeforeSpike);
                if ~isnan(trialIdx) && ~isnan(frameIdx)
                    frameAtSpike = squeeze(imageMatrix(trialIdx, frameIdx, :, :));
                    imagesAtSpikesCell{is} = frameAtSpike;
                else
                    imagesAtSpikesCell{is} = NaN(nSizeStimSide, nSizeStimSide);
                end
            end
            % Convert back to 3D array
            imagesAtSpikes = NaN(nSpikes, nSizeStimSide, nSizeStimSide);
            for is = 1:nSpikes
                imagesAtSpikes(is, :, :) = imagesAtSpikesCell{is};
            end
            averageImageAtSpike = squeeze(nanmean(imagesAtSpikes, 1));
            averageImagesAll(iCell,it,:,:)  = averageImageAtSpike;  % Put in matrix to use later. Size: [nBoots x nCells x nTimePointsBeforeSpike x xDim x yDim]
        end
end
toc
delete(gcp("nocreate"));


%% bootstrap script

averageImagesAll_shuffled   = NaN(nboots, nCells, numel(beforeSpike), nSizeStimSide, nSizeStimSide);
imageMatrix_list            = reshape(imageMatrix, [], size(imageMatrix,3), size(imageMatrix,4));   % Reshape from nTrials x nFrames to one dimension of all trials (nTrials*nFrames)
frameStarts                 = timestamps;
frameEnds                   = [timestamps(:,2:end), timestamps(:,end)+0.1];
[nTrials, nFrames]          = size(timestamps);
timeOffsets                 = 1:numel(beforeSpike);

parpool("Threads", nThreads)   % Start parallel pool processing
tic
for ib = 1:nboots
    fprintf(['boot ' num2str(ib) '/' num2str(nboots) '\n'])
    trialOrder          = randperm(size(imageMatrix,1));     % Random permutation of the integers from 1 to number of total trials without repeating elements
    frameOrder          = randperm(size(imageMatrix,2)); 
    imageMatrix_shuf    = imageMatrix(trialOrder, frameOrder, :, :);   % Resample with the random permutation and then reshape into expected matrix size
    parfor iCell = 170:179
        exCellSpikeTimes = spikeTimesCell{iCell}; 
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
            imagesAtSpikes = NaN(nSpikes, nSizeStimSide, nSizeStimSide);    % Preallocate
                
            % Convert valid indices to linear indices
            if any(valid)
                ind                         = sub2ind([size(imageMatrix_shuf,1), size(imageMatrix_shuf,2)], trialIdx(valid), frameIdx(valid));    % Compute linear indices into imageMatrix_shuf
                frames                      = reshape(imageMatrix_shuf, [], nSizeStimSide, nSizeStimSide);    % Extract all frames at once
                imagesAtSpikes(valid,:,:)   = frames(ind, :, :);
            end

            averageImageAtSpike                         = squeeze(nanmean(imagesAtSpikes, 1));
            averageImagesAll_shuffled(ib,iCell,it,:,:)  = averageImageAtSpike;
        end
    end
end
toc
delete(gcp("nocreate"));



%% save data

save( ...
    fullfile( ...
        dirBase, ...
        'sara', ...
        'Analysis', ...
        'Neuropixel', ...
        'marmosetFromNicholas', ...
        'spatialRFs', ...
        ['elf1_spatialRFs_Wiesel_' res '.mat']), ...
    'totalSpikesUsed', ...
    'averageImagesAll', ...
    'averageImagesAll_shuffled', ...
    'imageMatrix', ...
    'nboots', ...
    'beforeSpike');





%% %%%%%%%%%%%%%%%%%
%%%%
%%%


clear all; close all; clc

runloc = 1;   % Where is this script being run? 1 == Hubel, 2 == Wiesel
res = 'HR';

nboots = 1;
beforeSpike = [0.15 0.12 0.09 0.07 0.04]; % Look 40 ms before the spike

%%
if runloc == 1    % Hubel
    dirBase = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home';
    nThreads = 20;
elseif runloc == 2    % Wiesel
    dirBase = 'home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home';
    nThreads = 40;
else
    error('Location not valid. 1 == Hubel, 2 == Wiesel.')
end

%% load RF experiment data

load(fullfile(dirBase,'sara','Data','fromNicholas','CrossOri_randDirFourPhase_V1_marmoset_LFP','elf1','elfrfdata.mat'))
% Variables loaded:
%   dgspikes        nCells x nBins (matrix) - 1ms bins with spike counts (0/1)
%   onstimmatlr     1 x nTrials (cell array) containing [nPixels x nFrames]  - "on" stim image for low resolution experiment
%   offstimmatlr
%   onstimmathr
%   offstimmathr
%   stimstlr        1 x nTrials (matrix) -  trial start time (in seconds) for low resolution experiment
%   stimsthr

refRate = 99.9726324918554; % refresh rate of monitor, from Nicholas (in Hz)


%% get spike times 

dt = 0.001; % 1 ms bins

nCells = size(dgspikes,1);
spikeTimes = cell(nCells,1);

for i = 1:nCells
    spikeTimesCell{i} = find(dgspikes(i,:)) * dt; % find indices of spikes and convert to seconds
end

%% make imageMatrix

if res == 'LR'
    OnStim_list = cat(3,onstimmatlr{:});
    OffStim_list = cat(3,offstimmatlr{:});
elseif res == 'HR'
    OnStim_list = cat(3,onstimmathr{:});
    OffStim_list = cat(3,offstimmathr{:});
else
    error('*res* variable is not interpretable. Set to low resolution (LR) or high resolution (HR)')
end

stim_list = OnStim_list - OffStim_list; % nPixels x nFrames x nTrials

nTrials = size(stim_list,3);
nFramesPerTrial = size(stim_list,2);
nSizeStimSide = sqrt(size(stim_list,1));

% reshape into imageMatrix
stim_list_reorder = permute(stim_list, [3 2 1]);     % change order to nTrials x nFrames x nPixels
imageMatrix = reshape(stim_list_reorder, nTrials, nFramesPerTrial, nSizeStimSide, nSizeStimSide);       % nPixels -> 2D stimulus square



%% get stimulus on times

if res == 'LR'
    trialOnsets = stimstlr; % load the start of each stimulus presentation from .mat file from Nicholas
elseif res == 'HR'
    trialOnsets = stimsthr; 
else
    error('*res* variable is not interpretable. Set to low resolution (LR) or high resolution (HR)')
end


fr = 1/refRate;

for it = 1:nTrials
    timestamps(it,:) = trialOnsets(it) + (0:(nFramesPerTrial-1))*fr;  
end


%%
nCells  = size(dgspikes,1);
lastTimestamp = timestamps(end)+10; % Last timestamp plus 10 seconds

totalSpikesUsed = [];
averageImagesAll = [];

parpool("Threads", nThreads)   % Start parallel pool processing
tic
for iCell = 170:179
    fprintf(['cell ' num2str(iCell) '/' num2str(nCells) '\n'])
    exCellSpikeTimes = spikeTimesCell{iCell};  % Not continuous recording, there are no spikes after lastTimestamp
    totalSpikesUsed(iCell) = length(exCellSpikeTimes);
        for it = 1:length(beforeSpike)
            timeBeforeSpike = beforeSpike(it); % Look [40 ms, etc.] before the spike
            nSpikes = length(exCellSpikeTimes);
            imagesAtSpikesCell = cell(nSpikes, 1);
            % Parallelize looping over spike times
            parfor is = 1:nSpikes
                spikeTime = exCellSpikeTimes(is);
                [trialIdx, frameIdx] = findNoiseStimAtSpike_marmoset(spikeTime, timestamps, timeBeforeSpike);
                if ~isnan(trialIdx) && ~isnan(frameIdx)
                    frameAtSpike = squeeze(imageMatrix(trialIdx, frameIdx, :, :));
                    imagesAtSpikesCell{is} = frameAtSpike;
                else
                    imagesAtSpikesCell{is} = NaN(nSizeStimSide, nSizeStimSide);
                end
            end
            % Convert back to 3D array
            imagesAtSpikes = NaN(nSpikes, nSizeStimSide, nSizeStimSide);
            for is = 1:nSpikes
                imagesAtSpikes(is, :, :) = imagesAtSpikesCell{is};
            end
            averageImageAtSpike = squeeze(nanmean(imagesAtSpikes, 1));
            averageImagesAll(iCell,it,:,:)  = averageImageAtSpike;  % Put in matrix to use later. Size: [nBoots x nCells x nTimePointsBeforeSpike x xDim x yDim]
        end
end
toc
delete(gcp("nocreate"));


%% bootstrap script

averageImagesAll_shuffled   = NaN(nboots, nCells, numel(beforeSpike), nSizeStimSide, nSizeStimSide);
imageMatrix_list            = reshape(imageMatrix, [], size(imageMatrix,3), size(imageMatrix,4));   % Reshape from nTrials x nFrames to one dimension of all trials (nTrials*nFrames)
frameStarts                 = timestamps;
frameEnds                   = [timestamps(:,2:end), timestamps(:,end)+0.1];
[nTrials, nFrames]          = size(timestamps);
timeOffsets                 = 1:numel(beforeSpike);

parpool("Threads", nThreads)   % Start parallel pool processing
tic
for ib = 1:nboots
    fprintf(['boot ' num2str(ib) '/' num2str(nboots) '\n'])
    trialOrder          = randperm(size(imageMatrix,1));     % Random permutation of the integers from 1 to number of total trials without repeating elements
    frameOrder          = randperm(size(imageMatrix,2)); 
    imageMatrix_shuf    = imageMatrix(trialOrder, frameOrder, :, :);   % Resample with the random permutation and then reshape into expected matrix size
    parfor iCell = 170:179
        exCellSpikeTimes = spikeTimesCell{iCell}; 
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
            imagesAtSpikes = NaN(nSpikes, nSizeStimSide, nSizeStimSide);    % Preallocate
                
            % Convert valid indices to linear indices
            if any(valid)
                ind                         = sub2ind([size(imageMatrix_shuf,1), size(imageMatrix_shuf,2)], trialIdx(valid), frameIdx(valid));    % Compute linear indices into imageMatrix_shuf
                frames                      = reshape(imageMatrix_shuf, [], nSizeStimSide, nSizeStimSide);    % Extract all frames at once
                imagesAtSpikes(valid,:,:)   = frames(ind, :, :);
            end

            averageImageAtSpike                         = squeeze(nanmean(imagesAtSpikes, 1));
            averageImagesAll_shuffled(ib,iCell,it,:,:)  = averageImageAtSpike;
        end
    end
end
toc
delete(gcp("nocreate"));



%% save data

save( ...
    fullfile( ...
        dirBase, ...
        'sara', ...
        'Analysis', ...
        'Neuropixel', ...
        'marmosetFromNicholas', ...
        'spatialRFs', ...
        ['elf1_spatialRFs_Wiesel_' res '.mat']), ...
    'totalSpikesUsed', ...
    'averageImagesAll', ...
    'averageImagesAll_shuffled', ...
    'imageMatrix', ...
    'nboots', ...
    'beforeSpike');

