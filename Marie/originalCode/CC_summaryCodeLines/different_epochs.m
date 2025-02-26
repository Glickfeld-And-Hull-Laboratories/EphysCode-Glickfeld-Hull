xmin= -3; 
xmax = 2;
bwidth = 0.050;
xmin/bwidth;
binvalue0 = 20;

% for SS
close all
figure
colorsMat = distinguishable_colors(6);
for n = 1:colorsMat
    colors{n,1} = colorsMat(n,:);
end
for k = 1:length(RecordingList)
    ThisRecording = SS([SS.RecorNum] == k);
    %after juice silent
    clear N_SS
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).EpochOnsetsFirstAfterJuice_sil.', n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        end
    end
    nexttile
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)), 'lineProp', colors(1,:));
    hold on
    
    %after juice click
    clear N_SS
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).EpochOnsetsFirstAfterJuice_clk.', n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)), 'lineProp', colors(2,:));
    
    %onsetPredict
    clear N_SS
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetPred.RecordTime].', n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)), 'lineProp', colors(3,:));
    
    %after onset react
    clear N_SS
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetReact.RecordTime].', n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)), 'lineProp', colors(4,:));
    
    %after onset outside
    clear N_SS
    c = 1;
    for n = 1:length(SS([SS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetOutside.RecordTime].', n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
            N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)), 'lineProp', colors(5,:));

%     
%     %onset before
%     clear N_SS
%     c = 1;
%     for n = 1:length(SS([SS.RecorNum] == k))
%         if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
%             [N_SS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetBefore.RecordTime].', n, SS([SS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
%             %N_SS(c,:) = smoothdata([N_SS(c,:)], 'sgolay', smoothVal);
%             N_SS(c,:) = (N_SS(c,:) - mean(N_SS(c,1:binvalue0)))/std(N_SS(c,1:binvalue0));
%             c = c + 1;
%         end
%     end
%     shadedErrorBar2(edges(1:end-1), mean(N_SS), std(N_SS)/sqrt(size(N_SS, 1)), 'lineProp', colors(6,:));
% title(['day ' num2str(RecordingList(k).day)]);
    if k == 1
        ylabel('sp/s (z-score)');
xlabel('time from lick onset (s)');
legend({'silent'; 'click'; 'predict'; 'react'; 'outside'; 'before'}, 'Location', 'northeast');
legend('boxoff')
    end
    ylim([-5 15]);
    xlim([-2 2]);
    FormatFigure(NaN, NaN);
end

% xlim([-2 2]);
% ylim([-1.5 3]);
FigureWrap(NaN, ['different_epochs'], NaN, NaN, NaN, NaN, 12, 2);


% for CS
xmin= -3; 
xmax = 2;
bwidth = 0.050;
xmin/bwidth;
binvalue0 = 20;

close all
figure
colorsMat = distinguishable_colors(6);
for n = 1:colorsMat
    colors{n,1} = colorsMat(n,:);
