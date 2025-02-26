function [time, MainWaveforms, MultiChanWFStruct, Scale] = troubleshoot(struct, dataLength, n, timeLim, TimeGridA, TimeGridB, unit, map, color, PlotSamps, PlotMean, ScalePass)
%map is structure with each row being a channel and fields chan, xcoord,
%ycoord, typically MEH_chanMap
%PlotSamps is 1 to plot waveforms, 0 to just pass them out.
%can pass NAN for TG to turn TG off.

index = find([struct.unitID] == unit); %% n changes to index in struct pointing to specified unit
CenterChan = struct(index).channel;


figure
if ~isnan(TimeGridA)
    [time, MainWaveforms, ~] = SampleWaveformsTimeLimTGzerogo(TimeGridA, TimeGridB, struct, dataLength, n, timeLim, unit, CenterChan); %first we want to get size of unit so we can scale
else 
    [time, MainWaveforms, ~] = SampleWaveformsTimeLimNewzerogo(struct, dataLength, n, timeLim, unit, CenterChan); %first we want to get size of unit so we can scale
end
close all

AlignWaveforms(MainWaveforms)
MultiChanWFStruct = 0;
Scale = 0;
end