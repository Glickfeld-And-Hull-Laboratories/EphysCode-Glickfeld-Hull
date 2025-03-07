function AvgWaveformBlackRockTimeLim(RawData, timeLim, timestamps, n, color1, color2, plotSingleWFs)

title_ = 'WF';
dataLength = .003;
SampRate = 30000;

timestamps = timestamps(timestamps < timeLim(2)); %time limit timestamps
timestamps = timestamps(timestamps > timeLim(1));

step = floor(length(timestamps)/n) %How many spikes in each time duration division so some spikes are chosen from each segement

timestamps = (timestamps - .001); % catch the begining of the waveform
nSamp = floor(dataLength * SampRate);
nSamp = int64(nSamp);

timestep = 1/SampRate;
time = 0:timestep:dataLength-1/SampRate;

if step > 0
    fprintf('\nStep size is %i, %i waveforms plotted and averaged\n', step, n);
    randn = zeros(n,1);
for i = 1:n
  randn(i,1) = randi([(((i-1)*step)+1),(i*step)]); %pick which spike from each section defined as step spikes
end
TSindex = randn;
end

if step == 0
    TSindex = [1:length(timestamps)].';
    if ~isempty(timestamps)
    %warning('\n Not enough spikes to compute average. All available spikes are used')
    fprintf('\nNot enough spikes to perform planned calculation. %i spikes are averaged and plotted\n', length(timestamps))
    warndlg('Not enough spikes available perform planned mean WF calculation. Available spikes are averaged and plotted');
    end
end
if ~isempty(timestamps)
    Waveforms = zeros(nSamp, length(TSindex));
for i = 1:length(TSindex)
samp0 = int64(timestamps(TSindex(i,1))*SampRate);
%SampleTS(i) = timestamps(TSindex(i,1));
Waveforms(:,i) = RawData(samp0:samp0+nSamp-1).';
end
else
fprintf('\nNo spikes in window. Avg WF = 0.\n')
warndlg('No spikes in WF mean calculation window. AvgWF = 0');
end

AvgWvF = avgeWaveforms(Waveforms);

%figure
hold on
if(plotSingleWFs)
for p = 1:length(TSindex)
    plot(time, Waveforms(:,p), color1);
end
end
plot(time, AvgWvF, color2);
hold off
    
title(title_);
%xticks([0 30 60 90 120 150])
%xticklabels({'0' '.001','.002','.003', '.004', '.005'})
box off;
%ax.TickDir = 'out'
ax = gca; 
ax.TickDir = 'out';
ax.FontName = 'Calibri'; 'FixedWidth';
ax.FontSize = 18;
end