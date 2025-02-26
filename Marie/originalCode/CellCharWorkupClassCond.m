function [FR, WF, wfStructStruct] = CellCharWorkupClassCond(unit, struct, acg_xaxis, acg_binsize, ISIxaxis, trigger1, trigger1_Name, trigger1_xaxis, trigger1_binsize, color, nametag,  trigger2, trigger2_Name, trigger2_xaxis, trigger2_binsize, LickTimes, LickEpochOnsets, RTs, JuiceBin, TimeLim1, TimeLim2, map)
%unit = unit number, struct = GoodUnitStruct or similar, trigger = laser,
%TimeGridA = start of analysis period, TimeGridB = end of analysis period, 
%TGlim1WFs, TGlim2WFs, StimWFs are all controlled by boolians and may have
%to be ~ed out

SD = 3;
TG = 0;
if TG == 0
       TimeGridA = NaN;
       TimeGridB = NaN;
end
xmin = acg_xaxis(1);
xmax = acg_xaxis(2);
%TimeLim1 = [0 inf];
%TimeLim2 = [NaN NaN]; %getting out of the way from old code
TrigMin = trigger1_xaxis(1);
TrigMax = trigger1_xaxis(2);
TimeShowStart = 0;
TimeShowEnd = inf;
psth = 1; %(if you want psth on or not)
raster = 1; %(if you want raster on or not)
doublechart = 1; %(if you want to replot stats for TimeLim2condition)
color2 = 'm'; %color for doublechart
WFpanel = 1;
MultiChanWFboo = 1;
%laserStimWF = 1;


%StimTimeWin = .01;
Hist2 = 1;
Hist3 = 1;
Hist4 = 1;
AmpHist = 1;
DrugLines = 0;
  
psthLickEpochOnset = 1;
psthWater = 0;
rasterWater = 0;
AxisAdjust = 1;
RawChannel = 1;
ExtraRawChannels = 0;
    
%set y-axis
%ylimON = 0; %(0 or 1 if you want the ylimits on or not);

JuiceMin = -1;
JuiceMax = 5;
ylimitACG = NaN;
ylimitISI = NaN;
ylimitWF1 = NaN;
ylimitWF2 = ylimitWF1;
ylimitFR = NaN;
ylimitResp = NaN;
ylimitTrace = NaN;
ylimitJuice = NaN;



FR = FRstructTimeGridTimeLimit(TimeGridA, TimeGridB, TimeLim1, struct, unit, color, 0);
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
if ~isnan(TimeLim2)
title_ = [unitStr ' fires at ' FRstr ' on channel ' channelStr ' baseline [' TimeLimStart ' ' TimeLimEnd '] drugComp [' num2str(TimeLim2(1)) ' ' num2str(TimeLim2(2)) '] ' nametag];
else
title_ = [unitStr ' fires at ' FRstr ' on channel ' channelStr ' baseline '  TimeLimStart ' ' TimeLimEnd ' ' nametag];
end
%title(title_)
f = figure;
%%%%%%%%
channel = channel;
%%%%

set(gcf,'Position',[0 0 2000 800]);
layout1 = tiledlayout(2,6);
%fprintf('fig?')

%t.Title.String = title_;
title(layout1, title_, 'FontSize', 22, 'FontName', 'Arial', 'FontWeight', 'bold');

 %Tile1
%FR panel
nexttile 
fr= FRstruct(unit, struct, 1, 'k', 1);
title('FR')
ylabel('Hz');
xlabel('sec');

    if DrugLines == 1
        for d = 1:length(DrugLinesStruct)
        xline(DrugLinesStruct(d).time, 'r', 'LineWidth', 2, 'Label', DrugLinesStruct(d).Name);
        end
    end    
xline(trigger1(1), 'b', 'Label', ['First' trigger1_Name]);
%xline(TimeLim1(1), 'b');
%xline(TimeLim1(2), 'b');
%xline(5019, 'r', 'LineWidth', 2, 'Label', 'Exc blockers');
%xline(TimeLim2(1), 'm');
%xline(TimeLim2(2), 'm');

