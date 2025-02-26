function MakeLongTrace (Struct, channel, units, timeWindow, colors)
%channel = channel to extract
%units = list of units to highlight
%timeWindow = time limits to extract between, i.e. [2.0, 3.0]
%colors = vector the same size as units, with a unique color for each unit
figure
hold on

   
[TraceData, reporter] = LongTraceRead_fixedChan(timeWindow, units(1,1), Struct, channel);


%for n = 1:length(indices)
%     UnitTimestamps(n).unitID = AllUnitStruct(indices(n,1)).unitID;
%     UnitTimestamps(n).timestamps = AllUnitStruct(indices(n,1)).timestamps;
%if n ==1
%[TraceData] = LongTraceRead(timeWindow, UnitTimestamps(1).timestamps, channel);
%end
 for n = 1:length(units)
     %unitIN = find([Struct.unitID] == units(n,1));
AddUnitToTrace_fixedChan(timeWindow, Struct, units(n,1), channel, colors(n,1:3));
end
for m = 1:length(units)
dim = [(.1+ m*.05) .8 .2 .2];
unitstr = num2str(units(m,1));

annotation('textbox', dim, 'String', unitstr, 'color', colors(m,1:3), 'FitBoxToText','on');
end

end
