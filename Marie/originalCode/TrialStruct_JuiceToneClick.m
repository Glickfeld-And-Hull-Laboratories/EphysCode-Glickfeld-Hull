function [TrialStruct, AllEvents, LastEvents] = TrialStruct_JuiceToneClick(JuiceTimes_sil, JuiceTimes_clk, NoJuice_clk, ToneTimes)
%reworked this on 240813 to remake RecordingList in CC data with more flags
%to work with more easily and remake prediction, reaction, outside trials.


% [TrialStruct, JuiceAlone_click, ToneAlone, Juice_clickAfterTone, ToneBeforeJuice_click, FictiveJuice]
% code:
% 0 = JuiceTimesSil;
% 1 = JuiceTimesClick;
% 2 = ToneTimes;
% 3 = NoJuice_clk;
J_sEvents = [];
J_cEvents = [];
ToneTimesEvents = [];
NoJuice_clkEvents = [];
for n = 1:length(JuiceTimes_sil)
    J_sEvents(n,1).time = JuiceTimes_sil(n,1);
    J_sEvents(n,1).event = 0;
end
for n = 1:length(JuiceTimes_clk)
    J_cEvents(n,1).time = JuiceTimes_clk(n,1);
    J_cEvents(n,1).event = 1;
end
for n = 1:length(ToneTimes)
    ToneTimesEvents(n,1).time = ToneTimes(n,1);
    ToneTimesEvents(n,1).event = 2;
end
for n = 1:length(NoJuice_clk)
    NoJuice_clkEvents(n,1).time = NoJuice_clk(n,1);
    NoJuice_clkEvents(n,1).event = 3;
end
AllEvents = [];
if ~isempty(J_sEvents)
    AllEvents = [AllEvents; J_sEvents];
end
if ~isempty(J_cEvents)
    AllEvents = [AllEvents; J_cEvents];
end
if ~isempty(ToneTimesEvents)
    AllEvents = [AllEvents; ToneTimesEvents];
end
if ~isempty(NoJuice_clkEvents)
    AllEvents = [AllEvents; NoJuice_clkEvents];
end

AllEvents = SortStruct(AllEvents, 'time', 'ascend');
if AllEvents(1).time == AllEvents(2).time   %deal with occaisional double first entry
    AllEvents = AllEvents(2:end);
end
TimeDiff = [diff([AllEvents.time].'); inf];
LastEvents = [TimeDiff > 3];

TrialStruct = struct('TrialType', [], 'ToneTime', [], 'JuiceTime', [], 'JuiceClk', [], 'EmptyClick', [], 'FictiveJuice', [], 'FictiveTone', []);
tcounter = 1;
for n = 1:length(LastEvents)
    if LastEvents(n) == 1
        k = find(LastEvents(1:n), 2, 'last');
        if length(k) >1
        n = k(1) + 1;
        k = k(end);
        thisTrialEvents = AllEvents(n:k);
    else
         thisTrialEvents = AllEvents(1:k);
    end
        [~, Locb] = ismember(2, [thisTrialEvents.event]);
        if Locb > 0
            TrialStruct(tcounter,1).ToneTime = [thisTrialEvents(Locb).time];
        end
        [~, Locb] = ismember(0, [thisTrialEvents.event]);
        if Locb > 0
            TrialStruct(tcounter,1).JuiceTime = [thisTrialEvents(Locb).time];
            TrialStruct(tcounter,1).JuiceClk = 0;
        end
        [~, Locb] = ismember(1, [thisTrialEvents.event]);
        if Locb > 0
            TrialStruct(tcounter,1).JuiceTime = [thisTrialEvents(Locb).time];
            TrialStruct(tcounter,1).JuiceClk = 1;
        end
        [~, Locb] = ismember(3, [thisTrialEvents.event]);
        if Locb > 0
            TrialStruct(tcounter,1).EmptyClick = [thisTrialEvents(Locb).time];
        end
        % should be a new thing by now
        if isempty(TrialStruct(tcounter,1).JuiceClk)
            TrialStruct(tcounter,1).JuiceClk = NaN;
        end
        if isempty(TrialStruct(tcounter,1).ToneTime)
            TrialStruct(tcounter,1).ToneTime = NaN;
        end
        if isempty(TrialStruct(tcounter,1).JuiceTime)
            TrialStruct(tcounter,1).JuiceTime = NaN;
        end
        if isempty(TrialStruct(tcounter,1).EmptyClick)
            TrialStruct(tcounter,1).EmptyClick = NaN;
        end
        tcounter = tcounter + 1;
    end
end

% TrialTypes:
% b = both clikc
% b_s = both silent
% t = tone alone
% j = juice click
% j_s = juice silent
% eCl = click without juice
% t_eCl = tone with empty click
for n = 1:length(TrialStruct)
    if (TrialStruct(n).JuiceClk == 1 & ~isnan(TrialStruct(n).ToneTime))
        TrialStruct(n).TrialType = 'b';
    end
    if (TrialStruct(n).JuiceClk == 0 & ~isnan(TrialStruct(n).ToneTime))
        TrialStruct(n).TrialType = 'b_s';
    end
    if (isnan(TrialStruct(n).JuiceClk) & ~isnan(TrialStruct(n).ToneTime))
        TrialStruct(n).TrialType = 't';
    end
    if (TrialStruct(n).JuiceClk == 1 & isnan(TrialStruct(n).ToneTime))
        TrialStruct(n).TrialType = 'j';
    end
    if (TrialStruct(n).JuiceClk == 0 & isnan(TrialStruct(n).ToneTime))
        TrialStruct(n).TrialType = 'j_s';
    end
    if (~isnan(TrialStruct(n).EmptyClick) & ~isnan(TrialStruct(n).ToneTime))
        TrialStruct(n).TrialType = 't_eCl';
    end
    if (~isnan(TrialStruct(n).EmptyClick) & isnan(TrialStruct(n).ToneTime))
        TrialStruct(n).TrialType = 'eCl';
    end
end

PairedStruct = TrialStruct(strcmp({TrialStruct.TrialType}, 'b') | strcmp({TrialStruct.TrialType}, 'b_s'));
if isempty(PairedStruct)
    delay = .681;
end
if ~isempty(PairedStruct)
    delay = median([PairedStruct.JuiceTime] - [PairedStruct.ToneTime]);
end

for n = 1:length(TrialStruct)
    if ~isnan(TrialStruct(n).ToneTime)
        TrialStruct(n).FictiveTone = TrialStruct(n).ToneTime;
    else
        TrialStruct(n).FictiveTone = TrialStruct(n).JuiceTime - delay;
    end
    if ~isnan(TrialStruct(n).JuiceTime)
        TrialStruct(n).FictiveJuice = TrialStruct(n).JuiceTime;
    else
        TrialStruct(n).FictiveJuice = TrialStruct(n).ToneTime + delay;
    end
    if ~isnan(TrialStruct(n).EmptyClick)
        TrialStruct(n).FictiveJuice = TrialStruct(n).EmptyClick;
        if ~isnan(TrialStruct(n).ToneTime)
            TrialStruct(n).FictiveTone = TrialStruct(n).ToneTime;
        else
            TrialStruct(n).FictiveTone = TrialStruct(n).EmptyClick - delay;
        end
    end
end

% TrialTypes:
% b = both clikc
% b_s = both silent
% t = tone alone
% j = juice click
% j_s = juice silent
% c_n = click without juice

