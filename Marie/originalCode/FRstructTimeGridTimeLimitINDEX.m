function [FRate, N, edges] = FRstructTimeGridTimeLimitINDEX(TimeGridA,TimeGridB, TimeLim, struct, unit, color, plotboo, bwidth)

%n = find([struct.unitID] == unit); %% n changes to index in struct pointing to specified unit
n = unit;
TS2 = struct(n).timestamps;  %% Make vector, TimeStamps2, that has timestamps from unit.

title_ = [struct(n).unitID];
title_ = num2str(title_);
titleTr_ = inputname(1);
title_ = strcat(['Hz over time is' titleTr_ 'TG']);
title_ = strcat([title_ 'TG']);

TS2 = TS2(TS2 < TimeLim(2)); %time limit timestamps
TS2 = TS2(TS2 > TimeLim(1));


if ~isnan(TimeGridA)
TimeGridB = TimeGridB((TimeGridB < TimeLim(2)) & (TimeGridB > TimeLim(1)));
TimeGridA = TimeGridA((TimeGridA < TimeLim(2)) & (TimeGridA > TimeLim(1)));
if TimeGridB(1) < TimeGridA(1) %fixes MAJOR time grid bug
    TimeGridB = TimeGridB(2:end);
end
if TimeGridA(end) > TimeGridB(end)
    TimeGridA = TimeGridA(1:end-1);
end
TS2 = TimeGridUnit(TimeGridA, TimeGridB, TS2);
end
TimeTotal = 0;
AllSpikes = 0;

if ~isempty(TS2)
FR = zeros(length(TimeGridB),1);
if ~isnan(TimeGridA)
for f = 1:length(FR)
    TSWin = (TS2(TS2 > TimeGridA(f) & TS2 < TimeGridB(f)));
    AllSpikes = AllSpikes + length(TSWin);
    FR(f) = length(TS2(TS2 > TimeGridA(f) & TS2 < TimeGridB(f))) /(TimeGridB(f)-TimeGridA(f));
    TimeTotal = TimeTotal + (TimeGridB(f)-TimeGridA(f));
    timegrid = [TimeGridA(f) TimeGridB(f)];
    if length(TSWin) ~= 0
    tester = length(TSWin);
    tester2 = (TimeGridB(f)-TimeGridA(f));
    end
end
else
    AllSpikes = length(TS2);
    TimeTotal = TS2(end);
end
else
    FRate = 0;
end
FRate = AllSpikes/TimeTotal;

if plotboo == 1
%plot(clusts);
%figure;
%bar (FR, 1, color);
[N, edges] = histcounts(TS2, 'Binwidth', bwidth, 'Normalization', 'countdensity');
bar(edges(1:end-1), N);
box off;
ax = gca; 
ax.TickDir = 'out';
ax.FontName = 'Calibri'; 'FixedWidth';
ax.FontSize = 18;

%title(title_);
title([num2str(unit),   ' Hz over time TG']);
end
end