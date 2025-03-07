
SD = 4;
binwidth = .0002;

for n = 1:length(MLIsA_put)
     if ~isempty([MLIsA_put(n).MLI_MLI_SyncSymmary])
    for k = 1:length(MLIsA_put(n).MLI_MLI_SyncSymmary)
        if MLIsA_put(n).MLI_MLI_SyncSymmary(k).syncBoo4SD == 1
        N = MLIsA_put(n).MLI_MLI_SyncSymmary(k).N;
edges = MLIsA_put(n).MLI_MLI_SyncSymmary(k).edges;
[meanLine, stdevLine] = StDevLine(N, edges, -.006);
crossings = edges(N>(meanLine + SD*stdevLine));
MLIsA_put(n).MLI_MLI_SyncSymmary(k).start = crossings(1);
MLIsA_put(n).MLI_MLI_SyncSymmary(k).end = crossings(end);
        end
        end
    end
end

counter = 1;
counter2 = 1;
MLIsA_putSYNC = [];
MLIsA_putDUR = [];
MLIsA_putstart = [];
MLIsA_putend = [];
for n = 1:length(MLIsA_put)
   for k = 1:length(MLIsA_put(n).MLI_MLI_SyncSymmary)
       if [MLIsA_put(n).MLI_MLI_SyncSymmary(k).syncBoo4SD] == 1
           startSync = find(MLIsA_put(n).MLI_MLI_SyncSymmary(k).edges == MLIsA_put(n).MLI_MLI_SyncSymmary(k).start);
            endSynch = find(MLIsA_put(n).MLI_MLI_SyncSymmary(k).edges == MLIsA_put(n).MLI_MLI_SyncSymmary(k).end);
            MLIsA_put(n).MLI_MLI_SyncSymmary(k).SpPerSecInc =  mean(MLIsA_put(n).MLI_MLI_SyncSymmary(k).N(startSync:endSynch));
            MLIsA_putSYNC(counter) = MLIsA_put(n).MLI_MLI_SyncSymmary(k).SpPerSecInc;
            MLIsA_putDUR(counter) = MLIsA_put(n).MLI_MLI_SyncSymmary(k).end - MLIsA_put(n).MLI_MLI_SyncSymmary(k).start;
            MLIsA_putstart(counter) = MLIsA_put(n).MLI_MLI_SyncSymmary(k).start;
            MLIsA_putend(counter)= MLIsA_put(n).MLI_MLI_SyncSymmary(k).end;
           counter = counter + 1;
       end
   end
end
meany(MLIsA_putSYNC)
meany(MLIsA_putDUR)
% meany(MLIsA_putstart)
% meany(MLIsA_putend)