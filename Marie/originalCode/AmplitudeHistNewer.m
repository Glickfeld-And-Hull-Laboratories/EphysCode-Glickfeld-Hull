function [RightHalf] = AmplitudeHistNewerINDEX(index, struct, TimeLim, color)


%index = find([struct.unitID] == unit); %find unit of interest
title1 = [struct(index).unitID];

amplitudes = struct(index).amplitudes;
timestamps = struct(index).timestamps;

TSindex = find((timestamps > TimeLim(1)) & (timestamps < TimeLim(2)));
timestamps = timestamps(TSindex);
amplitudes = amplitudes(TSindex);


[N,edges] = histcounts(amplitudes);
edges = edges(1:end-1); %get rid of last trailing edge value
maxValue = max(N)
PeakIndex = (find(N == maxValue))
NR= N(PeakIndex:end);
edgesR = edges(PeakIndex:end);
%[NR, edgesR] = histcounts(RightHalf);
%histogram(RightHalf);
%Values = N;
%BinEdges = edges(1:end-1);

figure
hold on
BinMax = edges(PeakIndex)
RightHalf = amplitudes(find(amplitudes >= BinMax))-BinMax;
histogram(RightHalf);



%bar(edges-BinMax, N, 1, 'Facecolor', color, 'EdgeColor', 'none'); 
plot(edges-BinMax, N, 'r');
%bar(edgesR-BinMax, NR, 1, 'Facecolor', 'y', 'EdgeColor', 'none'); 
plot(edgesR-BinMax, NR, 'm', 'LineWidth',2);
plot(-(edgesR-BinMax), NR, 'm', 'LineWidth',2);
scatter(0, maxValue, 'ro')

%plot(BinEdges, N, 'm')
%histogram(RightHalf)
%check = BinEdges(PeakIndex:end);
pd = fitdist(RightHalf,'HalfNormal');
xvals = [floor(edgesR(1)):.1:floor(edgesR(end))]-BinMax;
size(xvals)
%xvals = [1:100];
y = pdf(pd, xvals);
y= y/max(y) * max(NR);
plot(xvals, y, 'k')
%plot(-xvals, y, 'k')

sizeReal = trapz(edges-BinMax,N)
sizeIdeal = 2* trapz(xvals,y)
%tester = length(RightHalf)
%sizeCurve = trapz(xvals, y)
MissingPercent = (sizeIdeal - sizeReal)/sizeIdeal
%tester3 = (sizeCurve*2 - 
%ylim([min(amplitudes)-1, max(amplitudes)+1]);
%xlim([timestamps(1)-5, max(AdjValues) + 5]);
title(['Unit ' num2str(title1) ' amplitudes']);
ylabel('counts');
xlabel('Amplitude (arb. units)');
FormatFigure


end