function AmpsForBlackrock(RawData, timeLim, timestamps)


dataLength = .003;
SampRate = 30000;

timestamps = timestamps(timestamps < timeLim(2)); %time limit timestamps
timestamps = timestamps(timestamps > timeLim(1));



timestamps = (timestamps - .001); % catch the begining of the waveform
nSamp = floor(dataLength * SampRate);
nSamp = int64(nSamp);
Waveforms = zeros(nSamp, length(timestamps));

TSindex = [1:length(timestamps)].';
Amp = zeors(TSindex(end),1);
for i = 1:length(TSindex)
samp0 = int64(timestamps(TSindex(i,1))*SampRate);
Waveforms(:,i) = RawData(samp0:samp0+nSamp-1).';
Amp(i) = max(Waveforms(:,i))-min(Waveforms(:,i));
end

figure;
plot(Amp);
title('Raw Amps');
FormatFigure
end