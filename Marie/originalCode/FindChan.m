function channel = FindChan(unit, struct)
unitIN = find([struct.unitID] == unit);
channel = struct(unitIN).channel
end
