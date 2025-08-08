%% Adapted from test_fastASD_3D.m
%

setpaths_ASD    % Run script 'setpaths_ASD.m' 

%% Make the stimulus matrix (x)
% Assuming:
%   imageMatrix: nTrials x nFrames x xDim x yDim
%   xDim, yDim: spatial size of each frame

[nTrials, nFramesPerTrial, xDim, yDim] = size(imageMatrix);
nTotalFrames = nTrials * nFramesPerTrial;
nPixels = xDim * yDim;

% Reshape imageMatrix: flatten frame dimension, preserve order
imageList = reshape(imageMatrix, nTotalFrames, xDim, yDim);  % [nTotalFrames x xDim x yDim]

% Flatten each image: result is [nTotalFrames x (xDim * yDim)]
x = reshape(permute(imageMatrix, [2 1 3 4]), [], size(imageMatrix,3)*size(imageMatrix,4));     % Reshape stacks by column, not by row. So we switch the rows and columns to have it perform the correct function (the goal: stacking going frame1_trial1, frame2_trial1, ..., frame1_trial2)




%% Bin spike times into stimulus frame times (y)
% Assuming:
%   timestamps: [nTrials x nFramesPerTrial], timestamps of each stimulus onset

% Flatten timestamps to match: [nTotalFrames x 1]
stimTimes = reshape(permute(timestamps, [2 1]), [], 1);     % Reshape stacks by column, not by row. So we switch the rows and columns to have it perform the correct function

lastTimestamp = timestamps(end)+10; % Last timestamp plus 10 seconds
nCells = length(goodUnitStruct);
allSpikeTimes = cell(nCells, 1);  % preallocate cell array to hold spike times per unit
for i = 1:nCells
    allSpikeTimes{i} = goodUnitStruct(i).timestamps();  
end
% Filter each cell for spikes before lastTimestamp
spiketimes = cellfun(@(t) t(t < lastTimestamp), allSpikeTimes, 'UniformOutput', false);

cell = 130;
spikeTimesCell = spiketimes{cell};


binEdges = [stimTimes; stimTimes(end) + 0.1];  % bin edges for 10 Hz
y = histcounts(spikeTimesCell, binEdges)';  % [nFrames x 1]



nks = [xDim, yDim, nTotalFrames];
x = double(x);





%% Compute ridge regression estimate 
fprintf('\n...Running ridge regression with fixed-point updates...\n');

