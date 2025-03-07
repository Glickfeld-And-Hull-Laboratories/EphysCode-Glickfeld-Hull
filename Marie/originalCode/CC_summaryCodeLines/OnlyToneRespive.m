%only paired blocks- tone
bwidth = .005;
xmin = -.5;
xmax = .5;
xmin/bwidth;
binvalue0 = 80;


close all
figure
colorsMat = distinguishable_colors(length(RecordingList));
for n = 1:length(RecordingList)
    colors{n,1} = colorsMat(n,:);
end
for k = 4:length(RecordingList)
    ThisRecording = CS([CS.RecorNum] == k);
    
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if (~isnan(ThisRecording(n).AllTone.Dir))
            figure
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).AllPairedBlock.ToneTime].', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 1, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(k,:));
    hold on
    
end
ylabel('sp/s (z-score)');
xlabel('time from tone (s) paired block');
%     legend({'day 7 (after cue - naive day)'; 'day 10 (after cue)'; 'day 13 (after cue)'; 'day 18 (after cue)'; 'day 21 (after cue)'; 'day 23 (after cue)'}, 'Location', 'northeast');
% legend('boxoff')
title('Cspk responding to tone');
xlim([-.1 .3]);
ylim([-1 11]);
FigureWrap(NaN, ['day_over_day_cspk_tone_pairedBlocks_toneRespive'], NaN, NaN, NaN, NaN, NaN, NaN);