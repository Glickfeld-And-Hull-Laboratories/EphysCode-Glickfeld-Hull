%%set this!
recordingLabelString = '1613_210402g0';

fid = fopen('FirstJuiceAdj.txt');
FirstJuiceAdj = fscanf(fid, '%f');
fclose(fid);
fid = fopen('FirstLicksEpochsAdj.txt');
FirstLicksEpochsAdj = fscanf(fid, '%f');
fclose(fid);
fid = fopen('NoJuiceAdj.txt');
NoJuiceAdj = fscanf(fid, '%f');
fclose(fid);
fid = fopen('AllLicksAdj.txt');
AllLicksAdj = fscanf(fid, '%f');
fclose(fid);
fid = fopen('JuiceTimesAdj.txt');
JuiceTimesAdj = fscanf(fid, '%f');
fclose(fid);

counter = 1;
for n = 1:length(GoodUnitStruct)
if GoodUnitStruct(n).FR <3
GoodUnitsLessThan3hz(counter) = GoodUnitStruct(n);
counter = counter + 1;
end
end

for n = 1:length(GoodUnitsLessThan3hz)
[~, GoodUnitsLessThan3hz(n).WFduringJuice, ~] = SampleWaveformsTimeLimNewzerogo(GoodUnitsLessThan3hz, .003, 100, [JuiceTimesAdj(1)-10, JuiceTimesAdj(end) + 10], GoodUnitsLessThan3hz(n).unitID, GoodUnitsLessThan3hz(n).channel);
GoodUnitsLessThan3hz(n).AvgWvF = avgeWaveforms(GoodUnitsLessThan3hz(n).WFduringJuice);
[GoodUnitsLessThan3hz(n).ISIn, GoodUnitsLessThan3hz(n).ISIedges] = autoCorrStructNewLimits(AllUnitStruct, -.3, .3, .001, GoodUnitsLessThan3hz(n).unitID, [JuiceTimesAdj(1) - 10 JuiceTimesAdj(end) + 10], 'm');
if GoodUnitsLessThan3hz(n).ISIn(321) > 1
GoodUnitsLessThan3hz(n).ISI20msMT1boo = 1;
else
GoodUnitsLessThan3hz(n).ISI20msMT1boo = [];
end
GoodUnitsLessThan3hz(n).recordingLabel = recordingLabelString;
GoodUnitsLessThan3hz(n).JuiceTimesAdj = JuiceTimesAdj;
GoodUnitsLessThan3hz(n).FirstLicksEpochsAdj = FirstLicksEpochsAdj;
GoodUnitsLessThan3hz(n).AllLicksAdj = AllLicksAdj;
end

counter = 1;
for n = 1:length(GoodUnitsLessThan3hz)
if isempty(GoodUnitsLessThan3hz(n).ISI20msMT1boo)
[N, edges] = OneUnitHistStructTimeLim(GoodUnitsLessThan3hz(n).JuiceTimesAdj, GoodUnitsLessThan3hz(n).unitID, GoodUnitsLessThan3hz, -2, 8, .1, [0 inf], 'k', .1);
RespToJuice(counter,:) = N;
counter = counter + 1;
end
end
figure
hold on
for n = 1:length(RespToJuice(:,1))
    plot(edges(1:end-1), RespToJuice(n,:));
end
MeanRespToJuice = mean(RespToJuice,1);
plot(edges(1:end-1), MeanRespToJuice, 'k', 'LineWidth', 2);
xline(0,'b', 'LineWidth', 2);
xline(-.7, 'g', 'LineWidth', 2);
FormatFigure;
title('CS Firing Rate in Resp to Juice Delivery');
ylabel('Hz');
xlabel('sec');
saveas(gca, 'RespToJuice')
print('RespToJuice','-depsc','-painters')

figure
counter = 1;
for n = 1:length(GoodUnitsLessThan3hz)
if isempty(GoodUnitsLessThan3hz(n).ISI20msMT1boo)
[N, edges] = OneUnitHistStructTimeLim(GoodUnitsLessThan3hz(n).FirstLicksEpochsAdj, GoodUnitsLessThan3hz(n).unitID, GoodUnitsLessThan3hz, -2, 8, .1, [0 inf], 'k', .1);
RespToLickEpoch(counter,:) = N;
counter = counter + 1;
end
end
figure
hold on
for n = 1:length(RespToLickEpoch(:,1))
    plot(edges(1:end-1), RespToLickEpoch(n,:));
end
MeanRespToLickInit = mean(RespToLickEpoch,1);
plot(edges(1:end-1), MeanRespToLickInit, 'k', 'LineWidth', 2);
xline(0,'k', 'LineWidth', 2);
FormatFigure;
title('CS Firing Rate in Resp to Lick Initiation');
ylabel('Hz');
xlabel('sec');
saveas(gca, 'RespToLickInitian')
print('RespToJLickInitian','-depsc','-painters')

figure
counter = 1;
clear N edges MeanRespToLickInit2 RespToLickInit2
for n = 1:length(GoodUnitsLessThan3hz)
if isempty(GoodUnitsLessThan3hz(n).ISI20msMT1boo)
[N, edges] = OneUnitHistStructTimeLim(GoodUnitsLessThan3hz(n).JuiceTimesAdj, GoodUnitsLessThan3hz(n).unitID, GoodUnitsLessThan3hz, -2, 8, .5, [0 inf], 'k', .1);
RespToJuice(counter,:) = N;
counter = counter + 1;
end
end
figure
hold on
colorcounter = [0:(1/(counter-1)):1];
for n = 1:length(RespToJuice(:,1))
    plot(edges(1:end-1), RespToJuice(n,:), 'Color', [0, colorcounter(n), colorcounter(n)]);
end
MeanRespToJuice = mean(RespToJuice,1);
plot(edges(1:end-1), MeanRespToJuice, 'm', 'LineWidth', 2);
xline(0,'b', 'LineWidth', 2);
xline(-.698, 'g', 'LineWidth', 2);
xlim([-2 4]);
FormatFigure;
title('CS Firing Rate in Resp to Juice');
ylabel('Hz');
xlabel('sec');
saveas(gca, 'RespToJuice')
print('RespToJuice','-depsc','-painters')


