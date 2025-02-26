clear N_JuiceTimes_sil
clear N_JuiceTimes_clk
clear N_JuiceTimes_clk
clear N_ToneTimes
figure
for k = 1:7
    ThisDay = CS([CS.day] == k);
    if ~isempty(ThisDay)
        nexttile
        hold on
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).JuiceTimes_sil)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(ThisDay(n).RecorNum).JuiceTimes_sil, n, ThisDay, -.1, .305, .005, [0 inf], 4, 'k', NaN, 0, 0);
            counter = counter + 1;
            end
        end
        if ~isempty(N)
        shadedErrorBar2(edges(1:end-1), nanmean(N, 1), nanstd(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', 'k');
        [Cspk_day_SilRwd_Max(k).max, Cspk_day_SilRwd_Max(k).I] = max(nanmean(N, 1));
        Cspk_day_SilRwd_Max(k).time = edges(Cspk_day_SilRwd_Max(k).I);
        Cspk_day_SilRwd_Max(k).day = RecordingList(ThisDay(n).RecorNum).day;
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('Cspk/s');
        xlabel('time from silent reward')
        ylim([0 15]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length([RecordingList(RecNumsInCond(t)).JuiceTimes_sil]);
        end
        legend({['CS = ' num2str(size(N, 1)) '; trials = ' num2str(trials_)]});
        legend('boxoff');
        %N_JuiceTimes_sil(k).N = smoothdata(N, 2, 'sgolay', 11);
        else
            plot([NaN], [NaN]);
        end
        N_JuiceTimes_sil(k).N = N;
        N_JuiceTimes_sil(k).edges = edges;
        
        %nexttile
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).JuiceTimes_clk)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(ThisDay(n).RecorNum).JuiceTimes_clk, n, ThisDay, -.1, .305, .005, [0 inf], 4, 'k', NaN, 0, 0);
            counter = counter + 1;
            end
        end
        if ~isempty(N)
            [Cspk_day_AudRwd_Max(k).max, Cspk_day_AudRwd_Max(k).I] = max(nanmean(N, 1));
             Cspk_day_AudRwd_Max(k).time = edges(Cspk_day_AudRwd_Max(k).I);
            Cspk_day_AudRwd_Max(k).day = RecordingList(ThisDay(n).RecorNum).day;
        shadedErrorBar2(edges(1:end-1), mean(N, 1), std(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', 'b');
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('Cspk/s');
        xlabel('time from audible reward')
        ylim([0 15]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length([RecordingList(RecNumsInCond(t)).JuiceTimes_clk]);
        end
        legend({['CS = ' num2str(size(N, 1)) '; trials = ' num2str(trials_)]});        
        legend('boxoff');
        %N_JuiceTimes_clk(k).N = smoothdata(N, 2, 'sgolay', 11);
             else
            plot([NaN], [NaN]);
        end
        N_JuiceTimes_clk(k).N = N;
        N_JuiceTimes_clk(k).edges = edges;
        
        %nexttile
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).ToneTimes)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(ThisDay(n).RecorNum).ToneTimes, n, ThisDay, -.1, .305, .005, [0 inf], 4, 'k', NaN, 0, 0);
                counter = counter + 1;
            end
        end
        if ~isempty(N)
        [Cspk_day_Tone_Max(k).max, Cspk_day_Tone_Max(k).I] = max(nanmean(N, 1));
        Cspk_day_Tone_Max(k).time = edges(Cspk_day_Tone_Max(k).I);
        Cspk_day_Tone_Max(k).day = RecordingList(ThisDay(n).RecorNum).day;
            shadedErrorBar2(edges(1:end-1), mean(N, 1), std(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', 'g');
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('Cspk/s');
        %xlabel('time from tone')
        xlabel('time from event');
        ylim([0 15]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length([RecordingList(RecNumsInCond(t)).ToneTimes]);
        end
%         legend({['CS = ' num2str(size(N, 1)) '; trials = ' num2str(trials_)]});   
%         legend('boxoff');
        %N_ToneTimes(k).N = smoothdata(N, 2, 'sgolay', 11);
             else
            plot([NaN], [NaN]);
        end
        N_ToneTimes(k).N = N;
        N_ToneTimes(k).edges = edges;
        
        %nexttile
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).NoJuiceClk)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(ThisDay(n).RecorNum).NoJuiceClk, n, ThisDay, -.1, .305, .005, [0 inf], 4, 'k', NaN, 0, 0);
                counter = counter + 1;
            end
        end
        if ~isempty(N)
        [Cspk_day_Tone_Max(k).max, Cspk_day_Tone_Max(k).I] = max(nanmean(N, 1));
        Cspk_day_Tone_Max(k).time = edges(Cspk_day_Tone_Max(k).I);
        Cspk_day_Tone_Max(k).day = RecordingList(ThisDay(n).RecorNum).day;
            shadedErrorBar2(edges(1:end-1), mean(N, 1), std(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', {[.5 .5 .5]});
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('Cspk/s');
        %xlabel('time from empty click')
        xlabel('time from event');
        ylim([0 15]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length([RecordingList(RecNumsInCond(t)).NoJuiceClk]);
        end
        %legend({['CS = ' num2str(size(N, 1)) '; trials = ' num2str(trials_)]});   
        %legend('boxoff');
        %N_NoJuiceClk(k).N = smoothdata(N, 2, 'sgolay', 11);
        % [' trials = ' num2str(trials_)]
             else
            plot([NaN], [NaN]);
        end
        N_NoJuiceClk(k).N = N;
        N_NoJuiceClk(k).edges = edges;
        
         legend({['silent reward, n = ' num2str(size(N_JuiceTimes_sil(k).N, 1)) ]; ...
            ['solenoid, n = ' num2str(size(N_JuiceTimes_clk(k).N, 1))]; ...
            ['tone, n = ' num2str(size(N_ToneTimes(k).N, 1))]; ...
            ['empty solenoid = ' num2str(size(N_NoJuiceClk(k).N, 1))] });    
    end
    
end
%FigureWrap(NaN, ['Cspk_response_naive_over_days'], NaN, NaN, NaN, NaN, 2.0, 12);

figure
hold on
plot([Cspk_day_SilRwd_Max.day], [Cspk_day_SilRwd_Max.max], 'k');
plot([Cspk_day_AudRwd_Max.day], [Cspk_day_AudRwd_Max.max], 'b');
plot([Cspk_day_Tone_Max.day], [Cspk_day_Tone_Max.max], 'g');

figure
hold on
plot([Cspk_day_SilRwd_Max.day], [Cspk_day_SilRwd_Max.time], 'k');
plot([Cspk_day_AudRwd_Max.day], [Cspk_day_AudRwd_Max.time], 'b');
plot([Cspk_day_Tone_Max.day], [Cspk_day_Tone_Max.time], 'g');

figure
hold on
shadedErrorBar2(edges(1:end-1), mean(cell2mat({N_JuiceTimes_sil.N}.'), 1), std(cell2mat({N_JuiceTimes_sil.N}.'), 0, 1)/sqrt(size(cell2mat({N_JuiceTimes_sil.N}.'), 1)), 'LineProp', 'k');
shadedErrorBar2(edges(1:end-1), mean(cell2mat({N_JuiceTimes_clk.N}.'), 1), std(cell2mat({N_JuiceTimes_clk.N}.'), 0, 1)/sqrt(size(cell2mat({N_JuiceTimes_clk.N}.'), 1)), 'LineProp', 'b');
shadedErrorBar2(edges(1:end-1), mean(cell2mat({N_ToneTimes.N}.'), 1), std(cell2mat({N_ToneTimes.N}.'), 0, 1)/sqrt(size(cell2mat({N_ToneTimes.N}.'), 1)), 'LineProp', 'g');
shadedErrorBar2(edges(1:end-1), mean(cell2mat({N_NoJuiceClk.N}.'), 1), std(cell2mat({N_NoJuiceClk.N}.'), 0, 1)/sqrt(size(cell2mat({N_NoJuiceClk.N}.'), 1)), 'LineProp', {[.5 .5 .5]});
legend({ [ ' silent reward, n = ' num2str((size(cell2mat({N_JuiceTimes_sil.N}.'), 1)))]; ... 
    [' audible reward n = ' num2str((size(cell2mat({N_JuiceTimes_clk.N}.'), 1)))]; ... 
    [' neutral tone n = ' num2str((size(cell2mat({N_ToneTimes.N}.'), 1)))]; ... 
    [' neutral click n = ' num2str((size(cell2mat({N_NoJuiceClk.N}.'), 1)))] });
legend('boxoff');
ylabel('Cspk sp/s');
xlabel('time from event');
xlim([-.1 .25]);
%FigureWrap(NaN, ['Cspk_response_naive' num2str(k)], NaN, NaN, NaN, NaN, NaN, NaN);
    