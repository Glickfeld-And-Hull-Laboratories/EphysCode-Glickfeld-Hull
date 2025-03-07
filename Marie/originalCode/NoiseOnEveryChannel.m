% =============================================================
% Simple helper functions and MATLAB structures demonstrating
% how to read and manipulate SpikeGLX meta and binary files.
%
% The most important part of the demo is ReadMeta().
% Please read the comments for that function. Use of
% the 'meta' structure will make your data handling
% much easier!
%af

%Use gain-adjusted struct and take in matchign time limits from
%binaryStruct

% timeLim = [0, inf] where 0 is begining to use and inf is the max. S, AvgWvF, SigNoise, MAD,
function [NoiseAnalysis] = NoiseOnEveryChannel(BinaryStruct, map)
%Where BinaryStruct is a structure of channels and voltages to be used for
%noise calculations

for n = 1:384
channelIndex = n;
ch = map(n).chan;

   dataArray = [BinaryStruct(channelIndex).Binary]; %gain-corrected raw data
   NoiseMedian = median(dataArray);
   MAD = median(abs(dataArray - NoiseMedian));  
    NoiseAnalysis(n).chan = ch;
    NoiseAnalysis(n).Median = NoiseMedian;
   NoiseAnalysis(n).OneStDev = (MAD/.6745);    %Estimate of 1 STDEV of noise distribution
end
end
