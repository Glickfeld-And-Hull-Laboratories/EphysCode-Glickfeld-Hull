function channel = ChannelFind (unit, struct)

unitIN = find([struct.unitID] == unit);
channel = struct(unitIN).channel;
end