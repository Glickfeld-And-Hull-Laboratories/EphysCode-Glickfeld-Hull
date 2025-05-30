% Adapted from Marie Hemelt's subfunction ReadInClusters.m, copied on
% 2/19/2025 by SMG

function [NoiseUnits, GoodUnits] = ReadInClusterLabels(cluster_struct)
n=1;   % set counters to one that will help fill the vectors of Good, Noise, and MU lists of units and both Good and MU
g=1;
m=1;
%b=1;

for k=1:length(cluster_struct) % make vectors of units that are good, noise, or mua
    if strcmp(cluster_struct(k).group, 'noise')
        NoiseUnits(n,1)=cluster_struct(k).cluster;
        n = n+1;
    end
    if strcmp(cluster_struct(k).group,'good')
        GoodUnits(g,1)=cluster_struct(k).cluster;
        g = g+1;
    end
    if strcmp(cluster_struct(k).group,'mua')
        MUnits(m,1) = str2double(cluster_struct(k).cluster);
        m = m+1;
    end
        
end


end