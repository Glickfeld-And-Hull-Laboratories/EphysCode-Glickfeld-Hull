function [FR, WF] = CellCharWorkupBaseLine(unit, struct, TimeGridA, TimeGridB, xmin, xmax, TimeLim1, ISIxaxis, binsize, color)

psth = 1; %(if you want psth on or not)
raster = 0; %(if you want raster on or not)

%set y-axis
ylimON = 0; %(0 or 1 if you want the ylimits on or not);
ylimitACG = [0 2];
ylimitISI = [0 2];
ylimitWF1 = [-.0002 .0002];
ylimitWF2 = ylimitWF1;
ylimitFR = [0 2];
ylimitResp = [0 4];

FR = FRstructTimeGridTimeLimit(TimeGridA, TimeGridB, TimeLim1, struct, unit, color);
FRstr = num2str(round(FR,1));
unitStr = num2str(unit);
unitIN = find([struct.unitID] == unit);
channel = struct(unitIN).channel;
channelStr = num2str(struct(unitIN).channel);
TimeLimStart = num2str(TimeLim1(1));
TimeLimEnd = num2str(TimeLim1(2));
title_ = [unitStr ' fires at ' FRstr ' on channel ' channelStr ' from ' TimeLimStart ' to ' TimeLimEnd];
%title(title_)
f = figure;

set(gcf,'Position',[150 -150 1800 1100]);
t = tiledlayout('flow');
%t.Title.String = title_;
title(t, title_, 'FontSize', 40, 'FontName', 'Arial', 'FontWeight', 'bold');
%nexttile



%nexttile


nexttile
autoCorrStructNewLimitsTG(TimeGridA, TimeGridB, struct, xmin, xmax, binsize, unit, TimeLim1, color);
title('Baseline ACG');
ylabel('Hz');
xlabel('sec');
if ylimON == 1
ylim(ylimitACG);
end
FormatFigure


nexttile
ISIstructTimeGridTimeLim(TimeGridA, TimeGridB, struct, unit, ISIxaxis, TimeLim1, binsize, 'k');
title('Baseline ISI')
ylabel('Hz');
xlabel('sec');
if ylimON == 1
ylim(ylimitISI);
end
FormatFigure


nexttile
%[time, WF, ~] = SampleWaveformsTimeLimNew(struct, .003, 100, TimeLim, unit, channel);
[time, WF, ~] = SampleWaveformsTimeLimTG(TimeGridA, TimeGridB, struct, .003, 100, TimeLim1, unit, channel);
title('Non-stim WF')
ylabel('V');
xlabel('msec');
if ylimON ==1
ylim(ylimitWF1);
end
FormatFigure


nexttile
fr= FRstruct(unit, struct, 30);
title('FR')
ylabel('Hz');
xlabel('sec');
xlim([TimeLim1(1) TimeLim1(2)]);
if ylimON == 1
ylim(ylimitFR);
end
FormatFigure


saveas(gca, [unitStr 'baseline'])
print([unitStr 'baseline'], '-dpdf');
%saveas(gca, [unitStr 'baseline'], 'epsc')

%p = uipanel(f);
%p.Title = 'title';
end



