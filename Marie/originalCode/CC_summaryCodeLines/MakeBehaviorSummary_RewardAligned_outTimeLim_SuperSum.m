%run CreateTrainingDataSum

%g = mouse
%p = day/field
F1 = fieldnames(TrainingDataSum);
for g = 1:length(TrainingDataSum)
if ~isempty(TrainingDataSum(g))
TempCell = struct2cell(TrainingDataSum(g));
end
for p = 2:length(TempCell)
if ~isempty(TempCell{p})
    if ~isempty(TempCell{p}.TrialStruct_clk)
TempTrialStruct = TempCell{p}.TrialStruct_clk;
    else
        TempTrialStruct = TempCell{p}.TrialStruct_sil;
    end
if ~isempty(TempTrialStruct)
[TrainingDataSum(g).(F1{p}).TrialStruct, ~] = RTjuice(TempTrialStruct, TempCell{p}.AllLicks, .5);
TrainingDataSum(g).(F1{p}).LickOnsets = FindLickOnsets([TempCell{p}.AllLicks], .5);
RTs = [TrainingDataSum(g).(F1{p}).TrialStruct.RTj];
RTs(isinf(RTs) | isnan(RTs)) = [];
TrainingDataSum(g).(F1{p}).meanRT = nanmean(RTs);
TrainingDataSum(g).(F1{p}).sterrRT = std(RTs)/sqrt(length(RTs));
counterP = 1;
counterR = 1;
counterO = 1;
counterB = 1;
counterE = 1;
LickOnsetPred = [];
LickOnsetReact = [];
LickOnsetOutside =[];
LickOnsetBefore = [];
LickOnsetEmpty = [];
if sum(strcmp({TrainingDataSum(g).(F1{p}).TrialStruct.TrialType}, 'b')) > 5
for n = 1:length(TrainingDataSum(g).(F1{p}).LickOnsets)
for k = 1:length(TrainingDataSum(g).(F1{p}).TrialStruct)
if strcmp({TrainingDataSum(g).(F1{p}).TrialStruct(k).TrialType}, 'b')
if TrainingDataSum(g).(F1{p}).LickOnsets(n) > (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone + .15)
if TrainingDataSum(g).(F1{p}).LickOnsets(n) <= (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone + .68 +.15)
LickOnsetPred(counterP).RecordTime = TrainingDataSum(g).(F1{p}).LickOnsets(n);
LickOnsetPred(counterP).TrialTime = TrainingDataSum(g).(F1{p}).LickOnsets(n)- TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice;
TrainingDataSum(g).(F1{p}).TrialStruct(k).TrialOutcome = 'p';
counterP = counterP + 1;
end
if TrainingDataSum(g).(F1{p}).LickOnsets(n) > (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone + .68+.15)
if TrainingDataSum(g).(F1{p}).LickOnsets(n) <= (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone + .88 + .68)
LickOnsetReact(counterR).RecordTime = TrainingDataSum(g).(F1{p}).LickOnsets(n);
LickOnsetReact(counterR).TrialTime = TrainingDataSum(g).(F1{p}).LickOnsets(n)- TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice;
TrainingDataSum(g).(F1{p}).TrialStruct(k).TrialOutcome = 'r';
counterR = counterR +1;
end
end
if TrainingDataSum(g).(F1{p}).LickOnsets(n) > (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone + .88 + .68)
if k < length(TrainingDataSum(g).(F1{p}).TrialStruct)
if TrainingDataSum(g).(F1{p}).LickOnsets(n) < (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice + 5) 
LickOnsetOutside(counterO).RecordTime = TrainingDataSum(g).(F1{p}).LickOnsets(n);
LickOnsetOutside(counterO).TrialTime = TrainingDataSum(g).(F1{p}).LickOnsets(n)- TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice;
TrainingDataSum(g).(F1{p}).TrialStruct(k).TrialOutcome = 'o';
counterO = counterO +1;
end
% non-rewarded licks that occur before next trial-check that some lick has
% occured between reward and this lick 
if TrainingDataSum(g).(F1{p}).LickOnsets(n) < (TrainingDataSum(g).(F1{p}).TrialStruct(k+1).FictiveTone) & TrainingDataSum(g).(F1{p}).LickOnsets(n) < (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice + 20)
if ~isempty(TrainingDataSum(g).(F1{p}).LickOnsets(1:n-1) > TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice)
LickOnsetEmpty(counterE).RecordTime = TrainingDataSum(g).(F1{p}).LickOnsets(n);
LickOnsetEmpty(counterE).TrialTime = TrainingDataSum(g).(F1{p}).LickOnsets(n)- TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice;
counterE = counterE + 1;
end
end
end
end
end
if TrainingDataSum(g).(F1{p}).LickOnsets(n) < (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone + .15)
if TrainingDataSum(g).(F1{p}).LickOnsets(n) > (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone - 20)
LickOnsetBefore(counterB).RecordTime = TrainingDataSum(g).(F1{p}).LickOnsets(n);
LickOnsetBefore(counterB).TrialTime = TrainingDataSum(g).(F1{p}).LickOnsets(n)- TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice;
TrainingDataSum(g).(F1{p}).TrialStruct(k).TrialOutcome = 'b';
counterB = counterB +1;
end
end
end
end
end
else %repeat all that for days without paired tone-reard
    if ~isempty(TempCell{p}.TrialStruct_clk)
 TempTrialStruct = TempCell{p}.TrialStruct_clk;
    else
    TempTrialStruct = TempCell{p}.TrialStruct_sil;
    end
