bmin = -1;
bmax = 1.5;
bsize = .01;
Izero = abs(-.3/bsize) - 1;
C = colororder;

clear N_react
clear N_Outside
figure
for k = 6:7
    ThisDay = SS([SS.day] == k);
    if ~isempty(ThisDay)
        nexttile
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
                trigger = [RecordingList(ThisDay(n).RecorNum).LickOnsetReact.RecordTime];
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, ThisDay, bmin, bmax, bsize, [0 inf], 4, 'k', NaN, 0, 0);
                N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
        end
        if ~isempty(N)
        shadedErrorBar2(edges(1:end-1), nanmean(N, 1), nanstd(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', 'k');
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('SSpk/s');
        xlabel('time from silent reward')
        ylim([0 15]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length(trigger);
        end
        legend({['SS = ' num2str(size(N, 1))]});
        legend('boxoff');
        %N_React(k).N = smoothdata(N, 2, 'sgolay', 11);
        N_React(k).N = N;
        N_React(k).edges = edges;
        end
        
        nexttile
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
               trigger = [RecordingList(ThisDay(n).RecorNum).LickOnsetOutside.RecordTime];
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, ThisDay, bmin, bmax, bsize, [0 inf], 4, 'k', NaN, 0, 0);
            N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
        end
        if ~isempty(N)
        shadedErrorBar2(edges(1:end-1), mean(N, 1), std(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', 'b');
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('SSpk/s');
        xlabel('time from audible reward')
        ylim([0 15]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length(trigger);
        end
        legend({['SS = ' num2str(size(N, 1)) '; trials = ' num2str(trials_)]});        
        legend('boxoff');
        %N_Outside(k).N = smoothdata(N, 2, 'sgolay', 11);
        N_Outside(k).N = N;
        N_Outside(k).edges = edges;
        end
        
        
        
    end
end



figure
hold on
shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_React.N}.'), 1), nanstd(cell2mat({N_React.N}.'), 0, 1)/sqrt(size(cell2mat({N_React.N}.'), 1)), 'LineProp', {C(2,:)});
shadedErrorBar2(edges(1:end-1), mean(cell2mat({N_Outside.N}.'), 1), std(cell2mat({N_Outside.N}.'), 0, 1)/sqrt(size(cell2mat({N_Outside.N}.'), 1)), 'LineProp', {C(3,:)});
legend({ [ 'react, n = ' num2str((size(cell2mat({N_React.N}.'), 1)))]; ... 
    [' outside n = ' num2str((size(cell2mat({N_Outside.N}.'), 1)))]; ... 
     });
legend('boxoff');
ylabel('SSpk sp/s zscore');
xlabel('time from lick detection');
xlim([-.4 .2]);
ylim([-4 6]);
FigureWrap(NaN, ['SSpk_response_naive_LickAligned_byOutcome_day6_7'], NaN, NaN, NaN, NaN, NaN, NaN);