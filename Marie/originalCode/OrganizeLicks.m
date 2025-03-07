function[JuiceLickOrganize]= OrganizeLicks(JuiceTimes, LicksList)
prejuice = 5; %hard-code in pre-juice period that you want associated with the juice
for n = 1:(length(JuiceTimes)-1)
    trialLicks = LicksList(LicksList > (JuiceTimes(n)-prejuice));
    trialLicks = trialLicks(trialLicks < (JuiceTimes(n+1)-prejuice));
    JuiceLickOrganize{n,1} = JuiceTimes(n);
    if ~isempty(trialLicks)
    JuiceLickOrganize{n,2}= trialLicks.';
    else
        JuiceLickOrganize{n,2}= NaN;
    end
    JuiceLickOrganize{n+1,1}= JuiceTimes(n+1);
    JuiceLickOrganize{n+1,2}=NaN;
end
size(JuiceLickOrganize)
plotSpikeRaster(JuiceLickOrganize.', 'PlotType', 'vertline'); % create the raster plot using a function someone else wrote.
xline(0,'b');
end