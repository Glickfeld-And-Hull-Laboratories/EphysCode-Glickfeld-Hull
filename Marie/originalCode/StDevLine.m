function [meanLine, stdevLine] = StDevLine(N, edges, cutoff)
%if you want to do mean/st all the way to the trigger, cutoff = 0, otherwise set cutoff= some bin value before zero;
index0 = find(edges >= cutoff)-1;

Prestim = N(1:index0(1));

stdevLine = std(Prestim);
meanLine = mean(Prestim);


end
