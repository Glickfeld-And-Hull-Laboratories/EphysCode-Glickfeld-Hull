counter = 1;
for n = 1:length(MLIsB)
    for k = 1:length(MLIsB(n).MLI_MLI_InhSummary)
        if MLIsB(n).MLI_MLI_InhSummary(k).inhBoo4SD
           Index(counter).MLIa =  MLIsB(n).MLI_MLI_InhSummary(k).indexFollow;
           Index(counter).MLIb = MLIsB(n).MLI_MLI_InhSummary(k).indexDrive;
           for p = 1:length(MLIsA)
               if MLIsA(p).MLI_PC_Summary(1).MLIindex == Index(counter).MLIa
                   Index(counter).Type = 'A';
                   Index(counter).PCindex = [MLIsA(p).MLI_PC_Summary.SSindex];
                   Index(counter).inhBoo = [MLIsA(p).MLI_PC_Summary.inhBoo4SD];
                   Index(counter).N = [MLIsA(p).MLI_PC_Summary.N];
                   Index(counter).edges = [MLIsA(p).MLI_PC_Summary.edges];
                   Index(counter).RecorNum = MLIsA(p).RecorNum;
                   Index(counter).MLI_N = MLIsB(n).MLI_MLI_InhSummary(k).N;
                   Index(counter).MLI_edges = MLIsB(n).MLI_MLI_InhSummary(k).edges;
               end    
           end
           counter = counter + 1;
        end
    end
end

counter =1;
for n = 1:length(Index)
    for k = 1:length(Index(n).PCindex)
        if Index(n).inhBoo(k) == 1
    PClist(counter).MLIb = Index(n).MLIb;
    PClist(counter).MLIa = Index(n).MLIa;
    PClist(counter).PC = Index(n).PCindex(k);
    PClist(counter).inhBoo = Index(n).inhBoo(k);
    PClist(counter).N = [Index(n).N(:,k)];
    PClist(counter).edges = [Index(n).N(:,k)];
    PClist(counter).RecorNum = Index(n).RecorNum;
    counter = counter + 1;
        end
    end
end

%split into three arrays
PClist_290 = PClist;
PClist_290(3:end) = [];
PClist(1:2) = [];
PClist_447 = PClist;
PClist_447(18:34) = [];
PClist_448 = PClist;
PClist_448(1:17) = [];
[uniquePC_447, index_447, ~] = unique([PClist_447.PC]);
[uniquePC_448, index_448, ~] = unique([PClist_448.PC]);

%remove duplicates
PClist_448_tester = PClist_448(index_448);
PClist_447_tester = PClist_447(index_447);


%re-concatenate
PClist = [PClist_290 PClist_447_tester PClist_448_tester];

for n = 1:length(PClist)
    [PClist(n).NewN, PClist(n).NewEdges] = XcorrFastINDEX_TG(SumSt, -.02, .02, .001,  PClist(n).MLIb, PClist(n).PC, RecordingList(10).RunningData.qsc_TGA, RecordingList(10).RunningData.qsc_TGB , 0, inf, 'm', 1, 4, 0);
    [PClist(n).Ncorr, ~, ~, ~] = XcorrFastINDEX_CorCorrect(SumSt, -.02, .02, .001,  PClist(n).MLIb, PClist(n).PC, RecordingList(10).RunningData.qsc_TGA, RecordingList(10).RunningData.qsc_TGB , 0, inf, 'k', 0, 4, 0); %times in seconds, n unit of interest for struct (.unitID= string, .timestamps= vector 
    PClist(n).N = PClist(n).NewN - PClist(n).Ncorr;
end
figure
hold on
shadedErrorBar2([PClist(1).NewEdges], mean([PClist.N].'), std(struct2mat(PClist, 'N'))/sqrt(size((struct2mat(PClist, 'N')),1)), 'lineProp', 'k')
xlabel('time from MLI2')
ylabel('delta PC sp/s')
[meanLine, stdevLine] = StDevLine(mean([PClist.N].'), [PClist(1).NewEdges], 0);
yline((meanLine + 4*stdevLine), 'k');
%  FigureWrap('Select MLI2 -> PC', 'SelectMLIB_PC', NaN, NaN, NaN, NaN);

figure
for n = 1:length(PClist)
    hold on
    plot(PClist(1).NewEdges, PClist(n).N)
end
