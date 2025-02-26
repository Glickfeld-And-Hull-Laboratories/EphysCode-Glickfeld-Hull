function CellCharWorkupCSMLI(indexMLI, struct, xmin, xmax, TimeLim, TGA, TGB, binsize, Events1, Events2, Events3, EventTimeLim, EventBin, map)
%unit = unit number, struct = GoodUnitStruct or similar, trigger = laser,
%TimeGridA = start of analysis period, TimeGridB = end of analysis period, 
%TGlim1WFs, TGlim2WFs, StimWFs are all controlled by boolians and may have
%to be ~ed out

nametag = ['MLI_CS_2'];
if isnan(TimeLim)
    TimeLim = [0 inf];
end

TimeShowStart = 0;
TimeShowEnd = inf;
psth = 0; %(if you want psth on or not)
raster = 1; %(if you want raster on or not)
doublechart = 0; %(if you want to replot stats for TimeLim2condition)
MultiChanWFboo = 1;
SD = 6;

FR = FRstructTimeGridTimeLimitINDEX2(TGA, TGB, TimeLim, struct, indexMLI, 'k', 0, 1);
FRstr = num2str(round(FR,1));
unitStr = num2str(indexMLI);
channel = struct(indexMLI).channel;
channelStr = num2str(struct(indexMLI).channel);
TimeLimStart = num2str(TimeLim(1));
TimeLimEnd = num2str(TimeLim(2));
PhyllumLayer = struct(indexMLI).layer;
PC_dist = num2str(struct(indexMLI).PC_dist);
expertID = struct(indexMLI).MLIexpertID;

%find all nearby CS to this MLI in struct
counter = 1;
CS_list = [];
 for m = 1:length(struct)
        if struct(m).RecorNum == struct(indexMLI).RecorNum
        if Cell2CellDistINDEX(struct, m, indexMLI, map) < 200
        if strcmp(struct(m).CellType, 'CS')
            CS_list(counter) = m;
            counter = counter +1;
        end
        end
        end
 end



if TimeLim(1) == 0 & TimeLim(2) == inf
    title_ = [unitStr ' ' expertID 'ID ' FRstr 'sp/s on ' channelStr ' in ' PhyllumLayer ' ' PC_dist ' from PC' ];
else
title_ = [unitStr ' ' expertID 'ID ' FRstr 'sp/s on ' channelStr ' in ' PhyllumLayer ' ' PC_dist ' from PC during [' num2str(TimeLim(1)) ' ' num2str(TimeLim(2)) ']' ];
end
%title(title_)
f = figure;
%%%%%%%%

set(gcf,'Position',[0 0 2000 800]);
layout1 = tiledlayout('flow', 'TileSpacing', 'none', 'Padding', 'none');

title(layout1, title_, 'FontSize', 22, 'FontName', 'Arial', 'FontWeight', 'bold');

%FR panel
nexttile 
FR = FRstructTimeGridTimeLimitINDEX2(TGA, TGB, TimeLim, struct, indexMLI, 'k', 1, 1);
title('FR')
ylabel('Hz');
xlabel('sec');
if ~isnan(Events1)
xline(Events1(1), 'b', 'Label', 'FirstEvent1');
end
xlim([TimeShowStart TimeShowEnd]);
FormatFigure
%end FR panel

if isempty(CS_list)
nexttile;
    hold on
multiWFPlotterCompColors(struct, [indexMLI], [0, 0, 0], map)
axis off
end

 if ~isempty(CS_list)
parulaColors = colormap(parula(length(CS_list)));
%MulitChanWF & ccg panels
for m = 1:length(CS_list)
    nexttile;
    hold on
multiWFPlotterCompColors(struct, [indexMLI; CS_list(m)], [0, 0, 0; parulaColors(m,:)], map)
axis off
nexttile
hold on
[N, edges] = XcorrRateCorrect(struct, -.025, .025, .001, CS_list(m), indexMLI,  TGA, TGB, TimeLim(1), TimeLim(2), parulaColors(m,:), 1, SD, 0);
FormatFigure
end
 end
 
 %Event1 psth
    nexttile;
hold on
    for m = 1:length(CS_list)
        [N, edges, ~] = OneUnitHistStructTimeLimLineINDEX(Events1, CS_list(m), struct, EventTimeLim(1), EventTimeLim(2), EventBin, TimeLim, SD, parulaColors(m,:), NaN, 0, 0);
        yyaxis right
        plot(edges(1:end-1), N, 'Color', parulaColors(m,:), 'Marker', 'none', 'LineWidth', .5, 'LineStyle', '-')
    end
[N, edges, ~] = OneUnitHistStructTimeLimLineINDEX(Events1, indexMLI, struct, EventTimeLim(1), EventTimeLim(2), EventBin, TimeLim, SD,'k', NaN, 0, 0);
yyaxis left
plot(edges(1:end-1), N, 'k', 'LineWidth', .5)
xline(0, 'g');
xline(.682, 'c');
title('Tone/Juice resp')
xlabel('time from tone (s)')
ylabel ('Hz')

%Events1 with without CS
 nexttile;
hold on
    for m = 1:length(CS_list)
        if struct(indexMLI).RecorNum <9
            [TrialsSpike, TrialsNoSpike] = TrialsWith_outCS(Events1, struct, CS_list(m), [.65 .82]);
        else
            [TrialsSpike, TrialsNoSpike] = TrialsWith_outCS(Events1, struct, CS_list(m), [0 .25]);
        end
        [N_with, edges] =  OneUnitHistStructTimeLimLineINDEX(TrialsSpike, indexMLI, struct, -.5, 1.5, .1, [0 inf], SD,'m', NaN, 0, 0);
        [N_without, edges] =  OneUnitHistStructTimeLimLineINDEX(TrialsNoSpike, indexMLI, struct, -.5, 1.5, .1, [0 inf], SD,'m', NaN, 0, 0);
        plot(edges(1:end-1), N_with-N_without, 'Color', parulaColors(m,:))
    end

    
     %Event2 psth
    nexttile;
hold on
    for m = 1:length(CS_list)
        [N, edges, ~] = OneUnitHistStructTimeLimLineINDEX(Events2, CS_list(m), struct, -.75, 1, EventBin, TimeLim, SD, parulaColors(m,:), NaN, 0, 0);
        yyaxis right
        plot(edges(1:end-1), N, 'Color', parulaColors(m,:), 'Marker', 'none', 'LineWidth', .5, 'LineStyle', '-')
     end
[N, edges, ~] = OneUnitHistStructTimeLimLineINDEX(Events2, indexMLI, struct, -.75, 1, EventBin, TimeLim, SD,'k', NaN, 0, 0);
yyaxis left
plot(edges(1:end-1), N, 'k', 'LineWidth', .5)
xline(0, 'r');
title('Lick onset no reward expect. resp')
xlabel('time from Lick onset (s)')
ylabel ('Hz')


saveas(gca, [unitStr nametag]);
print(['un ' unitStr nametag], '-depsc', '-painters');
print(['un ' unitStr nametag], '-bestfit', '-dpdf', '-painters');
f.PaperPositionMode = 'manual';
f.PaperUnits = 'points';
f.PaperSize = [2100 860];
print(nametag, '-dpsc', '-bestfit', '-append');


end