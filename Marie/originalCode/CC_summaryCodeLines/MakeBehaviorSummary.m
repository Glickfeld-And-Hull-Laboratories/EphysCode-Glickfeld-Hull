TrainingData(1).animal = 1694;
TrainingData(1).day0 = TrainingData_1694(1);
TrainingData(1).day1 = TrainingData_1694(2);
TrainingData(1).day2 = TrainingData_1694(3);
TrainingData(1).day3 = TrainingData_1694(4);
TrainingData(1).day4 = TrainingData_1694(5);
TrainingData(1).day5 = TrainingData_1694(6);
TrainingData(1).day6 = TrainingData_1694(7);
TrainingData(1).day7 = TrainingData_1694(8);
TrainingData(1).day8 = TrainingData_1694(9);
TrainingData(1).day9 = TrainingData_1694(10);
TrainingData(1).day10 = TrainingData_1694(11);
TrainingData(1).day11 = TrainingData_1694(12);
TrainingData(1).day12 = TrainingData_1694(13);
TrainingData(1).day13 = TrainingData_1694(14);
TrainingData(1).day14 = TrainingData_1694(15);
TrainingData(1).day15 = TrainingData_1694(16);
TrainingData(1).day16 = TrainingData_1694(17);
TrainingData(1).day17 = TrainingData_1694(18);

%g = mouse
%p = day/field
F1 = fieldnames(TrainingData);
for g = 1:length(TrainingData)
if ~isempty(TrainingData(g))
TempCell = struct2cell(TrainingData(g));
end
for p = 2:length(TempCell)
if ~isempty(TempCell{p})
TempTrialStruct = TempCell{p}.TrialStruct;
[TrainingData(g).(F1{p}).TrialStruct, ~] = RTtone(TempTrialStruct, TempCell{p}.AllLicks, .5);
TrainingData(g).(F1{p}).LickOnsets = FindLickOnsets([TempCell{p}.AllLicks], .5);
RTs = [TrainingData(g).(F1{p}).TrialStruct.RTt];
RTs(isinf(RTs) | isnan(RTs)) = [];
TrainingData(g).(F1{p}).meanRT = nanmean(RTs);
TrainingData(g).(F1{p}).sterrRT = std(RTs)/sqrt(length(RTs));
counterP = 1;
counterR = 1;
counterO = 1;
counterB = 1;
LickOnsetPred = [];
LickOnsetReact = [];
LickOnsetOutside =[];
LickOnsetBefore = [];
if sum(strcmp({TrainingData(g).(F1{p}).TrialStruct.TrialType}, 'b')) > 5
for n = 1:length(TrainingData(g).(F1{p}).LickOnsets)
for k = 1:length(TrainingData(g).(F1{p}).TrialStruct)
if strcmp({TrainingData(g).(F1{p}).TrialStruct(k).TrialType}, 'b')
if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone + .15)
if TrainingData(g).(F1{p}).LickOnsets(n) <= (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone + .68 +.15)
LickOnsetPred(counterP).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
LickOnsetPred(counterP).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone;
counterP = counterP + 1;
end
if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone + .68+.15)
if TrainingData(g).(F1{p}).LickOnsets(n) <= (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone + .88 + .68)
LickOnsetReact(counterR).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
LickOnsetReact(counterR).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone;
counterR = counterR +1;
end
end
if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone + .88 + .68)
if k < length(TrainingData(g).(F1{p}).TrialStruct)
if TrainingData(g).(F1{p}).LickOnsets(n) < (TrainingData(g).(F1{p}).TrialStruct(k+1).FictiveJuice - 1)
LickOnsetOutside(counterO).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
LickOnsetOutside(counterO).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone;
counterO = counterO +1;
end
end
end
end
if TrainingData(g).(F1{p}).LickOnsets(n) < (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone + .15)
if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone - 20)
LickOnsetBefore(counterB).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
LickOnsetBefore(counterB).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone;
counterB = counterB +1;
end
end
end
end
end
else %repeat all that for days without paired tone-reard
 
    for n = 1:length(TrainingData(g).(F1{p}).LickOnsets)
for k = 1:length(TrainingData(g).(F1{p}).TrialStruct)
%if strcmp({TrainingData(g).(F1{p}).TrialStruct(k).TrialType}, 'b')
if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone + .15)
if TrainingData(g).(F1{p}).LickOnsets(n) <= (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone + .68 +.15)
LickOnsetPred(counterP).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
LickOnsetPred(counterP).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone;
counterP = counterP + 1;
end
if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone + .68+.15)
if TrainingData(g).(F1{p}).LickOnsets(n) <= (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone + .88 + .68)
LickOnsetReact(counterR).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
LickOnsetReact(counterR).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone;
counterR = counterR +1;
end
end
if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone + .88 + .68)
if k < length(TrainingData(g).(F1{p}).TrialStruct)
if TrainingData(g).(F1{p}).LickOnsets(n) < (TrainingData(g).(F1{p}).TrialStruct(k+1).FictiveJuice - 1)
LickOnsetOutside(counterO).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
LickOnsetOutside(counterO).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone;
counterO = counterO +1;
end
end
end
end
if TrainingData(g).(F1{p}).LickOnsets(n) < (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone + .15)
if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone - 20)
LickOnsetBefore(counterB).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
LickOnsetBefore(counterB).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).FictiveTone;
counterB = counterB +1;
end
end
%end
end
end
    
