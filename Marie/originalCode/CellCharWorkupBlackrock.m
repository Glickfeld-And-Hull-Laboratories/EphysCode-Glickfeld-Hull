function CellCharWorkupBlackrock(UnitStruct, unit, nametag)

n = find([UnitStruct.unitID] == unit);

if isnan(UnitStruct(n).LaserON)
    FirstLaser = inf;
else
    FirstLaser = UnitStruct(n).LaserON(1);
end
f = figure;
FR = FRstructLimits(UnitStruct, 1, [0 FirstLaser], UnitStruct(n).unitID);
title_ = ['Unit ' num2str(UnitStruct(n).unitID) UnitStruct(n).group ' from ' UnitStruct(n).Indentification ' at ' num2str(UnitStruct(n).depth) ' fires at ' num2str(FR) ' Hz SNR:' num2str(UnitStruct(n).snr)];
layout1 = tiledlayout(3,3);
title(layout1, title_, 'FontSize', 30, 'FontName', 'Arial', 'FontWeight', 'bold');

nexttile %FR tile
FRstruct(n, UnitStruct, 1, 'k', 1);
if ~isinf(FirstLaser)
    for i = 1:length(UnitStruct(n).LaserON)
        xline(UnitStruct(n).LaserON(i), 'b');
    end
ylabel('Hz');
xlabel('sec');
%xline(FirstLaser, 'b', 'Label', 'First Laser');
%xline(UnitStruct(n).LaserON(end), 'b', 'Label', 'Last Laser');
end

nexttile % template tile
plot(UnitStruct(n).template);
title('Template');
xlabel('msec');
FormatFigure;

nexttile % Mean WF tile
AvgWaveformBlackRockTimeLim(UnitStruct(n).RawData, [0 inf], UnitStruct(n).timestamps, 100, 'k', 'r', 1);
if ~isnan(UnitStruct(n).LaserON)
AvgWaveformBlackRockTimeLimTG(UnitStruct(n).LaserON, UnitStruct(n).LaserOFF+.005, UnitStruct(n).RawData, [0 inf], UnitStruct(n).timestamps, 100, 'k', 'c', 0);
end
xlabel('msec');
FormatFigure;

nexttile %ACG tile basic
autoCorrStructNewLimits(UnitStruct, -.1, .1, .001, n, [0 UnitStruct(n).LaserON(1)], 'k');

nexttile %ACG tile Zoom
autoCorrStructNewLimits(UnitStruct, -.05, .05, .0005, n, [0 UnitStruct(n).LaserON(1)], 'k');
FormatFigure;
ylabel('Hz');
xlabel('msec');
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1), L(2), 5))
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);



nexttile %ACG tile w. laser included
autoCorrStructNewLimits(UnitStruct, -.05, .05, .0005, n, [0 inf], 'k');
FormatFigure
ylabel('Hz')
xlabel('msec')
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1), L(2), 5));
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);


nexttile %Amps
AmpsBlackRock(UnitStruct(n).RawData, [0 inf], UnitStruct(n).timestamps, 'k');
FormatFigure;
title('Raw Amplitudes');

nexttile %Resp to Laser Hist
if ~isinf(FirstLaser)
OneUnitHistStructTimeLim(UnitStruct(n).LaserON, n, UnitStruct, -.1, .1, .001, [0 inf], 'k', 1);
end
FormatFigure
ylabel('Hz')
xlabel('msec')
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1), L(2), 5));
%set(gca,'XTick',linspace(TrigMin, TrigMax, 6))
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);

nexttile %Laser Raster
if ~isinf(FirstLaser)
RasterMatrix = OrganizeRasterSpikesNew(UnitStruct, UnitStruct(n).LaserON, n, .1, .1);
xlim([-.1 .1]);
hold on
for i = 1:length(UnitStruct(n).LaserOFF)
plot(UnitStruct(n).LaserOFF(i)-UnitStruct(n).LaserON(i), i-.5, 'b.');
end
xline(0, 'b.')%, 'Label', 'Laser ON');
end
FormatFigure
ylabel('Hz')
xlabel('msec')
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1), L(2), 5));
%set(gca,'XTick',linspace(TrigMin, TrigMax, 6))
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);
f.WindowState = 'maximized';


%IDinfo = strsplit(UnitStruct(n).Identification,'_');
saveas(gca, [UnitStruct(n).Indentification ' ' num2str(UnitStruct(n).unitID) nametag])
print([UnitStruct(n).Indentification ' ' num2str(UnitStruct(n).unitID) nametag], '-dpdf', '-painters');