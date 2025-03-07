% Imports KS (and other) data to begin matlab analysis.
%
% Gets .imec file that was used for KS and phy to parse metadata.
%
% Returns vectors of unit name/numbers (as scalars) that are classified as
% good, noise, and mua in py (GoodUnits, NoiseUnits, MUnits).
%
% Returns structure of all units that contains unit (as a string( in field
% unitID and vectors of timestamps for corresponding units (as vectors) in
% field .timstamps (AllUnitStruct).
%
% Also returns structure of good units that contains unit (as a string) in
% field .unitID and vectors of timestamps for corresponding units (as
% vectors) in field .timestamps (GoodUnitStruct).
%
%
%
function [AllUnitStruct] = ImportKSNoSort(); % Add LaserStim to left side if wanted

    SpikeTimes = SampToSec();         % use SampToSec funtion to get spiketimes and convert them to seconds using exact sampling rate
    
    clustersAllST = double(readNPY('spike_clusters.npy'));           % For every spiketime, the cluster associated with it
    
    fileID = fopen('cluster_info.tsv');                             % Get sorting data: which units are good, noise, and mu
    C = textscan(fileID, '%s %s %s %s %s %s %s %s %s %s %s', 'HeaderLines', 1);
    cluster = C{1};
    group = C{9};
    channel = C{6};
    depth = C{7};
    FR = C{8};
    cluster_struct = struct('cluster', cluster, 'group', group, 'chanel', channel, 'depth', depth, 'FR', FR);
    
    %[NoiseUnits, GoodUnits, MultiUnits, GoodANDmua] = ReadInClusters(cluster_struct);
    
    [AllUnitStruct] = CreateUnivStruct(cluster, SpikeTimes, clustersAllST);
     for j = 1:length(cluster)
            ucluster(j) = str2double(cluster_struct(j).cluster);
            uchannel(j) = str2double(cluster_struct(j).chanel);
            udepth(j) = str2double(cluster_struct(j).depth);
            uFR(j) = str2double(cluster_struct(j).FR);
     end
        
     
    for i = 1:length(AllUnitStruct)
        index = find(ucluster == AllUnitStruct(i).unitID);
        AllUnitStruct(i).channel = uchannel (index);
        AllUnitStruct(i).depth = udepth(index);
        AllUnitStruct(i).group = group(index);
        AllUnitStruct(i).FR = uFR(index);
    end
       
        
    
    
    
   % fid = fopen('LaserStimAdj.txt');
  % LaserStimAdj = fscanf(fid, '%f');
   %fclose(fid);
    
    
    
end
    