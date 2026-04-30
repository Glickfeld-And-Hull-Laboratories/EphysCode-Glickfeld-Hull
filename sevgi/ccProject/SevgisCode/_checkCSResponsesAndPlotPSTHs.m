function checkCSResponsesAndPlotPSTHs(miceVSDays, miceVSSelectedDay1, miceVSSelectedDayN, behavDataForRecordingDays, unitCSs, unitSSs, sLabel, modeAlignment)

    globals;
    cellCSResponsivePerMouse = cell(1, length(miceVSDays));
    cellCSNonResponsivePerMouse = cell(1, length(miceVSDays));

    %%%%%%%%%%%%% FIRST, GET ALL DAYS %%%%%%%%%%%%%%%
    for ind=1:length(miceVSDays) % Loop through each mouse
        mouseId = miceVSDays{ind,1};
        days = miceVSDays{ind,2};
        [cellCSTimesResponsive, cellCSTimesNonResponsive] = ...
            checkCSResponses(behavDataForRecordingDays, unitCSs, unitSSs, mouseId, days, modeAlignment, sLabel); % Loop through each day

        cellCSResponsivePerMouse{ind} = cellCSTimesResponsive;
        cellCSNonResponsivePerMouse{ind} = cellCSTimesNonResponsive;   
    end

    %%%%%%%%%%%%%%% DAY 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(miceVSSelectedDay1)        
        [day1CSResponsiveAllMice, day1CSNonResponsiveAllMice, ~, ~, ~, ~] = ...
        buildArraysOfSpikeTimes(miceVSSelectedDay1, cellCSResponsivePerMouse, cellCSNonResponsivePerMouse, ...
        [], [], [], [],0);
    
        callPlot(day1CSResponsiveAllMice, day1CSNonResponsiveAllMice, [], [], [], [], [], [], [], [], '1', modeAlignment, sLabel);
    end

    %%%%%%%%%%%%%%% DAY N %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(miceVSSelectedDayN)
        [dayNCSResponsiveAllMice, dayNCSNonResponsiveAllMice, ~, ~, ~, ~] = ...
        buildArraysOfSpikeTimes(miceVSSelectedDayN, cellCSResponsivePerMouse, cellCSNonResponsivePerMouse, ...
        [], [], [], [],0);
    
        callPlot(dayNCSResponsiveAllMice, dayNCSNonResponsiveAllMice, [], [], [], [], [], [], [], [], 'N', modeAlignment, sLabel);
    end

    %%%%%%%%%%%%%%% DAY ALL %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [dayAllCSResponsiveAllMice, dayAllCSNonResponsiveAllMice, ~, ~, ~, ~] = ...
    buildArraysOfSpikeTimes([], cellCSResponsivePerMouse, cellCSNonResponsivePerMouse, ...
    [], [], [], [],1);

    callPlot(dayAllCSResponsiveAllMice, dayAllCSNonResponsiveAllMice, [], [], [], [], [], [], [], [], 'All', modeAlignment, sLabel);
    
end