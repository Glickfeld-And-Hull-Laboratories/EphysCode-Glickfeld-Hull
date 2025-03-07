

%set some values for CS resp
xmin = -2;
xmax = 1;
binvalue0 = 100;
bwidth = .005;
smoothVal = 51;

% some meaure of responsiveness and then measure CS response
close all
for k = 1:length(RecordingList)
    figure
    tiledlayout(3,1)
    ThisRecording = CS([CS.RecorNum] == k);
    
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceAlone, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    nexttile
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)),'LineProp', 'c');
    hold on
    
    %clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceAfterTone, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'LineProp', 'k');
    ylim([[-1 10]]);
    title(['day ' num2str(RecordingList(k).day)]);
    xlabel('time from reward')
    legend({'reward alone'; 'reward after cue'}, 'Location', 'northeast');
    legend('boxoff')
    xlim([-.1 .3]);
    FormatFigure(NaN, NaN);
    
    
    nexttile
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).ToneAlone, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'LineProp', 'g');
    hold on
    
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).ToneBeforeJuice, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'LineProp', 'k');
    ylim([[-1 5]]);
    %title(num2str(k));
    xlabel('time from tone')
    legend({'cue alone'; 'cue before reward'}, 'Location', 'northeast');
    legend('boxoff')
    xlim([-.1 .5]);
    FormatFigure(NaN, NaN);
    
    nexttile
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).RewardLickOnset, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)));
    ylim([[-1 5]]);
    %title(num2str(k));
    xlabel('time from lick detection')
    legend('boxoff')
    xlim([-1 1]);
    
    FigureWrap(NaN, ['CS_all_respToCueRewardLick_rec' num2str(k)], NaN, NaN, NaN, NaN, 4, 2);
end


%set some values for SS resp
xmin = -2;
xmax = 1;
binvalue0 = 100;
bwidth = .005;
smoothVal = 21;

% measure SS response of "responsive" cells
close all
for k = 1:length(RecordingList)
    figure
    tiledlayout(3,1)
    ThisRecording = SS([SS.RecorNum] == k);
    
    clear N_SS
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceAlone, n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        end
    end
    nexttile
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)),'LineProp', 'c');
    hold on
    
    %clear N_SS
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceAfterTone, n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)), 'LineProp', 'k');
    ylim([[-15 20]]);
    title(['day ' num2str(RecordingList(k).day)]);
    xlabel('time from reward')
    %legend({'reward alone'; 'reward after cue'}, 'Location', 'northeast');
    %legend('boxoff')
    xlim([-.2 .5]);
    FormatFigure(NaN, NaN);
    
    
    nexttile
    clear N_SS
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).ToneAlone, n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)), 'LineProp', 'g');
    hold on
    
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).ToneBeforeJuice, n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)), 'LineProp', 'k');
    ylim([[-15 20]]);
    %title(num2str(k));
    xlabel('time from tone')
    %legend({'cue alone'; 'cue before reward'}, 'Location', 'northeast');
    %legend('boxoff')
    xlim([-.1 .5]);
    FormatFigure(NaN, NaN);
    
    nexttile
    clear N_SS
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).RewardLickOnset, n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)));
    ylim([[-15 20]]);
    %title(num2str(k));
    xlabel('time from lick detection')
    %legend('boxoff')
    xlim([-1 1]);
    
    FigureWrap(NaN, ['SS_all_respToCueRewardLick_rec' num2str(k)], NaN, NaN, NaN, NaN, 4, 2);
    k 
    c = c - 1
end

close all
for k = 1:length(RecordingList)
    figure
    ThisRecording = CS([CS.RecorNum] == k);
    
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceAlone_clk, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    nexttile
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)),'LineProp', 'k');
    hold on
    
     clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceAlone_sil, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)),'LineProp', 'y');
title(['day ' num2str(RecordingList(k).day)]);
    xlabel('time from reward (s)');
    legend({'audible reward'; 'silent reward'}, 'Location', 'northeast');
legend('boxoff')
ylim([-1 10]);
xlim([-.1 .2]);
FigureWrap(NaN, ['CS_all_respClickNoClick_rec' num2str(k)], NaN, NaN, NaN, NaN, 4, 2);
end

close all
for k = 1:length(RecordingList)
    figure
    ThisRecording = CS([CS.RecorNum] == k);
    
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceAfterTone, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    nexttile
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)),'LineProp', 'g');
    hold on
    
     clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceAlone_clk, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)),'LineProp', 'b');
title(['day ' num2str(RecordingList(k).day)]);
    xlabel('time from reward (s)');
    legend({'juice after tone'; 'juice alone'}, 'Location', 'northeast');
legend('boxoff')
ylim([-1 10]);
xlim([-.1 .2]);
FigureWrap(NaN, ['CS_all_respTone_Unexpect_rec' num2str(k)], NaN, NaN, NaN, NaN, 4, 2);
end

close all
for k = 1:length(RecordingList)
    figure
    ThisRecording = CS([CS.RecorNum] == k);
    
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).ToneBeforeJuice, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    nexttile
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)),'LineProp', 'g');
    hold on
    
     clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).JuiceAlone_clk, n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)),'LineProp', 'b');
title(['day ' num2str(RecordingList(k).day)]);
    xlabel('time from reward (s)');
    legend({'juice after tone'; 'juice alone'}, 'Location', 'northeast');
legend('boxoff')
ylim([-1 10]);
xlim([-.1 .2]);
FigureWrap(NaN, ['CS_all_respTone_Unexpect_rec' num2str(k)], NaN, NaN, NaN, NaN, 4, 2);
end

%plot the same thing but each cell individually