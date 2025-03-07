for lmnop = 1:19
    if ~isempty([RecordingList(lmnop).TrialStructAdj])
    clear EpochsOnsetsFirstAfterTone
    clear EpochsOnsetsNoJuice_noexpect
counter = 1;
counter2 = 1;
[~, RecordingList(lmnop).JuiceAloneAdj, RecordingList(lmnop).ToneAloneAdj, RecordingList(lmnop).JuiceAfterTone, RecordingList(lmnop).ToneBeforeJuice, ~] = JuiceToneCreateTrialSt(rmmissing([RecordingList(lmnop).TrialStructAdj.JuiceTime]), rmmissing([RecordingList(lmnop).TrialStructAdj.ToneTime]));

EpochsOnsets = RecordingList(lmnop).EpochOnsetsAdj;
AllLicks = RecordingList(lmnop).AllLicksAdj; 
ToneBeforeJuice = RecordingList(lmnop).ToneBeforeJuice;
JuiceAfterTone = RecordingList(lmnop).JuiceAfterTone;
for n = 1:length(EpochsOnsets)
    [i, k] = find (ToneBeforeJuice < EpochsOnsets(n), 1, 'last');
    if ~isempty(i)
    if isempty(AllLicks(AllLicks < EpochsOnsets(n) & AllLicks > ToneBeforeJuice(i)))
        EpochsOnsetsFirstAfterTone(counter) = EpochsOnsets(n);
        counter = counter + 1;
    end
    if length(AllLicks(AllLicks < EpochsOnsets(n) & AllLicks > JuiceAfterTone(i))) >=3
        EpochsOnsetsNoJuice_noexpect(counter2) = EpochsOnsets(n);
        counter2 = counter2 + 1;
    end
    end
end
RecordingList(lmnop).EpochsOnsetFirstAfterTone = EpochsOnsetsFirstAfterTone;
RecordingList(lmnop).EpochsOnsetNoJuice_expect =EpochsOnsetsNoJuice_noexpect;
    end
end

