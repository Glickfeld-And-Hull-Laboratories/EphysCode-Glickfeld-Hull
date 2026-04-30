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
    checkSSResponses(behavDataForRecordingDays, unitSSs, paramMouseId, paramDay)
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
    
        unitSS = unitSSs(indsSSs(1));
        recordingDayInd = unitSS.RecorNum;
        behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);
        [arrBehavTimesSelected, recordingDayCellAllLicksSelected, lickOnsetsSelected, cueTimesSelected] = ...
            findBehavioralTimes(paramMouseId, paramDay, behavDataForRecordingDay);
    
        for indLoop=1:length(indsSSs)
            unitSS = unitSSs(indsSSs(indLoop));
            recordingDayInd = unitSS.RecorNum;
            behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);
    
            mouseId = behavDataForRecordingDay.mouse;
            day = behavDataForRecordingDay.day;               
    
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
            if (indLoop+1)<=length(indsSSs)
                unitSSNext = unitSSs(indsSSs(indLoop+1));
                recordingDayIndNext = unitSSNext.RecorNum;
                behavDataForRecordingDayNext = behavDataForRecordingDays(recordingDayIndNext);
                dayNext = behavDataForRecordingDayNext.day;            
            end
        
            % If day changed, do collective plottings for all CSs and SSs gathered
            if dayNext ~= day ||  (indLoop+1)==length(indsSSs)  
                % Get the next day's behavioral data
                if (indLoop+1)<=length(indsSSs)
                    [arrBehavTimesSelected, recordingDayCellAllLicksSelected, lickOnsetsSelected, cueTimesSelected] = ...
                        findBehavioralTimes(paramMouseId, paramDay, behavDataForRecordingDayNext);
                end
    
                logger.info('checkSSResponses', ['# of units=' num2str(length(cellSSTimes),'%.0f') ' day ' num2str(day) ' mouse ' num2str(mouseId)]);
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