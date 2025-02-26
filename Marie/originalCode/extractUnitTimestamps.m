function timestamps = extractUnitTimestamps(UnivStruct, unit)


    unitIN = find([UnivStruct.unitID] == unit);
    %eval(strUnit '=GoodUnitStruct(x).timestamps');
    timestamps =  UnivStruct(unitIN).timestamps;
end
    