
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


%% Load bootstrap shuffle

load(fullfile(base, exptStruct.loc, 'Analysis', 'Neuropixel', exptStruct.date, [mouse '-' date '_spatialRFs_Wiesel.mat']))

%% plot spatial RFs

if ~exist(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs']), 'dir')
    mkdir(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs']));
end

nCells  = length(goodUnitStruct);
lastTimestamp = timestamps(end)+10; % Last timestamp plus 10 seconds

figure;
sp      = 1;   % subplot count
start   = 1;    % cell count
n       = 1;    % page count

for iCell = 1:nCells
    for it = 1:length(beforeSpike)
        timeBeforeSpike     = beforeSpike(it); % Look [40 ms, etc.] before the spike
        averageImageAtSpike = squeeze(averageImagesAll(iCell,it,:,:));

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
        start=start+1;z
    end
   if start > 8
        sgtitle('zcore image, clim ([-10 10])')
        print( ...
            fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs'], ...
            [mouse '-' date '_RFs_ZscoreAverageAndThreshold_cell' num2str(iCell-3) 'to' num2str(iCell) '.pdf']), ...
            '-dpdf', '-fillpage')       
        figure;
        movegui('center')
        start   = 1;
        n       = n+1;
        sp      = 1;
        close all
    end
    if iCell == nCells
        sgtitle(['noise trials = ' num2str(size(timestamps,1))])
        print( ...
            fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs'], ...
            [mouse '-' date '_RFs_ZscoreAverageAndThreshold_untilcell' num2str(iCell) '.pdf']), ...
            '-dpdf','-fillpage')
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
    print( ...
        fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs'], ...
        [mouse '-' date '_RFs_2dGaussianFits_cell' num2str(iCell) '.pdf']), ...
        '-dpdf', '-fillpage')
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

save( ...
    fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\', ...
        [mouse '-' date '_spatialRFs.mat']]), ...
    'totalSpikesUsed', ...
    'averageImagesAll', ...
    'averageImagesAll_shuffled', ...
    'averageImageZscore', ...
    'averageImageZscoreThresh', ...
    'nboots', ...
    'zthreshold', ...
    'cells_sigRFbyTime_On', ...
    'cells_sigRFbyTime_Off', ...
    'ind_sigRF' ...
    );

%%
close all;

[m, bestTime] = max(squeeze(sum(sum(averageImageZscore,3),4)),[],2);

listnc  = 1:nCells;
ind     = listnc(sum(cells_sigRFbyTime_On,2)>0);

ind     = [51 60 95 105 112 127 130 132 135];
nc      = length(ind);

% Preallocate struct array for props
clear props
xmask = zeros(29,52);

for ic = 1:nc
    iCell = ind(ic);
    xx = squeeze(averageImageZscore(iCell,bestTime(iCell),:,:));
    maskOn = xx;
    maskOn(maskOn<0) = 0;
    figure;
        subplot(4,4,1); imagesc(xx); colormap('gray'); subtitle('Zscore'); clim([-7 7])
    
    xmask(10:20,10:30) = 1;
    bw = activecontour(maskOn,xmask);
    cc = bwconncomp(bw);
    p = regionprops(cc,"Area");
    [maxArea,maxIdx] = max([p.Area]);
    bw2 = cc2bw(cc,ObjectsToKeep=maxIdx);
    [B,L] = bwboundaries(bw2,'noholes');
    boundary = B{1};
        subplot(4,4,2); imagesc(maskOn); colormap('gray'); subtitle('Zscore'); clim([-7 7])
        subplot(4,4,3); imshow(bw)
        subplot(4,4,4); imshow(label2rgb(L, @jet, [.5 .5 .5]))
        
    
    % get properties of shape
    clear tmp
    tmp = regionprops(bw2, ...
             'Area', ...
             'BoundingBox', ...
             'Circularity', ...
             'Centroid', ...
             'ConvexHull', ...
             'Eccentricity', ...
             'EquivDiameter', ...
             'Extent', ...
             'MajorAxisLength', ...
             'MinorAxisLength', ...
             'Orientation');
      props(ic) = tmp();

      aspRatio = [props(ic).MajorAxisLength]./[props(ic).MinorAxisLength];
      subplot(4,4,5); imshow(label2rgb(L, @jet, [.5 .5 .5]))
            hold on
            plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2);
            title(['A.R. = ' num2str(aspRatio)])
    sgtitle(['cell ' num2str(iCell)])
        
