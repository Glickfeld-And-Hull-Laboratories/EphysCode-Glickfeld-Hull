%
%  ===================================== 
% 
% Function to analyze pupil position and radius for each frame, then 
% organize from frames to trials. Run cropPupil.m first
%
% =====================================
%
%   Inputs
%       - iexp (integer), experiment number 
%       - threshold (integer), pixel value to threshold the image at 
%
%

function analyzePupil(iexp, threshold)    
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

% Some plotting of pupil & no pupil found trials
    x = x1;
    minx = length(x);
    frames = sort(randsample(length(x),minx));
    figure;
    start = 1;
    for i = 1:minx
        subplot(10,10,start);
        imagesq(data(:,:,x(frames(i)))); 
        hold on;
        start = start+1;
        if start == 100
            break
        end
    end
    sgtitle(['No pupil detected- ' num2str(length(x)) ' frames']); movegui('center')
    
    x = x2;
    minx = length(x);
    frames = sort(randsample(length(x),minx));
    figure;
    start = 1;
    for i = 1:minx
        subplot(20,20,start);
        imagesq(data(:,:,x(frames(i)))); 
        hold on;
        viscircles(centroid(x(frames(i)),:), radii(x(frames(i))),'Color','k');
        start = start+1;
        if start == 400
            break
        end
    end
    sgtitle('Pupil detected'); movegui('center')

% Get trial information for frames
    dt                  = diff(timestamps);
    gapThreshold        = 0.5;     % seconds
    trialStartIdxAll    = [1; find(dt > gapThreshold) + 1];
    framesPerTrialAll   = diff([trialStartIdxAll; length(timestamps)+1]);
    trialEndIdxAll      = trialStartIdxAll + framesPerTrialAll - 1;
    
    expectedFramesPerTrial  = 30;
    trialIsTooLong          = framesPerTrialAll > 1.5 * expectedFramesPerTrial; % Find gaps in timestamps. remove the first entry if it's too long (non-trial block)
    firstTrialToKeep        = find(~trialIsTooLong, 1, 'first');  % skip initial RF block
    
    trialStartIdx   = trialStartIdxAll(firstTrialToKeep:end); % Extract trial info starting from the first 30 hz on, 0 hz off trial
    trialEndIdx     = trialEndIdxAll(firstTrialToKeep:end);
    framesPerTrial  = framesPerTrialAll(firstTrialToKeep:end);

    fprintf('Detected %d trials. First trial skipped.\n', length(trialStartIdx));


