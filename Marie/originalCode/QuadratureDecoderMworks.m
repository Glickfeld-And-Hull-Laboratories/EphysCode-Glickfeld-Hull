function [SpeedTimes, SpeedValues] = QuadratureDecoderMworks(QuadratureTimes, QuadratureValues)
if ~isempty(QuadratureTimes) & ~isempty(QuadratureValues)
pulsePerRev = 1024;
StateChangePerRev = 4*pulsePerRev;
dia = 14.8; %diameter in cm
binW = .1; %bin width for speed calculations in sec

SpeedTimes = [QuadratureTimes(1):binW:QuadratureTimes(end)];
SpeedTimes(end+1) =SpeedTimes(end) + binW;
 

for n = 1:length(SpeedTimes)-1
    Indices = find(QuadratureTimes < SpeedTimes(n+1) & QuadratureTimes > SpeedTimes(n));
    if ~isempty(Indices)
    Movement(n,:) = double(QuadratureValues(Indices(end))) - double(QuadratureValues(Indices(1)));
    else
      Movement(n,:) = 0;
    end
end
SpeedValues = ((Movement/StateChangePerRev)*pi*dia)/binW;
SpeedTimes = SpeedTimes(1:end-1);
else
    SpeedValues = [];
SpeedTimes = [];
end
end
