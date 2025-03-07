% go to folder of interest!!!  & set these variables

function [N, edges] = LickHistCumul(JuiceTimes, LickTimes, range, bwidth, color, plotBoo)
%JuiceTimes = JuiceTimes;                                 % designate first cluster of interest (acts as trigger)
%LickTimes = LickTimes;                                  %designate second cluster of interest 

%range = [-20,5];                       % designate x-axis range in sec
xmin = range(1);                     % designate x-axis range in sec, xmin should be negative
xmax = range(2);
trange = abs(xmin);
if trange < xmax
    trange = xmax;
end

%bwidth = [.01];                               %designate bin size in sec
%%%%


L1 = (length(JuiceTimes));                           % L = number of spikes
L2 = (length(LickTimes));


k = 1;                                              %create counter for output vector index
for j = 1:L1                                          % for every element in the first spiketime vector (JuicTimes)
    state = 0;                                      % will check if there are any spikes for this trigger
    for i=1:L2                                      % for every element in the second (or mirror) spiketime vector (LickTimes)
       test = LickTimes(i,:)- JuiceTimes(j,:);             % get difference between spiketimes
%        if test == 0;
%            test= nan;                               % eliminate zeros
%        end
       if ((test <= trange) & (test >= -trange));    % Check if difference is in histogram range
           useDeltas (k,1) = test;                  % If yes, add difference to vector that will create histogram
           k = k+1;                                 % update index
           state = 1;                               % mark that there are spikes for this trigger
       end
           
    end  
    if (state == 0)
        useDeltas (k,1) = NaN;                      % if no spikes for this trigger, mark an empty trial to help with probability
    end
end
if exist ('useDeltas') 
if plotBoo == 1
%figure
%hold on
end
% histogram (useDeltas, 'BinLimits', range, 'Binwidth', bwidth, 'Facecolor', 'k', 'Linestyle', 'none', 'Facealpha', 1)  %'Normalization', 'probability', 
% title('Licking interval histogram')
% box off
% %ax.TickDir = 'out'
% ax = gca; 
% ax.TickDir = 'out';
% ax.FontName = 'Calibri', 'FixedWidth';
% ax.FontSize = 18;
[N, edges] = histcounts(useDeltas, 'BinLimits', range, 'Binwidth', bwidth, 'Normalization', 'cumcount');
[N, ~] = FreqLine(N, edges, L1, color, NaN, plotBoo);
N = N*bwidth;
else
 fprintf('index %s has no licks in window\n') % Alert user if no spikes in range.
    N = NaN(1,(range(end)-range(1))/bwidth);
    edges = NaN(1,(range(end)-range(1))/bwidth+1);
    L1 = NaN;
end


end