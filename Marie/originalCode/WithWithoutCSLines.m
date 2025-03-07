n
index = find([SumSt.unitID] == SumSt(n).PCpair)
[Trial1, Trial2] = TrialDivide([SumSt(n).TrialStruct.JuiceTime].', SumSt(index).timestamps, .02, .065, NaN, NaN);
figure
hold on
OneUnitHistStructTimeLimLineINDEX(Trial1, index, SumSt, -.2, .2, .005, [0 inf], 4, 'm', 'CS CStrials', 0);
OneUnitHistStructTimeLimLineINDEX(Trial2, index, SumSt, -.2, .2, .005, [0 inf], 4, 'r', 'CS noCStrials', 0);
OneUnitHistStructTimeLimLineINDEX(Trial2, n, SumSt, -.2, .2, .005, [0 inf], 4, 'b', 'SS noCStrials', 0);
OneUnitHistStructTimeLimLineINDEX(Trial1, n, SumSt, -.2, .2, .005, [0 inf], 4, 'k', 'SS CStrials', 0);
saveas(gca, ['unit' num2str(SumSt(n).unitID) 'WithWithoutCStrials'])
print(['unit' num2str(SumSt(n).unitID) 'WithWithoutCStrials'], '-dpdf','-painters')