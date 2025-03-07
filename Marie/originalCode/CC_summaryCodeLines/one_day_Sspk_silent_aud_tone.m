bmin = -.2;
bmax = .305;
bsize = .01;
Izero = abs(bmin/bsize) - 1;

clear N_JuiceTimes_sil
clear N_JuiceTimes_clk
clear N_NoJuiceClk
clear N_ToneTimes
figure
for k = 7:26                          % edit this for day
    ThisDay = SS_train([SS_train.day] == k);
    if ~isempty(ThisDay)
        nexttile
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).JuiceTimes_sil)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(ThisDay(n).RecorNum).JuiceTimes_sil, n, ThisDay, bmin, bmax, bsize, [0 inf], 4, 'k', NaN, 0, 0);
                N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
            end
        end
        if ~isempty(N)
        shadedErrorBar2(edges(1:end-1), nanmean(N, 1), nanstd(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', 'k');
        [SS_trainpk_day_SilRwd_Max(k).max, SS_trainpk_day_SilRwd_Max(k).I] = max(nanmean(N, 1));
        SS_trainpk_day_SilRwd_Max(k).time = edges(SS_trainpk_day_SilRwd_Max(k).I);
        SS_trainpk_day_SilRwd_Max(k).day = RecordingList(ThisDay(n).RecorNum).day;
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('SS_trainpk/s');
        xlabel('time from silent reward')
        ylim([0 15]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length([RecordingList(RecNumsInCond(t)).JuiceTimes_sil]);
        end
        legend({['SS_train = ' num2str(size(N, 1)) '; trials = ' num2str(trials_)]});
        legend('boxoff');
        N_JuiceTimes_sil(k).N = smoothdata(N, 'sgolay', 11);
        N_JuiceTimes_sil(k).edges = edges;
        end
        
        nexttile
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).JuiceTimes_clk)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(ThisDay(n).RecorNum).JuiceTimes_clk, n, ThisDay, bmin, bmax, bsize, [0 inf], 4, 'k', NaN, 0, 0);
            N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
            end
        end
        if ~isempty(N)
            [SS_trainpk_day_AudRwd_Max(k).max, SS_trainpk_day_AudRwd_Max(k).I] = max(nanmean(N, 1));
             SS_trainpk_day_AudRwd_Max(k).time = edges(SS_trainpk_day_AudRwd_Max(k).I);
            SS_trainpk_day_AudRwd_Max(k).day = RecordingList(ThisDay(n).RecorNum).day;
        shadedErrorBar2(edges(1:end-1), mean(N, 1), std(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', 'b');
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('SS_trainpk/s');
        xlabel('time from audible reward')
        ylim([0 15]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length([RecordingList(RecNumsInCond(t)).JuiceTimes_clk]);
        end
        legend({['SS_train = ' num2str(size(N, 1)) '; trials = ' num2str(trials_)]});        
        legend('boxoff');
        N_JuiceTimes_clk(k).N = smoothdata(N, 'sgolay', 11);
        N_JuiceTimes_clk(k).edges = edges;
        end
        
        nexttile
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).ToneTimes)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(ThisDay(n).RecorNum).ToneTimes, n, ThisDay, bmin, bmax, bsize, [0 inf], 4, 'k', NaN, 0, 0);
                 N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
            end
        end
        if ~isempty(N)
        [SS_trainpk_day_Tone_Max(k).max, SS_trainpk_day_Tone_Max(k).I] = max(nanmean(N, 1));
        SS_trainpk_day_Tone_Max(k).time = edges(SS_trainpk_day_Tone_Max(k).I);
        SS_trainpk_day_Tone_Max(k).day = RecordingList(ThisDay(n).RecorNum).day;
            shadedErrorBar2(edges(1:end-1), mean(N, 1), std(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', 'g');
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('SS_trainpk/s');
        xlabel('time from tone')
        ylim([0 15]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length([RecordingList(RecNumsInCond(t)).ToneTimes]);
        end
        legend({['SS_train = ' num2str(size(N, 1)) '; trials = ' num2str(trials_)]});   
        legend('boxoff');
        N_ToneTimes(k).N = smoothdata(N, 'sgolay', 11);
        N_ToneTimes(k).edges = edges;
        end
        
        nexttile
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).NoJuiceClk)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(ThisDay(n).RecorNum).NoJuiceClk, n, ThisDay, bmin, bmax, bsize, [0 inf], 4, 'k', NaN, 0, 0);
                 N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
            end
        end
        if ~isempty(N)
        [SS_trainpk_day_Tone_Max(k).max, SS_trainpk_day_Tone_Max(k).I] = max(nanmean(N, 1));
        SS_trainpk_day_Tone_Max(k).time = edges(SS_trainpk_day_Tone_Max(k).I);
        SS_trainpk_day_Tone_Max(k).day = RecordingList(ThisDay(n).RecorNum).day;
            shadedErrorBar2(edges(1:end-1), mean(N, 1), std(N, 0, 1)/sqrt(size(N, 1)), 'LineProp', {[.5 .5 .5]});
        title(['day ' num2str(RecordingList(ThisDay(1).RecorNum).day)]);
        ylabel('SS_trainpk/s');
        xlabel('time from empty click')
        ylim([0 15]);
        RecNumsInCond = unique([ThisDay.RecorNum]);
        trials_ = 0;
        for t = 1:length(RecNumsInCond)
            trials_ = trials_ + length([RecordingList(RecNumsInCond(t)).NoJuiceClk]);
        end
        legend({['SS_train = ' num2str(size(N, 1)) '; trials = ' num2str(trials_)]});   
        legend('boxoff');
        N_NoJuiceClk(k).N = smoothdata(N, 'sgolay', 11);
        N_NoJuiceClk(k).edges = edges;
        end
        
    end
end


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
ylabel('SS_trainpk sp/s, z-score');
xlabel('time from event');
xlim([-.1 .25]);
FigureWrap(NaN, ['SS_trainpk_response_day1' num2str(k)], NaN, NaN, NaN, NaN, NaN, NaN);