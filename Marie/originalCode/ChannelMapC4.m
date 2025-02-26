function [channelmap] = ChannelMapC4(struct, unit, rez)

index = find([struct.unitID] == unit); %% n changes to index in struct pointing to specified unit
unitchan = struct(index).channel;
chanindex = unitchan + 1; %from channel (0-based) to matlab index(1-based)
channelmap = zeros(41,3);

for n = 1:41 %hard-coded for 200 microns, 20 channels around the main channel
    delta = n - 20;
    if (((unitchan + delta) > 1) && ((unitchan + delta) < length([rez.ycoord])))
channelmap(n,1) = unitchan + delta;
channelmap(n,2) = rez(chanindex + delta).xcoord - rez(chanindex).xcoord;
channelmap(n,3) = rez(chanindex + delta).ycoord - rez(chanindex).ycoord;
    end
end