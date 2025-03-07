
% lower panel
SD = 4;
binwidth = .0005;
for n = 1:length(MLIs)
    for k = 1:length(MLIs(n).MLI_MLI_InhSummary)
        if ~isempty([MLIs(n).MLI_MLI_InhSummary])
        if MLIs(n).MLI_MLI_InhSummary(k).inhBoo4SD == 1
        N = MLIs(n).MLI_MLI_InhSummary(k).N;
edges = MLIs(n).MLI_MLI_InhSummary(k).edges;
[meanLine, stdevLine] = StDevLine(N, edges, binwidth);
crossings = edges(N<(meanLine - SD*stdevLine));
MLIs(n).MLI_MLI_InhSummary(k).lat = crossings(1);
MLIs(n).MLI_MLI_InhSummary(k).inhEnd = crossings(end);
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
        

figure
hold on

counter = 1;
clear MLI_MLI_LAT
for n = 1:length(MLIsB)
    for k = 1:length(MLIsB(n).MLI_MLI_InhSummary)
        if [MLIsB(n).MLI_MLI_InhSummary(k).inhBoo4SD] == 1
         if MLIsB(n).MLI_MLI_InhSummary(k).MLI_MLI_dist <= 125
        MLI_MLI_LAT(counter).lat = MLIsB(n).MLI_MLI_InhSummary(k).lat;
        counter = counter + 1;
         end
        end
    end
end
histogram ([MLI_MLI_LAT.lat], [0:.0005:.003], 'FaceColor', 'k')

counter = 1;
clear MLI_MLI_LAT
for n = 1:length(MLIsB)
    for k = 1:length(MLIsB(n).MLI_MLI_InhSummary)
        if [MLIsB(n).MLI_MLI_InhSummary(k).inhBoo4SD] == 1
            if MLIsB(n).MLI_MLI_InhSummary(k).MLI_MLI_dist <= 125
                if strcmp([MLIsB(n).MLI_MLI_InhSummary(k).Type], 'A')
        MLI_MLI_LAT(counter).lat = MLIsB(n).MLI_MLI_InhSummary(k).lat;
        counter = counter + 1;
                end
            end
        end
    end
end
histogram ([MLI_MLI_LAT.lat], [0:.0005:.003], 'FaceColor', 'm')


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

figure
hold on

% counter = 1;
% clear MLI_PC
% for n = 1:length(MLIs)
%     for k = 1:length(MLIs(n).MLI_PC_Summary)
%         if [MLIs(n).MLI_PC_Summary(k).inhBoo4SD] == 1
%         MLI_PC(counter).lat = MLIs(n).MLI_PC_Summary(k).lat  ;
%         counter = counter + 1;
%         end
%     end
% end
% histogram ([MLI_PC.lat], [0:.0005:.003], 'FaceColor', 'k')

counter = 1;
clear MLI_PC
for n = 1:length(MLIsA)
    for k = 1:length(MLIsA(n).MLI_PC_Summary)
        if [MLIsA(n).MLI_PC_Summary(k).inhBoo4SD] == 1
        MLI_PC(counter).lat = MLIsA(n).MLI_PC_Summary(k).lat  ;
        counter = counter + 1;
        end
    end
end
histogram ([MLI_PC.lat], [0:.0005:.003], 'FaceColor', 'm')











