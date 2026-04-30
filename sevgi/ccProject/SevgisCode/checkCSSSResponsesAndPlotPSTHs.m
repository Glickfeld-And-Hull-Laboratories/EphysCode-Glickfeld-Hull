function [arrModulationMagnitudeRewRespCSDay1, arrModulationMagnitudeCueRespCSDay1, ...
    arrModulationMagnitudeRewRespCSDayN, arrModulationMagnitudeCueRespCSDayN, ...
    arrModulationMagnitudeRewRespCSDayAll, arrModulationMagnitudeCueRespCSDayAll, integralValuesAfterRew] = ...
    checkCSSSResponsesAndPlotPSTHs(miceVSDays, miceVSSelectedDay1, miceVSSelectedDayN, behavDataForRecordingDays, unitCSs, unitSSs, sLabel)

    globals;
    arrModulationMagnitudeRewRespCSDay1 = [];
    arrModulationMagnitudeCueRespCSDay1 = [];
    arrModulationMagnitudeRewRespCSDayN = [];
    arrModulationMagnitudeCueRespCSDayN = [];
    cellCSResponsivePerMouse = cell(1, length(miceVSDays));
    cellCSNonResponsivePerMouse = cell(1, length(miceVSDays));   
    integralValuesAfterRew = [];

    %%%%%%%%%%%%% FIRST, GET ALL DAYS %%%%%%%%%%%%%%%
    for ind=1:length(miceVSDays) % Loop through each mouse
        mouseId = miceVSDays{ind,1};
        days = miceVSDays{ind,2};
        [cellCSTimesResponsive, cellCSTimesNonResponsive, ...
            cellSSTimesJuiceRespCueRespCS, cellSSTimesJuiceRespCueNonRespCS, ...
            cellSSTimesJuiceNonRespCueRespCS, cellSSTimesJuiceNonRespCueNonRespCS, ...
            cellSSAllLicksJuiceRespCueResponsiveCS, cellSSAllLicksJuiceRespCueNonResponsiveCS, ...
            cellSSAllLicksJuiceNonRespCueResponsiveCS, cellSSAllLicksJuiceNonRespCueNonResponsiveCS, ...
            cellSSLickOnsetsJuiceRespCueResponsiveCS, cellSSLickOnsetsJuiceRespCueNonResponsiveCS, ...
            cellSSLickOnsetsJuiceNonRespCueResponsiveCS, cellSSLickOnsetsJuiceNonRespCueNonResponsiveCS, ...
            cellSSCuesJuiceRespCueResponsiveCS, cellSSCuesJuiceRespCueNonResponsiveCS, ...
            cellSSCuesJuiceNonRespCueResponsiveCS, cellSSCuesJuiceNonRespCueNonResponsiveCS] = ...
            checkCSSSResponses(behavDataForRecordingDays, unitCSs, unitSSs, mouseId, days); % Loop through each day

        cellCSResponsivePerMouse{ind} = cellCSTimesResponsive;
        cellCSNonResponsivePerMouse{ind} = cellCSTimesNonResponsive;

        cellSSJuiceRespCueRespCSPerMouse{ind} = cellSSTimesJuiceRespCueRespCS;
        cellSSJuiceRespCueNonRespCSPerMouse{ind} = cellSSTimesJuiceRespCueNonRespCS;
        cellSSJuiceNonRespCueRespCSPerMouse{ind} = cellSSTimesJuiceNonRespCueRespCS;
        cellSSJuiceNonRespCueNonRespCSPerMouse{ind} = cellSSTimesJuiceNonRespCueNonRespCS;

        cellSSAllLicksJuiceRespCueResponsiveCSPerMouse{ind} = cellSSAllLicksJuiceRespCueResponsiveCS;
        cellSSAllLicksJuiceRespCueNonResponsiveCSPerMouse{ind} = cellSSAllLicksJuiceRespCueNonResponsiveCS;
        cellSSAllLicksJuiceNonRespCueResponsiveCSPerMouse{ind} = cellSSAllLicksJuiceNonRespCueResponsiveCS;
        cellSSAllLicksJuiceNonRespCueNonResponsiveCSPerMouse{ind} = cellSSAllLicksJuiceNonRespCueNonResponsiveCS;

        cellSSLickOnsetsJuiceRespCueResponsiveCSPerMouse{ind} = cellSSLickOnsetsJuiceRespCueResponsiveCS;
        cellSSLickOnsetsJuiceRespCueNonResponsiveCSPerMouse{ind} = cellSSLickOnsetsJuiceRespCueNonResponsiveCS;
        cellSSLickOnsetsJuiceNonRespCueResponsiveCSPerMouse{ind} = cellSSLickOnsetsJuiceNonRespCueResponsiveCS;
        cellSSLickOnsetsJuiceNonRespCueNonResponsiveCSPerMouse{ind} = cellSSLickOnsetsJuiceNonRespCueNonResponsiveCS;

        cellSSCuesJuiceRespCueResponsiveCSPerMouse{ind} = cellSSCuesJuiceRespCueResponsiveCS;
        cellSSCuesJuiceRespCueNonResponsiveCSPerMouse{ind} = cellSSCuesJuiceRespCueNonResponsiveCS;
        cellSSCuesJuiceNonRespCueResponsiveCSPerMouse{ind} = cellSSCuesJuiceNonRespCueResponsiveCS;
        cellSSCuesJuiceNonRespCueNonResponsiveCSPerMouse{ind} = cellSSCuesJuiceNonRespCueNonResponsiveCS;
    end

