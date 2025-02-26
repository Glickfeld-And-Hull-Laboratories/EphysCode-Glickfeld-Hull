function [SaneSpikes] = SaneSpikesC4(struct, TimeLim, TimeGridC, TimeGridD, unit)
%works with TS in samples not time and assumes sampling rate of 30000
%TimeGridC and D exclude spikes between C(n) and D(n).
TimeLim = TimeLim * 30000;
TimeGridC = TimeGridC * 30000;
TimeGridD = TimeGridD * 30000;

index = find([struct.unitID] == unit);
timestamps = [struct(index).timestamps];

SaneSpikes = ones(length(timestamps),1);

SaneSpikes(timestamps > TimeLim(2)) = 0; %make insane timestamps outside the limits
SaneSpikes(timestamps < TimeLim(1)) = 0;


for i = 1:length(TimeGridD) %make insane timestamps between C(n) and D(c)
    SaneSpikes(timestamps < TimeGridD(i) & timestamps > TimeGridC(i)) = 0;
end
SaneSpikes = [timestamps SaneSpikes];
end