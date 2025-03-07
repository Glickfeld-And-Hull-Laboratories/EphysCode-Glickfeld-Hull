function [TrialStructRTt] = RTboth(TrialStruct, AllLicks, threshold, limit)
%threshold is time before lick that must not have licks to be considered a response. 
%juiceDelay = .68; %time between juice and tone in seconds
TimeLim = limit; %maximum RT in sec
if isempty(TrialStruct)
TrialStruct(1).RTt = [];
    TrialStructRTt = [];
    TrialStructSortedt = [];
else
TrialStruct = TrialStruct(strcmp({TrialStruct.TrialType}, 'b'));
for i =1:length(TrialStruct)
        LicksAfterTone = AllLicks(AllLicks > TrialStruct(i).ToneTime);
        TrialStruct(i).FictiveTone = TrialStruct(i).ToneTime;
        if ~isempty(LicksAfterTone)
           priorlick = AllLicks(find(AllLicks < LicksAfterTone(1), 1, 'last'));
            if (LicksAfterTone(1)-TrialStruct(i).ToneTime < TimeLim)
                %priorlick = find(AllLicks < LicksAfterTone(1), 1, 'last');
                if LicksAfterTone(1) - priorlick >= threshold
                    TrialStruct(i).RTt = LicksAfterTone(1)-TrialStruct(i).ToneTime;
                else
                    TrialStruct(i).RTt = NaN;
                end
            else
                TrialStruct(i).RTt = inf;
            end
        else
            TrialStruct(i).RTt = inf;
        end

TrialStructRTt = TrialStruct;
% TrialStructRTt = TrialStruct(strcmp({TrialStruct.TrialType}, 'b'));
%TrialStructSortedt = SortStructAscend(TrialStruct, 'RTt');
end
%TrialStructSortedt = TrialStruct;
end
