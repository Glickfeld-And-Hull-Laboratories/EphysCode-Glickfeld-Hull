for n = 1:6
figure
hold on
OneUnitHistStructTimeLimLineINDEX(rmmissing([SummaryStruct(n).TrialStruct.JuiceTime].'), n, SummaryStruct, -.2, .2, .005, [0 inf], 4, 'b', NaN, 0);
[N, edges] = OneUnitHistStructTimeLimLineINDEX(rmmissing([SummaryStruct(n).TrialStruct.JuiceTime].'), find([SummaryStruct.unitID] == SummaryStruct(n).PCpair), SummaryStruct, -.2, .2, .005, [0 inf], 4, 'k', NaN, 0);
[LatUP, LatDOWN] = RespLatency(N, edges, 3, 2, 0);
xline(LatUP -.005,'k');
FormatFigure
saveas(gca, ['SS_SSunit' num2str(SummaryStruct(n).unitID)])
 print(['SS_SSuunit' num2str(SummaryStruct(n).unitID)], '-dpdf','-painters')
end

figure
hold on
for n = 1:length(SummaryStruct)
TrialStruct = SummaryStruct(n).TrialStruct;
%Trigger = [TrialStruct(find([SummaryStruct(n).TrialStruct.TrialType].' == 't')).ToneTime].';
Trigger = rmmissing([SummaryStruct(n).TrialStruct.JuiceTime].');
if strcmp(SummaryStruct(n).handID, 'SS_pause')
OneUnitHistStructTimeLimLineINDEX(Trigger, n, SummaryStruct, -.2, .2, .005, [0 inf], 4, 'b', NaN, 0);
end
if strcmp(SummaryStruct(n).handID, 'SS_noPair')
OneUnitHistStructTimeLimLineINDEX(Trigger, n, SummaryStruct, -.2, .2, .005, [0 inf], 4, 'k', NaN, 0);
end
FormatFigure
title('SS response to JuiceAdj')
saveas(gca, ['SS_Juice'])
 print(['SS_Juice'], '-dpdf','-painters')
end
