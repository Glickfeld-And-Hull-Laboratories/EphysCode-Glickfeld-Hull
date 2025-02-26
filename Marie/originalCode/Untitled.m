figure
counter = 1;
counter2 = 1;
for n = 1:length(SS1613_210402g0)
    earlyRT=[B(9:30), I(9:30)];
    ShortRTsIndex = earlyRT(:,2);
    JuiceTimesShort = SS1613_210402g0(n).JuiceTimes(ShortRTsIndex);
    if ~isempty(JuiceTimesShort)
if ~isempty(SS1613_210402g0(n).CSpair) || ~isempty(SS1613_210402g0(n).PutSS)
    figure
    %PSTHmakerTimeLimIndexPoint(JuiceTimesAdj, SS1613_210402g0(n).unitID, GoodUnitStruct, -2, 5, .1, [0 inf], 'k', .1);
[N, edges] = PSTHmakerTimeLimIndexPoint(JuiceTimesShort, n, SS1613_210402g0, -2, 8, .1, [0 inf], 'k', .1); %SS1613_210402g0(n).FirstLicksEpochsAdj, n, SS1613_210402g0, -2, 8, .1, [0 inf], 'k', .1);
RespToJuiceShortRTsCon(counter,:) = N/N(1);
counter = counter + 1;
end
    end
end
close all

figure
hold on
colorcounter = [0:(1/(counter + counter2-1)):1];

if exist('RespToJuiceShortRTsCon')
for n = 1:length(RespToJuiceShortRTsCon(:,1))
    plot(edges(1:end-1), RespToJuiceShortRTsCon(n,:), 'Color', [0, colorcounter(n), colorcounter(n)]);
end
MeanRespJuiceShortRTsCon = mean(RespToJuiceShortRTsCon,1);
plot(edges(1:end-1), MeanRespJuiceShortRTsCon, 'm', 'LineWidth', 2);
end

xline(0,'b', 'LineWidth', 2);
xline(-.698, 'g', 'LineWidth', 2);
xlim([-2 4]);
FormatFigure;
title('SS Firing Rate in Resp to ShortRTs');
ylabel('Hz');
xlabel('sec');

hold on

-----------------


%figure
counter = 1;
counter2 = 1;
for n = 1:length(SS1613_210402g0)
    lateRT=[B(97:118), I(97:118)];
    LateRTsIndex = lateRT(:,2);
    JuiceTimesLate = SS1613_210402g0(n).JuiceTimes(LateRTsIndex);
    if ~isempty(JuiceTimesLate)
if ~isempty(SS1613_210402g0(n).CSpair) || ~isempty(SS1613_210402g0(n).PutSS)
    figure
    %PSTHmakerTimeLimIndexPoint(JuiceTimesAdj, SS1613_210402g0(n).unitID, GoodUnitStruct, -2, 5, .1, [0 inf], 'k', .1);
[N, edges] = PSTHmakerTimeLimIndexPoint(JuiceTimesLate, n, SS1613_210402g0, -2, 8, .1, [0 inf], 'k', .1); %SS1613_210402g0(n).FirstLicksEpochsAdj, n, SS1613_210402g0, -2, 8, .1, [0 inf], 'k', .1);
RespToJuiceLateRTsCon(counter,:) = N/N(1);
counter = counter + 1;
end
    end
end
%close all

figure
hold on
colorcounter = [0:(1/(counter + counter2-1)):1];

if exist('RespToJuiceLateRTsCon')
for n = 1:length(RespToJuiceLateRTsCon(:,1))
    plot(edges(1:end-1), RespToJuiceLateRTsCon(n,:), 'Color', [0, colorcounter(n), colorcounter(n)], 'LineStyle', ':');
end
MeanRespToJuiceLateRTsCon = mean(RespToJuiceLateRTsCon,1);
plot(edges(1:end-1), MeanRespToJuiceLateRTsCon, 'm', 'LineWidth', 2, 'LineStyle', ':');
end

-----------------


xline(0,'b', 'LineWidth', 2);
xline(-.698, 'g', 'LineWidth', 2);
xlim([-2 4]);
FormatFigure;
title('SS Firing Rate in Resp to ShortRTs');
ylabel('Hz');
xlabel('sec');
%saveas(gca, 'SSRespToShortRTNorm')
%print('SSRespToShortRTNorm','-depsc','-painters')



figure
counter = 1;
counter2 = 1;
for n = 1:length(AllSS)
if ~isempty(AllSS(n).CSpair)
    figure
    %PSTHmakerTimeLimIndexPoint(JuiceTimesAdj, AllSS(n).unitID, GoodUnitStruct, -2, 5, .1, [0 inf], 'k', .1);
[N, edges] = PSTHmakerTimeLimIndexPoint(AllSS(n).JuiceTimesAdj, n, AllSS, -2, 8, .1, [0 inf], 'k', .1);
RespToJuiceCon(counter,:) = N/N(1);
counter = counter + 1;
end
if ~isempty(AllSS(n).PutSS)
    figure
    %PSTHmakerTimeLimIndexPoint(JuiceTimesAdj, AllSS(n).unitID, GoodUnitStruct, -2, 5, .1, [0 inf], 'k', .1);
[N, edges] = PSTHmakerTimeLimIndexPoint(AllSS(n).JuiceTimesAdj, n, AllSS, -2, 8, .1, [0 inf], 'k', .1);
RespToJuicePut(counter2,:) = N/N(1);
counter2 = counter2 + 1;
end
end
close all

figure
hold on
colorcounter = [0:(1/(counter + counter2-1)):1];

for n = 1:length(RespToJuiceCon(:,1))
    plot(edges(1:end-1), RespToJuiceCon(n,:), 'Color', [.3 .3 .3]);%[0, colorcounter(n), colorcounter(n)]);
end
MeanRespToJuiceCon = mean(RespToJuiceCon,1);
plot(edges(1:end-1), MeanRespToJuiceCon, 'm', 'LineWidth', 2);

for n = 1:length(RespToJuicePut(:,1))
    plot(edges(1:end-1), RespToJuicePut(n,:), 'Color', [.3 .3 .3], 'LineStyle', '--');
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
saveas(gca, 'SSRespToJuiceTrainedNorm')
print('SSRespToJuiceTrainedNorm','-depsc','-painters')