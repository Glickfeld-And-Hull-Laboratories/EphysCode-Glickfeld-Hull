for n = 1:length(RecordingList)
    TrialType = {RecordingList(n).TrialStructAdj.TrialType}.';
    PreviousTrialType = circshift(TrialType, 1);
    PreviousTrialType{1} = 'n';
    RecordingList(n).PreviousTrialWasUnexpectedReward = RecordingList(n).TrialStructAdj(strcmp(PreviousTrialType, 'j'));
end
