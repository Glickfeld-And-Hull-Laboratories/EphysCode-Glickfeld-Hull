function [NoiseArray] = ArrayOfNoise(mainChannel, NoiseOnAllChans, map)
chanSpan = 20;
index = find([NoiseOnAllChans.chan] == mainChannel); %switch from channel number to Matlab Index
    counter = 1;
for r = (index - chanSpan):(index + chanSpan)
if ((r > 0) && ( r < length(map)))
NoiseArray(counter,1) = NoiseOnAllChans(r);

counter  = counter + 1;
end
end