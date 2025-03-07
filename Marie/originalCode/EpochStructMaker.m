for n = 1:16
Epochs = RecordingList(n).EpochOnsetsAdj;
for j = 1:length(Epochs)
[i, ~] = find(Epochs(j) == RecordingList(n).AllLicksAdj);
triplet = RecordingList(n).AllLicksAdj(i:i+2);
d1 = triplet(2)-triplet(1);
d2 = triplet(3)-triplet(2);
RecordingList(n).EpochStruct(j,1).EpochFreq = 1/mean([d1 d2]);

[~, nk] = find ([RecordingList(n).TrialStructAdj.ToneTime] < Epochs(j), 1, 'last');
if isempty(nk)
    RecordingList(n).EpochStruct(j,1).TrialType = 'NaN';
    RecordingList(n).EpochStruct(j,1).TrialFictJuice = NaN;
    RecordingList(n).EpochStruct(j,1).TrialIndex = nk;
    RecordingList(n).EpochStruct(j,1).EpochType = 'out';
    RecordingList(n).EpochStruct(j,1).EpochRT = NaN;
    RecordingList(n).EpochStruct(j,1).ToneTime = NaN;
    RecordingList(n).EpochStruct(j,1).EpochTime = Epochs(j);
else
k = find (RecordingList(n).AllLicksAdj > RecordingList(n).TrialStructAdj(nk).FictiveJuice, 1, 'first');
RecordingList(n).EpochStruct(j,1).TrialType = RecordingList(n).TrialStructAdj(nk).TrialType;
RecordingList(n).EpochStruct(j,1).TrialFictJuice = RecordingList(n).TrialStructAdj(nk).FictiveJuice;
        RecordingList(n).EpochStruct(j,1).EpochRT = Epochs(j) -RecordingList(n).TrialStructAdj(nk).ToneTime;
        RecordingList(n).EpochStruct(j,1).TrialIndex = nk;
        RecordingList(n).EpochStruct(j,1).ToneTime = RecordingList(n).TrialStructAdj(nk).ToneTime;
        RecordingList(n).EpochStruct(j,1).EpochTime = Epochs(j);

if RecordingList(n).AllLicksAdj(k) < Epochs(j)
    RecordingList(n).EpochStruct(j,1).EpochType = 'out';
    RecordingList(n).EpochStruct(j,1).EpochRT = Epochs(j) -RecordingList(n).TrialStructAdj(nk).ToneTime;

elseif ~strcmp({RecordingList(n).TrialStructAdj(nk).TrialType}, 'j')
    if Epochs(j) <= RecordingList(n).TrialStructAdj(nk).FictiveJuice + .1
        RecordingList(n).EpochStruct(j,1).EpochType = 'hit';
    end
    if Epochs(j) > RecordingList(n).TrialStructAdj(nk).FictiveJuice + .1
        RecordingList(n).EpochStruct(j,1).EpochType = 'miss';
    end
end
end
end
end

for n = 9:16
    EpochStruct = RecordingList(n).EpochStruct;
    EpochStruct = EpochStruct(strcmp({EpochStruct.EpochType}, 'hit'));
    EpochStructTJ= EpochStruct(strcmp({EpochStruct.TrialType}, 'b')); %only tone-juice hits
    EpochStructTJ= EpochStructTJ([EpochStructTJ.EpochFreq] <= 11.5); %remove very high freq 'licks' that are likely to be grooming
    Trials = [EpochStructTJ.ToneTime];
    Epochs = [EpochStructTJ.EpochTime];
    Freq = [EpochStructTJ.EpochFreq];
    RTs = [EpochStructTJ.EpochRT];
    RecordingList(n).EpochFreqLow25_trial_tjhit = Trials(Freq < prctile([EpochStructTJ.EpochFreq], 25));
    RecordingList(n).EpochFreqHigh25_trial_tjhit = Trials(Freq > prctile([EpochStructTJ.EpochFreq], 75));
    RecordingList(n).EpochFreqLow25_epochs_tjhit = Epochs(Freq < prctile([EpochStructTJ.EpochFreq], 25));
    RecordingList(n).EpochFreqHigh25_epochs_tjhit = Epochs(Freq > prctile([EpochStructTJ.EpochFreq], 75));
    
    RecordingList(n).EpochTimeFast25_trial_tjhit = Trials(RTs < prctile([EpochStructTJ.EpochRT], 25));
    RecordingList(n).EpochTimeSlow25_trial_tjhit = Trials(RTs > prctile([EpochStructTJ.EpochRT], 75));
    RecordingList(n).EpochTimeFast25_epochs_tjhit = Epochs(RTs < prctile([EpochStructTJ.EpochRT], 25));
    RecordingList(n).EpochTimeSlow25_epochs_tjhit = Epochs(RTs > prctile([EpochStructTJ.EpochRT], 75));
end

for n = 1:8
    EpochStruct = RecordingList(n).EpochStruct;
    EpochStruct = EpochStruct(strcmp({EpochStruct.EpochType}, 'miss'));
    EpochStructTJ= EpochStruct(strcmp({EpochStruct.TrialType}, 'b')); %only tone-juice hits
    EpochStructTJ = EpochStructTJ([EpochStructTJ.EpochRT] < 1.6);
    EpochStructTJ= EpochStructTJ([EpochStructTJ.EpochFreq] <= 11.5); %remove very high freq 'licks' that are likely to be grooming
    Trials = [EpochStructTJ.ToneTime];
    Epochs = [EpochStructTJ.EpochTime];
    Freq = [EpochStructTJ.EpochFreq];
    RTs = [EpochStructTJ.EpochRT];
    %RecordingList(n).EpochFreqLow25_trial_tjhit = Trials(Freq < prctile([EpochStructTJ.EpochFreq], 25));
    %RecordingList(n).EpochFreqHigh25_trial_tjhit = Trials(Freq > prctile([EpochStructTJ.EpochFreq], 75));
    %RecordingList(n).EpochFreqLow25_epochs_tjhit = Epochs(Freq < prctile([EpochStructTJ.EpochFreq], 25));
    %RecordingList(n).EpochFreqHigh25_epochs_tjhit = Epochs(Freq > prctile([EpochStructTJ.EpochFreq], 75));
    n
    %RecordingList(n).EpochTimeFast25_trial_tjhit = Trials(RTs < prctile([EpochStructTJ.EpochRT], 25));
    prctile([EpochStructTJ.EpochRT], 25)
    %RecordingList(n).EpochTimeSlow25_trial_tjhit = Trials(RTs > prctile([EpochStructTJ.EpochRT], 75));
    prctile([EpochStructTJ.EpochRT], 75)
    %RecordingList(n).EpochTimeFast25_epochs_tjhit = Epochs(RTs < prctile([EpochStructTJ.EpochRT], 25));
    %RecordingList(n).EpochTimeSlow25_epochs_tjhit = Epochs(RTs > prctile([EpochStructTJ.EpochRT], 75));
end

    