%     %%%%%%%%%%%%%%% DAY 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if ~isempty(miceVSSelectedDay1)        
%         day1CSResponsiveAllMice = expandCellArray(cellCSResponsivePerMouse, miceVSSelectedDay1);
%         day1CSNonResponsiveAllMice = expandCellArray(cellCSNonResponsivePerMouse, miceVSSelectedDay1);
%         day1SSJuiceRespCueRespCSAllMice = expandCellArray(cellSSJuiceRespCueRespCSPerMouse, miceVSSelectedDay1);
%         day1SSJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSJuiceRespCueNonRespCSPerMouse, miceVSSelectedDay1);
%         day1SSJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSJuiceNonRespCueRespCSPerMouse, miceVSSelectedDay1);
%         day1SSJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSJuiceNonRespCueNonRespCSPerMouse, miceVSSelectedDay1);
%         
%         day1SSLicksJuiceRespCueRespCSAllMice = expandCellArray(cellSSAllLicksJuiceRespCueResponsiveCSPerMouse, miceVSSelectedDay1);
%         day1SSLicksJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSAllLicksJuiceRespCueNonResponsiveCSPerMouse, miceVSSelectedDay1);
%         day1SSLicksJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSAllLicksJuiceNonRespCueResponsiveCSPerMouse, miceVSSelectedDay1);
%         day1SSLicksJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSAllLicksJuiceNonRespCueNonResponsiveCSPerMouse, miceVSSelectedDay1);
%         
%         day1SSLickOnsetsJuiceRespCueRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceRespCueResponsiveCSPerMouse, miceVSSelectedDay1);
%         day1SSLickOnsetsJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceRespCueNonResponsiveCSPerMouse, miceVSSelectedDay1);
%         day1SSLickOnsetsJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceNonRespCueResponsiveCSPerMouse, miceVSSelectedDay1);
%         day1SSLickOnsetsJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceNonRespCueNonResponsiveCSPerMouse, miceVSSelectedDay1);
% 
%         day1SSCuesJuiceRespCueRespCSAllMice = expandCellArray(cellSSCuesJuiceRespCueResponsiveCSPerMouse, miceVSSelectedDay1);
%         day1SSCuesJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSCuesJuiceRespCueNonResponsiveCSPerMouse, miceVSSelectedDay1);
%         day1SSCuesJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSCuesJuiceNonRespCueResponsiveCSPerMouse, miceVSSelectedDay1);
%         day1SSCuesJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSCuesJuiceNonRespCueNonResponsiveCSPerMouse, miceVSSelectedDay1);
% 
%         [arrModulationMagnitudeRewRespCSDay1, arrModulationMagnitudeCueRespCSDay1, ~] = callPlot(day1CSResponsiveAllMice, day1CSNonResponsiveAllMice, ...
%         day1SSJuiceRespCueRespCSAllMice, day1SSJuiceRespCueNonRespCSAllMice, ...
%         day1SSJuiceNonRespCueRespCSAllMice, day1SSJuiceNonRespCueNonRespCSAllMice, ...
%         day1SSLicksJuiceRespCueRespCSAllMice, day1SSLicksJuiceRespCueNonRespCSAllMice, ...
%         day1SSLicksJuiceNonRespCueRespCSAllMice, day1SSLicksJuiceNonRespCueNonRespCSAllMice, ...
%         day1SSLickOnsetsJuiceRespCueRespCSAllMice, day1SSLickOnsetsJuiceRespCueNonRespCSAllMice, ...
%         day1SSLickOnsetsJuiceNonRespCueRespCSAllMice, day1SSLickOnsetsJuiceNonRespCueNonRespCSAllMice, ...
%         day1SSCuesJuiceRespCueRespCSAllMice, day1SSCuesJuiceRespCueNonRespCSAllMice, ...
%         day1SSCuesJuiceNonRespCueRespCSAllMice, day1SSCuesJuiceNonRespCueNonRespCSAllMice, ...
%         '1', sLabel);
%     end
% 
%     %%%%%%%%%%%%%%% DAY N %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if ~isempty(miceVSSelectedDayN)
%         dayNCSResponsiveAllMice = expandCellArray(cellCSResponsivePerMouse, miceVSSelectedDayN);
%         dayNCSNonResponsiveAllMice = expandCellArray(cellCSNonResponsivePerMouse, miceVSSelectedDayN);
%         dayNSSJuiceRespCueRespCSAllMice = expandCellArray(cellSSJuiceRespCueRespCSPerMouse, miceVSSelectedDayN);
%         dayNSSJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSJuiceRespCueNonRespCSPerMouse, miceVSSelectedDayN);
%         dayNSSJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSJuiceNonRespCueRespCSPerMouse, miceVSSelectedDayN);
%         dayNSSJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSJuiceNonRespCueNonRespCSPerMouse, miceVSSelectedDayN);
%         
%         dayNSSLicksJuiceRespCueRespCSAllMice = expandCellArray(cellSSAllLicksJuiceRespCueResponsiveCSPerMouse, miceVSSelectedDayN);
%         dayNSSLicksJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSAllLicksJuiceRespCueNonResponsiveCSPerMouse, miceVSSelectedDayN);
%         dayNSSLicksJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSAllLicksJuiceNonRespCueResponsiveCSPerMouse, miceVSSelectedDayN);
%         dayNSSLicksJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSAllLicksJuiceNonRespCueNonResponsiveCSPerMouse, miceVSSelectedDayN);
% 
%         dayNSSLickOnsetsJuiceRespCueRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceRespCueResponsiveCSPerMouse, miceVSSelectedDayN);
%         dayNSSLickOnsetsJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceRespCueNonResponsiveCSPerMouse, miceVSSelectedDayN);
%         dayNSSLickOnsetsJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceNonRespCueResponsiveCSPerMouse, miceVSSelectedDayN);
%         dayNSSLickOnsetsJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceNonRespCueNonResponsiveCSPerMouse, miceVSSelectedDayN);
% 
%         dayNSSCuesJuiceRespCueRespCSAllMice = expandCellArray(cellSSCuesJuiceRespCueResponsiveCSPerMouse, miceVSSelectedDayN);
%         dayNSSCuesJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSCuesJuiceRespCueNonResponsiveCSPerMouse, miceVSSelectedDayN);
%         dayNSSCuesJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSCuesJuiceNonRespCueResponsiveCSPerMouse, miceVSSelectedDayN);
%         dayNSSCuesJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSCuesJuiceNonRespCueNonResponsiveCSPerMouse, miceVSSelectedDayN);
% 
%         [arrModulationMagnitudeRewRespCSDayN, arrModulationMagnitudeCueRespCSDayN, ~] = callPlot(dayNCSResponsiveAllMice, dayNCSNonResponsiveAllMice, ...
%         dayNSSJuiceRespCueRespCSAllMice, dayNSSJuiceRespCueNonRespCSAllMice, ...
%         dayNSSJuiceNonRespCueRespCSAllMice, dayNSSJuiceNonRespCueNonRespCSAllMice, ...
%         dayNSSLicksJuiceRespCueRespCSAllMice, dayNSSLicksJuiceRespCueNonRespCSAllMice, ...
%         dayNSSLicksJuiceNonRespCueRespCSAllMice, dayNSSLicksJuiceNonRespCueNonRespCSAllMice, ...
%         dayNSSLickOnsetsJuiceRespCueRespCSAllMice, dayNSSLickOnsetsJuiceRespCueNonRespCSAllMice, ...
%         dayNSSLickOnsetsJuiceNonRespCueRespCSAllMice, dayNSSLickOnsetsJuiceNonRespCueNonRespCSAllMice, ...
%         dayNSSCuesJuiceRespCueRespCSAllMice, dayNSSCuesJuiceRespCueNonRespCSAllMice, ...
%         dayNSSCuesJuiceNonRespCueRespCSAllMice, dayNSSCuesJuiceNonRespCueNonRespCSAllMice, ...
%         'N', sLabel);
%     end

    %%%%%%%%%%%%%% DAY ALL %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dayAllCSResponsiveAllMice = expandCellArray(cellCSResponsivePerMouse);
    dayAllCSNonResponsiveAllMice = expandCellArray(cellCSNonResponsivePerMouse);
    dayAllSSJuiceRespCueRespCSAllMice = expandCellArray(cellSSJuiceRespCueRespCSPerMouse);
    dayAllSSJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSJuiceRespCueNonRespCSPerMouse);
    dayAllSSJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSJuiceNonRespCueRespCSPerMouse);
    dayAllSSJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSJuiceNonRespCueNonRespCSPerMouse);
    
    daySSAllLicksJuiceRespCueRespCSAllMice = expandCellArray(cellSSAllLicksJuiceRespCueResponsiveCSPerMouse);
    daySSAllLicksJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSAllLicksJuiceRespCueNonResponsiveCSPerMouse);
    daySSAllLicksJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSAllLicksJuiceNonRespCueResponsiveCSPerMouse);
    daySSAllLicksJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSAllLicksJuiceNonRespCueNonResponsiveCSPerMouse);

    daySSLickOnsetsJuiceRespCueRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceRespCueResponsiveCSPerMouse);
    daySSLickOnsetsJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceRespCueNonResponsiveCSPerMouse);
    daySSLickOnsetsJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceNonRespCueResponsiveCSPerMouse);
    daySSLickOnsetsJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceNonRespCueNonResponsiveCSPerMouse);

    daySSCuesJuiceRespCueRespCSAllMice = expandCellArray(cellSSCuesJuiceRespCueResponsiveCSPerMouse);
    daySSCuesJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSCuesJuiceRespCueNonResponsiveCSPerMouse);
    daySSCuesJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSCuesJuiceNonRespCueResponsiveCSPerMouse);
    daySSCuesJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSCuesJuiceNonRespCueNonResponsiveCSPerMouse);

    [arrModulationMagnitudeRewRespCSDayAll, arrModulationMagnitudeCueRespCSDayAll, ~, integralValuesAfterRew] = callPlot(dayAllCSResponsiveAllMice, dayAllCSNonResponsiveAllMice, ...
    dayAllSSJuiceRespCueRespCSAllMice, dayAllSSJuiceRespCueNonRespCSAllMice, ...
    dayAllSSJuiceNonRespCueRespCSAllMice, dayAllSSJuiceNonRespCueNonRespCSAllMice, ...
    daySSAllLicksJuiceRespCueRespCSAllMice, daySSAllLicksJuiceRespCueNonRespCSAllMice, ...
    daySSAllLicksJuiceNonRespCueRespCSAllMice, daySSAllLicksJuiceNonRespCueNonRespCSAllMice, ...
    daySSLickOnsetsJuiceRespCueRespCSAllMice, daySSLickOnsetsJuiceRespCueNonRespCSAllMice, ...
    daySSLickOnsetsJuiceNonRespCueRespCSAllMice, daySSLickOnsetsJuiceNonRespCueNonRespCSAllMice, ...
    daySSCuesJuiceRespCueRespCSAllMice, daySSCuesJuiceRespCueNonRespCSAllMice, ...
    daySSCuesJuiceNonRespCueRespCSAllMice, daySSCuesJuiceNonRespCueNonRespCSAllMice, ...
    'All', sLabel);
end