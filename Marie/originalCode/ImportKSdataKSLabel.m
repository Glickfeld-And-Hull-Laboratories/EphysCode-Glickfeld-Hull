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
function [cluster_struct, GoodUnits, MultiUnits, GoodANDmua, AllUnits, AllUnitStruct, GoodUnitStruct, MultiUnitStruct, GoodANDmuaStruct] = ImportKSdataKSLabel(); % Add LaserStim to left side if wanted

    SpikeTimes = SampToSec();         % use SampToSec funtion to get spiketimes and convert them to seconds using exact sampling rate
    
    clustersAllST = double(readNPY('spike_clusters.npy'));           % For every spiketime, the cluster associated with it
    spike_amplitudes = double(readNPY('amplitudes.npy'));               % For every spiketime, the amplituded associated with it
    
    fileID = fopen('cluster_info.tsv');                             % Get sorting data: which units are good, noise, and mu
    %C = textscan(fileID, '%s %s %s %s %s %s %s %s %s %s %s', 'HeaderLines', 1, 'Delimiter', {' ', '\t', '\b'}); % removed blank space delimiter and adjusted # of colums to match phyllum
    C = textscan(fileID, '%s %s %s %s %s %s %s %s %s %s %s', 'HeaderLines', 1, 'Delimiter', {' ', '\t', '\b'}); % removed blank space delimiter and adjusted # of colums to match phyllum
    cluster = C{1};
    group = C{9};
    channel = C{6};
    depth = C{7};
    FR = C{8};
    KSLabel = C{4};
    %cluster = C{1};
    %group = C{6};
    %channel = C{3};
    %depth = C{4};
    %FR = C{5};
    
    cluster_struct = struct('cluster', cluster, 'group', group, 'chanel', channel, 'depth', depth, 'FR', FR, 'KSLabel', KSLabel);
    
    [NoiseUnits, GoodUnits, MultiUnits, GoodANDmua] = ReadInClusters1(cluster_struct);
    
    
    [AllUnitStruct] = CreateUnivStruct(cluster, SpikeTimes, clustersAllST, spike_amplitudes);
     for j = 1:length(cluster)
            ucluster(j) = str2double(cluster_struct(j).cluster);
            uchannel(j) = str2double(cluster_struct(j).chanel);
            udepth(j) = str2double(cluster_struct(j).depth);
            uFR(j) = str2double(cluster_struct(j).FR);
            AllUnits(j,1) = str2double(cluster_struct(j).cluster);
     end
        
     
    for i = 1:length(AllUnitStruct)
        index = find(ucluster == AllUnitStruct(i).unitID);
        AllUnitStruct(i).channel = uchannel (index);
        AllUnitStruct(i).depth = udepth(index);
        AllUnitStruct(i).group = group(index);
        AllUnitStruct(i).FR = uFR(index);
    end
       
        
    
    cellGoodUnits = {GoodUnits};
    
    [GoodUnitStruct] = CreateGoodStruct(GoodUnits, SpikeTimes, clustersAllST, spike_amplitudes);
    for i = 1:length(GoodUnitStruct)
        index = find(ucluster == GoodUnitStruct(i).unitID);
        GoodUnitStruct(i).channel = uchannel (index);
        GoodUnitStruct(i).depth = udepth(index);
        GoodUnitStruct(i).group = group(index);
        GoodUnitStruct(i).FR = uFR(index);
    end
    
    [MultiUnitStruct] = CreateGoodStruct(MultiUnits, SpikeTimes, clustersAllST, spike_amplitudes);
    for i = 1:length(MultiUnitStruct)
        index = find(ucluster == MultiUnitStruct(i).unitID);
        MultiUnitStruct(i).channel = uchannel (index);
        MultiUnitStruct(i).depth = udepth(index);
        MultiUnitStruct(i).group = group(index);
        MultiUnitStruct(i).FR = uFR(index);
    end
    
      [GoodANDmuaStruct] = CreateGoodStruct(GoodANDmua, SpikeTimes, clustersAllST, spike_amplitudes);
    for i = 1:length(GoodANDmuaStruct)
        index = find(ucluster == GoodANDmuaStruct(i).unitID);
        GoodANDmuaStruct(i).channel = uchannel (index);
        GoodANDmuaStruct(i).depth = udepth(index);
        GoodANDmuaStruct(i).group = group(index);
        GoodANDmuaStruct(i).FR = uFR(index);
    end
    
    
    
    
   % fid = fopen('LaserStimAdj.txt');
  % LaserStimAdj = fscanf(fid, '%f');
   %fclose(fid);
    
   %GoodUnitStructSorted = SortStruct(GoodUnitStruct, 'channel');
   % GoodANDmuaStructSorted = SortStruct(GoodANDmuaStruct, 'channel');
   % AllUnitStructSorted = SortStruct(AllUnitStruct, 'channel'); 
    
end
    