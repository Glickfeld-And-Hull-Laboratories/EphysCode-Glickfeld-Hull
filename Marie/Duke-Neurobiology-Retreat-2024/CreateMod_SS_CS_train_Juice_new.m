bmin = -3;
bmax = 1;
binsize = .01;
Izero = abs(bmin/binsize) - 1;
Zzero = ((abs(bmin) - 1)/binsize);
smooth = [0, 5];


% use new CS_paired and SS_paired creation code from CreateDataset
% clear CS_paired
% clear SS_paired
% % create CS_paired & SS paired- only need to do once
% counter = 1;
% for n = 1:length(CS)
%     if ~isempty(CS(n).PCpair)
%         struct = SS([SS.RecorNum] == [CS(n).RecorNum]);
%         if ~isempty(find([struct.unitID] == CS(n).PCpair, 1))
%             CS_paired(counter) = CS(n);
%             SS_paired(counter) = struct(find([struct.unitID] == CS(n).PCpair, 1));
%             if length(find([struct.unitID] == CS(n).PCpair, 1)) > 1
%                 counter = counter + 1;
%                 CS_paired(counter) = CS(n);
%                 SS_paired(counter) = struct(find([struct.unitID] == CS(n).PCpair, 2));
%             end
%             counter = counter + 1;
%         end
%     end
% end
clear struct
clear N

CS_paired = rmfield(CS_paired, {'JuiceTimes_both', 'JuiceTimes_clk', 'JuiceTimes_clkMod', 'ToneTimes', 'ToneMod'});

