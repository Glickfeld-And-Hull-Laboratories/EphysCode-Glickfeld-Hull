function [FR, WF, wfStructStruct] = CellCharWorkupDrugStruct_uhd(unit, struct, trigger, TimeGridA, TimeGridB, xmin, xmax, TrigMin, TrigMax, TimeLim1, TimeLim2, DrugLinesStruct, ISIxaxis, binsize, color, nametag, map)
%unit = unit number, struct = GoodUnitStruct or similar, trigger = laser,
%TimeGridA = start of analysis period, TimeGridB = end of analysis period, 
%TGlim1WFs, TGlim2WFs, StimWFs are all controlled by boolians and may have
%to be ~ed out

TimeShowStart = 0;
TimeShowEnd = inf;
psth = 1; %(if you want psth on or not)
raster = 1; %(if you want raster on or not)
doublechart = 1; %(if you want to replot stats for TimeLim2condition)
color2 = 'm'; %color for doublechart
WFpanel = 1;
MultiChanWFboo = 1;
%laserStimWF = 1;
laserStimOverlay = 1;
DrugOverlayMulti = 1;
laserStimOverlayMulti = 1;
StimTimeWin = .01;
extraHist = 0;
AmpHist = 1;
DrugLines = 1;
   for d = 1:length(DrugLinesStruct)
       DrugLinesStruct(d).Trial = length(trigger(trigger<DrugLinesStruct(d).time));
   end
psthLick = 0;
psthWater = 0;
rasterWater = 0;
AxisAdjust = 1;
RawChannel = 1;
ExtraRawChannels = 0;
EventStructBoo = 1;
    
%set y-axis
%ylimON = 0; %(0 or 1 if you want the ylimits on or not);

JuiceMin = -2;
JuiceMax = 3;
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
unitIN = find([struct.unitID] == unit)
channel = struct(unitIN).channel
channelStr = num2str(struct(unitIN).channel);
TimeLimStart = num2str(TimeLim1(1));
TimeLimEnd = num2str(TimeLim1(2));
if ~isnan(TimeLim2)
title_ = [unitStr ' fires at ' FRstr ' on channel ' channelStr ' baseline [' TimeLimStart ' ' TimeLimEnd '] drugComp [' num2str(TimeLim2(1)) ' ' num2str(TimeLim2(2)) '] ' nametag];
else
title_ = [unitStr ' fires at ' FRstr ' on channel ' channelStr ' baseline [' TimeLimStart ' ' TimeLimEnd '] ' nametag];
end
%title(title_)
f = figure;
%%%%%%%%

%%%%

set(gcf,'Position',[0 0 1100 850]);
layout1 = tiledlayout(3,4);
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
xline(trigger(1), 'b', 'Label', 'FirstLaser');
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
FormatFigure(NaN,NaN);
%end FR panel





%WFpanel
if WFpanel == 1
nexttile;
%[time, WF, ~] = SampleWaveformsTimeLimNew(struct, .003, 100, TimeLim, unit, channel);
[time, WF, ~] = SampleWaveformsTimeLimTGzerogo(TimeGridA, TimeGridB, struct, .003, 100, TimeLim1, unit, channel, 1);
title('Non-stim WF')
ylabel('V');
xlabel('msec');
if ~isnan(ylimitWF1)
ylim(ylimitWF1);
end
hold on
plot([0;.001], [0;0], color2);
hold off;
FormatFigure(NaN,NaN);
%end WF panel

%LaserStimOverlay
if laserStimOverlay == 1
    if ~isnan(TimeLim2(1))
[time, WF_postTG, ~] = SampleWaveformsTimeLimTGzerogo(TimeGridA, TimeGridB, struct, .003, 100, TimeLim2, unit, channel, 0);
[time, WF_post, ~] = SampleWaveformsTimeLimNewzerogo(struct, .003, 100, TimeLim2, unit, channel, 0);
    end
[time, WF_stim, ~] = SampleWaveformsTimeLimTGzerogo(TimeGridB, TimeGridB+.005, struct, .003, 100, TimeLim1, unit, channel, 0);
hold off
title('DrugTG Y, StimPre B, ')
ylabel('V');
xlabel('msec');
   if ~isnan(TimeLim2(1))
AvgWvF_preTG = avgeWaveforms(WF);
AvgWvF_postTG = avgeWaveforms(WF_postTG);
   end
%AvgWvF_post = avgeWaveforms(WF_post);
AvgWvF_stim = avgeWaveforms(WF_stim);

hold on
    if ~isnan(TimeLim2(1))
plot(time, AvgWvF_preTG, 'r', 'LineWidth', 2);
plot(time, AvgWvF_postTG, 'y', 'LineWidth', 2);
    end
%plot(time, AvgWvF_post, 'y');
plot(time, AvgWvF_stim, 'b', 'LineWidth', 2);

