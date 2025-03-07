exist('SS_CS')
exist('SS_unpaired')
exist('CS_unpaired')
exist('MLI_ccg')
exist('MLI_layer')
exist('MF_expert')
exist('Golgi_expert')

SummaryStruct_SS = SummaryStructMakerClassical([SS_CS.SS], 'SS_pause', 'expert', [], 'reward_ACWF', GoodUnitStructSorted, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [SS_CS.CS], AllLicksAdj);
close all
SummaryStruct_SS_nopair = SummaryStructMakerClassical(SS_unpaired, 'SS_noPair', 'expert', [], 'reward_ACWF', GoodUnitStructSorted, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [], AllLicksAdj);
close all
SummaryStruct_CS = SummaryStructMakerClassical([SS_CS.CS], 'CS_pause', 'expert', [], 'reward_ACWF', GoodUnitStructSorted, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [SS_CS.SS], AllLicksAdj);
close all
SummaryStruct_CS_nopair = SummaryStructMakerClassical(CS_unpaired, 'CS_noPair', 'expert', [], 'reward_ACWF', GoodUnitStructSorted, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [], AllLicksAdj);
close all
SummaryStruct_MLI_ccg = SummaryStructMakerClassical(MLI_ccg, 'MLI', 'expert', 'ccg', 'reward_ACWF', GoodUnitStructSorted, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [], AllLicksAdj);
close all
SummaryStruct_MLI_layer = SummaryStructMakerClassical(MLI_layer, 'MLI', 'expert', 'layer', 'reward_ACWF', GoodUnitStructSorted, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [], AllLicksAdj);
close all
SummaryStruct_MF = SummaryStructMakerClassical(MF_expert, 'MF', 'expert', [], 'reward_ACWF', GoodUnitStructSorted, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [], AllLicksAdj);
close all
SummaryStruct_Golgi = SummaryStructMakerClassical(Golgi_expert, 'Golgi', 'expert', [], 'reward_ACWF', GoodUnitStructSorted, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [], AllLicksAdj);
close all
SummaryStruct = [SummaryStruct_SS SummaryStruct_CS SummaryStruct_MLI_ccg SummaryStruct_MLI_layer SummaryStruct_MF SummaryStruct_Golgi SummaryStruct_SS_nopair SummaryStruct_CS_nopair]; 

SummaryStruct_SS = SummaryStructMakerClassical([SS_CS.SS], 'SS_pause', 'expert', [], 'reward_ACWF', AllUnitStruct_Phyllum, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [SS_CS.CS], AllLicksAdj);
SummaryStruct_CS = SummaryStructMakerClassical([SS_CS.CS], 'CS_pause', 'expert', [], 'reward_ACWF', AllUnitStruct_Phyllum, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [SS_CS.SS], AllLicksAdj);
SummaryStruct_MLI_ccg = SummaryStructMakerClassical(uniqueMLIs(1:5), 'MLI', 'expert', 'ccg', 'reward_ACWF', AllUnitStruct_Phyllum, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [], AllLicksAdj);
SummaryStruct_MLI_layer = SummaryStructMakerClassical(uniqueMLIs(6:6), 'MLI', 'expert', 'layer', 'reward_ACWF', AllUnitStruct_Phyllum, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [], AllLicksAdj);
SummaryStruct_Golgi = SummaryStructMakerClassical(Golgi_expert, 'Golgi', 'expert', [], 'reward_ACWF', AllUnitStruct_Phyllum, 1, [0 inf],  MEH_chanMap, TrialStructRTtAdj, [], AllLicksAdj);
SummaryStruct = [SummaryStruct_SS SummaryStruct_CS SummaryStruct_MLI_ccg SummaryStruct_MLI_layer SummaryStruct_MF SummaryStruct_Golgi]; 

for n = 1:length(SummaryStruct_events)
TrialStructAdj = SummaryStruct_events(n).TrialStructAdj;
J = [TrialStructAdj.TrialType].' == 'j';
T = [TrialStructAdj.TrialType].' == 't';
B = [TrialStructAdj.TrialType].' == 'b';
Temp = [TrialStructAdj.JuiceTime].';
JuiceAloneAdj = Temp(J);
JuiceAfterToneAdj = Temp(B);
Temp = [TrialStructAdj.ToneTime].';
ToneAloneAdj = Temp(T);
ToneBeforeJuiceAdj = Temp(B);
SummaryStruct_events(n).JuiceAloneAdj = JuiceAloneAdj;
SummaryStruct_events(n).JuiceAfterToneAdj = JuiceAfterToneAdj;
SummaryStruct_events(n).ToneAloneAdj = ToneAloneAdj;
SummaryStruct_events(n).ToneBeforeJuiceAdj = ToneBeforeJuiceAdj;
[FirstJuiceLicksAdj, FirstJuiceEpochsAdj] = ExtractFirstJuice3(SummaryStruct_events(n).TrialStructAdj, SummaryStruct_events(n).AllLicksAdj);
[NoJuiceLicksAdj, NoJuiceEpochsAdj] = ExtractNoJuice(SummaryStruct_events(n).TrialStructAdj, SummaryStruct_events(n).AllLicksAdj);
EpochOnsetsAdj = FindLickingEpochs(SummaryStruct_events(n).AllLicksAdj);
SummaryStruct_events(n).FirstJuiceLicksAdj = FirstJuiceLicksAdj;
SummaryStruct_events(n).FirstJuiceEpochsAdj = FirstJuiceEpochsAdj;
SummaryStruct_events(n).NoJuiceLicksAdj = NoJuiceLicksAdj;
SummaryStruct_events(n).NoJuiceEpochsAdj =  NoJuiceEpochsAdj;
SummaryStruct_events(n).EpochOnsetsAdj =  EpochOnsetsAdj;
end