[TrainingDataSum(g).(F1{p}).TrialStruct, ~] = RTjuice(TempTrialStruct, TempCell{p}.AllLicks, .5);
TrainingDataSum(g).(F1{p}).LickOnsets = FindLickOnsets([TempCell{p}.AllLicks], .5);
RTs = [TrainingDataSum(g).(F1{p}).TrialStruct.RTj];
RTs(isinf(RTs) | isnan(RTs)) = [];
TrainingDataSum(g).(F1{p}).meanRT = nanmean(RTs);
TrainingDataSum(g).(F1{p}).sterrRT = std(RTs)/sqrt(length(RTs));
    for n = 1:length(TrainingDataSum(g).(F1{p}).LickOnsets)
for k = 1:length(TrainingDataSum(g).(F1{p}).TrialStruct)
%if strcmp({TrainingDataSum(g).(F1{p}).TrialStruct(k).TrialType}, 'b')
if TrainingDataSum(g).(F1{p}).LickOnsets(n) > (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone + .15)
if TrainingDataSum(g).(F1{p}).LickOnsets(n) <= (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone + .68 +.15)
LickOnsetPred(counterP).RecordTime = TrainingDataSum(g).(F1{p}).LickOnsets(n);
LickOnsetPred(counterP).TrialTime = TrainingDataSum(g).(F1{p}).LickOnsets(n)- TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice;
TrainingDataSum(g).(F1{p}).TrialStruct(k).TrialOutcome = 'p';
counterP = counterP + 1;
end
if TrainingDataSum(g).(F1{p}).LickOnsets(n) > (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone + .68+.15)
if TrainingDataSum(g).(F1{p}).LickOnsets(n) <= (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone + .88 + .68)
LickOnsetReact(counterR).RecordTime = TrainingDataSum(g).(F1{p}).LickOnsets(n);
LickOnsetReact(counterR).TrialTime = TrainingDataSum(g).(F1{p}).LickOnsets(n)- TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice;
TrainingDataSum(g).(F1{p}).TrialStruct(k).TrialOutcome = 'r';
counterR = counterR +1;
end
end
if TrainingDataSum(g).(F1{p}).LickOnsets(n) > (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone + .88 + .68)
if k < length(TrainingDataSum(g).(F1{p}).TrialStruct)
if TrainingDataSum(g).(F1{p}).LickOnsets(n) < (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice + 5) 
LickOnsetOutside(counterO).RecordTime = TrainingDataSum(g).(F1{p}).LickOnsets(n);
LickOnsetOutside(counterO).TrialTime = TrainingDataSum(g).(F1{p}).LickOnsets(n)- TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice;
TrainingDataSum(g).(F1{p}).TrialStruct(k).TrialOutcome = 'o';
counterO = counterO +1;
end
% non-rewarded licks that occur before next trial-check that some lick has
% occured between reward and this lick
if (TrainingDataSum(g).(F1{p}).LickOnsets(n) < (TrainingDataSum(g).(F1{p}).TrialStruct(k+1).FictiveJuice) & TrainingDataSum(g).(F1{p}).LickOnsets(n) < (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice + 20) )
if ~isempty(TrainingDataSum(g).(F1{p}).LickOnsets(1:n-1) > TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice)
LickOnsetEmpty(counterE).RecordTime = TrainingDataSum(g).(F1{p}).LickOnsets(n);
LickOnsetEmpty(counterE).TrialTime = TrainingDataSum(g).(F1{p}).LickOnsets(n)- TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice;
counterE = counterE + 1;
end
end
end
end
end
if TrainingDataSum(g).(F1{p}).LickOnsets(n) < (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone + .15)
if TrainingDataSum(g).(F1{p}).LickOnsets(n) > (TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveTone - 20)
LickOnsetBefore(counterB).RecordTime = TrainingDataSum(g).(F1{p}).LickOnsets(n);
LickOnsetBefore(counterB).TrialTime = TrainingDataSum(g).(F1{p}).LickOnsets(n)- TrainingDataSum(g).(F1{p}).TrialStruct(k).FictiveJuice;
TrainingDataSum(g).(F1{p}).TrialStruct(k).TrialOutcome = 'b';
counterB = counterB +1;
end
end
%end
end
end
    
