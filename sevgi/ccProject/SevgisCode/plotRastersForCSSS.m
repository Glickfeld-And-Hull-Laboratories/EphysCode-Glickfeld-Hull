function plotRastersForCSSS(miceVSDays, behavDataForRecordingDays, unitCSs, unitSSs)

    globals;

    if isequal(miceVSDays,MICE_VS_NAIVE_DAYS)
        modeTraining=1; % NAIVE
    elseif isequal(miceVSDays,MICE_VS_HABITUATION_DAYS)
        modeTraining=2;
    elseif isequal(miceVSDays,MICE_VS_EXPERT_DAYS)
        modeTraining=3;
    end    

    %%%%%%%%%%%%% PLOT RASTERS OF ALL DAYS %%%%%%%%%%%%%%%
    for ind=1:length(miceVSDays) % Loop through each mouse
        mouseId = miceVSDays{ind,1};
        naiveDays = miceVSDays{ind,2};
        plotRaster_CSSS(behavDataForRecordingDays, unitCSs, unitSSs, mouseId, naiveDays, modeTraining); % Loop through each day
    end
    
end