bwidth = .01;
SS_pause = SumSt(strcmp({SumSt.handID}, 'SS_pause'));


for n = 1:length(MLIsA)
    if isempty([RecordingList(MLIsA(n).RecorNum).LaserStimAdj])
[MLIsA(n).FR_Run100ms, edges] = FRstructTimeGridTimeLimitINDEX2(RecordingList(MLIsA(n).RecorNum).RunningData.move_TGA+0, RecordingList(MLIsA(n).RecorNum).RunningData.move_TGA+.05, [0 inf], SumSt,  MLIsA(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
[MLIsA(n).FR_Run100ms_base, ~] = FRstructTimeGridTimeLimitINDEX2(RecordingList(MLIsA(n).RecorNum).RunningData.move_TGA-1, RecordingList(MLIsA(n).RecorNum).RunningData.move_TGA-.25, [0 inf], SumSt,  MLIsA(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
    else
        [MLIsA(n).FR_Run100ms, ~] = FRstructTimeGridTimeLimitINDEX2([RecordingList(MLIsA(n).RecorNum).RunningData.move_TGA+0], [RecordingList(MLIsA(n).RecorNum).RunningData.move_TGA+.05], [0 RecordingList(MLIsA(n).RecorNum).LaserStimAdj(1)], SumSt,  MLIsA(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
        [MLIsA(n).FR_Run100ms_base, ~] = FRstructTimeGridTimeLimitINDEX2([RecordingList(MLIsA(n).RecorNum).RunningData.move_TGA-1], [RecordingList(MLIsA(n).RecorNum).RunningData.move_TGA-.25], [0 RecordingList(MLIsA(n).RecorNum).LaserStimAdj(1)], SumSt,  MLIsA(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
    end
    MLIsA(n).FR_Run100ms_norm = MLIsA(n).FR_Run100ms/MLIsA(n).FR_qsc;
    MLIsA(n).FR_Run100ms_norm2 = MLIsA(n).FR_Run100ms/MLIsA(n).FR_Run100ms_base;
end

for n = 1:length(MLIsA)
    if isempty([RecordingList(MLIsA(n).RecorNum).LaserStimAdj])
[MLIsA(n).FR_Qsc1s, ~] = FRstructTimeGridTimeLimitINDEX2(RecordingList(MLIsA(n).RecorNum).RunningData.qsc_TGA+.95, RecordingList(MLIsA(n).RecorNum).RunningData.qsc_TGA+1, [0 inf], SumSt,  MLIsA(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
    [MLIsA(n).FR_Qsc1s_base, ~] = FRstructTimeGridTimeLimitINDEX2(RecordingList(MLIsA(n).RecorNum).RunningData.qsc_TGA-1, RecordingList(MLIsA(n).RecorNum).RunningData.qsc_TGA-.25, [0 inf], SumSt,  MLIsA(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
    else
        [MLIsA(n).FR_Qsc1s, ~] = FRstructTimeGridTimeLimitINDEX2([RecordingList(MLIsA(n).RecorNum).RunningData.qsc_TGA+.95], [RecordingList(MLIsA(n).RecorNum).RunningData.qsc_TGA+1], [0 RecordingList(MLIsA(n).RecorNum).LaserStimAdj(1)], SumSt,  MLIsA(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
            [MLIsA(n).FR_Qsc1s_base, ~] = FRstructTimeGridTimeLimitINDEX2([RecordingList(MLIsA(n).RecorNum).RunningData.qsc_TGA-1], [RecordingList(MLIsA(n).RecorNum).RunningData.qsc_TGA-.25], [0 RecordingList(MLIsA(n).RecorNum).LaserStimAdj(1)], SumSt,  MLIsA(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
    end
    MLIsA(n).FR_Qsc1s_norm = MLIsA(n).FR_Qsc1s/MLIsA(n).FR_move;
    MLIsA(n).FR_Qsc1s_norm2 = MLIsA(n).FR_Qsc1s/MLIsA(n).FR_Qsc1s_base;
end

for n = 1:length(MLIsB)
    if isempty([RecordingList(MLIsB(n).RecorNum).LaserStimAdj])
[MLIsB(n).FR_Run100ms, ~] = FRstructTimeGridTimeLimitINDEX2(RecordingList(MLIsB(n).RecorNum).RunningData.move_TGA+0, RecordingList(MLIsB(n).RecorNum).RunningData.move_TGA+.05, [0 inf], SumSt,  MLIsB(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
   [MLIsB(n).FR_Run100ms_base, ~] = FRstructTimeGridTimeLimitINDEX2(RecordingList(MLIsB(n).RecorNum).RunningData.move_TGA-1, RecordingList(MLIsB(n).RecorNum).RunningData.move_TGA-.25, [0 inf], SumSt,  MLIsB(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
    else [MLIsB(n).FR_Run100ms, ~] = FRstructTimeGridTimeLimitINDEX2([RecordingList(MLIsB(n).RecorNum).RunningData.move_TGA+0], [RecordingList(MLIsB(n).RecorNum).RunningData.move_TGA+.05], [0 RecordingList(MLIsB(n).RecorNum).LaserStimAdj(1)], SumSt,  MLIsB(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
[MLIsB(n).FR_Run100ms_base, ~] = FRstructTimeGridTimeLimitINDEX2([RecordingList(MLIsB(n).RecorNum).RunningData.move_TGA-1], [RecordingList(MLIsB(n).RecorNum).RunningData.move_TGA-.25], [0 RecordingList(MLIsB(n).RecorNum).LaserStimAdj(1)], SumSt,  MLIsB(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
    end
    MLIsB(n).FR_Run100ms_norm = MLIsB(n).FR_Run100ms/MLIsB(n).FR_qsc;
    MLIsB(n).FR_Run100ms_norm2 = MLIsB(n).FR_Run100ms/MLIsB(n).FR_Run100ms_base;
end

for n = 1:length(MLIsB)
    if isempty([RecordingList(MLIsB(n).RecorNum).LaserStimAdj])
[MLIsB(n).FR_Qsc1s, ~] = FRstructTimeGridTimeLimitINDEX2(RecordingList(MLIsB(n).RecorNum).RunningData.qsc_TGA+.95, RecordingList(MLIsB(n).RecorNum).RunningData.qsc_TGA+1, [0 inf], SumSt,  MLIsB(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
    [MLIsB(n).FR_Qsc1s_base, ~] = FRstructTimeGridTimeLimitINDEX2(RecordingList(MLIsB(n).RecorNum).RunningData.qsc_TGA-1, RecordingList(MLIsB(n).RecorNum).RunningData.qsc_TGA-.25, [0 inf], SumSt,  MLIsB(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
    else
        [MLIsB(n).FR_Qsc1s, ~] = FRstructTimeGridTimeLimitINDEX2([RecordingList(MLIsB(n).RecorNum).RunningData.qsc_TGA+.95], [RecordingList(MLIsB(n).RecorNum).RunningData.qsc_TGA+1], [0 RecordingList(MLIsB(n).RecorNum).LaserStimAdj(1)], SumSt,  MLIsB(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
        [MLIsB(n).FR_Qsc1s_base, ~] = FRstructTimeGridTimeLimitINDEX2([RecordingList(MLIsB(n).RecorNum).RunningData.qsc_TGA-1], [RecordingList(MLIsB(n).RecorNum).RunningData.qsc_TGA-.25], [0 RecordingList(MLIsB(n).RecorNum).LaserStimAdj(1)], SumSt,  MLIsB(n).MLI_PC_Summary(1).MLIindex, 'k', 0, bwidth);
    end
    MLIsB(n).FR_Qsc1s_norm = MLIsB(n).FR_Qsc1s/MLIsB(n).FR_move;
    MLIsB(n).FR_Qsc1s_norm2 = MLIsB(n).FR_Qsc1s/MLIsB(n).FR_Qsc1s_base;
end

%did the first time to make to make a list of PC
%SS_pause = SumSt(strcmp('SS_pause', {SumSt.handID}));

for n = 1:length(SS_pause)
    if isempty([RecordingList(SS_pause(n).RecorNum).LaserStimAdj])
[SS_pause(n).FR_Run100ms, ~] = FRstructTimeGridTimeLimitINDEX2(RecordingList(SS_pause(n).RecorNum).RunningData.move_TGA+0, RecordingList(SS_pause(n).RecorNum).RunningData.move_TGA+.05, [0 inf], SS_pause,  n, 'k', 0, bwidth);
 [SS_pause(n).FR_Run100ms_base, ~] = FRstructTimeGridTimeLimitINDEX2(RecordingList(SS_pause(n).RecorNum).RunningData.move_TGA-1, RecordingList(SS_pause(n).RecorNum).RunningData.move_TGA-.25, [0 inf], SS_pause,  n, 'k', 0, bwidth);
    else
        [SS_pause(n).FR_Run100ms, ~] = FRstructTimeGridTimeLimitINDEX2([RecordingList(SS_pause(n).RecorNum).RunningData.move_TGA+0], [RecordingList(SS_pause(n).RecorNum).RunningData.move_TGA+.05], [0 RecordingList(SS_pause(n).RecorNum).LaserStimAdj(1)], SS_pause,  n, 'k', 0, bwidth);
        [SS_pause(n).FR_Run100ms_base, ~] = FRstructTimeGridTimeLimitINDEX2([RecordingList(SS_pause(n).RecorNum).RunningData.move_TGA-1], [RecordingList(SS_pause(n).RecorNum).RunningData.move_TGA-.25], [0 RecordingList(SS_pause(n).RecorNum).LaserStimAdj(1)], SS_pause,  n, 'k', 0, bwidth);
    end
    SS_pause(n).FR_Run100ms_norm = SS_pause(n).FR_Run100ms/SS_pause(n).FR_qsc;
    SS_pause(n).FR_Run100ms_norm2 = SS_pause(n).FR_Run100ms/SS_pause(n).FR_Run100ms_base;
end

for n = 1:length(SS_pause)
    if isempty([RecordingList(SS_pause(n).RecorNum).LaserStimAdj])
[SS_pause(n).FR_Qsc1s, ~] = FRstructTimeGridTimeLimitINDEX2(RecordingList(SS_pause(n).RecorNum).RunningData.qsc_TGA+.95, RecordingList(SS_pause(n).RecorNum).RunningData.qsc_TGA+1, [0 inf], SS_pause, n, 'k', 0, bwidth);
[SS_pause(n).FR_Qsc1s_base, ~] = FRstructTimeGridTimeLimitINDEX2(RecordingList(SS_pause(n).RecorNum).RunningData.qsc_TGA-1, RecordingList(SS_pause(n).RecorNum).RunningData.qsc_TGA-.25, [0 inf], SS_pause, n, 'k', 0, bwidth);
    else
        [SS_pause(n).FR_Qsc1s, ~] = FRstructTimeGridTimeLimitINDEX2([RecordingList(SS_pause(n).RecorNum).RunningData.qsc_TGA+.95], [RecordingList(SS_pause(n).RecorNum).RunningData.qsc_TGA+1], [0 RecordingList(SS_pause(n).RecorNum).LaserStimAdj(1)], SS_pause, n, 'k', 0, bwidth);
        [SS_pause(n).FR_Qsc1s_base, ~] = FRstructTimeGridTimeLimitINDEX2([RecordingList(SS_pause(n).RecorNum).RunningData.qsc_TGA-1], [RecordingList(SS_pause(n).RecorNum).RunningData.qsc_TGA-.25], [0 RecordingList(SS_pause(n).RecorNum).LaserStimAdj(1)], SS_pause, n, 'k', 0, bwidth);
    end
    SS_pause(n).FR_Qsc1s_norm = SS_pause(n).FR_Qsc1s/SS_pause(n).FR_move;
    SS_pause(n).FR_Qsc1s_norm2 = SS_pause(n).FR_Qsc1s/SS_pause(n).FR_Qsc1s_base;
end


% this version uses a different baseline than the original- norm22- that
% norm2alizes to the period just before analysis rather than the whole qsc
% or movement period.
% 
% figure
% hold on
% size(edges)
% tester =(cell2mat({MLIsB.FR_Qsc1s_base}));
% shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({MLIsB.FR_Qsc1s_base}.')), std(cell2mat({MLIsB.qsc_TGA_N_norm}.'))/sqrt(size(cell2mat({MLIsB.FR_Qsc1s_base}.'),1)), 'lineProp', 'g');
% 
% 
% 
% 



mliRange = [[MLIsA.FR_Run100ms_norm2] [MLIsB.FR_Run100ms_norm2]];
support = [min(mliRange)-5 max(mliRange)+5];
[f,xi,bandw] = ksdensity(mliRange,  'support', support);
figure
violin([MLIsA.FR_Run100ms_norm2].', support, 'x', [0 inf], {'testerA_far'}, 'facecolor', 'm', 'bw', bandw);
violin([MLIsB.FR_Run100ms_norm2].', support, 'x', [.75 inf], {'testerA_far'}, 'facecolor', 'g', 'bw', bandw);
violin([SS_pause.FR_Run100ms_norm2].', support, 'x', [1.5 inf], {'testerA_far'}, 'facecolor', 'k', 'bw', bandw);

xlim([-.4 2]);
ylim([0 3.5])
xticks([0 .75 1.5])
xticklabels({'MLIA','MLIB','PC'})
legend('off')
%FigureWrap('violin running onset norm2', 'violinAroundRunOnsetNorm2', NaN, 'norm2 sp/sec', NaN, [-.5 6.5]);

% p = ranksum([MLIsA.FR_Run100ms_norm2].',[MLIsB.FR_Run100ms_norm2].')
% p = ranksum([MLIsA.FR_Run100ms_norm2].',[SS_pause.FR_Run100ms_norm2].')
% p = ranksum([MLIsB.FR_Run100ms_norm2].',[SS_pause.FR_Run100ms_norm2].')
figure
norm2Rates = [[MLIsA.FR_Run100ms_norm2] [MLIsB.FR_Run100ms_norm2] [SS_pause.FR_Run100ms_norm2]];
groupVar = [[zeros(1,length([MLIsA.FR_Run100ms_norm2]))] [zeros(1,length([MLIsB.FR_Run100ms_norm2]))+1] [zeros(1,length([SS_pause.FR_Run100ms_norm2]))+2]]; 
[p,tbl,stats] = kruskalwallis(norm2Rates,groupVar,'off')
c = multcompare(stats, 'CType', 'dunn-sidak')



mliRange = [[MLIsA.FR_Qsc1s_norm2] [MLIsB.FR_Qsc1s_norm2]];
support = [min(mliRange)-5 max(mliRange)+5];
[f,xi,bandw] = ksdensity(mliRange,  'support', support);
figure
violin([MLIsA.FR_Qsc1s_norm2].', support, 'x', [0 inf], {'testerA_far'}, 'facecolor', 'm', 'bw', bandw);
violin([MLIsB.FR_Qsc1s_norm2].', support, 'x', [.75 inf], {'testerA_far'}, 'facecolor', 'g', 'bw', bandw);
violin([SS_pause.FR_Qsc1s_norm2].', support, 'x', [1.5 inf], {'testerA_far'}, 'facecolor', 'k', 'bw', bandw);

xlim([-.4 2]);
ylim([-.1 2])
xticks([0 .75 1.5])
xticklabels({'MLIA','MLIB','PC'})
legend('off')
%FigureWrap('violin qsc onset norm2', 'violinAroundQscOnsetNorm2', NaN, 'norm2 sp/sec', NaN, [-.1 2]);


 p = ranksum([MLIsA.FR_Qsc1s_norm2].',[MLIsB.FR_Qsc1s_norm2].')
% p = ranksum([MLIsA.FR_Qsc1s_norm2].',[SS_pause.FR_Qsc1s_norm2].')
% p = ranksum([MLIsB.FR_Qsc1s_norm2].',[SS_pause.FR_Qsc1s_norm2].')

figure
norm2Rates = [[MLIsA.FR_Qsc1s_norm2] [MLIsB.FR_Qsc1s_norm2] [SS_pause.FR_Qsc1s_norm2]];
groupVar = [[zeros(1,length([MLIsA.FR_Run100ms_norm2]))] [zeros(1,length([MLIsB.FR_Run100ms_norm2]))+1] [zeros(1,length([SS_pause.FR_Run100ms_norm2]))+2]]; 
[p,tbl,stats] = kruskalwallis(norm2Rates,groupVar,'off')
c = multcompare(stats, 'CType', 'dunn-sidak')

% MLIsTyped = MLIs;
% [MLIsTyped.CellType_old] = MLIsTyped.CellType; MLIsTyped = orderfields(MLIsTyped,[1:25,45,26:44]); MLIsTyped = rmfield(MLIsTyped,'CellType');
% [MLIsTyped.CellType] = MLIsTyped.Type; MLIsTyped = orderfields(MLIsTyped,[1:39,45,40:44]); MLIsTyped = rmfield(MLIsTyped,'Type');
% MLIsTyped(1).BrainReg = [];