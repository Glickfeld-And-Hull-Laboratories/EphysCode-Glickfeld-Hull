figure
hold on
counter = 1;
connCount = 0;
clear MLIA_PC
for n = 1:length(MLIsA_put)
    for k = 1:length(MLIsA_put(n).MLI_PC_Summary)
        if [MLIsA_put(n).MLI_PC_Summary(k).MLI_PC_dist] <=125
%              if [MLIsA_put(n).MLI_PC_Summary(k).inhBoo4SD] == 1
        MLIA_PC(counter).N = MLIsA_put(n).MLI_PC_Summary(k).N;
        edges = MLIsA_put(n).MLI_PC_Summary(k).edges;
        counter = counter + 1;
        if [MLIsA_put(n).MLI_PC_Summary(k).inhBoo4SD] == 1
            connCount = connCount + 1;
           end
%              end
        end
    end
end
shadedErrorBar2(edges, mean(struct2mat(MLIA_PC, 'N')), std(struct2mat(MLIA_PC, 'N'))/sqrt(size((struct2mat(MLIA_PC, 'N')),1)), 'lineProp', 'k')
text(.005, 3, [num2str(counter-1) ' close MLI1-PC pairs']);
text(.005, 4, [num2str(connCount) ' inhibitory']);
% FigureWrap('A_inhNeighPC', 'A_inhNeighPC', 'delta sp/s', 'sec', NaN, NaN);

figure
hold on
counter = 1;
connCount = 0;
clear MLIB_PC
for n = 1:length(MLIsB_put)
    for k = 1:length(MLIsB_put(n).MLI_PC_Summary)
        if [MLIsB_put(n).MLI_PC_Summary(k).MLI_PC_dist] <=125
%              if [MLIsB_put(n).MLI_PC_Summary(k).inhBoo4SD] == 1
        MLIB_PC(counter).N = MLIsB_put(n).MLI_PC_Summary(k).N;
        edges = MLIsB_put(n).MLI_PC_Summary(k).edges;
        counter = counter + 1;
        if [MLIsB_put(n).MLI_PC_Summary(k).inhBoo4SD] == 1
            connCount = connCount + 1;
           end
%              end
        end
    end
end
shadedErrorBar2(edges, mean(struct2mat(MLIB_PC, 'N')), std(struct2mat(MLIB_PC, 'N'))/sqrt(size((struct2mat(MLIB_PC, 'N')),1)), 'lineProp', 'k')
text(.005, 3, [num2str(counter-1) ' close MLI1-PC pairs']);
text(.005, 4, [num2str(connCount) ' inhibitory']);
ylim([-15 5]);
% FigureWrap('B_inhNeighPC', 'B_inhNeighPC', 'delta sp/s', 'sec', NaN, NaN);
