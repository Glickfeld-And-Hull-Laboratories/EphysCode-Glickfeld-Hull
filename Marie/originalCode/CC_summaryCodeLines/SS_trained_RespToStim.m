bmin = -.5;
bmax = .8;
bsize = .01;
Izero = abs(bmin/bsize) - 1;

clear N_JuiceTimes_sil
clear N_JuiceAfterTone
clear N_NoJuiceClk
clear N_ToneTimes
figure
for k = 7:26                          % edit this for day
    ThisDay = SS_train([SS_train.day] == k);
    if ~isempty(ThisDay)

        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).JuiceTimes_sil)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(ThisDay(n).RecorNum).JuiceTimes_sil, n, ThisDay, bmin, bmax, bsize, [0 inf], 4, 'k', NaN, 0, 0);
                N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
            end
        end
        
        N_JuiceTimes_sil(k).N = smoothdata(N, 1,  'sgolay', 11);
        N_JuiceTimes_sil(k).edges = edges;
        

        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).JuiceAfterTone)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(ThisDay(n).RecorNum).JuiceAfterTone, n, ThisDay, bmin, bmax, bsize, [0 inf], 4, 'k', NaN, 0, 0);
            N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
            end
        end
       
        N_JuiceAfterTone(k).N = smoothdata(N, 1,  'sgolay', 11);
        N_JuiceAfterTone(k).edges = edges;
        
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).ToneTimes)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(ThisDay(n).RecorNum).ToneTimes, n, ThisDay, bmin, bmax, bsize, [0 inf], 4, 'k', NaN, 0, 0);
                 N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
            end
        end
        
        N_ToneTimes(k).N = smoothdata(N, 1,  'sgolay', 11);
        N_ToneTimes(k).edges = edges;
        
        
        N = [];
        counter = 1;
        for n = 1:length(ThisDay)
            if ~isempty(RecordingList(ThisDay(n).RecorNum).NoJuiceClk)
                [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(ThisDay(n).RecorNum).NoJuiceClk, n, ThisDay, bmin, bmax, bsize, [0 inf], 4, 'k', NaN, 0, 0);
                 N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero)); 
                counter = counter + 1;
            end
        end
        
        N_NoJuiceClk(k).N = smoothdata(N, 1,  'sgolay', 11);
        N_NoJuiceClk(k).edges = edges;
        
    end
end


figure
hold on
shadedErrorBar2(edges(1:end-1), mean(cell2mat({N_JuiceTimes_sil.N}.'), 1), std(cell2mat({N_JuiceTimes_sil.N}.'), 0, 1)/sqrt(size(cell2mat({N_JuiceTimes_sil.N}.'), 1)), 'LineProp', 'k');
shadedErrorBar2(edges(1:end-1), mean(cell2mat({N_JuiceAfterTone.N}.'), 1), std(cell2mat({N_JuiceAfterTone.N}.'), 0, 1)/sqrt(size(cell2mat({N_JuiceAfterTone.N}.'), 1)), 'LineProp', 'b');
shadedErrorBar2(edges(1:end-1), mean(cell2mat({N_ToneTimes.N}.'), 1), std(cell2mat({N_ToneTimes.N}.'), 0, 1)/sqrt(size(cell2mat({N_ToneTimes.N}.'), 1)), 'LineProp', 'g');
legend({ [ ' silent reward, n = ' num2str((size(cell2mat({N_JuiceTimes_sil.N}.'), 1)))]; ... 
    [' predicted reward n = ' num2str((size(cell2mat({N_JuiceAfterTone.N}.'), 1)))]; ... 
    [' predictive tone n = ' num2str((size(cell2mat({N_ToneTimes.N}.'), 1)))]; ... 
     }, 'FontSize', 6);
legend('boxoff');
ylabel('SSspk sp/s, z-score');
xlabel('time from event');
xlim([-.5 1]);
FigureWrap('SS_trained_RespToStim', ['SS_trained_RespToStim'], NaN, NaN, NaN, NaN, NaN, NaN);