end

aspRatio = [props.MajorAxisLength]./[props.MinorAxisLength];
circ = [props.Circularity];

figure;
    scatter(aspRatio,circ)
    xlabel('aspect ratio (maj axis length/min axis length)')
    ylabel('circularity')
figure;
    scatter(aspRatio,circ)
    xlabel('aspect ratio (maj axis length/min axis length)')
    ylabel('circularity')









ZpAvg = mean(Zp,1);
ZcAvg = mean(Zc,1);
ZpMax = max(Zp,[],1);
ZcMax = max(Zc,[],1);
PCIavg = mean(PCI,1);
PCImax = max(PCI,[],1);


figure;
    subplot 361
        scatter([props.Circularity],ZpAvg(ind))
        ylabel('avg Zp across phases')
        xlabel('circularity')
    subplot 362
        scatter([props.Circularity],ZcAvg(ind))
        ylabel('avg Zc across phases')
        xlabel('circularity')
    subplot 363
        scatter([props.Circularity],ZpMax(ind))
        ylabel('max Zp across phases')
        xlabel('circularity')
    subplot 364
        scatter([props.Circularity],ZcMax(ind))
        ylabel('max Zc across phases')
        xlabel('circularity')
    subplot 365
        scatter([props.Circularity],PCIavg(ind))
        ylabel('avg PCI across phases')
        xlabel('circularity')
    subplot 366
        scatter([props.Circularity],PCImax(ind))
        ylabel('max PCI across phases')
        xlabel('circularity')
    subplot 367
        scatter([props.Eccentricity],ZpAvg(ind))
        ylabel('avg Zp across phases')
        xlabel('eccentricity')
    subplot 368
        scatter([props.Eccentricity],ZcAvg(ind))
        ylabel('avg Zc across phases')
        xlabel('eccentricity')
    subplot 369
        scatter([props.Eccentricity],ZpMax(ind))
        ylabel('max Zp across phases')
        xlabel('eccentricity')
    subplot(3,6,10)
        scatter([props.Eccentricity],ZcMax(ind))
        ylabel('max Zc across phases')
        xlabel('eccentricity')
    subplot(3,6,11)
        scatter([props.Eccentricity],PCIavg(ind))
        ylabel('avg PCI across phases')
        xlabel('circularity')
    subplot(3,6,12)
        scatter([props.Eccentricity],PCImax(ind))
        ylabel('max PCI across phases')
        xlabel('circularity')
    subplot(3,6,13)
        scatter(aspRatio,ZcAvg(ind))
        ylabel('avg Zc across phases')
        xlabel('maj ax length / min ax length')
    subplot(3,6,14)
        scatter(aspRatio,ZpAvg(ind))
        ylabel('avg Zp across phases')
        xlabel('maj ax length / min ax length')
    subplot(3,6,15)
        scatter(aspRatio,ZcMax(ind))
        ylabel('max Zc across phases')
        xlabel('maj ax length / min ax length')
    subplot(3,6,16)
        scatter(aspRatio,ZpMax(ind))
        ylabel('max Zp across phases')
        xlabel('maj ax length / min ax length')
    subplot(3,6,17)
        scatter(aspRatio,PCIavg(ind))
        ylabel('avg PCI across phases')
        xlabel('maj ax length / min ax length')
    subplot(3,6,18)
        scatter(aspRatio,PCImax(ind))
        ylabel('max PCI across phases')
        xlabel('maj ax length / min ax length')
 
    
    


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
