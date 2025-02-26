for n = 1:length(MLIs)
    if ~isempty([RecordingList(MLIs(n).RecorNum).LaserStimAdj])
        MLIs(n).TimeLim = [0 RecordingList(MLIs(n).RecorNum).LaserStimAdj(1)];
    else MLIs(n).TimeLim = [0 inf];
    end
end

for n = 1:length(MLIsA)
    if ~isempty([RecordingList(MLIsA(n).RecorNum).LaserStimAdj])
        MLIsA(n).TimeLim = [0 RecordingList(MLIsA(n).RecorNum).LaserStimAdj(1)];
    else MLIsA(n).TimeLim = [0 inf];
    end
end

for n = 1:length(MLIsB)
    if ~isempty([RecordingList(MLIsB(n).RecorNum).LaserStimAdj])
        MLIsB(n).TimeLim = [0 RecordingList(MLIsB(n).RecorNum).LaserStimAdj(1)];
    else MLIsB(n).TimeLim = [0 inf];
    end
end



figure
hold on
for n = 1:length(MLIsA)
    [N, edges, ~] = XcorrFastINDEX_TG(MLIsA, -.2, .2, .001, n, n, [RecordingList(MLIsA(n).RecorNum).RunningData.qsc_TGA], [RecordingList(MLIsA(n).RecorNum).RunningData.qsc_TGB], MLIsA(n).TimeLim(1), MLIsA(n).TimeLim(2), 'b', 0, SD, 0);
    Ns_A(n).N = N;
end
shadedErrorBar2(edges, mean(struct2mat(Ns_A, 'N')), std(struct2mat(Ns_A, 'N'))/sqrt(size((struct2mat(Ns_A, 'N')),1)), 'lineProp', 'm')

for n = 1:length(MLIsB)
    [N, edges, ~] = XcorrFastINDEX_TG(MLIsB, -.2, .2, .001, n, n, [RecordingList(MLIsB(n).RecorNum).RunningData.qsc_TGA], [RecordingList(MLIsB(n).RecorNum).RunningData.qsc_TGB], MLIsB(n).TimeLim(1), MLIsB(n).TimeLim(2), 'b', 0, SD, 0);
    Ns_B(n).N = N;
end
shadedErrorBar2(edges, mean(struct2mat(Ns_B, 'N')), std(struct2mat(Ns_B, 'N'))/sqrt(size((struct2mat(Ns_B, 'N')),1)), 'lineProp', 'g')

for n = 1:length(MLIs)
    [N, edges, ~] = XcorrFastINDEX_TG(MLIs, -.2, .2, .001, n, n, [RecordingList(MLIs(n).RecorNum).RunningData.qsc_TGA], [RecordingList(MLIs(n).RecorNum).RunningData.qsc_TGB], MLIs(n).TimeLim(1), MLIs(n).TimeLim(2), 'b', 0, SD, 0);
    Ns_All(n).N = N;
end
shadedErrorBar2(edges, mean(struct2mat(Ns_All, 'N')), std(struct2mat(Ns_All, 'N'))/sqrt(size((struct2mat(Ns_All, 'N')),1)), 'lineProp', 'k')
% FigureWrap('MLI type ACG', 'MLI_Type_ACG', 'time from MLI spike', 'MLI spikes/s', [-.1 .1], NaN);


figure
fullRange = [MLIs.FR_qsc];
support = [min(fullRange)-5 max(fullRange)+5];
[f,xi,bandw] = ksdensity(fullRange,  'support', support);
A = [MLIsA.FR_qsc];
B = [MLIsB.FR_qsc];
All = [MLIs.FR_qsc];
emptyCells = cellfun(@isempty,{MLIs.Type});
UnKn = [MLIs(emptyCells).FR_qsc];
violin([All].', support, 'x', [0 inf], {'All'}, 'facecolor', 'k', 'bw', bandw);
violin([A].', support, 'x', [.75 inf], {'A'}, 'facecolor', 'm', 'bw', bandw);
violin([B].', support, 'x', [1.5 inf], {'B'}, 'facecolor', 'g', 'bw', bandw);
violin([UnKn].', support, 'x', [2.25 inf], {'UnKn'}, 'facecolor', 'k', 'bw', bandw);
xlim([-.5 2.75]);
xticks([0 .75 1.5 2.25])
xticklabels({'All','A','B', 'UnKn'})
% FigureWrap('ViolinQscFR', 'ViolinQscFR', NaN, 'sp/sec (qsc)', NaN, [-3 80]);

[h,p] = kstest2(A, B)
