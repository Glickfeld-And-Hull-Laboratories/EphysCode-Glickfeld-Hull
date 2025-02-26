SD = 4;
binwidth = .0005;
counter = 1;

for n = 1:length(SumSt)
    tic
    n
    TGA = RecordingList(SumSt(n).RecorNum).RunningData.qsc_TGA;
    TGB = RecordingList(SumSt(n).RecorNum).RunningData.qsc_TGB;
       if strcmp({SumSt(n).CellType}, 'MLI')
           MLI_MLI_counter = 0;
            recNum = SumSt(n).RecorNum;
            for m = 1:length(SumSt)
                if recNum == SumSt(m).RecorNum
                if strcmp(SumSt(m).handID, 'MLI')
                    if n ~= m
                    MLI_MLI_counter = MLI_MLI_counter +1;
                    if isempty([RecordingList(recNum).LaserStimAdj])
                    [N, edges] = XcorrFastINDEX_TG(SumSt, -.02, .02, binwidth, n, m, TGA, TBG, 0, inf, 'k', 0, SD, 0);
                    else
                    [N, edges] = XcorrFastINDEX_TG(SumSt, -.02, .02, binwidth, n, m, TGA, TBG, 0, RecordingList(recNum).LaserStimAdj(1), 'k', 0, SD, 0);
                    end

        MLI_MLI(counter).indexDrive = n;
        MLI_MLI(counter).unitIDdrive = SumSt(n).unitID;
        MLI_MLI(counter).indexFollow = m;
        MLI_MLI(counter).unitIDfollow = SumSt(m).unitID;
        MLI_MLI(counter).N = N;
        MLI_MLI(counter).edges = edges;
        MLI_MLI(counter).dist = Cell2CellDistINDEX(SumSt, n, m, MEH_chanMap);
        MLI_MLI(counter).recordingID = SumSt(n).recordingID;
        MLI_MLI(counter).RecorNum = recNum;
        MLI_MLI(counter).originalIDdrive = SumSt(n).MLIexpertID;
        MLI_MLI(counter).originalIDFollow = SumSt(m).MLIexpertID;

  
    
    index = find(edges >= 0);
    ValueMin = min(N(index(2:((.001/binwidth)*6))));
    [meanLine, stdevLine] = StDevLine(N, edges, binwidth);
    %figure
    %plot(edges(1:end), N/meanLine)
    %yline((meanLine-SD*stdevLine)/meanLine, 'y');
    %title(['MLI_MLI index = ' num2str(n)])
     if ValueMin< (meanLine - SD*stdevLine)
     MLI_MLI(counter).inhSD4_4ms = 1;
     MLI_MLI_thisone(MLI_MLI_counter).inhBoo4SD = 1;
     else
     MLI_MLI(counter).inhSD4_4ms = 0;
     MLI_MLI_thisone(MLI_MLI_counter).inhBoo4SD = 0;
     end
     toc
     MLI_MLI_thisone(MLI_MLI_counter).indexDrive = n;
     MLI_MLI_thisone(MLI_MLI_counter).indexFollow = m;
     MLI_MLI_thisone(MLI_MLI_counter).MLI_MLI_dist = Cell2CellDistINDEX(SumSt, n, m, MEH_chanMap);
     MLI_MLI_thisone(MLI_MLI_counter).N = N;
     MLI_MLI_thisone(MLI_MLI_counter).edges = edges;
     MLI_MLI(counter).MLI_MLI_summary = MLI_MLI_thisone;
     if any([MLI_MLI_thisone.inhBoo4SD])
             SumSt(n).MLI_MLI_4SDinh = 1;
     else
             SumSt(n).MLI_MLI_4SDinh = 0;
     end
     SumSt(n).MLI_MLI_InhSummary = MLI_MLI_thisone;
     counter = counter + 1;
                    end
                end
                end
            end
            MLI_MLI_thisone = [];
            N = [];
            edges = [];
       end
end

SD = 4;
binwidth = .0005;
MLI_MLI_counter = 1;

for n = 1:length(MLI_MLI)
N = MLI_MLI(n).N;
edges = MLI_MLI(n).edges;
index = find(edges == 0);
Value0 = N(index);
[meanLine, stdevLine] = StDevLine(N, edges, -.005);

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















