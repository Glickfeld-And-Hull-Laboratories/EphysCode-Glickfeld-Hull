SD = 4;
counter = 1;
for n = 1:length(MLIsFav)
    tic
    n
        for m = 1:length(SumSt)
            if (MLIsFav(n).recordingNum == SumSt(m).recordingNum)
            if MLIsFav(n).unitID == SumSt(m).unitID
                k = m;
            end
            end
        end
        for m = 1:length(SumSt)
            if (MLIsFav(n).recordingNum == SumSt(m).recordingNum)
                if strcmp(SumSt(m).handID, 'SS_pause')
            if MLIsFav(n).unitID == SumSt(m).unitID
            else
         [N, edges] = XcorrFastINDEX(SumSt, -.02, .02, .0005, k, m, 0, inf, 'k', 0, SD, 0);
        MLI_PC(counter).indexMLIsFavDrive = n;
        MLI_PC(counter).indexSumStDrive = k;
        MLI_PC(counter).unitIDdrive = MLIsFav(n).unitID;
        MLI_PC(counter).indexSumStFollow = m;
        MLI_PC(counter).unitIDfollow = SumSt(m).unitID;
        MLI_PC(counter).N = N;
        MLI_PC(counter).edges = edges;
        MLI_PC(counter).dist = Cell2CellDistINDEX(SumSt, k, m, MEH_chanMap);
        MLI_PC(counter).recordingID = MLIsFav(n).recordingID;
         toc
         counter = counter + 1;
         N = [];
         edges = [];
            end
                end
            end
        end
end

binwidth = .0005;
for n = 1:length(MLI_PC)
    N = MLI_PC(n).N;
    edges = MLI_PC(n).edges;
    index = find(edges >= 0);
    ValueMin = min(N(index(2:((.001/binwidth)*4))));
    [meanLine, stdevLine] = StDevLine(N, edges, binwidth);
    %figure
    %plot(edges(1:end), N/meanLine)
    %yline((meanLine-SD*stdevLine)/meanLine, 'y');
    %title(['MLI_PC index = ' num2str(n)])
     if ValueMin< (meanLine - SD*stdevLine)
     MLI_PC(n).inhSD4_4ms = 1;
     end
end

for n = 1:length(MLI_PC)
if MLI_PC(n).inhSD4_4ms == 1
N = MLI_PC(n).N;
edges = MLI_PC(n).edges;
index = find(edges >= 0)-1;
ValueMin = min(N(index));
[meanLine, stdevLine] = StDevLine(N, edges, -.005);
%figure
plot(edges(1:end), N/meanLine)
yline((meanLine-SD*stdevLine)/meanLine, 'y');
title(['MLI_PC index = ' num2str(n)])
end
end


