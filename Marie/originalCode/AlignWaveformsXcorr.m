function [AlignedWaveforms, shiftTime, peakcentered, noshift] = AlignWaveformsXcorr(Waveforms, shiftmax)
%shiftmax = maximum amount to shift in samples
sampRate = 30000;
AVG = avgeWaveforms(Waveforms);
noshift = 1;
noshift2 = 1;
peakcentered = 0;

%min-centered
[centermin, Icentermin] = min(AVG);
if Icentermin > shiftmax
 for n = 1:size(Waveforms,2)
     if (Icentermin+shiftmax < size(Waveforms,1) & Icentermin-shiftmax > 0)
     [corr, lags] = xcorr(AVG(Icentermin-shiftmax:Icentermin+shiftmax), Waveforms((Icentermin-shiftmax:Icentermin+shiftmax),n));
    [~, I] = max(corr);
    shift = lags(I);
     else 
         shift = 0;
     end
   
         if abs(shift) <= shiftmax
        AlignedWaveforms(:,n) = Waveforms(shiftmax+1-shift:(end-shiftmax-shift),n); %+1 bc of zero index
         shiftTime(n) = -shift/sampRate;
         else
        AlignedWaveforms(:,n) = Waveforms(shiftmax+1:(end-shiftmax),n);
        noshift = noshift + 1;
        shiftTime(n) = 0;
         end 
 end
 MinSize = max(avgeWaveforms(AlignedWaveforms))- min(avgeWaveforms(AlignedWaveforms))*1000;
else
    MinSize = 0;
end
 %max-centered
[centermax, Icentermax] = max(AVG);
 for n = 1:size(Waveforms,2)
  if (Icentermax+shiftmax < size(Waveforms,1) & Icentermax-shiftmax > 0) % not totally sure this is right, but it should be a rare minority
      [corr2, lags2] = xcorr(AVG(Icentermax-shiftmax:Icentermax+shiftmax), Waveforms((Icentermax-shiftmax:Icentermax+shiftmax),n));
    [~, I2] = max(corr2);
    I2;
    shift2 = lags2(I2);
  else shift2 = 0;
  end
    
    
    if abs(shift2) <= shiftmax
        AlignedWaveforms2(:,n) = Waveforms(shiftmax+1-shift2:(end-shiftmax-shift2),n); %+1 bc of zero index
        shiftTime2(n) = -shift2/sampRate;
        else
        AlignedWaveforms2(:,n) = Waveforms(shiftmax+1:(end-shiftmax),n);
        shiftTime2(n) = 0;
        noshift2 = noshift2 + 1;
    end
 
 end 
 MaxSize = max(avgeWaveforms(AlignedWaveforms2))- min(avgeWaveforms(AlignedWaveforms2))*1000;
    if MaxSize > MinSize
        AlignedWaveforms = AlignedWaveforms2;
        peakcentered = 1;
        noshift= noshift2;
        shiftTime = shiftTime2;
    end
shiftTime = shiftTime.';

for n = 1:size(AlignedWaveforms, 2)    %add NaNs to make the waveforms show up on the right place in the graph
    AlignedWaveforms3(:,n) = [NaN(1, shiftmax).'; [AlignedWaveforms(:,n)]; NaN(1, shiftmax).'];
end
AlignedWaveforms = AlignedWaveforms3;
hold on
for k = 1:size(AlignedWaveforms, 2)
%plot(AlignedWaveforms(:,k), 'k');
end
%plot(avgeWaveforms(AlignedWaveforms), 'Color', 'r', 'LineWidth', 2);

 end



