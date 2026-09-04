
function getSpatialRF_HeldOut_Correlations(iexp, exptloc, runloc, cellsIdx, nChunks, doCrop)

%% Load expt info
fprintf('Loading expt info... \n')
[exptStruct] = createExptStruct(iexp,exptloc); % Load relevant times and directories for this experiment

%% Load unit info
fprintf('Loading unit info... \n')

if runloc == 1    % Hubel
    dirBase = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home';
    nThreads = 20;
elseif runloc == 2    % Wiesel
    dirBase = '/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home';
    nThreads = 40;
elseif runloc == 3   % Nuke
    dirBase = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home';
    nThreads = 10;
else
    error('Location not valid. 1 == Hubel, 2 == Wiesel.')
end

load(fullfile(dirBase,'sara','Analysis','Neuropixel', exptStruct.date, [exptStruct.date '_' exptStruct.mouse '_unitStructs.mat']))
load(fullfile(dirBase,'sara','Analysis','Neuropixel', exptStruct.date, [exptStruct.mouse '-' exptStruct.date '_spatialRFs.mat']),'bestTimePoint')


%% Load timestamps and downsampled white noise stimulus
fprintf('Loading timestamps and downsampled white noise stimulus... \n')

    mouse = exptStruct.mouse;
    date = exptStruct.date;
 
    % Load stim on information (both MWorks signal and photodiode)
        cd(fullfile(dirBase, exptStruct.loc, 'Analysis', 'Neuropixel', exptStruct.date))        % Move from KS_Output folder to ...\Analysis\neuropixel\date folder, where TPrime output is saved
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
    load(fullfile(dirBase, exptStruct.loc, 'Analysis', 'Neuropixel', 'noiseStimuli/', '5min_2deg_4rep_imageMatrix.mat'))

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

%% Compute STA
fprintf('Computing STA... \n')

nCells  = length(goodUnitStruct);
lastTimestamp = timestamps(end)+10; % Last timestamp plus 10 seconds

totalSpikesUsed = [];
averageImagesAll = [];

cellsToUse_list = 1:length(cellsIdx);
stimImages = imageMatrix; %trying this because I'm getting a weird error when I run as a function

parpool("Threads", nThreads)   % Start parallel pool processing
tic
for ic = cellsToUse_list
    iCell = cellsIdx(ic);
    fprintf(['cell ' num2str(ic) '/' num2str(length(cellsIdx)) '\n'])
    exCellSpikeTimes = goodUnitStruct(iCell).timestamps(find(goodUnitStruct(iCell).timestamps<lastTimestamp));  % Only take spikes during the RF run (for speed of processing)  
    totalSpikesUsed(ic) = length(exCellSpikeTimes);
    it = bestTimePoint(iCell,1);
    timeBeforeSpike = beforeSpike(it); % Look [40 ms, etc.] before the spike
    nSpikes = length(exCellSpikeTimes);
    imagesAtSpikesCell = cell(nSpikes, 1);
    % Parallelize looping over spike times
    spksToUse_list = 1:nSpikes;
    parfor is = spksToUse_list
        spikeTime = exCellSpikeTimes(is);
        [trialIdx, frameIdx] = findNoiseStimAtSpike(spikeTime, timestamps, timeBeforeSpike);
        if ~isnan(trialIdx) && ~isnan(frameIdx)
            frameAtSpike = squeeze(stimImages(trialIdx, frameIdx, :, :));
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
fprintf('Making heldOutMask... \n')

nTrials = size(imageMatrix,1);
framesPerTrial = size(imageMatrix,2);
totalFrames = nTrials*framesPerTrial;
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
fprintf('Computing STAs with heldOutMask... \n')

totalSpikesUsed_HO = [];
averageImagesAll_HO = [];
stimImages = imageMatrix; %trying this because I'm getting a weird error when I run as a function
chunksToUse_list = 1:nChunks;

