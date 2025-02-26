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
    clear N_max
for k = 1:length(RecordingList)
    ThisRecording = CS([CS.RecorNum] == k);
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            if k < 4
                [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceTimes_clk, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            else
                [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).AllPairedBlock.JuiceTime].', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            end
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(k,:));
    hold on
    N_max(k).cs_max = max(mean(N_CS));
    N_max(k).day = RecordingList(k).day;
end
ylabel('sp/s (z-score)');
xlabel('time from audible reward (s) cued paired block only');
    legend({'day 1'; 'day 2'; 'day 3'; 'day 7 (after cue - naive day)'; 'day 10 (after cue)'; 'day 13 (after cue)'; 'day 18 (after cue)'; 'day 21 (after cue)'; 'day 23 (after cue)'}, 'Location', 'northeast');
legend('boxoff')
title('Cspk responding to reward or tone');
xlim([-.1 .3]);
ylim([-1 11]);
FigureWrap(NaN, ['day_over_day_cspk_audible_reward'], NaN, NaN, NaN, NaN, NaN, NaN);
figure
plot([N_max.day], [N_max.cs_max]);
ylabel('max Cspk/s (z-score) after audible reward');
xlabel('training day');
xline(7, 'k');
FigureWrap(NaN, ['day_over_day_Max_cspk_audible_reward'], NaN, NaN, NaN, NaN, NaN, NaN);


%plot the same t

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
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).ToneTimes, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(k,:));
    hold on
    
end
ylabel('sp/s (z-score)');
xlabel('time from tone (s)');
%     legend({'day 7 (after cue - naive day)'; 'day 10 (after cue)'; 'day 13 (after cue)'; 'day 18 (after cue)'; 'day 21 (after cue)'; 'day 23 (after cue)'}, 'Location', 'northeast');
% legend('boxoff')
title('Cspk responding to reward or tone');
xlim([-.1 .3]);
ylim([-1 11]);
FigureWrap(NaN, ['day_over_day_cspk_tone'], NaN, NaN, NaN, NaN, NaN, NaN);
%plot the same t

%only paired blocks- juice
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
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).AllPairedBlock.JuiceTime].', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(k,:));
    hold on
    
end
ylabel('sp/s (z-score)');
xlabel('time from audible reward (s) paired block');
%     legend({'day 7 (after cue - naive day)'; 'day 10 (after cue)'; 'day 13 (after cue)'; 'day 18 (after cue)'; 'day 21 (after cue)'; 'day 23 (after cue)'}, 'Location', 'northeast');
% legend('boxoff')
title('Cspk responding to reward or tone');
xlim([-.1 .3]);
ylim([-1 11]);
FigureWrap(NaN, ['day_over_day_cspk_juice_pairedBlocks'], NaN, NaN, NaN, NaN, NaN, NaN);

%only paired blocks- tone
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
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).AllPairedBlock.ToneTime].', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
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
title('Cspk responding to reward or tone');
xlim([-.1 .3]);
ylim([-1 11]);
FigureWrap(NaN, ['day_over_day_cspk_tone_pairedBlocks'], NaN, NaN, NaN, NaN, NaN, NaN);


close all
figure
colorsMat = distinguishable_colors(length(RecordingList));
for n = 1:length(RecordingList)
    colors{n,1} = colorsMat(n,:);
end
for k = 1:length(RecordingList)
    ThisRecording = CS([CS.RecorNum] == k);
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
                [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceTimes_sil, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(k,:));
    hold on
end
ylabel('sp/s (z-score)');
xlabel('time from silent reward (s)');
%     legend({'day 1'; 'day 2'; 'day 3'; 'day 7 (after cue - naive day)'; 'day 10 (after cue)'; 'day 13 (after cue)'; 'day 18 (after cue)'; 'day 21 (after cue)'; 'day 23 (after cue)'}, 'Location', 'northeast');
% legend('boxoff')
title('Cspk responding to reward or tone');
xlim([-.1 .3]);
ylim([-1 11]);
FigureWrap(NaN, ['day_over_day_cspk_silent_reward'], NaN, NaN, NaN, NaN, NaN, NaN);

%only paired blocks tone different binsize
bwidth = .02;
xmin = -.5;
xmax = .5;
xmin/bwidth;
binvalue0 = 20;

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
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).AllPairedBlock.ToneTime].', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
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
title('Cspk responding to reward or tone');
xlim([-.1 .3]);
ylim([-1 11]);
FigureWrap(NaN, ['day_over_day_cspk_tone_pairedBlocks_bin'], NaN, NaN, NaN, NaN, NaN, NaN);

