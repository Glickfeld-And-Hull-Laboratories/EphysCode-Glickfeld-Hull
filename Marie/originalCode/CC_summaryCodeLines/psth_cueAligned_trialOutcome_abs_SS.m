 
Rxmin= -.5; 
Rxmax = 1.2;
Lxmin = -.8;
Lxmax = .7;
Rbinwidth = .01;
Lbinwidth = .01;
Rxmin/Rbinwidth;
binvalue0 = 150;
colorRange = [-5 80]; 
C = colororder;

close all
figure
tiledlayout(9, 2, 'TileSpacing', 'compact', 'Padding', 'none')

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

        
%tiledlayout(1, 6, 'TileSpacing', 'compact', 'Padding', 'none')

nexttile
if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).ToneTime].')
    clear N
    clear addthis
for n = 1:length(ThisRecording)
    [addthis(1,:), edges] = OneUnitHistStructTimeLimLineINDEX([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).ToneTime].', n, ThisRecording, Rxmin, Rxmax, Rbinwidth, [0 inf], 4, 'k', NaN, 0, 0);
        [meanLine, stdevLine] = StDevLine(addthis, edges, 0);           % calc for z-score
        addthis = (addthis - meanLine)/stdevLine;                               % z-score
            addthis = abs(addthis);                                             % abs val
            addthis = smoothdata(addthis, 'sgolay', 11);
    N(n,:) = addthis;
end
shadedErrorBar2(edges(1:end-1), mean(N), std(N)/sqrt(size(N, 1)), 'lineProp', {C(1,:)});
end
xlabel(['time from cue on day ' num2str(RecordingList(ThisRecording(1).RecorNum).day)]);
hold on



if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'r')).ToneTime].')
    clear N
    clear addthis
for n = 1:length(ThisRecording)
    [addthis(1,:), edges] = OneUnitHistStructTimeLimLineINDEX([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'r')).ToneTime].', n, ThisRecording, Rxmin, Rxmax, Rbinwidth, [0 inf], 4, 'k', NaN, 0, 0);
        [meanLine, stdevLine] = StDevLine(addthis, edges, 0);           % calc for z-score
        addthis = (addthis - meanLine)/stdevLine;                               % z-score
            addthis = abs(addthis);                                             % abs val
            addthis = smoothdata(addthis, 'sgolay', 11);
    N(n,:) = addthis;
end
shadedErrorBar2(edges(1:end-1), mean(N), std(N)/sqrt(size(N, 1)), 'lineProp', {C(2,:)});
end

if ~isnan([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'o')).ToneTime].')
    clear N
    clear addthis
for n = 1:length(ThisRecording)
    [addthis(1,:), edges] = OneUnitHistStructTimeLimLineINDEX([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'o')).ToneTime].', n, ThisRecording, Rxmin, Rxmax, Rbinwidth, [0 inf], 4, 'k', NaN, 0, 0);
        [meanLine, stdevLine] = StDevLine(addthis, edges, 0);           % calc for z-score
        addthis = (addthis - meanLine)/stdevLine;                               % z-score
            addthis = abs(addthis);                                             % abs val
            addthis = smoothdata(addthis, 'sgolay', 11);                        % smooth
    N(n,:) = addthis;
end
shadedErrorBar2(edges(1:end-1), mean(N), std(N)/sqrt(size(N, 1)), 'lineProp', {C(3,:)});
if k == 1
legend({'predict'; 'react'; 'outside'}, 'Location', 'northeast');
legend('boxoff')
end
end
FormatFigure(NaN, NaN);


nexttile
if ~isnan([RecordingList(k).LickOnsetPred.RecordTime].')
    clear N
    clear addthis
for n = 1:length(ThisRecording)
    [addthis(1,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetPred.RecordTime].', n, ThisRecording, Lxmin, Lxmax, Lbinwidth, [0 inf], 4, 'k', NaN, 0, 0);
        [meanLine, stdevLine] = StDevLine(addthis, edges, -.7);           % calc for z-score
        addthis = (addthis - meanLine)/stdevLine;                               % z-score
            addthis = abs(addthis);                                             % abs val
            addthis = smoothdata(addthis, 'sgolay', 11);
    N(n,:) = addthis;
end
shadedErrorBar2(edges(1:end-1), mean(N), std(N)/sqrt(size(N, 1)), 'lineProp', {C(1,:)});
end
xlabel(['time from lick day ' num2str(RecordingList(k).day)]);
hold on


if ~isnan([RecordingList(k).LickOnsetReact.RecordTime].')
    clear N
    clear addthis
for n = 1:length(ThisRecording)
    [addthis(1,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetReact.RecordTime].', n, ThisRecording, Lxmin, Lxmax, Lbinwidth, [0 inf], 4, 'k', NaN, 0, 0);
        [meanLine, stdevLine] = StDevLine(addthis, edges, -.7);           % calc for z-score
        addthis = (addthis - meanLine)/stdevLine;                               % z-score
            addthis = abs(addthis);                                             % abs val
            addthis = smoothdata(addthis, 'sgolay', 11);
    N(n,:) = addthis;
end
shadedErrorBar2(edges(1:end-1), mean(N), std(N)/sqrt(size(N, 1)), 'lineProp', {C(2,:)});
end

if ~isnan([RecordingList(k).LickOnsetOutside.RecordTime].')
    clear N
    clear addthis
for n = 1:length(ThisRecording)
    [addthis(1,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetOutside.RecordTime].', n, ThisRecording, Lxmin, Lxmax, Lbinwidth, [0 inf], 4, 'k', NaN, 0, 0);
        [meanLine, stdevLine] = StDevLine(addthis, edges, -.7);           % calc for z-score
        addthis = (addthis - meanLine)/stdevLine;                               % z-score
            addthis = abs(addthis);                                             % abs val
            addthis = smoothdata(addthis, 'sgolay', 11);
    N(n,:) = addthis;
end
shadedErrorBar2(edges(1:end-1), mean(N), std(N)/sqrt(size(N, 1)), 'lineProp', {C(3,:)});
end
if k == 1
legend({'predict'; 'react'; 'outside'}, 'Location', 'northeast');
legend('boxoff')
end
FormatFigure(NaN, NaN);


end
    FigureWrap(NaN, ['SS_psth_trialOutcome_stim_toneResp_Abs' num2str(k)], NaN, NaN, NaN, NaN, 10, 4);
