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
    buildCSDistOfResponses(behavDataForRecordingDays, unitCSs, unitSSs, paramMouseId, paramDay, modeAlignment, sLabel)
    globals;
        
    recordingDayTrialsSelected = [];
    csInds = [];
    csIndsPerDay = [];
    responseMagnitudes = [];
    responseMagnitudesPerDay = [];
    
    % arrNaiveRecordingDays = behavDataForRecordingDays([behavDataForRecordingDays.day] <= 3); % get only first three (Naive) days
    indsRecordingDays = find([behavDataForRecordingDays.mouse]==paramMouseId & ismember([behavDataForRecordingDays.day],paramDay));
    indsCSs = find(ismember([unitCSs.RecorNum], indsRecordingDays));
    
    dayNext = 0;

    nUnitActivated = 0;
    nUnitSuppressed = 0;
    nUnitNonResponsive = 0;

    cellCSTimesResponsivePerDay = cell(1,length(paramDay));
    cellCSTimesNonResponsivePerDay = cell(1,length(paramDay));
    
    sAlignedTo = 'click';        

    for indLoop=1:length(indsCSs)
        unitCS = unitCSs(indsCSs(indLoop));
        recordingDayInd = unitCS.RecorNum;
        [unitSS, ~] = findPair(unitSSs, recordingDayInd, unitCS, [], []);

        if ~isempty(unitSS)
            behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);
                            
            mouseId = behavDataForRecordingDay.mouse;
            day = behavDataForRecordingDay.day;
            
            recordingDayTrials = behavDataForRecordingDay.TrialStruct;
            recordingDayLickOnsets = behavDataForRecordingDay.LickOnsets;

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
            lickOnsetTrialTypes = lickOnsetTrialTypes(~nanIdsCell & ~nanIdsOutcomeCell); % Ignore NaN lick onset entries
            lickOnsetOutcomeTypes = lickOnsetOutcomeTypes(~nanIdsCell & ~nanIdsOutcomeCell); % Ignore NaN lick onset entries
            recordingDayLickOnsets = recordingDayLickOnsets(~nanIdsCell & ~nanIdsOutcomeCell); % Ignore NaN lick onset entries
            
            [r1,~] = find(cellfun(@(x) isequal(x,paramMouseId),MICE_VS_NAIVE_DAYS));
            [r2,~] = find(cellfun(@(x) isequal(x,paramDay),MICE_VS_NAIVE_DAYS));
            
            % Select only specified trial types
            if any(r1==r2) % Found a matching NAIVE DAY record
                indsSelectedTrials = ismember({recordingDayTrials.TrialType},TRIALS_TO_INCLUDE_CS_RESPONSIVE_NAIVE);
                indsSelectedLickOnsetsTrialType = ismember(lickOnsetTrialTypes,TRIALS_TO_INCLUDE_CS_RESPONSIVE_NAIVE);                
            else
                indsSelectedTrials = ismember({recordingDayTrials.TrialType},TRIALS_TO_INCLUDE_CS_RESPONSIVE_NOTNAIVE);
                indsSelectedLickOnsetsTrialType = ismember(lickOnsetTrialTypes,TRIALS_TO_INCLUDE_CS_RESPONSIVE_NOTNAIVE);
            end
                
            recordingDayTrialsSelected = recordingDayTrials(indsSelectedTrials);
                
            if ~isempty(recordingDayTrialsSelected)            
