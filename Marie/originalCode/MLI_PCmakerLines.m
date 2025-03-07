SD = 4;
binwidth = .0005;
counter = 1;
for n = 1:length(SumSt)
    tic
    n
       if strcmp({SumSt(n).CellType}, 'MLI')
           MLI_PC_counter = 0;
            recNum = SumSt(n).RecorNum;
            for m = 1:length(SumSt)
                if recNum == SumSt(m).RecorNum
                if strcmp(SumSt(m).handID, 'SS_pause')
                    MLI_PC_counter = MLI_PC_counter +1;
                    if isempty([RecordingList(recNum).LaserStimAdj])
                    [N, edges] = XcorrFastINDEX(SumSt, -.02, .02, binwidth, n, m, 0, inf, 'k', 0, SD, 0);
                    else
                    [N, edges] = XcorrFastINDEX(SumSt, -.02, .02, binwidth, n, m, 0, RecordingList(recNum).LaserStimAdj(1), 'k', 0, SD, 0);
                    end

        MLI_PC(counter).indexDrive = n;
        MLI_PC(counter).unitIDdrive = SumSt(n).unitID;
        MLI_PC(counter).indexFollow = m;
        MLI_PC(counter).unitIDfollow = SumSt(m).unitID;
        MLI_PC(counter).N = N;
        MLI_PC(counter).edges = edges;
        MLI_PC(counter).dist = Cell2CellDistINDEX(SumSt, n, m, MEH_chanMap);
        MLI_PC(counter).recordingID = SumSt(n).recordingID;
        MLI_PC(counter).RecorNum = recNum;
        MLI_PC(counter).originalID = SumSt(n).MLIexpertID;

  
         
    index = find(edges >= 0);
    ValueMin = min(N(index(2:((.001/binwidth)*4))));
    [meanLine, stdevLine] = StDevLine(N, edges, binwidth);
    %figure
    %plot(edges(1:end), N/meanLine)
    %yline((meanLine-SD*stdevLine)/meanLine, 'y');
    %title(['MLI_PC index = ' num2str(n)])
     if ValueMin< (meanLine - SD*stdevLine)
     MLI_PC(counter).inhSD4_4ms = 1;
     MLI_PC_thisone(MLI_PC_counter).inhBoo4SD = 1;
     else
     MLI_PC(counter).inhSD4_4ms = 0;
     MLI_PC_thisone(MLI_PC_counter).inhBoo4SD = 0;
     end
     toc
     MLI_PC_thisone(MLI_PC_counter).MLIindex = n;
     MLI_PC_thisone(MLI_PC_counter).SSindex = m;
     MLI_PC_thisone(MLI_PC_counter).MLI_PC_dist = Cell2CellDistINDEX(SumSt, n, m, MEH_chanMap);
     MLI_PC_thisone(MLI_PC_counter).N = N;
     MLI_PC_thisone(MLI_PC_counter).edges = edges;
     SumSt(n).MLI_PC_Summary = MLI_PC_thisone;
     MLI_PC(counter).MLI_PC_summary = MLI_PC_thisone;
     if any([MLI_PC_thisone.inhBoo4SD])
             SumSt(n).MLI_PC_4SDinh = 1;
     else
             SumSt(n).MLI_PC_4SDinh = 0;
     end
     counter = counter + 1;
                end
                end
            end
            MLI_PC_thisone = [];
            N = [];
            edges = [];
       end
end






%%%% old code %%%%

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


