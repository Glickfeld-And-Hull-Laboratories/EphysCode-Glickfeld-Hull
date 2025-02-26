TrainingDataSum(1).animal = 1695;
rLcounter = 1; % change this when using RecordingList with more animals

TrainingDataSum(1).day1.AllLicks = RecordingList(rLcounter).AllLicks;
TrainingDataSum(1).day1.TrialStruct = RecordingList(rLcounter).TrialStruct;
TrainingDataSum(1).day1.TrialStruct_clk = RecordingList(rLcounter).TrialStruct_clk;
TrainingDataSum(1).day1.JuiceTimes_sil = RecordingList(rLcounter).JuiceTimes_sil;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day2.AllLicks = RecordingList(rLcounter).AllLicks;
TrainingDataSum(1).day2.TrialStruct = RecordingList(rLcounter).TrialStruct;
TrainingDataSum(1).day2.TrialStruct_clk = RecordingList(rLcounter).TrialStruct_clk;
TrainingDataSum(1).day2.JuiceTimes_sil = RecordingList(rLcounter).JuiceTimes_sil;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day3.AllLicks = RecordingList(rLcounter).AllLicks;
TrainingDataSum(1).day3.TrialStruct = RecordingList(rLcounter).TrialStruct;
TrainingDataSum(1).day3.TrialStruct_clk = RecordingList(rLcounter).TrialStruct_clk;
TrainingDataSum(1).day3.JuiceTimes_sil = RecordingList(rLcounter).JuiceTimes_sil;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day6.AllLicks = RecordingList(rLcounter).AllLicks;
TrainingDataSum(1).day6.TrialStruct = RecordingList(rLcounter).TrialStruct;
TrainingDataSum(1).day6.TrialStruct_clk = RecordingList(rLcounter).TrialStruct_clk;
TrainingDataSum(1).day6.JuiceTimes_sil = RecordingList(rLcounter).JuiceTimes_sil;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day7.AllLicks = RecordingList(rLcounter).AllLicks;
TrainingDataSum(1).day7.TrialStruct = RecordingList(rLcounter).TrialStruct;
TrainingDataSum(1).day7.TrialStruct_clk = RecordingList(rLcounter).TrialStruct_clk;
TrainingDataSum(1).day7.JuiceTimes_sil = RecordingList(rLcounter).JuiceTimes_sil;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day8.AllLicks = RecordingList(rLcounter).AllLicks;
TrainingDataSum(1).day8.TrialStruct = RecordingList(rLcounter).TrialStruct;
TrainingDataSum(1).day8.TrialStruct_clk = RecordingList(rLcounter).TrialStruct_clk;
TrainingDataSum(1).day8.JuiceTimes_sil = RecordingList(rLcounter).JuiceTimes_sil;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day11.AllLicks = RecordingList(rLcounter).AllLicks;
TrainingDataSum(1).day11.TrialStruct = RecordingList(rLcounter).TrialStruct;
TrainingDataSum(1).day11.TrialStruct_clk = RecordingList(rLcounter).TrialStruct_clk;
TrainingDataSum(1).day11.JuiceTimes_sil = RecordingList(rLcounter).JuiceTimes_sil;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day12.AllLicks = RecordingList(rLcounter).AllLicks;
TrainingDataSum(1).day12.TrialStruct = RecordingList(rLcounter).TrialStruct;
TrainingDataSum(1).day12.TrialStruct_clk = RecordingList(rLcounter).TrialStruct_clk;
TrainingDataSum(1).day12.JuiceTimes_sil = RecordingList(rLcounter).JuiceTimes_sil;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day13.AllLicks = RecordingList(rLcounter).AllLicks;
TrainingDataSum(1).day13.TrialStruct = RecordingList(rLcounter).TrialStruct;
TrainingDataSum(1).day13.TrialStruct_clk = RecordingList(rLcounter).TrialStruct_clk;
TrainingDataSum(1).day13.JuiceTimes_sil = RecordingList(rLcounter).JuiceTimes_sil;
rLcounter = rLcounter + 1;

