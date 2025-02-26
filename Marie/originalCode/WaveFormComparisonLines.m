%to see waveforms from different cells during a particular time period
%overlaid. To change waveform colors between runs (to compare two different
%time periods) change the color in line 87 of SampleWaveformsTimeLim

for n = 1:length(CSlist)
        %can exclude some with 'if' if needed
    [time, Waveforms, SampleTS] = SampleWaveformsTimeLim(AllUnitStruct, .009, 20, TimeLim2, CSlist(n,1), CSlistCH(n,1));

end
