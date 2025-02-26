

 
Rxmin= -.1; 
Rxmax = .3;
Lxmin = -1;
Lxmax = 1;
Rbinwidth = .005;
Lbinwidth = .01;
Rxmin/Rbinwidth;
binvalue0 = 150;
colorRange = [-5 80];

%audibleRewardtimes
close all
for k = 1:length(RecordingList)
    ThisRecording = MF([MF.RecorNum] == k);
    figure
tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'none')
nexttile
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).JuiceAlone_clk, [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, NaN);
xlabel('time from audible reward (s)');
ylabel('MF #');
nexttile
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).ToneTimes, [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, NaN);
xlabel('time from tone (s)');
ylabel('MF #');
nexttile
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).EpochOnsets, [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, NaN);
xlabel('time from epoch onset (s)');
ylabel('MF #');
 FigureWrap(NaN, ['MF_heatmap_' num2str(k)], NaN, NaN, NaN, NaN, 1.2, 12);
  
    end

