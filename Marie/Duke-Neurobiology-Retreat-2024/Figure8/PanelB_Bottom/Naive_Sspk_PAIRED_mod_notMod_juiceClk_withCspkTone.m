bmin = -3;
bmax = 2;
binsize = .01;
Izero = ((abs(bmin)-1)/binsize) - 1;
smooth = [1, 5];
clear N
clear N_b_ModJ
clear N_b_NOmodJ
clear N_j_ModJ
clear N_j_NoModJ
%C = colororder;

counter = 1;
for n = 1:length(SS_paired_ModJuiceClk)
    R = SS_paired_ModJuiceClk(n).RecorNum;
    if [Rlist(R).day] == 7 | [Rlist(R).day] == 8 | [Rlist(R).day] == 9
    Trials = [Rlist(R).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 'b'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
         [trigger, trialsNoSpike] = TrialsWith_outCS(trigger.', CS_paired_ModJuiceClk, n, [-.62 -.4]);
        [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, SS_paired_ModJuiceClk, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
        % zscore if we want to switch back N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero));
      % N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
        counter = counter + 1;
    end
    end
end
N = N(~isnan(sum(N,2)),:);
if smooth(1) == 1
    N_b_ModJ.N = smoothdata(N, 2, 'sgolay', smooth(2));
else
    N_b_ModJ.N = N;
end
N_b_ModJ.edges = edges;
counterL = 1;
trials_c = 0;
list_trialsC = Rlist([Rlist.day] == 7 | [Rlist.day] == 8 | [Rlist.day] == 9);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 'b'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
                 [trigger, trialsNoSpike] = TrialsWith_outCS(trigger.', CS_paired_ModJuiceClk, n, [-.62 -.4]);
        [N_b_ModJ(counterL).LickHist_N, N_b_ModJ(counterL).LickHist_edges] = LickHist(trigger, list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_b_ModJ(counterL).DeliveryHist_N, N_b_ModJ(counterL).DeliveryHist_edges] = LickHist(trigger, list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
                [N_b_ModJ(counterL).RunMean, N_b_ModJ(counterL).RunEdges, ~] = RunSpeedHistLines(trigger, list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_b_ModJ(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end


clear N
counter = 1;
for n = 1:length(SS_paired_NOmodJuiceClk)
    R = SS_paired_NOmodJuiceClk(n).RecorNum;
    if [Rlist(R).day] == 7 | [Rlist(R).day] == 8 | [Rlist(R).day] == 9
    Trials = [Rlist(R).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 'b'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
                 [trigger, trialsNoSpike] = TrialsWith_outCS(trigger.', CS_paired_NOmodJuiceClk, n, [-.62 -.4]);
        [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, SS_paired_NOmodJuiceClk, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
      % N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
        counter = counter + 1;
    end
    end
end
if smooth(1) == 1
    N_b_NOmodJ.N = smoothdata(N, 2, 'sgolay', smooth(2));
else
    N_b_NOmodJ.N = N;
end
N_b_NOmodJ.edges = edges;
counterL = 1;
trials_c = 0;
list_trialsC =  Rlist([Rlist.day] == 7 | [Rlist.day] == 8 | [Rlist.day] == 9);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 'b'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
                 [trigger, trialsNoSpike] = TrialsWith_outCS(trigger.', CS_paired_NOmodJuiceClk, n, [-.62 -.4]);
        [N_b_NOmodJ(counterL).LickHist_N, N_b_NOmodJ(counterL).LickHist_edges] = LickHist(trigger, list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_b_NOmodJ(counterL).DeliveryHist_N, N_b_NOmodJ(counterL).DeliveryHist_edges] = LickHist(trigger, list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
        %[N_b_NOmodJ(counterL).RunMean, N_b_NOmodJ(counterL).RunEdges, tester] = RunSpeedHistLines(trigger, list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_b_NOmodJ(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end
allRTs = [];
ballRTs = [];
allTrialStruct = [];
list_trialsC =  Rlist([Rlist.day] == 7 | [Rlist.day] == 8 | [Rlist.day] == 9);
for n = 1:length(list_trialsC)
    thisTrialStruct = list_trialsC(n).TrialStruct;
allRTs = [allRTs; [thisTrialStruct.RTj].'];
    thisTrialStruct_b = thisTrialStruct(strcmp({thisTrialStruct.TrialType}, 'b')).RTj;
ballRTs = [ballRTs;  [thisTrialStruct_b].'];
allTrialStruct = [allTrialStruct; thisTrialStruct];
end
allRTs(isinf(allRTs) | isnan(allRTs)) = [];
ballRTs(isinf(ballRTs) | isnan(ballRTs)) = [];
figure
hold on
PredictionTrials = allTrialStruct(strcmp({allTrialStruct.Outcome}, 'p'));
if ~isempty(PredictionTrials)
[HistN, HistEdge] = histcounts([PredictionTrials.RTj], [-1.5:.05:45]);
bar(HistEdge(1:end-1), HistN/length(allTrialStruct), 'FaceAlpha', .5, 'FaceColor', C(1,:));
end
ReactionTrials = allTrialStruct(strcmp({allTrialStruct.Outcome}, 'r'));
if ~isempty(ReactionTrials)
[HistN, HistEdge] = histcounts([ReactionTrials.RTj], [-1.5:.05:45]);
bar(HistEdge(1:end-1), HistN/length(allTrialStruct), 'FaceAlpha', .5, 'FaceColor', C(2,:));
end
OutsideTrials = allTrialStruct(strcmp({allTrialStruct.Outcome}, 'o') | strcmp({allTrialStruct.Outcome}, 'b'));
if ~isempty(OutsideTrials)
[HistN, HistEdge] = histcounts([OutsideTrials.RTj], [-1:.05:45]);
bar(HistEdge(1:end-1), HistN/length(allTrialStruct), 'FaceAlpha', .5, 'FaceColor', C(3,:));
end
xline(-.682, 'g', 'LineWidth', 1);
xline(0, 'c', 'LineWidth', 1);
xline(.3, 'k', 'LineWidth', 1);
xline(-.3, 'k', 'LineWidth', 1);
xlim([-1.5 2.5])
xlabel('time from rewarded solenoid (s)');
ylabel('n lick onsets');
FormatFigure(NaN, NaN);
legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'}, 'Location', 'northoutside', 'FontSize', 12);
legend('boxoff')


figure
% nexttile
% hold on
% shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_j_ModJ.N}.'), 1), nanstd(cell2mat({N_j_ModJ.N}.'), 0, 1)/sqrt(size(cell2mat({N_j_ModJ.N}.'), 1)), 'LineProp', {C(1,:)});
% shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_j_NoModJ.N}.'), 1), nanstd(cell2mat({N_j_NoModJ.N}.'), 0, 1)/sqrt(size(cell2mat({N_j_NoModJ.N}.'), 1)), 'LineProp', {C(9,:)});
% %xline(-.682, 'g', 'LineWidth', 1);
% xline(0, 'c', 'LineWidth', 1);
% xlim([-1 0.5])
% xline(-.62, 'k');
% xline(-.4, 'k');
% % legend({'unmodulated by unexpected reward'; 'modulated by  unexpected reward'; 'reward'}, 'Location', 'northoutside', 'FontSize', 12);
% % legend('boxoff')
% ylim([70 100]);
% xlabel('time from rewarded solenoid (s)');
% ylabel('Sspk/s')
% FormatFigure(NaN, NaN)

nexttile
hold on
shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_b_NOmodJ.N}.'), 1), nanstd(cell2mat({N_b_NOmodJ.N}.'), 0, 1)/sqrt(size(cell2mat({N_b_NOmodJ.N}.'), 1)), 'LineProp', {C(9,:)});
shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_b_ModJ.N}.'), 1), nanstd(cell2mat({N_b_ModJ.N}.'), 0, 1)/sqrt(size(cell2mat({N_b_ModJ.N}.'), 1)), 'LineProp', {C(1,:)});
xline(-.682, 'g', 'LineWidth', 1);
xline(0, 'c', 'LineWidth', 1);
xlim([-1 0.5])
% legend({'unmodulated by unexpected reward'; 'modulated by unexpected reward'; 'cue'; 'reward'}, 'Location', 'northoutside', 'FontSize', 12);
% legend('boxoff')
ylim([70 100]);
xlabel('time from rewarded solenoid (s)');
ylabel('Sspk/s')
xline(-.62, 'k');
xline(-.4, 'k');
FigureWrap(NaN, 'Naive_Sspk_PAIRED_mod_notMod_juiceClk_withCspkTone', NaN, NaN, NaN, NaN, 2.5, 3.5);

% counterTotalNaive = 0;
% counterNaiveResp = 0;
% counterNaiveNoMod = 0; 
% for n = 1:length(SS_paired)
%     R = CS_paired(n).RecorNum;
%     if [Rlist(R).day] == 7 | [Rlist(R).day] == 8 | [Rlist(R).day] == 9
%         counterTotalNaive = counterTotalNaive + 1;
%     if CS_paired(n).JuiceTimes_clkMod == 1
%         counterNaiveResp = counterNaiveResp + 1;
%     end
%     if CS_paired(n).JuiceTimes_clkMod == 0
%         counterNaiveNoMod = counterNaiveNoMod + 1;
%     end
%     end
% end
% total = counterNaiveNoMod + counterNaiveResp;
% fprintf('%2.1f percent responsive Naive \n',  (100*counterNaiveResp/total))
% figure
% h = pie([counterNaiveResp/total counterNaiveNoMod/total], {'Resp. unexpected reward'; 'No resp. unexepected reward'});
% patchHand = findobj(h, 'Type', 'Patch'); 
% patchHand(1).FaceColor = C(2,:);
% patchHand(2).FaceColor = C(9,:);
% title('Naive')
% FigureWrap(NaN, 'Naive_Sspk_PAIRED_mod_notMod_juiceClk_Pie', NaN, NaN, NaN, NaN, 1.0, 1.0);


