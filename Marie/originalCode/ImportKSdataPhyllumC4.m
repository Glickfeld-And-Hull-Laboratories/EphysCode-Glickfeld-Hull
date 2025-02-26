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
function [AllUnitStruct, GoodUnitStruct, MultiUnitStruct, GoodANDmuaStruct, loc, C] = ImportKSdataPhyllumC4(); % Add LaserStim to left side if wanted
%[cluster_struct, AllUnitStruct, GoodUnitStruct, MultiUnitStruct, GoodANDmuaStruct, GoodUnitStructSorted, GoodANDmuaStructSorted, AllUnitStructSorted] = ImportKSdataPhyllum() % Add LaserStim to left side if wanted

    SpikeTimes = SampToSec();         % use SampToSec funtion to get spiketimes and convert them to seconds using exact sampling rate
    
    clustersAllST = double(readNPY('spike_clusters.npy'));           % For every spiketime, the cluster associated with it
    spike_amplitudes = double(readNPY('amplitudes.npy'));               % For every spiketime, the amplituded associated with it
    
    fileID = fopen('cluster_info.tsv');                             % Get sorting data: which units are good, noise, and mu
    %C = textscan(fileID, '%s %s %s %s %s %s %s %s %s %s %s', 'HeaderLines', 1, 'Delimiter', {' ', '\t', '\b'}); % removed blank space delimiter and adjusted # of colums to match phyllum
    %C = textscan(fileID, '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', 'HeaderLines', 1, 'Delimiter', {'\t'}, 'MultipleDelimsAsOne', 1); % removed blank space delimiter and adjusted # of colums to match phyllum
    C = readcell('cluster_info.tsv', 'FileType', 'text');
    C = C(2:end,:);
    cluster = (C(:,1));
    group = C(:,38);
    channel = C(:,27);
    depth = C(:,30);
    FR = C(:,35);
    layer = C(:,33);
    C4_label = C(:,6);
    C4_confidence = C(:,3);
    snr = C(:,24);
    PC_dist = C(:,23);
    %DCS_dist = C{16};
    %MF_dist= C{12};
    %distFromPC = {}
    %cluster = C{1};
    %group = C{6};
    %channel = C{3};
    %depth = C{4};
    %FR = C{5};
    
    cluster_struct = struct('cluster', cluster, 'group', group, 'chanel', channel, 'depth', depth, 'FR', FR, 'layer', layer, 'c4_label', C4_label, 'c4_confidence', C4_confidence, 'PC_dist', PC_dist, 'snr', snr);
    
    [NoiseUnits, GoodUnits, MultiUnits, GoodANDmua] = ReadInClustersC4(cluster_struct);
    
    
    [AllUnitStruct] = CreateUnivStructC4(cluster, SpikeTimes, clustersAllST, spike_amplitudes);
    
     for j = 1:length(cluster)
            ucluster(j,1) = (cluster_struct(j).cluster);
            uchannel(j,1) = (cluster_struct(j).chanel);
            udepth(j,1) = (cluster_struct(j).depth);
            uFR(j,1) = (cluster_struct(j).FR);
            uC4_label{j,1} = (cluster_struct(j).c4_label);
            if ismissing(uC4_label{j,1})
               uC4_label{j,1} = NaN; 
            end
            uC4_confidence(j,1) = (cluster_struct(j).c4_confidence);
            if ismissing(uC4_confidence(j,1))
              if j == 1
                uC4_confidence = [];
               uC4_confidence(j,1) = NaN; 
              end
            end
            uPC_dist(j,1) = (cluster_struct(j).PC_dist);
%             uDCS_dist(j) = str2double(cluster_struct(j).DCS_dist);
%             uMF_dist(j) = str2double(cluster_struct(j).MF_dist);
            usnr(j,1) = (cluster_struct(j).snr);
            AllUnits(j,1) = (cluster_struct(j).cluster);
     end
        
     
    for i = 1:length(AllUnitStruct)
        index = find(ucluster == AllUnitStruct(i).unitID);
        AllUnitStruct(i).channel = uchannel (index);
        AllUnitStruct(i).depth = udepth(index);
        AllUnitStruct(i).group = group(index);
        AllUnitStruct(i).FR = uFR(index);
        AllUnitStruct(i).layer = layer(index);
        AllUnitStruct(i).c4_label = uC4_label{index};
        AllUnitStruct(i).c4_confidence = uC4_confidence(index);
        AllUnitStruct(i).PC_dist = uPC_dist(index);
