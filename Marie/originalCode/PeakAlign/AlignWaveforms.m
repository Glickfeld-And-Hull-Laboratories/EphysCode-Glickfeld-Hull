function AlignedWaveforms = AlignWaveforms(Waveforms, AlignMode, AlignI, m)
Right = 20;
Left = 5;
if AlignMode ==1
    Waveforms = -(Waveforms);
end
counter = 1
 for n = 1:size(Waveforms,2)
    [MiniMum, I] = min(Waveforms(AlignI-Left:AlignI+Right,n));
    localminindex = I + AlignI-Left-1;
    figure
    hold on
    plot(Waveforms(:,n));
    scatter(localminindex, MiniMum)
    if (abs(Waveforms(localminindex,n)-Waveforms(localminindex+1,n)) > .00001) 
        if (abs(Waveforms(localminindex,n)-Waveforms(localminindex - 1,n))> .00001)
        shift = (I-AlignI);
        AlignedWaveforms(:,counter) = Waveforms(localminindex-30:localminindex+60,n);
        counter = counter+1;
    end
 end 
 figure
hold on
for n = 1:size(AlignedWaveforms, 2)
plot(AlignedWaveforms(:,n));
counter
end
end

