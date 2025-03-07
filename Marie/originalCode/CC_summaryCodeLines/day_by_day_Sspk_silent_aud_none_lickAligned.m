bmin = -1.5;
bmax = 1;
bsize = .01;
Izero = abs((bmin-.5)/bsize) - 1;

clear N_AfterJuice_sil
clear N_AfterJuice_clk
clear N_Empty
figure
for k = 1:7
    ThisDay = SS([SS.day] == k);
    if ~isempty(ThisDay)
        nexttile
        hold on
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).EpochOnsetsFirstAfterJuice_sil)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(ThisDay(n).RecorNum).EpochOnsetsFirstAfterJuice_sil].', n, ThisDay, bmin, bmax, .01, [0 inf], 4, 'k', NaN, 0, 0);
                N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
            end
        end
        if ~isempty(N)
        shadedErrorBar2(edges(1:end-1), nanmean(N, 1), nanstd(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', 'k');
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('SSpk/s');
        xlabel('time from lick after silent reward')
        ylim([0 15]);
        xlim([-.8 .5]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length([RecordingList(RecNumsInCond(t)).EpochOnsetsFirstAfterJuice_sil]);
        end
%         legend({['SS = ' num2str(size(N, 1)) '; trials = ' num2str(trials_)]});
%         legend('boxoff');
        else
            plot([NaN], [NaN]);
        end
        N_AfterJuice_sil(k).N = smoothdata(N, 2, 'sgolay', 11);
        N_AfterJuice_sil(k).edges = edges;

        
        %nexttile
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).EpochOnsetsFirstAfterJuice_clk)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(ThisDay(n).RecorNum).EpochOnsetsFirstAfterJuice_clk].', n, ThisDay, bmin, bmax, .01, [0 inf], 4, 'k', NaN, 0, 0);
                N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
            end
        end
        if ~isempty(N)
        shadedErrorBar2(edges(1:end-1), mean(N, 1), std(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', 'b');
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('SSpk/s');
        xlabel('time from lick after audible reward')
        ylim([0 15]);
        xlim([-.8 .5]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length([RecordingList(RecNumsInCond(t)).EpochOnsetsFirstAfterJuice_clk]);
        end
%         legend({['SS = ' num2str(size(N, 1)) '; trials = ' num2str(trials_)]});        
%         legend('boxoff');
        else
            plot([NaN], [NaN]);
        end
         N_AfterJuice_clk(k).N = smoothdata(N, 2, 'sgolay', 11);
        N_AfterJuice_clk(k).edges = edges;
        
        %nexttile
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).LickOnsetEmpty)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(ThisDay(n).RecorNum).LickOnsetEmpty.RecordTime].', n, ThisDay, bmin, bmax, .01, [0 inf], 4, 'k', NaN, 0, 0);
                N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
            end
        end
        if ~isempty(N)
        shadedErrorBar2(edges(1:end-1), mean(N, 1), std(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', {[.5 .5 .5]});
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('SSpk/s');
        xlabel('time from lick no reward')
        ylim([0 15]);
        xlim([-.8 .5]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length([RecordingList(RecNumsInCond(t)).LickOnsetEmpty]);
        end
%         legend({['SS = ' num2str(size(N, 1)) '; trials = ' num2str(trials_)]});   
%         legend('boxoff');
        else
            plot([NaN], [NaN]);
        end
        N_Empty(k).N = smoothdata(N, 2, 'sgolay', 11);
        N_Empty(k).edges = edges;
        
        ylabel('SSpk/s zscore');
        %xlabel('time from empty click')
        xlabel('time from event')
        FormatFigure(NaN, NaN);
        xlim([-.1 .25]);
        ylim([-6 5]);
        legend({['n = ' num2str(size(N_AfterJuice_sil(k).N, 1)) ]; ...
            ['n = ' num2str(size(N_AfterJuice_clk(k).N, 1))]; ...
            ['n = ' num2str(size(N_Empty(k).N, 1))]});  
        legend('boxoff')
    end
end


figure
hold on
shadedErrorBar2(edges(1:end-1), mean(cell2mat({N_AfterJuice_sil.N}.'), 1), std(cell2mat({N_AfterJuice_sil.N}.'), 0, 1)/sqrt(size(cell2mat({N_AfterJuice_sil.N}.'), 1)), 'LineProp', 'k');
shadedErrorBar2(edges(1:end-1), mean(cell2mat({N_AfterJuice_clk.N}.'), 1), std(cell2mat({N_AfterJuice_clk.N}.'), 0, 1)/sqrt(size(cell2mat({N_AfterJuice_clk.N}.'), 1)), 'LineProp', 'b');
shadedErrorBar2(edges(1:end-1), mean(cell2mat({N_Empty.N}.'), 1), std(cell2mat({N_Empty.N}.'), 0, 1)/sqrt(size(cell2mat({N_Empty.N}.'), 1)), 'LineProp', {[.5 .5 .5]});
legend({ [ ' silent reward, n = ' num2str((size(cell2mat({N_AfterJuice_sil.N}.'), 1)))]; ... 
    [' audible reward n = ' num2str((size(cell2mat({N_AfterJuice_clk.N}.'), 1)))]; ... 
    [' empty licks n = ' num2str((size(cell2mat({N_Empty.N}.'), 1)))] });
legend('boxoff');
ylabel('SSpk sp/s, z-score');
xlabel('time from lick onset');
xlim([-1 .5]);
FigureWrap(NaN, ['SSpk_LickResponse_naive' num2str(k)], NaN, NaN, NaN, NaN, NaN, NaN);

