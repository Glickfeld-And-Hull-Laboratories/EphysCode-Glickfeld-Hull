bwidth = .1;
reporter = 0;
%MLIsB = rmfield(MLIsB, 'PctileFR');
%MLIsB = rmfield(MLIsB, 'PctileFR');

for n = 1:length(MLIsB)
[N, edges] = FrByBin(MLIsB, bwidth, n, NaN, NaN, 0, inf) ;
Bottom = N(N<=prctile(N,10));
Top = N(N>=prctile(N,90));
%N = N(N>0);
%edges = edges(N>0);
MLIsB(n).PctileFR.BottomTGA= edges(N<=prctile(N,10));
if length(MLIsB(n).PctileFR.BottomTGA)>length(N)/10
MLIsB(n).PctileFR.BottomTGA = randsample([MLIsB(n).PctileFR.BottomTGA], round(length(N)/10));
end
MLIsB(n).PctileFR.BottomTGB = MLIsB(n).PctileFR.BottomTGA + bwidth;

MLIsB(n).PctileFR.TopTGA = edges(N>=prctile(N,90));
if length(MLIsB(n).PctileFR.TopTGA)>length(N)/10
MLIsB(n).PctileFR.TopTGA = randsample([MLIsB(n).PctileFR.TopTGA], round(length(N)/10));
end
MLIsB(n).PctileFR.TopTGB = MLIsB(n).PctileFR.TopTGA + bwidth;
MLIsB(n).PctileFR.BottomMean = mean(Bottom);
MLIsB(n).PctileFR.TopMean = mean(Top);

for k = 1:length(MLIsB(n).MLI_PC_Summary)
    MLIsB(n).PctileFR.PCpairs(k).FRateBottom = [];
        MLIsB(n).PctileFR.PCpairs(k).FRateTop = [];
[MLIsB(n).PctileFR.PCpairs(k).FRateBottom, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsB(n).PctileFR.BottomTGA, MLIsB(n).PctileFR.BottomTGB, [0 MLIsB(n).TimeLimit(2)], SumSt, MLIsB(n).MLI_PC_Summary(k).SSindex, 'k', 0, bwidth);
[MLIsB(n).PctileFR.PCpairs(k).FRateTop, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsB(n).PctileFR.TopTGA, MLIsB(n).PctileFR.TopTGB, [0 MLIsB(n).TimeLimit(2)], SumSt,  MLIsB(n).MLI_PC_Summary(k).SSindex, 'k', 0, bwidth);
MLIsB(n).PctileFR.PCpairs(k).indexDrive = MLIsB(n).MLI_PC_Summary(k).MLIindex;
MLIsB(n).PctileFR.PCpairs(k).indexFollow = MLIsB(n).MLI_PC_Summary(k).SSindex;
MLIsB(n).PctileFR.PCpairs(k).MLI_PC_dist = MLIsB(n).MLI_PC_Summary(k).MLI_PC_dist;
end

for k = 1:length(MLIsB(n).MLI_MLI_InhSummary)
    MLIsB(n).PctileFR.MLIpairs(k).FRateBottom = [];
        MLIsB(n).PctileFR.MLIpairs(k).FRateTop = [];
[MLIsB(n).PctileFR.MLIpairs(k).FRateBottom, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsB(n).PctileFR.BottomTGA, MLIsB(n).PctileFR.BottomTGB, [0 MLIsB(n).TimeLimit(2)], SumSt, MLIsB(n).MLI_MLI_InhSummary(k).indexFollow, 'k', 0, bwidth);
[MLIsB(n).PctileFR.MLIpairs(k).FRateTop, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsB(n).PctileFR.TopTGA, MLIsB(n).PctileFR.TopTGB, [0 MLIsB(n).TimeLimit(2)], SumSt,  MLIsB(n).MLI_MLI_InhSummary(k).indexFollow, 'k', 0, bwidth);
MLIsB(n).PctileFR.MLIpairs(k).indexDrive = MLIsB(n).MLI_MLI_InhSummary(k).indexDrive;
MLIsB(n).PctileFR.MLIpairs(k).indexFollow = MLIsB(n).MLI_MLI_InhSummary(k).indexFollow;
MLIsB(n).PctileFR.MLIpairs(k).MLI_MLI_dist = MLIsB(n).MLI_MLI_InhSummary(k).MLI_MLI_dist;
end

end


