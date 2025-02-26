
% upper panel
SD = 4;
binwidth = .0005;
for n = 1:length(MLIs)
    for k = 1:length(MLIs(n).MLI_PC_Summary)
        if ~isempty([MLIs(n).MLI_PC_Summary])
        if MLIs(n).MLI_PC_Summary(k).inhBoo4SD == 1
        N = MLIs(n).MLI_PC_Summary(k).N;
edges = MLIs(n).MLI_PC_Summary(k).edges;
[meanLine, stdevLine] = StDevLine(N, edges, binwidth);
crossings = edges(N<(meanLine - SD*stdevLine));
MLIs(n).MLI_PC_Summary(k).lat = crossings(1);
MLIs(n).MLI_PC_Summary(k).inhEnd = crossings(end);
        end
        end
    end
end
      

for n = 1:length(MLIsB)
    for k = 1:length(MLIsB(n).MLI_PC_Summary)
        if ~isempty([MLIsB(n).MLI_PC_Summary])
        if MLIsB(n).MLI_PC_Summary(k).inhBoo4SD == 1
        N = MLIsB(n).MLI_PC_Summary(k).N;
edges = MLIsB(n).MLI_PC_Summary(k).edges;
[meanLine, stdevLine] = StDevLine(N, edges, binwidth);
crossings = edges(N<(meanLine - SD*stdevLine));
MLIsB(n).MLI_PC_Summary(k).lat = crossings(1);
MLIsB(n).MLI_PC_Summary(k).inhEnd = crossings(end);
        end
        end
    end
end
        

for n = 1:length(MLIsA)
    for k = 1:length(MLIsA(n).MLI_PC_Summary)
        if ~isempty([MLIsA(n).MLI_PC_Summary])
        if MLIsA(n).MLI_PC_Summary(k).inhBoo4SD == 1
        N = MLIsA(n).MLI_PC_Summary(k).N;
edges = MLIsA(n).MLI_PC_Summary(k).edges;
[meanLine, stdevLine] = StDevLine(N, edges, binwidth);
crossings = edges(N<(meanLine - SD*stdevLine));
MLIsA(n).MLI_PC_Summary(k).lat = crossings(1);
MLIsA(n).MLI_PC_Summary(k).inhEnd = crossings(end);
        end
        end
    end
end


counter = 1;
counter2 = 1;
MLIsAINH = [];
MLIsADUR = [];
MLIsALAT = [];
for n = 1:length(MLIsA)
   for k = 1:length(MLIsA(n).MLI_PC_Summary)
       if MLIsA(n).MLI_PC_Summary(k).inhBoo4SD == 1
           meany = mean(MLIsA(n).MLI_PC_Summary(k).N(1:39));
           latInd = find(MLIsA(n).MLI_PC_Summary(k).edges == MLIsA(n).MLI_PC_Summary(k).lat);
            IndEnd = find(MLIsA(n).MLI_PC_Summary(k).edges == MLIsA(n).MLI_PC_Summary(k).inhEnd);
           MLIsA(n).MLI_PC_Summary(k).SpPerSecInh = meany- mean(MLIsA(n).MLI_PC_Summary(k).N(latInd:IndEnd));
            MLIsAINH(counter) = MLIsA(n).MLI_PC_Summary(k).SpPerSecInh;
            MLIsADUR(counter) = MLIsA(n).MLI_PC_Summary(k).inhEnd - MLIsA(n).MLI_PC_Summary(k).lat;
            MLIsALAT(counter) = MLIsA(n).MLI_PC_Summary(k).lat;
           counter = counter + 1;
       end
   end
end
mean(MLIsAINH)
std(MLIsAINH)/sqrt(length(MLIsAINH))
% mean(MLIsADUR)
% std(MLIsADUR)/sqrt(length(MLIsADUR))
% mean(MLIsALAT)
% std(MLIsALAT)/sqrt(length(MLIsALAT))