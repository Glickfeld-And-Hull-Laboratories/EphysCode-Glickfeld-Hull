% clearvars -except Rlist CS SS SumSt
% close all
% globals;

% behavDataForRecordingDays = Rlist;

% structUnitsPerRecordingDays = SumSt;
% cellTypes = {SumSt.CellType};
% cellC4Labels = {SumSt.c4_label};
% indTemp = find(strcmp({SumSt.CellType}, 'CS') & [SumSt.c4_confidence]>2);

% unitCSs = CS;

function [cellCSTimesResponsivePerDay, cellCSTimesNonResponsivePerDay] = ...
    checkCSResponses(behavDataForRecordingDays, unitCSs, unitSSs, paramMouseId, paramDay, modeAlignment, sLabel)
    globals;
        
    recordingDayTrialsSelected = [];
    
    % arrNaiveRecordingDays = behavDataForRecordingDays([behavDataForRecordingDays.day] <= 3); % get only first three (Naive) days
    indsRecordingDays = find([behavDataForRecordingDays.mouse]==paramMouseId & ismember([behavDataForRecordingDays.day],paramDay));
    indsCSs = find(ismember([unitCSs.RecorNum], indsRecordingDays));
    
    currentMouseId = 0;
    currentDay = 0;

    nUnitActivated = 0;
    nUnitSuppressed = 0;
    nUnitNonResponsive = 0;

    cellCSTimesResponsivePerDay = cell(1,length(paramDay));
    cellCSTimesNonResponsivePerDay = cell(1,length(paramDay));
    
    if modeAlignment == MODE_ALIGNMENT_TO_CLICK
        sAlignedTo = 'click';
        pathToCSPsthFolder = pathToCSToClickPsthFolder;
    elseif modeAlignment == MODE_ALIGNMENT_TO_LICK
        sAlignedTo = 'lick';
        pathToCSPsthFolder = pathToCSToLickPsthFolder;
    elseif modeAlignment == MODE_ALIGNMENT_TO_TONE
        sAlignedTo = 'tone';
        pathToCSPsthFolder = pathToCSToTonePsthFolder;
    end

    for indLoop=1:length(indsCSs)
        unitCS = unitCSs(indsCSs(indLoop));
        recordingDayInd = unitCS.RecorNum;
%         if FLAG_PLOT_ONLY_PAIRED_WCS
            [unitSS, ~] = findPair(unitSSs, recordingDayInd, unitCS, [], []);
%         end

%         if ~FLAG_PLOT_ONLY_PAIRED_WCS || ~isempty(unitSS)
            behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);
    %         if behavDataForRecordingDay.TrainBoo==1
            recordingDayTrials = behavDataForRecordingDay.TrialStruct;
            recordingDayLickOnsets = behavDataForRecordingDay.LickOnsets;
    
            mouseId = behavDataForRecordingDay.mouse;
            day = behavDataForRecordingDay.day;
                    
            % If mouse or day changed, do collective plottings for all CSs gathered
            if currentMouseId ~= mouseId || currentDay ~= day
                if currentMouseId~=0 && ~isempty(cellCSTimesResponsive)
                    sMouseId = '';
                    if ~isempty(currentMouseId) && currentMouseId~=0
                        sMouseId = ['mouse' num2str(currentMouseId)];
                    end
    
                    nTotalUnits = nUnitActivated+nUnitSuppressed+nUnitNonResponsive;
                    percentageActivated = 100*nUnitActivated/nTotalUnits;
                    logger.info('checkCSResponsesToClick', ['Activated units=' num2str(percentageActivated,'%.2f') ' % '...
                        'Suppressed units = ' num2str(100*nUnitSuppressed/nTotalUnits,'%.2f') ' % Non-responsive units = ' num2str(100*nUnitNonResponsive/nTotalUnits,'%.2f') ' % ' ...
                        'day ' num2str(currentDay) ' mouse ' num2str(currentMouseId)]);
                    
                    % Plot RESPONSIVE CSs PSTHs
                    if ~isempty(cellCSTimesResponsive)
                        sPercentageActivated = '';
                        if ~isempty(percentageActivated)
                            sPercentageActivated = num2str(percentageActivated,'%.2f');
                        end
                        
                        sTitle = ['(Resp)' NEURON_TYPE_CS '(n=' num2str(length(cellCSTimesResponsive)) ') rate on day ' num2str(currentDay) ' ' sMouseId ' (' sPercentageActivated ' %) '];                        
                        sFirstLast = '';
                        if FIRST_VS_LAST
                            sTitle = [sTitle ' responsive for the first ' num2str(TRIALS_FIRST) ' vs last ' num2str(TRIALS_TO_COMPARE) ' trials)'];
                            sFirstLast = ['_firstVSlast' num2str(TRIALS_TO_COMPARE)];
                        end
                        sFile = [pathToCSPsthFolder sMouseId sLabel '_day' num2str(currentDay) '_' NEURON_TYPE_CS '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_Resp_alignedTo' sAlignedTo sFirstLast '.tif'];
