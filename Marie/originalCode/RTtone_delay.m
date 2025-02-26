function [TrialStructRTt, TrialStructSortedt] = RTtone_delay(TrialStruct, AllLicks, threshold, Lim, delay)
%threshold is time before lick that must not have licks to be considered a response. 
%juiceDelay = .68; %time between juice and tone in seconds
TimeLim = Lim; %maximum RT in sec
if isempty(TrialStruct)
TrialStruct(1).RTt = [];
    TrialStructRTt = [];
    TrialStructSortedt = [];
else
for i =1:length(TrialStruct)
    if ~strcmp(TrialStruct(i).TrialType, 'j')
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
    elseif strcmp(TrialStruct(i).TrialType, 'j')
        LicksAfterJuice = AllLicks(AllLicks > (TrialStruct(i).JuiceTime - delay));
        TrialStruct(i).FictiveTone = TrialStruct(i).JuiceTime -delay;
        if ~isempty(LicksAfterJuice)
            priorlick = AllLicks(find(AllLicks < LicksAfterJuice(1), 1, 'last'));
            if (LicksAfterJuice(1)-(TrialStruct(i).JuiceTime) < TimeLim)
                
                if LicksAfterJuice(1)- priorlick >= threshold
                    TrialStruct(i).RTt = LicksAfterJuice(1)-(TrialStruct(i).FictiveTone);
                    TrialStruct(i).RTt_realTime = LicksAfterJuice(1);
                else
                    TrialStruct(i).RTt = NaN;
                    TrialStruct(i).RTt_realTime = NaN;
                end
            else
                TrialStruct(i).RTt = inf;
                TrialStruct(i).RTt_realTime = NaN;
            end
        else
            TrialStruct(i).RTt = inf;
            TrialStruct(i).RTt_realTime = NaN;
        end
    end
end

TrialStructRTt = TrialStruct;
TrialStructSortedt = SortStructAscend(TrialStruct, 'RTt');
end
%TrialStructSortedt = TrialStruct;
end





