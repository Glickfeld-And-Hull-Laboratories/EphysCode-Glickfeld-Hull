function [FirstJuiceLicks, FirstJuiceEpochs] = ExtractFirstJuice3(TrialStruct, AllLicks)

%juiceDelay = .68; %time between juice and tone in seconds
EpochOnset = FindLickingEpochs(AllLicks, 1, .21);

c = 1;
for i =2:length(TrialStruct)-1
   if ~strcmp(TrialStruct(i).TrialType, 't')
        LicksAfterJuice = AllLicks(AllLicks > TrialStruct(i).FictiveJuice);
        LicksBetweenJuice = LicksAfterJuice(LicksAfterJuice < TrialStruct(i+1).FictiveJuice);
        if ~isempty(LicksBetweenJuice)
            FirstJuiceLicks(c,1) = LicksBetweenJuice(1);
            c = c + 1;
        end
    end
end


c = 1;
for i =2:length(TrialStruct)-1
   if ~strcmp(TrialStruct(i).TrialType, 't')
        EpochsAfterJuice = EpochOnset(EpochOnset > TrialStruct(i).FictiveJuice);
        EpochsBetweenJuice = EpochsAfterJuice(EpochsAfterJuice < TrialStruct(i+1).FictiveJuice);
        if ~isempty(EpochsBetweenJuice)
            FirstJuiceEpochs(c,1) = EpochsBetweenJuice(1);
            c = c + 1;
        end
    end
end
end

    
   

