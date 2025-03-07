
close all
for k = 1:length(RecordingList)
    Rxmin= -.5;
    Rxmax = 1.2;
    Lxmin = -.8;
    Lxmax = .7;
    Rbinwidth = .01;
    Lbinwidth = .01;
    Rxmin/Rbinwidth;
    binvalue0 = 150;
    colorRange = [-5 80];
    ThisRecording = CS_paired([CS_paired.RecorNum] == k);
    c = 1;
%     for n = 1:length(ThisRecording)
%     if(( ~isnan([ThisRecording(n).AllTone.Dir]) | ~isnan([ThisRecording(n).AllJuice.Dir]) | ~isnan([ThisRecording(n).JuiceAlone.Dir])))
%     RespSS(c) = ThisRecording(n);
%     c = c + 1;
%     end
%     end
%     ThisRecording = RespSS;

%choose trials
   TrialStruct = RecordingList(k).TrialStructOutcomes;
    %TrialStruct = TrialStruct(strcmp({TrialStruct.TrialType}, 'b'));

        figure
tiledlayout(2, 4, 'TileSpacing', 'compact', 'Padding', 'none')

nexttile
if ~isnan(RecordingList(k).JuiceAlone_clk_unpairedBlock)
%[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).ToneTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).JuiceAlone_clk_unpairedBlock, [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
%xlabel('time from cue on P trials');
xlabel(['time from reward on audible reward trials unpaired block day ' num2str(RecordingList(k).day)]);
ylabel('CSpk')
end

nexttile
if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).ToneTime].')
[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).ToneTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from cue on P trials');
end


nexttile
if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'r')).ToneTime].')
[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'r')).ToneTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from cue on R trials');
end

nexttile
if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'o')).ToneTime].')
[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'o')).ToneTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from cue on O trials');
end

Rxmin= -.5;
Rxmax = 1.2;
Lxmin = -.8;
Lxmax = .7;
Rbinwidth = .02;
Lbinwidth = .02;
Rxmin/Rbinwidth;
binvalue0 = 150;
colorRange = [-5 80];
ThisRecording = SS_paired([SS_paired.RecorNum] == k);

nexttile
if ~isnan(RecordingList(k).JuiceAlone_clk_unpairedBlock)
%[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).ToneTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
[N, edges] = cellHeatMap(ThisRecording, RecordingList(k).JuiceAlone_clk_unpairedBlock, [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
%xlabel('time from cue on P trials');
xlabel(['time from reward on audible reward trials unpaired block day ' num2str(RecordingList(k).day)]);
ylabel('SSpk')
end

nexttile
if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).ToneTime].')
[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).ToneTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from cue on P trials');
end


nexttile
if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'r')).ToneTime].')
[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'r')).ToneTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from cue on R trials');
end

nexttile
if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'o')).ToneTime].')
[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'o')).ToneTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, 1, NaN);
xlabel('time from cue on O trials');
end
 
FigureWrap(NaN, ['Paired_heatmap_trialOutcome_stim_toneResp_Abs' num2str(k)], NaN, NaN, NaN, NaN, 5, 16);
end
    