%if ~isnan(TimeLim2) %This section will end FR graph at end of TimeLim2
    %timeEnd = TimeLim2(2)-30;
%else
    %timeEnd = TimeLim1(2)-30;
%end
%or we can just plot the whole recording
timeStart = TimeShowStart;
timeEnd = TimeShowEnd;
xlim([timeStart timeEnd]);
if ~isnan(ylimitFR)
ylim(ylimitFR);
end
FormatFigure
%end FR panel





%WFpanel
if WFpanel == 1
nexttile;
if TG == 1
[time, WF, ~] = SampleWaveformsTimeLimTGzerogo(TimeGridA, TimeGridB, struct, .003, 100, TimeLim1, unit, channel, 1);
else
    [time, WF, ~] = SampleWaveformsTimeLimNewzerogo(struct, .003, 100, TimeLim1, unit, channel, 1);
end

title('Non-stim WF')
ylabel('V');
xlabel('msec');
if ~isnan(ylimitWF1)
ylim(ylimitWF1);
end
hold on
plot([0;.001], [0;0], color2);
FormatFigure;
ylabel('V');
xlabel('msec');
AvgWvF = avgeWaveforms(WF);
plot(time, AvgWvF, 'r', 'LineWidth', 2);
hold off
if ~isnan(ylimitWF2)
ylim(ylimitWF2);
end
FormatFigure
end
%end WF panel

%MulitChanWF panel
if MultiChanWFboo == 1
    nexttile;
    hold on
   
[time, WF, TGlim1WFs, Scale] = MultiChanWF(struct, .003, .001, 100, TimeLim1, TimeGridA, TimeGridB, unit, map, 'k', 0, 1, NaN);
end


hold off


%end MulitChanWF panel

%ISI panel
nexttile;
if TG == 1
ISIstructTimeLim(TimeGridA, TimeGridB, struct, unit, ISIxaxis, TimeLim1, acg_binsize, color, .5, 1);
hold on
if doublechart == 1
    ISIstructTimeGridTimeLim(TimeGridA, TimeGridB, struct, unit, ISIxaxis, TimeLim2, binsize, color2, .5);
end
else
ISIstructTimeLim(struct, unit, ISIxaxis, TimeLim1, acg_binsize, color, 0.5, 1);
end
title('Baseline ISI')
ylabel('Hz');
xlabel('msec');
if ~isnan(ylimitISI)
ylim(ylimitISI);
end
FormatFigure;
set(gca,'XTick',linspace(ISIxaxis(1),ISIxaxis(2),4));
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);
%end ISI panel



%ACG panel
nexttile;
autoCorrStructNewLimitsTG(TimeGridA, TimeGridB, struct, xmin, xmax, acg_binsize, unit, TimeLim1, color, 1);
hold on
if doublechart == 1
    autoCorrStructNewLimitsTG(TimeGridA, TimeGridB, struct, xmin, xmax, acg_binsize, unit, TimeLim2, color2, .5);
end 
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


%LaserStimWFpanel
%actually post-drug WF, I don't think we need this now
%if laserStimWF == 1
%nexttile
%[time, WF_postTG, ~] = SampleWaveformsTimeLimTG(TimeGridA, TimeGridB, struct, .003, 100, TimeLim2, unit, channel);
%%[time, WF_post, ~] = SampleWaveformsTimeLimNew(struct, .003, 100, TimeLim2, unit, channel);
%hold off
%title('All WF')
%ylabel('V');
%xlabel('msec');
%AvgWvF = avgeWaveforms(WF);
%AvgWvF_postTG = avgeWaveforms(WF_postTG);

%%figure
%hold on
%plot(time, AvgWvF, 'y');
%plot(time, AvgWvF_postTG, 'm');
%hold off
%if ~isnan(ylimitWF2)
%ylim(ylimitWF2);
%end
%FormatFigure
%end
%title('TLim2 m, TLim1 y')
% if laserStimWF == 0
%     WF_post = 0;
% end
%end StimWF panel




