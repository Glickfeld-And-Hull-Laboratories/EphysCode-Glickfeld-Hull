function behavDataForRecordingDays = assignEarlyVSLateQuartileLicks(behavDataForRecordingDays)

    globals;

    cellAllLicksRT = {};
    for i=1:length(behavDataForRecordingDays)
        lickOnsets = behavDataForRecordingDays(i).LickOnsets;
        allLicks = behavDataForRecordingDays(i).AllLicks;
        trialStruct = behavDataForRecordingDays(i).TrialStruct;
        isRewarded = ismember([trialStruct.Outcome],['p','r']);
        indRewarded = find(isRewarded);
        trialStructRT = [trialStruct(isRewarded).RTj];
        [values,~] = histcounts(trialStructRT,EDGES_LICK);        
        firstQuartile = round(sum(values)/4);
        lastQuartile = 3*firstQuartile;
        cumSumValues = cumsum(values);
        indFirstQ = find(cumSumValues>=firstQuartile,1);
        indLastQ = find(cumSumValues<=lastQuartile,1,"last");
        indsFirstQuartile = find(trialStructRT<=EDGES_LICK(indFirstQ)); % find the indices of earliest(1/4) licks
        indsLastQuartile = find(trialStructRT>=EDGES_LICK(indLastQ)); % find the indices of latest(3/4) licks
        [behavDataForRecordingDays(i).TrialStruct.EarlyVSLateLicks] = deal('');
        [behavDataForRecordingDays(i).TrialStruct(indRewarded(indsFirstQuartile)).EarlyVSLateLicks] = deal('e');
        [behavDataForRecordingDays(i).TrialStruct(indRewarded(indsLastQuartile)).EarlyVSLateLicks] = deal('l');
    end
end