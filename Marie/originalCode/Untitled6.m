[RTsOneSec, JuiceLicks] =findRT(JuiceLicks);
AllLicks = MakeAllLicks(JuiceLicks);
[JuiceEpochLicks, LicksEpochsOnset] = FindLickingEpochs2(JuiceLicks);
NoJuice = ExtractNoJuice(JuiceLicks);

FirstJuice = ExtractFirstJuice(JuiceLicks);
save FirstLicksEpochs.txt FirstLicksEpochs -ascii -double
save AllLicks.txt AllLicks -ascii -double
save RTsOneSec.txt RTsOneSec -ascii -double
save NoJuice.txt NoJuice -ascii -double
save FirstJuice.txt FirstJuice -ascii -double