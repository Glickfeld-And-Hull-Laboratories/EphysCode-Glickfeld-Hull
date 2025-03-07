function [LatUP, LatDOWN] = RespLatency(N, edges, STDEV, ConsBins, cutoff)
% 0 = down, 1 = up
% STDEV = n*stdev to use
%N is in FR
%ConsBins is how many consecutive bins above/below STDEV
%cutoff is 0, before which we are using activity to calculate baseline

LatUP = NaN;
LatDOWN = NaN;
bwidth = edges(2)-edges(1);
%N = (N/L1)*(1/bwidth); % convert bars to firing rates
edges = edges(1:(length(edges)-1)); % remove last traiiling edge so sizes of N and edges match)
edges = edges + (.5*bwidth); % shift edges so bars are aligned to left side of each bin.
index0 = find(edges >= cutoff, 1);

[meanLine, stdevLine] = StDevLine(N, edges, cutoff);

Cross = find(N(index0:end)>(meanLine + STDEV*stdevLine));
for n = 1:(length(Cross)-ConsBins+1)
        if Cross(n+ConsBins-1) == Cross(n)+ConsBins-1
            LatUP = edges(Cross(n)+index0-1);
            break
        end
end

if (meanLine - STDEV*stdevLine) >0
Cross = find(N(index0:end)<(meanLine - STDEV*stdevLine));
for n = 1:(length(Cross)-ConsBins+1)
        if Cross(n+ConsBins-1) == Cross(n)+ConsBins-1
            LatDOWN = edges(Cross(n)+index0-1);
            break
        end
end
end

end
        
    

