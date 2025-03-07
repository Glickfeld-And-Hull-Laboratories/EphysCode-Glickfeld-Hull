function AmplitudeHistNew(unit, struct, TimeLim, color)


index = find([struct.unitID] == unit); %find unit of interest
title1 = [struct(index).unitID];

amplitudes = struct(index).amplitudes;
timestamps = struct(index).timestamps;

TSindex = find((timestamps > TimeLim(1)) & (timestamps < TimeLim(2)));
timestamps = timestamps(TSindex);
amplitudes = amplitudes(TSindex);

[N,edges] = histcounts(amplitudes);
Values = N;
BinEdges = edges(1:end-1);
%h = histogram(amplitudes);
%Values = h.Values;
%BinEdges = h.BinEdges(1:(end-1));    %drop last BinEdge to loose right edge of last bin

maxValues = max(Values);
AdjValues = (Values/maxValues)*timestamps(end)*.2 + timestamps(end) + .01*timestamps(end); %Normalize histogram to size of scatterplot

%figure
barh(BinEdges, AdjValues, 1, 'Facecolor', color, 'EdgeColor', 'none'); %'BaseValue', (timestamps(end) + .01*timestamps(end)) ); using the baseValue puts a subtle gray line I can't get rid off
xline((timestamps(end) + .01*timestamps(end)), 'w'); 
hold on
area([timestamps(1), timestamps(end)+.01*timestamps(end)], [max(amplitudes)+1, max(amplitudes)+1], 'FaceColor', [1 1 1], 'LineStyle', 'none');
scatter(timestamps, amplitudes, 'MarkerEdgeColor', color);
%hold on
%plot((AdjValues),BinEdges);

ylim([min(amplitudes)-1, max(amplitudes)+1]);
xlim([timestamps(1)-5, max(AdjValues) + 5]);
title(['Unit ' num2str(title1) ' amplitude over time']);
ylabel('Amplitude (arb. units)');
xlabel('sec');
FormatFigure(NaN,NaN);


end