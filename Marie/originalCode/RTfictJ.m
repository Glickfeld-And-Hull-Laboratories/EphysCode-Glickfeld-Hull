function [TrialStructRTt, TrialStructSortedt] = RTfictJ(TrialStruct, AllLicks)

%juiceDelay = .68; %time between juice and tone in seconds
TimeLim = 6; %maximum RT in sec
TrialStruct(1).RTt = [];

for i =1:length(TrialStruct)
  
        LicksAfterTone = AllLicks(AllLicks > TrialStruct(i).FictiveJuice);
        if ~isempty(LicksAfterTone)
        if (LicksAfterTone(1)-TrialStruct(i).FictiveJuice < TimeLim)
            TrialStruct(i).RTt = LicksAfterTone(1)-TrialStruct(i).FictiveJuice;
        else
              TrialStruct(i).RTt = NaN;  
        end
        else
              TrialStruct(i).RTt = NaN;  
        end
   elseif strcmp(TrialStruct(i).TrialType, 'j')
       TrialStruct(i).RTt = NaN;
   end
end
TrialStructRTt = TrialStruct;
TrialStructSortedt = SortStructAscend(TrialStruct, 'RTt');
end