%         AllUnitStruct(i).DCS_dist = uDCS_dist(index);
%         AllUnitStruct(i).MF_dist = uMF_dist(index);
        AllUnitStruct(i).snr = usnr(index);
    end
       
        
    
    cellGoodUnits = {GoodUnits};
    
    [GoodUnitStruct] = CreateGoodStruct(GoodUnits, SpikeTimes, clustersAllST, spike_amplitudes);
    for i = 1:length(GoodUnitStruct)
        index = find(ucluster == GoodUnitStruct(i).unitID);
        GoodUnitStruct(i).channel = uchannel (index);
        GoodUnitStruct(i).depth = udepth(index);
        GoodUnitStruct(i).group = group(index);
        GoodUnitStruct(i).FR = uFR(index);
        GoodUnitStruct(i).layer = layer(index);
        GoodUnitStruct(i).c4_label = uC4_label{index};
        GoodUnitStruct(i).c4_confidence = uC4_confidence(index);
        GoodUnitStruct(i).PC_dist = uPC_dist(index);
%         GoodUnitStruct(i).DCS_dist = uDCS_dist(index);
%         GoodUnitStruct(i).MF_dist = uMF_dist(index);
        GoodUnitStruct(i).snr = usnr(index);
    end
    
    [MultiUnitStruct] = CreateGoodStruct(MultiUnits, SpikeTimes, clustersAllST, spike_amplitudes);
    for i = 1:length(MultiUnitStruct)
        index = find(ucluster == MultiUnitStruct(i).unitID);
        MultiUnitStruct(i).channel = uchannel (index);
        MultiUnitStruct(i).depth = udepth(index);
        MultiUnitStruct(i).group = group(index);
        MultiUnitStruct(i).FR = uFR(index);
        MultiUnitStruct(i).layer = layer(index);
        MultiUnitStruct(i).c4_label = uC4_label{index};
        MultiUnitStruct(i).c4_confidence = uC4_confidence(index);
        MultiUnitStruct(i).PC_dist = uPC_dist(index);
%         MultiUnitStruct(i).DCS_dist = uDCS_dist(index);
%         MultiUnitStruct(i).MF_dist = uMF_dist(index);
        MultiUnitStruct(i).snr = usnr(index);
    end
    
      [GoodANDmuaStruct] = CreateGoodStruct(GoodANDmua, SpikeTimes, clustersAllST, spike_amplitudes);
    for i = 1:length(GoodANDmuaStruct)
        index = find(ucluster == GoodANDmuaStruct(i).unitID);
        GoodANDmuaStruct(i).channel = uchannel (index);
        GoodANDmuaStruct(i).depth = udepth(index);
        GoodANDmuaStruct(i).group = group(index);
        GoodANDmuaStruct(i).FR = uFR(index);
        GoodANDmuaStruct(i).layer = layer(index);
        GoodANDmuaStruct(i).c4_label = uC4_label{index};
        GoodANDmuaStruct(i).c4_confidence = uC4_confidence(index);
        GoodANDmuaStruct(i).PC_dist = uPC_dist(index);
%         GoodANDmuaStruct(i).DCS_dist = uDCS_dist(index);
%         GoodANDmuaStruct(i).MF_dist = uMF_dist(index);
        GoodANDmuaStruct(i).snr = usnr(index);
    end
    
    loc = what().path;
    
    
   % fid = fopen('LaserStimAdj.txt');
  % LaserStimAdj = fscanf(fid, '%f');
   %fclose(fid);
    
%    GoodUnitStructSorted = SortStruct(GoodUnitStruct, 'channel', 'descend');
%     GoodANDmuaStructSorted = SortStruct(GoodANDmuaStruct, 'channel', 'descend');
%     AllUnitStructSorted = SortStruct(AllUnitStruct, 'channel', 'descend'); 
%     
end
    