%                         plotComparisonPSTHs(cellCSTimesResponsive, NEURON_TYPE_CS, sTitle, sFile, ['Time from ' sAlignedTo ' (s)'], [], 0, COLORS(11, :));
                    end
    
                    % Plot NON-RESPONSIVE CSs PSTHs
                    if ~isempty(cellCSTimesNonResponsive)
                        sTitle = ['(NonResp)' NEURON_TYPE_CS ' (n=' num2str(length(cellCSTimesNonResponsive)) ') rate on day ' num2str(currentDay) ' ' sMouseId];
                        sFirstLast = '';
                        if FIRST_VS_LAST
                            sTitle = [sTitle ' responsive for the first ' num2str(TRIALS_FIRST) ' vs last ' num2str(TRIALS_TO_COMPARE) ' trials)'];
                            sFirstLast = ['_firstVSlast' num2str(TRIALS_TO_COMPARE)];
                        end
                        sFile = [pathToCSPsthFolder sMouseId sLabel '_day' num2str(currentDay) '_' NEURON_TYPE_CS '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_NonResp_alignedTo' sAlignedTo sFirstLast '.tif'];                    
%                         plotComparisonPSTHs(cellCSTimesNonResponsive, NEURON_TYPE_CS, sTitle, sFile, ['Time from ' sAlignedTo ' (s)'], [], 0, COLORS(11, :));
                    end
                    
                    dayInd = find(ismember(paramDay,currentDay)); % find which day's data processed                    
                    cellCSTimesResponsivePerDay{dayInd} = cellCSTimesResponsive;
                    cellCSTimesNonResponsivePerDay{dayInd} = cellCSTimesNonResponsive;
                end
    
                cellCSTimesResponsive = {};   
                cellCSTimesNonResponsive = {};
    
                currentMouseId=mouseId;
                currentDay = day;
    
                nUnitActivated = 0;
                nUnitSuppressed = 0;
                nUnitNonResponsive = 0;
            end
    
            % Patch to correct NaN values in TrialType
            trialTypes = {recordingDayTrials.TrialType};
            outcomeTypes = {recordingDayTrials.Outcome};
            nanIdsCell = cellfun(@ (x) any(isnan(x)),trialTypes, UniformOutput=true);
            nanIdsOutcomeCell = cellfun(@ (x) any(isnan(x)),outcomeTypes, UniformOutput=true);
            recordingDayTrials = recordingDayTrials(~nanIdsCell & ~nanIdsOutcomeCell); % Ignore NaN lick onset entries

            lickOnsetTrialTypes = {recordingDayLickOnsets.TrialType};
            lickOnsetOutcomeTypes = {recordingDayLickOnsets.Outcome};
            nanIdsCell = cellfun(@ (x) any(isnan(x)),lickOnsetTrialTypes, UniformOutput=true);
            nanIdsOutcomeCell = cellfun(@ (x) any(isnan(x)),lickOnsetOutcomeTypes, UniformOutput=true);
            %[lickOnsetTrialTypes{nanIdsCell}] = deal('');
%             lickOnsetTrialTypes = lickOnsetTrialTypes(~nanIdsCell & ~nanIdsOutcomeCell); % Ignore NaN lick onset entries
%             lickOnsetOutcomeTypes = lickOnsetOutcomeTypes(~nanIdsCell & ~nanIdsOutcomeCell); % Ignore NaN lick onset entries
            recordingDayLickOnsets = recordingDayLickOnsets(~nanIdsCell & ~nanIdsOutcomeCell); % Ignore NaN lick onset entries
               
            arrBehavTimesSelected = findBehavioralTimes(paramMouseId, paramDay, modeAlignment, recordingDayTrials, recordingDayLickOnsets); %, lickOnsetTrialTypes, lickOnsetOutcomeTypes);
            if ~isempty(arrBehavTimesSelected)
                                    
                csTimesAlignedSelected = chunkAlignSpikeTimes(unitCS.timestamps, arrBehavTimesSelected);
                
                % Find the reward responsive CS
                flagResponsive = isResponsive(unitCS.timestamps, recordingDayTrials,pathToCSPsthFolder, num2str(mouseId), sLabel, day, unitCS.unitID);
                
                if flagResponsive == -1
                    if FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS == FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO
                        nUnitSuppressed = nUnitSuppressed + 1;
                        logger.info('checkCSResponsesToClick', ['RARE but Suppressed unit=' num2str(unitCS.unitID) ' day ' num2str(behavDataForRecordingDay.day) ' mouse ' num2str(behavDataForRecordingDay.mouse)]);
                    elseif FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS == FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_DUAL
                        % for dual comparison, this means TRIAL_TYPE_2 had higher activity so put them into Non-responsive category cos there will be no
                        % non-responsives while comparing two trial type responses
                        nUnitNonResponsive = nUnitNonResponsive + 1;
                        logger.info('checkCSResponsesToClick', ['Less responsive unit=' num2str(unitCS.unitID) ' day ' num2str(behavDataForRecordingDay.day) ' mouse ' num2str(behavDataForRecordingDay.mouse)]);
                        cellCSTimesNonResponsive{length(cellCSTimesNonResponsive)+1} = csTimesAlignedSelected;                    
                    end
                elseif  flagResponsive == 1
                    nUnitActivated = nUnitActivated + 1;
                    logger.info('checkCSResponsesToClick', ['Responsive unit=' num2str(unitCS.unitID) ' day ' num2str(behavDataForRecordingDay.day) ' mouse ' num2str(behavDataForRecordingDay.mouse)]);
                    cellCSTimesResponsive{length(cellCSTimesResponsive)+1} = csTimesAlignedSelected;
                elseif flagResponsive == 0 && FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS == FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO                   
                    nUnitNonResponsive = nUnitNonResponsive + 1;
                    logger.info('checkCSResponsesToClick', ['Non responsive unit=' num2str(unitCS.unitID) ' day ' num2str(behavDataForRecordingDay.day) ' mouse ' num2str(behavDataForRecordingDay.mouse)]);
                    cellCSTimesNonResponsive{length(cellCSTimesNonResponsive)+1} = csTimesAlignedSelected;
                end
            end