hold off
if ~isnan(ylimitWF2)
ylim(ylimitWF2);
end
FormatFigure(NaN,NaN);
end
 if laserStimOverlay == 0
     WF_post = 0;
     WF_postTG = 0;
     AvgWvF_postTG = 0;
 end
end
%end StimWF panel

%MulitChanWF panel
if MultiChanWFboo == 1
    nexttile([2 2]);
    hold on
[time, WF, TGlim1WFs, Scale] = MultiChanWF_uhd(struct, .003, .001, 100, TimeLim1, TimeGridA, TimeGridB, unit, map, 'k', 0, 1, NaN);
end

if DrugOverlayMulti == 1
    if ~isnan(TimeLim2)
        hold on
[~, ~, TGlim2WFs, ~] = MultiChanWF_uhd(struct, .003, .001, 100, TimeLim2, TimeGridA, TimeGridB, unit, map, color2, 0, 1, Scale);
%[~, ~, Lim2Wfs, wfSampSize, ~] = MultiChanWF(struct, .003, 100, TimeLim2, NaN, NaN, unit, map, 'g', 0, 1, Scale);
    for n = length(TGlim2WFs)
     plot(time+TGlim2WFs(n).X/1000, TGlim2WFs(n).AvgWf + TGlim2WFs(n).Y * TGlim2WFs(n).Scale /10, color2);
  
    end

    end
end
 if laserStimOverlayMulti == 1
     [~, ~, StimWFs, ~] = MultiChanWF_uhd(struct, .003, .001, 100, TimeLim1, TimeGridB, TimeGridB+StimTimeWin, unit, map, 'b', 0, 1, Scale);
     hold on
     for n = length(StimWFs)
     plot(time+StimWFs(n).X/1000, StimWFs(n).AvgWf + StimWFs(n).Y * StimWFs(n).Scale/10, 'b');
    end


 for n = length(TGlim1WFs)
    plot(time+TGlim1WFs(n).X/1000, TGlim1WFs(n).AvgWf + TGlim1WFs(n).Y * TGlim1WFs(n).Scale/10, 'k');
    end

 end
hold off


%end MulitChanWF panel

%ISI panel
nexttile;
ISIstructTimeGridTimeLim(TimeGridA, TimeGridB, struct, unit, ISIxaxis, TimeLim1, binsize, color, 1, 0.5);
hold on
if doublechart == 1
    ISIstructTimeGridTimeLim(TimeGridA, TimeGridB, struct, unit, ISIxaxis, TimeLim2, binsize, color2, 1, .5);
end
title('Baseline ISI')
ylabel('Hz');
xlabel('msec');
if ~isnan(ylimitISI)
ylim(ylimitISI);
end
FormatFigure(NaN,NaN);
set(gca,'XTick',linspace(ISIxaxis(1),ISIxaxis(2),4));
xl = xticklabels;
MSlabels = Sec2ms(xl);
xticklabels(MSlabels);
%end ISI panel



%ACG panel
nexttile;
%autoCorrStructNewLimitsTG(TimeGridA, TimeGridB, struct, xmin, xmax, binsize, unit, TimeLim1, color, 1);
hold on
    autoCorrStructNewLimitsTG(TimeGridA, TimeGridB, struct, xmin, xmax, binsize, unit, TimeLim1, color, 1);
if doublechart == 1
    autoCorrStructNewLimitsTG(TimeGridA, TimeGridB, struct, xmin, xmax, binsize, unit, TimeLim2, color2, .5);
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
FormatFigure(NaN,NaN);
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
%FormatFigure(NaN,NaN);
%end
%title('TLim2 m, TLim1 y')
% if laserStimWF == 0
%     WF_post = 0;
% end
%end StimWF panel


% extraHist panel
if extraHist == 1
nexttile
OneUnitHistStructTimeLim(trigger, unit, struct, TrigMin, TrigMax, binsize, TimeLim1, color, 1);
hold on
if doublechart == 1
    OneUnitHistStructTimeLim(trigger, unit, struct, TrigMin, TrigMax, binsize, TimeLim2, color2, .5);
end
title('Spikes')
ylabel('Hz');
xlabel('sec');
xline(0, 'b', 'LineWidth', 2, 'Label', 'Laser');
if ~isnan(ylimitResp)
ylim(ylimitResp);
end
%yline(130, 'r');
FormatFigure(NaN,NaN);
end
%end extraHist panel

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
[TraceData, reporter] = LongTraceRead([trigger(trial)+TrigMin, trigger(trial)+TrigMax], unit, struct, ChansFromChan);
 AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, unit, ChansFromChan, 'm');
  %AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, 234, 1, 'y');
 xline(trigger(trial), 'b', 'LineWidth', 2, 'Label', 'Laser');
  hold on
 p = plot([trigger(trial)-.05; trigger(trial)], [-.0001;-.0001], 'b');
    p.LineWidth = 2;
    text( trigger(trial)-.04, -.00012, '50 ms', 'Color', 'blue');
 title(['ch ' num2str(struct(unitIN).channel)]);
 if ~isnan(ylimitTrace)
   ylim(ylimitTrace);
 end
 FormatFigure(NaN,NaN);

