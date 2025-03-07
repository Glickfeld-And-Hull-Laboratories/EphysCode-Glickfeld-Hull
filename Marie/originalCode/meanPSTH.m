function [N, edges, L1] = meanPSTH(TS1, struct, xmin, xmax, bwidth, timeLim, STDEV, color, plotBoo, indivBoo, Zscore, ZscoreTimeMax)
%struct is already edited for which cells you want
for k = 1:length(struct)
[N(k,:), edges] = OneUnitHistStructTimeLimLineINDEX(TS1, k, struct, xmin, xmax, bwidth, timeLim, STDEV, 'k', NaN, 0, 0);
end

if ~isnan(ZscoreTimeMax)
ZscoreBinMax = find(edges <= ZscoreTimeMax, 1, 'last');
end

if Zscore == 1
    for k = 1:length(struct)
        [N(k,:)] = (N(k,:) - mean(N(k,1:ZscoreBinMax)))/std(N(k,1:ZscoreBinMax));
    end
end

if length(struct) > 0
if plotBoo == 1
    if size(N, 1) > 1
    shadedErrorBar2(edges(1:end-1), mean(N, 1, 'omitnan'), std(N, 1, 'omitnan')/sqrt(k), 'LineProp', color)
    else 
        plot(edges(1:end-1), N(k,:), color);
    end
end
L1 = k;
if indivBoo == 1
    for k = 1:size(N, 1)
    plot(edges(1:end-1), N(k,:), color);
    end
end
N = mean(N,1);
else
    if plotBoo == 1 | indivBoo == 1
        plot(NaN, NaN);
    end
    N = NaN;
    edges = NaN;
    L1 = 0;
end
end
