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
function [AllUnitStruct, GoodUnitStruct, MultiUnitStruct, GoodANDmuaStruct, loc] = ImportKSdataNpxC4(); % Add LaserStim to left side if wanted
%[cluster_struct, AllUnitStruct, GoodUnitStruct, MultiUnitStruct, GoodANDmuaStruct, GoodUnitStructSorted, GoodANDmuaStructSorted, AllUnitStructSorted] = ImportKSdataPhyllum() % Add LaserStim to left side if wanted

    SpikeTimes = SampToSec();         % use SampToSec funtion to get spiketimes and convert them to seconds using exact sampling rate
    
    clustersAllST = double(readNPY('spike_clusters.npy'));           % For every spiketime, the cluster associated with it
    spike_amplitudes = double(readNPY('amplitudes.npy'));               % For every spiketime, the amplituded associated with it
    
    fileID = fopen('cluster_info.tsv');                             % Get sorting data: which units are good, noise, and mu
    %C = textscan(fileID, '%s %s %s %s %s %s %s %s %s %s %s', 'HeaderLines', 1, 'Delimiter', {' ', '\t', '\b'}); % removed blank space delimiter and adjusted # of colums to match phyllum
    %C = textscan(fileID, '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', 'HeaderLines', 1, 'Delimiter', {'\t'}, 'MultipleDelimsAsOne', 1); % removed blank space delimiter and adjusted # of colums to match phyllum
    C = readcell('cluster_info.tsv', 'FileType', 'text');
    Fields = C(1,:).';
    C = C(2:end,:);
    cluster = (C(:,find(strcmp(Fields, 'cluster_id'))));
    group = C(:,find(strcmp(Fields, 'group')));
    channel = C(:,find(strcmp(Fields, 'ch')));
    depth = C(:,find(strcmp(Fields, 'depth')));
    FR = C(:,find(strcmp(Fields, 'fr')));
%     layer = C(:,find(strcmp(Fields, 'layer')));
%     C4_label = C(:,find(strcmp(Fields, 'C4_predicted_cell_type')));
%     C4_confidence = C(:,find(strcmp(Fields, 'C4_confidence')));
    snr = C(:,find(strcmp(Fields, 'SNR')));
    PC_dist = C(:,find(strcmp(Fields, 'PC_distance')));
    D = readcell('cluster_predicted_cell_type.tsv', 'FileType', 'text');
    D = D(2:end,:);
    E = readcell('cluster_confidence_ratio.tsv', 'FileType', 'text');
    E = E(2:end,:);
    F = readcell('cluster_layer.tsv', 'FileType', 'text');
    F = F(2:end,:);
    
    %DCS_dist = C{16};
    %MF_dist= C{12};
    %distFromPC = {}
    %cluster = C{1};
    %group = C{6};
    %channel = C{3};
    %depth = C{4};
    %FR = C{5};
    
    cluster_struct = struct('cluster', cluster, 'group', group, 'chanel', channel, 'depth', depth, 'FR', FR, 'PC_dist', PC_dist, 'snr', snr);
    
    [NoiseUnits, GoodUnits, MultiUnits, GoodANDmua] = ReadInClustersC4(cluster_struct);
    
    
    [AllUnitStruct] = CreateUnivStructC4(cluster, SpikeTimes, clustersAllST, spike_amplitudes);
    
     for j = 1:length(cluster)
            ucluster(j,1) = (cluster_struct(j).cluster);
            uchannel(j,1) = (cluster_struct(j).chanel);
            udepth(j,1) = (cluster_struct(j).depth);
            uFR(j,1) = (cluster_struct(j).FR);
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
        AllUnitStruct(i).group = group{index};
        AllUnitStruct(i).FR = uFR(index);
%         AllUnitStruct(i).layer = layer(index);

%         AllUnitStruct(i).c4_label = uC4_label{index};
%         AllUnitStruct(i).c4_confidence = uC4_confidence(index);
if ~isempty([D{cell2mat(D(:,1)) == AllUnitStruct(i).unitID, 2}])
        AllUnitStruct(i).c4_label = D{cell2mat(D(:,1)) == AllUnitStruct(i).unitID, 2};
        AllUnitStruct(i).c4_confidence = E{cell2mat(E(:,1)) == AllUnitStruct(i).unitID, 2};
         AllUnitStruct(i).layer = F{cell2mat(F(:,1)) == AllUnitStruct(i).unitID, 2};
else 
    AllUnitStruct(i).c4_label = [];
    AllUnitStruct(i).c4_confidence = [];
             AllUnitStruct(i).layer = 'unknown';
end
        AllUnitStruct(i).PC_dist = uPC_dist(index);
%         AllUnitStruct(i).DCS_dist = uDCS_dist(index);
%         AllUnitStruct(i).MF_dist = uMF_dist(index);
        AllUnitStruct(i).snr = usnr(index);
    end
       
        
    
    loc = what().path;
    
    GoodUnitStruct = AllUnitStruct([strcmp({AllUnitStruct.group}, 'good')]);
    MultiUnitStruct = AllUnitStruct([strcmp({AllUnitStruct.group}, 'mua')]); 
    GoodANDmuaStruct = AllUnitStruct([strcmp({AllUnitStruct.group}, 'good')] | [strcmp({AllUnitStruct.group}, 'good')]);
   % fid = fopen('LaserStimAdj.txt');
  % LaserStimAdj = fscanf(fid, '%f');
   %fclose(fid);
    
%    GoodUnitStructSorted = SortStruct(GoodUnitStruct, 'channel', 'descend');
%     GoodANDmuaStructSorted = SortStruct(GoodANDmuaStruct, 'channel', 'descend');
%     AllUnitStructSorted = SortStruct(AllUnitStruct, 'channel', 'descend'); 
%     
end
    