SDhigh = 5;
for n = 1:length(CS_paired)
    R = CS_paired(n).RecorNum;
    Trials = [Rlist(R).TrialStruct];
    if [Rlist(R).day] == 7 | [Rlist(R).day] == 8 | [Rlist(R).day] == 9
        trigger = Trials(strcmp({Trials.TrialType}, 'b'));
    else
        trigger = Trials(strcmp({Trials.TrialType}, 'j'));
    end
    if length(trigger) > 15
        trigger = [trigger.JuiceTime];
        [N, edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS_paired, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
        if smooth(1) == 1
            N = smoothdata(N, 1, 'sgolay', smooth(2));
        end
        [struct.LatLow, struct.LatHigh, struct.modBoo, struct.Dir, struct.doubleBoo] = LatencyMod(0, N, edges, SDhigh, [0 .4], 0);
        CS_paired(n).JuiceTimes_clk.modLatStruct = struct;
        CS_paired(n).JuiceTimes_clk.Dir = struct.Dir;
        if CS_paired(n).JuiceTimes_clk.modLatStruct.modBoo == 1 & CS_paired(n).JuiceTimes_clk.modLatStruct.LatHigh > 0 & CS_paired(n).JuiceTimes_clk.modLatStruct.LatHigh < .15
            CS_paired(n).JuiceTimes_clkMod = true;
        else
            if [Rlist(R).day] >= 7 %here I force it to be only false if Cspk is unresponsive to both juice alone and juice after cue
                trigger = Trials(strcmp({Trials.TrialType}, 'b'));
                trigger = [trigger.JuiceTime];
                [N, edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS_paired, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
                [struct.LatLow, struct.LatHigh, struct.modBoo, struct.Dir, struct.doubleBoo] = LatencyMod(0, N, edges, SDhigh, [0 .4], 0);
                CS_paired(n).JuiceTimes_both.modLatStruct = struct;
                CS_paired(n).JuiceTimes_both.Dir = struct.Dir;
                if CS_paired(n).JuiceTimes_both.modLatStruct.modBoo == 0
                    CS_paired(n).JuiceTimes_clkMod = false;
                else
                    if CS_paired(n).JuiceTimes_both.modLatStruct.modBoo == 1 & CS_paired(n).JuiceTimes_both.modLatStruct.LatHigh > 0 & CS_paired(n).JuiceTimes_both.modLatStruct.LatHigh < .15
                        CS_paired(n).JuiceTimes_clkMod = true;
                    else CS_paired(n).JuiceTimes_clkMod = false;
                    end
                end
            else
                CS_paired(n).JuiceTimes_clkMod = false;
            end
        end
    else
        CS_paired(n).JuiceTimes_clkMod = NaN;
    end
end

for n = 1:length(CS_paired)
    if ~isempty([Rlist(CS_paired(n).RecorNum).ToneTimes])
        [N, edges] = OneUnitHistStructTimeLimLineINDEX(Rlist(CS_paired(n).RecorNum).ToneTimes, n, CS_paired, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
        if smooth(1) == 1
            N = smoothdata(N, 1, 'sgolay', smooth(2));
        end
        [struct.LatLow, struct.LatHigh, struct.modBoo, struct.Dir, struct.doubleBoo] = LatencyMod(0, N, edges, SDhigh, [0 .4], 0);
        CS_paired(n).ToneTimes.modLatStruct = struct;
        CS_paired(n).ToneTimes.Dir = struct.Dir;
        if CS_paired(n).ToneTimes.modLatStruct.modBoo == 1
            CS_paired(n).ToneMod = true;
        else
            CS_paired(n).ToneMod = false;
        end
    else
        CS_paired(n).ToneMod = NaN;
    end
end


%CS_pairedpaired_mod = CS_paired([CS_paired.ToneMod] | [CS_paired.JuiceTimes_clkMod] | [CS_paired.NoJuiceClkMod]);
%SSpaired_mod = SS_paired([CS_paired.ToneMod] | [CS_paired.JuiceTimes_clkMod] | [CS_paired.NoJuiceClkMod]);

CS_paired_ModJuiceClk =  CS_paired([CS_paired.JuiceTimes_clkMod] == 1);
SS_paired_ModJuiceClk =  SS_paired([CS_paired.JuiceTimes_clkMod] == 1);

CS_paired_ModTone = CS_paired([CS_paired.ToneMod] == 1);
SS_paired_ModTone = SS_paired([CS_paired.ToneMod] == 1);

% low
bmin = -1;
bmax = 1;
binsize = .01;
Izero = abs(bmin/binsize) - 1;

% use new CS_paired and SS_paired creation code from CreateDataset
% clear CS_paired
% clear SS_paired
% % create CS_paired & SS paired- only need to do once
% counter = 1;
% for n = 1:length(CS)
%     if ~isempty(CS(n).PCpair)
%         struct = SS([SS.RecorNum] == [CS(n).RecorNum]);
%         if ~isempty(find([struct.unitID] == CS(n).PCpair, 1))
%             CS_paired(counter) = CS(n);
%             SS_paired(counter) = struct(find([struct.unitID] == CS(n).PCpair, 1));
%             if length(find([struct.unitID] == CS(n).PCpair, 1)) > 1
%                 counter = counter + 1;
%                 CS_paired(counter) = CS(n);
%                 SS_paired(counter) = struct(find([struct.unitID] == CS(n).PCpair, 2));
%             end
%             counter = counter + 1;
%         end
%     end
% end
clear struct

CS_paired = rmfield(CS_paired, {'JuiceTimes_both', 'JuiceTimes_clk', 'JuiceTimes_clkMod', 'ToneTimes', 'ToneMod'});

SDlow = 3;
for n = 1:length(CS_paired)
    R = CS_paired(n).RecorNum;
    Trials = [Rlist(R).TrialStruct];
    if [Rlist(R).day] == 7 | [Rlist(R).day] == 8 | [Rlist(R).day] == 9
        trigger = Trials(strcmp({Trials.TrialType}, 'b'));
    else
        trigger = Trials(strcmp({Trials.TrialType}, 'j'));
    end
    if length(trigger) > 20
        trigger = [trigger.JuiceTime];
        [N, edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS_paired, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
        if smooth(1) == 1
            N = smoothdata(N, 1, 'sgolay', smooth(2));
        end
        [struct.LatLow, struct.LatHigh, struct.modBoo, struct.Dir, struct.doubleBoo] = LatencyMod(0, N, edges, SDlow, [0 .4], 0);
        CS_paired(n).JuiceTimes_clk.modLatStruct = struct;
        CS_paired(n).JuiceTimes_clk.Dir = struct.Dir;
        if CS_paired(n).JuiceTimes_clk.modLatStruct.modBoo == 1
            CS_paired(n).JuiceTimes_clkMod = true;
        else
            if [Rlist(R).day] >= 7 %here I force it to be only false if Cspk is unresponsive to both juice alone and juice after cue
                trigger = Trials(strcmp({Trials.TrialType}, 'b'));
                trigger = [trigger.JuiceTime];
                [N, edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS_paired, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
                [struct.LatLow, struct.LatHigh, struct.modBoo, struct.Dir, struct.doubleBoo] = LatencyMod(0, N, edges, SDlow, [0 .4], 0);
                CS_paired(n).JuiceTimes_both.modLatStruct = struct;
                CS_paired(n).JuiceTimes_both.Dir = struct.Dir;
                if CS_paired(n).JuiceTimes_both.modLatStruct.modBoo == 0
                    CS_paired(n).JuiceTimes_clkMod = false;
                else
                    CS_paired(n).JuiceTimes_clkMod = true;
                end
            else
                CS_paired(n).JuiceTimes_clkMod = false;
            end
        end
    else
        CS_paired(n).JuiceTimes_clkMod = NaN;
    end
end

for n = 1:length(CS_paired)
    if ~isempty([Rlist(CS_paired(n).RecorNum).ToneTimes])
        [N, edges] = OneUnitHistStructTimeLimLineINDEX(Rlist(CS_paired(n).RecorNum).ToneTimes, n, CS_paired, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
        if smooth(1) == 1
            N = smoothdata(N, 1, 'sgolay', smooth(2));
        end
        [struct.LatLow, struct.LatHigh, struct.modBoo, struct.Dir, struct.doubleBoo] = LatencyMod(0, N, edges, SDlow, [0 .4], 0);
        CS_paired(n).ToneTimes.modLatStruct = struct;
        CS_paired(n).ToneTimes.Dir = struct.Dir;
        if CS_paired(n).ToneTimes.modLatStruct.modBoo == 1
            CS_paired(n).ToneMod = true;
        else
            CS_paired(n).ToneMod = false;
        end
    else
        CS_paired(n).ToneMod = NaN;
    end
end

CS_paired_NOmodJuiceClk =  CS_paired([CS_paired.JuiceTimes_clkMod] == 0);
SS_paired_NOmodJuiceClk =  SS_paired([CS_paired.JuiceTimes_clkMod] == 0);

CS_paired_NOtoneMod = CS_paired([CS_paired.ToneMod] == 0);
SS_paired_NOtoneMod = SS_paired([CS_paired.ToneMod] == 0);
%

bmin = -3;
bmax = 2;
binsize = .01;
Izero = ((abs(bmin)-1)/binsize) - 1;
Zzero = ((abs(bmin) - 1)/binsize);
smooth = [0, 5];
clear N
clear N_b_ModJ
clear N_b_NOmodJ
clear N_j_ModJ
clear N_j_NoModJ
%C = colororder;

counter = 1;
for n = 1:length(SS_paired_ModJuiceClk)
    R = SS_paired_ModJuiceClk(n).RecorNum;
    if [Rlist(R).TrainBoo] == 1
        Trials = [Rlist(R).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 'b'));
        if ~isempty(trigger)
            trigger = [trigger.JuiceTime];
            [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, SS_paired_ModJuiceClk, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
            % zscore if we want to switch back N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero));
            N(counter, :) = (N(counter, :) - mean(N(counter,1:Zzero)));
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
list_trialsC = Rlist([Rlist.TrainBoo] == 1);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 'b'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
        [N_b_ModJ(counterL).LickHist_N, N_b_ModJ(counterL).LickHist_edges] = LickHist(trigger.', list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_b_ModJ(counterL).DeliveryHist_N, N_b_ModJ(counterL).DeliveryHist_edges] = LickHist(trigger.', list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
        [N_b_ModJ(counterL).RunMean, N_b_ModJ(counterL).RunEdges, ~] = RunSpeedHistLines(trigger.', list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_b_ModJ(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end

clear N
counter = 1;
for n = 1:length(SS_paired_ModJuiceClk)
    R = SS_paired_ModJuiceClk(n).RecorNum;
    if [Rlist(R).TrainBoo] == 1
        Trials = [Rlist(R).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 'j'));
        if ~isempty(trigger)
            trigger = [trigger.JuiceTime];
            [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, SS_paired_ModJuiceClk, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
            % zscore if we want to switch back N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero));
            N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
            counter = counter + 1;
        end
    end
end
N = N(~isnan(sum(N,2)),:);
if smooth(1) == 1
    N_j_ModJ.N = smoothdata(N, 2, 'sgolay', smooth(2));
else
    N_j_ModJ.N = N;
end
N_j_ModJ.edges = edges;
counterL = 1;
trials_c = 0;
list_trialsC = Rlist([Rlist.TrainBoo] == 1);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 'j'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
        [N_j_ModJ(counterL).LickHist_N, N_j_ModJ(counterL).LickHist_edges] = LickHist(trigger.', list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_j_ModJ(counterL).DeliveryHist_N, N_j_ModJ(counterL).DeliveryHist_edges] = LickHist(trigger.', list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
        [N_j_ModJ(counterL).RunMean, N_j_ModJ(counterL).RunEdges, ~] = RunSpeedHistLines(trigger.', list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_j_ModJ(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end

clear N
counter = 1;
for n = 1:length(SS_paired_NOmodJuiceClk)
    R = SS_paired_NOmodJuiceClk(n).RecorNum;
    if [Rlist(R).TrainBoo] == 1
        Trials = [Rlist(R).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 'j'));
        if ~isempty(trigger)
            trigger = [trigger.JuiceTime];
            [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, SS_paired_NOmodJuiceClk, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
            % zscore if we want to switch back N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero));
            N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
            counter = counter + 1;
        end
    end
end
N = N(~isnan(sum(N,2)),:);
if smooth(1) == 1
    N_j_NoModJ.N = smoothdata(N, 2, 'sgolay', smooth(2));
else
    N_j_NoModJ.N = N;
end
N_j_NoModJ.edges = edges;
counterL = 1;
trials_c = 0;
list_trialsC = Rlist([Rlist.TrainBoo] == 1);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 'j'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
        [N_j_NoModJ(counterL).LickHist_N, N_j_NoModJ(counterL).LickHist_edges] = LickHist(trigger.', list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_j_NoModJ(counterL).DeliveryHist_N, N_j_NoModJ(counterL).DeliveryHist_edges] = LickHist(trigger.', list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
        [N_j_NoModJ(counterL).RunMean, N_j_NoModJ(counterL).RunEdges, ~] = RunSpeedHistLines(trigger.', list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_j_NoModJ(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end

clear N
counter = 1;
for n = 1:length(SS_paired_NOmodJuiceClk)
    R = SS_paired_NOmodJuiceClk(n).RecorNum;
    if [Rlist(R).TrainBoo] == 1
        Trials = [Rlist(R).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 'b'));
        if ~isempty(trigger)
            trigger = [trigger.JuiceTime];
            [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, SS_paired_NOmodJuiceClk, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
            N(counter, :) = (N(counter, :) - mean(N(counter,1:Zzero)));
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
list_trialsC = Rlist([Rlist.TrainBoo] == 1);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 'b'));
    trigger = trigger(strcmp({trigger.Outcome}, 'r'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
        [N_b_NOmodJ(counterL).LickHist_N, N_b_NOmodJ(counterL).LickHist_edges] = LickHist(trigger.', list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_b_NOmodJ(counterL).DeliveryHist_N, N_b_NOmodJ(counterL).DeliveryHist_edges] = LickHist(trigger.', list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
        [N_b_NOmodJ(counterL).RunMean, N_b_NOmodJ(counterL).RunEdges, tester] = RunSpeedHistLines(trigger.', list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_b_NOmodJ(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end
allRTs = [];
ballRTs = [];
allTrialStruct = [];
list_trialsC = Rlist([Rlist.TrainBoo] == 1);
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
nexttile
hold on
shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_j_ModJ.N}.'), 1), nanstd(cell2mat({N_j_ModJ.N}.'), 0, 1)/sqrt(size(cell2mat({N_j_ModJ.N}.'), 1)), 'LineProp', {C(2,:)});
shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_j_NoModJ.N}.'), 1), nanstd(cell2mat({N_j_NoModJ.N}.'), 0, 1)/sqrt(size(cell2mat({N_j_NoModJ.N}.'), 1)), 'LineProp', {C(9,:)});
%xline(-.682, 'g', 'LineWidth', 1);
xline(0, 'c', 'LineWidth', 1);
xlim([-1 0.5])
% legend({'unmodulated by unexpected reward'; 'modulated by  unexpected reward'; 'reward'}, 'Location', 'northoutside', 'FontSize', 12);
% legend('boxoff')
% ylim([60 120]);
xlabel('time from rewarded solenoid (s)');
ylabel('Sspk/s')
FormatFigure(NaN, NaN)
% FigureWrap(NaN, 'Trained_Sspk_PAIRED_mod_notMod_juiceClk_j', NaN, NaN, NaN, NaN, 2.0, 2.0);

figure
nexttile
hold on
shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_b_NOmodJ.N}.'), 1), nanstd(cell2mat({N_b_NOmodJ.N}.'), 0, 1)/sqrt(size(cell2mat({N_b_NOmodJ.N}.'), 1)), 'LineProp', {C(9,:)});
shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_b_ModJ.N}.'), 1), nanstd(cell2mat({N_b_ModJ.N}.'), 0, 1)/sqrt(size(cell2mat({N_b_ModJ.N}.'), 1)), 'LineProp', {C(2,:)});
xline(-.682, 'g', 'LineWidth', 1);
xline(0, 'c', 'LineWidth', 1);
xlim([-1 0.5])
% legend({['CS resp <' num2str(SDlow) ' SD']; ['CS resp >' num2str(SDhigh) ' SD']; 'tone'; 'reward'}, 'Location', 'northoutside', 'FontSize', 8);
% legend('boxoff')
% ylim([60 120]);
xlabel('time from rewarded solenoid (s)');
ylabel('Sspk/s')
% FigureWrap(NaN, 'Trained_Sspk_PAIRED_mod_notMod_juiceClk_b', NaN, NaN, NaN, NaN, 2.0, 2.0);

counterTotalTrained = 0;
counterTrainedResp = 0;
counterTrainedNoMod = 0;
for n = 1:length(SS_paired)
    R = CS_paired(n).RecorNum;
    if [Rlist(R).TrainBoo] == 1
        counterTotalTrained = counterTotalTrained + 1;
        if CS_paired(n).JuiceTimes_clkMod == 1
            counterTrainedResp = counterTrainedResp + 1;
        end
        if CS_paired(n).JuiceTimes_clkMod == 0
            counterTrainedNoMod = counterTrainedNoMod + 1;
        end
    end
end
total = counterTrainedNoMod + counterTrainedResp;
fprintf('%2.1f percent responsive Trained \n',  (100*counterTrainedResp/total))
figure
h = pie([counterTrainedResp/total counterTrainedNoMod/total], {'Resp. unexpected reward'; 'No resp. unexepected reward'});
patchHand = findobj(h, 'Type', 'Patch');
patchHand(1).FaceColor = C(2,:);
patchHand(2).FaceColor = C(9,:);
title('Trained')
% FigureWrap(NaN, 'Trained_Sspk_PAIRED_mod_notMod_juiceClk_Pie', NaN, NaN, NaN, NaN, 1.0, 1.0);






bmin = -3;
bmax = 2;
binsize = .01;
Izero = ((abs(bmin))/binsize);
Zzero = ((abs(bmin) - 1)/binsize);
smooth = [0, 5];
clear N
clear N_b_ModJ
clear N_b_NOmodJ
clear N_j_ModJ
clear N_j_NoModJ
%C = colororder;

counter = 1;
for n = 1:length(CS_paired_ModJuiceClk)
    R = CS_paired_ModJuiceClk(n).RecorNum;
    if [Rlist(R).TrainBoo] == 1
        Trials = [Rlist(R).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 'b'));
        if ~isempty(trigger)
            trigger = [trigger.JuiceTime];
            [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS_paired_ModJuiceClk, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
            % zscore if we want to switch back N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero));
            N(counter, :) = (N(counter, :) - mean(N(counter,1:Zzero)));
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
list_trialsC = Rlist([Rlist.TrainBoo] == 1);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 'b'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
        [N_b_ModJ(counterL).LickHist_N, N_b_ModJ(counterL).LickHist_edges] = LickHist(trigger.', list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_b_ModJ(counterL).DeliveryHist_N, N_b_ModJ(counterL).DeliveryHist_edges] = LickHist(trigger.', list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
        [N_b_ModJ(counterL).RunMean, N_b_ModJ(counterL).RunEdges, ~] = RunSpeedHistLines(trigger.', list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_b_ModJ(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end

clear N
counter = 1;
for n = 1:length(CS_paired_ModJuiceClk)
    R = CS_paired_ModJuiceClk(n).RecorNum;
    if [Rlist(R).TrainBoo] == 1
        Trials = [Rlist(R).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 'j'));
        if ~isempty(trigger)
            trigger = [trigger.JuiceTime];
            [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS_paired_ModJuiceClk, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
            % zscore if we want to switch back N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero));
            N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
            counter = counter + 1;
        end
    end
end
N = N(~isnan(sum(N,2)),:);
if smooth(1) == 1
    N_j_ModJ.N = smoothdata(N, 2, 'sgolay', smooth(2));
else
    N_j_ModJ.N = N;
end
N_j_ModJ.edges = edges;
counterL = 1;
trials_c = 0;
list_trialsC = Rlist([Rlist.TrainBoo] == 1);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 'j'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
        [N_j_ModJ(counterL).LickHist_N, N_j_ModJ(counterL).LickHist_edges] = LickHist(trigger.', list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_j_ModJ(counterL).DeliveryHist_N, N_j_ModJ(counterL).DeliveryHist_edges] = LickHist(trigger.', list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
        [N_j_ModJ(counterL).RunMean, N_j_ModJ(counterL).RunEdges, ~] = RunSpeedHistLines(trigger.', list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_j_ModJ(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end

clear N
counter = 1;
for n = 1:length(CS_paired_NOmodJuiceClk)
    R = CS_paired_NOmodJuiceClk(n).RecorNum;
    if [Rlist(R).TrainBoo] == 1
        Trials = [Rlist(R).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 'j'));
        if ~isempty(trigger)
            trigger = [trigger.JuiceTime];
            [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS_paired_NOmodJuiceClk, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
            % zscore if we want to switch back N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)))/std(N(counter,1:Izero));
            N(counter, :) = (N(counter, :) - mean(N(counter,1:Izero)));
            counter = counter + 1;
        end
    end
end
N = N(~isnan(sum(N,2)),:);
if smooth(1) == 1
    N_j_NoModJ.N = smoothdata(N, 2, 'sgolay', smooth(2));
else
    N_j_NoModJ.N = N;
end
N_j_NoModJ.edges = edges;
counterL = 1;
trials_c = 0;
list_trialsC = Rlist([Rlist.TrainBoo] == 1);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 'j'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
        [N_j_NoModJ(counterL).LickHist_N, N_j_NoModJ(counterL).LickHist_edges] = LickHist(trigger.', list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_j_NoModJ(counterL).DeliveryHist_N, N_j_NoModJ(counterL).DeliveryHist_edges] = LickHist(trigger.', list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
        [N_j_NoModJ(counterL).RunMean, N_j_NoModJ(counterL).RunEdges, ~] = RunSpeedHistLines(trigger.', list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_j_NoModJ(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end

clear N
counter = 1;
for n = 1:length(CS_paired_NOmodJuiceClk)
    R = CS_paired_NOmodJuiceClk(n).RecorNum;
    if [Rlist(R).TrainBoo] == 1
        Trials = [Rlist(R).TrialStruct];
        trigger = Trials(strcmp({Trials.TrialType}, 'b'));
        if ~isempty(trigger)
            trigger = [trigger.JuiceTime];
            [N(counter,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger.', n, CS_paired_NOmodJuiceClk, bmin, bmax, binsize, [0 inf], 4, 'k', NaN, 0, 0);
            N(counter, :) = (N(counter, :) - mean(N(counter,1:Zzero)));
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
list_trialsC = Rlist([Rlist.TrainBoo] == 1);
for n = 1:length(list_trialsC)
    Trials = [list_trialsC(n).TrialStruct];
    trigger = Trials(strcmp({Trials.TrialType}, 'b'));
    trigger = trigger(strcmp({trigger.Outcome}, 'r'));
    if ~isempty(trigger)
        trigger = [trigger.JuiceTime];
        [N_b_NOmodJ(counterL).LickHist_N, N_b_NOmodJ(counterL).LickHist_edges] = LickHist(trigger.', list_trialsC(n).AllLicks, [-2 2], .1, 'k', 0);
        [N_b_NOmodJ(counterL).DeliveryHist_N, N_b_NOmodJ(counterL).DeliveryHist_edges] = LickHist(trigger.', list_trialsC(n).JuiceTimes, [-2 2], .1, 'k', 0);
        [N_b_NOmodJ(counterL).RunMean, N_b_NOmodJ(counterL).RunEdges, tester] = RunSpeedHistLines(trigger.', list_trialsC(n).RunningStruct.SpeedTimesAdj, list_trialsC(n).RunningStruct.SpeedValues, -2, 2);
        N_b_NOmodJ(counterL).trials_c = length(trigger);
        counterL = counterL + 1;
    end
end
allRTs = [];
ballRTs = [];
allTrialStruct = [];
list_trialsC = Rlist([Rlist.TrainBoo] == 1);
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
legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'}, 'Location', 'northoutside', 'FontSize', 8);
legend('boxoff')


figure
nexttile
hold on
shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_j_ModJ.N}.'), 1), nanstd(cell2mat({N_j_ModJ.N}.'), 0, 1)/sqrt(size(cell2mat({N_j_ModJ.N}.'), 1)), 'LineProp', {C(2,:)});
shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_j_NoModJ.N}.'), 1), nanstd(cell2mat({N_j_NoModJ.N}.'), 0, 1)/sqrt(size(cell2mat({N_j_NoModJ.N}.'), 1)), 'LineProp', {C(9,:)});
%xline(-.682, 'g', 'LineWidth', 1);
xline(0, 'c', 'LineWidth', 1);
xlim([-1 0.5])
% legend({['CS resp <' num2str(SDlow) ' SD']; ['CS resp >' num2str(SDhigh) ' SD']; 'reward'}, 'Location', 'northoutside', 'FontSize', 8);
% legend('boxoff')
ylim([-2 10]);
xlabel('time from rewarded solenoid (s)');
ylabel('Cspk/s')
FormatFigure(NaN, NaN)
% FigureWrap(NaN, 'Trained_Cspk_PAIRED_mod_notMod_juiceClk_j', NaN, NaN, NaN, NaN, 2.0, 2.0);

figure
nexttile
hold on
shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_b_NOmodJ.N}.'), 1), nanstd(cell2mat({N_b_NOmodJ.N}.'), 0, 1)/sqrt(size(cell2mat({N_b_NOmodJ.N}.'), 1)), 'LineProp', {C(9,:)});
shadedErrorBar2(edges(1:end-1), nanmean(cell2mat({N_b_ModJ.N}.'), 1), nanstd(cell2mat({N_b_ModJ.N}.'), 0, 1)/sqrt(size(cell2mat({N_b_ModJ.N}.'), 1)), 'LineProp', {C(2,:)});
xline(-.682, 'g', 'LineWidth', 1);
xline(0, 'c', 'LineWidth', 1);
xlim([-1 0.5])
% legend({['CS resp <' num2str(SDlow) ' SD']; ['CS resp >' num2str(SDhigh) ' SD']; 'reward'}, 'Location', 'northoutside', 'FontSize', 8);
% legend('boxoff')
ylim([-2 10]);
xlabel('time from rewarded solenoid (s)');
ylabel('Cspk/s')
% FigureWrap(NaN, 'Trained_Cspk_PAIRED_mod_notMod_juiceClk_b', NaN, NaN, NaN, NaN, 2.0, 2.0);

counterTotalTrained = 0;
counterTrainedResp = 0;
counterTrainedNoMod = 0;
for n = 1:length(CS_paired)
    R = CS_paired(n).RecorNum;
    if [Rlist(R).TrainBoo] == 1
        counterTotalTrained = counterTotalTrained + 1;
        if CS_paired(n).JuiceTimes_clkMod == 1
            counterTrainedResp = counterTrainedResp + 1;
        end
        if CS_paired(n).JuiceTimes_clkMod == 0
            counterTrainedNoMod = counterTrainedNoMod + 1;
        end
    end
end
total = counterTrainedNoMod + counterTrainedResp;
fprintf('%2.1f percent responsive Trained \n',  (100*counterTrainedResp/total))
figure
h = pie([counterTrainedResp/total counterTrainedNoMod/total], {'Resp. unexpected reward'; 'No resp. unexepected reward'});
patchHand = findobj(h, 'Type', 'Patch');
patchHand(1).FaceColor = C(2,:);
patchHand(2).FaceColor = C(9,:);
title('Trained')
% FigureWrap(NaN, 'Trained_Cspk_PAIRED_mod_notMod_juiceClk_Pie', NaN, NaN, NaN, NaN, 1.0, 1.0);