parpool("Threads", nThreads)   % Start parallel pool processing
tic
for ih = chunksToUse_list
    fprintf(['heldOut chunk ' num2str(ih) '/' num2str(nChunks) '\n'])
    for ic = cellsToUse_list
        iCell = cellsIdx(ic);
        exCellSpikeTimes = goodUnitStruct(iCell).timestamps(find(goodUnitStruct(iCell).timestamps<lastTimestamp));  % Only take spikes during the RF run (for speed of processing)  
        totalSpikesUsed_HO(ih,ic) = length(exCellSpikeTimes);
        it = bestTimePoint(iCell,1);
        timeBeforeSpike = beforeSpike(it); % Look [40 ms, etc.] before the spike
        nSpikes = length(exCellSpikeTimes);
        imagesAtSpikesCell = cell(nSpikes, 1);
        % Parallelize looping over spike times
        spksToUse_list = 1:nSpikes;
        parfor is = spksToUse_list
            spikeTime = exCellSpikeTimes(is);
            [trialIdx, frameIdx] = findNoiseStimAtSpike(spikeTime, timestamps, timeBeforeSpike);
            if ~isnan(trialIdx) && ~isnan(frameIdx) && heldOutMask(ih,trialIdx, frameIdx)
                frameAtSpike = squeeze(stimImages(trialIdx, frameIdx, :, :));
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
fprintf('Loading STA bootstrap to get pixelwise null distribution... \n')

load(fullfile(dirBase,'sara','Analysis','Neuropixel',exptStruct.date,[exptStruct.mouse '-' exptStruct.date '_spatialRFs_Wiesel.mat']),'averageImagesAll_shuffled');
allCells_bootstrap = averageImagesAll_shuffled;   % loads all cells for the experiment
clear averageImagesAll_shuffled

for ic = 1:length(cellsIdx)
    iCell = cellsIdx(ic);
    averageImagesAll_shuffled(:,ic,:,:) = allCells_bootstrap(:,iCell,bestTimePoint(ic,1),:,:);
end

%% pixelwise de-noising of STA
fprintf('Computing STA zscore... \n')

%     averageImagesAll_reshaped   = reshape(averageImagesAll, [1, size(averageImagesAll)]);
%     STAs_all                    = cat(1, averageImagesAll_reshaped, averageImagesAll_HO);
%     
    wnMean          = mean(mean(imageMatrix,1),2);
    wnMeanAvg       = mean(wnMean(:));
    wnMeanDiffMat   = wnMean-wnMeanAvg;

    averageImagesAll_shuffledMinusMean  = averageImagesAll_shuffled - reshape(reshape(wnMeanDiffMat,[],xDim,yDim),[],1,xDim,yDim);

    nCellsSel = size(averageImagesAll_shuffledMinusMean, 2);
    shuffledMean = reshape(mean(averageImagesAll_shuffledMinusMean,1),   nCellsSel, xDim, yDim);
    shuffledStd  = reshape(std(averageImagesAll_shuffledMinusMean,0,1),  nCellsSel, xDim, yDim);

   % for normal STA
    averageImagesAll_MinusMean  = averageImagesAll - reshape(wnMeanDiffMat,[],xDim,yDim);
    averageImageZscore          = (averageImagesAll_MinusMean-shuffledMean)./shuffledStd;   % z-score: subtract mean from the raw value and then divide all by standard deviation
    zscoreSTAs_all(1,:,:,:)     = averageImageZscore;

   % for held out data STAs
   for ih = 1:nChunks
        data = reshape(averageImagesAll_HO(ih,:,:,:), nCellsSel, xDim, yDim);
        averageImagesAll_MinusMean_HO           = data - reshape(wnMeanDiffMat,[],xDim,yDim);
        averageImageZscore_HO                   = (averageImagesAll_MinusMean_HO-shuffledMean)./shuffledStd;   % z-score: subtract mean from the raw value and then divide all by standard deviation
        zscoreSTAs_all(ih+1,:,:,:)              = averageImageZscore_HO;
   end


%% get spike counts per stimulus
fprintf('Computing spike counts per white noise frame... \n')

binsize = 0.06;   % 60ms bin, will be centered on the timepoint input to the function

its = beforeSpike(bestTimePoint(cellsIdx,1));   % this function expects a timestamp input for each cell to center the window on; do NOT give it the index value list

spkCounts = getSpkTimesForRFConvolution(cellsIdx,its,binsize,iexp,runloc);


%% Fitting
fprintf('Fitting models to data... \n')