end
for k = 1:length(RecordingList)
    ThisRecording = CS([CS.RecorNum] == k);
    %after juice silent
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
    nexttile
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(1,:));
    hold on
    
    %after juice click
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
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(2,:));
    
    %onsetPredict
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetPred.RecordTime].', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(3,:));
    
    %after onset react
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetReact.RecordTime].', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(4,:));
    
    %after onset outside
    clear N_CS
    c = 1;
    for n = 1:length(CS([CS.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetOutside.RecordTime].', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
            N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(5,:));

    
%     %onset before
%     clear N_CS
%     c = 1;
%     for n = 1:length(CS([CS.RecorNum] == k))
%         if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
%             [N_CS(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetBefore.RecordTime].', n, CS([CS.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
%             %N_CS(c,:) = smoothdata([N_CS(c,:)], 'sgolay', smoothVal);
%             N_CS(c,:) = (N_CS(c,:) - mean(N_CS(c,1:binvalue0)))/std(N_CS(c,1:binvalue0));
%             c = c + 1;
%         end
%     end
%     shadedErrorBar2(edges(1:end-1), mean(N_CS), std(N_CS)/sqrt(size(N_CS, 1)), 'lineProp', colors(6,:));
% title(['day ' num2str(RecordingList(k).day)]);
    if k == 1
        ylabel('sp/s (z-score)');
xlabel('time from lick onset (s)');
legend({'silent'; 'click'; 'predict'; 'react'; 'outside'; 'before'}, 'Location', 'northeast');
legend('boxoff')
    end
    ylim([-1.5 4]);
    xlim([-2 2]);
    FormatFigure(NaN, NaN);
end

% xlim([-2 2]);
% ylim([-1.5 3]);
FigureWrap(NaN, ['different_epochs_CS'], NaN, NaN, NaN, NaN, 12, 2);

%for MF
xmin= -3; 
xmax = 2;
bwidth = 0.050;
xmin/bwidth;
binvalue0 = 20;

% for MF
close all
figure
colorsMat = distinguishable_colors(6);
for n = 1:colorsMat
    colors{n,1} = colorsMat(n,:);
end
for k = 1:length(RecordingList)
    ThisRecording = MF([MF.RecorNum] == k);
    %after juice silent
    clear N_MF
    c = 1;
    for n = 1:length(MF([MF.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_MF(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).EpochOnsetsFirstAfterJuice_sil.', n, MF([MF.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_MF(c,:) = smoothdata([N_MF(c,:)], 'sgolay', smoothVal);
            N_MF(c,:) = (N_MF(c,:) - mean(N_MF(c,1:binvalue0)))/std(N_MF(c,1:binvalue0));
            c = c + 1;
        end
    end
    nexttile
    shadedErrorBar2(edges(1:end-1), mean(N_MF), std(N_MF)/sqrt(size(N_MF, 1)), 'lineProp', colors(1,:));
    hold on
    
    %after juice click
    clear N_MF
    c = 1;
    for n = 1:length(MF([MF.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_MF(c,:), edges] = OneUnitHistStructTimeLimLineINDEX(RecordingList(k).EpochOnsetsFirstAfterJuice_clk.', n, MF([MF.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_MF(c,:) = smoothdata([N_MF(c,:)], 'sgolay', smoothVal);
            N_MF(c,:) = (N_MF(c,:) - mean(N_MF(c,1:binvalue0)))/std(N_MF(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_MF), std(N_MF)/sqrt(size(N_MF, 1)), 'lineProp', colors(2,:));
    
    %onsetPredict
    clear N_MF
    c = 1;
    for n = 1:length(MF([MF.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_MF(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetPred.RecordTime].', n, MF([MF.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_MF(c,:) = smoothdata([N_MF(c,:)], 'sgolay', smoothVal);
            N_MF(c,:) = (N_MF(c,:) - mean(N_MF(c,1:binvalue0)))/std(N_MF(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_MF), std(N_MF)/sqrt(size(N_MF, 1)), 'lineProp', colors(3,:));
    
    %after onset react
    clear N_MF
    c = 1;
    for n = 1:length(MF([MF.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_MF(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetReact.RecordTime].', n, MF([MF.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_MF(c,:) = smoothdata([N_MF(c,:)], 'sgolay', smoothVal);
            N_MF(c,:) = (N_MF(c,:) - mean(N_MF(c,1:binvalue0)))/std(N_MF(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_MF), std(N_MF)/sqrt(size(N_MF, 1)), 'lineProp', colors(4,:));
    
    %after onset outside
    clear N_MF
    c = 1;
    for n = 1:length(MF([MF.RecorNum] == k))
        if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
            [N_MF(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetOutside.RecordTime].', n, MF([MF.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
            %N_MF(c,:) = smoothdata([N_MF(c,:)], 'sgolay', smoothVal);
            N_MF(c,:) = (N_MF(c,:) - mean(N_MF(c,1:binvalue0)))/std(N_MF(c,1:binvalue0));
            c = c + 1;
        end
    end
    shadedErrorBar2(edges(1:end-1), mean(N_MF), std(N_MF)/sqrt(size(N_MF, 1)), 'lineProp', colors(5,:));

    
%     %onset before
%     clear N_MF
%     c = 1;
%     for n = 1:length(MF([MF.RecorNum] == k))
%         if ( ~isnan(ThisRecording(n).AllTone.Dir) | ~isnan(ThisRecording(n).AllJuice.Dir) | ~isnan(ThisRecording(n).JuiceAlone.Dir))
%             [N_MF(c,:), edges] = OneUnitHistStructTimeLimLineINDEX([RecordingList(k).LickOnsetBefore.RecordTime].', n, MF([MF.RecorNum] == k), xmin, xmax, bwidth, [0 inf], 4, [k/10 k/10 k/10], NaN, 0, 0);
%             %N_MF(c,:) = smoothdata([N_MF(c,:)], 'sgolay', smoothVal);
%             N_MF(c,:) = (N_MF(c,:) - mean(N_MF(c,1:binvalue0)))/std(N_MF(c,1:binvalue0));
%             c = c + 1;
%         end
%     end
%     shadedErrorBar2(edges(1:end-1), mean(N_MF), std(N_MF)/sqrt(size(N_MF, 1)), 'lineProp', colors(6,:));
% title(['day ' num2str(RecordingList(k).day)]);
    if k == 1
        ylabel('sp/s (z-score)');
xlabel('time from lick onset (s)');
legend({'silent'; 'click'; 'predict'; 'react'; 'outside'; 'before'}, 'Location', 'northeast');
legend('boxoff')
    end
    ylim([-5 20]);
    xlim([-2 2]);
    FormatFigure(NaN, NaN);
end

% xlim([-2 2]);
% ylim([-1.5 3]);
FigureWrap(NaN, ['different_epochs_mf'], NaN, NaN, NaN, NaN, 12, 2);


