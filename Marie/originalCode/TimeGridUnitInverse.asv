function TimeGridUnitINV = TimeGridUnitInverse(TimeGridC, TimeGridD, unit) %cexcludes timestamps between each C and D
TimeGridUnitINV = [];
for i = 1:length(TimeGridC)
    AddThis1 = unit(unit<TimeGridC(i));
    AddThis2 = AddThis1(AddThis1 > TimeGridD(i));
    TimeGridUnitINV = [TimeGridUnitINV; AddThis2];
end
end