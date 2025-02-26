function TimeGridUnit = TimeGridUnit(TimeGridA, TimeGridB, unit) %chooses only timestamps between each TGA and TGB

TimeGridUnit = [];
for i = 1:length(TimeGridB)

    AddThis1 = unit(unit<TimeGridB(i));
    AddThis2 = AddThis1(AddThis1 > TimeGridA(i));
    TimeGridUnit = [TimeGridUnit; AddThis2];
end
end