% go to folder of interest!!!  & set these variables

function [N_se, edges, N_mean, N] = LickHist_SE(JuiceTimes, LickTimes, range, bwidth)

xmin = range(1);                     % designate x-axis range in sec, xmin should be negative
xmax = range(2);
trange = abs(xmin);
if trange < xmax
    trange = xmax;
end

L1 = (length(JuiceTimes));                           % L = number of spikes
L2 = (length(LickTimes));


k = 1;                                              %create counter for output vector index
for j = 1:L1                                          % for every element in the first spiketime vector (JuicTimes)
    state = 0;                                      % will check if there are any spikes for this trigger
    k = 1;
    for i=1:L2                                      % for every element in the second (or mirror) spiketime vector (LickTimes)
       test = LickTimes(i,:)- JuiceTimes(j,:);             % get difference between spiketimes
       if ((test <= trange) & (test >= -trange))    % Check if difference is in histogram range
           useDeltas{k,j} = test;                  % If yes, add difference to vector that will create histogram
           k = k+1;                                 % update index
           state = 1;                               % mark that there are spikes for this trigger
       end
           
    end  
    if (state == 0)
        useDeltas{k,j} = NaN;                      % if no spikes for this trigger, mark an empty trial to help with probability
    end
end

size(useDeltas);

if exist ('useDeltas') 
for j = 1:L1   
[N(:,j), edges] = histcounts([useDeltas{:,j}], 'BinLimits', range, 'Binwidth', bwidth);
N(:,j) = N(:,j)/bwidth; % convert bars to firing rates
end
N_sd = std(N, 0, 2);
N_se = N_sd/sqrt(L1);
N_mean = mean(N, 2);

else
 fprintf('index %s has no licks in window\n') % Alert user if no spikes in range.
    N = NaN(1,(range(end)-range(1))/bwidth);
    edges = NaN(1,(range(end)-range(1))/bwidth+1);
    L1 = NaN;
end


end