function [FR, WF, WF_post, time] = CellCharWorkupCombData(unit, struct, triggertype, TimeGridSize, xmin, xmax, TrigMin, TrigMax, TimeLim2, ISIxaxis, binsize, color)

%trigger type can be 'laser' or 'juice'

%set y-axis
ylimitACG = [0 25];
ylimitISI = [0 25];
ylimitWF1 = [-.0002 .0002];
ylimitWF2 = ylimitWF1;
ylimitFR = [0 25];
ylimitResp = [0 50];

unitIN = find([struct.unitID] == unit);

if strcmp(triggertype, 'laser')
trigger = struct(unitIN).LaserStim;
end

TimeGridB = trigger;
TimeGridA = trigger - TimeGridSize;

TimeLim = struct(unitIN).TimeLim;

FR = FRstructTimeGridTimeLimit(TimeGridA, TimeGridB, TimeLim, struct, unit);
FRstr = num2str(round(FR,1));
unitStr = num2str(unit);

channel = struct(unitIN).channel;
channelStr = num2str(struct(unitIN).channel);
TimeLimStart = num2str(TimeLim(1));
TimeLimEnd = num2str(TimeLim(2));
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
autoCorrStructNewLimitsTG(TimeGridA, TimeGridB, struct, xmin, xmax, binsize, unit, TimeLim, color);
title('Baseline ACG');
ylabel('Hz');
xlabel('sec');
ylim(ylimitACG);
FormatFigure


nexttile
ISIstructTimeGridTimeLim(TimeGridA, TimeGridB, struct, unit, ISIxaxis, TimeLim, binsize);
title('Baseline ISI')
ylabel('Hz');
xlabel('sec');
ylim(ylimitISI);
FormatFigure


nexttile
%[time, WF, ~] = SampleWaveformsTimeLimNew(struct, .003, 100, TimeLim, unit, channel);
[time, WF, ~] = SampleWaveformsTimeLimTG(TimeGridA, TimeGridB, struct, .003, 100, TimeLim, unit, channel);
title('Baseline non-stim WF')
ylabel('V');
xlabel('msec');
ylim(ylimitWF1);
FormatFigure


nexttile
fr= FRstruct(unit, struct, 30);
title('FR')
ylabel('Hz');
xlabel('sec');
%xline(960, 'b');
%xline(2040, 'r');
%xline(2760, 'r');
ylim(ylimitFR);
FormatFigure


nexttile
OneUnitHistStructTimeLim(trigger, unit, struct, TrigMin, TrigMax, binsize, TimeLim);
title('Spikes')
ylabel('Hz');
xlabel('sec');
xline(0, 'b');
ylim(ylimitResp);
%yline(130, 'r');
FormatFigure


%RasterMatrix = OrganizeRasterSpikes(struct, trigger, unit, -(TrigMin), TrigMax);
%title('Spikes')
%ylabel('Trial');
%xlabel('sec');
%xline(0, 'b');
%yline(130, 'r');
%FormatFigure

nexttile
[time, WF_post, ~] = SampleWaveformsTimeLimNew(struct, .003, 100, TimeLim2, unit, channel);
title('Post-drug all WF')
ylabel('V');
xlabel('msec');
ylim(ylimitWF2);
FormatFigure


saveas(gca, unitStr)
saveas(gca, unitStr, 'epsc')

%p = uipanel(f);
%p.Title = 'title';
end