% Sufficient statistics (old way of doing it, not used for ASD)
dd.xx = x'*x;   % stimulus auto-covariance
dd.xy = (x'*y); % stimulus-response cross-covariance
dd.yy = y'*y;   % marginal response variance
dd.nx = nks;     % number of dimensions in stimulus
dd.ny = nTotalFrames;  % total number of samples

% Run ridge regression using fixed-point update of hyperparameters
maxiter = 100;
tic;
kridge = autoRidgeRegress_fp(dd,maxiter);
toc;


%% Compute ASD estimate
fprintf('\n\n...Running ASD_2D...\n');

minlen = 2.5;  % minimum length scale along each dimension

tic; 
[kasd,asdstats] = fastASD(x,y,nks,minlen);
toc;

k2d = reshape(kasd, xDim, yDim);

%%  ---- Make Plots ----

kridge_tns = reshape(kridge,nks);
kasd_tns = reshape(kasd,nks);

for j = 1:min(4,nks(3));
    subplot(3,4,j); imagesc(ktns(:,:,j)); 
    title(sprintf('slice %d',j));
    subplot(3,4,j+4); imagesc(kridge_tns(:,:,j));
    subplot(3,4,j+8); imagesc(kasd_tns(:,:,j));
end
subplot(3,4,1); ylabel('\bf{true k}');
subplot(3,4,5); ylabel('\bf ridge');
subplot(3,4,9); ylabel('\bf ASD');


% Display facts about estimate
ci = asdstats.ci;
fprintf('\nHyerparam estimates (+/-1SD)\n-----------------------\n');
fprintf('     l: %5.1f  %5.1f (+/-%.1f)\n',len(1),asdstats.len,ci(1));
fprintf('   rho: %5.1f  %5.1f (+/-%.1f)\n',rho(1),asdstats.rho,ci(2));
fprintf('nsevar: %5.1f  %5.1f (+/-%.1f)\n',signse.^2,asdstats.nsevar,ci(3));

% Compute errors
err = @(khat)(sum((k-khat(:)).^2)); % Define error function
fprintf('\nErrors:\n------\n  Ridge = %7.2f\n  ASD2D = %7.2f\n\n', ...
     [err(kridge) err(kasd)]);
% 









%% Testing fastASD



[nTrials, nFramesPerTrial, xDim, yDim] = size(imageMatrix);
nTotalFrames = nTrials * nFramesPerTrial;

% Convert to [nTotalFrames x xDim x yDim]
imageList = reshape(imageMatrix, nTotalFrames, xDim, yDim);

upsample_factor = 10;  % for 10 Hz → 100 Hz
imageList_us = repelem(imageList, upsample_factor, 1, 1);  % [nTotalFrames*10 x xDim x yDim]

[nFrames, xDim, yDim] = size(imageList_us);
nx = xDim * yDim;

% Final design matrix x: each row is one flattened frame
x = reshape(imageList_us, nFrames, nx);  % size: [frames x (xDim*yDim)]
x = double(x);  % make sure it’s double precision
xavg = mean(mean(x,1),2);
x = x(:,:)-xavg;


% Bin spike times into stimulus frame times (y)
% Assuming:
%   timestamps: [nTrials x nFramesPerTrial], timestamps of each stimulus onset

% Flatten timestamps to match: [nTotalFrames x 1]
stimTimes = reshape(permute(timestamps, [2 1]), [], 1);     % Reshape stacks by column, not by row. So we switch the rows and columns to have it perform the correct function

lastTimestamp = timestamps(end)+10; % Last timestamp plus 10 seconds
nCells = length(goodUnitStruct);
allSpikeTimes = cell(nCells, 1);  % preallocate cell array to hold spike times per unit
for i = 1:nCells
    allSpikeTimes{i} = goodUnitStruct(i).timestamps();  
end
% Filter each cell for spikes before lastTimestamp
spiketimes = cellfun(@(t) t(t < lastTimestamp), allSpikeTimes, 'UniformOutput', false);

icell = 131;
spikeTimesCell = spiketimes{icell};

% Define number of upsampled frames (matches x)
nTotalFrames_us = size(x, 1);

% Define bin edges from first stimulus time (in seconds) for 100 Hz bins
binDuration = 0.01;  % 100 Hz
binEdges = stimTimes(1):binDuration:(stimTimes(1) + binDuration * nTotalFrames_us);

% Bin spike times
y = histcounts(spikeTimesCell, binEdges)';  % [120000 x 1]
yavg = mean(y);
% y = y-yavg;

nks = [xDim, yDim];

%
minlen = [1; 1];  % minimum length scale along each dimension
[kasd,asdstats] = fastASD(x,y,nks,minlen);


asdfit = reshape(kasd, [], yDim);     % [xDim x yDim x nt]

figure; imagesc(asdfit); movegui('center') 











%%


[nTrials, nFramesPerTrial, xDim, yDim] = size(imageMatrix);
nTotalFrames = nTrials * nFramesPerTrial;

% Reshape to [nTotalFrames x xDim x yDim]
imageList = reshape(imageMatrix, nTotalFrames, xDim, yDim);

% Upsample to 100 Hz by repeating each frame
upsample_factor = 10;  % 10 Hz → 100 Hz
imageList_us = repelem(imageList, upsample_factor, 1, 1);  % [nTotalFrames*10 x xDim x yDim]
[nFrames, xDim, yDim] = size(imageList_us);

% Set number of time lags (temporal depth)
nTimeLags = 5;
nks = [xDim, yDim, nTimeLags];  % ASD expects [space x time]
nk = prod(nks);
nSamples = nFrames - nTimeLags + 1;

% Build spatiotemporal design matrix: [nSamples x (xDim*yDim*nTimeLags)]
x = zeros(nSamples, nk);
for t = nTimeLags:nFrames
    stimChunk = imageList_us(t - nTimeLags + 1:t, :, :);  % [nTimeLags x xDim x yDim]
    stimChunk = permute(stimChunk, [2 3 1]);              % [xDim x yDim x nTimeLags]
    x(t - nTimeLags + 1, :) = reshape(stimChunk, 1, []);  % Flatten
end
x = double(x);
x = (x - mean(x, 1)) ./ std(x, 0, 1);

% Subtract mean (recommended)
x = x - mean(x, 1);

% --- Spike binning ---

% Flatten timestamps [nTrials x nFramesPerTrial] → [nTotalFrames x 1]
stimTimes = reshape(permute(timestamps, [2 1]), [], 1);

lastTimestamp = timestamps(end) + 10;
nCells = length(goodUnitStruct);
spiketimes = cellfun(@(t) t(t < lastTimestamp), ...
    arrayfun(@(g) g.timestamps(), goodUnitStruct, 'UniformOutput', false), ...
    'UniformOutput', false);

icell = 131;
spikeTimesCell = spiketimes{icell};

% Generate upsampled timestamps at 100 Hz (to match imageList_us)
fs_new = 100;  % Hz
stimTimes_us = (0:(nFrames-1))' / fs_new + stimTimes(1);  % assumes frame 1 starts at first stim time

% Bin spikes in 100 Hz bins
binEdges = [stimTimes_us; stimTimes_us(end)+1/fs_new];  % [nFrames+1 x 1]
spikeCounts = histcounts(spikeTimesCell, binEdges)';    % [nFrames x 1]
y = spikeCounts(nTimeLags:end);                         % align with x (nSamples x 1)
y = (y - mean(y)) / std(y);  % z-score normalization

% --- Run fastASD ---

minlen = [2.5; 2.5; 2.5];  % smoothness priors (pixels/frames)
[kasd, asdstats] = fastASD(x, y, nks, minlen);

% --- Visualization ---
% Reshape to [nTimeLags x xDim x yDim]
ktns = reshape(kasd, nks);     
ktns = permute(ktns, [3 1 2]);  % [nTimeLags x xDim x yDim]

% Plot selected time slices
figure;
nToPlot = min(6, nTimeLags);
for t = 1:nToPlot
    subplot(2, ceil(nToPlot/2), t);
    imagesc(squeeze(ktns(t, :, :)));
    title(sprintf('Lag %d', t));
    axis image off;
end
sgtitle(sprintf('Spatiotemporal ASD Filter (cell %d)', icell));



%% Original, not upsampled 

[nTrials, nFramesPerTrial, xDim, yDim] = size(imageMatrix);
nTotalFrames = nTrials * nFramesPerTrial;

% Reshape to [nTotalFrames x xDim x yDim]
imageList = reshape(imageMatrix, nTotalFrames, xDim, yDim);
[nFrames, xDim, yDim] = size(imageList);

% Set number of time lags (temporal depth)
nTimeLags = 5;
nks = [xDim, yDim, nTimeLags];  % ASD expects [space x time]
nk = prod(nks);
nSamples = nFrames - nTimeLags + 1;

% Build spatiotemporal design matrix: [nSamples x (xDim*yDim*nTimeLags)]
x = zeros(nSamples, nk);
for t = nTimeLags:nFrames
    stimChunk = imageList(t - nTimeLags + 1:t, :, :);  % [nTimeLags x xDim x yDim]
    stimChunk = permute(stimChunk, [2 3 1]);              % [xDim x yDim x nTimeLags]
    x(t - nTimeLags + 1, :) = reshape(stimChunk, 1, []);  % Flatten
end
x = double(x);
x = (x - mean(x, 1)) ./ std(x, 0, 1);

% Subtract mean (recommended)
x = x - mean(x, 1);

% --- Spike binning ---

% Flatten timestamps [nTrials x nFramesPerTrial] → [nTotalFrames x 1]
stimTimes = reshape(permute(timestamps, [2 1]), [], 1);

lastTimestamp = timestamps(end) + 10;
nCells = length(goodUnitStruct);
spiketimes = cellfun(@(t) t(t < lastTimestamp), ...
    arrayfun(@(g) g.timestamps(), goodUnitStruct, 'UniformOutput', false), ...
    'UniformOutput', false);

icell = 131;
spikeTimesCell = spiketimes{icell};

% Define bin edges from first stimulus time (in seconds) for 100 Hz bins
binDuration = 0.01;  % 100 Hz
binEdges = stimTimes(1):binDuration:(stimTimes(1) + binDuration * nTotalFrames);

% Bin spike times
y = histcounts(spikeTimesCell, binEdges)';  % align with x (nSamples x 1)
y = y(nTimeLags:end);  
y = (y - mean(y)) / std(y);  % z-score normalization


% --- Run fastASD ---

minlen = [2.5; 2.5; 2.5];  % smoothness priors (pixels/frames)
[kasd, asdstats] = fastASD(x, y, nks, minlen);

% --- Visualization ---
% Reshape to [nTimeLags x xDim x yDim]
ktns = reshape(kasd, nks);     
ktns = permute(ktns, [3 1 2]);  % [nTimeLags x xDim x yDim]

% Plot selected time slices
figure;
nToPlot = min(6, nTimeLags);
for t = 1:nToPlot
    subplot(2, ceil(nToPlot/2), t);
    imagesc(squeeze(ktns(t, :, :)));
    title(sprintf('Lag %d', t));
    axis image off;
end
sgtitle(sprintf('Spatiotemporal ASD Filter (cell %d)', icell));





%% try 2D 


[nTrials, nFramesPerTrial, xDim, yDim] = size(imageMatrix);
nTotalFrames = nTrials * nFramesPerTrial;

% Original imageMatrix: [nTrials x nFramesPerTrial x xDim x yDim]
imageList = reshape(imageMatrix, nTotalFrames, xDim, yDim);  
% Now: imageList is [nFrames x xDim x yDim]

x = reshape(permute(imageList, [2 3 1]), nFrames, []);  
% x is [nFrames x (xDim*yDim)]


nks = [xDim, yDim];  
ktns = reshape(kasd, nks);
nk = prod(nks);

x = reshape(permute(imageList, [2 3 1]),nFrames,[]);
x = double(x);
x = (x - mean(x, 1)) ./ std(x, 0, 1);

% --- Spike binning ---

% Flatten timestamps [nTrials x nFramesPerTrial] → [nTotalFrames x 1]
stimTimes = reshape(permute(timestamps, [2 1]), [], 1);

lastTimestamp = timestamps(end) + 10;
nCells = length(goodUnitStruct);
spiketimes = cellfun(@(t) t(t < lastTimestamp), ...
    arrayfun(@(g) g.timestamps(), goodUnitStruct, 'UniformOutput', false), ...
    'UniformOutput', false);

icell = 125;
spikeTimesCell = spiketimes{icell};

% Define bin edges from first stimulus time (in seconds) for 100 Hz bins
binDuration = 0.1;  % 100 Hz
binEdges = stimTimes(1):binDuration:(stimTimes(1) + binDuration * nTotalFrames);




meanStim = squeeze(mean(imageList, 1));  % [xDim x yDim]
stdStim  = squeeze(std(imageList, 0, 1));  % [xDim x yDim]

figure;
subplot(1,2,1); imagesc(meanStim'); axis image; title('Mean stimulus'); colorbar;
subplot(1,2,2); imagesc(stdStim'); axis image; title('Stimulus std dev'); colorbar;


[U,S,~] = svd(x, 'econ');
singularValues = diag(S);

figure;
semilogy(singularValues, '.-'); 
xlabel('Component'); ylabel('Singular value (log)');
title('Stimulus matrix singular values');

cumvar = cumsum(singularValues.^2) / sum(singularValues.^2);
n90 = find(cumvar >= 0.9, 1);

fprintf('Number of components explaining 90%% variance: %d\n', n90);