for n = 1:length(MLIsA)
[N, edges] = FrByBin(MLIsA, bwidth, n, NaN, NaN, 0, inf) ;
Bottom = N(N<=prctile(N,10));
Top = N(N>=prctile(N,90));
%N = N(N>0);
%edges = edges(N>0);
MLIsA(n).PctileFR.BottomTGA= edges(N<=prctile(N,10));
if length(MLIsA(n).PctileFR.BottomTGA)>length(N)/10
MLIsA(n).PctileFR.BottomTGA = randsample([MLIsA(n).PctileFR.BottomTGA], round(length(N)/10));
end
MLIsA(n).PctileFR.BottomTGB = MLIsA(n).PctileFR.BottomTGA + bwidth;

MLIsA(n).PctileFR.TopTGA = edges(N>=prctile(N,90));
if length(MLIsA(n).PctileFR.TopTGA)>length(N)/10
MLIsA(n).PctileFR.TopTGA = randsample([MLIsA(n).PctileFR.TopTGA], round(length(N)/10));
end
MLIsA(n).PctileFR.TopTGB = MLIsA(n).PctileFR.TopTGA + bwidth;
MLIsA(n).PctileFR.BottomMean = mean(Bottom);
MLIsA(n).PctileFR.TopMean = mean(Top);

for k = 1:length(MLIsA(n).MLI_PC_Summary)
    MLIsA(n).PctileFR.PCpairs(k).FRateBottom = [];
        MLIsA(n).PctileFR.PCpairs(k).FRateTop = [];
[MLIsA(n).PctileFR.PCpairs(k).FRateBottom, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsA(n).PctileFR.BottomTGA, MLIsA(n).PctileFR.BottomTGB, [0 MLIsA(n).TimeLimit(2)], SumSt, MLIsA(n).MLI_PC_Summary(k).SSindex, 'k', 0, bwidth);
[MLIsA(n).PctileFR.PCpairs(k).FRateTop, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsA(n).PctileFR.TopTGA, MLIsA(n).PctileFR.TopTGB, [0 MLIsA(n).TimeLimit(2)], SumSt,  MLIsA(n).MLI_PC_Summary(k).SSindex, 'k', 0, bwidth);
MLIsA(n).PctileFR.PCpairs(k).indexDrive = MLIsA(n).MLI_PC_Summary(k).MLIindex;
MLIsA(n).PctileFR.PCpairs(k).indexFollow = MLIsA(n).MLI_PC_Summary(k).SSindex;
MLIsA(n).PctileFR.PCpairs(k).MLI_PC_dist = MLIsA(n).MLI_PC_Summary(k).MLI_PC_dist;
end

for k = 1:length(MLIsA(n).MLI_MLI_InhSummary)
    MLIsA(n).PctileFR.MLIpairs(k).FRateBottom = [];
        MLIsA(n).PctileFR.MLIpairs(k).FRateTop = [];
[MLIsA(n).PctileFR.MLIpairs(k).FRateBottom, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsA(n).PctileFR.BottomTGA, MLIsA(n).PctileFR.BottomTGB, [0 MLIsA(n).TimeLimit(2)], SumSt, MLIsA(n).MLI_MLI_InhSummary(k).indexFollow, 'k', 0, bwidth);
[MLIsA(n).PctileFR.MLIpairs(k).FRateTop, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsA(n).PctileFR.TopTGA, MLIsA(n).PctileFR.TopTGB, [0 MLIsA(n).TimeLimit(2)], SumSt,  MLIsA(n).MLI_MLI_InhSummary(k).indexFollow, 'k', 0, bwidth);
MLIsA(n).PctileFR.MLIpairs(k).indexDrive = MLIsA(n).MLI_MLI_InhSummary(k).indexDrive;
MLIsA(n).PctileFR.MLIpairs(k).indexFollow = MLIsA(n).MLI_MLI_InhSummary(k).indexFollow;
MLIsA(n).PctileFR.MLIpairs(k).MLI_MLI_dist = MLIsA(n).MLI_MLI_InhSummary(k).MLI_MLI_dist;
end

end













bwidth = .1;
reporter = 0;
%MLIsA = rmfield(MLIsA, 'PctileFR');
%MLIsB = rmfield(MLIsB, 'PctileFR');
% percentile times already calculated
for n = 1:length(MLIsA)
for k = 1:length(MLIsA(n).MLI_PC_Summary)
if MLIsA(n).MLI_PC_Summary(k).MLI_PC_dist < 125
    MLIsA(n).PctileFR.PCpairs(k).FRateBottom = [];
        MLIsA(n).PctileFR.PCpairs(k).FRateTop = [];
