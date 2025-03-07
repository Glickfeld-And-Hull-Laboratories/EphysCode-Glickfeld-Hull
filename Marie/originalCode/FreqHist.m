function [N, edges] = FreqHist(N, edges, L1, color, FaceAlpha, plotboo)

% call like this
% [N, edges] = histcounts(useDeltas, 'BinLimits', range, 'Binwidth', bwidth);
% FreqHist(N, edges, length(TS1), 'k');

bwidth = edges(2)-edges(1);
%N = N/2; %because we count each section twice, once before the trigger/TS1 and once after
N = (N/(L1))*(1/bwidth); % convert bars to firing rates
%length(N)
%length(edges)
edges = edges(1:(length(edges)-1)); % remove last traiiling edge so sizes of N and edges match)
edges = edges + (.5*bwidth); % shift edges so bars are aligned to left side of each bin.

%hold off
%figure
%hold on
if plotboo == 1
bar (edges, N, 1, color, 'FaceAlpha', FaceAlpha);
end


end