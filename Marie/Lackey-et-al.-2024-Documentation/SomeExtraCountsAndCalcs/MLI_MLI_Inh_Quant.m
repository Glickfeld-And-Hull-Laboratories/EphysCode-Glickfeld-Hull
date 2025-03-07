 

for n = 1:length(MLIsB)
    for k = 1:length(MLIsB(n).MLI_MLI_InhSummary)
        if ~isempty([MLIsB(n).MLI_MLI_InhSummary])
        if MLIsB(n).MLI_MLI_InhSummary(k).inhBoo4SD == 1
        N = MLIsB(n).MLI_MLI_InhSummary(k).N;
edges = MLIsB(n).MLI_MLI_InhSummary(k).edges;
[meanLine, stdevLine] = StDevLine(N, edges, binwidth);
crossings = edges(N<(meanLine - SD*stdevLine));
MLIsB(n).MLI_MLI_InhSummary(k).lat = crossings(1);
MLIsB(n).MLI_MLI_InhSummary(k).inhEnd = crossings(end);
        end
        end
    end
end
        

for n = 1:length(MLIsB)
    for k = 1:length(MLIsB(n).MLI_MLI_InhSummary)
        if ~isempty([MLIsB(n).MLI_MLI_InhSummary])
        if MLIsB(n).MLI_MLI_InhSummary(k).inhBoo4SD == 1
        N = MLIsB(n).MLI_MLI_InhSummary(k).N;
edges = MLIsB(n).MLI_MLI_InhSummary(k).edges;
[meanLine, stdevLine] = StDevLine(N, edges, binwidth);
crossings = edges(N<(meanLine - SD*stdevLine));
MLIsB(n).MLI_MLI_InhSummary(k).lat = crossings(1);
MLIsB(n).MLI_MLI_InhSummary(k).inhEnd = crossings(end);
        end
        end
    end
end


counter = 1;
counter2 = 1;
MLIsBINH = [];
MLIsBDUR = [];
MLIsBLAT = [];
for n = 1:length(MLIsB)
   for k = 1:length(MLIsB(n).MLI_MLI_InhSummary)
       if MLIsB(n).MLI_MLI_InhSummary(k).inhBoo4SD == 1
           meany = mean(MLIsB(n).MLI_MLI_InhSummary(k).N(1:39));
           latInd = find(MLIsB(n).MLI_MLI_InhSummary(k).edges == MLIsB(n).MLI_MLI_InhSummary(k).lat);
            IndEnd = find(MLIsB(n).MLI_MLI_InhSummary(k).edges == MLIsB(n).MLI_MLI_InhSummary(k).inhEnd);
           MLIsB(n).MLI_MLI_InhSummary(k).SpPerSecInh = meany- mean(MLIsB(n).MLI_MLI_InhSummary(k).N(latInd:IndEnd));
            MLIsBINH(counter) = MLIsB(n).MLI_MLI_InhSummary(k).SpPerSecInh;
            MLIsBDUR(counter) = MLIsB(n).MLI_MLI_InhSummary(k).inhEnd - MLIsB(n).MLI_MLI_InhSummary(k).lat;
            MLIsBLAT(counter) = MLIsB(n).MLI_MLI_InhSummary(k).lat;
           counter = counter + 1;
       end
   end
end
mean(MLIsBINH)
std(MLIsBINH)/sqrt(length(MLIsBINH))
% mean(MLIsBDUR)
% std(MLIsBDUR)/sqrt(length(MLIsBDUR))
% mean(MLIsBLAT)
% std(MLIsBLAT)/sqrt(length(MLIsBLAT))