for ih = 1:(nChunks+1)
    fprintf(['Held out data chunk: ' num2str(ih) '/' num2str(nChunks) '\n'])

    nSelected   = numel(cellsIdx);
    
    if ih == 1
        if doCrop
            sideLength      = 29;
            STA_for_fitting_all = nan(sideLength, sideLength, nSelected, nChunks+1); 
            xStart_all          = nan(nSelected, nChunks+1);        
        else
            STA_for_fitting_all = nan(xDim, yDim, nSelected, nChunks+1); 
        end
    end

    
    if doCrop
        
        STA_cropped     = nan(sideLength, sideLength, nSelected);
        for k = 1:nSelected
            data        = squeeze(zscoreSTAs_all(ih, k, :, :));
            [el, az]    = getRFcenter(data);
            data_smth   = medfilt2(imgaussfilt(data, 1));
            [STA_cropped(:, :, k), xStart(k)] = cropRFtoCenter(az, el, data_smth, sideLength);
        end
        STA_for_fitting     = STA_cropped;
        xStart_all(:,ih)    = xStart(:);
    else
        % zscoreSTAs_all is (nChunks+1, nCells, xDim, yDim); reorder to
        % (xDim, yDim, nSelected) to match STA_for_fitting_all's shape
        STA_for_fitting = permute(squeeze(zscoreSTAs_all(ih,:,:,:)), [2 3 1]);
    end


    STA_for_fitting_all(:,:,:,ih) = STA_for_fitting;   
              

    options.visualize = 0;
    options.parallel  = 0;
    options.shape     = 'elliptical';
    options.runs      = 48;
    
    modelRegistry = [
        struct( ...
            'name','Noncon DoG', ...
            'type','standard', ...
            'fitFcn', @(STA) fitNonConcentricEllipticalDoG(STA,'unnormalized',20), ...
            'k',10)
        struct( ...
            'name','Gabor', ...
            'type','sg', ...
            'fitFcn', @(STA) fit2dGabor_JM(STA,options), ...
            'k',10)
        struct( ...
            'name','Gaussian', ...
            'type','standard', ...
            'fitFcn', @(STA) fitEllipticalGaussian(STA,'unnormalized',20), ...
            'k',7)
    ];
    
    omitCells = [];
    
    fitIdx = 1:nSelected;
    
    results = runRFModelComparison( ...
        fitIdx, ...
        cellsIdx, ...
        STA_for_fitting, ...
        modelRegistry, ...
        omitCells, ...
        'pdf', ...
        'test_all_fit.pdf');
    
    if options.parallel == 1
        delete(gcp("nocreate"));
    end
    
    modelNames  = {results.modelRegistry.name};
    
    dog_fits    = cat(3,results.models{1}{:});
    gabor_fits  = cat(3,results.models{2}{:});
    gaus_fits   = cat(3,results.models{3}{:});
    
    
    dog_fits_all(:,:,:,ih)    = cat(3,results.models{1}{:});
    gabor_fits_all(:,:,:,ih)  = cat(3,results.models{2}{:});
    gaus_fits_all(:,:,:,ih)   = cat(3,results.models{3}{:});

    if ih == 1 % if full condition, save results
        results_full = results;
    else
        results_HO{ih} = results;
    end

end


%% Plot STA
fprintf('Plotting STAs... \n')

data_all                    =  zscoreSTAs_all;
maxSmth = max(max(max(max(abs(data_all)))));

% Print STA time point choices
pdfDir = fullfile(dirBase, 'sara', 'Analysis', 'Neuropixel',exptStruct.date, 'spatialRFs_heldOut');
if ~exist(pdfDir, 'dir'); mkdir(pdfDir); end

pdfFile = fullfile(pdfDir, 'spatialRFs_zscored_heldOut.pdf');
if isfile(pdfFile); delete(pdfFile); end

for ic = 1:length(cellsIdx)
    iCell = cellsIdx(ic);
    figure();
    sgtitle(['cell ' num2str(iCell) ', ic = ' num2str(ic)])
        data = medfilt2(imgaussfilt(squeeze(data_all(1,ic,:,:)),1));
        subplot(4,5,1)
            imagesc(data); hold on
            pbaspect([16 9 1])
            colormap(gray)
            clim([-5 5])
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            subtitle('STA')
    for ih = 1:nChunks
        data = medfilt2(imgaussfilt(squeeze(data_all(ih+1,ic,:,:)),1));
        subplot(4,5,ih+5)
            imagesc(data); hold on
            pbaspect([16 9 1])
            colormap(gray)
            clim([-5 5])
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
    end
    % Append current figure as a new page in the PDF
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);
    close(gcf)
end


% Print STA time point choices
numCells = length(cellsIdx);
figPlotN = ceil(sqrt(numCells));

% 
% figure();
% for ic = 1:length(cellsIdx)
%     subplot(figPlotN,figPlotN,ic)
%         iCell = cellsIdx(ic);
%         sgtitle('cropped STA')
%             data = squeeze(STA_for_fitting_all(1,:,:,ic)); hold on
%             imagesc(data); hold on
%             axis square; box off; axis off
%             colormap(gray)
%             clim([-5 5])
%             set(gca,'xtick',[]); set(gca,'xticklabel',[])
%             set(gca,'ytick',[]); set(gca,'yticklabel',[])
%             subtitle(num2str(ic))
% end
% print(fullfile(dirBase, 'sara','Analysis','Neuropixel', exptStruct.date, 'spatialRFs_heldOut', 'spatialRFs_zscored_1page.pdf'),'-dpdf','-bestfit');




