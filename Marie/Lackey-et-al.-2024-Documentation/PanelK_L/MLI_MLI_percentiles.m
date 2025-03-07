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