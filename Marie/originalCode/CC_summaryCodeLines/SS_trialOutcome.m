%only paired blocks- tone
bwidth = .005;
xmin = -.5;
xmax = 2;
xmin/bwidth;
binvalue0 = 80;


close all
figure
colorsMat = distinguishable_colors(length(RecordingList));
for n = 1:length(RecordingList)
    colors{n,1} = colorsMat(n,:);
end
figure
for k = 4:length(RecordingList)
    ThisRecording = SS([SS.RecorNum] == k);
    TrialStruct = RecordingList(k).TrialStructOutcomes;
    TrialStruct = TrialStruct(strcmp({TrialStruct.TrialType}, 'b'));
nexttile
    clear N_SS
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        %if (~isnan(ThisRecording(n).AllTone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).ToneTime].', n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        %end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)), 'lineProp', 'g');
    hold on
       clear N_SS
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        %if (~isnan(ThisRecording(n).AllTone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'r')).ToneTime].', n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        %end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)), 'lineProp', 'r');
    hold on
       clear N_SS
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        %if (~isnan(ThisRecording(n).AllTone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'o')).ToneTime].', n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        %end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)), 'lineProp', 'k');
   if k == length(RecordingList)
    ylabel('sp/s (z-score)');
xlabel('time from tone (s)');
legend({'predict'; 'react'; 'outside'}, 'Location', 'northeast');
legend('boxoff')
   end
title(['Cspk day ' num2str(RecordingList(k).day)]);
ylabel('sp/s (z-score)');
FormatFigure(NaN, NaN);
xlim([-.1 1]);
ylim([-1 11]);
    
end
FigureWrap(NaN, ['day_over_day_Sspk_tone_trialOutcome'], NaN, NaN, NaN, NaN, 12,2);