end
Num_b_trials = length(TrainingDataSum(g).(F1{p}).TrialStruct(strcmp({TrainingDataSum(g).(F1{p}).TrialStruct.TrialType}, 'b')))
TrainingDataSum(g).(F1{p}).LickOnsetPred = LickOnsetPred;
TrainingDataSum(g).(F1{p}).LickOnsetReact = LickOnsetReact;
TrainingDataSum(g).(F1{p}).LickOnsetOutside = LickOnsetOutside;
TrainingDataSum(g).(F1{p}).LickOnsetBefore = LickOnsetBefore;
TrainingDataSum(g).(F1{p}).LickOnsetEmpty = LickOnsetEmpty;
% RecordingList(p-1).LickOnsetPred = LickOnsetPred;
% RecordingList(p-1).LickOnsetReact = LickOnsetReact;
% RecordingList(p-1).LickOnsetOutside = LickOnsetOutside;
% RecordingList(p-1).LickOnsetBefore = LickOnsetBefore;
% RecordingList(p-1).LickOnsetEmpty = LickOnsetEmpty;
% RecordingList(p-1).TrialStructOutcomes = TrainingDataSum(g).(F1{p}).TrialStruct;
TrainingDataSum(g).(F1{p}).PredPerc = length(LickOnsetPred)/Num_b_trials;
TrainingDataSum(g).(F1{p}).ReactPerc = length(LickOnsetReact)/Num_b_trials;
TrainingDataSum(g).(F1{p}).MissPerc = (Num_b_trials-length(LickOnsetPred)-length(LickOnsetReact))/Num_b_trials;
end
end
end
end

%this code works, but switched over to BehaviorOutcomesCell.m for more
%functionality.
clear BehavOutcomesStruct
F1 = fieldnames(TrainingDataSum);
numMice = length(TrainingDataSum);
for p = 2:length(F1)
          BehavOutcomesStruct(p).day = p-1; %this is not ideal coding! check.
