
 
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
    ThisRecording = CS([CS.RecorNum] == k);
    c = 1;
%     for n = 1:length(ThisRecording)
%     if(( ~isnan([ThisRecording(n).AllTone.Dir]) | ~isnan([ThisRecording(n).AllJuice.Dir]) | ~isnan([ThisRecording(n).JuiceAlone.Dir])))
%     RespCS(c) = ThisRecording(n);
%     c = c + 1;
%     end
%     end
%     ThisRecording = RespCS;
        figure
tiledlayout(1, 5, 'TileSpacing', 'compact', 'Padding', 'none')
nexttile
if ~isempty(RecordingList(k).JuiceAlone_clk)
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).JuiceAlone_clk, [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, [-2 20]);
end
xlabel('time from audible reward (s)');
ylabel(['CS # day ' num2str(RecordingList(k).day)]);
nexttile
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).ToneTimes, [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, [-2 20]);
xlabel('time from tone (s)');

nexttile
[N, edges] = cellHeatMap(ThisRecording, [RecordingList(k).LickOnsetPred.RecordTime].', [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, 1, [-2 20]);
xlabel('time from epoch pred(s)');

  nexttile
[N, edges] = cellHeatMap(ThisRecording, [RecordingList(k).LickOnsetReact.RecordTime].' , [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, 1, [-2 20]);
xlabel('time from epoch React (s)');

nexttile
[N, edges] = cellHeatMap(ThisRecording, [RecordingList(k).LickOnsetOutside.RecordTime].', [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, 1, [-2 20]);
xlabel('time from epoch onset outside (s)');

 FigureWrap(NaN, ['CS_heatmap_' num2str(k)], NaN, NaN, NaN, NaN, 1.2, 30);
end
    
close all
for k = 1:length(RecordingList)
    ThisRecording = SS([SS.RecorNum] == k);
    c = 1;
%     for n = 1:length(ThisRecording)
%     if(( ~isnan([ThisRecording(n).AllTone.Dir]) | ~isnan([ThisRecording(n).AllJuice.Dir]) | ~isnan([ThisRecording(n).JuiceAlone.Dir])))
%     RespSS(c) = ThisRecording(n);
%     c = c + 1;
%     end
%     end
%     ThisRecording = RespSS;
        figure
tiledlayout(1, 5, 'TileSpacing', 'compact', 'Padding', 'none')
nexttile
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).JuiceAlone_clk, [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from audible reward (s)');
ylabel(['SS # day ' num2str(RecordingList(k).day)]);
nexttile
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).ToneTimes, [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from tone (s)');

nexttile
[N, edges] = cellHeatMap(ThisRecording, [RecordingList(k).LickOnsetPred.RecordTime].', [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from epoch pred(s)');

  nexttile
[N, edges] = cellHeatMap(ThisRecording, [RecordingList(k).LickOnsetReact.RecordTime].' , [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from epoch React (s)');

nexttile
[N, edges] = cellHeatMap(ThisRecording, [RecordingList(k).LickOnsetOutside.RecordTime].', [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from epoch onset outside (s)');

 FigureWrap(NaN, ['SS_heatmap' num2str(k)], NaN, NaN, NaN, NaN, 1.2, 30);
end
    
close all
for k = 1:length(RecordingList)
    ThisRecording = MF([MF.RecorNum] == k);
    c = 1;
%     for n = 1:length(ThisRecording)
%     if(( ~isnan([ThisRecording(n).AllTone.Dir]) | ~isnan([ThisRecording(n).AllJuice.Dir]) | ~isnan([ThisRecording(n).JuiceAlone.Dir])))
%     RespMF(c) = ThisRecording(n);
%     c = c + 1;
%     end
%     end
%     ThisRecording = RespMF;
        figure
tiledlayout(1, 5, 'TileSpacing', 'compact', 'Padding', 'none')
nexttile
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).JuiceAlone_clk, [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from audible reward (s)');
ylabel(['MF # day ' num2str(RecordingList(k).day)]);
nexttile
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).ToneTimes, [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from tone (s)');

nexttile
[N, edges] = cellHeatMap(ThisRecording, [RecordingList(k).LickOnsetPred.RecordTime].', [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from epoch pred(s)');

  nexttile
[N, edges] = cellHeatMap(ThisRecording, [RecordingList(k).LickOnsetReact.RecordTime].' , [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from epoch React (s)');

nexttile
[N, edges] = cellHeatMap(ThisRecording, [RecordingList(k).LickOnsetOutside.RecordTime].', [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from epoch onset outside (s)');

 FigureWrap(NaN, ['MF_heatmap' num2str(k)], NaN, NaN, NaN, NaN, 1.2, 30);
    end