for k = 1:length(RecordingList)
   
    AllCells = Summary_1694([Summary_1694.RecorNum] == k);
    
    CS = AllCells(strcmp({AllCells.c4_label}, 'PkC_cs'));
CS = CS([CS.c4_confidence] > 2);
SS = AllCells(strcmp({AllCells.c4_label}, 'PkC_ss'));
SS = SS([SS.c4_confidence] > 2);
MF = AllCells(strcmp({AllCells.c4_label}, 'MFB'));
MF = MF([MF.c4_confidence] > 2);
MLI = AllCells(strcmp({AllCells.c4_label}, 'MLI'));
MLI = MLI([MLI.c4_confidence] > 2);
Gol = AllCells(strcmp({AllCells.c4_label}, 'GoC'));

trigger = RecordingList(k).JuiceAlone_clk;
%xlabel_ = 'time from epoch onset (s)';
xmin = -.1;
xmax = .2;
binvalue0 = 100;
bwidth = .001;
smoothVal = 1;

clear N_SS
for n = 1:length(SS)
    [N_SS(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, SS, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
    %N_SS(n,:) = smoothdata([N_SS(n,:)], 'sgolay', smoothVal);
    N_SS(n,:) = (N_SS(n,:) - mean(N_SS(n,1:binvalue0)))/std(N_SS(n,1:binvalue0));
end


clear N_CS
for n = 1:length(CS)
    [N_CS(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, CS, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
    %N_CS(n,:) = smoothdata([N_CS(n,:)], 'sgolay', smoothVal);
    N_CS(n,:) = (N_CS(n,:) - mean(N_CS(n,1:binvalue0)))/std(N_CS(n,1:binvalue0));
end


clear N_MLI
for n = 1:length(MLI)
    [N_MLI(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, MLI, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
    %N_MLI(n,:) = smoothdata([N_MLI(n,:)], 'sgolay', smoothVal);
    N_MLI(n,:) = (N_MLI(n,:) - mean(N_MLI(n,1:binvalue0)))/std(N_MLI(n,1:binvalue0));
end


clear N_Gol
for n = 1:length(Gol)
    [N_Gol(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, Gol, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
    %N_Gol(n,:) = smoothdata([N_Gol(n,:)], 'sgolay', smoothVal);
    N_Gol(n,:) = (N_Gol(n,:) - mean(N_Gol(n,1:binvalue0)))/std(N_Gol(n,1:binvalue0));
end


clear N_MF
for n = 1:length(MF)
    [N_MF(n,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, MF, xmin, xmax, bwidth, [0 inf], 4, 'k', NaN, 0, 0);
    %N_MF(n,:) = smoothdata([N_MF(n,:)], 'sgolay', smoothVal);
    N_MF(n,:) = (N_MF(n,:) - mean(N_MF(n,1:binvalue0)))/std(N_MF(n,1:binvalue0));
end


 %viz code
 figure
 hold on
 %plot(edges(1:end-1), mean(N_SS), 'b');
 shadedErrorBar2(edges(1:end-1), nanmean(N_SS), nanstd(N_SS)/sqrt(size(N_SS, 1)), 'LineProp', 'b');
  %plot(edges(1:end-1), mean(N_CS), 'k');
   shadedErrorBar2(edges(1:end-1), nanmean(N_CS), nanstd(N_SS)/sqrt(size(N_CS, 1)), 'LineProp', 'k');
   %plot(edges(1:end-1), mean(N_MLI), 'm');
    shadedErrorBar2(edges(1:end-1), nanmean(N_MLI), nanstd(N_SS)/sqrt(size(N_MLI, 1)), 'LineProp', 'm');
    %plot(edges(1:end-1), mean(N_Gol), 'g');
     shadedErrorBar2(edges(1:end-1), nanmean(N_Gol), nanstd(N_SS)/sqrt(size(N_Gol, 1)), 'LineProp', 'g');
     %plot(edges(1:end-1), mean(N_MF), 'r');
      shadedErrorBar2(edges(1:end-1), nanmean(N_MF), nanstd(N_SS)/sqrt(size(N_MF, 1)), 'LineProp', 'r');
      %legend({'Sspk'; 'Cpsk'; 'MLI'; 'Golgi'; 'MFB'});
%FigureWrap(NaN, 'RewardDeliveryPSTH_Zscore', 'time from reward (s)', 'sp/s (z-score)', NaN, NaN, NaN, NaN)
% end
xlim([-.01 .02]);
title([num2str(k) ' ' num2str(length(trigger))]);
end