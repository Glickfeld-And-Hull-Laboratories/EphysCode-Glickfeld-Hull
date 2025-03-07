function [SpikeSamples, miniVoltage] = PlotRawDataBlackRock(UnitStruct, n, i, RawData, color, color2)
SampRate = 30000;

% plot Raw Trace
LaserTime = UnitStruct(n).LaserON(i);
PlotStart = LaserTime-.03;
PlotEnd = LaserTime +.1;
Xtime = [PlotStart*30000:PlotEnd*30000]/30000;
Xsamples = int64([PlotStart*30000:PlotEnd*30000]);
Voltage = (RawData(Xsamples));
plot(Xtime,Voltage, color);
xlim([Xtime(1) Xtime(end)]);
hold on

%Overlay any spike in trace
SpikeTimes = UnitStruct(n).timestamps(UnitStruct(n).timestamps > PlotStart);
SpikeTimes = SpikeTimes(SpikeTimes < PlotEnd);
if ~isempty(SpikeTimes)
    for j = 1:length(SpikeTimes)
    SpikeSamples = [int64((SpikeTimes(j)-.001)*SampRate):int64((SpikeTimes(j)+.002)*SampRate)];
    Xvals = double(SpikeSamples)/SampRate;
   miniVoltage = (RawData(SpikeSamples));
    plot(Xvals, miniVoltage, color2);
    end
else
    fprintf('no spikes in timeseries');
end

xline(LaserTime, 'b');
xline(UnitStruct(n).LaserOFF(i), 'b');
end