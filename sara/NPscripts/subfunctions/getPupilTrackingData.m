function getPupilTrackingData(exptStruct)

% Set base directories
    dataDir     = (['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Data\neuropixel\' exptStruct.date]);
    analysisDir = (['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date]);

% Load camera frames
    cd(dataDir)
    movieFiles = dir(fullfile(dataDir, '*.avi'));   % Find all files ending in .avi
    assert(numel(movieFiles) == 1, 'Error. Expected exactly one .avi file in dataDir.');    % Throw error if more or less than 1 movie file is found
    mov = VideoReader(movieFiles.name);   % Load frames

% Load frame timestamps
    matFiles = dir(fullfile(dataDir, '*.mat'));   % Find all files ending in .mat
    assert(numel(matFiles) == 1, 'Error. Expected exactly one .mat file in dataDir.');  % Throw error if more or less than 1 matlab file is found
    load(fullfile(dataDir, matFiles.name));   % Load timestamps, should be  in variable 'ts'

% Double check frame timestamps match number of frames collected
    timestamps      = ts(find(ts>0));    % In pupil tracking code, timestamp array is initialized with zeroes and much larger than needed. We only want the recorded timestamps
    framesCollected = mov.NumFrames;     % Get number of frames collected
    assert(length(timestamps) == framesCollected, 'Error. Collected frames do not match collected timestamps.');    % Throw error if frames collected doesn't match timestamps collected

% Double check each chunk of frames has exactly 30 frames
    dt              = diff(timestamps(:));   % Compute frame-to-frame time differences
    chunkBoundaries = [find(dt > 1); numel(timestamps) + 1];   % Find gaps > 1 sec to detect chunk boundaries

% Check each chunk has exactly 30 frames
    chunkLengths    = diff(chunkBoundaries);
    assert(all(chunkLengths == 30), 'One or more chunks do not have exactly 30 frames.');
    shortChunks     = find(chunkLengths<30);
    longChunks      = find(chunkLengths>30);
 







end