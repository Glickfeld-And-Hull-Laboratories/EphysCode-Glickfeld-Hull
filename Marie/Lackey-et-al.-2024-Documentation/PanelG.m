% top
figure
hold on
counter = 1;
clear MLIA_MLI
for n = 1:length(MLIsA_put)
    for k = 1:length(MLIsA_put(n).MLI_MLI_SyncSymmary)
        if [MLIsA_put(n).MLI_MLI_SyncSymmary(k).MLI_MLI_dist] <= 125
           if [MLIsA_put(n).MLI_MLI_InhSummary(k).Type_put] == 'A' 
        MLIA_MLI(counter).N = MLIsA_put(n).MLI_MLI_SyncSymmary(k).N;
        edges = MLIsA_put(n).MLI_MLI_SyncSymmary(k).edges;
        counter = counter + 1;
           end
        end
    end
end
shadedErrorBar2(edges, mean(struct2mat(MLIA_MLI, 'N')), std(struct2mat(MLIA_MLI, 'N'))/sqrt(size((struct2mat(MLIA_MLI, 'N')),1)), 'lineProp', 'm')
text(.005, 5, ['pink is ' num2str(counter-1) ' MLI1-MLI1 pairs']);

counter = 1;
clear MLIA_MLI
for n = 1:length(MLIsA_put)
    for k = 1:length(MLIsA_put(n).MLI_MLI_SyncSymmary)
        if [MLIsA_put(n).MLI_MLI_SyncSymmary(k).MLI_MLI_dist] <= 125
           if [MLIsA_put(n).MLI_MLI_InhSummary(k).Type] == 'B' 
        MLIA_MLI(counter).N = MLIsA_put(n).MLI_MLI_SyncSymmary(k).N;
        edges = MLIsA_put(n).MLI_MLI_SyncSymmary(k).edges;
        counter = counter + 1;
           end
        end
    end
end
shadedErrorBar2(edges, mean(struct2mat(MLIA_MLI, 'N')), std(struct2mat(MLIA_MLI, 'N'))/sqrt(size((struct2mat(MLIA_MLI, 'N')),1)), 'lineProp', 'g')
text(.005, 8, ['green is ' num2str(counter-1) ' MLI1-MLI2 pairs']);


counter = 1;
clear MLIA_MLI
for n = 1:length(MLIsA_put)
    for k = 1:length(MLIsA_put(n).MLI_MLI_SyncSymmary)
        if [MLIsA_put(n).MLI_MLI_SyncSymmary(k).MLI_MLI_dist] <= 125
        MLIA_MLI(counter).N = MLIsA_put(n).MLI_MLI_SyncSymmary(k).N;
        edges = MLIsA_put(n).MLI_MLI_SyncSymmary(k).edges;
        counter = counter + 1;
        end
    end
end
shadedErrorBar2(edges, mean(struct2mat(MLIA_MLI, 'N')), std(struct2mat(MLIA_MLI, 'N'))/sqrt(size((struct2mat(MLIA_MLI, 'N')),1)), 'lineProp', 'k')
text(.005, 2.5, ['black is ' num2str(counter-1) ' allMLI1 - MLI pairs']);
xline(0,'m')
xlim([-.01 .01]);
ylim([-12 20]);
FormatFigure(NaN, NaN);

%bottom
figure
hold on
counter = 1;
clear MLSB_MLI
for n = 1:length(MLIsB_put)
    for k = 1:length(MLIsB_put(n).MLI_MLI_SyncSymmary)
        if [MLIsB_put(n).MLI_MLI_SyncSymmary(k).MLI_MLI_dist] <= 125
           if [MLIsB_put(n).MLI_MLI_InhSummary(k).Type_put] == 'A' 
        MLSB_MLI(counter).N = MLIsB_put(n).MLI_MLI_SyncSymmary(k).N;
        edges = MLIsB_put(n).MLI_MLI_SyncSymmary(k).edges;
        counter = counter + 1;
           end
        end
    end
end
shadedErrorBar2(edges, mean(struct2mat(MLSB_MLI, 'N')), std(struct2mat(MLSB_MLI, 'N'))/sqrt(size((struct2mat(MLSB_MLI, 'N')),1)), 'lineProp', 'm')
text(.005, 3, ['pink is ' num2str(counter-1) ' MLI2-MLI1 pairs']);

counter = 1;
clear MLSB_MLI
for n = 1:length(MLIsB_put)
    for k = 1:length(MLIsB_put(n).MLI_MLI_SyncSymmary)
        if [MLIsB_put(n).MLI_MLI_SyncSymmary(k).MLI_MLI_dist] <= 125
           if [MLIsB_put(n).MLI_MLI_InhSummary(k).Type] == 'B' 
        MLSB_MLI(counter).N = MLIsB_put(n).MLI_MLI_SyncSymmary(k).N;
        edges = MLIsB_put(n).MLI_MLI_SyncSymmary(k).edges;
        counter = counter + 1;
           end
        end
    end
end
shadedErrorBar2(edges, mean(struct2mat(MLSB_MLI, 'N')), std(struct2mat(MLSB_MLI, 'N'))/sqrt(size((struct2mat(MLSB_MLI, 'N')),1)), 'lineProp', 'g')
text(.005, 3.5, ['green is ' num2str(counter-1) ' MLI2-MLI2 pairs']);

counter = 1;
clear MLSB_MLI
for n = 1:length(MLIsB_put)
    for k = 1:length(MLIsB_put(n).MLI_MLI_SyncSymmary)
        if [MLIsB_put(n).MLI_MLI_SyncSymmary(k).MLI_MLI_dist] <= 125
        MLSB_MLI(counter).N = MLIsB_put(n).MLI_MLI_SyncSymmary(k).N;
        edges = MLIsB_put(n).MLI_MLI_SyncSymmary(k).edges;
        counter = counter + 1;
        end
    end
end
shadedErrorBar2(edges, mean(struct2mat(MLSB_MLI, 'N')), std(struct2mat(MLSB_MLI, 'N'))/sqrt(size((struct2mat(MLSB_MLI, 'N')),1)), 'lineProp', 'k')
text(.005, 2.5, ['black is ' num2str(counter-1) ' allMLI2 - MLI pairs']);
xline(0,'m')