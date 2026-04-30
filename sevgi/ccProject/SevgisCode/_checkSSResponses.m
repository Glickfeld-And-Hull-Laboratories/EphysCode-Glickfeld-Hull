% clearvars -except Rlist CS SS SumSt
% close all
% globals;

% behavDataForRecordingDays = Rlist;

% structUnitsPerRecordingDays = SumSt;
% cellTypes = {SumSt.CellType};
% cellC4Labels = {SumSt.c4_label};
% indTemp = find(strcmp({SumSt.CellType}, 'CS') & [SumSt.c4_confidence]>2);

% unitSSs = SS;

function cellSSTimesPerDay = checkSSResponses(behavDataForRecordingDays, unitSSs, paramMouseId, paramDay, modeTraining, modeAlignment)
    globals;
        
    recordingDayTrialsSelected = [];
    
    indsRecordingDays = find([behavDataForRecordingDays.mouse]==paramMouseId & ismember([behavDataForRecordingDays.day],paramDay));
    if FROM_CS_TO_SS
        pcPairs={unitSSs.PCpair};
        flagUnpaired = cellfun(@(x) (isempty(x) || isnan(x)), pcPairs, UniformOutput=true);
        indsSSs = find(ismember([unitSSs.RecorNum], indsRecordingDays) & flagUnpaired);
    else % If it is coming from the other direction (SS->CS), we just wanna plot SSs, don't check their paired field
        indsSSs = find(ismember([unitSSs.RecorNum], indsRecordingDays));
    end
        
    currentMouseId = 0;
    currentDay = 0;
    cellSSTimes = {};

    nUnitActivated = 0;
    nUnitSuppressed = 0;
    nUnitNonResponsive = 0;

    cellSSTimesPerDay = cell(1,length(paramDay));

    if modeAlignment == MODE_ALIGNMENT_TO_CLICK
        sAlignedTo = 'click';
        pathToSSPsthFolder = pathToSSToClickPsthFolder;
    elseif modeAlignment == MODE_ALIGNMENT_TO_LICK
        sAlignedTo = 'lick';
        pathToSSPsthFolder = pathToSSToLickPsthFolder;
    end

    for indLoop=1:length(indsSSs)
        unitSS = unitSSs(indsSSs(indLoop));
        recordingDayInd = unitSS.RecorNum;
        behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);
        recordingDayTrials = behavDataForRecordingDay.TrialStruct;
        recordingDayLickOnsets = behavDataForRecordingDay.LickOnsets;

        mouseId = behavDataForRecordingDay.mouse;
        day = behavDataForRecordingDay.day;
                
        % If mouse or day changed, do collective plottings for all CSs and SSs gathered
        if currentMouseId ~= mouseId || currentDay ~= day
            if currentMouseId~=0 && ~isempty(cellSSTimes)
                sMouseId = '';
                if ~isempty(currentMouseId) && currentMouseId~=0
                    sMouseId = ['mouse' num2str(currentMouseId)];
                end
                
                % Plot SSs PSTHs
                if ~isempty(cellSSTimes)                    
                    sTitle = ['Unpaired ' NEURON_TYPE_SS ' (n=' num2str(length(cellSSTimes)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId];
                    sFile = [pathToSSPsthFolder sMouseId '_day' num2str(currentDay) '_' num2str(TRIALS_TO_COMPARE) '_' NEURON_TYPE_SS '_Unpaired_' sAlignedTo '.tif'];
%                     plotComparisonPSTHs(cellSSTimes, NEURON_TYPE_SS, sTitle, sFile, ~FIRST_VS_LAST, [], 1, COLORS(8,:));                   
                end
                
                dayInd = find(ismember(paramDay,currentDay)); % find which day's data processed
                cellSSTimesPerDay{dayInd} = cellSSTimes;
            end

            cellSSTimes = {};
            currentMouseId=mouseId;
            currentDay = day;
        end

        % Patch to correct NaN values in TrialType
        lickOnsetTrialTypes = {recordingDayLickOnsets.TrialType};
        nanIdsCell = cellfun(@ (x) any(isnan(x)),lickOnsetTrialTypes, UniformOutput=true);
        %[lickOnsetTrialTypes{nanIdsCell}] = deal('');
        lickOnsetTrialTypes = lickOnsetTrialTypes(~nanIdsCell); % Ignore NaN lick onset entries
        recordingDayLickOnsets = recordingDayLickOnsets(~nanIdsCell); % Ignore NaN lick onset entries

        if modeTraining==1 % NAIVE DAYS ANALYZED
            indsSelectedTrials = ismember({recordingDayTrials.TrialType},TRIALS_TO_INCLUDE_NAIVE_DAY_ANALYSES);
            indsSelectedLickOnsets = ismember(lickOnsetTrialTypes,TRIALS_TO_INCLUDE_NAIVE_DAY_ANALYSES);
        elseif modeTraining==2 % HABITUATION DAYS ANALYZED
            indsSelectedTrials = ismember({recordingDayTrials.TrialType},TRIALS_TO_INCLUDE_HABITUATION_DAY_ANALYSES);            
            indsSelectedLickOnsets = ismember(lickOnsetTrialTypes,TRIALS_TO_INCLUDE_HABITUATION_DAY_ANALYSES);
        elseif modeTraining==3 % EXPERT DAYS ANALYZED
            indsSelectedTrials = ismember({recordingDayTrials.TrialType},TRIALS_TO_INCLUDE_EXPERT_DAY_ANALYSES);
            indsSelectedLickOnsets = ismember(lickOnsetTrialTypes,TRIALS_TO_INCLUDE_EXPERT_DAY_ANALYSES);
        end
        recordingDayTrialsSelected = recordingDayTrials(indsSelectedTrials);
        recordingDayLickOnsetsSelected = recordingDayLickOnsets(indsSelectedLickOnsets);

        if ~isempty(recordingDayTrialsSelected)
            arrJuiceTimes = [recordingDayTrials.JuiceTime];
            arrToneTimes = [recordingDayTrials.ToneTime];
                        
            if modeAlignment == MODE_ALIGNMENT_TO_CLICK
                arrJuiceTimesSelected = [recordingDayTrialsSelected.JuiceTime];
                ssTimesAlignedToClickSelected = chunkAlignSpikeTimes(unitSS.timestamps, arrJuiceTimesSelected);
                cellSSTimes{length(cellSSTimes)+1} = ssTimesAlignedToClickSelected;

                toneTimesAlignedToClick = chunkAlignSpikeTimes(arrToneTimes, arrJuiceTimes);
                ssTimesAlignedToClick = chunkAlignSpikeTimes(unitSS.timestamps, arrJuiceTimes);
                colorCodes = getColorCodesForTrialTypes({recordingDayTrials.TrialType}, 1);
                sTitle = ['Unpaired SS aligned to juice on day ' num2str(behavDataForRecordingDay.day) ' mouse=' num2str(behavDataForRecordingDay.mouse)];
                sFile = [pathToSSRasterToClickFolder 'mouse' num2str(behavDataForRecordingDay.mouse) '_day_' num2str(behavDataForRecordingDay.day) '_' unitSS.c4_label '_' num2str(unitSS.unitID) '_Unpaired.tif'];
%                 plotRaster(unitSS.unitID, unitSS.c4_label, unitSS.layer, unitSS.channel, ssTimesAlignedToClick, toneTimesAlignedToClick, sTitle, sFile, colorCodes);
            elseif modeAlignment == MODE_ALIGNMENT_TO_LICK                
                arrLickOnsetTimesSelected = [recordingDayLickOnsetsSelected.time];
                ssTimesAlignedToLickSelected = chunkAlignSpikeTimes(unitSS.timestamps, arrLickOnsetTimesSelected);
                cellSSTimes{length(cellSSTimes)+1} = ssTimesAlignedToLickSelected;

                arrLickOnsetTimes = [recordingDayLickOnsets.time];
                toneTimesAlignedToLick = chunkAlignSpikeTimes(arrToneTimes, arrLickOnsetTimes);
                ssTimesAlignedToLick = chunkAlignSpikeTimes(unitSS.timestamps, arrLickOnsetTimes);
                colorCodes = getColorCodesForTrialTypes({recordingDayLickOnsets.TrialType}, 1);
                sTitle = ['Unpaired SS aligned to lick on day ' num2str(behavDataForRecordingDay.day) ' mouse=' num2str(behavDataForRecordingDay.mouse)];
                sFile = [pathToSSRasterToLickFolder 'mouse' num2str(behavDataForRecordingDay.mouse) '_day_' num2str(behavDataForRecordingDay.day) '_' unitSS.c4_label '_' num2str(unitSS.unitID) '_Unpaired.tif'];
%                 plotRaster(unitSS.unitID, unitSS.c4_label, unitSS.layer, unitSS.channel, ssTimesAlignedToLick, [], sTitle, sFile, colorCodes); % toneTimesAlignedToLick
            end
            logger.info('checkSSResponses', ['SS unitId=' num2str(unitSS.unitID) ' day ' num2str(behavDataForRecordingDay.day) ' mouse ' num2str(behavDataForRecordingDay.mouse)]);                          
        end
    end

    % To plot the last batch of SSs PSTHs        
    if ~isempty(cellSSTimes)
        sMouseId = '';
        if ~isempty(currentMouseId) && currentMouseId~=0
            sMouseId = ['mouse' num2str(currentMouseId)];
        end

        sTitle = ['Unpaired ' NEURON_TYPE_SS ' (n=' num2str(length(cellSSTimes)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId];
        sFile = [pathToSSPsthFolder sMouseId '_day' num2str(currentDay) '_firstVSlast' num2str(TRIALS_TO_COMPARE) '_' NEURON_TYPE_SS '_Unpaired.tif'];
%         plotComparisonPSTHs(cellSSTimes, NEURON_TYPE_SS, sTitle, sFile, ~FIRST_VS_LAST, [], 1, COLORS(8,:));

        dayInd = find(ismember(paramDay,currentDay)); % find which day's data processed
        cellSSTimesPerDay{dayInd} = cellSSTimes;
    end   
    
end