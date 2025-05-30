% Find populations of Cspks that are responsive or not to tone (lines 6- 98) in the naive
% condition, and check how these populations respond to tone and solenoid
% click. Make a pie chart of Cspk recorded in naive animals that respond to
% the tone or are unresponsive.


%This section Re-run modulation calculation:

% Set parameters
bmin = -1;
bmax = 1;
binsize = .01;
Izero = abs(bmin/binsize) - 1;
SD = 3;

% Remove any old calculations
FieldNames = fields(CS);
if any(strcmp(FieldNames, 'JuiceTimes_both'))
    CS = rmfield(CS, 'JuiceTimes_both');
end
if any(strcmp(FieldNames, 'JuiceTimes_clk'))
    CS = rmfield(CS, 'JuiceTimes_clk');
end
if any(strcmp(FieldNames, 'JuiceTimes_clkMod'))
    CS = rmfield(CS, 'JuiceTimes_clkMod');
end
if any(strcmp(FieldNames, 'ToneTimes'))
    CS = rmfield(CS, 'ToneTimes');
end
if any(strcmp(FieldNames, 'ToneMod'))
    CS = rmfield(CS, 'ToneMod');
end


for n = 1:length(CS)
    R = CS(n).RecorNum;
    Trials = [Rlist(R).TrialStruct];
    if [Rlist(R).day] == 7 | [Rlist(R).day] == 8 | [Rlist(R).day] == 9
        trigger = Trials(strcmp({Trials.TrialType}, 'b'));
    else
        trigger = Trials(strcmp({Trials.TrialType}, 'j'));
    end
    if length(trigger) > 20
        trigger = [trigger.JuiceTime];
        [N, edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
        [struct.LatLow, struct.LatHigh, struct.modBoo, struct.Dir, struct.doubleBoo] = LatencyMod(0, N, edges, SD, [0 .4], 0);
        CS(n).JuiceTimes_clk.modLatStruct = struct;
        CS(n).JuiceTimes_clk.Dir = struct.Dir;
        if CS(n).JuiceTimes_clk.modLatStruct.modBoo == 1
            CS(n).JuiceTimes_clkMod = true;
        else
            if [Rlist(R).day] >= 7 %here I force it to be only false if Cspk is unresponsive to both juice alone and juice after cue
                trigger = Trials(strcmp({Trials.TrialType}, 'b'));
                trigger = [trigger.JuiceTime];
                [N, edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
                [struct.LatLow, struct.LatHigh, struct.modBoo, struct.Dir, struct.doubleBoo] = LatencyMod(0, N, edges, SD, [0 .4], 0);
                CS(n).JuiceTimes_both.modLatStruct = struct;
                CS(n).JuiceTimes_both.Dir = struct.Dir;
                if CS(n).JuiceTimes_both.modLatStruct.modBoo == 0
                    CS(n).JuiceTimes_clkMod = false;
                else
                    CS(n).JuiceTimes_clkMod = true;
                end
            else
                CS(n).JuiceTimes_clkMod = false;
            end
        end
    else
        CS(n).JuiceTimes_clkMod = NaN;
    end
end

for n = 1:length(CS)
    if ~isempty([Rlist(CS(n).RecorNum).ToneTimes])
        [N, edges] = OneUnitHistStructTimeLimLineINDEX(Rlist(CS(n).RecorNum).ToneTimes, n, CS, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
        [struct.LatLow, struct.LatHigh, struct.modBoo, struct.Dir, struct.doubleBoo] = LatencyMod(0, N, edges, SD, [0 .4], 0);
        CS(n).ToneTimes.modLatStruct = struct;
        CS(n).ToneTimes.Dir = struct.Dir;
        if CS(n).ToneTimes.modLatStruct.modBoo == 1
            CS(n).ToneMod = true;
        else
            CS(n).ToneMod = false;
        end
    else
        CS(n).ToneMod = NaN;
    end
end


CS_ModJuiceClk =  CS([CS.JuiceTimes_clkMod] == 1);
CS_NOmodJuiceClk =  CS([CS.JuiceTimes_clkMod] == 0);


CS_ModTone = CS([CS.ToneMod] == 1);
CS_NOtoneMod = CS([CS.ToneMod] == 0);

% End re-run modulation section


bmin = -3;
bmax = 2;
binsize = .005;
Izero = ((abs(bmin)-1)/binsize) - 1;
smooth = [1, 5];
clear N
clear N_t_modT
clear N_t_NOmodT
clear N_j_NOmodT
clear N_j_modT
clear N_eClk_NOmodT
clear N_eClk_modT
%C = colororder;
clear N
counter = 1;
for n = 1:length(CS_ModTone)
    R = CS_ModTone(n).RecorNum;
    if [Rlist(R).day] == 1  | [Rlist(R).day] ==  2 | [Rlist(R).day] == 3
    Trials = [Rlist(R).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 't'));
    if ~isempty(trigger)
        trigger = [trigger.FictiveJuice];
        [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS_ModTone, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
        % zscore if we want to switch back N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero));
      % N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
        counter = counter + 1;
    else
        hello = 0
    end
    end
end
N = N(~isnan(sum(N,2)),:);
if smooth(1) == 1
    N_t_modT.N = smoothdata(N, 2, 'sgolay', smooth(2));
else
    N_t_modT.N = N;
end
N_t_modT.edges = edges;
counterL = 1;
trials_c = 0;
list_trialsC = Rlist([Rlist.day] == 1  | [Rlist.day] ==  2 | [Rlist.day] == 3);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 't'));
    if ~isempty(trigger)
        trigger = [trigger.FictiveJuice];
        [N_t_modT(counterL).LickHist_N, N_t_modT(counterL).LickHist_edges] = LickHist(trigger.', list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_t_modT(counterL).DeliveryHist_N, N_t_modT(counterL).DeliveryHist_edges] = LickHist(trigger.', list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
                [N_t_modT(counterL).RunMean, N_t_modT(counterL).RunEdges, ~] = RunSpeedHistLines(trigger.', list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_t_modT(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end

clear N
counter = 1;
for n = 1:length(CS_ModTone)
    R = CS_ModTone(n).RecorNum;
    if [Rlist(R).day] == 1  | [Rlist(R).day] ==  2 | [Rlist(R).day] == 3
    Trials = [Rlist(R).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 'j'));
    if ~isempty(trigger)
        trigger = [trigger.FictiveJuice];
        [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS_ModTone, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
        % zscore if we want to switch back N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero));
      % N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
        counter = counter + 1;
    else
        hello = 0
    end
    end
