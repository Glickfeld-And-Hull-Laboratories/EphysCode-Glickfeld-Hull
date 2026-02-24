
function [stimStruct] = createStimStruct_sizeCon(exptStruct)
    mwtime = exptStruct.exptTime;
    mouse = exptStruct.mouse;
    date = exptStruct.date;

    if contains(date,'_')
        temp_str = strsplit(exptStruct.date,'_');
        mworks_date = temp_str{1};
    else
        mworks_date = date;
    end
    
    % Load MWorks stimulus information
        bName = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\Behavior\Data\data-' mouse '-' mworks_date '-' mwtime '.mat'];
        load(bName);
        
        stimAzimuth        = double(input.gratingAzimuthDeg);
        stimElevation      = double(input.gratingElevationDeg);
        stimDirections     = cell2mat(input.tGratingDirectionDeg);
        stimDiameters      = cell2mat(input.tGratingDiameterDeg);
        stimContrasts      = cell2mat(input.tGratingContrast);

        try
            tStimOnTime        = cell2mat(cellfun(@(x) x(end-1),input.counterTimesUs,'un',0));
            dropTrial = [];
        catch
            tStimOnTime(1) = input.counterTimesUs{1}(end-1);
            tStimOnTime = [tStimOnTime, cell2mat(cellfun(@(x) x(1),input.counterTimesUs(2:end),'un',0))];
            dropTrial = find(cell2mat(cellfun(@(x) length(x)<2,input.counterTimesUs,'un',0)));
        end

        tTrialStart        = cell2mat(input.tThisTrialStartTimeMs);
        
        if length(input.wheelSpeedTimesUs{1}) > 2000
            wheelSpeedValues      = cellfun(@(x) bin_andmake_pad_array(x,100),input.wheelSpeedValues,'un',0);
            wheelSpeedTimestamps  = cellfun(@(x) bin_andmake_pad_array(x,100),input.wheelSpeedTimesUs,'un',0);
        else
            wheelSpeedValues      = input.wheelSpeedValues;
            wheelSpeedTimestamps  = input.wheelSpeedTimesUs;
        end

    % Load stim on information (both MWorks signal and photodiode)
        cd (['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\' exptStruct.loc '\Analysis\Neuropixel\' exptStruct.date])        % Move from KS_Output folder to ...\Analysis\neuropixel\date folder, where TPrime output is saved
        stimOnTimestampsMW  = table2array(readtable([date '_mworksStimOnSync.txt']));
        stimOnTimestampsPD  = table2array(readtable([date '_photodiodeSync.txt']));

    % Lonely TTL removal
        lonelyThreshold = 0.05; % 50 ms
        timeDiffs       = abs(diff(stimOnTimestampsPD));  % Compute pairwise differences efficiently
        hasNeighbor = [false; timeDiffs < lonelyThreshold] | [timeDiffs < lonelyThreshold; false]; % Identify indices where a close neighbor exists
        filteredPD = stimOnTimestampsPD(hasNeighbor);   % Keep only timestamps that have a neighbor within 50 ms

    % Account for report of the monitor's refresh rate in the photodiode signal
        minInterval = 0.4; % Define a minimum separation threshold (should be longer than a refresh cycle but shorter than ISI)     
        leadingEdgesPD = filteredPD([true; diff(filteredPD) > minInterval]); % Extract the leading edges (first timestamp of each stimulus period)
        % [true; ...] ensures that the very first timestamp is always included because otherwise diff() returns an array that is one element shorter than the original.

    % Check that PD signal starts at same time as MW signal; sometimes there are errant PD signals 
        firstMW = stimOnTimestampsMW(1); % Get the first MW timestamp
        leadingEdgesPD = leadingEdgesPD(leadingEdgesPD >= firstMW); % Remove any PD timestamps that occur before the first MW timestamp

    % Find stimulus blocks and separate stim on timestamps
        threshold       = 30; % Time gap to define a break (in seconds)
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
        stimStruct.stimAzimuth          = stimAzimuth;
        stimStruct.stimElevation        = stimElevation;
        stimStruct.timestamps           = stimBlocks{exptStruct.sizeCon_idx};   % Cell array (number of stim blocks long) containing all stim on timestamps within each block
        stimStruct.stimDirection        = stimDirections;
        stimStruct.stimDiameter         = stimDiameters;
        stimStruct.stimContrast         = stimContrasts;
        stimStruct.tWheelSpeedValues    = wheelSpeedValues;
        stimStruct.tWheelSpeedTimestamps= wheelSpeedTimestamps;
        stimStruct.tStimOnTime          = tStimOnTime;
        stimStruct.tTrialStart          = tTrialStart;
        stimStruct.tWheelIntervalS      = 0.1;
        stimStruct.stimDuration         = 0.1;    % Stimulus duration in seconds

        if numel(dropTrial) > 0
            keepTrials = setdiff(1:length(wheelSpeedValues),dropTrial);
            stimStruct.tWheelSpeedValues = wheelSpeedValues(keepTrials);
            stimStruct.tWheelSpeedTimestamps = wheelSpeedTimestamps(keepTrials);
            stimStruct.tStimOnTime = tStimOnTime(keepTrials);
            stimStruct.tTrialStart = tTrialStart(keepTrials);
            stimStruct.stimDirection        = stimDirections(keepTrials);
            stimStruct.stimDiameter         = stimDiameters(keepTrials);
            stimStruct.stimContrast         = stimContrasts(keepTrials);
            % stimStruct.timestamps = stimBlocks{exptStruct.sizeCon_idx}(keepTrials(1:end-1));
        end
        

    warning('*createStimStruct* I am hard coding stimulus duration for now. Assumes 0.1s on, 5s off.')

    
end

function [out_array] = bin_andmake_pad_array(indata,padshape)
    padded_array = nan(padshape,ceil(length(indata)/padshape));

    padded_array(1:length(indata)) = indata;
    reshape_data = reshape(padded_array,padshape,[]);

    out_array = nanmean(reshape_data,1);
end




    
                
