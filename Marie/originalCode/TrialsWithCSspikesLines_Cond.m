clear CS_spikeNospike_cond
clear SS_spikeNospike_cond
clear MLI_spikeNospike_cond
counter = 1;
counter2 = 1;
counter3 = 1;
for n = 1:length(Conditioned)
if strcmp({Conditioned(n).handID}, 'CS_pause')
[~, MaskFire] = TrialsWithSpike(n, Conditioned, [RecordingList(Conditioned(n).RecorNum).ToneBeforeJuiceAdj], [.08 .22]);
%[TrialsSpike, MaskFire] = TrialsWithSpike(n, Conditioned, [RecordingList(Conditioned(n).RecorNum).ToneBeforeJuiceAdj], [.69 .82]);
ToneTimes = [RecordingList(Conditioned(n).RecorNum).ToneBeforeJuiceAdj].';
TrialsNoSpike = ToneTimes(logical(abs(MaskFire)-1));
TrialsSpike = ToneTimes(logical((MaskFire)));
if length(TrialsSpike)/length([RecordingList(Conditioned(n).RecorNum).TrialStructAdj.JuiceTime])>.1
[CS_spikeNospike_cond(counter).SpikeTrials_N, CS_spikeNospike_cond(counter).SpikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsSpike.', n, Conditioned, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[CS_spikeNospike_cond(counter).NospikeTrials_N, CS_spikeNospike_cond(counter).NospikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsNoSpike.', n, Conditioned, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[CS_spikeNospike_cond(counter).AllTrials_N, CS_spikeNospike_cond(counter).AllTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(ToneTimes.', n, Conditioned, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);

CS_spikeNospike_cond(counter).ConditionedIndex = n;
CS_spikeNospike_cond(counter).JuiceTimes = [RecordingList(Conditioned(n).RecorNum).TrialStructAdj.JuiceTime];
CS_spikeNospike_cond(counter).MaskFire = TrialsSpike;
CS_spikeNospike_cond(counter).TrialsNoSpike = TrialsNoSpike;
CS_spikeNospike_cond(counter).SumTrialsFire = length(TrialsSpike);
CS_spikeNospike_cond(counter).SumTrialsNoFire = length(TrialsNoSpike);
CS_spikeNospike_cond(counter).AllTrials = length(ToneTimes);
if CS_spikeNospike_cond(counter).SumTrialsFire + CS_spikeNospike_cond(counter).SumTrialsNoFire ~= CS_spikeNospike_cond(counter).AllTrials 
    n
    counter
end
CS_spikeNospike_cond(counter).RecorNum = Conditioned(n).RecorNum;
CS_spikeNospike_cond(counter).channel= Conditioned(n).channel;


for k = 1:length(Conditioned)
    if strcmp({Conditioned(n).handID}, 'CS_pause')
        if k ~= n
    if Cell2CellDistINDEX(Conditioned, n, k, MEH_chanMap) < 160
    end
        end
    end
end



counter = counter + 1;

%SS
PC_unitID = Conditioned(n).PCpair;
for pc = 1:length(Conditioned)
if Conditioned(pc).unitID == PC_unitID
if Conditioned(pc).RecorNum == Conditioned(n).RecorNum
PC_index = pc;
end
end
end

[SS_spikeNospike_cond(counter2).SpikeTrials_N, SS_spikeNospike_cond(counter2).SpikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsSpike, PC_index, Conditioned, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[SS_spikeNospike_cond(counter2).NospikeTrials_N, SS_spikeNospike_cond(counter2).NospikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsNoSpike.', PC_index, Conditioned, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[SS_spikeNospike_cond(counter2).AllTrials_N, SS_spikeNospike_cond(counter2).AllTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX([RecordingList(Conditioned(n).RecorNum).ToneBeforeJuiceAdj], PC_index, Conditioned, -.5, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
SS_spikeNospike_cond(counter2).CS_ConditionedIndex = n;
SS_spikeNospike_cond(counter2).SS_ConditionedIndex = PC_index;
SS_spikeNospike_cond(counter2).JuiceTimes = [RecordingList(Conditioned(n).RecorNum).TrialStructAdj.JuiceTime];
SS_spikeNospike_cond(counter2).MaskFire = TrialsSpike;
SS_spikeNospike_cond(counter2).TrialsNoSpike = TrialsNoSpike;
SS_spikeNospike_cond(counter2).SumTrialsFire = length(TrialsSpike);
SS_spikeNospike_cond(counter2).SumTrialsNoFire = length(TrialsNoSpike);
counter2 = counter2 + 1;


%MLI
for k = 1:length(Conditioned)
    if strcmp({Conditioned(k).CellType}, 'MLI')
    if Cell2CellDistINDEX(Conditioned, n, k, MEH_chanMap) < 160
        if Conditioned(k).RecorNum == Conditioned(n).RecorNum
        [MLI_spikeNospike_cond(counter3).SpikeTrials_N, MLI_spikeNospike_cond(counter3).SpikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsSpike, k, Conditioned, -8, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[MLI_spikeNospike_cond(counter3).NospikeTrials_N, MLI_spikeNospike_cond(counter3).NospikeTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX(TrialsNoSpike.', k, Conditioned, -8, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);
[MLI_spikeNospike_cond(counter3).AllTrials_N, MLI_spikeNospike_cond(counter3).AllTrials_edges, ~] = OneUnitHistStructTimeLimLineINDEX([RecordingList(Conditioned(n).RecorNum).ToneBeforeJuiceAdj], k, Conditioned, -8, 2.2, .01, [0 inf], 4,'k', NaN, 0, 0);

MLI_spikeNospike_cond(counter3).CS_ConditionedIndex = n;
MLI_spikeNospike_cond(counter3).MLI_ConditionedIndex = k;
MLI_spikeNospike_cond(counter3).JuiceTimes = [RecordingList(Conditioned(n).RecorNum).TrialStructAdj.JuiceTime];
MLI_spikeNospike_cond(counter3).MaskFire = TrialsSpike;
MLI_spikeNospike_cond(counter3).TrialsNoSpike = TrialsNoSpike;
MLI_spikeNospike_cond(counter3).SumTrialsFire = length(TrialsSpike);
MLI_spikeNospike_cond(counter3).SumTrialsNoFire = length(TrialsNoSpike);
MLI_spikeNospike_cond(counter3).AllTrials = [RecordingList(Conditioned(n).RecorNum).ToneBeforeJuiceAdj];
MLI_spikeNospike_cond(counter3).SumAllTrials = length([RecordingList(Conditioned(n).RecorNum).ToneBeforeJuiceAdj]);

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
shadedErrorBar2(CS_spikeNospike_cond(1).SpikeTrials_edges(1:end-1),  mean(struct2mat(CS_spikeNospike_cond, 'SpikeTrials_N')), std(struct2mat(CS_spikeNospike_cond, 'SpikeTrials_N'))/sqrt(length(struct2mat(CS_spikeNospike_cond, 'SpikeTrials_N'))), 'lineProp', 'm');
shadedErrorBar2(CS_spikeNospike_cond(1).NospikeTrials_edges(1:end-1), mean(struct2mat(CS_spikeNospike_cond, 'NospikeTrials_N')), std(struct2mat(CS_spikeNospike_cond, 'NospikeTrials_N'))/sqrt(length(struct2mat(CS_spikeNospike_cond, 'NospikeTrials_N'))), 'lineProp', 'b')
shadedErrorBar2(CS_spikeNospike_cond(1).AllTrials_edges(1:end-1), mean(struct2mat(CS_spikeNospike_cond, 'AllTrials_N')), std(struct2mat(CS_spikeNospike_cond, 'AllTrials_N'))/sqrt(length(struct2mat(CS_spikeNospike_cond, 'AllTrials_N'))), 'lineProp', 'k')
figure
hold on
shadedErrorBar2(SS_spikeNospike_cond(1).NospikeTrials_edges(1:end-1),  mean(struct2mat(SS_spikeNospike_cond, 'SpikeTrials_N')), std(struct2mat(SS_spikeNospike_cond, 'SpikeTrials_N'))/sqrt(length(struct2mat(SS_spikeNospike_cond, 'SpikeTrials_N'))), 'lineProp', 'm');
shadedErrorBar2(SS_spikeNospike_cond(1).SpikeTrials_edges(1:end-1), mean(struct2mat(SS_spikeNospike_cond, 'NospikeTrials_N')), std(struct2mat(SS_spikeNospike_cond, 'NospikeTrials_N'))/sqrt(length(struct2mat(SS_spikeNospike_cond, 'NospikeTrials_N'))), 'lineProp', 'b')
shadedErrorBar2(SS_spikeNospike_cond(1).AllTrials_edges(1:end-1), mean(struct2mat(SS_spikeNospike_cond, 'AllTrials_N')), std(struct2mat(SS_spikeNospike_cond, 'AllTrials_N'))/sqrt(length(struct2mat(SS_spikeNospike_cond, 'AllTrials_N'))), 'lineProp', 'k')
figure
hold on
shadedErrorBar2(MLI_spikeNospike_cond(1).NospikeTrials_edges(1:end-1), mean(struct2mat(MLI_spikeNospike_cond, 'NospikeTrials_N')), std(struct2mat(MLI_spikeNospike_cond, 'NospikeTrials_N'))/sqrt(length(struct2mat(MLI_spikeNospike_cond, 'NospikeTrials_N'))), 'lineProp', 'b')
shadedErrorBar2(MLI_spikeNospike_cond(1).NospikeTrials_edges(1:end-1), mean(struct2mat(MLI_spikeNospike_cond, 'SpikeTrials_N')), std(struct2mat(MLI_spikeNospike_cond, 'SpikeTrials_N'))/sqrt(length(struct2mat(MLI_spikeNospike_cond, 'SpikeTrials_N'))), 'lineProp', 'm')
shadedErrorBar2(MLI_spikeNospike_cond(1).AllTrials_edges(1:end-1), mean(struct2mat(MLI_spikeNospike_cond, 'AllTrials_N')), std(struct2mat(MLI_spikeNospike_cond, 'AllTrials_N'))/sqrt(length(struct2mat(MLI_spikeNospike_cond, 'AllTrials_N'))), 'lineProp', 'k')