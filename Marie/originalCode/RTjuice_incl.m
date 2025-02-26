function [TrialStructRTj, TrialStructSortedj] = RTjuice_incl(TrialStruct, AllLicks, threshold, TimeLim, juiceDelay)
%threshold is time before lick that must not have licks to be considered a response. 
%this code considers that negative RT might be response to tone, so
%threshold is actually considered from FictiveJuices - .68;
%juiceDelay = .682; %time between juice and tone in seconds
%this version calculates all trials, including 't'
 %TimeLim = maximum RT in sec
 
TrialStruct(1).RTj = [];
for i =1:length(TrialStruct)
        LicksAfterJuice = AllLicks(AllLicks > TrialStruct(i).FictiveJuice - 1); % licks after tone that may or may not have come before possible juice delivery
        if ~isempty(LicksAfterJuice)
           priorlick = AllLicks(find(AllLicks < LicksAfterJuice(1), 1, 'last'));
            if (LicksAfterJuice(1) - (TrialStruct(i).FictiveJuice - juiceDelay) < TimeLim)
                if LicksAfterJuice(1) - priorlick >= threshold
                    TrialStruct(i).RTj = LicksAfterJuice(1)-TrialStruct(i).FictiveJuice;
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
TrialStructRTj = TrialStruct;
TrialStructSortedj = SortStructAscend(TrialStruct, 'RTj');
%TrialStructSortedt = TrialStruct;
end





