function CellCharWorkupBinPersuit(UnitStruct, unit, nametag)

TimeGridA = NaN;
TimeGridB = NaN;
TimeLim1 = [0 inf];
channel = 80;
struct = UnitStruct;

n = find([UnitStruct.unitID] == unit);

f = figure;
FR = FRstructLimits(UnitStruct, [0 inf], UnitStruct(n).unitID);
title_ = ['Unit ' num2str(UnitStruct(n).unitID)];
layout1 = tiledlayout(3,3);
title(layout1, title_, 'FontSize', 30, 'FontName', 'Arial', 'FontWeight', 'bold');

nexttile %FR tile
FRstruct(unit, UnitStruct, 1, 'k', 1);
% if ~isinf(FirstLaser)
%     for i = 1:length(UnitStruct(n).LaserON)
%         xline(UnitStruct(n).LaserON(i), 'b');
%     end
ylabel('Hz');
xlabel('sec');
%xline(FirstLaser, 'b', 'Label', 'First Laser');
%xline(UnitStruct(n).LaserON(end), 'b', 'Label', 'Last Laser');
% end

% nexttile % template tile
% plot(UnitStruct(n).template);
% title('Template');
% xlabel('msec');
% FormatFigure;

%WFpanel
nexttile;
%[time, WF, ~] = SampleWaveformsTimeLimNew(struct, .003, 100, TimeLim, unit, channel);
[time, WF, ~] = SampleWaveformsTimeLimTGzerogo(TimeGridA, TimeGridB, struct, .006, 100, TimeLim1, unit, channel, 1);
title('Non-stim WF')
ylabel('V');
xlabel('msec');
% if ~isnan(ylimitWF1)
% ylim(ylimitWF1);
% end
hold on
plot([0;.001], [0;0], 'k');
hold off;
FormatFigure(NaN,NaN);
%end WF panel

% if laserStimOverlayMulti == 1
%     [~, ~, StimWFs, ~] = MultiChanWF_uhd(struct, .003, .001, 100, TimeLim1, TimeGridB, TimeGridB+StimTimeWin, unit, map, 'b', 0, 1, Scale);
%     hold on
%     for n = length(StimWFs)
%         plot(time+StimWFs(n).X/1000, StimWFs(n).AvgWf + StimWFs(n).Y * StimWFs(n).Scale/10, 'b');
%     end
%     for n = length(TGlim1WFs)
%         plot(time+TGlim1WFs(n).X/1000, TGlim1WFs(n).AvgWf + TGlim1WFs(n).Y * TGlim1WFs(n).Scale/10, 'k');
%     end
%     
% end

nexttile %ACG tile basic
autoCorrStructNewLimits(UnitStruct, -.1, .1, .001, n, [0 inf], 'k');

nexttile %ACG tile Zoom
autoCorrStructNewLimits(UnitStruct, -.01, .01, .0005, n, [0 inf], 'k');
FormatFigure(NaN, NaN);
ylabel('Hz');
xlabel('msec');
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1), L(2), 5))
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);


% 
% nexttile %ACG tile w. laser included
% autoCorrStructNewLimits(UnitStruct, -.05, .05, .0005, n, [0 inf], 'k');
% FormatFigure(NaN, NaN);
% ylabel('Hz')
% xlabel('msec')
% L = get(gca,'XLim');
% set(gca,'XTick',linspace(L(1), L(2), 5));
% xl = xticklabels;
% MSlabels = Sec2ms(xl);
% xticklabels(MSlabels);


% nexttile %Amps
% AmpsBlackRock(UnitStruct(n).RawData, [0 inf], UnitStruct(n).timestamps, 'k');
% FormatFigure;
% title('Raw Amplitudes');

% nexttile %Resp to Laser Hist
% if ~isinf(FirstLaser)
% OneUnitHistStructTimeLim(UnitStruct(n).LaserON, n, UnitStruct, -.1, .1, .001, [0 inf], 'k', 1);
% end
% FormatFigure
% ylabel('Hz')
% xlabel('msec')
% L = get(gca,'XLim');
% set(gca,'XTick',linspace(L(1), L(2), 5));
% %set(gca,'XTick',linspace(TrigMin, TrigMax, 6))
% xl = xticklabels;
% MSlabels = Sec2ms(xl);
% xticklabels(MSlabels);

% nexttile %Laser Raster
% if ~isinf(FirstLaser)
% RasterMatrix = OrganizeRasterSpikesNew(UnitStruct, UnitStruct(n).LaserON, n, .1, .1);
% xlim([-.1 .1]);
% hold on
% for i = 1:length(UnitStruct(n).LaserOFF)
% plot(UnitStruct(n).LaserOFF(i)-UnitStruct(n).LaserON(i), i-.5, 'b.');
% end
% xline(0, 'b.')%, 'Label', 'Laser ON');
% end
% FormatFigure
% ylabel('Hz')
% xlabel('msec')
% L = get(gca,'XLim');
% set(gca,'XTick',linspace(L(1), L(2), 5));
% %set(gca,'XTick',linspace(TrigMin, TrigMax, 6))
% xl = xticklabels;
% MSlabels = Sec2ms(xl);
% xticklabels(MSlabels);
% f.WindowState = 'maximized';


%IDinfo = strsplit(UnitStruct(n).Identification,'_');
saveas(gca, [num2str(UnitStruct(n).unitID) nametag])
print([num2str(UnitStruct(n).unitID) nametag], '-dpdf', '-painters');