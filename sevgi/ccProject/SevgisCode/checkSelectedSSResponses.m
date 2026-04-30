% clearvars -except Rlist CS SS SumSt
% close all
% globals;

% behavDataForRecordingDays = Rlist;

% structUnitsPerRecordingDays = SumSt;
% cellTypes = {SumSt.CellType};
% cellC4Labels = {SumSt.c4_label};
% indTemp = find(strcmp({SumSt.CellType}, 'CS') & [SumSt.c4_confidence]>2);

% unitSSs = SS;

function [cellSSIDsPerDay, cellSSTimesPerDay, cellSSAllLicksPerDay, cellSSLickOnsetsPerDay, cellSSCuesPerDay, cellDepth] = ...
    checkSelectedSSResponses(behavDataForRecordingDays, unitSSs, selectSSIDsAllMice, paramMouseId, paramDay)
    globals;
        
    dayNext = 0;    
    
    indsRecordingDays = find([behavDataForRecordingDays.mouse]==paramMouseId & ismember([behavDataForRecordingDays.day],paramDay));
    indsSSs = find(ismember([unitSSs.RecorNum], indsRecordingDays));
    
    cellSSTimes = {};
    cellSSIDs = {};
    depths = [];
    cellSSAllLicks = {};
    cellSSLickOnsets = {};
    cellSSCues = {};
    
    cellSSIDsPerDay = cell(1, length(paramDay));
    cellSSTimesPerDay = cell(1,length(paramDay));
    cellDepth = cell(1, length(paramDay));
    cellSSAllLicksPerDay = cell(1,length(paramDay));
    cellSSLickOnsetsPerDay = cell(1,length(paramDay));
    cellSSCuesPerDay = cell(1, length(paramDay));

    if ~isempty(indsSSs)

        mouseIdDayUnitID = selectSSIDsAllMice{1};
        cellMouseIdDayUnitID = split(mouseIdDayUnitID,'_');
        mouseId = str2num(cellMouseIdDayUnitID{1});
        day = str2num(cellMouseIdDayUnitID{2});
        unitID = str2num(cellMouseIdDayUnitID{3});
        
        recordingDayInd = find([behavDataForRecordingDays.mouse]==mouseId & ismember([behavDataForRecordingDays.day],day));
        behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);
        [arrBehavTimesSelected, recordingDayCellAllLicksSelected, lickOnsetsSelected, cueTimesSelected] = ...
            findBehavioralTimes(paramMouseId, paramDay, behavDataForRecordingDay);
    
        for ind = 1:length(selectSSIDsAllMice)
            mouseIdDayUnitID = selectSSIDsAllMice{ind};
            cellMouseIdDayUnitID = split(mouseIdDayUnitID,'_');
            mouseId = str2num(cellMouseIdDayUnitID{1});
            day = str2num(cellMouseIdDayUnitID{2});
            unitID = str2num(cellMouseIdDayUnitID{3});

            dayInd = find(ismember(paramDay,day)); % find which day's data processed
            if ~isempty(dayInd)
                recordingDayInd = find([behavDataForRecordingDays.mouse]==mouseId & ismember([behavDataForRecordingDays.day],day));
                behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);
        
                unitSS = unitSSs([unitSSs.RecorNum] == recordingDayInd & [unitSSs.unitID] == unitID);
        
                if ~isempty(arrBehavTimesSelected)
                    ssTimesAlignedSelected = chunkAlignSpikeTimes(unitSS.timestamps, arrBehavTimesSelected);
                    recordingDayCellAllLicksSelectedAligned = chunkAlignBehavTimes(recordingDayCellAllLicksSelected, arrBehavTimesSelected);
                    lickOnsetsSelectedAligned = chunkAlignBehavTimes(lickOnsetsSelected, arrBehavTimesSelected);
                    cueTimesSelectedAligned = chunkAlignBehavTimes(cueTimesSelected, arrBehavTimesSelected);
                    
                    cellSSIDs{length(cellSSIDs)+1} = [num2str(mouseId) '_' num2str(day) '_' num2str(unitSS.unitID)];
                    cellSSTimes{length(cellSSTimes)+1} = ssTimesAlignedSelected;
                    depthSS = behavDataForRecordingDay.depth - unitSS.channel*10 - 195; % depth of recording(Ztip) - channel depth - tipLength
                    depths = [depths depthSS];
                    cellSSAllLicks{length(cellSSAllLicks)+1} = recordingDayCellAllLicksSelectedAligned;
                    cellSSLickOnsets{length(cellSSLickOnsets)+1} = lickOnsetsSelectedAligned;
                    cellSSCues{length(cellSSCues)+1} = cueTimesSelectedAligned;
                end
        
                % If mouse or day changed, do collective plottings for all CSs gathered        
                if (ind+1)<=length(selectSSIDsAllMice)
                    mouseIdDayUnitIDNext = selectSSIDsAllMice{ind+1};
                    cellMouseIdDayUnitIDNext = split(mouseIdDayUnitIDNext,'_');
                    mouseIdNext = str2num(cellMouseIdDayUnitIDNext{1});
                    dayNext = str2num(cellMouseIdDayUnitIDNext{2});
                    recordingDayIndNext = find([behavDataForRecordingDays.mouse]==mouseIdNext & ismember([behavDataForRecordingDays.day],dayNext));
                    behavDataForRecordingDayNext = behavDataForRecordingDays(recordingDayIndNext);
                end
            
                % If day changed, do collective plottings for all CSs and SSs gathered
                if dayNext ~= day ||  (ind+1)==length(selectSSIDsAllMice)  
                    % Get the next day's behavioral data
                    if (ind+1)<=length(selectSSIDsAllMice)
                        [arrBehavTimesSelected, recordingDayCellAllLicksSelected, lickOnsetsSelected, cueTimesSelected] = ...
                            findBehavioralTimes(mouseIdNext, dayNext, behavDataForRecordingDayNext);
                    end
        
                    logger.info('checkSelectedSSResponses', ['# of units=' num2str(length(cellSSTimes),'%.0f') ' day ' num2str(day) ' mouse ' num2str(mouseId)]);
                    dayInd = find(ismember(paramDay,day)); % find which day's data processed
                    cellSSIDsPerDay{dayInd} = cellSSIDs;
                    cellSSTimesPerDay{dayInd} = cellSSTimes;
                    cellDepth{dayInd} = depths;
                    cellSSAllLicksPerDay{dayInd} = cellSSAllLicks;
                    cellSSLickOnsetsPerDay{dayInd} = cellSSLickOnsets;
                    cellSSCuesPerDay{dayInd} = cellSSCues;
                   
                    cellSSIDs = {};
                    cellSSTimes = {};
                    depths = [];
                    cellSSAllLicks = {};
                    cellSSLickOnsets = {};
                    cellSSCues = {};
                end
            end
        end
    end
end