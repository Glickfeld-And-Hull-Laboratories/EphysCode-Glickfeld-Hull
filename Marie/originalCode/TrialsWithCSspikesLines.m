clear MLI_spikeNospike
clear CS_spikeNospike
clear SS_spikeNospike
counter = 1;
counter2 = 1;
counter3 = 1;
for n = 1:length(Naive)
if strcmp({Naive(n).handID}, 'CS_pause')
[TrialsSpike, MaskFire] = TrialsWithSpike(n, Naive, [RecordingList(Naive(n).RecorNum).TrialStructAdj.JuiceTime], [.22 .8]);
JuiceTimes = [RecordingList(Naive(n).RecorNum).TrialStructAdj.JuiceTime];
TrialsNoSpike = JuiceTimes(logical(abs(MaskFire)-1));
if length(TrialsSpike)/length([RecordingList(Naive(n).RecorNum).TrialStructAdj.JuiceTime])>.1
[CS_spikeNospike(counter).SpikeTrials_N, CS_spikeNospike(counter).SpikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsSpike, n, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[CS_spikeNospike(counter).NospikeTrials_N, CS_spikeNospike(counter).NospikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsNoSpike.', n, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
CS_spikeNospike(counter).NaiveIndex = n;
CS_spikeNospike(counter).JuiceTimes = [RecordingList(Naive(n).RecorNum).TrialStructAdj.JuiceTime];
CS_spikeNospike(counter).MaskFire = TrialsSpike;
CS_spikeNospike(counter).TrialsNoSpike = TrialsNoSpike;
CS_spikeNospike(counter).SumTrialsFire = length(TrialsSpike);
CS_spikeNospike(counter).SumTrialsNoFire = length(TrialsNoSpike);

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

[SS_spikeNospike(counter2).SpikeTrials_N, SS_spikeNospike(counter2).SpikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsSpike, PC_index, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[SS_spikeNospike(counter2).NospikeTrials_N, SS_spikeNospike(counter2).NospikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsNoSpike.', PC_index, Naive, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
SS_spikeNospike(counter2).CS_NaiveIndex = n;
SS_spikeNospike(counter2).SS_NaiveIndex = PC_index;
SS_spikeNospike(counter2).JuiceTimes = [RecordingList(Naive(n).RecorNum).TrialStructAdj.JuiceTime];
SS_spikeNospike(counter2).MaskFire = TrialsSpike;
SS_spikeNospike(counter2).TrialsNoSpike = TrialsNoSpike;
SS_spikeNospike(counter2).SumTrialsFire = length(TrialsSpike);
SS_spikeNospike(counter2).SumTrialsNoFire = length(TrialsNoSpike);
counter2 = counter2 + 1;


%MLI
for k = 1:length(Naive)
    if strcmp({Naive(k).CellType}, 'MLI')
    if Cell2CellDistINDEX(Naive, n, k, MEH_chanMap) < 160
        if Naive(k).RecorNum == Naive(n).RecorNum
        [MLI_spikeNospike(counter3).SpikeTrials_N, MLI_spikeNospike(counter3).SpikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsSpike, k, Naive, -8, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[MLI_spikeNospike(counter3).NospikeTrials_N, MLI_spikeNospike(counter3).NospikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsNoSpike.', k, Naive, -8, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
MLI_spikeNospike(counter3).CS_NaiveIndex = n;
MLI_spikeNospike(counter3).MLI_NaiveIndex = k;
MLI_spikeNospike(counter3).JuiceTimes = [RecordingList(Naive(n).RecorNum).TrialStructAdj.JuiceTime];
MLI_spikeNospike(counter3).MaskFire = TrialsSpike;
MLI_spikeNospike(counter3).TrialsNoSpike = TrialsNoSpike;
MLI_spikeNospike(counter3).SumTrialsFire = length(TrialsSpike);
MLI_spikeNospike(counter3).SumTrialsNoFire = length(TrialsNoSpike);
counter3 = counter3 + 1;
    end
    end
    end
end





end
end
end
figure
hold on
shadedErrorBar2(CS_spikeNospike(1).SpikeTrials_edges(1:end-1),  mean(struct2mat(CS_spikeNospike, 'SpikeTrials_N')), std(struct2mat(CS_spikeNospike, 'SpikeTrials_N'))/sqrt(length(struct2mat(CS_spikeNospike, 'SpikeTrials_N'))), 'lineProp', 'm');
shadedErrorBar2(CS_spikeNospike(1).NospikeTrials_edges(1:end-1), mean(struct2mat(CS_spikeNospike, 'NospikeTrials_N')), std(struct2mat(CS_spikeNospike, 'NospikeTrials_N'))/sqrt(length(struct2mat(CS_spikeNospike, 'NospikeTrials_N'))), 'lineProp', 'b')
figure
hold on
shadedErrorBar2(SS_spikeNospike(1).NospikeTrials_edges(1:end-1),  mean(struct2mat(SS_spikeNospike, 'SpikeTrials_N')), std(struct2mat(SS_spikeNospike, 'SpikeTrials_N'))/sqrt(length(struct2mat(SS_spikeNospike, 'SpikeTrials_N'))), 'lineProp', 'm');
shadedErrorBar2(SS_spikeNospike(1).SpikeTrials_edges(1:end-1), mean(struct2mat(SS_spikeNospike, 'NospikeTrials_N')), std(struct2mat(SS_spikeNospike, 'NospikeTrials_N'))/sqrt(length(struct2mat(SS_spikeNospike, 'NospikeTrials_N'))), 'lineProp', 'b')
figure
hold on
shadedErrorBar2(MLI_spikeNospike(1).NospikeTrials_edges(1:end-1), mean(struct2mat(MLI_spikeNospike, 'NospikeTrials_N')), std(struct2mat(MLI_spikeNospike, 'NospikeTrials_N'))/sqrt(length(struct2mat(MLI_spikeNospike, 'NospikeTrials_N'))), 'lineProp', 'b')
shadedErrorBar2(MLI_spikeNospike(1).NospikeTrials_edges(1:end-1), mean(struct2mat(MLI_spikeNospike, 'SpikeTrials_N')), std(struct2mat(MLI_spikeNospike, 'SpikeTrials_N'))/sqrt(length(struct2mat(MLI_spikeNospike, 'SpikeTrials_N'))), 'lineProp', 'm')