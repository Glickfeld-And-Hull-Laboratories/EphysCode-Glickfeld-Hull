% go to folder of interest!!!  & set these variables

function [N, edges] = GeneralHist(TS1, TS2, xmin, xmax, bwidth, color, LineBoo, stdevlineboo) %times in seconds
%JuiceTimes = JuiceTimes;                                 % designate first cluster of interest (acts as trigger)
%LickTimes = LickTimes;                                  %designate second cluster of interest 
FaceAlpha = 1;
STDEV = 3;

range = [xmin, xmax];                       % designate x-axis range in sec
trange = abs(xmin);
if trange < xmax
    trange = xmax;
end
Trig1string = inputname(1);
TS2string = inputname(2);
title_ = [TS2string ' in response to ' Trig1string];

%bwidth = [.01];                               %designate bin size in sec
%%%%

%ts = readNPY('spike_times.npy');           %convert all spike times from python to matlab
%dts = double(ts)/30000.0000;              % create vector of all spike timestamps
%cl = double(readNPY('spike_clusters.npy'));           % create vector designating cluster for each ts
%if size(dts) ~= size(cl);                       % check that vector sizes are equal
%       printf('warning: spike_times and spike_clusters are unequal')
%end
%log1 = cl(:,1) == cluster1;                     % create logical vector for first cluster of interest
%log2 = cl(:,1) == cluster2;                  %create logical vector for second cluster of interest
%k1 = find(log1);                                % create vector of indices for clusters of interest
%k2 = find(log2);
%cl_ts = [cl dts];                              % create matrices of cluster, timestamps
%clone_ts = cl_ts(k1,:);                      % create matrices of timestamps for clustesr of interest
%cltwo_ts = cl_ts(k2, :);

%clust1 = dts(k1,:);                      % create a vector of timestamps for cluster of interest
%clust2 = dts(k2,:);
%selectCL_ts = cast(selectCL_ts,'uint32');      % recast ts as a double instead of uint64
L1 = (length(TS1));                           % L = number of spikes
L2 = (length(TS2));
%deltaT = tall(zeros(L*L,1));
%column = zeros(100)


k = 1;                                              %create counter for output vector index
for i=1:L2                                           % for every element in the first spiketime vector
    for j = 1:L1                                     % for every element in the second (or mirror) spiketime vector
       test = TS2(i,:)- TS1(j,:);             % get difference between spiketimes
       if test == 0
           %test= nan;                               % eliminate zeros
       end
       if ((test <= trange) & (test >= -trange))   % Check if difference is in histogram range
           useDeltas (k,1) = test;                  % If yes, add difference to vector that will create histogram
           k = k+1;                                 % update index
       end
           
    end  
end
[N, edges] = histcounts(useDeltas, 'BinLimits', range, 'Binwidth', bwidth);
if LineBoo == 0
[N, ~] = FreqHist(N, edges, length(TS1), color, FaceAlpha, 1); % because we are counting through the trials with the spiketimes, not the triggers
else
[N, edges] = FreqLine(N, edges, L1, color, NaN, 1);
end
%length(TS1)
[meanLine, stdevLine] = StDevLine(N, edges, 0);
%AddStDevLines(meanLine, stdevLine);
if stdevlineboo == 1
yline(meanLine + STDEV*stdevLine, 'g', 'LineWidth', 2);
if (meanLine - STDEV*stdevLine) >0
yline((meanLine - STDEV*stdevLine), 'y', 'LineWidth', 2);
end
end
title(title_);
FormatFigure(NaN, NaN)
xlim([xmin xmax]);
xlabel('sec');
ylabel('Hz');
xline(0, 'b');


end
