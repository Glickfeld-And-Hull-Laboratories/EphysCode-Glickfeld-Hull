counter = 1;

for n = 1:length(Naive)
    if strcmp({Naive(n).handID}, 'CS_pause')
[TrialsSpike, MaskFire] = TrialsWithSpike(n, Naive, [RecordingList(Naive(n).RecorNum).TrialStructAdj.JuiceTime], [.02 .04]);
Mask_NextSpike = circshift(MaskFire, 1);
Mask_NextSpike(1) = 0;
(Naive(n).RecorNum)
TrialStruct = RecordingList((Naive(n).RecorNum)).TrialStructAdj';
TrialStruct_NOTnexttrial = TrialStruct(Mask_NextSpike == 0);
TrialStruct_NextTrial = TrialStruct(Mask_NextSpike == 1);
if length(MaskFire)/length([RecordingList(Naive(n).RecorNum).TrialStructAdj.JuiceTime])>.2
    
PC_unitID = Naive(n).PCpair;
for pc = 1:length(Naive)
    if Naive(pc).unitID == PC_unitID
        if strcmp({Naive(pc).recordingID}, {Naive(n).recordingID})
            PC_index = pc;
        end
    end
end

[N, edges, L1] = OneUnitHistStructTimeLimLineINDEX([TrialStruct_NextTrial.ToneTime].', PC_index, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
SSresp(counter).NextTrial_N = N;
SSresp(counter).NextTrial_edges = edges;
SSresp(counter).SSindex = PC_index;
SSresp(counter).CSindex = n;
[N, edges, L1] = OneUnitHistStructTimeLimLineINDEX([TrialStruct_NOTnexttrial.ToneTime].', PC_index, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
SSresp(counter).NOTexttrial_N = N;
SSresp(counter).NOTexttrial_edges = edges;
counter = counter + 1;
    end
    end
end


---------------------



Mean(counter).index = n;
Mean(counter).nextTrial = mean([TrialStruct_NextTrial([TrialStruct_NextTrial.RTt] ~=inf).RTt], 'omitnan');
Mean(counter).nextTrialSTD = std([TrialStruct_NextTrial([TrialStruct_NextTrial.RTt] ~=inf).RTt], 'omitnan');
Mean(counter).nextTrialLength = length([TrialStruct_NextTrial([TrialStruct_NextTrial.RTt] ~=inf).RTt]);

Mean(counter).NOTnextTrial = mean([TrialStruct_NOTnexttrial([TrialStruct_NOTnexttrial.RTt] ~=inf).RTt], 'omitnan');
Mean(counter).NOTnextTrialSTD = std([TrialStruct_NOTnexttrial([TrialStruct_NOTnexttrial.RTt] ~=inf).RTt], 'omitnan');
Mean(counter).NOTnextTrialLength = length([TrialStruct_NOTnexttrial([TrialStruct_NOTnexttrial.RTt] ~=inf).RTt]);
counter = counter +1;
    end
end