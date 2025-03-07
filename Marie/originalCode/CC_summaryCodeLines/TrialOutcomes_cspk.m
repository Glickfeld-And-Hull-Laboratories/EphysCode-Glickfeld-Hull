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
    ThisRecording = CS([CS.RecorNum] == k);
    TrialStruct = RecordingList(k).TrialStructOutcomes;
    TrialStruct = TrialStruct(strcmp({TrialStruct.TrialType}, 'b'));
nexttile
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if (~isnan(ThisRecording(n).AllTone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'p')).ToneTime].', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', 'g');
    hold on
       clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if (~isnan(ThisRecording(n).AllTone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'r')).ToneTime].', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', 'r');
    hold on
       clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if (~isnan(ThisRecording(n).AllTone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([TrialStruct(strcmp({TrialStruct.TrialOutcome}, 'o')).ToneTime].', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', 'k');
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
FigureWrap(NaN, ['day_over_day_cspk_tone_trialOutcome'], NaN, NaN, NaN, NaN, 12,2);