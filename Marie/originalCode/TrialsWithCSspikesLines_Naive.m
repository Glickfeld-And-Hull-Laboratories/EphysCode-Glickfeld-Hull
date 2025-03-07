clear CS_spikeNospike_naive
clear SS_spikeNospike_naive
clear MLI_spikeNospike_naive
counter = 1;
counter2 = 1;
counter3 = 1;
for n = 1:length(Naive)
if strcmp({Naive(n).handID}, 'CS_pause')
%[~, MaskFire] = TrialsWithSpike(n, Naive, [RecordingList(Naive(n).RecorNum).ToneBeforeJuiceAdj], [.08 .22]);
[TrialsSpike, MaskFire] = TrialsWithSpike(n, Naive, [RecordingList(Naive(n).RecorNum).ToneBeforeJuiceAdj], [.69 .82]);
ToneTimes = [RecordingList(Naive(n).RecorNum).ToneBeforeJuiceAdj].';
TrialsNoSpike = ToneTimes(logical(abs(MaskFire)-1));
TrialsSpike = ToneTimes(logical((MaskFire)));
if length(TrialsSpike)/length([RecordingList(Naive(n).RecorNum).TrialStructAdj.JuiceTime])>.1
[CS_spikeNospike_naive(counter).SpikeTrials_N, CS_spikeNospike_naive(counter).SpikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsSpike.', n, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[CS_spikeNospike_naive(counter).NospikeTrials_N, CS_spikeNospike_naive(counter).NospikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsNoSpike.', n, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[CS_spikeNospike_naive(counter).AllTrials_N, CS_spikeNospike_naive(counter).AllTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(ToneTimes.', n, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);

LastTrialCS_fire = circshift(MaskFire, 1);
LastTrialCS_fire(1) = 0;
Trials_LastTrialSpike = ToneTimes(logical(LastTrialCS_fire));
Trials_LastTrialNospike = ToneTimes(logical(abs(LastTrialCS_fire)-1));
[CS_spikeNospike_naive(counter).LastTrialSpike_N, CS_spikeNospike_naive(counter).LastTrialSpike_edges, ~] = OneUnitHistStructTimeLimLineINDEX(Trials_LastTrialSpike.', n, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[CS_spikeNospike_naive(counter).LastTrialNospikes_N, CS_spikeNospike_naive(counter).LastTrialNospikes_edges, ~] = OneUnitHistStructTimeLimLineINDEX(Trials_LastTrialNospike.', n, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);

CS_spikeNospike_naive(counter).Trials_LastTrialSpike = Trials_LastTrialSpike;
CS_spikeNospike_naive(counter).Trials_LastTrialNospike = Trials_LastTrialNospike;
CS_spikeNospike_naive(counter).NaiveIndex = n;
CS_spikeNospike_naive(counter).JuiceTimes = ToneTimes;
CS_spikeNospike_naive(counter).MaskFire = MaskFire;
CS_spikeNospike_naive(counter).TrialsNoSpike = TrialsNoSpike;
CS_spikeNospike_naive(counter).SumTrialsFire = length(TrialsSpike);
CS_spikeNospike_naive(counter).SumTrialsNoFire = length(TrialsNoSpike);
CS_spikeNospike_naive(counter).AllTrials = length(ToneTimes);
CS_spikeNospike_naive(counter).BrainReg = Naive(n).BrainReg;
%if CS_spikeNospike_naive(counter).SumTrialsFire + CS_spikeNospike_naive(counter).SumTrialsNoFire ~= CS_spikeNospike_naive(counter).AllTrials 
%    n
%    counter
%end
CS_spikeNospike_naive(counter).RecorNum = Naive(n).RecorNum;
CS_spikeNospike_naive(counter).channel= Naive(n).channel;


for k = 1:length(Naive)
    if strcmp({Naive(n).handID}, 'CS_pause')
        if k ~= n
    if Cell2CellDistINDEX(Naive, n, k, MEH_chanMap) < 160
    end
        end
    end
end



counter = counter + 1;

%SS
PC_unitID = Naive(n).PCpair;
for pc = 1:length(Naive)
if Naive(pc).unitID == PC_unitID
if Naive(pc).RecorNum == Naive(n).RecorNum
PC_index = pc;
end
end
end

[SS_spikeNospike_naive(counter2).SpikeTrials_N, SS_spikeNospike_naive(counter2).SpikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsSpike.', PC_index, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[SS_spikeNospike_naive(counter2).NospikeTrials_N, SS_spikeNospike_naive(counter2).NospikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsNoSpike.', PC_index, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[SS_spikeNospike_naive(counter2).AllTrials_N, SS_spikeNospike_naive(counter2).AllTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX([RecordingList(Naive(n).RecorNum).ToneBeforeJuiceAdj], PC_index, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);

LastTrialCS_fire = circshift(MaskFire, 1);
LastTrialCS_fire(1) = 0;
Trials_LastTrialSpike = ToneTimes(logical(LastTrialCS_fire));
Trials_LastTrialNospike = ToneTimes(logical(abs(LastTrialCS_fire)-1));
[SS_spikeNospike_naive(counter2).LastTrialSpike_N, SS_spikeNospike_naive(counter2).LastTrialSpike_edges, ~] = OneUnitHistStructTimeLimLineINDEX(Trials_LastTrialSpike.', PC_index, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[SS_spikeNospike_naive(counter2).LastTrialNospikes_N, SS_spikeNospike_naive(counter2).LastTrialNospikes_edges, ~] = OneUnitHistStructTimeLimLineINDEX(Trials_LastTrialNospike.', PC_index, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);

SS_spikeNospike_naive(counter2).Trials_LastTrialSpike = Trials_LastTrialSpike;
SS_spikeNospike_naive(counter2).Trials_LastTrialNospike = Trials_LastTrialNospike;
SS_spikeNospike_naive(counter2).CS_NaiveIndex = n;
SS_spikeNospike_naive(counter2).SS_NaiveIndex = PC_index;
SS_spikeNospike_naive(counter2).JuiceTimes = [RecordingList(Naive(n).RecorNum).TrialStructAdj.JuiceTime];
SS_spikeNospike_naive(counter2).MaskFire = TrialsSpike;
SS_spikeNospike_naive(counter2).TrialsNoSpike = TrialsNoSpike;
SS_spikeNospike_naive(counter2).SumTrialsFire = length(TrialsSpike);
SS_spikeNospike_naive(counter2).SumTrialsNoFire = length(TrialsNoSpike);
SS_spikeNospike_naive(counter2).BrainReg = Naive(n).BrainReg;
counter2 = counter2 + 1;


%MLI
for k = 1:length(Naive)
    if strcmp({Naive(k).CellType}, 'MLI')
    if Cell2CellDistINDEX(Naive, n, k, MEH_chanMap) < 160
        if Naive(k).RecorNum == Naive(n).RecorNum
        [MLI_spikeNospike_naive(counter3).SpikeTrials_N, MLI_spikeNospike_naive(counter3).SpikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsSpike.', k, Naive, -8, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[MLI_spikeNospike_naive(counter3).NospikeTrials_N, MLI_spikeNospike_naive(counter3).NospikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsNoSpike.', k, Naive, -8, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[MLI_spikeNospike_naive(counter3).AllTrials_N, MLI_spikeNospike_naive(counter3).AllTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX([RecordingList(Naive(n).RecorNum).ToneBeforeJuiceAdj], k, Naive, -8, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);

MLI_spikeNospike_naive(counter3).CS_NaiveIndex = n;
MLI_spikeNospike_naive(counter3).MLI_NaiveIndex = k;
MLI_spikeNospike_naive(counter3).JuiceTimes = [RecordingList(Naive(n).RecorNum).TrialStructAdj.JuiceTime];
MLI_spikeNospike_naive(counter3).MaskFire = TrialsSpike;
MLI_spikeNospike_naive(counter3).TrialsNoSpike = TrialsNoSpike;
MLI_spikeNospike_naive(counter3).SumTrialsFire = length(TrialsSpike);
MLI_spikeNospike_naive(counter3).SumTrialsNoFire = length(TrialsNoSpike);
MLI_spikeNospike_naive(counter3).AllTrials = [RecordingList(Naive(n).RecorNum).ToneBeforeJuiceAdj];
MLI_spikeNospike_naive(counter3).SumAllTrials = length([RecordingList(Naive(n).RecorNum).ToneBeforeJuiceAdj]);
MLI_spikeNospike_naive(counter3).BrainReg = Naive(n).BrainReg;

counter3 = counter3 + 1;
    end
    end
    end
end





end
end
end

CS_spikeNospike_naive = CS_spikeNospike_naive(strcmp({CS_spikeNospike_naive.BrainReg}, 'Crus2'));
SS_spikeNospike_naive = SS_spikeNospike_naive(strcmp({SS_spikeNospike_naive.BrainReg}, 'Crus2'));
MLI_spikeNospike_naive = MLI_spikeNospike_naive(strcmp({MLI_spikeNospike_naive.BrainReg}, 'Crus2'));

figure
hold on
shadedErrorBar2(CS_spikeNospike_naive(1).SpikeTrials_edges(1:end-1),  mean(struct2mat(CS_spikeNospike_naive, 'SpikeTrials_N')), std(struct2mat(CS_spikeNospike_naive, 'SpikeTrials_N'))/sqrt(length(struct2mat(CS_spikeNospike_naive, 'SpikeTrials_N'))), 'lineProp', 'm');
shadedErrorBar2(CS_spikeNospike_naive(1).NospikeTrials_edges(1:end-1), mean(struct2mat(CS_spikeNospike_naive, 'NospikeTrials_N')), std(struct2mat(CS_spikeNospike_naive, 'NospikeTrials_N'))/sqrt(length(struct2mat(CS_spikeNospike_naive, 'NospikeTrials_N'))), 'lineProp', 'b')
shadedErrorBar2(CS_spikeNospike_naive(1).AllTrials_edges(1:end-1), mean(struct2mat(CS_spikeNospike_naive, 'AllTrials_N')), std(struct2mat(CS_spikeNospike_naive, 'AllTrials_N'))/sqrt(length(struct2mat(CS_spikeNospike_naive, 'AllTrials_N'))), 'lineProp', 'k')
title('CS')
legend({'no spike trial'; 'spike trial'; 'all trial'})
legend('boxoff');

figure
hold on
shadedErrorBar2(CS_spikeNospike_naive(1).LastTrialNospikes_edges(1:end-1),  mean(struct2mat(CS_spikeNospike_naive, 'LastTrialNospikes_N')), std(struct2mat(CS_spikeNospike_naive, 'LastTrialNospikes_N'))/sqrt(length(struct2mat(CS_spikeNospike_naive, 'LastTrialNospikes_N'))), 'lineProp', 'b');
shadedErrorBar2(CS_spikeNospike_naive(1).LastTrialSpike_edges(1:end-1), mean(struct2mat(CS_spikeNospike_naive, 'LastTrialSpike_N')), std(struct2mat(CS_spikeNospike_naive, 'LastTrialSpike_N'))/sqrt(length(struct2mat(CS_spikeNospike_naive, 'LastTrialSpike_N'))), 'lineProp', 'm')
shadedErrorBar2(CS_spikeNospike_naive(1).AllTrials_edges(1:end-1), mean(struct2mat(CS_spikeNospike_naive, 'AllTrials_N')), std(struct2mat(CS_spikeNospike_naive, 'AllTrials_N'))/sqrt(length(struct2mat(CS_spikeNospike_naive, 'AllTrials_N'))), 'lineProp', 'k')
title('CS last trial');
legend({'lastTrialNoSpikes'; 'LastTrialSpike'; 'AllTrials'})
legend('boxoff');


figure
hold on
shadedErrorBar2(SS_spikeNospike_naive(1).NospikeTrials_edges(1:end-1),  mean(struct2mat(SS_spikeNospike_naive, 'SpikeTrials_N')), std(struct2mat(SS_spikeNospike_naive, 'SpikeTrials_N'))/sqrt(length(struct2mat(SS_spikeNospike_naive, 'SpikeTrials_N'))), 'lineProp', 'm');
shadedErrorBar2(SS_spikeNospike_naive(1).SpikeTrials_edges(1:end-1), mean(struct2mat(SS_spikeNospike_naive, 'NospikeTrials_N')), std(struct2mat(SS_spikeNospike_naive, 'NospikeTrials_N'))/sqrt(length(struct2mat(SS_spikeNospike_naive, 'NospikeTrials_N'))), 'lineProp', 'b')
shadedErrorBar2(SS_spikeNospike_naive(1).AllTrials_edges(1:end-1), mean(struct2mat(SS_spikeNospike_naive, 'AllTrials_N')), std(struct2mat(SS_spikeNospike_naive, 'AllTrials_N'))/sqrt(length(struct2mat(SS_spikeNospike_naive, 'AllTrials_N'))), 'lineProp', 'k')
title('SS')
legend({'no spike trial'; 'spike trial'; 'all trial'})
legend('boxoff');

figure
hold on
shadedErrorBar2(SS_spikeNospike_naive(1).LastTrialNospikes_edges(1:end-1),  mean(struct2mat(SS_spikeNospike_naive, 'LastTrialNospikes_N')), std(struct2mat(SS_spikeNospike_naive, 'LastTrialNospikes_N'))/sqrt(length(struct2mat(SS_spikeNospike_naive, 'LastTrialNospikes_N'))), 'lineProp', 'b');
shadedErrorBar2(SS_spikeNospike_naive(1).LastTrialSpike_edges(1:end-1), mean(struct2mat(SS_spikeNospike_naive, 'LastTrialSpike_N')), std(struct2mat(SS_spikeNospike_naive, 'LastTrialSpike_N'))/sqrt(length(struct2mat(SS_spikeNospike_naive, 'LastTrialSpike_N'))), 'lineProp', 'm')
shadedErrorBar2(SS_spikeNospike_naive(1).AllTrials_edges(1:end-1), mean(struct2mat(SS_spikeNospike_naive, 'AllTrials_N')), std(struct2mat(SS_spikeNospike_naive, 'AllTrials_N'))/sqrt(length(struct2mat(SS_spikeNospike_naive, 'AllTrials_N'))), 'lineProp', 'k')
title('SS last trial');
legend({'lastTrialNoSpikes'; 'LastTrialSpike'; 'AllTrials'})
legend('boxoff');

figure
hold on
shadedErrorBar2(MLI_spikeNospike_naive(1).NospikeTrials_edges(1:end-1), mean(struct2mat(MLI_spikeNospike_naive, 'NospikeTrials_N')), std(struct2mat(MLI_spikeNospike_naive, 'NospikeTrials_N'))/sqrt(length(struct2mat(MLI_spikeNospike_naive, 'NospikeTrials_N'))), 'lineProp', 'b')
shadedErrorBar2(MLI_spikeNospike_naive(1).NospikeTrials_edges(1:end-1), mean(struct2mat(MLI_spikeNospike_naive, 'SpikeTrials_N')), std(struct2mat(MLI_spikeNospike_naive, 'SpikeTrials_N'))/sqrt(length(struct2mat(MLI_spikeNospike_naive, 'SpikeTrials_N'))), 'lineProp', 'm')
shadedErrorBar2(MLI_spikeNospike_naive(1).AllTrials_edges(1:end-1), mean(struct2mat(MLI_spikeNospike_naive, 'AllTrials_N')), std(struct2mat(MLI_spikeNospike_naive, 'AllTrials_N'))/sqrt(length(struct2mat(MLI_spikeNospike_naive, 'AllTrials_N'))), 'lineProp', 'k')
title('MLI');
legend({'no spike trial'; 'spike trial'; 'all trial'})
legend('boxoff');