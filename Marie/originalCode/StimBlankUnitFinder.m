function StimBlankUnit = StimBlankUnitFinder(unit, TimeGridA, TimeGridB, struct)
if TimeGridB(1) > TimeGridA(1) %double check that TimeGrids are formatted as usual

    TimeWindow = TimeGridA(2)-TimeGridB(1) % TimeGridB = stimtimes, TimeGridA = time before Stimtimes that is usuable
    
    unitIN = find([struct.unitID] == unit);        % find index for units of interest

    TS = [struct(unitIN).timestamps];    
    
for i = 1:length(TimeGridB)
    
    TGindex = find(TS > TimeGridB(i) & (TS<TimeGridB(i)+TimeWindow));
    TS(TGindex) = NaN;
end
end
StimBlankUnit = TS;
end