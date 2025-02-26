figure
hold on
counter = 1;
connCount = 0;
clear MLIA_PC
for n = 1:length(MLIsA)
    for k = 1:length(MLIsA(n).MLI_PC_Summary)
        if [MLIsA(n).MLI_PC_Summary(k).MLI_PC_dist] <=125
             if [MLIsA(n).MLI_PC_Summary(k).inhBoo4SD] == 1
        MLIA_PC(counter).N = MLIsA(n).MLI_PC_Summary(k).N;
        edges = MLIsA(n).MLI_PC_Summary(k).edges;
        counter = counter + 1;
        if [MLIsA(n).MLI_PC_Summary(k).inhBoo4SD] == 1
            connCount = connCount + 1;
           end
             end
        end
    end
end
shadedErrorBar2(edges, mean(struct2mat(MLIA_PC, 'N')), std(struct2mat(MLIA_PC, 'N'))/sqrt(size((struct2mat(MLIA_PC, 'N')),1)), 'lineProp', 'k')
%text(.005, 3, [num2str(counter-1) ' close MLI1-PC pairs']);
text(.005, 4, [num2str(connCount) ' inhibitory']);
% FigureWrap('A_inhNeighPC', 'A_inhNeighPC', 'delta sp/s', 'sec', NaN, NaN);
