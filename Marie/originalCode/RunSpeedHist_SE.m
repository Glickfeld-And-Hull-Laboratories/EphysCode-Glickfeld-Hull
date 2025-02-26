function [Nmean, Nedges, N, N_se] = RunSpeedHist_SE(Trigger, SpeedTimesAdj, SpeedValues, xmin, xmax)
bins = (xmax - xmin)/(SpeedTimesAdj(2)-SpeedTimesAdj(1)); %make bins that are the size of samples of speedtimes

for n = 1:length(Trigger)
    index = find([SpeedTimesAdj] > (Trigger(n) + xmin), 1);
    if index+bins <= length(SpeedValues)
    N(:,n).values = SpeedValues(index:index+bins);
    end
        
end
Nmean = mean(cell2mat({N.values}.'));
if length(Nmean) == 1
    Nmean = cell2mat({N.values}.');
end

Nedges = [xmin:(SpeedTimesAdj(2)-SpeedTimesAdj(1)):xmax];

N_sd = std(cell2mat({N.values}.'), 0, 1);
N_se = N_sd/sqrt(size(cell2mat({N.values}.'), 2));

%plot(Nedges.', Nmean);
end
    
    