BehavOutcomesStruct(p).LickOnsetPred = [];
BehavOutcomesStruct(p).LickOnsetReact = [];
BehavOutcomesStruct(p).LickOnsetOutside = [];
BehavOutcomesStruct(p).LickOnsetBefore = [];
BehavOutcomesStruct(p).LickOnsetEmpty = [];
for n = 1:numMice
    if ~(isempty(TrainingDataSum(n).(F1{p})))

BehavOutcomesStruct(p).LickOnsetPred = [[BehavOutcomesStruct(p).LickOnsetPred]; [TrainingDataSum(n).(F1{p}).LickOnsetPred.TrialTime].'];
BehavOutcomesStruct(p).LickOnsetReact = [[BehavOutcomesStruct(p).LickOnsetReact]; [TrainingDataSum(n).(F1{p}).LickOnsetReact.TrialTime].'];
BehavOutcomesStruct(p).LickOnsetOutside = [[BehavOutcomesStruct(p).LickOnsetOutside]; [TrainingDataSum(n).(F1{p}).LickOnsetOutside.TrialTime].'];
BehavOutcomesStruct(p).LickOnsetBefore = [[BehavOutcomesStruct(p).LickOnsetBefore]; [TrainingDataSum(n).(F1{p}).LickOnsetBefore.TrialTime].'];
BehavOutcomesStruct(p).LickOnsetEmpty = [[BehavOutcomesStruct(p).LickOnsetEmpty]; [TrainingDataSum(n).(F1{p}).LickOnsetEmpty.TrialTime].'];
    end
    end
end



% 
% 
% figure
% hold on
% if ~isempty([TrainingDataSum(g).(F1{p}).LickOnsetPred])
% histogram ([TrainingDataSum(g).(F1{p}).LickOnsetPred.TrialTime], [-1.5:.05:45], 'FaceAlpha', .5, 'FaceColor', C(1,:))
% end
% if ~isempty([TrainingDataSum(g).(F1{p}).LickOnsetReact])
% histogram ([TrainingDataSum(g).(F1{p}).LickOnsetReact.TrialTime], [-1.5:.05:45], 'FaceAlpha', .5, 'FaceColor', C(2,:))
% end
% if ~isempty([TrainingDataSum(g).(F1{p}).LickOnsetOutside]) | ~isempty([TrainingDataSum(g).(F1{p}).LickOnsetBefore])
% histogram ([[TrainingDataSum(g).(F1{p}).LickOnsetOutside.TrialTime], [TrainingDataSum(g).(F1{p}).LickOnsetBefore.TrialTime]] , [-1:.05:45], 'FaceAlpha', .5, 'FaceColor', C(3,:))
% end
% if p > 3
% xline(-.682, 'g', 'LineWidth', 1);
% end
% xline(0, 'c', 'LineWidth', 1);
% xlim([-1.5 2.5])
% title([TrainingDataSum(g).(F1{1}) ' ' F1{p}]);
% title([F1{p}]);
% xlabel('time from cue (s)');
% ylabel('n lick onsets');
% FormatFigure(NaN, NaN);
% if p == 2
% legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'})
% legend('boxoff')
% end
% %FigureWrap(NaN, ['behavior day ' F1{p}], NaN, NaN, NaN, NaN, 1.5, 2);
% end
% end
% end
% nexttile
% hold on
% plot([0:length(PredPerc)-1], PredPerc);
% plot([0:length(PredPerc)-1], ReactPerc);
% plot([0:length(PredPerc)-1], MissPerc);
% xticklabels({RecordingList.day})
% xlabel('day');
% ylabel('liklihood of response type');
% title('response type liklihood');
% xlim([0 length(PredPerc)-1]);
% FormatFigure(NaN, NaN)
% nexttile
% allMeanRTs = cellfun(@mean, allRTs);
% allStErrRTs = cellfun(@nanStErr, allRTs);
% errorbar([0:length(PredPerc)-1], allMeanRTs, allStErrRTs)
% xlim([-1 19]);
% ylim([-.3 2]);
% yline(0, 'c');
% xticklabels({RecordingList.day})
% xlabel('day');
% ylabel('reaction time from reward');
% FormatFigure(NaN, NaN);
% 
% nexttile
% ballMeanRTs = cellfun(@mean, ballRTs);
% ballStErrRTs = cellfun(@nanStErr, ballRTs);
% errorbar(ballMeanRTs, ballStErrRTs)
% xlabel('day');
% ylabel('mean reaction time');
% title('mean reaction time');
% yline(0, 'c');
% xlim([-1 19]);
% ylim([-.3 2]);
% xlabel('day');
% ylabel('reaction time from reward after cue');
% %FigureWrap(NaN, 'BehaviorSummary_reward', NaN, NaN, NaN, NaN, 11, 16);
% 
% 
% figure
% ballMeanRTs = cellfun(@mean, ballRTs);
% ballStErrRTs = cellfun(@nanStErr, ballRTs);
% errorbar(ballMeanRTs, ballStErrRTs)
% xlabel('day');
% ylabel('mean reaction time');
% title('mean reaction time');
% yline(0, 'c');
% xlim([-1 19]);
% xlabel('day');
% xticklabels({RecordingList.day})
% ylabel('reaction time from reward after cue');
% FormatFigure(NaN, NaN);
% %FigureWrap(NaN, 'RTsummary_reward', NaN, NaN, NaN, NaN, 11, 16);
% 
% 
% 
% %old code
% % 
% % 
% % C = colororder;
% % F1 = fieldnames(TrainingDataSum);
% % allRTs = cell(1,length(F1)-1);
% % ballRTs = cell(1,length(F1)-1);
% % counter_aRT = 1;
% % for g = 1:length(TrainingDataSum)
% % counter_mRT = 1;
% % meanRT = [];
% % sterrRT = [];
% % for p = 2:length(F1)
% % if ~isempty(TrainingDataSum(g).(F1{p}))
% % if p == 2
% % f = figure
% % end
% % meanRT(counter_mRT)= TrainingDataSum(g).(F1{p}).meanRT;
% % sterrRT(counter_mRT) = TrainingDataSum(g).(F1{p}).sterrRT;
% % PredPerc(counter_mRT) = TrainingDataSum(g).(F1{p}).PredPerc;
% % ReactPerc(counter_mRT) = TrainingDataSum(g).(F1{p}).ReactPerc;
% % MissPerc(counter_mRT) = TrainingDataSum(g).(F1{p}).MissPerc;
% % counter_mRT = counter_mRT + 1;
% % RTs = [TrainingDataSum(g).(F1{p}).TrialStruct.RTj];
% % %bRTs = RTs(strcmp({TrainingDataSum(g).(F1{p}).TrialStruct.TrialType}, 'b') |
% % %strcmp({TrainingDataSum(g).(F1{p}).TrialStruct.TrialType}, 'j')); %only RTts
% % %on 'b' or 'j' trials
% % bRTs = RTs(strcmp({TrainingDataSum(g).(F1{p}).TrialStruct.TrialType}, 'b')); %only RTjs on 'b' trials
% % RTs(isinf(RTs) | isnan(RTs)) = [];
% % bRTs(isinf(bRTs) | isnan(bRTs)) = [];
% % allRTs{:, p-1} = [allRTs{:, p-1}; RTs.'];
% % ballRTs{:, p-1} = [ballRTs{:, p-1}; bRTs.']; %both all RTs
% % nexttile % hist of lick times Naive
% % figure
% % hold on
% % if ~isempty([TrainingDataSum(g).(F1{p}).LickOnsetPred])
% % histogram ([TrainingDataSum(g).(F1{p}).LickOnsetPred.TrialTime], [-1.5:.05:45], 'FaceAlpha', .5, 'FaceColor', C(1,:))
% % end
% % if ~isempty([TrainingDataSum(g).(F1{p}).LickOnsetReact])
% % histogram ([TrainingDataSum(g).(F1{p}).LickOnsetReact.TrialTime], [-1.5:.05:45], 'FaceAlpha', .5, 'FaceColor', C(2,:))
% % end
% % if ~isempty([TrainingDataSum(g).(F1{p}).LickOnsetOutside]) | ~isempty([TrainingDataSum(g).(F1{p}).LickOnsetBefore])
% % histogram ([[TrainingDataSum(g).(F1{p}).LickOnsetOutside.TrialTime], [TrainingDataSum(g).(F1{p}).LickOnsetBefore.TrialTime]] , [-1:.05:45], 'FaceAlpha', .5, 'FaceColor', C(3,:))
% % end
% % if p > 3
% % xline(-.682, 'g', 'LineWidth', 1);
% % end
% % xline(0, 'c', 'LineWidth', 1);
% % xlim([-1.5 2.5])
% % title([TrainingDataSum(g).(F1{1}) ' ' F1{p}]);
% % title([F1{p}]);
% % xlabel('time from cue (s)');
% % ylabel('n lick onsets');
% % FormatFigure(NaN, NaN);
% % if p == 2
% % legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'})
% % legend('boxoff')
% % end
% % %FigureWrap(NaN, ['behavior day ' F1{p}], NaN, NaN, NaN, NaN, 1.5, 2);
% % end
% % end
% % end
% % nexttile
% % hold on
% % plot([0:length(PredPerc)-1], PredPerc);
% % plot([0:length(PredPerc)-1], ReactPerc);
% % plot([0:length(PredPerc)-1], MissPerc);
% % xticklabels({RecordingList.day})
% % xlabel('day');
% % ylabel('liklihood of response type');
% % title('response type liklihood');
% % xlim([0 length(PredPerc)-1]);
% % FormatFigure(NaN, NaN)
% % nexttile
% % allMeanRTs = cellfun(@mean, allRTs);
% % allStErrRTs = cellfun(@nanStErr, allRTs);
% % errorbar([0:length(PredPerc)-1], allMeanRTs, allStErrRTs)
% % xlim([-1 19]);
% % ylim([-.3 2]);
% % yline(0, 'c');
% % xticklabels({RecordingList.day})
% % xlabel('day');
% % ylabel('reaction time from reward');
% % FormatFigure(NaN, NaN);
% % 
% % nexttile
% % ballMeanRTs = cellfun(@mean, ballRTs);
% % ballStErrRTs = cellfun(@nanStErr, ballRTs);
% % errorbar(ballMeanRTs, ballStErrRTs)
% % xlabel('day');
% % ylabel('mean reaction time');
% % title('mean reaction time');
% % yline(0, 'c');
% % xlim([-1 19]);
% % ylim([-.3 2]);
% % xlabel('day');
% % ylabel('reaction time from reward after cue');
% % %FigureWrap(NaN, 'BehaviorSummary_reward', NaN, NaN, NaN, NaN, 11, 16);
% % 
% % 
% % figure
% % ballMeanRTs = cellfun(@mean, ballRTs);
% % ballStErrRTs = cellfun(@nanStErr, ballRTs);
% % errorbar(ballMeanRTs, ballStErrRTs)
% % xlabel('day');
% % ylabel('mean reaction time');
% % title('mean reaction time');
% % yline(0, 'c');
% % xlim([-1 19]);
% % xlabel('day');
% % xticklabels({RecordingList.day})
% % ylabel('reaction time from reward after cue');
% % FormatFigure(NaN, NaN);
% % %FigureWrap(NaN, 'RTsummary_reward', NaN, NaN, NaN, NaN, 11, 16);
% 