TrainingDataSum(1).day14.AllLicks = RecordingList(rLcounter).AllLicks;
TrainingDataSum(1).day14.TrialStruct = RecordingList(rLcounter).TrialStruct;
TrainingDataSum(1).day14.TrialStruct_clk = RecordingList(rLcounter).TrialStruct_clk;
TrainingDataSum(1).day14.JuiceTimes_sil = RecordingList(rLcounter).JuiceTimes_sil;
rLcounter = rLcounter + 1;

%g = mouse
%p = day/field
F1 = fieldnames(TrainingDataSum);
for g = 1:length(TrainingDataSum)
if ~isempty(TrainingDataSum(g))
TempCell = struct2cell(TrainingDataSum(g));
end
for p = 2:length(TempCell)
if ~isempty(TempCell{p})
TempTrialStruct = TempCell{p}.TrialStruct;
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
elseif  ~isempty([TempCell{p}.TrialStruct_clk])   %repeat all that for days without paired tone-reward, just clik
 TempTrialStruct = TempCell{p}.TrialStruct_clk;
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
   
else % if day has neither tone-reward pair or audible reward, but only silent reward   
 [TempTrialStruct, ~, ~, ~, ~, ~] = JuiceToneCreateTrialSt(TempCell{p}.JuiceTimes_sil, []);
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
TraintinDataSum(g).(F1{p}).LickOnsetEmpty = LickOnsetEmpty;
RecordingList(p-1).LickOnsetPred = LickOnsetPred;
RecordingList(p-1).LickOnsetReact = LickOnsetReact;
RecordingList(p-1).LickOnsetOutside = LickOnsetOutside;
RecordingList(p-1).LickOnsetBefore = LickOnsetBefore;
RecordingList(p-1).LickOnsetEmpty = LickOnsetEmpty;
RecordingList(p-1).TrialStructOutcomes = TrainingDataSum(g).(F1{p}).TrialStruct;
TrainingDataSum(g).(F1{p}).PredPerc = length(LickOnsetPred)/Num_b_trials;
TrainingDataSum(g).(F1{p}).ReactPerc = length(LickOnsetReact)/Num_b_trials;
TrainingDataSum(g).(F1{p}).MissPerc = (Num_b_trials-length(LickOnsetPred)-length(LickOnsetReact))/Num_b_trials;
end
end
end



