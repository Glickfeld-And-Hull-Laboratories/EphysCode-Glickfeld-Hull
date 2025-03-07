k = 4;

close all
%reward delivery

ThisRecording = SS([SS.RecorNum] == k);
for n = 5
    figure
nexttile
[N, edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceTimes_clk, n, ThisRecording, -.1, .205, .005, [0 inf], 4, 'k', NaN, 0, 0);
[N_se, ~, ~] = OneUnitHistINDEX_sd(RecordingList(k).JuiceTimes_clk, n, SS, -.1, .205, .005, [0 inf]);
shadedErrorBar2(edges(1:end-1), N, N_se, 'LineProp', 'b');
end
ylim([0 100]);
FigureWrap(NaN, 'Rrd_lick_tile_c4exp_SS', NaN, NaN, NaN, NaN, .7, 2)

close all
ThisRecording = CS([CS.RecorNum] == k);
for n = 1
figure
nexttile
[N, edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceTimes_clk, n, ThisRecording, -.1, .205, .005, [0 inf], 4, 'k', NaN, 0, 0);
[N_se, ~, ~] = OneUnitHistINDEX_sd(RecordingList(k).JuiceTimes_clk, 27, CS, -.1, .205, .005, [0 inf]);
shadedErrorBar2(edges(1:end-1), N, N_se, 'LineProp', 'k');
end
FigureWrap(NaN, 'Rrd_lick_tile_c4exp_CS', NaN, NaN, NaN, NaN, .7, 2)

close all
ThisRecording = MLI([MLI.RecorNum] == k);
for n = 1:1
    figure
nexttile
[N, edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceTimes_clk, n, ThisRecording, -.1, .205, .005, [0 inf], 4, 'k', NaN, 0, 0);
[N_se, ~, ~] = OneUnitHistINDEX_sd(RecordingList(k).JuiceTimes_clk, 2, MLI, -.1, .205, .005, [0 inf]);
shadedErrorBar2(edges(1:end-1), N, N_se, 'LineProp', 'm');
end
FigureWrap(NaN, 'Rrd_lick_tile_c4exp_MLI', NaN, NaN, NaN, NaN, .7, 2)

close all
ThisRecording = Gol([Gol.RecorNum] == k);
for n = 1
figure
nexttile
[N, edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceTimes_clk, n, ThisRecording, -.1, .205, .005, [0 inf], 4, 'k', NaN, 0, 0);
[N_se, ~, ~] = OneUnitHistINDEX_sd(RecordingList(k).JuiceTimes_clk, 2, Gol, -.1, .205, .005, [0 inf]);
shadedErrorBar2(edges(1:end-1), N, N_se, 'LineProp', 'g');
end
% ylim([0 40]);
FigureWrap(NaN, 'Rrd_lick_tile_c4exp_Gol', NaN, NaN, NaN, NaN, .7, 2)

close all
ThisRecording = MF([MF.RecorNum] == k);
for n = 93
figure
nexttile
[N, edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceTimes_clk, n, ThisRecording, -.1, .205, .005, [0 inf], 4, 'k', NaN, 0, 0);
[N_se, ~, ~] = OneUnitHistINDEX_sd(RecordingList(k).JuiceTimes_clk, 15, MF, -.1, .205, .005, [0 inf]);
shadedErrorBar2(edges(1:end-1), N, N_se, 'LineProp', 'r');
end
ylim([-3 200]);
FigureWrap(NaN, 'Rrd_lick_tile_c4exp_MF', NaN, NaN, NaN, NaN, .7, 2)

figure
[N, edges] = LickHist(RecordingList(k).JuiceTimes_clk, RecordingList(k).AllLicks, [-.5 .55], .05, 'k', 0);
%N = N*(length(RecordingList(k).JuiceTimes_clk)*.05);
[N_se, edges] = LickHist_SE(RecordingList(k).JuiceTimes_clk, RecordingList(k).AllLicks, [-.5 .55], .05);
%N_se = N_se*(length(RecordingList(k).JuiceTimes_clk)*.05);
shadedErrorBar2(edges(1:end-1), N, N_se, 'LineProp', 'k');
 ylabel('licks/s');
 xlabel('time from reward delivery (s)');
FigureWrap(NaN, ['reward_lick_relation_c4_day_' num2str(RecordingList(k).day)], NaN, NaN, NaN, NaN, .7, 2)