%ampHis Panel

if AmpHist == 1
    nexttile
    AmplitudeHistNew(unit, struct, [timeStart timeEnd], color)
    title('Amplitude');
    
    if DrugLines == 1
        for d = 1:length(DrugLinesStruct)
        xline(DrugLinesStruct(d).time, 'r', 'LineWidth', 2, 'Label', DrugLinesStruct(d).Name);
        end
    end
    
end
% end AmpHist Panel
%
%layout2 = tiledlayout(layout1,1,3);
%layout2.Layout.Tile = 7;
%To make the nested layout span multiple tiles, specify the TileSpan property as a two-element vector. For example, this code spans layout2 across one row and two columns of tiles.

if RawChannel ==1
nexttile
%layout1.Layout.TileSpan = [1 3];
%plot(trigger);
trial = 20; %which laser stimulation trial to use for the trace
fprintf(['For unit ' unitStr 'Laser trial' num2str(trial)]);
ChansFromChan = 0;
[TraceData, reporter] = LongTraceRead([trigger1(trial)+TrigMin, trigger1(trial)+TrigMax], unit, struct, ChansFromChan);
 AddUnitToTrace ([trigger1(trial)+TrigMin, trigger1(trial)+TrigMax], struct, unit, ChansFromChan, 'm');
  %AddUnitToTrace ([trigger1(trial)+TrigMin, trigger1(trial)+TrigMax], struct, 234, 1, 'y');
 xline(trigger1(trial), 'b', 'LineWidth', 2, 'Label', 'Laser');
  hold on
 p = plot([trigger1(trial)-.05; trigger1(trial)], [-.0001;-.0001], 'b');
    p.LineWidth = 2;
    text( trigger1(trial)-.04, -.00012, '50 ms', 'Color', 'blue');
 title(['ch ' num2str(struct(unitIN).channel)]);
 if ~isnan(ylimitTrace)
   ylim(ylimitTrace);
 end
 FormatFigure

%PSTH panel 1
if psth ==  1
nexttile
OneUnitHistStructTimeLim(trigger1, unit, struct, TrigMin, TrigMax, trigger1_binsize, TimeLim1, 4, color, 1, 1);
hold on
if doublechart == 1
    OneUnitHistStructTimeLim(trigger1, unit, struct, TrigMin, TrigMax, trigger1_binsize, TimeLim2, 4, color2, .7, 0);
end
title(trigger1_Name);
ylabel('Hz');
xlabel('msec');
xline(0, 'b', 'LineWidth', 2);
if ~isnan(ylimitResp)
ylim(ylimitResp);
end
%yline(130, 'r');
set(gca,'XTick',linspace(TrigMin, TrigMax,5));
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);
FormatFigure
end
%end PSTH panel

%raster panel (Laser)
if raster == 1
nexttile
RasterMatrix = OrganizeRasterSpikesNew(struct, trigger1, unit, -(TrigMin), TrigMax, color);
title(trigger1_Name);
ylabel('Trial');
xlabel('msec');

if DrugLines == 1
    for d = 1:length(DrugLinesStruct)
    yline(DrugLinesStruct(d).Trial, 'r', 'LineWidth', 2, 'Label', DrugLinesStruct(d).Name);
    end
end
    xline(0, 'b', 'LineWidth', 2);
    
%L = get(gca,'XLim');
%set(gca,'XTick',linspace(L(1), L(2), 5))
xlim([TrigMin TrigMax]);
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1), L(2), 5));
%set(gca,'XTick',linspace(TrigMin, TrigMax, 6))
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);
FormatFigure;

end
%end raster panel




%licking PSTH
if psthLickEpochOnset == 1
    nexttile
    OneUnitHistStructTimeLim(LickEpochOnsets, unit, struct, -.5, 2, .005, TimeLim1, SD, color, 0.5, 0);
