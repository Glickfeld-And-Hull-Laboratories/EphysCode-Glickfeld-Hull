for n = 1:length(SumSt)
k = (SumSt(n).RecorNum);
[N, edges, L1] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).ToneBeforeJuiceAdj], n, SumSt, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
SumSt(n).ToneBeforeJuice_N = N;
SumSt(n).ToneBeforeJuice_edges = edges;
[N, edges, L1] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).UnexpectedReward].', n, SumSt, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
SumSt(n).UnexpectedReward_N = N;
SumSt(n).UnexpectedReward_edges = edges;
[N, edges, L1] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).OmittedReward].', n, SumSt, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
SumSt(n).OmittedReward_N = N;
SumSt(n).OmittedReward_edges = edges;
end
Naive = SumSt([SumSt.TrainBoo] == 0);
Conditioned = SumSt([SumSt.TrainBoo] == 1);
Conditioned_Responsive = Conditioned([Conditioned.Responsive] == 1);
Naive_Responsive = Naive([Naive.Responsive] == 1);

for n = 1:length(SumSt)
k = (SumSt(n).RecorNum);
[N, edges, L1] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).PreviousTrialWasOmittedReward.ToneTime].', n, SumSt, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
SumSt(n).Tone_PreviousTrialWasOmittedReward_N = N;
SumSt(n).Tone_PreviousTrialWasOmittedReward_edges = edges;
[N, edges, L1] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).PreviousTrialWasTone_Juice.ToneTime].', n, SumSt, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
SumSt(n).Tone_PreviousTrialWasTone_Juice_N = N;
SumSt(n).Tone_PreviousTrialWasTone_Juice_edges = edges;

end

for n = 1:length(SumSt)
k = (SumSt(n).RecorNum);
[N, edges, L1] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).PreviousTrialWasUnexpectedReward.ToneTime].', n, SumSt, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
SumSt(n).Tone_PreviousTrialWasUnexpectedReward_N = N;
SumSt(n).Tone_PreviousTrialWasUnexpectedReward_edges = edges;
end