end
N = N(~isnan(sum(N,2)),:);
if smooth(1) == 1
    N_j_modT.N = smoothdata(N, 2, 'sgolay', smooth(2));
else
    N_j_modT.N = N;
end
N_j_modT.edges = edges;
counterL = 1;
trials_c = 0;
list_trialsC = Rlist([Rlist.day] == 1  | [Rlist.day] ==  2 | [Rlist.day] == 3);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 'j'));
    if ~isempty(trigger)
        trigger = [trigger.FictiveJuice];
        [N_j_modT(counterL).LickHist_N, N_j_modT(counterL).LickHist_edges] = LickHist(trigger.', list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_j_modT(counterL).DeliveryHist_N, N_j_modT(counterL).DeliveryHist_edges] = LickHist(trigger.', list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
                [N_j_modT(counterL).RunMean, N_j_modT(counterL).RunEdges, ~] = RunSpeedHistLines(trigger.', list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_j_modT(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end

clear N
counter = 1;
for n = 1:length(CS_NOtoneMod)
    R = CS_NOtoneMod(n).RecorNum;
    if [Rlist(R).day] == 1  | [Rlist(R).day] ==  2 | [Rlist(R).day] == 3
    Trials = [Rlist(R).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 'j'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
        [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS_NOtoneMod, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
      % N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
        counter = counter + 1;
    else 
        hello = 0
    end
    end
end
if smooth(1) == 1
    N_j_NOmodT.N = smoothdata(N, 2, 'sgolay', smooth(2));
else
    N_j_NOmodT.N = N;
end
N_j_NOmodT.edges = edges;
counterL = 1;
trials_c = 0;
list_trialsC = Rlist([Rlist.day] == 1  | [Rlist.day] ==  2 | [Rlist.day] == 3);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 'j'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
        [N_j_NOmodT(counterL).LickHist_N, N_j_NOmodT(counterL).LickHist_edges] = LickHist(trigger.', list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_j_NOmodT(counterL).DeliveryHist_N, N_j_NOmodT(counterL).DeliveryHist_edges] = LickHist(trigger.', list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
        [N_j_NOmodT(counterL).RunMean, N_j_NOmodT(counterL).RunEdges, tester] = RunSpeedHistLines(trigger.', list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_j_NOmodT(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end

clear N
counter = 1;
for n = 1:length(CS_NOtoneMod)
    R = CS_NOtoneMod(n).RecorNum;
    if [Rlist(R).day] == 1  | [Rlist(R).day] ==  2 | [Rlist(R).day] == 3
    Trials = [Rlist(R).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 't'));
    if ~isempty(trigger)
        trigger = [trigger.FictiveJuice];
        [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS_NOtoneMod, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
      % N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
        counter = counter + 1;
    else 
        hello = 0
    end
    end
end
if smooth(1) == 1
    N_t_NOmodT.N = smoothdata(N, 2, 'sgolay', smooth(2));
else
    N_t_NOmodT.N = N;
end
N_t_NOmodT.edges = edges;
counterL = 1;
trials_c = 0;
list_trialsC = Rlist([Rlist.day] == 1  | [Rlist.day] ==  2 | [Rlist.day] == 3);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 't'));
    if ~isempty(trigger)
        trigger = [trigger.FictiveJuice];
        [N_t_NOmodT(counterL).LickHist_N, N_t_NOmodT(counterL).LickHist_edges] = LickHist(trigger.', list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_t_NOmodT(counterL).DeliveryHist_N, N_t_NOmodT(counterL).DeliveryHist_edges] = LickHist(trigger.', list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
        [N_t_NOmodT(counterL).RunMean, N_t_NOmodT(counterL).RunEdges, tester] = RunSpeedHistLines(trigger.', list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_t_NOmodT(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end


% clear N
% counter = 1;
% for n = 1:length(CS_ModTone)
%     R = CS_ModTone(n).RecorNum;
%     if [Rlist(R).day] == 1  | [Rlist(R).day] ==  2 | [Rlist(R).day] == 3
%     trigger = [Rlist(R).NoJuice_Click];
%     if ~isempty(trigger)
%         [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, CS_ModTone, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
%         % zscore if we want to switch back N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero));
%       % N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
%         counter = counter + 1;
%     else
%         hello = 0
%     end
%     end
% end
% N = N(~isnan(sum(N,2)),:);
% if smooth(1) == 1
%     N_eClk_modT.N = smoothdata(N, 2, 'sgolay', smooth(2));
% else
%     N_eClk_modT.N = N;
% end
% N_eClk_modT.edges = edges;
% counterL = 1;
% trials_c = 0;
% list_trialsC = Rlist([Rlist.day] == 1  | [Rlist.day] ==  2 | [Rlist.day] == 3);
% for n = 1:length(list_trialsC)
%     trigger = [list_trialsC(n).NoTone];
%     if ~isempty(trigger)
%         [N_eClk_modT(counterL).LickHist_N, N_eClk_modT(counterL).LickHist_edges] = LickHist(trigger, list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
%         [N_eClk_modT(counterL).DeliveryHist_N, N_eClk_modT(counterL).DeliveryHist_edges] = LickHist(trigger, list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
%                 [N_eClk_modT(counterL).RunMean, N_eClk_modT(counterL).RunEdges, ~] = RunSpeedHistLines(trigger, list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
%         N_eClk_modT(counterL).trials_c = length(trigger);
%         counterL = counterL + 1;
%     end
% end

% clear N
% counter = 1;
% for n = 1:length(CS_NOtoneMod)
%     R = CS_NOtoneMod(n).RecorNum;
%     if [Rlist(R).day] == 1  | [Rlist(R).day] ==  2 | [Rlist(R).day] == 3
% trigger = [Rlist(R).NoJuice_Clk];
% if ~isempty(trigger)
%         [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, CS_NOtoneMod, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
%       % N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
%         counter = counter + 1;
%     else 
%         hello = 0
%     end
%     end
% end
% if smooth(1) == 1
%     N_eClk_NOmodT.N = smoothdata(N, 2, 'sgolay', smooth(2));
% else
%     N_eClk_NOmodT.N = N;
% end
% N_eClk_NOmodT.edges = edges;
% counterL = 1;
% trials_c = 0;
% list_trialsC = Rlist([Rlist.day] == 1  | [Rlist.day] ==  2 | [Rlist.day] == 3);
% for n = 1:length(list_trialsC)
%     trigger = [list_trialsC(n).NoJuice_clk];
%     if ~isempty(trigger)
%         [N_eClk_NOmodT(counterL).LickHist_N, N_eClk_NOmodT(counterL).LickHist_edges] = LickHist(trigger, list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
%         [N_eClk_NOmodT(counterL).DeliveryHist_N, N_eClk_NOmodT(counterL).DeliveryHist_edges] = LickHist(trigger, list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
%         [N_eClk_NOmodT(counterL).RunMean, N_eClk_NOmodT(counterL).RunEdges, tester] = RunSpeedHistLines(trigger, list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
%         N_eClk_NOmodT(counterL).trials_c = length(trigger);
%         counterL = counterL + 1;
%     end
% end
% allRTs = [];
% ballRTs = [];
% allTrialStruct = [];
% C = colororder;
% list_trialsC = Rlist([Rlist.day] == 7  | [Rlist.day] ==  8 | [Rlist.day] == 9);
% for n = 1:length(list_trialsC)
%     thisTrialStruct = list_trialsC(n).TrialStruct;
% allRTs = [allRTs; [thisTrialStruct.RTj].'];
%     thisTrialStruct_b = thisTrialStruct(strcmp({thisTrialStruct.TrialType}, 'b')).RTj;
% ballRTs = [ballRTs;  [thisTrialStruct_b].'];
% allTrialStruct = [allTrialStruct; thisTrialStruct];
% end
% allRTs(isinf(allRTs) | isnan(allRTs)) = [];
% ballRTs(isinf(ballRTs) | isnan(ballRTs)) = [];
% figure
% hold on
% PredictionTrials = allTrialStruct(strcmp({allTrialStruct.Outcome}, 'p'));
% if ~isempty(PredictionTrials)
% [HistN, HistEdge] = histcounts([PredictionTrials.RTj], [-1.5:.05:45]);
% bar(HistEdge(1:end-1), HistN/length(allTrialStruct), 'FaceAlpha', .5, 'FaceColor', C(1,:));
% end
% ReactionTrials = allTrialStruct(strcmp({allTrialStruct.Outcome}, 'r'));
% if ~isempty(ReactionTrials)
% [HistN, HistEdge] = histcounts([ReactionTrials.RTj], [-1.5:.05:45]);
% bar(HistEdge(1:end-1), HistN/length(allTrialStruct), 'FaceAlpha', .5, 'FaceColor', C(2,:));
% end
% OutsideTrials = allTrialStruct(strcmp({allTrialStruct.Outcome}, 'o') | strcmp({allTrialStruct.Outcome}, 'b'));
% if ~isempty(OutsideTrials)
% [HistN, HistEdge] = histcounts([OutsideTrials.RTj], [-1:.05:45]);
% bar(HistEdge(1:end-1), HistN/length(allTrialStruct), 'FaceAlpha', .5, 'FaceColor', C(3,:));
% end
% xline(-.682, 'g', 'LineWidth', 1);
% xline(0, 'c', 'LineWidth', 1);
% xline(.3, 'k', 'LineWidth', 1);
% xline(-.3, 'k', 'LineWidth', 1);
% xlim([-1.5 2.5])
% xlabel('time from rewarded solenoid (s)');
% ylabel('n lick onsets');
% FormatFigure(NaN, NaN);
% %legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'}, 'Location', 'northoutside', 'FontSize', 12);
% %legend('boxoff')


figure
nexttile
hold on
shadedErrorBar2(N_j_modT(1).edges(1:end-1), nanmean(cell2mat({N_j_NOmodT.N}.'), 1), nanstd(cell2mat({N_j_NOmodT.N}.'), 0, 1)/sqrt(size(cell2mat({N_j_NOmodT.N}.'), 1)), 'LineProp', {C(9,:)});
shadedErrorBar2(N_j_modT(1).edges(1:end-1), nanmean(cell2mat({N_j_modT.N}.'), 1), nanstd(cell2mat({N_j_modT.N}.'), 0, 1)/sqrt(size(cell2mat({N_j_modT.N}.'), 1)), 'LineProp', {C(4,:)});
%xline(-.682, 'g', 'LineWidth', 1);
xline(0, 'c', 'LineWidth', 1);
xlim([-1 0.5])
%legend({'unmodulated by tone (unexpected reward)'; 'modulated by tone (unexpected reward)'; 'reward'}, 'Location', 'northoutside', 'FontSize', 12);
%legend('boxoff')
xlabel('time from rewarded solenoid (s)');
ylabel('Cspk/s')
ylim([0 10]);
FormatFigure(NaN, NaN);

nexttile
hold on
shadedErrorBar2(N_j_modT(1).edges(1:end-1), nanmean(cell2mat({N_t_NOmodT.N}.'), 1), nanstd(cell2mat({N_t_NOmodT.N}.'), 0, 1)/sqrt(size(cell2mat({N_t_NOmodT.N}.'), 1)), 'LineProp', {C(9,:)});
shadedErrorBar2(N_j_modT(1).edges(1:end-1), nanmean(cell2mat({N_t_modT.N}.'), 1), nanstd(cell2mat({N_t_modT.N}.'), 0, 1)/sqrt(size(cell2mat({N_t_modT.N}.'), 1)), 'LineProp', {C(4,:)});
xline(-.682, 'g', 'LineWidth', 1);
%xline(0, 'c', 'LineWidth', 1);
xlim([-1 0.5])
%legend({'unmodulated by tone (omitted reward)'; 'modulated by tone (omitted reward)'; 'cue'}, 'Location', 'northoutside', 'FontSize', 12);
%legend('boxoff')
xlabel('time from omitted solenoid (s)');
ylabel('Cspk/s')
ylim([0 10]);
FormatFigure(NaN, NaN)

% cells that are modulated by expected reward do not have enough eClk
% trials to evaluate
% nexttile
% hold on
% shadedErrorBar2(N_eClk_NOmodT(1).edges(1:end-1), nanmean(cell2mat({N_eClk_NOmodT.N}.'), 1), nanstd(cell2mat({N_eClk_NOmodT.N}.'), 0, 1)/sqrt(size(cell2mat({N_eClk_NOmodT.N}.'), 1)), 'LineProp', {C(2,:)});
% shadedErrorBar2(N_eClk_modT(1).edges(1:end-1), nanmean(cell2mat({N_eClk_modT.N}.'), 1), nanstd(cell2mat({N_eClk_modT.N}.'), 0, 1)/sqrt(size(cell2mat({N_eClk_modT.N}.'), 1)), 'LineProp', {C(1,:)});
% xline(-.682, 'g', 'LineWidth', 1);
% %xline(0, 'c', 'LineWidth', 1);
% xlim([-1 0.5])
% %legend({'unmodulated by unexpected reward (omitted reward)'; 'responsive to unexpected reward (omitted reward)'; 'cue'}, 'Location', 'northoutside', 'FontSize', 12);
% %legend('boxoff')
% xlabel('time from omitted solenoid (s)');
% ylabel('Cspk/s')
% ylim([-1 12]);
 FigureWrap(NaN, 'Naive_1_3_Cspk_mod_notMod_Tone', NaN, NaN, NaN, NaN, 5, 3.5);
 

counterTotalNaive = 0;
counterNaiveResp = 0;
counterNaiveNoMod = 0;
for n = 1:length(CS)
    R = CS(n).RecorNum;
    if [Rlist(R).day] == 1  | [Rlist(R).day] ==  2 | [Rlist(R).day] == 3
        counterTotalNaive = counterTotalNaive + 1;
    if CS(n).ToneMod == 1
        counterNaiveResp = counterNaiveResp + 1;
    end
    if CS(n).ToneMod == 0
        counterNaiveNoMod = counterNaiveNoMod + 1;
    end
    end
end
total = (counterNaiveNoMod+counterNaiveResp)
fprintf('%2.1f percent responsive Naive \n',  (100*counterNaiveResp/(counterNaiveNoMod+counterNaiveResp)))
figure
h = pie([counterNaiveResp/total counterNaiveNoMod/total], {[num2str(round(100*counterNaiveResp/(counterNaiveNoMod+counterNaiveResp))) '% modulated by tone']; 'unmodulated by tone'});
patchHand = findobj(h, 'Type', 'Patch'); 
patchHand(1).FaceColor = C(4,:);
patchHand(2).FaceColor = C(9,:);
title('Naive day 1-3')
 FigureWrap(NaN, 'Naive_day1_3_Cspk_mod_notMod_Tone_Pie', NaN, NaN, NaN, NaN, 1, 1);
