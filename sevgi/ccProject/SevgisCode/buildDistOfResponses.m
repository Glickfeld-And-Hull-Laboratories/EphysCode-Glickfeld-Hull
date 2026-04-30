% clearvars -except Rlist CS SS SumSt
% close all
% globals;

% behavDataForRecordingDays = Rlist;

% structUnitsPerRecordingDays = SumSt;
% cellTypes = {SumSt.CellType};
% cellC4Labels = {SumSt.c4_label};
% indTemp = find(strcmp({SumSt.CellType}, 'CS') & [SumSt.c4_confidence]>2);

% unitCSs = CS;

function [csIndsPerDay, responseMagnitudesPerDay] = ...
    buildDistOfResponses(behavDataForRecordingDays, unitCSs, unitSSs, paramMouseId, paramDay, sLabel)
    globals;
        
    recordingDayTrialsSelected = [];
    csInds = [];
    csIndsPerDay = [];
    responseMagnitudes = [];
    responseMagnitudesPerDay = [];
    
    % arrNaiveRecordingDays = behavDataForRecordingDays([behavDataForRecordingDays.day] <= 3); % get only first three (Naive) days
        
    dayNext = 0;

    nUnitActivated = 0;
    nUnitSuppressed = 0;
    nUnitNonResponsive = 0;

    cellCSTimesResponsivePerDay = cell(1,length(paramDay));
    cellCSTimesNonResponsivePerDay = cell(1,length(paramDay));
    
    sAlignedTo = 'click';        

    if FROM_CS_TO_SS
        unitMasters = unitCSs;
        unitSlaves = unitSSs;
        indsRecordingDays = find([behavDataForRecordingDays.mouse]==paramMouseId & ismember([behavDataForRecordingDays.day],paramDay));
        inds = find(ismember([unitCSs.RecorNum], indsRecordingDays));    
    else
        unitMasters = unitSSs;
        unitSlaves = unitCSs;
        indsRecordingDays = find([behavDataForRecordingDays.mouse]==paramMouseId & ismember([behavDataForRecordingDays.day],paramDay));
        inds = find(ismember([unitSSs.RecorNum], indsRecordingDays));    
    end

    unitMaster = unitMasters(inds(1));
    recordingDayInd = unitMaster.RecorNum;
    behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);
    [arrBehavTimesSelected, recordingDayCellAllLicksSelected, lickOnsetsSelected] = findBehavioralTimes(paramMouseId, paramDay, behavDataForRecordingDay);

    for indLoop=1:length(inds)
        unitMaster = unitMasters(inds(indLoop));
        recordingDayInd = unitMaster.RecorNum;
        [unitSlave, ~] = findPair(unitSlaves, recordingDayInd, unitMaster, []);

        behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);                            
        mouseId = behavDataForRecordingDay.mouse;
        day = behavDataForRecordingDay.day;

        if ~isempty(unitSlave)
            if ~isempty(arrBehavTimesSelected) 
%             if ~isempty(recordingDayTrialsSelected)
                % Find responsive cells
                [baselineFR, modulationFR, responseMagnitude] = getResponse(unitMaster.timestamps, arrBehavTimesSelected); %,pathToCSPsthFolder, num2str(mouseId), sLabel, day, unitCS.unitID);
                responseMagnitudes = [responseMagnitudes responseMagnitude];
                csInds = [csInds inds(indLoop)];
            end
        end
%         end

        % If mouse or day changed, do collective plottings for all CSs gathered        
        if (indLoop+1)<=length(inds)
            unitCSNext = unitMasters(inds(indLoop+1));
            recordingDayIndNext = unitCSNext.RecorNum;
            behavDataForRecordingDayNext = behavDataForRecordingDays(recordingDayIndNext);
            dayNext = behavDataForRecordingDayNext.day;
        end

        if dayNext ~= day ||  (indLoop+1)==length(inds)  % % BUG !!
            if (indLoop+1)<=length(inds)
                [arrBehavTimesSelected, recordingDayCellAllLicksSelected, lickOnsetsSelected] = findBehavioralTimes(paramMouseId, paramDay, behavDataForRecordingDayNext);
            end
            if ~isempty(responseMagnitudes)
                sMouseId = ['mouse' num2str(mouseId)];                        
                logger.info('buildDistOfResponses', ['day ' num2str(day) ' mouse ' num2str(mouseId) ' mean response=' num2str(mean(responseMagnitudes))]);
                
                if ~all(responseMagnitudes==0)
%                         f = prePlot();
%                         sTitle = [NEURON_TYPE_CS '(n=' num2str(length(responseMagnitudes)) ') rate on day ' num2str(day) ' ' sMouseId];                        
%                         sFile = [pathToRespMagnDistToClickFolder sMouseId sLabel '_day' num2str(day) '_' NEURON_TYPE_CS '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_Resp_alignedTo' sAlignedTo];
%                         edges = [round(min(responseMagnitudes))-1:1:round(max(responseMagnitudes))+1];
%                         h = histogram(responseMagnitudes, edges);
%                         postPlot(f, 'z-score(spk/s)', 'Freq.', [], [], 0, max(h.Values)+1, sTitle, sFile);
%                             
                    responseMagnitudesPerDay = [responseMagnitudesPerDay responseMagnitudes];
                    csIndsPerDay = [csIndsPerDay csInds];
                end
            end
    
            dayNext = day;
            responseMagnitudes = [];
            csInds = [];
        end        
    end        
end