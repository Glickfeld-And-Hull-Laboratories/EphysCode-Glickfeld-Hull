function [arrBehavTimesSelected, recordingDayCellAllLicksSelected, lickOnsetsSelected, cueTimesSelected] = ...
    findBehavioralTimes(paramMouseId, paramDay, behavDataForRecordingDay)
    globals;
    
    arrBehavTimesSelected = [];
    recordingDayCellAllLicksSelected = {};
    lickOnsetsSelected = [];
    cueTimesSelected = [];

    recordingDayTrials = behavDataForRecordingDay.TrialStruct;
    recordingDayLickOnsets = behavDataForRecordingDay.LickOnsets;
    recordingDayCellAllLicks = behavDataForRecordingDay.cellAllLicks;

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
    recordingDayLickOnsets = recordingDayLickOnsets(~nanIdsCell & ~nanIdsOutcomeCell); % Ignore NaN lick onset entries
    recordingDayCellAllLicks = recordingDayCellAllLicks(~nanIdsCell & ~nanIdsOutcomeCell);

    [r1,~] = find(cellfun(@(x) isequal(x,paramMouseId),MICE_VS_NAIVE_DAYS));
    [r2,~] = find(cellfun(@(x) isequal(x,paramDay),MICE_VS_NAIVE_DAYS));
        
    % Select only specified trial types
    if any(r1==r2) % Found a matching NAIVE DAY record
        indsSelectedTrials = ismember({recordingDayTrials.TrialType},TRIALS_TO_INCLUDE_NAIVE);
        indsSelectedLickOnsetsTrialType = ismember({recordingDayLickOnsets.TrialType},TRIALS_TO_INCLUDE_NAIVE);                
    else
        indsSelectedTrials = ismember({recordingDayTrials.TrialType},TRIALS_TO_INCLUDE_NOTNAIVE);
        indsSelectedLickOnsetsTrialType = ismember({recordingDayLickOnsets.TrialType},TRIALS_TO_INCLUDE_NOTNAIVE);
    end

    recordingDayTrialsSelected = recordingDayTrials(indsSelectedTrials);
                
    if ~isempty(recordingDayTrialsSelected)            
        
        indsSelectedLickOnsetsOutcomeType = ismember({recordingDayLickOnsets.Outcome},TRIALOUTCOMES_TO_INCLUDE);

        % Select only specified trial outcomes
        if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK 
            % since we always check reward responsive CSs! it should not change based on which behavioral event we align
            clickTimes = [recordingDayTrialsSelected.JuiceTime];
            flagJuiceTimeisNaN = isnan([recordingDayTrialsSelected.JuiceTime]);
            if any(r1==r2) && any(flagJuiceTimeisNaN) % if there are NaN values in Juice Time and this is a Naive day, go to EmptyClick times for different trial types to get the time value
                flagOtherTrialTypes = ismember({recordingDayTrialsSelected.TrialType},{'eCl'}); % since Naive days trials may include other trial types with solenoid click (eCl,t_eCl other than b,j)
                if any(flagOtherTrialTypes)
                    indsEmptyClickTimeisNonNaN = find(flagOtherTrialTypes & ~isnan([recordingDayTrialsSelected.EmptyClick])); 
                    clickTimes(indsEmptyClickTimeisNonNaN) = [recordingDayTrialsSelected(indsEmptyClickTimeisNonNaN).EmptyClick];
                end
            end
    
            indsSelectedTrialsOutcomeType = ismember({recordingDayTrialsSelected.Outcome},TRIALOUTCOMES_TO_INCLUDE);
            arrBehavTimesSelected = clickTimes(indsSelectedTrialsOutcomeType); 
            recordingDayTrialsSelected = recordingDayTrialsSelected(indsSelectedTrialsOutcomeType);

            if ~isempty(EARLY_VS_LATE_LICK)
                indsSelectedTrialsEarlyLateLickType = ismember({recordingDayTrialsSelected.EarlyVSLateLicks},EARLY_VS_LATE_LICK);
                arrBehavTimesSelected = arrBehavTimesSelected(indsSelectedTrialsEarlyLateLickType);
                recordingDayTrialsSelected = recordingDayTrialsSelected(indsSelectedTrialsEarlyLateLickType);
            end

            trialIndsSelected = [recordingDayTrialsSelected.TrialInd];
            for ii=1:length(trialIndsSelected)
                indsLOTrials = find([recordingDayLickOnsets.TrialInd]==trialIndsSelected(ii) & ismember({recordingDayLickOnsets.Outcome},TRIALOUTCOMES_TO_INCLUDE));
                firstLickOnsetInTrial = [];
                if ~isempty(indsLOTrials)
                    firstLickOnsetInTrial = recordingDayLickOnsets(indsLOTrials(1)).time; % get the first of the lick onsets cus late onsets may skew the average
                end                    
                lickOnsetsSelected{length(lickOnsetsSelected)+1} = firstLickOnsetInTrial;
                allLicks = recordingDayCellAllLicks(indsLOTrials);
                recordingDayCellAllLicksSelected{length(recordingDayCellAllLicksSelected)+1} = cell2mat(allLicks');            
            end
            
            if length(recordingDayCellAllLicksSelected)~=length(arrBehavTimesSelected)
                error('trial numbers do NOT match! - click aligned');
            end
        elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
            recordingDayLickOnsetsSelected = recordingDayLickOnsets(indsSelectedLickOnsetsTrialType & indsSelectedLickOnsetsOutcomeType);            
            recordingDayCellAllLicksSelected = recordingDayCellAllLicks(indsSelectedLickOnsetsTrialType & indsSelectedLickOnsetsOutcomeType);
            indsSelectedTrialsOutcomeType = ismember({recordingDayTrialsSelected.Outcome},TRIALOUTCOMES_TO_INCLUDE);

            if ~isempty(EARLY_VS_LATE_LICK)                
                indsSelectedTrialsEarlyLateLickType = ismember({recordingDayTrialsSelected.EarlyVSLateLicks},EARLY_VS_LATE_LICK);
                trialIndsEarlyvsLate = [recordingDayTrialsSelected(indsSelectedTrialsOutcomeType & indsSelectedTrialsEarlyLateLickType).TrialInd];
                indsRecordingDayLickOnsetsSelected = ismember([recordingDayLickOnsetsSelected.TrialInd],trialIndsEarlyvsLate);
                recordingDayLickOnsetsSelected = recordingDayLickOnsetsSelected(indsRecordingDayLickOnsetsSelected);
                recordingDayCellAllLicksSelected = recordingDayCellAllLicksSelected(indsRecordingDayLickOnsetsSelected);
            end            
            arrBehavTimesSelected = [recordingDayLickOnsetsSelected.time];

            trialIndForCueTimes = [recordingDayLickOnsetsSelected.TrialInd];
            cueTimesSelected = {};
            recordingDayTrialsSelected = recordingDayTrialsSelected(indsSelectedTrialsOutcomeType);
            for indC=1:length(trialIndForCueTimes)
                indsRDT = find([recordingDayTrialsSelected.TrialInd]==trialIndForCueTimes(indC));
                if ~isempty(indsRDT)
                    cueTimesSelected{length(cueTimesSelected)+1}=recordingDayTrialsSelected(indsRDT).ToneTime;
                else
                    cueTimesSelected{length(cueTimesSelected)+1} = [];
                end
            end
%             cueTimesSelected = num2cell([recordingDayLickOnsetsSelected.time]-[recordingDayLickOnsetsSelected.RTj]);
        elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_TONE
            toneTimes = [recordingDayTrialsSelected.ToneTime];
            indsSelectedTrialsOutcomeType = ismember({recordingDayTrialsSelected.Outcome},TRIALOUTCOMES_TO_INCLUDE);
            arrBehavTimesSelected = toneTimes(indsSelectedTrialsOutcomeType); 

            trialIndsSelected = [recordingDayTrialsSelected(indsSelectedTrialsOutcomeType).TrialInd];
            for ii=1:length(trialIndsSelected)
                indsLOTrials = find([recordingDayLickOnsets.TrialInd]==trialIndsSelected(ii));
                allLicks = recordingDayCellAllLicks(indsLOTrials);
                recordingDayCellAllLicksSelected{length(recordingDayCellAllLicksSelected)+1} = cell2mat(allLicks');
            end
            if length(recordingDayCellAllLicksSelected)~=length(arrBehavTimesSelected)
                error('trial numbers do NOT match! - tone aligned');
            end
        end
    end
end