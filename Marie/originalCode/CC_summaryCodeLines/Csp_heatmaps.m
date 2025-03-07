bwidth = .005;
xmin = -.5;
xmax = .5;
xmin/bwidth;
binvalue0 = 80;

clear N_CS;
close all
for n = 1:length(CS)
            if ( ~isnan(CS(n).AllTone.Dir) | ~isnan(CS(n).AllJuice.Dir) | ~isnan(CS(n).JuiceAlone.Dir))
                   figure
                   nexttile
                [N_CS(n,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(CS(n).RecorNum).ToneTimes], n, CS, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 1, 0);
                xlim([-.1 .3]);
                nexttile         
                [N_CS(n,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(CS(n).RecorNum).JuiceAlone_clk], n, CS, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 1, 0);
                xlim([-.1 .3]);
            end
end




 
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
    for n = 1:length(ThisRecording)
    if(( ~isnan([ThisRecording(n).AllTone.Dir]) | ~isnan([ThisRecording(n).AllJuice.Dir]) | ~isnan([ThisRecording(n).JuiceAlone.Dir])))
    RespCS(c) = ThisRecording(n);
    c = c + 1;
    end
    end
    ThisRecording = RespCS;
        figure
tiledlayout(1, 5, 'TileSpacing', 'compact', 'Padding', 'none')
nexttile
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).JuiceAlone_clk, [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, [-2 20]);
xlabel('time from audible reward (s)');
ylabel(['CS # day ' num2str(RecordingList(k).day)]);
nexttile
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).ToneTimes, [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, [-2 20]);
xlabel('time from tone (s)');
ylabel('CS #');
nexttile
[N, edges] = cellHeatMap(ThisRecording, [RecordingList(k).LickOnsetPred.RecordTime].', [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, [-2 20]);
xlabel('time from epoch pred(s)');
ylabel('CS #');
  nexttile
[N, edges] = cellHeatMap(ThisRecording, [RecordingList(k).LickOnsetReact.RecordTime].' , [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, [-2 20]);
xlabel('time from epoch React (s)');
ylabel('CS #');
nexttile
[N, edges] = cellHeatMap(ThisRecording, [RecordingList(k).LickOnsetOutside.RecordTime].', [Lxmin Lxmax], Lbinwidth, [0 inf], 1, 0, 1, [-2 20]);
xlabel('time from epoch onset outside (s)');
ylabel('CS #');
 FigureWrap(NaN, ['CS_respive_heatmap_' num2str(k)], NaN, NaN, NaN, NaN, 1.2, 50);
    end