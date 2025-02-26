[FirstJuiceLicksAdj, FirstJuiceEpochsAdj] = ExtractFirstJuice3(SummaryStruct(n).TrialStruct, SummaryStruct(n).AllLicksAdj);
[NoJuiceLicksAdj, NoJuiceEpochsAdj] = ExtractNoJuice(SummaryStruct(n).TrialStruct, SummaryStruct(n).AllLicksAdj);


OneUnitHistStructTimeLimLineINDEX(FirstJuiceEpochsAdj, index, SummaryStruct, -1, 1, .005, [0 inf], 4, 'm', 'CS FirstJuiceEpoch', 0);
OneUnitHistStructTimeLimLineINDEX(NoJuiceEpochsAdj, index, SummaryStruct, -1, 1, .005, [0 inf], 4, 'r', 'CS NoJuiceEpoch', 0);
OneUnitHistStructTimeLimLineINDEX(NoJuiceEpochsAdj, n, SummaryStruct, -1, 1, .005, [0 inf], 4, 'b', 'SS FirstJuiceEpoch', 0);
OneUnitHistStructTimeLimLineINDEX(FirstJuiceEpochsAdj, n, SummaryStruct, -1, 1, .005, [0 inf], 4, 'k', 'SS NoJuiceEpoch', 0);

saveas(gca, ['unit' num2str(SummaryStruct(n).unitID) 'JuiceNojuiceEpochslong'])
print(['unit' num2str(SummaryStruct(n).unitID) 'JuiceNojuiceEpochslong'], '-dpdf','-painters')