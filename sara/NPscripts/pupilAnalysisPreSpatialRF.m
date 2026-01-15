

    threshold = 80;

    base = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';

%Get experiment info
    [exptStruct]    = createExptStruct(iexp,'V1'); 
    mouse           = exptStruct.mouse;
    date            = exptStruct.date;
    loc             = exptStruct.loc;

% Load cropped pupil data
    load(fullfile([base, loc, '\Analysis\Neuropixel\', date], [mouse '_' date '_pupil_cropped.mat']))
    framesmat = double(framesmat);

% Load timestamps of collected frames
    dataDir     = fullfile(base, loc, 'Data', 'neuropixel', date, '\');
    matFiles    = dir(fullfile(dataDir, '*.mat'));   % Find all files ending in .mat
    assert(numel(matFiles) == 1, 'Error. Expected exactly one .mat file in dataDir.');  % Throw error if more or less than 1 matlab file is found
    load(fullfile(dataDir, matFiles.name));   % Load timestamps, should be  in variable 'ts'

% Double check frame timestamps match number of frames collected
    timestamps      = ts(find(ts>0));    % In pupil tracking code, timestamp array is initialized with zeroes and much larger than needed. We only want the recorded timestamps
    framesCollected = size(framesmat, 3);     % Get number of frames collected
    assert(length(timestamps) == framesCollected, 'Error. Collected frames do not match collected timestamps.');    % Throw error if frames collected doesn't match timestamps collected

% Threshold pixel values to pull out pupil
    framesThreshold                         = framesmat;
    framesThreshold(framesThreshold>threshold)     = 100;
    data                                    = framesThreshold;
    dataSzLoop                              = 1:size(data,3);

% Get trial information for frames
    dt                  = diff(timestamps);
    gapThreshold        = 0.5;     % seconds
    trialStartIdxAll    = [1; find(dt > gapThreshold) + 1];
    framesPerTrialAll   = diff([trialStartIdxAll; length(timestamps)+1]);
    trialEndIdxAll      = trialStartIdxAll + framesPerTrialAll - 1;
    
    expectedFramesPerTrialMin  = 40000;
    trialIsTooShort          = framesPerTrialAll < expectedFramesPerTrialMin; % Find gaps in timestamps. remove the first entry if it's too long (non-trial block)
    firstTrialToKeep        = find(~trialIsTooShort, 1, 'first');  % skip initial RF block
    
    trialStartIdx   = trialStartIdxAll(firstTrialToKeep); % Extract trial info starting from the first 30 hz on, 0 hz off trial
    trialEndIdx     = trialEndIdxAll(firstTrialToKeep);
    framesPerRFExpt  = framesPerTrialAll(firstTrialToKeep);

    fprintf('Detected %d trial. %d frames long. \n', length(trialStartIdx), framesPerRFExpt);

% Only analyze relevant data


figure;
data_avg = mean(data,3);
imagesc(data_avg); clim([])
movegui('center')
ax = gca;
rect = getrect(ax);
datat = data_avg(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
figure;
imagesc(datat)
movegui('center')
while 1  % till broken out of

    % interactively get clicks
    [X Y selectionType] = getAPoint(gca);

    if isnan(X)
        key = lower(Y);
        switch key
          case char(13) % return
            break;  % out of loop, done
          case 'z' 
            imagesc(datat)
            rect = getrect(ax);
            datat = data(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3));
            imagesc(datat)
        end
        continue
    end
end
close all
data = data(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3),:);
sz   = size(data);

% Run imfindcircles to detect the pupil
    calib = 1/27.8; %mm per pixel
    rad_range = [3 20];
    warning off;
    A = cell(sz(3),1);
    B = cell(sz(3),1);
    C = cell(sz(3),1);
    D = cell(sz(3),1);
    for n = 1:sz(3)
        A{n} = [0,0];
        B{n} = 0;
        C{n} = 0;
        D{n} = 0;
    end
    eye = struct('Centroid',A,'Radii',B,'Val',C,'SNR',D);

    parpool("Threads", 20)   % Start parallel pool processing
    tic
    parfor n = dataSzLoop
        warning off;
        [center,radii,metric] = imfindcircles(data(:,:,n), rad_range, 'ObjectPolarity','dark', 'Sensitivity', 0.9);
        if(isempty(center))     % If no circles are found
            eye(n).Centroid = [NaN NaN];    % Set value in eye struct to NaN
            eye(n).Radii    = NaN;
            eye(n).Val      = NaN;
            eye(n).SNR      = NaN;
        else
            snr = zeros(1,size(center,1));
            idx=1;
            t = double(data(:,:,n));
            vector_of_y_values = (1:size(data,1)) - center(idx,2);
            vector_of_x_values = (1:size(data,2)) - center(idx,1);
            [Yg, Xg] = ndgrid(vector_of_y_values, vector_of_x_values);
            idx1 = find(Xg.^2 + Yg.^2 < (radii(idx)/2).^2);
            idx2 = find(Xg.^2 + Yg.^2 < (radii(idx).*2.5).^2 & Xg.^2 + Yg.^2 > (radii(idx).*1.5).^2);
            snr(idx) = mean(t(idx1))./mean(t(idx2));
            [v,idx]             = max(snr);
            val                 = metric(idx);
            t                   = double(data(:,:,n));
            vector_of_y_values  = (1:size(data,1)) - center(idx,2);
            vector_of_x_values  = (1:size(data,2)) - center(idx,1);
            [Yg, Xg]            = ndgrid(vector_of_y_values, vector_of_x_values);
            idx1                = find(Xg.^2 + Yg.^2 < (radii(idx)/2).^2);
            idx2                = find(Xg.^2 + Yg.^2 < (radii(idx).*2.5).^2 & Xg.^2 + Yg.^2 > (radii(idx).*1.5).^2);
            snr                 = mean(t(idx1))./mean(t(idx2));

            eye(n).SNR      = snr;
            eye(n).Val      = val;
            eye(n).Centroid = center(idx,:);
            eye(n).Area     = pi*radii(idx)^2;
            eye(n).Radii    = radii(1);
            
        end
    end
    toc
    delete(gcp("nocreate"));

    centroid = cell2mat({eye.Centroid}');
    radii  = [eye.Radii]';                                                  

    x1 = find(isnan(radii));
    x2 = find(~isnan(radii));





% ==================
% RF block interlude

      
    % Load stim on information (both MWorks signal and photodiode)
        cd (['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\' exptStruct.loc '\Analysis\Neuropixel\' exptStruct.date])        % Move from KS_Output folder to ...\Analysis\neuropixel\date folder, where TPrime output is saved
        stimOnTimestampsMW  = table2array(readtable([date '_mworksStimOnSync.txt']));
        stimOnTimestampsPC  = table2array(readtable([date '_patchclampTriggerSync.txt']));
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
        if size(stimBlocks{ib},1) > 2980 && size(stimBlocks{ib},1) < 3010  % If stimulus block has at least 10 trials...
            ibRF = ibRF + 1;
            RFstimBlocks{ibRF} = stimBlocks{ib}(1:end-1); % Get rid of abherrant lonely PD signal at end of trial block
        end
    end



    frameTriggerStart = stimOnTimestampsPC(2:2:end);  % Trigger to MWorks is the second pulse of 2. This is what the 5 camera frames are aligned to, so we only want that signal
    approxLastFrame = stimOnTimestampsMW(4)+30;
    frameTriggerStartRFblock = frameTriggerStart(frameTriggerStart<approxLastFrame);

% Verify that all intervals between frameTriggerStart are within your expected range
    dt = diff(frameTriggerStartRFblock);
    if all(dt > 0.099 & dt < 0.101)
        disp('All inter-trigger intervals are within expected range.');
    else
        warning('Some inter-trigger intervals are outside 0.098–0.102 seconds!');
        xx = find(~(dt > 0.099 & dt < 0.101));  % show indices of violations
        disp([num2str(length(xx)) ' intervals outside of the expected range.'])
    end


    % Build the list of individual frame times (5 frames per patchclamp leading edge signal, evenly spaced within the 100 ms)
    frameSpacing = 0.02;
    nFramesPerTrigger = 5;
    offsets = (0:frameSpacing:(nFramesPerTrigger-1)*frameSpacing);  % 1 x k
    nTriggers = numel(frameTriggerStartRFblock);
    nCamFrames = numel(offsets);
    
    frameTimes = zeros(nTriggers*nCamFrames,1);  % preallocate
    for i = 1:nTriggers
        idx = (i-1)*nCamFrames + (1:nCamFrames);                      % indices for trigger i
        frameTimes(idx) = frameTriggerStartRFblock(i) + offsets;
    end
    
    % Display first few to visually inspect
    %frameTimes(1:15)

    % Check timing consistency
    dt = diff(frameTimes);
    if all(dt > 0.019 & dt < 0.021)
        disp('All frame-to-frame intervals are within expected range.');
    else
        warning('Some frame-to-frame intervals are outside 0.018–0.021 seconds!');
        xx = find(~(dt > 0.019 & dt < 0.021));
        fprintf('%d intervals outside of the expected range.\n', numel(xx));
    end   
    disp('The number of intervals outside of the expected range should be equal for both checks.')
        
    % 
    % 
    % approxLastFrameForPCcomp = approxLastFrame - frameTimes(1);
    % xxx= timestamps(timestamps<approxLastFrameForPCcomp);


    % Loop through each of the 4 white noise stimulus blocks
    for ib = 1:4
        PDsignal = RFstimBlocks{ib};  % Extract the photodiode (stim-on) timestamps for this block

        % Initialize output variables for this block
        % idx_in_PD:        a cell array where each cell contains indices of pupil frames that occurred between two consecutive photodiode events
        % frameGroupBlock:  vector (same size as frameTimes) where each entry indicates which photodiode event that frame belongs to
        idx_in_PD = cell(numel(PDsignal)-1, 1); 
        frameGroupBlock = zeros(size(frameTimes)); 

        % Loop through all photodiode signals in this block
        for is = 1:numel(PDsignal)
            if is ~= numel(PDsignal)
                % For all but the last PD pulse:
                % Find frames that occurred between PDsignal(is) and PDsignal(is+1)
                idx_in_PD{is} = find(frameTimes >= PDsignal(is) & frameTimes < PDsignal(is+1));
                inWindow = frameTimes >= PDsignal(is) & frameTimes < PDsignal(is+1);
                frameGroupBlock(inWindow) = is;
            else 
                 % For the final PD pulse:
                % There’s no next PDsignal, so assume this window extends 100 ms beyond
                idx_in_PD{is} = find(frameTimes >= PDsignal(is) & frameTimes < (PDsignal(is)+0.101));
                inWindow = frameTimes >= PDsignal(is) & frameTimes < (PDsignal(is)+0.101);
                frameGroupBlcok(inWindow) = is;
            end
        end

        % Store results for this block
        pupilFrameIdx{ib} = idx_in_PD;  % which pupil frame indices belong to each PD interval
        pupilFrameGroups{ib} = frameGroupBlock;  % for each pupil frame, which PD event it belongs to
        pupilFrameCounts{ib} = histcounts(frameGroupBlock, 0.5:1:(max(frameGroupBlock)+0.5));  % how many pupil frames per PD event
    end

% Summary of outputs:
% -------------------------------
% pupilFrameIdx:    1x4 cell array
%                   Each element: cell array (length ≈ number of white noise frames per trial, e.g. 3000)
%                   Each sub-cell: list of pupil frame indices captured during that stimulus
%
% pupilFrameGroups: 1x4 cell array
%                   Each element: numeric vector (same length as frameTimes)
%                   Each entry: stimulus number that the pupil frame belongs to
%
% pupilFrameCounts: 1x4 cell array
%                   Each element: numeric vector (# of frames per stimulus)
%                   Used to verify consistent 5 frames per white noise stimulus





% ==================
% Find points within 1 STD of mean
    
    figure; scatter(centroid(1:length(frameTimes),1),centroid(1:length(frameTimes),2)); movegui('center')
    
    meanX = mean(centroid(1:length(frameTimes),1),"omitmissing");
    stdX = std(centroid(1:length(frameTimes),1),"omitmissing");
    meanY = mean(centroid(1:length(frameTimes),2),"omitmissing");
    stdY = std(centroid(1:length(frameTimes),2),"omitmissing");
    
    % Extract coordinates
    X = centroid(1:length(frameTimes),1);
    Y = centroid(1:length(frameTimes),2);
    
    % Using standard deviation as a scaling factor
    % Option 1: Use average of stdX and stdY as 2D SD
    radialStd = mean([stdX stdY]);
    distFromMean = sqrt( (X - meanX).^2 + (Y - meanY).^2 );
    
    % Logical index of points within 1 radial SD
    within1SD_radial = distFromMean <= radialStd;
    
    % Count and fraction
    numWithin = sum(within1SD_radial);
    fracWithin = numWithin / numel(X);
    
    fprintf('Points within 1 radial SD: %d (%.2f%%)\n', numWithin, fracWithin*100);

% =========================


    nPupilRFFrames = 1:length(frameTimes);
    pupilFramesGoodCentroid = nPupilRFFrames(within1SD_radial);


% =========================
    
    
    for ib = 1:4
        pupilFramesBlock = pupilFrameIdx{ib};
        for is = 1:3000
           pupilFramesStim = pupilFramesBlock{is};
           pupilFramesStimGood = within1SD_radial(pupilFramesStim);
           pupilFramesToInclude = pupilFramesStim.*pupilFramesStimGood;
           nPupilFramesGood = sum(pupilFramesToInclude);
           if nPupilFramesGood > 2 
               imageMatrixPupilGood{ib}(is) = 1;
           else
               imageMatrixPupilGood{ib}(is) = 0;
           end
        end
    end

% =======================


save( ...
    fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\', ...
        [mouse '-' date '_imageMatrixPupilGood.mat']]), ...
    'imageMatrixPupilGood' ...
    );
    
% =======================
% Run on getSpatialRFPostPupilAnalysis_Wiesel.m on Wiesel
% =======================

load(fullfile(base, exptStruct.loc, 'Analysis', 'Neuropixel', exptStruct.date, [mouse '-' date '_spatialRFsPostPupil_Wiesel.mat']))

% =======================
% Plot STAs


if ~exist(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFsPostPupil']), 'dir')
    mkdir(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFsPostPupil']));
end

nCells  = length(goodUnitStruct);
lastTimestamp = approxLastFrame; % Last timestamp plus 10 seconds

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
         print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFsPostPupil'], [mouse '-' date '_spatialRFs_cell' num2str(iCell-7) 'to' num2str(iCell) '.pdf']),'-dpdf', '-fillpage')       
         figure;
         movegui('center')
         start   = 1;
         n       = n+1;
         sp      = 1;
         close all
     end
     if iCell == nCells
         sgtitle(['noise trials = ' num2str(size(timestamps,1))])
         print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFsPostPupil'], [mouse '-' date '_spatialRFs_untilcell' num2str(iCell) '.pdf']), '-dpdf','-fillpage')
         close all
     end   
end






