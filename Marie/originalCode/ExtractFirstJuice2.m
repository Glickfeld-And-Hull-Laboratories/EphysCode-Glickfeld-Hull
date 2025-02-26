function [FirstJuiceLicks, FirstJuiceEpochs] = ExtractFirstJuice2(TrialLicks)

%juiceDelay = .68; %time between juice and tone in seconds
AllLicks = MakeAllLicks(TrialLicks);
EpochOnset = FindLickingEpochs(AllLicks);

c = 1;
for i =2:length(TrialLicks)-1
   if ~strcmp(TrialLicks{i, 3}, 'ToneAlone')
        LicksAfterJuice = AllLicks(AllLicks > TrialLicks{i,1});
        LicksBetweenJuice = LicksAfterJuice(LicksAfterJuice < TrialLicks{i+1,1});
        if ~isempty(LicksBetweenJuice)
            FirstJuiceLicks(c,1) = LicksBetweenJuice(1);
            c = c + 1;
        end
    end
end


c = 1;
for i =2:length(TrialLicks)-1
   if ~strcmp(TrialLicks{i, 3}, 'ToneAlone')
        EpochsAfterJuice = EpochOnset(EpochOnset > TrialLicks{i,1});
        EpochsBetweenJuice = EpochsAfterJuice(EpochsAfterJuice < TrialLicks{i+1,1});
        if ~isempty(EpochsBetweenJuice)
            FirstJuiceEpochs(c,1) = EpochsBetweenJuice(1);
            c = c + 1;
        end
    end
end
end

    
   

