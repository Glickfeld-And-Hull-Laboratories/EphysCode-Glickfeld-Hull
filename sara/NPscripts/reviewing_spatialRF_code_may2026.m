%% Refining the spatial RF script


%% Load data

iexp    = 26;
exptloc = 'V1';

% Load data
    baseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
    [exptStruct] = createExptStruct(iexp,exptloc); % Load relevant times and directories for this experiment
    load(fullfile(baseDir, '\sara\Analysis\Neuropixel', [exptStruct.date], [exptStruct.date '_' exptStruct.mouse '_unitStructs.mat']), 'allUnitStruct', 'goodUnitStruct');

%% Load image matrix and timestamps


    mouse = exptStruct.mouse;
    date = exptStruct.date;
    base = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
   

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
        if size(stimBlocks{ib},1) > 2500  % If stimulus block has at least 10 trials...
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


%% Load bootstrap shuffle

load(fullfile(base, exptStruct.loc, 'Analysis', 'Neuropixel', exptStruct.date, [mouse '-' date '_spatialRFs_Wiesel.mat']))

nCells  = length(goodUnitStruct);
lastTimestamp = timestamps(end)+10; % Last timestamp plus 10 seconds


%% Generate zscore image, threshold

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
sigma           = 2; % Standard deviation for smoothing (adjust if needed)
avgImageZscoreSmooth  = imgaussfilt(averageImageZscore, sigma);  % 2D Gaussian smoothing; adjust the kernel size (final value, if needed)



%% find index of cells that have a cluster of 3 sig pixels within a 4 pixel square

nCells = size(goodUnitStruct,2);
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


ind_RF = find(ind_sigRF>0);
MUA_avgSTA = squeeze(mean(abs(squeeze(averageImageZscore(ind_RF,4,:,:))),1));
MUA_maxSTA = squeeze(max(abs(squeeze(averageImageZscore(ind_RF,4,:,:))),[],1));
MUA_sumSTA = squeeze(max(sum(squeeze(averageImageZscore(ind_RF,4,:,:))),1));
figure;movegui('center')
    subplot 321
        imagesc(MUA_avgSTA); set(gca,'CLim',[0 2])
        subtitle(['avg zscore of cells w RF, n=' num2str(length(ind_RF))]); set(gca,'CLim',[0 2])
    subplot 322
        imagesc(imgaussfilt(MUA_avgSTA,1)); colormap('parula'); set(gca,'CLim',[0 2])
        subtitle('imguassfilt, sigma 1')
    subplot 323
        imagesc(medfilt2(MUA_avgSTA)); colormap('parula'); set(gca,'CLim',[0 2])
        subtitle('median filter')
   subplot 324
        imagesc(medfilt2(MUA_maxSTA)); colormap('parula'); set(gca,'CLim',[0 11]); colorbar
        subtitle('max STA, median filter')
  subplot 325
        imagesc(medfilt2(MUA_sumSTA)); colormap('parula'); set(gca,'CLim',[0 13]); colorbar
        subtitle('sum STA, median filter')
    sgtitle('clim [0 2]')



%% get list of cells with detected RF

listnc  = 1:nCells;
ind     = listnc(ind_sigRF>0);

%% Local contrast analysis to choose best beforeSpikeTimepoint  

for ic = 1:nCells
    con_beforeSpike = beforeSpike(2:4);
    % figure;
    % movegui('center')
    is=1;
        for it = [2 3 4]
            xtempz(:,:) = medfilt2(imgaussfilt(squeeze(averageImageZscore(ic,it,:,:)),1)); %3:27,12:36

            if isnan(xtempz(1,1))
                xtempz(:,:) = ones(size(xtempz,1),size(xtempz,2));
            end

            jtempz(:,:) = rangefilt(xtempz(:,:),ones(5));

            % subplot(5,3,is)
                imagesc(squeeze(xtempz(:,:))); colormap('gray'); clim([-5 5]) %axis square;
                subtitle(['zscore STA,' num2str(beforeSpike(it)) ' ms'])
            % subplot(5,3,is+1)
                imagesc(squeeze(jtempz(:,:))); colormap('gray'); clim([0 10]) %axis square
                subtitle('local contrast map')
            % subplot(5,3,is+2)
                j = squeeze(jtempz(:,:));
                q(it) = quantile(j(:),0.9);
                histogram(j); xlim([0 15])
                xline(q(it))
                subtitle([num2str(q(it))])

            localConMap_data(ic,it,:,:) = xtempz;
            localConMap_map(ic,it,:,:) = jtempz;
            is=is+3;        
        end

        [m,i] = max(q);
        bestTimePoint(ic,1) = i; % best time point
        bestTimePoint(ic,2) = m; % max q90 value

        data = medfilt2(imgaussfilt(squeeze(averageImageZscore(ic,i,:,:)),1));
        [az, el] = getRFcenter(data);
        azs(ic) = az;
        els(ic) = el;
        

        % sgtitle([num2str(ic) '- best STA, ' num2str(beforeSpike(i)) ' ms'])
    %     print( ...
    %         fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs'], ...
    %         [mouse '-' date '_RFs_testLocalContrastAnalysis_smooth_cell' num2str(ic) '.pdf']), ...
    %         '-dpdf', '-fillpage')
    % close all
    clear xtempz jtempz q m i
end
