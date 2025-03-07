cB = 1;
cA = 1;
clear testerA_near testerB_near
figure
title ('near PC')
for n = 1:length(MLIsA)
%if MLIsA(n).PctileFR.BottomMean ==0
%reporter = reporter +1;
%end
for k = 1:length(MLIsA(n).MLI_PC_Summary)
if MLIsA(n).MLI_PC_Summary(k).MLI_PC_dist < 125
hold on
scatter(2, [MLIsA(n).PctileFR.PCpairs(k).FRateTop - MLIsA(n).PctileFR.PCpairs(k).FRateBottom],50, 'k', 'filled');
testerA_near(cA) = [MLIsA(n).PctileFR.PCpairs(k).FRateTop - MLIsA(n).PctileFR.PCpairs(k).FRateBottom];
cA = cA + 1;
end
end
end
for n = 1:length(MLIsB)
%if MLIsB(n).PctileFR.BottomMean ==0
%reporter = reporter +1;
%end
for k = 1:length(MLIsB(n).MLI_PC_Summary)
if MLIsB(n).MLI_PC_Summary(k).MLI_PC_dist < 125
scatter(4, [MLIsB(n).PctileFR.PCpairs(k).FRateTop - MLIsB(n).PctileFR.PCpairs(k).FRateBottom],50, 'k', 'filled');
testerB_near(cB) = [MLIsB(n).PctileFR.PCpairs(k).FRateTop - MLIsB(n).PctileFR.PCpairs(k).FRateBottom];
cB = cB + 1;
end
end
end
xlim([1, 5]);
yline(0, 'k')
[p, h] = ranksum(testerA_near, testerB_near);
text(2.5,1.6, ['p = ' num2str(p)])
errorbar([4], [nanmean(testerB_near)], [nanstd(testerB_near)/sqrt(length(testerB_near))], 'r');
errorbar([2], [nanmean(testerA_near)], [nanstd(testerA_near)/sqrt(length(testerA_near))], 'r');