 
Rxmin= -.1; 
Rxmax = .8;
Lxmin = -1;
Lxmax = 1;
Rbinwidth = .005;
Lbinwidth = .01;
Rxmin/Rbinwidth;
binvalue0 = 150;
colorRange = [-5 80]; 


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

%choose trials
   TrialStruct = RecordingList(k).TrialStructOutcomes;
    %TrialStruct = TrialStruct(strcmp({TrialStruct.TrialType}, 'b'));

        figure
tiledlayout(1, 6, 'TileSpacing', 'compact', 'Padding', 'none')

nexttile
if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).JuiceTime].')
[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).JuiceTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, NaN);
xlabel('time from juice on P trials');
end
ylabel(['SS # day ' num2str(RecordingList(k).day)]);

nexttile
if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'r')).JuiceTime].')
[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'r')).JuiceTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, NaN);
xlabel('time from juice on R trials');
end

nexttile
if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'o')).JuiceTime].')
[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'o')).JuiceTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, NaN);
xlabel('time from juice on O trials');
end

nexttile
if ~isnan( [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).ToneTime].')
[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).ToneTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, NaN);
xlabel('time from cue on P trials');
end


nexttile
if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'r')).ToneTime].')
[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'r')).ToneTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, NaN);
xlabel('time from cue on R trials');
end

nexttile
if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'o')).ToneTime].')
[N, edges] = cellHeatMap(ThisRecording, [TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'o')).ToneTime].', [Rxmin Rxmax], Rbinwidth, [0 inf], 1, 0, 1, NaN);
xlabel('time from cue on P trials');
end
 FigureWrap(NaN, ['SS_heatmap_trialOutcome_stim' num2str(k)], NaN, NaN, NaN, NaN, 1.2, 30);
end
    