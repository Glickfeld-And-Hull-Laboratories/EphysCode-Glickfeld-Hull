
function [mod] = ModMean(StDevLim, N, edges, SD, AccRespWindow)
%function [LatLow, LatHigh] = LatencyMod(StDevLim, N, edges, SD, minRespLat)
minRespLat = AccRespWindow(1);
maxRespLat = AccRespWindow(2);


 % baseline Stdev & mean
index0 = find(edges >= StDevLim)-1;
Prestim = N(1:index0);
stdevLine = std(Prestim);
meanLine = mean(Prestim);
EvalLimitHigh = meanLine + SD*stdevLine;
EvalLimitLow = meanLine - SD*stdevLine;

index1 = find(edges <= AccRespWindow(1));
index2 = find(edges >= AccRespWindow(2));
EvalWindow = N(index1:index2);
EvalMean = mean(EvalWindow);

if EvalMean > EvalLimitHigh
    mod = 1;
elseif EvalMean < EvalLimitLow
    mod = -1;
else
    mod = NaN;
end
end
