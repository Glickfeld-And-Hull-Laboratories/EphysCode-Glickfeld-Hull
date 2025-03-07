function [AllLicks, AllDurs] = MakeAllLicks(JuiceLicks)
AllLicks= [];
AllDurs = [];
for i = 1:length(JuiceLicks(:,1))
    AllLicks = [AllLicks, JuiceLicks{i, 2}];
    AllDurs = [AllDurs, JuiceLicks{i, 3}]; %lick durations
end
AllLicks = AllLicks.';
AllDurs = AllDurs.';
end