[MLIsA(n).PctileFR.PCpairs(k).FRateBottom, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsA(n).PctileFR.BottomTGA, MLIsA(n).PctileFR.BottomTGB, [0 inf], SumSt, MLIsA(n).MLI_PC_Summary(k).SSindex, 'k', 0, bwidth);
[MLIsA(n).PctileFR.PCpairs(k).FRateTop, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsA(n).PctileFR.TopTGA, MLIsA(n).PctileFR.TopTGB, [0 inf], SumSt,  MLIsA(n).MLI_PC_Summary(k).SSindex, 'k', 0, bwidth);
MLIsA(n).PctileFR.PCpairs(k).indexDrive = MLIsA(n).MLI_PC_Summary(k).MLIindex;
MLIsA(n).PctileFR.PCpairs(k).indexFollow = MLIsA(n).MLI_PC_Summary(k).SSindex;
MLIsA(n).PctileFR.PCpairs(k).MLI_PC_dist = MLIsA(n).MLI_PC_Summary(k).MLI_PC_dist;
end
end
end
for n = 1:length(MLIsB)
for k = 1:length(MLIsB(n).MLI_PC_Summary)
    MLIsB(n).PctileFR.PCpairs(k).FRateBottom = [];
    MLIsB(n).PctileFR.PCpairs(k).FRateTop = [];
if MLIsB(n).MLI_PC_Summary(k).MLI_PC_dist < 125
[MLIsB(n).PctileFR.PCpairs(k).FRateBottom, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsB(n).PctileFR.BottomTGA, MLIsB(n).PctileFR.BottomTGB, [0 inf], SumSt, MLIsB(n).MLI_PC_Summary(k).SSindex, 'k', 0, bwidth);
[MLIsB(n).PctileFR.PCpairs(k).FRateTop, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsB(n).PctileFR.TopTGA, MLIsB(n).PctileFR.TopTGB, [0 inf], SumSt,  MLIsB(n).MLI_PC_Summary(k).SSindex, 'k', 0, bwidth);
MLIsB(n).PctileFR.PCpairs(k).indexDrive = MLIsB(n).MLI_PC_Summary(k).MLIindex;
MLIsB(n).PctileFR.PCpairs(k).indexFollow = MLIsB(n).MLI_PC_Summary(k).SSindex;
MLIsB(n).PctileFR.PCpairs(k).MLI_PC_dist = MLIsB(n).MLI_PC_Summary(k).MLI_PC_dist;
end
end
end
cB = 1;
cA = 1;
clear testerA testerB
figure
for n = 1:length(MLIsA)
if MLIsA(n).PctileFR.BottomMean ==0
reporter = reporter +1;
end
for k = 1:length(MLIsA(n).MLI_PC_Summary)
if MLIsA(n).MLI_PC_Summary(k).MLI_PC_dist < 125
hold on
scatter(2, [MLIsA(n).PctileFR.PCpairs(k).FRateTop - MLIsA(n).PctileFR.PCpairs(k).FRateBottom],50, 'k', 'filled');
testerA(cA) = [MLIsA(n).PctileFR.PCpairs(k).FRateTop - MLIsA(n).PctileFR.PCpairs(k).FRateBottom];
cA = cA + 1;
end
end
end
for n = 1:length(MLIsB)
if MLIsB(n).PctileFR.BottomMean ==0
reporter = reporter +1;
end
for k = 1:length(MLIsB(n).MLI_PC_Summary)
if MLIsB(n).MLI_PC_Summary(k).MLI_PC_dist < 125
scatter(4, [MLIsB(n).PctileFR.PCpairs(k).FRateTop - MLIsB(n).PctileFR.PCpairs(k).FRateBottom],50, 'k', 'filled');
testerB(cB) = [MLIsB(n).PctileFR.PCpairs(k).FRateTop - MLIsB(n).PctileFR.PCpairs(k).FRateBottom];
cB = cB + 1;
end
end
end
xlim([1, 5]);
yline(0, 'k')
[p, h] = ranksum(testerA, testerB);
text(2.5,1.6, ['p = ' num2str(p)])
errorbar([4], [nanmean(testerB)], [nanstd(testerB)/sqrt(length(testerB))], 'r');
errorbar([2], [nanmean(testerA)], [nanstd(testerA)/sqrt(length(testerA))], 'r');
