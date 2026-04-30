aa=cat(1,behavDataForRecordingDays.TrialStruct);

for i=1:length(behavDataForRecordingDays)

    i
    aInd=sum(ismember({behavDataForRecordingDays(i).TrialStruct.TrialType},'t_eCl'))
    aInd1=sum(ismember({behavDataForRecordingDays(i).TrialStruct.TrialType},'eCl'))

end

indsSelectedTrials1 = ismember({recordingDayTrials.TrialType},'t_eCl');
sum(indsSelectedTrials1)

indsSelectedTrials2 = ismember({recordingDayTrials.TrialType},'eCl');
sum(indsSelectedTrials2)