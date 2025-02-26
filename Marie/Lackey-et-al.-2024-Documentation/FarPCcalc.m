cB = 1;
cA = 1;
clear testerA_far testerB_far
%figure
title('far pc')
for n = 1:length(MLIsA)
%if MLIsA(n).PctileFR.BottomMean ==0
%reporter = reporter +1;
%end
for k = 1:length(MLIsA(n).MLI_PC_Summary)
if MLIsA(n).MLI_PC_Summary(k).MLI_PC_dist > 125
hold on
scatter(6, [MLIsA(n).PctileFR.PCpairs(k).FRateTop - MLIsA(n).PctileFR.PCpairs(k).FRateBottom],50, 'k', 'filled');
testerA_far(cA) = [MLIsA(n).PctileFR.PCpairs(k).FRateTop - MLIsA(n).PctileFR.PCpairs(k).FRateBottom];
cA = cA + 1;
end
end
end
for n = 1:length(MLIsB)
%if MLIsB(n).PctileFR.BottomMean ==0
%reporter = reporter +1;
%end
for k = 1:length(MLIsB(n).MLI_PC_Summary)
if MLIsB(n).MLI_PC_Summary(k).MLI_PC_dist > 125
scatter(8, [MLIsB(n).PctileFR.PCpairs(k).FRateTop - MLIsB(n).PctileFR.PCpairs(k).FRateBottom],50, 'k', 'filled');
testerB_far(cB) = [MLIsB(n).PctileFR.PCpairs(k).FRateTop - MLIsB(n).PctileFR.PCpairs(k).FRateBottom];
cB = cB + 1;
end
end
end
xlim([1, 5]);
yline(0, 'k')
[p, h] = ranksum(testerA_far, testerB_far);
text(2.5,1.6, ['p = ' num2str(p)])
errorbar([8], [nanmean(testerB_far)], [nanstd(testerB_far)/sqrt(length(testerB_far))], 'r');
errorbar([6], [nanmean(testerA_far)], [nanstd(testerA_far)/sqrt(length(testerA_far))], 'r');