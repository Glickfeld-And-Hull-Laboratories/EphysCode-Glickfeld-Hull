%figure
for n = 1:length(MLIs)
for k = 1:length(MLIs(n).MLI_PC_Summary)

%    nexttile
%    hold on
N = MLIs(n).PC_MLI(k).N;
edges = MLIs(n).PC_MLI(k).edges;

    index = find(edges > .003);
    ValueMin = min(N(index(1:((.001/binwidth)*15))));
    ValueMax = max(N(index(1:((.001/binwidth)*15))));
    [meanLine, stdevLine] = StDevLine(N, edges, -.006);
%    plot(MLIs(n).PC_MLI(k).edges, MLIs(n).PC_MLI(k).N)
    %figure
    %plot(edges(1:end), N/meanLine)
    %yline((meanLine-SD*stdevLine)/meanLine, 'y');
    %title(['MLIs index = ' num2str(n)])
%     yline(meanLine - 4*stdevLine, 'y');
%     yline(meanLine + 4*stdevLine, 'g');
%     xline(edges((.001/binwidth*15)+index(1)));
     
     if ValueMin < (meanLine - 4*stdevLine)
     MLIs(n).PC_MLI(k).inhBoo4SD_15ms = 1;
     %MLIs(n).PC_MLI_inhBoo4SD = 1;
     else
     MLIs(n).PC_MLI(k).inhBoo4SD_15ms = 0;
     end
    
     if ValueMax > (meanLine + 4*stdevLine)
     MLIs(n).PC_MLI(k).exBoo4SD_15ms = 1;
     %MLIs(n).PC_MLI_exBoo4SD = 1;
     else
     MLIs(n).PC_MLI(k).exBoo4SD_15ms = 0;
     end
     MLIs(n).PC_MLI(k).MLIindex = MLIs(n).MLI_PC_Summary(k).MLIindex;
     MLIs(n).PC_MLI(k).SSindex = MLIs(n).MLI_PC_Summary(k).SSindex;
     MLIs(n).PC_MLI(k).MLIs_dist = MLIs(n).MLI_PC_Summary(k).MLI_PC_dist;
     MLIs(n).PC_MLI(k).N = N;
     MLIs(n).PC_MLI(k).edges = edges;
     if any([MLIs(n).PC_MLI.inhBoo4SD_15ms])
             MLIs(n).PC_MLI_4SDinh = 1;
     else
             MLIs(n).PC_MLI_4SDinh = 0;
     end
     
     if any([MLIs(n).PC_MLI.exBoo4SD_15ms])
             MLIs(n).PC_MLI_4SDex = 1;
     else
             MLIs(n).PC_MLI_4SDex = 0;
     end
end
end

figure
hold on
for n = 1:length(MLIs)
for k = 1:length(MLIs(n).PC_MLI)
    if MLIs(n).PC_MLI(k).inhBoo4SD_15ms == 1
        N = MLIs(n).PC_MLI(k).N;
edges = MLIs(n).PC_MLI(k).edges;
    
    [meanLine, stdevLine] = StDevLine(N, edges, -.006);
 plot(MLIs(n).PC_MLI(k).edges, MLIs(n).PC_MLI(k).N)
    %figure
    %plot(edges(1:end), N/meanLine)
    %yline((meanLine-SD*stdevLine)/meanLine, 'y');
    %title(['MLIs index = ' num2str(n)])
%    yline(meanLine - 4*stdevLine, 'y');
%   yline(meanLine + 4*stdevLine, 'g');
%     xline(edges((.001/binwidth*15)+index(1)));
     
    end
end
end