hold on
%if doublechart == 1
%    OneUnitHistStructTimeLim(trigger, unit, struct, TrigMin, TrigMax, binsize, TimeLim2, color2);
%end
title('Lick PSTH');
ylabel('Hz');
xlabel('sec');
xline(0, 'y', 'LineWidth', 2);
if ~isnan(ylimitJuice)
ylim(ylimitJuice);
end
%yline(130, 'r');
FormatFigure
end

%PSTH water tile
if psthWater == 1
    nexttile
    OneUnitHistStructTimeLim(JuiceTimes, unit, struct, JuiceMin, JuiceMax, JuiceBin, [JuiceTimes(1)-5, JuiceTimes(end)+10], color, 1);
hold on
%if doublechart == 1
%    OneUnitHistStructTimeLim(trigger, unit, struct, TrigMin, TrigMax, binsize, TimeLim2, color2);
%end
title('Resp to Juice')
ylabel('Hz');
xlabel('sec');
xline(0, 'c', 'LineWidth', 2);
if ~isnan(ylimitJuice)
ylim(ylimitJuice);
end
%yline(130, 'r');
FormatFigure
end

%RasterWater with lick lines by response time
if rasterWater == 1
  nexttile
  [B,I] = sort(RTs);
JuiceByReaction = JuiceTimes(I);
RasterMatrix = OrganizeRasterSpikesNew(struct, JuiceByReaction-.699, unit, -JuiceMin, JuiceMax);
title('Resp to Water by RT');
ylabel('Trial by Reaction Time');
xlabel('sec');
hold on
trials = [1:length(JuiceByReaction)];
plot(B,trials, 'g');
xline(0, 'g', 'LineWidth', 2);
xline(.698, 'c', 'LineWidth', 2);
FormatFigure
end

% extraHist panel
if Hist2 == 1
nexttile
OneUnitHistStructTimeLim(trigger2, unit, struct, TrigMin, TrigMax, trigger2_binsize, TimeLim1, 4, color, 1, 1);
hold on
if doublechart == 1
    OneUnitHistStructTimeLim(trigger2, unit, struct, TrigMin, TrigMax, trigger2_binsize, TimeLim2, color2, .5);
end
title('trigger2_Name')
ylabel('Hz');
xlabel('sec');
xline(0, 'b', 'LineWidth', 2);
if ~isnan(ylimitResp)
ylim(ylimitResp);
end
%yline(130, 'r');
FormatFigure

%raster for trigger 2
nexttile
RasterMatrix = OrganizeRasterSpikesNew(struct, trigger2, unit, trigger2_xaxis(1), trigger2_xaxis(2), color);
title('trigger2_Name');
ylabel('Trial');
xlabel('msec');

xlim(trigger2_xaxis);
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1), L(2), 5));
%set(gca,'XTick',linspace(TrigMin, TrigMax, 6))
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);
FormatFigure;
end
%end extraHist panel

if Hist3 == 1
nexttile
OneUnitHistStructTimeLim(trigger3, unit, struct, TrigMin, TrigMax, trigger3_binsize, TimeLim1, 4, color, 1, 1);
hold on
if doublechart == 1
    OneUnitHistStructTimeLim(trigger3, unit, struct, TrigMin, TrigMax, trigger3_binsize, TimeLim2, color2, .5);
end
title('Spikes')
ylabel('Hz');
xlabel('sec');
xline(0, 'b', 'LineWidth', 2);
if ~isnan(ylimitResp)
ylim(ylimitResp);
end
%yline(130, 'r');
FormatFigure

%raster for trigger3
nexttile
RasterMatrix = OrganizeRasterSpikesNew(struct, trigger3, unit, trigger3_xaxis(1), trigger2_xaxis(2), color);
title('trigger3_Name');
ylabel('Trial');
xlabel('msec');