%         end
%         end
    end
    
    % To plot the last batch
    if exist('cellCSTimesResponsive','var') && ~isempty(cellCSTimesResponsive)
        nTotalUnits = nUnitActivated+nUnitSuppressed+nUnitNonResponsive;
        percentageActivated = 100*nUnitActivated/nTotalUnits;
        logger.info('checkCSResponsesToClick', ['Activated units=' num2str(percentageActivated,'%.2f') ' % '...
            'Suppressed units = ' num2str(100*nUnitSuppressed/nTotalUnits,'%.2f') ' % Non-responsive units = ' num2str(100*nUnitNonResponsive/nTotalUnits,'%.2f') ' % ' ...
            'day ' num2str(currentDay) ' mouse ' num2str(currentMouseId)]);                
        
        % Plot RESPONSIVE CSs PSTHs
        if ~isempty(cellCSTimesResponsive)
            sMouseId = '';
            if ~isempty(currentMouseId) && currentMouseId~=0
                sMouseId = ['mouse' num2str(currentMouseId)];
            end

            sPercentageActivated = '';
            if ~isempty(percentageActivated)
                sPercentageActivated = num2str(percentageActivated,'%.2f');
            end
            
            sTitle = ['(Resp)' NEURON_TYPE_CS '(n=' num2str(length(cellCSTimesResponsive)) ') rate on day ' num2str(currentDay) ' ' sMouseId ' (' sPercentageActivated ' %) '];                        
            sFirstLast = '';
            if FIRST_VS_LAST
                sTitle = [sTitle ' responsive for the first ' num2str(TRIALS_FIRST) ' vs last ' num2str(TRIALS_TO_COMPARE) ' trials)'];
                sFirstLast = ['_firstVSlast' num2str(TRIALS_TO_COMPARE)];
            end
            sFile = [pathToCSPsthFolder sMouseId sLabel '_day' num2str(currentDay) '_' NEURON_TYPE_CS '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_Resp_alignedTo' sAlignedTo sFirstLast '.tif'];
%             plotComparisonPSTHs(cellCSTimesResponsive, NEURON_TYPE_CS, sTitle, sFile, ['Time from ' sAlignedTo ' (s)'], [], 0, COLORS(11, :));
        end

        % Plot NON-RESPONSIVE CSs PSTHs
        if ~isempty(cellCSTimesNonResponsive)
            sTitle = ['(NonResp)' NEURON_TYPE_CS ' (n=' num2str(length(cellCSTimesNonResponsive)) ') rate on day ' num2str(currentDay) ' ' sMouseId];
            sFirstLast = '';
            if FIRST_VS_LAST
                sTitle = [sTitle ' responsive for the first ' num2str(TRIALS_FIRST) ' vs last ' num2str(TRIALS_TO_COMPARE) ' trials)'];
                sFirstLast = ['_firstVSlast' num2str(TRIALS_TO_COMPARE)];
            end
            sFile = [pathToCSPsthFolder sMouseId sLabel '_day' num2str(currentDay) '_' NEURON_TYPE_CS '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_NonResp_alignedTo' sAlignedTo sFirstLast '.tif'];                    
%             plotComparisonPSTHs(cellCSTimesNonResponsive, NEURON_TYPE_CS, sTitle, sFile, ['Time from ' sAlignedTo ' (s)'], [], 0, COLORS(11, :));
        end  

        dayInd = find(ismember(paramDay,currentDay)); % find which day's data processed
        cellCSTimesResponsivePerDay{dayInd} = cellCSTimesResponsive;
        cellCSTimesNonResponsivePerDay{dayInd} = cellCSTimesNonResponsive;
    end

end