%% Uncrop fits to full stimulus size
fprintf('Uncropping fits... \n')

if doCrop
    for ic = 1:nSelected
        xs = xStart_all(ic, ih);
        xe = xs + sideLength - 1;    % ending column (should be xs+28)
        for ih = 1:(nChunks+1)
            data = dog_fits_all(:,:,ic,ih);   % 29 x 29
            dog_corner = data(end,1);
            fullImg = dog_corner * ones(29, 52);   % Initialize full image with corner value
            fullImg(:, xs:xe) = data;   % Insert cropped data into correct location
            dog_fits_Uncropped(:,:,ic,ih) = fullImg; 
    
            data = gabor_fits_all(:,:,ic,ih);   % 29 x 29
            gabor_corner = data(end,end);
            fullImg = gabor_corner * ones(29, 52);   % Initialize full image with corner value
            fullImg(:, xs:xe) = data;   % Insert cropped data into correct location
            gabor_fits_Uncropped(:,:,ic,ih) = fullImg; 
    
            data = gaus_fits_all(:,:,ic,ih);   % 29 x 29
            gaus_corner = data(end,end);
            fullImg = gaus_corner * ones(29, 52);   % Initialize full image with corner value
            fullImg(:, xs:xe) = data;   % Insert cropped data into correct location
            gaus_fits_Uncropped(:,:,ic,ih) = fullImg; 
        end
    end
else
    % fits are already full-size
    dog_fits_Uncropped  = dog_fits_all;
    gabor_fits_Uncropped = gabor_fits_all;
    gaus_fits_Uncropped  = gaus_fits_all;
end



%% Model fits to test
fprintf('Getting correlations of fits and spike counts for held out data... \n')
fprintf('Making figures... \n')


mNames = {'dog','gabor','gaus'};

fitNames = {'dog_fits_Uncropped',...
            'gabor_fits_Uncropped',...
            'gaus_fits_Uncropped'};

nHeldOut = nChunks;

% Store correlations
corr_full = struct();
corr_HO = struct();

% Loop through models
for im = 1:length(mNames)

    model = mNames{im};
    fitData = eval(fitNames{im});
    fprintf('Running %s model...\n', model)

    % Get filters
    % ig=1 corresponds to full dataset fit
    filt = permute(fitData(:,:,:,1), [3 1 2]);
    % dimensions: cells x X x Y
    
    % Full convolution
    resp_all = convolveRFwithStim_HeldOutImageMatrix(filt, runloc);

    % Correlation for each cell
    corr_full.(model) = nan(nSelected,1);

    for ic = 1:nSelected
        corr_full.(model)(ic) = corr(resp_all(:,ic), spkCounts(:,ic), 'Rows','complete');
    end

    % Held-out convolution
    resp_all_HO = convolveRFwithStim_HeldOutImageMatrix(filt, runloc, heldOutMask);

    % Correlation on held-out frames
    corr_HO.(model) = nan(nSelected,nHeldOut);

    for ih = 1:nHeldOut
        mask = squeeze(heldOutMask(ih,:,:));
        mask_flat = mask(:);
        % Frames used in convolution function
        test_idx = find(mask_flat == 0);
        spk_test = spkCounts(test_idx,:);
        pred_test = resp_all_HO(:,:,ih);
        for ic = 1:nSelected
            corr_HO.(model)(ic,ih) = corr(pred_test(:,ic),spk_test(:,ic),'Rows','complete');
        end
    end
end

figure;
    hold on
    for im = 1:length(mNames)
        % average held-out corr per cell
        y = mean(corr_HO.(mNames{im}),2,'omitnan');
        plot(1:nSelected,y,'o-')
    end
    xlabel('Cell')
    ylabel('Held-out correlation (mean)')
    legend(mNames)
    title('Model prediction accuracy by cell')
print(fullfile(dirBase, 'sara','Analysis','Neuropixel', exptStruct.date, 'spatialRFs_heldOut', 'spatialRFs_heldOutCorrelations1.pdf'),'-dpdf','-bestfit');


