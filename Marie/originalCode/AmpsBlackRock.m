function AmpsBlackrock(RawData, timeLim, timestamps, color)


dataLength = .003;
SampRate = 30000;

timestamps = timestamps(timestamps < timeLim(2)); %time limit timestamps
timestamps = timestamps(timestamps > timeLim(1)+.001); %becasue we want to catch the first ms of waveform

if isinf(timeLim(2))
    timestamps = timestamps(timestamps < timestamps(end)-.002); %becasue we need at least .002 after the end of the file
end

timestamps = (timestamps - .001); % catch the begining of the waveform
nSamp = floor(dataLength * SampRate);
nSamp = int64(nSamp);
Waveforms = zeros(nSamp, length(timestamps));

TSindex = [1:length(timestamps)].';
Amp = zeros(TSindex(end),1);
for i = 1:length(TSindex)
samp0 = int64(timestamps(TSindex(i,1))*SampRate);
Waveforms(:,i) = RawData(samp0:samp0+nSamp-1).';
Amp(i) = max(Waveforms(:,i))-min(Waveforms(:,i));
end


[N,edges] = histcounts(Amp);
Values = N;
BinEdges = edges(1:end-1);

maxValues = max(Values);
AdjValues = (Values/maxValues)*timestamps(end)*.2 + timestamps(end) + .01*timestamps(end); %Normalize histogram to size of scatterplot

%figure
barh(BinEdges, AdjValues, 1, 'Facecolor', color, 'EdgeColor', 'none'); %'BaseValue', (timestamps(end) + .01*timestamps(end)) ); using the baseValue puts a subtle gray line I can't get rid off
xline((timestamps(end) + .01*timestamps(end)), 'w'); 
hold on
area([timestamps(1), timestamps(end)+.01*timestamps(end)], [max(Amp)+1, max(Amp)+1], 'FaceColor', [1 1 1], 'LineStyle', 'none');
scatter(timestamps, Amp, 'MarkerEdgeColor', color);
%hold on
%plot((AdjValues),BinEdges);

ylim([min(Amp)-1, max(Amp)+1]);
xlim([timestamps(1)-5, max(AdjValues) + 5]);
%title(['Unit ' num2str(title1) ' amplitude over time']);
ylabel('Amplitude (arb. units)');
xlabel('sec');
FormatFigure

%figure;
%plot([1:length(Amp)], Amp, 'o');
%title('Raw Amps');
%FormatFigure
end