% this version adds & to if statment line 35 so if trial is predictive so
% it will not also be reactive
% Rlist contains fields loc, mous, day, AllLicks, ToneTimes, JuiceTimes,
% JuiceTimes_clk, RunningStruct, NoJuiceClk, and TrialStruct. TrialStruct
% has been calculated from included metrics with
%[TrialStruct, AllEvents, FirstEvents] = TrialStruct_JuiceToneClick(Rlist(n).JuiceTimes_sil, Rlist(n).JuiceTimes_clk, Rlist(n).NoJuiceClk, Rlist(n).ToneTimes);
% minReactTime = .15 240822
function [Rlist] = OutcomesAndOtherMetrics(Rlist, minReactTime)
maxReactTime = minReactTime + .68;
for R = 1:length(Rlist)
    TempTrialStruct = Rlist(R).TrialStruct;
    TempAllLicks = [Rlist(R).AllLicks];
    [TempTrialStruct, ~] = RTjuice_incl(TempTrialStruct, TempAllLicks, .5, 6);
    Rlist(R).LickOnsets = FindLickOnsets(TempAllLicks, .5);
    RTs = [TempTrialStruct.RTj];
    RTs(isinf(RTs) | isnan(RTs)) = [];
    Rlist(R).meanRT = nanmean(RTs);
    Rlist(R).sterrRT = std(RTs)/sqrt(length(RTs));
    TempTrialStruct(1).Outcome = [];
    for n = 1:length(TempTrialStruct)
        if (TempTrialStruct(n).RTj > (-.68 + minReactTime) & TempTrialStruct(n).RTj < (minReactTime))
            TempTrialStruct(n).Outcome = 'p';
        else
            if TempTrialStruct(n).RTj >= minReactTime & TempTrialStruct(n).RTj < maxReactTime
                TempTrialStruct(n).Outcome = 'r';
            else
                if TempTrialStruct(n).RTj > maxReactTime
                    TempTrialStruct(n).Outcome = 'o';
                else
                    if TempTrialStruct(n).RTj < (-.68 + minReactTime)
                        TempTrialStruct(n).Outcome = 'b';
                    end
                end
            end
        end
        if isempty(TempTrialStruct(n).Outcome)
            TempTrialStruct(n).Outcome = NaN;
        end
    end
    Rlist(R).TrialStruct = TempTrialStruct;
    
    clear LickOnsetStruct
    for n = 1:length(Rlist(R).LickOnsets)
        LickOnsetStruct(n).time = Rlist(R).LickOnsets(n);
        %         LickOnsetStruct(n).time = Rlist(R).LickOnsets(n).time;
        juice = [Rlist(R).JuiceTimes];
        priorJuice = juice(find(juice <= [LickOnsetStruct(n).time], 1, 'last')); %find time of last juice before lickOnset
        fictiveJuice = [Rlist(R).TrialStruct.FictiveJuice];
        priorFictiveJuice = fictiveJuice(find(fictiveJuice <= LickOnsetStruct(n).time, 1, 'last')); %find time of last Fictive juice before lickOnset
        tone = [Rlist(R).ToneTimes];
        priorTone = tone(find(tone <= LickOnsetStruct(n).time, 1, 'last')); %find time of last tone before lickOnset
        nextTone = tone(find(tone > LickOnsetStruct(n).time, 1, 'first')); %find time of next tone after lickOnset
        nextJuice = juice(find(juice > LickOnsetStruct(n).time, 1, 'first')); %find time of next juice after lickOnset
        nextEvent = min([nextTone nextJuice]);
        if ~logical(size(priorTone, 2)) %solve a bug that comes if zero Tone trials for the following check
            priorTone = double.empty(0,1);
        end
        if (isempty(find([Rlist(R).TrialStruct.FictiveTone] == priorTone))) & (isempty(find([Rlist(R).TrialStruct.JuiceTime] == priorJuice))) %is this trial represented in the Trial Struct? If not, fill in with NaNs
            LickOnsetStruct(n).RewardBoo = NaN;
            LickOnsetStruct(n).RTj = NaN;
            LickOnsetStruct(n).TrialType = NaN;
            LickOnsetStruct(n).timeToNextEvent = NaN;
            LickOnsetStruct(n).Outcome = NaN;
            continue
        end
        if ~isempty(priorJuice) %skip trials before any juice delivery
            if isempty(priorTone)
                ToneThisTrial = 0;
            else if (priorTone - priorJuice < 2 & priorTone - priorJuice > 0 )|  priorTone > priorJuice        %determine if the lick onset is following a prior tone or a prior juice most recently
                    ToneThisTrial = 1;
                else
                    ToneThisTrial = 0;
                end
            end
            check = TempAllLicks((TempAllLicks >= priorJuice) & (TempAllLicks < LickOnsetStruct(n).time));
            if isempty(check)
                LickOnsetStruct(n).RewardBoo = 1;
            else
                LickOnsetStruct(n).RewardBoo = 0;
            end
            if ToneThisTrial == 1
                trialI = find([Rlist(R).TrialStruct.ToneTime] == priorTone);
            else
                trialI = find([Rlist(R).TrialStruct.JuiceTime] == priorJuice);
            end
            if ~isempty(trialI) %in case, for example, it is a juice trial that was omitted from TrialStruct but there was a previous tone trial that made it past the check above, then this will go below and get NaNs.
                LickOnsetStruct(n).TrialType = Rlist(R).TrialStruct(trialI).TrialType;
                LickOnsetStruct(n).RTj = LickOnsetStruct(n).time - Rlist(R).TrialStruct(trialI).FictiveJuice;
                LickOnsetStruct(n).Outcome = Rlist(R).TrialStruct(trialI).Outcome;
                if trialI < length(Rlist(R).TrialStruct)
                    LickOnsetStruct(n).timeToNextEvent = nextEvent - LickOnsetStruct(n).time;
                else
                    LickOnsetStruct(n).timeToNextEvent = inf;
                end
                if LickOnsetStruct(n).RTj > 6
                    LickOnsetStruct(n).Outcome = 'o';
                end
            else
                LickOnsetStruct(n).RewardBoo = NaN;
                LickOnsetStruct(n).RTj = NaN;
                LickOnsetStruct(n).TrialType = NaN;
                LickOnsetStruct(n).timeToNextEvent = NaN;
                LickOnsetStruct(n).Outcome = NaN;
            end
        else
            LickOnsetStruct(n).RewardBoo = 0;
            LickOnsetStruct(n).RTj = NaN;
            LickOnsetStruct(n).TrialType = NaN;
            LickOnsetStruct(n).timeToNextEvent = NaN;
            LickOnsetStruct(n).Outcome = NaN;
        end
    end
    Rlist(R).LickOnsets = LickOnsetStruct;
    
    
    Num_potP_trials = length(TempTrialStruct(strcmp({TempTrialStruct.TrialType}, 'b') | strcmp({TempTrialStruct.TrialType}, 'b_s') | strcmp({TempTrialStruct.TrialType}, 't') | strcmp({TempTrialStruct.TrialType}, 't_eCl')))
    PotP_trials = TempTrialStruct((strcmp({TempTrialStruct.TrialType}, 'b') | strcmp({TempTrialStruct.TrialType}, 'b_s') | strcmp({TempTrialStruct.TrialType}, 't') | strcmp({TempTrialStruct.TrialType}, 't_eCl')));
    Num_all_trials = length(TempTrialStruct);
    JuiceOnly_trials = TempTrialStruct((strcmp({TempTrialStruct.TrialType}, 'j')));
    Num_juiceOnly_trials = length(JuiceOnly_trials);
    Rlist(R).PredPerc_potP = length(PotP_trials(strcmp({PotP_trials.Outcome}, 'p')))/Num_potP_trials;
    Rlist(R).ReactPerc_potP = length(PotP_trials(strcmp({PotP_trials.Outcome}, 'r')))/Num_potP_trials;
    Rlist(R).MissPerc_potP = length(PotP_trials(strcmp({PotP_trials.Outcome}, 'o')))/Num_potP_trials;
    Rlist(R).PredPerc_all = length(TempTrialStruct(strcmp({TempTrialStruct.Outcome}, 'p')))/Num_all_trials;
    Rlist(R).ReactPerc_all = length(TempTrialStruct(strcmp({TempTrialStruct.Outcome}, 'r')))/Num_all_trials;
    Rlist(R).MissPerc_all = length(TempTrialStruct(strcmp({TempTrialStruct.Outcome}, 'o')))/Num_all_trials;
    Rlist(R).PredPerc_juiceOnly = length(JuiceOnly_trials(strcmp({JuiceOnly_trials.Outcome}, 'p')))/Num_all_trials;
    Rlist(R).ReactPerc_juiceOnly = length(JuiceOnly_trials(strcmp({JuiceOnly_trials.Outcome}, 'r')))/Num_all_trials;
    Rlist(R).MissPerc_juiceOnly = length(JuiceOnly_trials(strcmp({JuiceOnly_trials.Outcome}, 'o')))/Num_all_trials;
    jRTs = [JuiceOnly_trials.RTj];
    jRTs(isinf(jRTs) | isnan(jRTs)) = [];
    Rlist(R).JuiceOnlymeanRT = nanmean(jRTs);
    Rlist(R).JuiceOnlysterrRT = std(jRTs)/sqrt(length(jRTs));
    
    Rlist(R).LickOnsets = LickOnsetStruct;
    
    
end
end