end
Num_b_trials = length(TrainingData(g).(F1{p}).TrialStruct(strcmp({TrainingData(g).(F1{p}).TrialStruct.TrialType}, 'b')))
TrainingData(g).(F1{p}).LickOnsetPred = LickOnsetPred;
TrainingData(g).(F1{p}).LickOnsetReact = LickOnsetReact;
TrainingData(g).(F1{p}).LickOnsetOutside = LickOnsetOutside;
TrainingData(g).(F1{p}).LickOnsetBefore = LickOnsetBefore;
TrainingData(g).(F1{p}).PredPerc = length(LickOnsetPred)/Num_b_trials;
TrainingData(g).(F1{p}).ReactPerc = length(LickOnsetReact)/Num_b_trials;
TrainingData(g).(F1{p}).MissPerc = (Num_b_trials-length(LickOnsetPred)-length(LickOnsetReact))/Num_b_trials;
end
end
end



C = colororder;
F1 = fieldnames(TrainingData);
allRTs = cell(1,length(F1)-1);
ballRTs = cell(1,length(F1)-1);
counter_aRT = 1;
for g = 1:length(TrainingData)
counter_mRT = 1;
meanRT = [];
sterrRT = [];
for p = 2:length(F1)
if ~isempty(TrainingData(g).(F1{p}))
if p == 2
f = figure
end
meanRT(counter_mRT)= TrainingData(g).(F1{p}).meanRT;
sterrRT(counter_mRT) = TrainingData(g).(F1{p}).sterrRT;
PredPerc(counter_mRT) = TrainingData(g).(F1{p}).PredPerc;
ReactPerc(counter_mRT) = TrainingData(g).(F1{p}).ReactPerc;
MissPerc(counter_mRT) = TrainingData(g).(F1{p}).MissPerc;
counter_mRT = counter_mRT + 1;
RTs = [TrainingData(g).(F1{p}).TrialStruct.RTt];
%bRTs = RTs(strcmp({TrainingData(g).(F1{p}).TrialStruct.TrialType}, 'b') |
%strcmp({TrainingData(g).(F1{p}).TrialStruct.TrialType}, 'j')); %only RTts
%on 'b' or 'j' trials
bRTs = RTs(strcmp({TrainingData(g).(F1{p}).TrialStruct.TrialType}, 'b')); %only RTts on 'b' trials
RTs(isinf(RTs) | isnan(RTs)) = [];
bRTs(isinf(bRTs) | isnan(bRTs)) = [];
allRTs{:, p-1} = [allRTs{:, p-1}; RTs.'];
ballRTs{:, p-1} = [ballRTs{:, p-1}; bRTs.']; %both all RTs
nexttile % hist of lick times Naive
hold on
if ~isempty([TrainingData(g).(F1{p}).LickOnsetPred])
histogram ([TrainingData(g).(F1{p}).LickOnsetPred.TrialTime], [-1:.05:45], 'FaceAlpha', .5, 'FaceColor', C(1,:))
end
if ~isempty([TrainingData(g).(F1{p}).LickOnsetReact])
histogram ([TrainingData(g).(F1{p}).LickOnsetReact.TrialTime], [-1:.05:45], 'FaceAlpha', .5, 'FaceColor', C(2,:))
end
if ~isempty([TrainingData(g).(F1{p}).LickOnsetOutside]) | ~isempty([TrainingData(g).(F1{p}).LickOnsetBefore])
histogram ([[TrainingData(g).(F1{p}).LickOnsetOutside.TrialTime], [TrainingData(g).(F1{p}).LickOnsetBefore.TrialTime]] , [-1:.05:45], 'FaceAlpha', .5, 'FaceColor', C(3,:))
end
xline(0, 'g');
xline(.682, 'c');
xlim([-1 3])
title([TrainingData(g).(F1{1}) ' ' F1{p}]);
title([F1{p}]);
xlabel('time from cue (s)');
ylabel('n lick onsets');
FormatFigure(NaN, NaN);
if p == 2
legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'}, 'Location', 'westoutside')
legend('boxoff')
end
%FigureWrap('Naive Mice', 'Trained_LickingResp', 'time from cue', 'n reactions', NaN, NaN);
end
end
end
nexttile
hold on
plot([0:18], PredPerc);
plot([0:18], ReactPerc);
plot([0:18], MissPerc);
xlabel('day');
ylabel('liklihood of response type');
title('response type liklihood');
xlim([0 18]);
FormatFigure(NaN, NaN);
nexttile
allMeanRTs = cellfun(@mean, allRTs);
allStErrRTs = cellfun(@nanStErr, allRTs);
errorbar([0:18], allMeanRTs, allStErrRTs)
xlim([-1 19]);
yline(0, 'g');
FigureWrap(NaN, 'BehaviorSummary', NaN, NaN, NaN, NaN, 11, 16);


figure
ballMeanRTs = cellfun(@mean, ballRTs);
ballStErrRTs = cellfun(@nanStErr, ballRTs);
errorbar(ballMeanRTs, ballStErrRTs)
xlabel('day');
ylabel('mean reaction time');
title('mean reaction time');
yline(.68, 'c');
FormatFigure(NaN, NaN);
FigureWrap(NaN, 'RTsummary', NaN, NaN, NaN, NaN, 11, 16);
