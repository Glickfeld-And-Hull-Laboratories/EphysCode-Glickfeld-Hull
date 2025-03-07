function ISIstruct = PlotISIs(TimeGridA, TimeGridB, struct, UnitList, ISItimeLim, TimeLim, binwidth, color)

for j = 1:length(UnitList)
ISIstruct(j).unitID = UnitList(j);
[medianISI meanISI N edges] = ISIstructTimeGridTimeLim(TimeGridA, TimeGridB, struct, UnitList(j), ISItimeLim, TimeLim, binwidth, color);
ISIstruct(j).medianISI = medianISI;
ISIstruct(j).meanISI = meanISI;
ISIstruct(j).N = N;
ISIstruct(j).edges = edges;

end 
figure
hold on
for k = 1:length(UnitList)
    plot(ISIstruct(k).edges, ISIstruct(k).N, 'color', [0 0 0], 'LineWidth', .0002 );
end
end