figure;
for im = 1:length(mNames)
    subplot(3,1,im)
    hold on
    
    % Scatter individual held-out folds
    y_HO_all = corr_HO.(mNames{im});              % nSelected x nHeldOut
    x_HO_all = repmat((1:nSelected)', 1, nHeldOut); % match dimensions
    scatter(x_HO_all(:), y_HO_all(:), 15, [0.6 0.6 0.6], 'filled', ...
        'MarkerFaceAlpha', 0.4, 'HandleVisibility','off')  % exclude from legend
    
    plot(1:nSelected, corr_full.(mNames{im}), 'o-', 'DisplayName','Full')
    plot(1:nSelected, mean(corr_HO.(mNames{im}),2,'omitnan'), 's-', 'DisplayName','Held-out mean')
    
    xlabel('Cell')
    ylabel('Correlation')
    title(mNames{im})
    legend
end
print(fullfile(dirBase, 'sara','Analysis','Neuropixel', exptStruct.date, 'spatialRFs_heldOut', 'spatialRFs_heldOutCorrelations2.pdf'),'-dpdf','-bestfit');


%Determine winning model per cell, per held-out fold
nModels = length(mNames);
allCorr = cat(3, corr_HO.dog, corr_HO.gabor, corr_HO.gaus);  % nSelected x nHeldOut x nModels
winCounts = zeros(nSelected, nModels);  % rows = cell, cols = model
for ic = 1:nSelected
    for ih = 1:nHeldOut
        vals = squeeze(allCorr(ic, ih, :));  % 1 x nModels
        [~, winnerIdx] = max(vals);
        winCounts(ic, winnerIdx) = winCounts(ic, winnerIdx) + 1;
    end
end

figure(101);
subplot(2,1,1)
    bar(1:nSelected, winCounts, 'stacked')
    xlabel('Cell')
    ylabel(['Number of HO trials won (out of ' num2str(nChunks) ')'])
    legend(mNames)
    title('Winning model by cell, across held-out trials')
    set(gca, 'TickDir', 'out')


%% try to pick "best" winner not absolute

nParams = struct('dog',10,'gabor',8,'gaus',7);
winCounts = zeros(nSelected, nModels);
for ic = 1:nSelected
    for ih = 1:nHeldOut
        vals = squeeze(allCorr(ic, ih, :));  % 1 x nModels
        [maxVal, winnerIdx] = max(vals);
        
        % Find all models within epsilon of the max (candidate ties)
        tol = 0.05 * maxVal; 
        tiedIdx = find(vals >= (maxVal - tol));
        
        if length(tiedIdx) > 1
            % Among tied models, pick the one with fewest params
            tiedParams = cellfun(@(m) nParams.(m), mNames(tiedIdx));
            [~, minParamLocalIdx] = min(tiedParams);
            winnerIdx = tiedIdx(minParamLocalIdx);
        end
        
        winCounts(ic, winnerIdx) = winCounts(ic, winnerIdx) + 1;
    end
end

figure(101);
subplot(2,1,2)
    bar(1:nSelected, winCounts, 'stacked')
    xlabel('Cell')
    ylabel('Number of HO trials won (out of 10)')
    legend(mNames)
    title('Winning model by cell, across held-out trials')
    set(gca, 'TickDir', 'out')
print(fullfile(dirBase, 'sara','Analysis','Neuropixel', exptStruct.date, 'spatialRFs_heldOut', 'spatialRFs_heldOutCorrelations3.pdf'),'-dpdf','-bestfit');

%%
fprintf('Saving output... \n')

save( ...
    fullfile( ...
        dirBase, ...
        exptStruct.loc, ...
        'Analysis', ...
        'Neuropixel', ...
        exptStruct.date, ...
        'spatialRFs_heldOut', ...
        [mouse '-' date '_heldOut_correlations.mat']), ...
    'runloc', ...
    'cellsIdx', ...
    'corr_full', ... % correlations
    'corr_HO', ... % correlations, held out trials
    'mNames', ...  % model names
    'nChunks', ...
    'its', ...
    'spkCounts', ...
    'heldOutMask', ...
    'STA_for_fitting_all', ...
    'results_full', ...
    'results_HO', ...
    'dog_fits_Uncropped', ...
    'gabor_fits_Uncropped', ...
    'gaus_fits_Uncropped', ...
    'zscoreSTAs_all');


fprintf(['Process done. Output saved in... \n' exptStruct.loc '\\Analysis\\Neuropixel\\' exptStruct.date '\\spatialRFs_heldOut\\' mouse '-' date '_heldOut_correlations.mat'])
fprintf('\n')



end