xlim(trigger3_xaxis);
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1), L(2), 5));
%set(gca,'XTick',linspace(TrigMin, TrigMax, 6))
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);
FormatFigure;
end

if Hist4 == 1
nexttile
OneUnitHistStructTimeLim(trigger4, unit, struct, TrigMin, TrigMax, trigger4_binsize, TimeLim1, 4, color, 1, 1);
hold on
if doublechart == 1
    OneUnitHistStructTimeLim(trigger4, unit, struct, TrigMin, TrigMax, trigger4_binsize, TimeLim2, color2, .5);
end
title('Spikes')
ylabel('Hz');
xlabel('sec');
xline(0, 'b', 'LineWidth', 2);
if ~isnan(ylimitResp)
ylim(ylimitResp);
end
%yline(130, 'r');
FormatFigure

%trigger 4 raster
nexttile
RasterMatrix = OrganizeRasterSpikesNew(struct, trigger4, unit, trigger4_xaxis(1), trigger2_xaxis(2), color);
title('trigger4_Name');
ylabel('Trial');
xlabel('msec');

xlim(trigger4_xaxis);
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1), L(2), 5));
%set(gca,'XTick',linspace(TrigMin, TrigMax, 6))
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);
FormatFigure;
end

if ExtraRawChannels ==1
 nexttile
 ChansFromChan = -1;
[TraceData, reporter] = LongTraceRead([trigger1(trial)+TrigMin, trigger1(trial)+TrigMax], unit, struct, ChansFromChan);
 AddUnitToTrace ([trigger1(trial)+TrigMin, trigger1(trial)+TrigMax], struct, unit, ChansFromChan, 'm');
 %AddUnitToTrace ([trigger1(trial)+TrigMin, trigger1(trial)+TrigMax], struct, 234, 2, 'y');
  xline(trigger1(trial), 'b', 'LineWidth', 2);
   hold on
  plot([trigger1(trial); trigger1(trial)+.1], [0;0], 'b', 'LineWidth', 2);
   title(num2str(ChansFromChan));
    if ~isnan(ylimitTrace)
   ylim(ylimitTrace);
   end
   
 nexttile
 ChansFromChan = -2;
[TraceData, reporter] = LongTraceRead([trigger1(trial)+TrigMin, trigger1(trial)+TrigMax], unit, struct, ChansFromChan);
 AddUnitToTrace ([trigger1(trial)+TrigMin, trigger1(trial)+TrigMax], struct, unit, ChansFromChan, 'm');
 %AddUnitToTrace ([trigger1(trial)+TrigMin, trigger1(trial)+TrigMax], struct, 234, 0, 'y');
  xline(trigger1(trial), 'b');
  hold on
plot([trigger1(trial); trigger1(trial)+.1], [0;0], 'b', 'LineWidth', 2);
   title(num2str(ChansFromChan));
   if ~isnan(ylimitTrace)
   ylim(ylimitTrace);
   end
end


wfStructStruct.unit = unit;
wfStructStruct.Lim1 = TimeLim1;
wfStructStruct.TGlim1WFs = TGlim1WFs;
if ~isnan(TimeLim2(1))
wfStructStruct.Lim2 = TimeLim2;
wfStructStruct.TGlim2WFs = TGlim2WFs;
end
%wfStructStruct.StimTimeWin =StimTimeWin;
%wfStructStruct.StimWFs = StimWFs;
wfStructStruct.time = time;



saveas(gca, [unitStr nametag]);
%%print([unitStr nametag], '-dpdf')%, '-painters');
print(['ch ' channelStr 'un ' unitStr nametag], '-depsc', '-painters');
f.PaperPositionMode = 'manual';
f.PaperUnits = 'points';
f.PaperSize = [2100 860];
print(nametag, '-dpsc', '-bestfit', '-append');


%set(gcf, 'Renderer', 'zbuffer');
%saveas(gca, [unitStr nametag '.eps'], 'epsc')

%p = uipanel(f);
%p.Title = 'title';
end



