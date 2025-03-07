figure
hold on
counter = 1;
clear MLSB_MLI
for n = 1:length(MLIsB)
    for k = 1:length(MLIsB(n).MLI_MLI_SyncSymmary)
        if [MLIsB(n).MLI_MLI_SyncSymmary(k).MLI_MLI_dist] <= 125
            if MLIsB(n).MLI_MLI_InhSummary(k).inhBoo4SD == 1
           if [MLIsB(n).MLI_MLI_InhSummary(k).Type] == 'A' 
        MLSB_MLI(counter).N = MLIsB(n).MLI_MLI_SyncSymmary(k).N;
        edges = MLIsB(n).MLI_MLI_SyncSymmary(k).edges;
        counter = counter + 1;
           end
            end
        end
    end
end
shadedErrorBar2(edges, mean(struct2mat(MLSB_MLI, 'N')), std(struct2mat(MLSB_MLI, 'N'))/sqrt(size((struct2mat(MLSB_MLI, 'N')),1)), 'lineProp', 'm')
text(.005, 3, ['pink is ' num2str(counter-1) ' MLI2-MLI1 pairs']);

counter = 1;
clear MLSB_MLI
for n = 1:length(MLIsB)
    for k = 1:length(MLIsB(n).MLI_MLI_SyncSymmary)
        if [MLIsB(n).MLI_MLI_SyncSymmary(k).MLI_MLI_dist] <= 125
            if MLIsB(n).MLI_MLI_InhSummary(k).inhBoo4SD == 1
           if [MLIsB(n).MLI_MLI_InhSummary(k).Type] == 'B' 
        MLSB_MLI(counter).N = MLIsB(n).MLI_MLI_SyncSymmary(k).N;
        edges = MLIsB(n).MLI_MLI_SyncSymmary(k).edges;
        counter = counter + 1;
           end
            end
        end
    end
end
shadedErrorBar2(edges, mean(struct2mat(MLSB_MLI, 'N')), std(struct2mat(MLSB_MLI, 'N'))/sqrt(size((struct2mat(MLSB_MLI, 'N')),1)), 'lineProp', 'g')
text(.005, 3.5, ['green is' num2str(counter-1) ' MLI2-MLI2 pairs']);



counter = 1;
clear MLSB_MLI
for n = 1:length(MLIsB)
    for k = 1:length(MLIsB(n).MLI_MLI_SyncSymmary)
        if [MLIsB(n).MLI_MLI_SyncSymmary(k).MLI_MLI_dist] <= 125
            if MLIsB(n).MLI_MLI_InhSummary(k).inhBoo4SD == 1
        MLSB_MLI(counter).N = MLIsB(n).MLI_MLI_SyncSymmary(k).N;
        edges = MLIsB(n).MLI_MLI_SyncSymmary(k).edges;
        counter = counter + 1;
        end
        end
    end
end
shadedErrorBar2(edges, mean(struct2mat(MLSB_MLI, 'N')), std(struct2mat(MLSB_MLI, 'N'))/sqrt(size((struct2mat(MLSB_MLI, 'N')),1)), 'lineProp', 'k')
text(.005, 2.5, ['black is ' num2str(counter-1) ' allMLI2 - MLI pairs']);
xline(0,'m')