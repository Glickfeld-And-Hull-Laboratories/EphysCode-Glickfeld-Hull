xmin= -3; 
xmax = 2;
binvalue0 = 20;
bwidth = 0.050;

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
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).EpochOnsetsFirstAfterJuice_sil.', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(k,:));
    hold on
    
end
ylabel('sp/s (z-score)');
xlabel('time from lick onset (s) after silent reward');
% legend({'day 1'; 'day 2'; 'day 3'; 'day 7 (after cue - naive day)'; 'day 10 (after cue)'; 'day 13 (after cue)'; 'day 18 (after cue)'; 'day 21 (after cue)'; 'day 23 (after cue)'}, 'Location', 'northeast');
% legend('boxoff')
title('Cspk responding to reward or tone');
xlim([-2 2]);
ylim([-1.5 3]);
FigureWrap(NaN, ['day_over_day_licksFirstAfterJuiceSilent'], NaN, NaN, NaN, NaN, NaN, NaN);
%plot the same t


%over all recordings mean resp to lick after silent reward delivery
close all
figure
colorsMat = distinguishable_colors(length(RecordingList));
for n = 1:length(RecordingList)
    colors{n,1} = colorsMat(n,:);
end
    
    clear N_CS
    c = 1;
for k = 1:length(RecordingList)
    if ~isempty(RecordingList(k).EpochOnsetsFirstAfterJuice_sil)
    ThisRecording = CS([CS.RecorNum] == k);
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).EpochOnsetsFirstAfterJuice_sil.', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end 
    end
end
figure
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', 'k');
    hold on
ylabel('sp/s (z-score)');
xlabel('time from lick onset (s) after silent reward');
legend ('all days combined')
legend('boxoff')
title('Cspk responding to reward or tone');
xlim([-2 2]);
ylim([-1.5 3]);
FigureWrap(NaN, ['all_days_licksFirstAfterJuiceSilent'], NaN, NaN, NaN, NaN, NaN, NaN);
%plot the same t


% each day resp after audible reward
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
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).EpochOnsetsFirstAfterJuice_clk.', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(k,:));
    hold on
    
end
ylabel('sp/s (z-score)');
xlabel('time from lick onset (s) after audible reward');
% legend({'day 1'; 'day 2'; 'day 3'; 'day 7 (after cue - naive day)'; 'day 10 (after cue)'; 'day 13 (after cue)'; 'day 18 (after cue)'; 'day 21 (after cue)'; 'day 23 (after cue)'}, 'Location', 'northeast');
% legend('boxoff')
title('Cspk responding to reward or tone');
xlim([-2 2]);
ylim([-1.5 3]);
FigureWrap(NaN, ['day_over_day_licksFirstAfterJuiceAudible'], NaN, NaN, NaN, NaN, NaN, NaN);
%plot the same t

%over all recordings mean resp to lick after audible reward delivery
close all
figure
colorsMat = distinguishable_colors(length(RecordingList));
for n = 1:length(RecordingList)
    colors{n,1} = colorsMat(n,:);
end
    
    clear N_CS
    c = 1;
for k = 1:length(RecordingList)
    if ~isempty(RecordingList(k).EpochOnsetsFirstAfterJuice_sil)
    ThisRecording = CS([CS.RecorNum] == k);
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).EpochOnsetsFirstAfterJuice_clk.', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end 
    end
end
figure
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', 'k');
    hold on
ylabel('sp/s (z-score)');
xlabel('time from lick onset (s) after audible reward');
legend ('all days combined')
legend('boxoff')
title('Cspk responding to reward or tone');
xlim([-2 2]);
ylim([-1.5 3]);
FigureWrap(NaN, ['all_days_licksFirstAfterJuiceAudible'], NaN, NaN, NaN, NaN, NaN, NaN);
%plot the same t



