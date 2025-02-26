counter = 1;
for n = 1:length(MLIsFav)
    tic
    n
        for m = 1:length(MLIsFav)
            if (MLIsFav(n).recordingNum == MLIsFav(m).recordingNum)
            if MLIsFav(n).unitID == MLIsFav(m).unitID
                if ~(m == n)
                    ohno.m = m;
                    ohno.n = n;
                end
            else
         [N, edges] = XcorrFastINDEX(MLIsFav, -.02, .02, .0005, n, m, 0, inf, 'k', 0, SD, 0);
         MLI_MLI(counter).indexDrive = n;
         MLI_MLI(counter).unitIDdrive = MLIsFav(n).unitID;
         MLI_MLI(counter).indexFollow = m;
         MLI_MLI(counter).unitIDfollow = MLIsFav(m).unitID;
         MLI_MLI(counter).N = N;
         MLI_MLI(counter).edges = edges;
         MLI_MLI(counter).dist = Cell2CellDistINDEX(MLIsFav, n, m, MEH_chanMap);
         MLI_MLI(counter).recordingID = MLIsFav(n).recordingID;
         toc
         counter = counter + 1;
         N = [];
         edges = [];
                end
            end
        end
end


binwidth = .0005;
for n = 1:length(MLI_MLI)
    N = MLI_MLI(n).N;
    edges = MLI_MLI(n).edges;
    index = find(edges >= 0);
    ValueMin = min(N(index(2:((.001/binwidth)*6))));
    [meanLine, stdevLine] = StDevLine(N, edges, binwidth);
    %figure
    %plot(edges(1:end), N/meanLine)
    %yline((meanLine-SD*stdevLine)/meanLine, 'y');
    %title(['MLI_MLI index = ' num2str(n)])
     if ValueMin< (meanLine - SD*stdevLine)
     MLI_MLI(n).inhSD4 = 1;
     end
end

for n = 1:length(MLI_MLI)
if MLI_MLI(n).inhSD4 == 1
MLIsFav(MLI_MLI(n).indexDrive).inhSD4_4ms_inhibitsMLI = 1;
MLIsFav(MLI_MLI(n).indexFollow).inhSD4_4ms_inhibBY_MLI = 1;
end
end

for n = 1:length(MLI_MLI)
    N = MLI_MLI(n).N;
    edges = MLI_MLI(n).edges;
    index = find(edges == 0);
    %ValueMax = min(N(index(2:((.001/binwidth)*6))));
    [meanLine, stdevLine] = StDevLine(N, edges, binwidth);
    %figure
    %plot(edges(1:end), N/meanLine)
    %yline((meanLine-SD*stdevLine)/meanLine, 'y');
    %title(['MLI_MLI index = ' num2str(n)])
     if N(index) > (meanLine + SD*stdevLine)
     MLI_MLI(n).syncSD4 = 1;
     end
end








