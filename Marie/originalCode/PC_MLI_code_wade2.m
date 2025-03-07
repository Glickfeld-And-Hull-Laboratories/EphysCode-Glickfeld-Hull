for n = 1:length(MLIs)
for k = 1:length(MLIs(n).MLI_PC_Summary)
if isempty([RecordingList(MLIs(n).RecorNum).LaserStimAdj])
[N, edges] = XcorrFastINDEX(SumSt, -.02, .02, binwidth, MLIs(n).MLI_PC_Summary(k).SSindex, MLIs(n).MLI_PC_Summary(k).MLIindex, 0, inf, 'k', 0, SD, 0);
else
[N, edges] = XcorrFastINDEX(SumSt, -.02, .02, binwidth,  MLIs(n).MLI_PC_Summary(k).SSindex, MLIs(n).MLI_PC_Summary(k).MLIindex, 0, RecordingList(MLIs(n).RecorNum).LaserStimAdj(1), 'k', 0, SD, 0);
end
MLIs(n).PC_MLI(k).MLIindex = MLIs(n).MLI_PC_Summary(k).MLIindex;
MLIs(n).PC_MLI(k).SSindex = MLIs(n).MLI_PC_Summary(k).SSindex;
MLIs(n).PC_MLI(k).MLIs_dist = MLIs(n).MLI_PC_Summary(k).MLI_PC_dist;
MLIs(n).PC_MLI(k).N = N;
MLIs(n).PC_MLI(k).edges = edges;

end
end

MLIsA = MLIs(strcmp({MLIs.Type}, 'A'));
MLIsB = MLIs(strcmp({MLIs.Type}, 'B'));
