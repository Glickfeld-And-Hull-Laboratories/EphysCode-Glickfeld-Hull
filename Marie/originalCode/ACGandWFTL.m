function [FR, channel, TimeLim1, wfStructStruct, Nisi, edgesISI, Nacg, edgesACG] = ACGandWFTL(unit, struct, TimeGridA, TimeGridB, WFleng, catchTime, xmin, xmax, ISIxaxis, TimeLim1, binsize, color, nametag, map, Figboo)
%TGlim1WFs, TGlim2WFs, StimWFs are all controlled by boolians and may have
%to be ~ed out

AxisAdjust = 0;
ylimitACG = NaN;
ylimitISI = NaN;

if ~isnan(TimeGridA)
FR = FRstructTimeGridTimeLimit(TimeGridA, TimeGridB, TimeLim1, struct, unit, color, 0);
end
if isnan(TimeGridA)
    FR = FRstructLimits(struct, TimeLim1, unit);
end
if AxisAdjust == 1 && FR <2
    xmin = -.4;
    xmax = .4;
    ISIxaxis = [0 .4];       
end


FRstr = num2str(round(FR,1));
unitStr = num2str(unit);
unitIN = find([struct.unitID] == unit);
channel = struct(unitIN).channel;
channelStr = num2str(struct(unitIN).channel);
TimeLimStart = num2str(TimeLim1(1));
TimeLimEnd = num2str(TimeLim1(2));
title_ = [unitStr ' fires at ' FRstr ' on channel ' channelStr ' baseline [' TimeLimStart ' ' TimeLimEnd '] ' nametag];
%title(title_)
if Figboo == 1
f = figure;
%%%%%%%%
channel = channel;
%%%%
set(gcf,'Position',[200 200 1300 400]);
layout1 = tiledlayout(1,4);

title(layout1, title_, 'FontSize', 22, 'FontName', 'Arial', 'FontWeight', 'bold');

end



%MulitChanWF panel
nexttile
[time, ~, TGlim1WFs, ~] = MultiChanWF(struct, WFleng, catchTime, 100, TimeLim1, TimeGridA, TimeGridB, unit, map, 'k', 1, 1, NaN);




%ISI panel
nexttile;
[medianISI, meanISI, Nisi, edgesISI] = ISIstructTimeGridTimeLim(TimeGridA, TimeGridB, struct, unit, ISIxaxis, TimeLim1, binsize, color, 1);
hold on

title('Baseline ISI')
ylabel('Hz');
xlabel('msec');

FormatFigure;
set(gca,'XTick',linspace(ISIxaxis(1),ISIxaxis(2),4));
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);


%ACG panel
nexttile;
[Nacg, edgesACG] = autoCorrStructNewLimitsTG(TimeGridA, TimeGridB, struct, xmin, xmax, binsize, unit, TimeLim1, color, 1);
hold on

title('Baseline ACG');
ylabel('Hz');
xlabel('msec');
if ~isnan(ylimitACG)
ylim(ylimitACG);
end
set(gca,'XTick',linspace(xmin,xmax,5));
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);
FormatFigure
%end ACG panel

%amphistpanetl 
nexttile
    AmplitudeHistNew(unit, struct, [TimeLim1(1) TimeLim1(2)], color)
    title('Amplitude');


   
wfStructStruct.unit = unit;
wfStructStruct.channel = channel;
wfStructStruct.Lim1 = TimeLim1;
wfStructStruct.TGlim1WFs = TGlim1WFs;
wfStructStruct.time = time;



saveas(gca, [unitStr nametag]);
%%print([unitStr nametag], '-dpdf')%, '-painters');
print(['ch ' channelStr 'un ' unitStr nametag], '-depsc', '-painters');

print(nametag, '-dpsc', '-bestfit', '-append');


%set(gcf, 'Renderer', 'zbuffer');
%saveas(gca, [unitStr nametag '.eps'], 'epsc')

%p = uipanel(f);
%p.Title = 'title';
end



