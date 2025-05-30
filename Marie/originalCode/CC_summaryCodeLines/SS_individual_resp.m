xmin= -1; 
xmax = 1;
binwidth = .005;
xmin/binwidth;
binvalue0 = 150;


%audibleRewardtimes
close all
for k = 1:length(RecordingList)
    ThisRecording = SS([SS.RecorNum] == k);
    Dcolors = distinguishable_colors(length(ThisRecording));
    figure
    hold on
    c = 1;
    clear N_SS
    legend_ = {};
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceTimes_clk, n, ThisRecording, xmin, xmax, binwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N = smoothdata([N], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            plot(edges(1:end-1), N_SS(c,:), 'Color', Dcolors(n,:));
            legend_ = [legend_; num2str(n)];
            c = c + 1;
        end
    end
%     legend(legend_);
% legend('boxoff');
xlim([-.2 .4]);
ylim([-15 15]);
ylabel('sp/s (z-score)');
xlabel('time from audible reward (s)');
title(['day ' num2str(RecordingList(k).day)]);
FigureWrap(NaN, ['SS_individual_resp_audible_reward' num2str(RecordingList(k).day)], NaN, NaN, NaN, NaN, 1.5, 2);
end




%tonetimes
close all
for k = 1:length(RecordingList)
    ThisRecording = SS([SS.RecorNum] == k);
    Dcolors = distinguishable_colors(length(ThisRecording));
    figure
    hold on
    c = 1;
    clear N_SS
    legend_ = {};
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).ToneTimes, n, ThisRecording, xmin, xmax, binwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N = smoothdata([N], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            plot(edges(1:end-1), N_SS(c,:), 'Color', Dcolors(n,:));
            legend_ = [legend_; num2str(n)];
            c = c + 1;
        end
    end
%     legend(legend_);
% legend('boxoff');
xlim([-.2 .4]);
ylim([-4 12]);
ylabel('sp/s (z-score)');
xlabel('time from tone (s)');
title(['day ' num2str(RecordingList(k).day)]);
FigureWrap(NaN, ['SS_individual_resp_tone' num2str(RecordingList(k).day)], NaN, NaN, NaN, NaN, 1.5, 2);
end

xmin= -2; 
xmax = 2;
binwidth = .005;
xmin/binwidth;
binvalue0 = 150;
%EpochOnsets
close all
for k = 1:length(RecordingList)
    ThisRecording = SS([SS.RecorNum] == k);
    Dcolors = distinguishable_colors(length(ThisRecording));
    figure
    hold on
    c = 1;
    clear N_SS
    legend_ = {};
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).EpochOnsets, n, ThisRecording, xmin, xmax, binwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N = smoothdata([N], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            plot(edges(1:end-1), N_SS(c,:), 'Color', Dcolors(n,:));
            legend_ = [legend_; num2str(n)];
            c = c + 1;
        end
    end
%     legend(legend_);
% legend('boxoff');
xlim([-1 1]);
ylim([-13 15]);
ylabel('sp/s (z-score)');
xlabel('time from epoch onsets (s)');
title(['day ' num2str(RecordingList(k).day)]);
FigureWrap(NaN, ['SS_individual_resp_EpochOnsets' num2str(RecordingList(k).day)], NaN, NaN, NaN, NaN, 1.5, 2);
end
