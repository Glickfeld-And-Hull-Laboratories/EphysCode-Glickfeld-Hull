function [N, edges] = FreqLine(N, edges, L1, color, DisplayName, plotBoo)


% [N, edges] = histcounts(useDeltas, 'BinLimits', range, 'Binwidth', bwidth);
% [N, edges] = FreqHist(N, edges, length(TS1), 'k');

bwidth = edges(2)-edges(1);

%
edges = edges(1:(length(edges)-1)); % remove last traiiling edge so sizes of N and edges match)
edges = edges + (.5*bwidth); % shift edges so bars are aligned to left side of each bin.
%N = (N/(L1))*(1/bwidth); % convert bars to firing rates

N = N/(L1*bwidth); % convert bars to firing rates

%hold off
%figure
%hold on
%plot (edges, N, 'color', [.85 .85 .85]); %gray lines
if ~plotBoo == 0
if ~isnan(DisplayName)
    plot (edges, N, 'color', color, 'DisplayName', DisplayName);
legend
else
    plot (edges, N, 'color', color);
end
end



end