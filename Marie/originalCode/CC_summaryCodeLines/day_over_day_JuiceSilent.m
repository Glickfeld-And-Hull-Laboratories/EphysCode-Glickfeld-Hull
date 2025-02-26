xmin= -1; 
xmax = 3;
binvalue0 = 190;
bwidth = 0.005;

close all
figure
colors = {'k'; 'm'; 'r'; 'g'; 'y'; 'b'; 'c';};
for k = 1:7
    ThisRecording = CS([CS.RecorNum] == k);
    
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceAlone_sil, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors{k});
    hold on
    
end
ylabel('sp/s (z-score)');
xlabel('time from silent reward delivery (s)');
    legend({'day 1'; 'day 2'; 'day 3'; 'day 7 (after cue - naive day)'; 'day 10 (after cue)'; 'day 13 (after cue)'; 'day 18 (after cue)'}, 'Location', 'northeast');
legend('boxoff')
title('Cspk responding to reward or tone');
xlim([-.1 .3]);
ylim([-1 10]);
FigureWrap(NaN, ['day_over_day_JuiceSilent'], NaN, NaN, NaN, NaN, NaN, NaN);
%plot the same t




