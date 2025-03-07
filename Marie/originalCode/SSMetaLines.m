%set recrodinglabel string
recordingLabelString = '1614_210216g0';

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

CSpair
SSpair
PutSS

Tester = getTrueDepth(ByChannel, 2500, 90);%75);

for n = 1:length(Tester)
Tester(n).LaserOn = LaserStimAdj;
Tester(n).LaserOff = [];%LaserStimOffAdj;
end


for n = 1:length(Tester)
Tester(n).JuiceTimes = JuiceTimesAdj;
Tester(n).DrugStruct = [];
end

for n = 1:length(Tester)
Tester(n).FirstLicksEpochsAdj = FirstLicksEpochsAdj;
Tester(n).AllLicksAdj = AllLicksAdj;
Tester(n).NoJuiceAdj = NoJuiceAdj;
Tester(n).recordingLabel = recordingLabelString;
end

TrainingDay
RTs

for n = 1:length(Tester)
[~, Tester(n).WFduringJuice_1000, ~] = [];%SampleWaveformsTimeLimNewzerogo(Tester, .003, 1000, [JuiceTimesAdj(1)-10, JuiceTimesAdj(end) + 10], Tester(n).unitID, Tester(n).channel);
Tester(n).AvgWvFduringJuice = [];%avgeWaveforms(Tester(n).WFduringJuice);
Tester(n).RawDataFile = [];%'2021_04_20_1615_g0_t0.imec0.ap.bin';
end

for n = 1:length(Tester)
%[~, ~, MultiChanWFStruct] =  MultiChanWF(AllUnitStruct, .003, 100, [JuiceTimesAdj(1)-10, JuiceTimesAdj(end) + 10], FakeTimeGridA, FakeTimeGridB, Tester(n).unitID, MEH_chanMap, 'k', 0, 0, NaN);
Tester(n).MultiChanWFduringJuice = [];%MultiChanWFStruct;
end

[NoiseDataOrig, NoiseMetaDataOrig] = []:%NoiseSnips([0 inf], 30, 1);
[NoiseAnalysisOrig] = [];%NoiseOnEveryChannel(NoiseDataOrig, MEH_chanMap);

OutputData = [];%MultiChan_sig2noise(Tester, NoiseAnalysisOrig);

OneSDnoise
bestSig2Noise
bestChan

NoiseMetaData



figure
counter = 1;
counter2 = 1;
for n = 1:length(Tester)
if ~isempty(Tester(n).CSpair)
    figure
    %PSTHmakerTimeLimIndexPoint(JuiceTimesAdj, Tester(n).unitID, GoodUnitStruct, -2, 5, .1, [0 inf], 'k', .1);
[N, edges] = PSTHmakerTimeLimIndexPoint(Tester(n).FirstLicksEpochsAdj, n, Tester, -2, 8, .1, [0 inf], 'k', .1);
RespToLickEpochconfirmed(counter,:) = N;
counter = counter + 1;
end
if ~isempty(Tester(n).PutSS)
    figure
    %PSTHmakerTimeLimIndexPoint(JuiceTimesAdj, Tester(n).unitID, GoodUnitStruct, -2, 5, .1, [0 inf], 'k', .1);
[N, edges] = PSTHmakerTimeLimIndexPoint(Tester(n).FirstLicksEpochsAdj, n, Tester, -2, 8, .1, [0 inf], 'k', .1);
RespToLickEpochPut(counter2,:) = N;
counter2 = counter2 + 1;
end
end

figure
hold on
colorcounter = [0:(1/(counter + counter2-1)):1];

for n = 1:length(RespToLickEpochconfirmed(:,1))
    plot(edges(1:end-1), RespToLickEpochconfirmed(n,:), 'Color', [0, colorcounter(n), colorcounter(n)]);
end
MeanRespToLickEpochconfirmed = mean(RespToLickEpochconfirmed,1);
plot(edges(1:end-1), MeanRespToLickEpochconfirmed, 'm', 'LineWidth', 2);

for n = 1:length(RespToLickEpochPut(:,1))
    plot(edges(1:end-1), RespToLickEpochPut(n,:), 'Color', [0, colorcounter(n), colorcounter(n)], 'LineStyle', '--');
end
MeanRespToLickEpochPut = mean(RespToLickEpochPut,1);
plot(edges(1:end-1), MeanRespToLickEpochPut, 'm', 'LineWidth', 2, 'LineStyle', ':');
xline(0,'k', 'LineWidth', 2);
%xline(-.698, 'g', 'LineWidth', 2);
xlim([-2 4]);
FormatFigure;
title('SS Firing Rate in Resp to Lick');
ylabel('Hz');
xlabel('sec');
saveas(gca, 'RespToLick')
print('RespToLick','-depsc','-painters')



figure
counter = 1;
counter2 = 1;
for n = 1:length(Tester)
if ~isempty(Tester(n).CSpair)
    figure
    %PSTHmakerTimeLimIndexPoint(JuiceTimesAdj, Tester(n).unitID, GoodUnitStruct, -2, 5, .1, [0 inf], 'k', .1);
[N, edges] = PSTHmakerTimeLimIndexPoint(Tester(n).JuiceTimesAdj, n, Tester, -2, 8, .1, [0 inf], 'k', .1);
RespToJuiceCon(counter,:) = N;
counter = counter + 1;
end
if ~isempty(Tester(n).PutSS)
    figure
    %PSTHmakerTimeLimIndexPoint(JuiceTimesAdj, Tester(n).unitID, GoodUnitStruct, -2, 5, .1, [0 inf], 'k', .1);
[N, edges] = PSTHmakerTimeLimIndexPoint(Tester(n).JuiceTimesAdj, n, Tester, -2, 8, .1, [0 inf], 'k', .1);
RespToJuicePut(counter2,:) = N;
counter2 = counter2 + 1;
end
end

figure
hold on
colorcounter = [0:(1/(counter + counter2-1)):1];

for n = 1:length(RespToJuiceCon(:,1))
    plot(edges(1:end-1), RespToJuiceCon(n,:), 'Color', [0, colorcounter(n), colorcounter(n)]);
end
MeanRespToJuiceCon = mean(RespToJuiceCon,1);
plot(edges(1:end-1), MeanRespToJuiceCon, 'm', 'LineWidth', 2);

for n = 1:length(RespToJuicePut(:,1))
    plot(edges(1:end-1), RespToJuicePut(n,:), 'Color', [0, colorcounter(n), colorcounter(n)], 'LineStyle', '--');
end
MeanRespToJuicePut = mean(RespToJuicePut,1);
plot(edges(1:end-1), MeanRespToJuicePut, 'm', 'LineWidth', 2, 'LineStyle', ':');
xline(0,'b', 'LineWidth', 2);
xline(-.698, 'g', 'LineWidth', 2);
xlim([-2 4]);
FormatFigure;
title('SS Firing Rate in Resp to Juice');
ylabel('Hz');
xlabel('sec');
saveas(gca, 'RespToJuice')
print('RespToJuice','-depsc','-painters')