%                 % since we always check reward responsive CSs! it should not change based on which behavioral event we align
%                 clickTimes = [recordingDayTrialsSelected.JuiceTime];
%                 flagJuiceTimeisNaN = isnan([recordingDayTrialsSelected.JuiceTime]);
%                 if any(r1==r2) && any(flagJuiceTimeisNaN) % if there are NaN values in Juice Time and this is a Naive day, go to EmptyClick times for different trial types to get the time value
%                     flagOtherTrialTypes = ismember({recordingDayTrialsSelected.TrialType},{'eCl'}); % since Naive days trials may include other trial types with solenoid click (eCl,t_eCl other than b,j)
%                     if any(flagOtherTrialTypes)
%                         indsEmptyClickTimeisNonNaN = find(flagOtherTrialTypes & ~isnan([recordingDayTrialsSelected.EmptyClick])); 
%                         clickTimes(indsEmptyClickTimeisNonNaN) = [recordingDayTrialsSelected(indsEmptyClickTimeisNonNaN).EmptyClick];
%                     end
%                 end
% 
%                 % Select only specified trial outcomes
%                 if modeAlignment == MODE_ALIGNMENT_TO_CLICK         
%                     indsSelectedTrialsOutcomeType = ismember({recordingDayTrialsSelected.Outcome},TRIALOUTCOMES_TO_INCLUDE);
%                     clickTimes = clickTimes(indsSelectedTrialsOutcomeType);
%                     arrBehavTimesSelected = clickTimes;                
%                 elseif modeAlignment == MODE_ALIGNMENT_TO_LICK
%                     indsSelectedLickOnsetsOutcomeType = ismember(lickOnsetOutcomeTypes,TRIALOUTCOMES_TO_INCLUDE);
%                     recordingDayLickOnsetsSelected = recordingDayLickOnsets(indsSelectedLickOnsetsTrialType & indsSelectedLickOnsetsOutcomeType);
%                     arrBehavTimesSelected = [recordingDayLickOnsetsSelected.time];                
%                 end
%                     
%                 csTimesAlignedSelected = chunkAlignSpikeTimes(unitCS.timestamps, arrBehavTimesSelected);
%                 
                % Find the reward responsive CS
                responseMagnitude = getResponse(unitCS.timestamps, recordingDayTrialsSelected); %,pathToCSPsthFolder, num2str(mouseId), sLabel, day, unitCS.unitID);
                responseMagnitudes = [responseMagnitudes responseMagnitude];
                csInds = [csInds indsCSs(indLoop)];
            end
%         end

            % If mouse or day changed, do collective plottings for all CSs gathered        
            if (indLoop+1)<=length(indsCSs)
                unitCSNext = unitCSs(indsCSs(indLoop+1));
                recordingDayIndNext = unitCSNext.RecorNum;
                behavDataForRecordingDayNext = behavDataForRecordingDays(recordingDayIndNext);
                dayNext = behavDataForRecordingDayNext.day;
            end

            if dayNext ~= day
                if ~isempty(responseMagnitudes)
                    sMouseId = ['mouse' num2str(mouseId)];                        
                    logger.info('checkCSResponsesToClick', ['day ' num2str(day) ' mouse ' num2str(mouseId) ' mean response=' num2str(mean(responseMagnitudes))]);
                    
                    if ~all(responseMagnitudes==0)
%                         f = prePlot();
%                         sTitle = [NEURON_TYPE_CS '(n=' num2str(length(responseMagnitudes)) ') rate on day ' num2str(day) ' ' sMouseId];                        
%                         sFile = [pathToRespMagnDistToClickFolder sMouseId sLabel '_day' num2str(day) '_' NEURON_TYPE_CS '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_Resp_alignedTo' sAlignedTo '.tif'];
%                         edges = [round(min(responseMagnitudes))-1:1:round(max(responseMagnitudes))+1];
%                         h = histogram(responseMagnitudes, edges);
%                         postPlot(f, 'z-score(spk/s)', 'Freq.', [], [], 0, max(h.Values)+1, sTitle, sFile);
%                             
                        responseMagnitudesPerDay = [responseMagnitudesPerDay responseMagnitudes];
                        csIndsPerDay = [csIndsPerDay csInds];
                    end
%                     dayInd = find(ismember(paramDay,day)); % find which day's data processed                    
%                     cellCSTimesResponsivePerDay{dayInd} = cellCSTimesResponsive;
%                     cellCSTimesNonResponsivePerDay{dayInd} = cellCSTimesNonResponsive;
                end
        
                dayNext = day;
                responseMagnitudes = [];
                csInds = [];
            end
        end
    end        
end