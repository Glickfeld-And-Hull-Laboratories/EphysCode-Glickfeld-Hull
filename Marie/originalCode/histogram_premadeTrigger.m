% go to folder of interest!!!  & set these variables
%clear                                         % must clear manually before
%setting new variables
%cluster1 = 374;                                 % designate first cluster of interest (acts as trigger)
load('FirstTrigPerTrain.mat')          % load trigger timestamps (variable called trigstart)
cluster1 =  trigstart;                           % set premade trigger
%cluster2 = 144;                                  %designate second cluster
%of interest - set manually here
range = [-.500, .500];                       % designate x-axis range in sec
trange = 500;
bwidth = [.001];                               %designate bin size in sec
%%%%

ts = readNPY('spike_times.npy');           %convert all spike times from python to matlab
dts = double(ts)/30000.0000;              % create vector of all spike timestamps
cl = double(readNPY('spike_clusters.npy'));           % create vector designating cluster for each ts
if size(dts) ~= size(cl);                       % check that vector sizes are equal
       printf('warning: spike_times and spike_clusters are unequal')
end
%log1 = cl(:,1) == cluster1;                     % create logical vector for first cluster of interest
log2 = cl(:,1) == cluster2;                  %create logical vector for second cluster of interest
%k1 = find(log1);                                % create vector of indices for clusters of interest
k2 = find(log2);
cl_ts = [cl dts];                              % create matrices of cluster, timestamps
%clone_ts = cl_ts(k1,:);                      % create matrices of timestamps for clustesr of interest
cltwo_ts = cl_ts(k2, :);

clust1 = cluster1;                      % create a vector of timestamps for cluster of interest
clust2 = dts(k2,:);
%selectCL_ts = cast(selectCL_ts,'uint32');      % recast ts as a double instead of uint64
L1 = (length(clust1));                           % L = number of spikes
L2 = (length(clust2));
%deltaT = tall(zeros(L*L,1));
%column = zeros(100)


k = 1;                                              %create counter for output vector index
for i=1:L2                                           % for every element in the first spiketime vector
    for j = 1:L1                                     % for every element in the second (or mirror) spiketime vector
       test = clust2(i,:)- clust1(j,:);             % get difference between spiketimes
       if test == 0;
           test= nan;                               % eliminate zeros
       end
       if ((test <= trange) & (test >= -trange));    % Check if difference is in histogram range
           useDeltas (k,1) = test;                  % If yes, add difference to vector that will create histogram
           k = k+1;                                 % update index
       end
           
    end  
end
figure(1)
histogram (useDeltas, 'BinLimits', range, 'Binwidth', bwidth)
title('222 & 226')