%PSTH panel Laser
if psth ==  1
nexttile
OneUnitHistStructTimeLim(trigger, unit, struct, TrigMin, TrigMax, binsize, TimeLim1, 4, color, 1, 1);
hold on
if doublechart == 1
    OneUnitHistStructTimeLim(trigger, unit, struct, TrigMin, TrigMax, binsize, TimeLim2, 4, color2, .7, 0);
end
title('Resp To Laser');
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
FormatFigure(NaN,NaN);
end
%end PSTH panel

%raster panel (Laser)
if raster == 1
nexttile
RasterMatrix = OrganizeRasterSpikesNew(struct, trigger, unit, -(TrigMin), TrigMax, color);
title('Resp to Laser');
ylabel('Trial');
xlabel('msec');

if DrugLines == 1
    for d = 1:length(DrugLinesStruct)
    yline(DrugLinesStruct(d).Trial, 'r', 'LineWidth', 2, 'Label', DrugLinesStruct(d).Name);
    end
end

lineACSF = 48;
lineBlocker1 = 70;
lineBlocker2 = 255;
lineBlocker3 = 242;
lineBlocker4 = 299;
LaserPower5 = 335;
LaserPower10 = 366;
    
    %yline(lineACSF, '2230');
    %yline(lineBlocker1, 'r');
    %yline(lineBlocker2, 'r', 'LineWidth', 2, 'Label', 'Exc blockers');
    %yline(lineBlocker3, 'r');
    %yline(lineBlocker4, 'r');
    %yline(LaserPower5, 'm');
    %yline(LaserPower10, 'g');
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
FormatFigure(NaN,NaN);

end
%end raster panel




%licking PSTH
if psthLick == 1
    nexttile
    OneUnitHistStructTimeLim(LickTimes, unit, struct, JuiceMin, JuiceMax, JuiceBin, [JuiceTimes(1)-5, JuiceTimes(end)+10], color, 1);
hold on
%if doublechart == 1
%    OneUnitHistStructTimeLim(trigger, unit, struct, TrigMin, TrigMax, binsize, TimeLim2, color2);
%end
title('Resp to First Lick');
ylabel('Hz');
xlabel('sec');
xline(0, 'y', 'LineWidth', 2);
if ~isnan(ylimitJuice)
ylim(ylimitJuice);
end
%yline(130, 'r');
FormatFigure(NaN,NaN);
end

%PSTH water tile
if psthWater == 1
    nexttile
    OneUnitHistStructTimeLim(JuiceTimes, unit, struct, JuiceMin, JuiceMax, JuiceBin, [JuiceTimes(1)-5, JuiceTimes(end)+10], 4, color, 1, 1);
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
FormatFigure(NaN,NaN);
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
FormatFigure(NaN,NaN);
end



if ExtraRawChannels ==1
 nexttile
 ChansFromChan = -1;
[TraceData, reporter] = LongTraceRead([trigger(trial)+TrigMin, trigger(trial)+TrigMax], unit, struct, ChansFromChan);
 AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, unit, ChansFromChan, 'm');
 %AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, 234, 2, 'y');
  xline(trigger(trial), 'b', 'LineWidth', 2);
   hold on
  plot([trigger(trial); trigger(trial)+.1], [0;0], 'b', 'LineWidth', 2);
   title(num2str(ChansFromChan));
    if ~isnan(ylimitTrace)
   ylim(ylimitTrace);
   end
   
 nexttile
 ChansFromChan = -2;
[TraceData, reporter] = LongTraceRead([trigger(trial)+TrigMin, trigger(trial)+TrigMax], unit, struct, ChansFromChan);
 AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, unit, ChansFromChan, 'm');
 %AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, 234, 0, 'y');
  xline(trigger(trial), 'b');
  hold on
plot([trigger(trial); trigger(trial)+.1], [0;0], 'b', 'LineWidth', 2);
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
wfStructStruct.StimTimeWin =StimTimeWin;
wfStructStruct.StimWFs = StimWFs;
wfStructStruct.time = time;



saveas(gca, [unitStr nametag]);
%%print([unitStr nametag], '-dpdf')%, '-painters');
print(['ch ' channelStr 'un ' unitStr nametag], '-depsc', '-painters');
f.PaperPositionMode = 'manual';
f.PaperUnits = 'points';
f.PaperSize = [1100 850];
print(nametag, '-dpsc', '-bestfit', '-append');


%set(gcf, 'Renderer', 'zbuffer');
%saveas(gca, [unitStr nametag '.eps'], 'epsc')

%p = uipanel(f);
%p.Title = 'title';
end



