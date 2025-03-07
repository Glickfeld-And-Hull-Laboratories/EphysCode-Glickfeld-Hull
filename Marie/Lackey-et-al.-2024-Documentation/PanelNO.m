binwidth = .01;
SS_pause = SumSt(strcmp({SumSt.handID}, 'SS_pause'));

% Determine which MLI1s & SSs are modulated (increase) at running onset for
% further analysis. All MLI2s are included.
minRespLat = -.25;
maxRespLat = .4;
StDevLim = -.5;

for n = 1:length(SS_pause)
 [SS_pause(n).move_TGA_N, SS_pause(n).move_TGA_edges, ~] = OneUnitHistStructTimeLimLineINDEX([RecordingList(SS_pause(n).RecorNum).RunningData.move_TGA].', n, SS_pause, -1, 1.5, binwidth, [0 inf], 4,'k', NaN, 0, 0);
edges = SS_pause(n).move_TGA_edges;
N = SS_pause(n).move_TGA_N;
 % baseline Stdev & mean
index0 = find(edges >= StDevLim)-1;
Prestim = N(1:index0);
stdevLine = std(Prestim);
meanLine = mean(Prestim);
EvalLimitHigh = meanLine + SD*stdevLine;
index1 = find(edges >= minRespLat, 1);
index2 = find(edges <= maxRespLat, 1, 'last');
EvalWindow = N(index1:index2);
EvalN = max(EvalWindow);
if EvalN > EvalLimitHigh
    SS_pause(n).OnsetMod = 1;
else
    SS_pause(n).OnsetMod = NaN;
end
end
sum([SS_pause.OnsetMod] == 1)
ModSS_pause = SS_pause([SS_pause.OnsetMod] == 1);

for n = 1:length(MLIsA)
 [MLIsA(n).move_TGA_N, MLIsA(n).move_TGA_edges, ~] = OneUnitHistStructTimeLimLineINDEX([RecordingList(MLIsA(n).RecorNum).RunningData.move_TGA].', MLIsA(n).MLI_PC_Summary(1).MLIindex, SumSt, -1, 1.5, binwidth, [0 inf], 4,'k', NaN, 0, 0);
edges = MLIsA(n).move_TGA_edges;
N = MLIsA(n).move_TGA_N;
 % baseline Stdev & mean
index0 = find(edges >= StDevLim)-1;
Prestim = N(1:index0);
stdevLine = std(Prestim);
meanLine = mean(Prestim);
EvalLimitHigh = meanLine + SD*stdevLine;
index1 = find(edges >= minRespLat, 1);
index2 = find(edges <= maxRespLat, 1, 'last');
EvalWindow = N(index1:index2);
EvalN = max(EvalWindow);
if EvalN > EvalLimitHigh
    MLIsA(n).OnsetMod = 1;
else
    MLIsA(n).OnsetMod = NaN;
end
end
sum([MLIsA.OnsetMod] == 1)
ModMLIsA = MLIsA([MLIsA.OnsetMod] == 1);


for n = 1:length(MLIsB)
 [MLIsB(n).qsc_TGA_N, MLIsB(n).qsc_TGA_edges, ~] = OneUnitHistStructTimeLimLineINDEX([RecordingList(MLIsB(n).RecorNum).RunningData.qsc_TGA].', MLIsB(n).MLI_PC_Summary(1).MLIindex, SumSt, -1, 1.5, binwidth, [0 inf], 4,'k', NaN, 0, 0);
 [MLIsB(n).move_TGA_N, MLIsB(n).move_TGA_edges, ~] = OneUnitHistStructTimeLimLineINDEX([RecordingList(MLIsB(n).RecorNum).RunningData.move_TGA].', MLIsB(n).MLI_PC_Summary(1).MLIindex, SumSt, -1, 1.5, binwidth, [0 inf], 4,'k', NaN, 0, 0);
 % MLIsB(n).qsc_TGA_N_z = zscore(MLIsB(n).qsc_TGA_N);
MLIsB(n).qsc_TGA_N_norm = (MLIsB(n).qsc_TGA_N)/mean(MLIsB(n).qsc_TGA_N(1:50));
MLIsB(n).move_TGA_N_norm = (MLIsB(n).move_TGA_N)/mean(MLIsB(n).move_TGA_N(1:50));
% MLIsB(n).qsc_TGA_N_norm = (MLIsB(n).qsc_TGA_N)/MLIsB(n).FR_Qsc1s_base;
end

for n = 1:length(ModSS_pause)
     [ModSS_pause(n).qsc_TGA_N, ModSS_pause(n).qsc_TGA_edges, ~] = OneUnitHistStructTimeLimLineINDEX([RecordingList(ModSS_pause(n).RecorNum).RunningData.qsc_TGA].', n, ModSS_pause, -1, 1.5, binwidth, [0 inf], 4,'k', NaN, 0, 0);
ModSS_pause(n).qsc_TGA_N_norm = (ModSS_pause(n).qsc_TGA_N)/mean(ModSS_pause(n).qsc_TGA_N(1:50));
ModSS_pause(n).move_TGA_N_norm = (ModSS_pause(n).move_TGA_N)/mean(ModSS_pause(n).move_TGA_N(1:50));
end

for n = 1:length(ModMLIsA)
     [ModMLIsA(n).qsc_TGA_N, ModMLIsA(n).qsc_TGA_edges, ~] = OneUnitHistStructTimeLimLineINDEX([RecordingList(ModMLIsA(n).RecorNum).RunningData.qsc_TGA].', ModMLIsA(n).MLI_PC_Summary(1).MLIindex, SumSt, -1, 1.5, binwidth, [0 inf], 4,'k', NaN, 0, 0);
ModMLIsA(n).qsc_TGA_N_norm = (ModMLIsA(n).qsc_TGA_N)/mean(ModMLIsA(n).qsc_TGA_N(1:50));
ModMLIsA(n).move_TGA_N_norm = (ModMLIsA(n).move_TGA_N)/mean(ModMLIsA(n).move_TGA_N(1:50));
end

 figure
shadedErrorBar2([ModMLIsA(1).qsc_TGA_edges(1:end-1)], nanmean(cell2mat({ModMLIsA.qsc_TGA_N_norm}.')), nanstd(cell2mat({ModMLIsA.qsc_TGA_N_norm}.'))/sqrt(size(cell2mat({ModMLIsA.qsc_TGA_N_norm}.'),1)), 'lineProp', 'm');
hold on
shadedErrorBar2([MLIsB(1).qsc_TGA_edges(1:end-1)], nanmean(cell2mat({MLIsB.qsc_TGA_N_norm}.')), nanstd(cell2mat({MLIsB.qsc_TGA_N_norm}.'))/sqrt(size(cell2mat({MLIsB.qsc_TGA_N_norm}.'),2)), 'lineProp', 'g');
 shadedErrorBar2([ModSS_pause(1).qsc_TGA_edges(1:end-1)], nanmean(cell2mat({ModSS_pause.qsc_TGA_N_norm}.')), nanstd(cell2mat({ModSS_pause.qsc_TGA_N_norm}.'))/sqrt(size(cell2mat({ModSS_pause.qsc_TGA_N_norm}.'),1)), 'lineProp', 'k');

xlim([-.5 .99])


 figure
shadedErrorBar2([ModMLIsA(1).move_TGA_edges(1:end-1)], nanmean(cell2mat({ModMLIsA.move_TGA_N_norm}.')), nanstd(cell2mat({ModMLIsA.move_TGA_N_norm}.'))/sqrt(size(cell2mat({ModMLIsA.move_TGA_N_norm}.'),1)), 'lineProp', 'm');
hold on
shadedErrorBar2([MLIsB(1).move_TGA_edges(1:end-1)], nanmean(cell2mat({MLIsB.move_TGA_N_norm}.')), nanstd(cell2mat({MLIsB.move_TGA_N_norm}.'))/sqrt(size(cell2mat({MLIsB.move_TGA_N_norm}.'),2)), 'lineProp', 'g');
 shadedErrorBar2([ModSS_pause(1).move_TGA_edges(1:end-1)], nanmean(cell2mat({ModSS_pause.move_TGA_N_norm}.')), nanstd(cell2mat({ModSS_pause.move_TGA_N_norm}.'))/sqrt(size(cell2mat({ModSS_pause.move_TGA_N_norm}.'),1)), 'lineProp', 'k');

xlim([-.5 .99])

% meanA = nanmean(cell2mat({ModMLIsA.qsc_TGA_N}.'));
% meanB = nanmean(cell2mat({MLIsB.qsc_TGA_N}.'));
% measnSS = nanmean(cell2mat({ModSS_pause.qsc_TGA_N}.'));
% figure
% shadedErrorBar2([ModMLIsA(1).qsc_TGA_edges(1:end-1)], meanA/mean(meanA(1:75)), nanstd(cell2mat({ModMLIsA.qsc_TGA_N_norm}.'))/sqrt(size(cell2mat({MLIsA.qsc_TGA_N_norm}.'),1)), 'lineProp', 'm');
% hold on
% shadedErrorBar2([MLIsB(1).qsc_TGA_edges(1:end-1)], nanmean(cell2mat({MLIsB.qsc_TGA_N_norm}.')), nanstd(cell2mat({MLIsB.qsc_TGA_N_norm}.'))/sqrt(size(cell2mat({MLIsB.qsc_TGA_N_norm}.'),2)), 'lineProp', 'g');
%  shadedErrorBar2([ModSS_pause(1).qsc_TGA_edges(1:end-1)], nanmean(cell2mat({ModSS_pause.qsc_TGA_N_norm}.')), nanstd(cell2mat({ModSS_pause.qsc_TGA_N_norm}.'))/sqrt(size(cell2mat({ModSS_pause.qsc_TGA_N_norm}.'),1)), 'lineProp', 'k');
% 
% xlim([-.5 .99])

counter = 1;
for n = 1:length(ModMLIsA)
    R = (ModMLIsA(n).RecorNum);
    [Nmean(counter,:), Nedges, N] = RunSpeedHistLines(RecordingList(R).RunningData.move_TGA, RecordingList(R).RunningData.SpeedTimesAdj, RecordingList(R).RunningData.SpeedValues, -1, 1);
    counter = counter +1;
end
for n = 1:length(ModSS_pause)
    R = (ModSS_pause(n).RecorNum);
    [Nmean(counter,:), Nedges, N] = RunSpeedHistLines(RecordingList(R).RunningData.move_TGA, RecordingList(R).RunningData.SpeedTimesAdj, RecordingList(R).RunningData.SpeedValues, -1, 1);
    counter = counter +1;
end
for n = 1:length(MLIsB)
    R = (MLIsB(n).RecorNum);
    [Nmean(counter,:), Nedges, N] = RunSpeedHistLines(RecordingList(R).RunningData.move_TGA, RecordingList(R).RunningData.SpeedTimesAdj, RecordingList(R).RunningData.SpeedValues, -1, 1);
    counter = counter +1;
end
figure
hold on
shadedErrorBar2(Nedges, mean(Nmean), std(Nmean)/sqrt(size(Nmean,1)), 'lineProp', 'b');


counter = 1;
for n = 1:length(ModMLIsA)
    R = (ModMLIsA(n).RecorNum);
    [Nmean(counter,:), Nedges, N] = RunSpeedHistLines(RecordingList(R).RunningData.qsc_TGA, RecordingList(R).RunningData.SpeedTimesAdj, RecordingList(R).RunningData.SpeedValues, -1, 1);
    counter = counter +1;
end
for n = 1:length(ModSS_pause)
    R = (ModSS_pause(n).RecorNum);
    [Nmean(counter,:), Nedges, N] = RunSpeedHistLines(RecordingList(R).RunningData.qsc_TGA, RecordingList(R).RunningData.SpeedTimesAdj, RecordingList(R).RunningData.SpeedValues, -1, 1);
    counter = counter +1;
end
for n = 1:length(MLIsB)
    R = (MLIsB(n).RecorNum);
    [Nmean(counter,:), Nedges, N] = RunSpeedHistLines(RecordingList(R).RunningData.qsc_TGA, RecordingList(R).RunningData.SpeedTimesAdj, RecordingList(R).RunningData.SpeedValues, -1, 1);
    counter = counter +1;
end
figure
hold on
shadedErrorBar2(Nedges, mean(Nmean), std(Nmean)/sqrt(size(Nmean,1)), 'lineProp', 'b');
xlim([-.5 1]);