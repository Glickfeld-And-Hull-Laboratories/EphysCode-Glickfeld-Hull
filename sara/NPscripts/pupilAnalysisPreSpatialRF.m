

    threshold = 117;

    base = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';

%Get experiment info
    [exptStruct]    = createExptStruct(iexp); 
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
        if size(stimBlocks{ib},1) > 10  % If stimulus block has at least 10 trials...
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
        % if xx > 0 
        %     figure; histogram(dt(xx),length(xx)); sgtitle([num2str(length(xx)) 'intervals outside of the expected range'])
        % end
    end


    % Build the list of individual frame times (5 frames per patchclamp leading edge signal, evenly spaced within the 100 ms)
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
        % if ~isempty(xx)
        %     figure;
        %     histogram(dt(xx), numel(xx));
        %     sgtitle([num2str(numel(xx)) ' intervals outside of the expected range']);
        % end
    end   
    disp('The numver of intervals outside of the expected range should be equal for both checks.')
        

    





    


% ==================