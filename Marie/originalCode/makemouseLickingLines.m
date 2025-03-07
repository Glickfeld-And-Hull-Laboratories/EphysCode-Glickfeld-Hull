fid = fopen('1635day1_211105_g0_tcat.nidq.XD_2_1_0.txt');
JuiceTimes = fscanf(fid, '%f');
fclose(fid);

FindLickLevels(JuiceTimes, 5, 5, 5)
[JuiceLicks] = FindLicksStateMach(JuiceTimesAdj, 5, 5, .6, .8);

[RTs, JuiceLicks] = findRT(JuiceLicks);
meanRT = nanmean(RTs)
StErrRT = nanStErr(RTs)

AllLicks = MakeAllLicks(JuiceLicks);
NoJuice = ExtractNoJuice(JuiceLicks);
FirstLicksEpochs = FindLickingEpochs(AllLicks);
FirstJuice = ExtractFirstJuice(JuiceLicks);
save FirstLicksEpochs.txt FirstLicksEpochs -ascii -double
%save JuiceTimes.txt JuiceTimes -ascii -double
save AllLicks.txt AllLicks -ascii -double
save RTs.txt RTs -ascii -double
save NoJuice.txt NoJuice -ascii -double
save FirstJuice.txt FirstJuice -ascii -double

%set training day = n and mouse # and date!
n = 1


mouse1635(n).JuiceLicks = JuiceLicks;
%set date
mouse1635(n).date = 211105;

mouse1635(n).day = n;
mouse1635(n).RTmean = meanRT;
mouse1635(n).RTsterr = StErrRT;
mouse(n).FirstLicksEpochs = FirstLicksEpochs;
mouse1635(n).FirstLicksEpochs = FirstLicksEpochs;
mouse1635(n).AllLicks = AllLicks;
mouse1635(n).FirstJuice = FirstJuice;
mouse1635(n).NoJuice = NoJuice;
mouse1635(n).JuiceTimesAdj = JuiceTimesAdj;