function [NoiseUnits, GoodUnits, MUnits] = ReadInAllClusters(cluster_struct)
%cluster_struct= table2struct(cluster_group) % need a less hands-on way to import cluster_group.ts

for n=1:length(cluster_struct) % make vectors of units that are good, noise, or mua
        AllUnits(n,1)=str2double(cluster_struct(k).cluster);
end


end