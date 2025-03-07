SD = 4;

MLI_MLI_counter = 1;

for n = 1:length(MLI_MLI)
N_200us = MLI_MLI(n).N_200us;
edges_200us = MLI_MLI(n).edges_200us;
index = find(MLI_MLI(n).edges_200us >= -.001 & MLI_MLI(n).edges_200us <= .001);
Value0 = mean(MLI_MLI(n).N_200us(index));
[meanLine, stdevLine] = StDevLine(N_200us, edges_200us, -.005);

if n >1
if MLI_MLI(n).indexDrive ~= MLI_MLI(n-1).indexDrive
    MLI_MLI_thisone = [];
    MLI_MLI_counter = 1;
else
    MLI_MLI_counter = MLI_MLI_counter + 1;
end
end

%figure
%plot(edges(1:end), N/meanLine)
%yline((meanLine-SD*stdevLine)/meanLine, 'y');
%title(['MLI_MLI index = ' num2str(n)])
     if Value0 > (meanLine + SD*stdevLine)
     MLI_MLI(n).syncSD4 = 1;
     MLI_MLI_thisone(MLI_MLI_counter).syncBoo4SD = 1;
     else
     MLI_MLI(n).syncSD4 = 0;
     MLI_MLI_thisone(MLI_MLI_counter).syncBoo4SD = 0;
     end

     MLI_MLI_thisone(MLI_MLI_counter).indexDrive = MLI_MLI(n).indexDrive;
     MLI_MLI_thisone(MLI_MLI_counter).indexFollow = MLI_MLI(n).indexFollow;
     MLI_MLI_thisone(MLI_MLI_counter).MLI_MLI_dist = MLI_MLI(n).dist;
     MLI_MLI_thisone(MLI_MLI_counter).N = N;
     MLI_MLI_thisone(MLI_MLI_counter).edges = edges;
     MLI_MLI(n).MLI_MLI_summarySync = MLI_MLI_thisone;
     
     if any([MLI_MLI_thisone.syncBoo4SD] == 1)
             SumSt(MLI_MLI(n).indexDrive).sync4SD = 1;
     else
             SumSt(MLI_MLI(n).indexDrive).sync4SD = 0;
     end
     SumSt(MLI_MLI(n).indexDrive).MLI_MLI_SyncSymmary = MLI_MLI_thisone; 
     
     
            N = [];
            edges = [];
end

