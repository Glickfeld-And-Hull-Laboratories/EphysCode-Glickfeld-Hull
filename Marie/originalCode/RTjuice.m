function [TrialStructRTj, TrialStructSortedj] = RTjuice(TrialStruct, AllLicks, threshold)
%threshold is time before lick that must not have licks to be considered a response. 
%this code considers that negative RT might be response to tone, so
%threshold is actually considered from JuiceTimes - .68;
%juiceDelay = .68; %time between juice and tone in seconds
TimeLim = 6; %maximum RT in sec
TrialStruct(1).RTj = [];

for i =1:length(TrialStruct)
    if ~strcmp(TrialStruct(i).TrialType, 't')
        LicksAfterJuice = AllLicks(AllLicks > TrialStruct(i).JuiceTime - .682); % licks after tone that may or may not have come before juice delivery
        TrialStruct(i).FictiveJuice = TrialStruct(i).JuiceTime;
        TrialStruct(i).FictiveTone = TrialStruct(i).JuiceTime - .682;
        if ~isempty(LicksAfterJuice)
           priorlick = AllLicks(find(AllLicks < LicksAfterJuice(1), 1, 'last'));
            if (LicksAfterJuice(1) - (TrialStruct(i).JuiceTime - .682) < TimeLim)
                if LicksAfterJuice(1) - priorlick >= threshold
                    TrialStruct(i).RTj = LicksAfterJuice(1)-TrialStruct(i).JuiceTime;
                    TrialStruct(i).RTj_realTime = LicksAfterJuice(1);
                else
                    TrialStruct(i).RTj = NaN;
                    TrialStruct(i).RTj_realTime = NaN;
                end
            else
                TrialStruct(i).RTj = inf;
                TrialStruct(i).RTj_realTime = NaN;
            end
        else
            TrialStruct(i).RTj = inf;
            TrialStruct(i).RTj_realTime = NaN;
        end
    elseif strcmp(TrialStruct(i).TrialType, 't')
        LicksAfterJuice = AllLicks(AllLicks > (TrialStruct(i).ToneTime));
        TrialStruct(i).FictiveJuice = TrialStruct(i).ToneTime + .682;
        TrialStruct(i).FictiveTone = TrialStruct(i).ToneTime;
        if ~isempty(LicksAfterJuice)
            priorlick = AllLicks(find(AllLicks < LicksAfterJuice(1), 1, 'last'));
            if (LicksAfterJuice(1) - (TrialStruct(i).ToneTime) < TimeLim)
                
                if LicksAfterJuice(1)- priorlick >= threshold
                    TrialStruct(i).RTj = LicksAfterJuice(1)-(TrialStruct(i).FictiveJuice);
                    TrialStruct(i).RTj_realTime = LicksAfterJuice(1);
                else
                    TrialStruct(i).RTj = NaN;
                    TrialStruct(i).RTj_realTime = NaN;
                end
            else
                TrialStruct(i).RTj = inf;
                TrialStruct(i).RTj_realTime = NaN;
            end
        else
            TrialStruct(i).RTj = inf;
            TrialStruct(i).RTj_realTime = NaN;
        end
    end
end

TrialStructRTj = TrialStruct;
TrialStructSortedj = SortStructAscend(TrialStruct, 'RTj');
%TrialStructSortedt = TrialStruct;
end