% Look at random trials   
    rng("shuffle");
    trialList = randsample(length(trialStartIdx),15);
    nTrials = numel(trialList);
    ff = 30;
    figure;
    for i = 1:nTrials
        trialIdx = trialList(i);
        for ii = 1:ff
            % Convert to subplot index
            subplotIdx = (i-1)*ff + ii;
            subplot(nTrials, ff, subplotIdx);
                frameIdx = trialStartIdx(trialIdx) + ii;
                imagesq(data(:,:,frameIdx)); 
                hold on;
                viscircles(centroid(frameIdx,:), radii(frameIdx), 'Color','k','LineWidth',0.1);
                axis off;
                if ii==1; title(['trial ' num2str(trialList(i))]); end
        end
    end
    sgtitle('Each row is a trial, each column is a frame');
    movegui('center')
    print(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' date '\' date '_' mouse '_Pupil_rand_trial_samp.pdf'], '-dpdf','-fillpage')



    Rad_temp = radii;
    Centroid_temp = centroid;
    trialLength = trialEndIdx(1) - trialStartIdx(1) + 1;  % assume fixed trial length
    nTrials = numel(trialStartIdx)-1;
    warning('on'); warning('Hard coding the removal of the last trial, because it is often not equal to 30 frames')
    
    % Preallocate
    clear rad_mat_start centroid_mat_start eye_mat_start
    rad_mat_start = nan(trialLength, nTrials);
    centroid_mat_start = nan(trialLength, 2, nTrials);
    eye_mat_start = nan(sz(1), sz(2), trialLength, nTrials);  % assuming sz = size of imag
    
    for itrial = 1:nTrials
        trialFrames  = trialStartIdx(itrial) : trialEndIdx(itrial);
    
        % --- Handle frames where no circle was detected ---
        if any(isnan(Rad_temp(trialFrames,1)))    % If there are any NaNs in the trial...
            nanFrac = sum(isnan(Rad_temp(trialFrames,1))) / length(trialFrames);
            if nanFrac > 0.25   
                % more than 1/4 the trial is NaNs; so discard this trial
                Rad_temp(trialFrames,1) = NaN;
                Centroid_temp(trialFrames,:) = NaN;
            else
                % Interpolate missing values
                nanind = trialFrames(isnan(Rad_temp(trialFrames,1)));
                dataind = trialFrames(~isnan(Rad_temp(trialFrames,1)));
                for inan = 1:length(nanind)
                    gap = min(abs(nanind(inan) - dataind));
                    good_inds = dataind(abs(nanind(inan) - dataind) == gap);
                    Rad_temp(nanind(inan),1) = mean(Rad_temp(good_inds,1));
                    Centroid_temp(nanind(inan),:) = mean(centroid(good_inds,:),1);
                end
            end
          end
        % --- Store trial-aligned data ---
        rad_mat_start(:,itrial) = Rad_temp(trialFrames,1);
        centroid_mat_start(:,:,itrial) = Centroid_temp(trialFrames,:);
        eye_mat_start(:,:,:,itrial) = data(:,:,trialFrames);
    end



    % geometry params (edit if you have better values)
    f = 25;               % lens focal length (mm)
    s = 145;              % lens-to-pupil distance (mm) -- you provided
    R_eye = 1.5;          % eyeball radius (mm) -- change if you want
    pixel_size = 4.8e-3;  % mm (4.8 um)
    D = 230; % mm, eye-to-screen distance
    

    rad_mat_calib = bsxfun(@times, rad_mat_start, calib);
    centroid_mat_calib = bsxfun(@times,centroid_mat_start,calib);

    rad_stim = nan(1, nTrials);
    centroid_stim = nan(nTrials, 2);
    
    for itrial = 1:nTrials
        trialFrames = trialStartIdx(itrial) : trialEndIdx(itrial);
    
        % Extract calibrated data for this trial
        rad_trial = rad_mat_calib(1:numel(trialFrames), itrial);
        cent_trial = squeeze(centroid_mat_calib(1:numel(trialFrames), :, itrial));
    
        % Average over the stimulus period
        rad_stim(itrial) = mean(rad_trial, 'omitnan');

        % mean in mm, then convert to degrees of rotation
        centroid_mm  = mean(cent_trial, 1, 'omitnan');
        centroid_deg = atand(centroid_mm ./ D);
        
        centroid_stim(itrial,:) = centroid_deg;
    end




    figure; 
    subplot(2,1,1)
        scatter(centroid_stim(:,1),centroid_stim(:,2), [], rad_stim); colorbar
        ind = find(~isnan(centroid_stim(:,1)));
        %centroid_med = geometric_median(centroid_stim(:,ind));
        centroid_med = findMaxNeighbors(centroid_stim(ind,:),2);
        hold on;
        scatter(centroid_med(1),centroid_med(2),'og')
        centroid_dist = sqrt((centroid_stim(:,1)-centroid_med(1)).^2 + (centroid_stim(:,2)-centroid_med(2)).^2);
        title('Color- radius')
        xlabel('x-pos')
        ylabel('y-pos')
    subplot(2,1,2)
        hist(centroid_dist,0:0.5:60)
        title([num2str(sum(centroid_dist<4)) ' trials w/in 4 deg'])
        sgtitle([num2str(sum(~isnan(centroid_dist))) '/' num2str(nTrials) ' measurable trials'])
        xlabel('Centroid distance from median')
        movegui('center')
        
    % Compute mean centroid per trial (during stim)
    meanCentroids = squeeze(mean(centroid_mat_start, 1, 'omitnan'));  % [2 x nTrials]
    centroid_dist = vecnorm(meanCentroids' - median(meanCentroids,2)', 2, 2);  % distance from median
    
    % Histogram
    [n, edges, bin] = histcounts(centroid_dist, 0:2:30);
    validBins = find(n);  % bins that have data
    
    % Plot
    [nRows, nCols] = subplotn(length(validBins));
    figure;
    for ii = 1:length(validBins)
        subplot(nRows, nCols, ii)
    
        trialsInBin = find(bin == validBins(ii));  % which trials fall in this bin
    
        % First bin as reference
        if ii == 1
            refTrials = trialsInBin;
        end
    
        % Image: average over trials in this bin
        imToShow = mean(eye_mat_start(:,:,:,trialsInBin), 4, 'omitnan');
        imToShow = mean(imToShow, 3, 'omitnan');  % average across frames
        imagesc(imToShow); axis image; colormap gray; hold on;
    
        % Plot centroid trajectory for this bin
        cx = squeeze(mean(centroid_mat_start(:,1,trialsInBin), 3, 'omitnan'));
        cy = squeeze(mean(centroid_mat_start(:,2,trialsInBin), 3, 'omitnan'));
        plot(cx, cy, 'or')
    
        % Plot centroid trajectory for reference (bin 1)
        cx0 = squeeze(mean(centroid_mat_start(:,1,refTrials), 3, 'omitnan'));
        cy0 = squeeze(mean(centroid_mat_start(:,2,refTrials), 3, 'omitnan'));
        plot(cx0, cy0, 'ok')
    
        title([num2str(edges(validBins(ii))) ' - ' ...
            num2str(edges(validBins(ii)+1)) ' (' ...
            num2str(length(trialsInBin)) ' trials)']);
    end
    sgtitle('Example eye image by distance from median');
    movegui(gcf,'center')









    
%%
    



% Check each chunk has exactly 30 frames
    dt              = diff(timestamps(:));   % Compute frame-to-frame time differences
    chunkBoundaries = [find(dt > 1); numel(timestamps) + 1];   % Find gaps > 1 sec to detect chunk boundaries
    chunkLengths    = diff(chunkBoundaries);
    assert(all(chunkLengths == 30), 'One or more chunks do not have exactly 30 frames.');
    shortChunks     = find(chunkLengths<30);
    longChunks      = find(chunkLengths>30);
 


