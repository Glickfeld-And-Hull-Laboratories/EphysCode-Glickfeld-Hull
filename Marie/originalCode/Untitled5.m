figure
counter = 1;
counter2 = 1;
for n = 1:length(Tester)
if ~isempty(Tester(n).CSpair) || ~isempty(Tester(n).PutSS)
    figure
    %PSTHmakerTimeLimIndexPoint(JuiceTimesAdj, Tester(n).unitID, GoodUnitStruct, -2, 5, .1, [0 inf], 'k', .1);
[N, edges] = PSTHmakerTimeLimIndexPoint(LickNocueReward, n, Tester, -2, 8, .1, [0 inf], 'k', .1);
%N = N/N(1); %normalize
RespToNoCueReward(counter,:) = N;
stdevLine = std(N(1:10));
meanLine = mean(N(1:10));
upline = meanLine + 2*stdevLine;
downline = meanLine - 2*stdevLine;
stdevNoCueReward(counter,1) = upline;
stdevNoCueReweard(counter,2) = downline;
counter = counter + 1;
end
end
close all

counter2 = 1;
for n = 1:length(Tester)
if ~isempty(Tester(n).CSpair) || ~isempty(Tester(n).PutSS)
    figure
    %PSTHmakerTimeLimIndexPoint(JuiceTimesAdj, Tester(n).unitID, GoodUnitStruct, -2, 5, .1, [0 inf], 'k', .1);
[N, edges] = PSTHmakerTimeLimIndexPoint(LickCueReward, n, Tester, -2, 8, .1, [0 inf], 'k', .1);
%N = N/N(1); %normalize
RespToCueReward(counter2,:) = N;
stdevLine = std(N(1:10));
meanLine = mean(N(1:10));
upline = meanLine + 2*stdevLine;
downline = meanLine - 2*stdevLine;
stdevCueReward(counter2,1) = upline;
stdevCueReward(counter2,2) = downline;
counter2 = counter2 + 1;
end
end
close all

counter3 = 1;
for n = 1:length(Tester)
if ~isempty(Tester(n).CSpair) || ~isempty(Tester(n).PutSS)
    figure
    %PSTHmakerTimeLimIndexPoint(JuiceTimesAdj, Tester(n).unitID, GoodUnitStruct, -2, 5, .1, [0 inf], 'k', .1);
[N, edges] = PSTHmakerTimeLimIndexPoint(LickOutside, n, Tester, -2, 8, .1, [0 inf], 'k', .1);
%N = N/N(1); %normalize
RespToLickOutside(counter3,:) = N;
stdevLine = std(N(1:10));
meanLine = mean(N(1:10));
upline = meanLine + 2*stdevLine;
downline = meanLine - 2*stdevLine;
stdevLickOutside(counter3,1) = upline;
stdevLickOutside(counter3,2) = downline;
counter3 = counter3 + 1;
end
end

figure
hold on
colorcounter = [0:(1/(counter + counter2-1)):1];

for n = 1:length(RespToLickON(:,1))
    figure
    plot(edges(1:end-1), RespToNoCueReward(n,:), 'Color', [0, colorcounter(n), colorcounter(n)]);
    hold on
    plot(edges(1:end-1), RespToCueReward(n,:), 'Color', 'b');
    plot(edges(1:end-1), RespToLickOutside(n,:), 'Color', 'r');
    xline(0,'r', 'LineWidth', 2);
    yline(stdevCueReward(n,1), 'g', 'LineWidth', 2);
    yline(stdevCueReward(n,2), 'y', 'LineWidth', 2);
xline(-.698, 'g', 'LineWidth', 2);
xlim([-2 4]);
FormatFigure;
title('SS Firing Rate in Resp to Reward');
ylabel('Hz');
xlabel('sec');
saveas(gca, ['b = tone, r = outside' num2str(n)])
print(['b = tone, r = outside' num2str(n)],'-depsc','-painters')
end
%MeanRespToLickON = mean(RespToLickON,1);
%plot(edges(1:end-1), MeanRespToLickON, 'm', 'LineWidth', 2);


xline(0,'r', 'LineWidth', 2);
xline(-.698, 'g', 'LineWidth', 2);
xlim([-2 4]);
FormatFigure;
title('SS Firing Rate in Resp to Reward');
ylabel('Hz');
xlabel('sec');
%saveas(gca, 'RespToLickNoCueReward')
%print('RespToLickNoCueReward','-depsc','-painters')