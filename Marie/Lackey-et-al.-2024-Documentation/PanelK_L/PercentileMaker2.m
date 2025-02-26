
bwidth = .1;
reporter = 0;
%MLIsA = rmfield(MLIsA, 'PctileFR');
%MLIsB = rmfield(MLIsB, 'PctileFR');
% percentile times already calculated
for n = 1:length(MLIsA)
for k = 1:length(MLIsA(n).MLI_PC_Summary)
if MLIsA(n).MLI_PC_Summary(k).MLI_PC_dist > 125
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
    if MLIsB(n).MLI_PC_Summary(k).MLI_PC_dist < 125
    MLIsB(n).PctileFR.PCpairs(k).FRateBottom = [];
    MLIsB(n).PctileFR.PCpairs(k).FRateTop = [];
[MLIsB(n).PctileFR.PCpairs(k).FRateBottom, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsB(n).PctileFR.BottomTGA, MLIsB(n).PctileFR.BottomTGB, [0 inf], SumSt, MLIsB(n).MLI_PC_Summary(k).SSindex, 'k', 0, bwidth);
[MLIsB(n).PctileFR.PCpairs(k).FRateTop, ~] = FRstructTimeGridTimeLimitINDEX2(MLIsB(n).PctileFR.TopTGA, MLIsB(n).PctileFR.TopTGB, [0 inf], SumSt,  MLIsB(n).MLI_PC_Summary(k).SSindex, 'k', 0, bwidth);
MLIsB(n).PctileFR.PCpairs(k).indexDrive = MLIsB(n).MLI_PC_Summary(k).MLIindex;
MLIsB(n).PctileFR.PCpairs(k).indexFollow = MLIsB(n).MLI_PC_Summary(k).SSindex;
MLIsB(n).PctileFR.PCpairs(k).MLI_PC_dist = MLIsB(n).MLI_PC_Summary(k).MLI_PC_dist;
end
end
end
