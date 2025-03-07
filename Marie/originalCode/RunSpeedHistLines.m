function [Nmean, Nedges, N] = RunSpeedHistLines(Trigger, SpeedTimesAdj, SpeedValues, xmin, xmax)
%function [N] = RunSpeedHistLines(Trigger, SpeedTimesAdj, SpeedValues, xmin, xmax, bins)
%bins = range/.1 (or speedTimesAdj step size)
if ~isempty(SpeedTimesAdj)
bins = round((xmax - xmin)/(SpeedTimesAdj(2)-SpeedTimesAdj(1)));
for n = 1:length(Trigger)
    index = find([SpeedTimesAdj] > (Trigger(n) + xmin), 1);
    if index+bins <= length(SpeedValues)
    N(n,:).values = SpeedValues(index:index+bins).';
    end    
end
Nmean = mean(cell2mat({N.values}), 2);
Nedges = [xmin:(SpeedTimesAdj(2)-SpeedTimesAdj(1)):xmax];
%plot(Nedges.', Nmean);
else
   Nmean = [];
   Nedges = [];
   N = [];
end
end
    
    