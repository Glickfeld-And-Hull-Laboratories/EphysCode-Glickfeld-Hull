
close all
%CS_b according to CS_j sort
bmin = -2;
bmax = 2;
binsize = .01;
Izero = ((abs(bmin))/binsize);
Zzero = ((abs(bmin) - 1)/binsize);
smooth = [0, 5];
counter = 1;
clear N
clear N_CS_o_H

for n =1:length(CS)
    R = CS(n).RecorNum;
    if [Rlist(R).day] == 7 | [Rlist(R).day] == 8 | [Rlist(R).day] == 9
        Trials = [Rlist(R).LickOnsets];
        trigger = Trials(strcmp({Trials.Outcome}, 'o'));
        if ~isempty(trigger)
            trigger = [trigger.time];
            [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
%             N(counter, :) = (N(counter, :) - mean(N(counter,1:Zzero)))/std(N(counter,1:Zzero));
            %  N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
            counter = counter + 1;
        end
    end
end
N = N(~isnan(sum(N,2)),:);
if smooth(1) == 1
    N = smoothdata(N, 1, 'sgolay', smooth(2));
else
end
N_CS_o_H = N;
BinMin = Izero +1 - 1/binsize;
BinMax = Izero +1 + round(.5/binsize);
IZERO = 1/binsize + 1;
[S, I] = sort(mean(N_CS_o_H(:,(Izero):(Izero+.15/binsize)),2), 'descend');
N_CS_o_H = N_CS_o_H(I,:);
% N_CS_o_H = N_CS_o_H(:,BinMin:BinMax);
figure
nexttile
h = imagesc(edges(1:end-1), [1:size(N_CS_o_H, 1)], N_CS_o_H, [-3 20]);
ylabel('PC sorted by Cspk decrease');
xlabel('time from cued reward');
colorbar
xline(0, 'b');
% xline(-.68, 'k');
% xline(-.62, 'k');
% xline(-.4, 'k');
xlim([-1 .5]);
FigureWrap(NaN, 'Hab_Cspk_Heatmap_lickAlignedOutside', NaN, NaN, NaN, NaN, 2.0, 3.0);


counter = 1;
clear N
clear N_CS_o_N
for n =1:length(CS)
    R = CS(n).RecorNum;
    if [Rlist(R).day] <= 3
            Trials = [Rlist(R).LickOnsets];
        trigger = Trials(strcmp({Trials.Outcome}, 'o'));
        if ~isempty(trigger)
            trigger = [trigger.time];
            [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
%             N(counter, :) = (N(counter, :) - mean(N(counter,1:Zzero)))/std(N(counter,1:Zzero));
            %  N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
            counter = counter + 1;
        end
    end
end
N = N(~isnan(sum(N,2)),:);
if smooth(1) == 1
    N = smoothdata(N, 1, 'sgolay', smooth(2));
else
end
N_CS_o_N = N;
BinMin = Izero +1 - 1/binsize;
BinMax = Izero +1 + round(.5/binsize);
IZERO = 1/binsize + 1;
[S, I] = sort(mean(N_CS_o_N(:,(Izero):(Izero+.15/binsize)),2), 'descend');
N_CS_o_N = N_CS_o_N(I,:);
% N_CS_o_N = N_CS_o_N(:,BinMin:BinMax);
figure
nexttile
h = imagesc(edges(1:end-1), [1:size(N_CS_o_N, 1)], N_CS_o_N, [-3 20]);
ylabel('PC sorted by Cspk decrease');
xlabel('time from uncued reward');
colorbar
xline(0, 'b');
% xline(-.68, 'k');
% xline(-.62, 'k');
% xline(-.4, 'k');
xlim([-1 .5]);
FigureWrap(NaN, 'Naive_Cspk_Heatmap_LickAlignedOutside', NaN, NaN, NaN, NaN, 2.0, 3.0);


counter = 1;
clear N
clear N_CS_o_T
for n =1:length(CS)
    R = CS(n).RecorNum;
    if [Rlist(R).TrainBoo] == 1
             Trials = [Rlist(R).LickOnsets];
        trigger = Trials(strcmp({Trials.Outcome}, 'o'));
        if ~isempty(trigger)
            trigger = [trigger.time];
            [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
%             N(counter, :) = (N(counter, :) - mean(N(counter,1:Zzero)))/std(N(counter,1:Zzero));
            %  N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
            counter = counter + 1;
        end
    end
end
N = N(~isnan(sum(N,2)),:);
if smooth(1) == 1
    N = smoothdata(N, 1, 'sgolay', smooth(2));
else
end
N_CS_o_T = N;
BinMin = Izero +1 - 1/binsize;
BinMax = Izero +1 + round(.5/binsize);
IZERO = 1/binsize + 1;
[S, I] = sort(mean(N_CS_o_T(:,(Izero):(Izero+.15/binsize)),2), 'descend');
N_CS_o_T = N_CS_o_T(I,:);
% N_CS_o_T = N_CS_o_T(:,BinMin:BinMax);
figure
nexttile
h = imagesc(edges(1:end-1), [1:size(N_CS_o_T, 1)], N_CS_o_T, [-3 20]);
ylabel('PC sorted by Cspk decrease');
xlabel('time from cued reward');
colorbar
xline(0, 'b');
% xline(-.68, 'k');
% xline(-.62, 'k');
% xline(-.4, 'k');
xlim([-1 .5]);
FigureWrap(NaN, 'Trained_Cspk_Heatmap_LickAligned_outside', NaN, NaN, NaN, NaN, 2.0, 3.0);



counter = 1;
clear N
clear N_CS_sil
for n =1:length(CS)
    R = CS(n).RecorNum;
    if [Rlist(R).day] >= 0
            Trials = [Rlist(R).LickOnsets];
        trigger = Trials(strcmp({Trials.TrialType}, 'j_s'));
        if ~isempty(trigger)
            trigger = [trigger.time];
            [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
%             N(counter, :) = (N(counter, :) - mean(N(counter,1:Zzero)))/std(N(counter,1:Zzero));
            %  N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
            counter = counter + 1;
        end
    end
end
N = N(~isnan(sum(N,2)),:);
if smooth(1) == 1
    N = smoothdata(N, 1, 'sgolay', smooth(2));
else
end
N_CS_sil = N;
BinMin = Izero +1 - 1/binsize;
BinMax = Izero +1 + round(.5/binsize);
IZERO = 1/binsize + 1;
[S, I] = sort(mean(N_CS_sil(:,(Izero):(Izero+.15/binsize)),2), 'descend');
N_CS_sil = N_CS_sil(I,:);
% N_CS_sil = N_CS_sil(:,BinMin:BinMax);
% figure
% nexttile
% h = imagesc(edges(BinMin:BinMax)+binsize/2, [1:size(N_CS_sil, 1)], N_CS_sil, [-70 50]);
% ylabel('PC sorted by Cspk decrease');
% xlabel('time from rewarded solenoid');
% colorbar
% xline(0, 'b');
% xline(-.68, 'k');
% xline(-.62, 'k');
% xline(-.4, 'k');
% xlim([-1 1]);
FigureWrap(NaN, 'Silent_Cspk_Heatmap', NaN, NaN, NaN, NaN, 2.0, 3.0);



figure
nexttile
hold on
shadedErrorBar2(edges(1:end-1), nanmean(N_CS_o_H, 1), nanstd(N_CS_o_H, 0, 1)/sqrt(size(N_CS_o_H, 1)), 'LineProp', {C(1,:)});
shadedErrorBar2(edges(1:end-1), nanmean(N_CS_o_N, 1), nanstd(N_CS_o_N, 0, 1)/sqrt(size(N_CS_o_N, 1)), 'LineProp', {C(4,:)});
% shadedErrorBar2(edges(:,BinMin:BinMax), nanmean(N_CS_t_N, 1), nanstd(N_CS_t_N, 0, 1)/sqrt(size(N_CS_t_N, 1)), 'LineProp', {'g'});
shadedErrorBar2(edges(1:end-1), nanmean(N_CS_sil, 1), nanstd(N_CS_sil, 0, 1)/sqrt(size(N_CS_sil, 1)), 'LineProp', {C(9,:)});
shadedErrorBar2(edges(1:end-1), nanmean(N_CS_o_T, 1), nanstd(N_CS_o_T, 0, 1)/sqrt(size(N_CS_o_T, 1)), 'LineProp', {C(2,:)});
% xline(-.68, 'g', 'LineWidth', 1);
xline(0, 'k', 'LineWidth', 1);
xlim([-1 0.5])
% legend({'cued reward habituated'; 'uncued reward naive'; 'silent reward'; 'cued reward trained'; 'reward'}, 'Location', 'northoutside', 'FontSize', 12);
% legend('boxoff')
ylim([-.5 6]);
xlabel('time from lick outside trial (s)');
ylabel('Cspk/s')
FormatFigure(NaN, NaN)
FigureWrap(NaN, 'TrainingStageCspk_lickAlignedOutside', NaN, NaN, NaN, NaN, 2.0, 3.0);
% xlim([0 .15]);
FigureWrap(NaN, 'TrainingStageCspk_zoom', NaN, NaN, NaN, NaN, 2.0, 3.0);