C = colororder;
F1 = fieldnames(TrainingDataSum);
allRTs = cell(1,length(F1)-1);
ballRTs = cell(1,length(F1)-1);
counter_aRT = 1;
for g = 1:length(TrainingDataSum)
counter_mRT = 1;
meanRT = [];
sterrRT = [];
for p = 2:length(F1)
if ~isempty(TrainingDataSum(g).(F1{p}))
if p == 2
f = figure
end
meanRT(counter_mRT)= TrainingDataSum(g).(F1{p}).meanRT;
sterrRT(counter_mRT) = TrainingDataSum(g).(F1{p}).sterrRT;
PredPerc(counter_mRT) = TrainingDataSum(g).(F1{p}).PredPerc;
ReactPerc(counter_mRT) = TrainingDataSum(g).(F1{p}).ReactPerc;
MissPerc(counter_mRT) = TrainingDataSum(g).(F1{p}).MissPerc;
counter_mRT = counter_mRT + 1;
RTs = [TrainingDataSum(g).(F1{p}).TrialStruct.RTj];
%bRTs = RTs(strcmp({TrainingDataSum(g).(F1{p}).TrialStruct.TrialType}, 'b') |
%strcmp({TrainingDataSum(g).(F1{p}).TrialStruct.TrialType}, 'j')); %only RTts
%on 'b' or 'j' trials
bRTs = RTs(strcmp({TrainingDataSum(g).(F1{p}).TrialStruct.TrialType}, 'b')); %only RTjs on 'b' trials
RTs(isinf(RTs) | isnan(RTs)) = [];
bRTs(isinf(bRTs) | isnan(bRTs)) = [];
allRTs{:, p-1} = [allRTs{:, p-1}; RTs.'];
ballRTs{:, p-1} = [ballRTs{:, p-1}; bRTs.']; %both all RTs
nexttile % hist of lick times Naive
figure
hold on
if ~isempty([TrainingDataSum(g).(F1{p}).LickOnsetPred])
histogram ([TrainingDataSum(g).(F1{p}).LickOnsetPred.TrialTime], [-1.5:.05:45], 'FaceAlpha', .5, 'FaceColor', C(1,:))
end
if ~isempty([TrainingDataSum(g).(F1{p}).LickOnsetReact])
histogram ([TrainingDataSum(g).(F1{p}).LickOnsetReact.TrialTime], [-1.5:.05:45], 'FaceAlpha', .5, 'FaceColor', C(2,:))
end
if ~isempty([TrainingDataSum(g).(F1{p}).LickOnsetOutside]) | ~isempty([TrainingDataSum(g).(F1{p}).LickOnsetBefore])
histogram ([[TrainingDataSum(g).(F1{p}).LickOnsetOutside.TrialTime], [TrainingDataSum(g).(F1{p}).LickOnsetBefore.TrialTime]] , [-1:.05:45], 'FaceAlpha', .5, 'FaceColor', C(3,:))
end
if p > 3
xline(-.682, 'g', 'LineWidth', 1);
end
xline(0, 'c', 'LineWidth', 1);
xlim([-1.5 2.5])
title([TrainingDataSum(g).(F1{1}) ' ' F1{p}]);
title([F1{p}]);
xlabel('time from cue (s)');
ylabel('n lick onsets');
FormatFigure(NaN, NaN);
if p == 2
legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'})
legend('boxoff')
end
FigureWrap(NaN, ['behavior day ' F1{p}], NaN, NaN, NaN, NaN, 1.5, 2);
end
end
end
nexttile
hold on
plot([0:length(PredPerc)-1], PredPerc);
plot([0:length(PredPerc)-1], ReactPerc);
plot([0:length(PredPerc)-1], MissPerc);
xticklabels({RecordingList.day})
xlabel('day');
ylabel('liklihood of response type');
title('response type liklihood');
xlim([0 length(PredPerc)-1]);
FormatFigure(NaN, NaN)
nexttile
allMeanRTs = cellfun(@mean, allRTs);
allStErrRTs = cellfun(@nanStErr, allRTs);
errorbar([0:length(PredPerc)-1], allMeanRTs, allStErrRTs)
xlim([-1 19]);
ylim([-.3 2]);
yline(0, 'c');
xticklabels({RecordingList.day})
xlabel('day');
ylabel('reaction time from reward');
FormatFigure(NaN, NaN);

nexttile
ballMeanRTs = cellfun(@mean, ballRTs);
ballStErrRTs = cellfun(@nanStErr, ballRTs);
errorbar(ballMeanRTs, ballStErrRTs)
xlabel('day');
ylabel('mean reaction time');
title('mean reaction time');
yline(0, 'c');
xlim([-1 19]);
ylim([-.3 2]);
xlabel('day');
ylabel('reaction time from reward after cue');
FigureWrap(NaN, 'BehaviorSummary_reward', NaN, NaN, NaN, NaN, 11, 16);


figure
ballMeanRTs = cellfun(@mean, ballRTs);
ballStErrRTs = cellfun(@nanStErr, ballRTs);
errorbar(ballMeanRTs, ballStErrRTs)
xlabel('day');
ylabel('mean reaction time');
title('mean reaction time');
yline(0, 'c');
xlim([-1 19]);
xlabel('day');
xticklabels({RecordingList.day})
ylabel('reaction time from reward after cue');
FormatFigure(NaN, NaN);
FigureWrap(NaN, 'RTsummary_reward', NaN, NaN, NaN, NaN, 11, 16);
