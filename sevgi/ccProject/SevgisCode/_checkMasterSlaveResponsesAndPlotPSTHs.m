function checkMasterSlaveResponsesAndPlotPSTHs(miceVSDays, miceVSSelectedDay1, miceVSSelectedDayN, behavDataForRecordingDays, unitMasters, unitSlaves, sLabel, modeAlignment)

    globals;
    cellMasterResponsivePerMouse = cell(1, length(miceVSDays));
    cellMasterNonResponsivePerMouse = cell(1, length(miceVSDays));       

    %%%%%%%%%%%%% FIRST, GET ALL DAYS %%%%%%%%%%%%%%%
    for ind=1:length(miceVSDays) % Loop through each mouse
        mouseId = miceVSDays{ind,1};
        days = miceVSDays{ind,2};
        [cellMasterTimesResponsive, cellMasterTimesNonResponsive, ...
            cellSlaveTimesJuiceRespCueRespMaster, cellSlaveTimesJuiceRespCueNonRespMaster, ...
            cellSlaveTimesJuiceNonRespCueRespMaster, cellSlaveTimesJuiceNonRespCueNonRespMaster, ...
            cellSlaveAllLicksJuiceRespCueResponsiveMaster, cellSlaveAllLicksJuiceRespCueNonResponsiveMaster, ...
            cellSlaveAllLicksJuiceNonRespCueResponsiveMaster, cellSlaveAllLicksJuiceNonRespCueNonResponsiveMaster] = ...
            checkMasterSlaveResponses(behavDataForRecordingDays, unitMasters, unitSlaves, mouseId, days, modeAlignment); % Loop through each day

        cellMasterResponsivePerMouse{ind} = cellMasterTimesResponsive;
        cellMasterNonResponsivePerMouse{ind} = cellMasterTimesNonResponsive;

        cellSlaveJuiceRespCueRespMasterPerMouse{ind} = cellSlaveTimesJuiceRespCueRespMaster;
        cellSlaveJuiceRespCueNonRespMasterPerMouse{ind} = cellSlaveTimesJuiceRespCueNonRespMaster;
        cellSlaveJuiceNonRespCueRespMasterPerMouse{ind} = cellSlaveTimesJuiceNonRespCueRespMaster;
        cellSlaveJuiceNonRespCueNonRespMasterPerMouse{ind} = cellSlaveTimesJuiceNonRespCueNonRespMaster;

        cellSlaveAllLicksJuiceRespCueResponsiveMasterPerMouse{ind} = cellSlaveAllLicksJuiceRespCueResponsiveMaster;
        cellSlaveAllLicksJuiceRespCueNonResponsiveMasterPerMouse{ind} = cellSlaveAllLicksJuiceRespCueNonResponsiveMaster;
        cellSlaveAllLicksJuiceNonRespCueResponsiveMasterPerMouse{ind} = cellSlaveAllLicksJuiceNonRespCueResponsiveMaster;
        cellSlaveAllLicksJuiceNonRespCueNonResponsiveMasterPerMouse{ind} = cellSlaveAllLicksJuiceNonRespCueNonResponsiveMaster;
    end

    %%%%%%%%%%%%%%% DAY 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(miceVSSelectedDay1)       
        day1MasterResponsiveAllMice = expandCellArray(cellMasterResponsivePerMouse, miceVSSelectedDay1);
        day1MasterNonResponsiveAllMice = expandCellArray(cellMasterNonResponsivePerMouse, miceVSSelectedDay1);
        day1SlaveJuiceRespCueRespMasterAllMice = expandCellArray(cellSlaveJuiceRespCueRespMasterPerMouse, miceVSSelectedDay1);
        day1SlaveJuiceRespCueNonRespMasterAllMice = expandCellArray(cellSlaveJuiceRespCueNonRespMasterPerMouse, miceVSSelectedDay1);
        day1SlaveJuiceNonRespCueRespMasterAllMice = expandCellArray(cellSlaveJuiceNonRespCueRespMasterPerMouse, miceVSSelectedDay1);
        day1SlaveJuiceNonRespCueNonRespMasterAllMice = expandCellArray(cellSlaveJuiceNonRespCueNonRespMasterPerMouse, miceVSSelectedDay1);
        day1SlaveLicksJuiceRespCueRespMasterAllMice = expandCellArray(cellSlaveAllLicksJuiceRespCueResponsiveMasterPerMouse, miceVSSelectedDay1);
        day1SlaveLicksJuiceRespCueNonRespMasterAllMice = expandCellArray(cellSlaveAllLicksJuiceRespCueNonResponsiveMasterPerMouse, miceVSSelectedDay1);
        day1SlaveLicksJuiceNonRespCueRespMasterAllMice = expandCellArray(cellSlaveAllLicksJuiceNonRespCueResponsiveMasterPerMouse, miceVSSelectedDay1);
        day1SlaveLicksJuiceNonRespCueNonRespMasterAllMice = expandCellArray(cellSlaveAllLicksJuiceNonRespCueNonResponsiveMasterPerMouse, miceVSSelectedDay1);

        callPlot(day1MasterResponsiveAllMice, day1MasterNonResponsiveAllMice, ...
        day1SlaveJuiceRespCueRespMasterAllMice, day1SlaveJuiceRespCueNonRespMasterAllMice, ...
        day1SlaveJuiceNonRespCueRespMasterAllMice, day1SlaveJuiceNonRespCueNonRespMasterAllMice, ...
        day1SlaveLicksJuiceRespCueRespMasterAllMice, day1SlaveLicksJuiceRespCueNonRespMasterAllMice, ...
        day1SlaveLicksJuiceNonRespCueRespMasterAllMice, day1SlaveLicksJuiceNonRespCueNonRespMasterAllMice, ...
        '1', modeAlignment, sLabel);
    end

    %%%%%%%%%%%%%%% DAY N %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(miceVSSelectedDayN) 
        dayNMasterResponsiveAllMice = expandCellArray(cellMasterResponsivePerMouse, miceVSSelectedDayN);
        dayNMasterNonResponsiveAllMice = expandCellArray(cellMasterNonResponsivePerMouse, miceVSSelectedDayN);
        dayNSlaveJuiceRespCueRespMasterAllMice = expandCellArray(cellSlaveJuiceRespCueRespMasterPerMouse, miceVSSelectedDayN);
        dayNSlaveJuiceRespCueNonRespMasterAllMice = expandCellArray(cellSlaveJuiceRespCueNonRespMasterPerMouse, miceVSSelectedDayN);
        dayNSlaveJuiceNonRespCueRespMasterAllMice = expandCellArray(cellSlaveJuiceNonRespCueRespMasterPerMouse, miceVSSelectedDayN);
        dayNSlaveJuiceNonRespCueNonRespMasterAllMice = expandCellArray(cellSlaveJuiceNonRespCueNonRespMasterPerMouse, miceVSSelectedDayN);
        dayNSlaveLicksJuiceRespCueRespMasterAllMice = expandCellArray(cellSlaveAllLicksJuiceRespCueResponsiveMasterPerMouse, miceVSSelectedDayN);
        dayNSlaveLicksJuiceRespCueNonRespMasterAllMice = expandCellArray(cellSlaveAllLicksJuiceRespCueNonResponsiveMasterPerMouse, miceVSSelectedDayN);
        dayNSlaveLicksJuiceNonRespCueRespMasterAllMice = expandCellArray(cellSlaveAllLicksJuiceNonRespCueResponsiveMasterPerMouse, miceVSSelectedDayN);
        dayNSlaveLicksJuiceNonRespCueNonRespMasterAllMice = expandCellArray(cellSlaveAllLicksJuiceNonRespCueNonResponsiveMasterPerMouse, miceVSSelectedDayN);

        callPlot(dayNMasterResponsiveAllMice, dayNMasterNonResponsiveAllMice, ...
        dayNSlaveJuiceRespCueRespMasterAllMice, dayNSlaveJuiceRespCueNonRespMasterAllMice, ...
        dayNSlaveJuiceNonRespCueRespMasterAllMice, dayNSlaveJuiceNonRespCueNonRespMasterAllMice, ...
        dayNSlaveLicksJuiceRespCueRespMasterAllMice, dayNSlaveLicksJuiceRespCueNonRespMasterAllMice, ...
        dayNSlaveLicksJuiceNonRespCueRespMasterAllMice, dayNSlaveLicksJuiceNonRespCueNonRespMasterAllMice, ...
        'N', modeAlignment, sLabel);
    end

    %%%%%%%%%%%%%% DAY ALL %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dayAllMasterResponsiveAllMice = expandCellArray(cellMasterResponsivePerMouse);
    dayAllMasterNonResponsiveAllMice = expandCellArray(cellMasterNonResponsivePerMouse);
    dayAllSlaveJuiceRespCueRespMasterAllMice = expandCellArray(cellSlaveJuiceRespCueRespMasterPerMouse);
    dayAllSlaveJuiceRespCueNonRespMasterAllMice = expandCellArray(cellSlaveJuiceRespCueNonRespMasterPerMouse);
    dayAllSlaveJuiceNonRespCueRespMasterAllMice = expandCellArray(cellSlaveJuiceNonRespCueRespMasterPerMouse);
    dayAllSlaveJuiceNonRespCueNonRespMasterAllMice = expandCellArray(cellSlaveJuiceNonRespCueNonRespMasterPerMouse);
    daySlaveAllLicksJuiceRespCueRespMasterAllMice = expandCellArray(cellSlaveAllLicksJuiceRespCueResponsiveMasterPerMouse);
    daySlaveAllLicksJuiceRespCueNonRespMasterAllMice = expandCellArray(cellSlaveAllLicksJuiceRespCueNonResponsiveMasterPerMouse);
    daySlaveAllLicksJuiceNonRespCueRespMasterAllMice = expandCellArray(cellSlaveAllLicksJuiceNonRespCueResponsiveMasterPerMouse);
    daySlaveAllLicksJuiceNonRespCueNonRespMasterAllMice = expandCellArray(cellSlaveAllLicksJuiceNonRespCueNonResponsiveMasterPerMouse);

    if FROM_CS_TO_SS
        callPlot(dayAllMasterResponsiveAllMice, dayAllMasterNonResponsiveAllMice, ...
        dayAllSlaveJuiceRespCueRespMasterAllMice, dayAllSlaveJuiceRespCueNonRespMasterAllMice, ...
        dayAllSlaveJuiceNonRespCueRespMasterAllMice, dayAllSlaveJuiceNonRespCueNonRespMasterAllMice, ...
        daySlaveAllLicksJuiceRespCueRespMasterAllMice, daySlaveAllLicksJuiceRespCueNonRespMasterAllMice, ...
        daySlaveAllLicksJuiceNonRespCueRespMasterAllMice, daySlaveAllLicksJuiceNonRespCueNonRespMasterAllMice, ...
        'All', modeAlignment, sLabel);
    else

    end
end