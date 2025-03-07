function [RightHalf] = AmplitudeHistNewerINDEX(index, struct, TimeGridA, TimeGridB, TimeLim, color)


figure
hold on
%index = find([struct.unitID] == unit); %find unit of interest
title1 = [struct(index).unitID];

amplitudes = struct(index).amplitudes;
timestamps = struct(index).timestamps;

TSindex = find((timestamps > TimeLim(1)) & (timestamps < TimeLim(2)));
timestamps = timestamps(TSindex);
amplitudes = amplitudes(TSindex);

if ~isnan(TimeGridA) %untested as of 240318
TimeGridAmps = [];
for i = 1:length(TimeGridB)

    AddThis1 = amplitudes(timestamps<TimeGridB(i));
    TS_AddThis1 = timestamps(timestamps<TimeGridB(i));
    AddThis2 = amplitudes(TS_AddThis1 > TimeGridA(i));
    TimeGridAmps = [TimeGridAmps; AddThis2];
end
amplitudes = TimeGridAmps;
end

B = rmoutliers(amplitudes, 'percentiles', [0, 99.9]);
[N,edges] = histcounts(B);
bw = edges(2)-edges(1);
edges = edges(1:end-1); %get rid of last trailing edge value
maxValue = max(smoothdata(N, 20));
PeakIndex = (find(N == maxValue));
NR= N(PeakIndex:end);
edgesR = edges(PeakIndex:end);
%[NR, edgesR] = histcounts(RightHalf);
%histogram(RightHalf);
%Values = N;
%BinEdges = edges(1:end-1);

BinMax = edges(PeakIndex);
RightHalf = B(find(B >= B))-BinMax;
size(amplitudes)
size(BinMax)
size(B)
% histogram(amplitudes-BinMax);
% histogram(B-BinMax, 'FaceAlpha', 0.5);
[h_N, h_edges] = histcounts(amplitudes);
plot(h_edges(1:end-1), h_N, 'b', 'LineWidth', 4);
[h_N, h_edges] = histcounts(B);
plot(h_edges(1:end-1), h_N, 'y', 'LineWidth', 2);




%bar(edges-BinMax, N, 1, 'Facecolor', color, 'EdgeColor', 'none'); 
% plot(edges(1:PeakIndex)-BinMax+(bw/2), N(1:PeakIndex), 'r', 'LineWidth', 4);
% plot(edges(PeakIndex:end)-BinMax+(bw/2), N(PeakIndex:end), 'g',  'LineWidth', 4);
%bar(edgesR-BinMax, NR, 1, 'Facecolor', 'y', 'EdgeColor', 'none'); 
% plot(edgesR-BinMax, NR, 'm', 'LineWidth',2);
% plot(-(edgesR-BinMax), NR, 'm', 'LineWidth',2);
scatter(0, maxValue, 'ro')

%plot(BinEdges, N, 'm')
%histogram(RightHalf)
%check = BinEdges(PeakIndex:end);
%pd = fitdist(smoothdata(amplitudes-BinMax, 5),'HalfNormal');
%pd = histfit(amplitudes);
%pd = fitdist(amplitudes,'Normal');

% xvals = [(edges(1)):.1:(edges(end))];
% %size(xvals)
% %xvals = [1:100];
% y = pdf(pd, xvals);
% y= y/max(y) * max(NR);
% plot(xvals(xvals >=0), y(xvals >=0), 'y', 'LineWidth', 3)
% plot(-xvals(xvals >=0), y(xvals >=0), 'y', 'LineWidth', 3)
 %plot(xvals - BinMax + (bw/2), y, 'y', 'LineWidth', 3)
%  plot(xvals - BinMax + (bw/2), y, 'y', 'LineWidth', 3);
%plot(-xvals, y, 'k')

%sizeReal = trapz(edges-BinMax,N)
%sizeIdeal = trapz(xvals,y)
plot(edges(1:PeakIndex)-BinMax+(bw/2), N(1:PeakIndex), 'm');
sizeLeft = trapz(edges(1:PeakIndex)-BinMax+(bw/2), N(1:PeakIndex));
plot(edges(PeakIndex:end)-BinMax+(bw/2), N(PeakIndex:end), 'm');
sizeRight = trapz(edges(PeakIndex:end)-BinMax+(bw/2), N(PeakIndex:end));

plot(flip(edges(PeakIndex:end)-BinMax+(bw/2))*-1, flip(N(PeakIndex:end)), 'g');
%tester = length(RightHalf)
%sizeCurve = trapz(xvals, y)
%MissingPercent = (sizeIdeal - sizeReal)/sizeIdeal
MissingPercent = (sizeRight - sizeLeft)/(2*sizeRight);
%tester3 = (sizeCurve*2 - 
%ylim([min(amplitudes)-1, max(amplitudes)+1]);
%xlim([timestamps(1)-5, max(AdjValues) + 5]);
title(['Unit ' num2str(title1) ' ' num2str(round(MissingPercent*100)) '% missing']);
ylabel('counts');
xlabel('Amplitude (arb. units)');
FormatFigure(NaN, NaN)
%plot(edges-BinMax, N, 'y', 'LineWidth', 3);


end