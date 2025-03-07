%%Adapted from Marie Hemelt's subfunction ImportKSdataPhyllumC4_mod.m,
%%copied on 2/18/2025 by SMG
%%Removed personalized phy labels and added my own. Renamed and modified
%%subfunctions as needed.

% This function imports KS (and other) data to begin matlab analysis.
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
function [AllUnitStruct, GoodUnitStruct, MultiUnitStruct] = importKSdata_SG(); 

    SpikeTimes = SampToSec();         % use SampToSec funtion to get spiketimes and convert them to seconds using exact sampling rate
    
    clustersAllST    = double(readNPY('spike_clusters.npy'));           % For every spiketime, the cluster associated with it
    spike_amplitudes = double(readNPY('amplitudes.npy'));               % For every spiketime, the amplitude associated with it
    
    fileID      = fopen('cluster_info.tsv');                             % Get sorting data: which units are good, noise, and mu
    C           = readcell('cluster_info.tsv', 'FileType', 'text');
    Fields      = C(1,:).';
    C           = C(2:end,:);
    cluster     = (C(:,find(strcmp(Fields, 'cluster_id'))));
    group       = C(:,find(strcmp(Fields, 'group')));
    channel     = C(:,find(strcmp(Fields, 'ch')));
    depth       = C(:,find(strcmp(Fields, 'depth')));
    FR          = C(:,find(strcmp(Fields, 'fr')));
    rank        = C(:,find(strcmp(Fields, 'rank'))); % field that I created to rank all units based on goodness, 1 through 3
    
    cluster_struct = struct('cluster', cluster, 'group', group, 'channel', channel, 'depth', depth, 'FR', FR, 'rank', rank);

    
    [NoiseUnits, GoodUnits, MultiUnits] = ReadInClusterLabels(cluster_struct);

    
    [AllUnitStruct] = createAllUnitStruct(cluster, SpikeTimes, clustersAllST);
    
    for j = 1:length(cluster)
        ucluster(j,1)   = (cluster_struct(j).cluster);
        uchannel(j,1)   = (cluster_struct(j).channel);
        udepth(j,1)     = (cluster_struct(j).depth);
        uFR(j,1)        = (cluster_struct(j).FR);
        urank{j,1}      = (cluster_struct(j).rank);
        AllUnits(j,1)   = (cluster_struct(j).cluster);
    end
        
     
   for i = 1:length(AllUnitStruct)
        index = find(ucluster == AllUnitStruct(i).unitID);
        AllUnitStruct(i).channel    = uchannel (index);
        AllUnitStruct(i).depth      = udepth(index);
        AllUnitStruct(i).group      = group(index);
        AllUnitStruct(i).FR         = uFR(index);
        AllUnitStruct(i).rank       = urank{index};
    end
       
    cellGoodUnits = {GoodUnits};
    
    [GoodUnitStruct] = createGoodUnitStruct(GoodUnits, SpikeTimes, clustersAllST);
    for i = 1:length(GoodUnitStruct)
        index = find(ucluster == GoodUnitStruct(i).unitID);
        GoodUnitStruct(i).channel   = uchannel (index);
        GoodUnitStruct(i).depth     = udepth(index);
        GoodUnitStruct(i).group     = group(index);
        GoodUnitStruct(i).FR        = uFR(index);
        GoodUnitStruct(i).rank      = urank(index);
    end


    [MultiUnitStruct] = createGoodUnitStruct(MultiUnits, SpikeTimes, clustersAllST);
    for i = 1:length(MultiUnitStruct)
        index = find(ucluster == MultiUnitStruct(i).unitID);
        MultiUnitStruct(i).channel    = uchannel (index);
        MultiUnitStruct(i).depth      = udepth(index);
        MultiUnitStruct(i).group      = group(index);
        MultiUnitStruct(i).FR         = uFR(index);
        MultiUnitStruct(i).rank       = urank(index);
    end

    %   [GoodANDmuaStruct] = createGoodUnitStruct(GoodANDmua, SpikeTimes, clustersAllST);
    % for i = 1:length(GoodANDmuaStruct)
    %     index = find(ucluster == GoodANDmuaStruct(i).unitID);
    %     GoodANDmuaStruct(i).channel   = uchannel (index);
    %     GoodANDmuaStruct(i).depth     = udepth(index);
    %     GoodANDmuaStruct(i).group     = group(index);
    %     GoodANDmuaStruct(i).FR        = uFR(index);
    %     GoodANDmuaStruct(i).rank      = urank(index);
    % end

    loc = what().path;
    
    
   % fid = fopen('LaserStimAdj.txt');
  % LaserStimAdj = fscanf(fid, '%f');
   %fclose(fid);
    
%    GoodUnitStructSorted = SortStruct(GoodUnitStruct, 'channel', 'descend');
%    GoodANDmuaStructSorted = SortStruct(GoodANDmuaStruct, 'channel', 'descend');
%    AllUnitStructSorted = SortStruct(AllUnitStruct, 'channel', 'descend'); 
%     
end
    