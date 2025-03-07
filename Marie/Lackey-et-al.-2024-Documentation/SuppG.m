figure
hold on
counter = 1;
counter2 = 1;
clear MLIA_MLI
clear MLIA_MLIA
for n = 1:length(MLIsA_put)
    for k = 1:length(MLIsA_put(n).MLI_MLI_SyncSymmary)
%         if [MLIsA_put(n).MLI_MLI_SyncSymmary(k).MLI_MLI_dist] <=125
            if [MLIsA_put(n).MLI_MLI_SyncSymmary(k).syncBoo4SD] == 1
                if strcmp({MLIsA_put(n).MLI_MLI_InhSummary(k).Type_put}, 'A')
                    MLIA_MLIA(counter).N = MLIsA_put(n).MLI_MLI_SyncSymmary(k).N;
                    counter = counter + 1;
                else
                    MLIA_MLI(counter2).N = MLIsA_put(n).MLI_MLI_SyncSymmary(k).N;
                    counter2 = counter2 + 1;
                    edges = MLIsA_put(n).MLI_MLI_SyncSymmary(k).edges;
                end
            end
        end
    end
% end

shadedErrorBar2(edges, mean(struct2mat(MLIA_MLIA, 'N')), std(struct2mat(MLIA_MLIA, 'N'))/sqrt(size((struct2mat(MLIA_MLIA, 'N')),1)), 'lineProp', 'm')
shadedErrorBar2(edges, mean(struct2mat(MLIA_MLI, 'N')), std(struct2mat(MLIA_MLI, 'N'))/sqrt(size((struct2mat(MLIA_MLI, 'N')),1)), 'lineProp', 'k')

text(.005, 3, [num2str(counter-1) ' sync MLI1-MLI1 pairs']);
text(.005, 4, [num2str(counter2-1) ' sync MLI1-MLI pairs']);
xlim([-.01 .01]);
%I had to re-create this code and I'm not sure where the extra 5 MLIA-MLIA
%connections went- I wonder if I counted the 5 MLIA-MLI accidentally in
%that total previously?
