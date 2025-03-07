function AllLicksLatencies = MakeAllLicksLatencies(JuiceLicks)
AllLicks= [];
for i = 1:length(JuiceLicks(:,1))
    AllLicks = [AllLicks, (JuiceLicks{i, 2}-JuiceLicks{i,1})];
end
AllLicksLatencies = AllLicks.';
end