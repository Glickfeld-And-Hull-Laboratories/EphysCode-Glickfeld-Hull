function [TraceData, p] = UHDgranCellVis(unitID, struct, BurstISImax, preBurstISImin, TGA, TGB, ChansFromChan, TrigMin, TrigMax, gBursts, figBoo, nametag)
%gBursts can be small or inf for all
% ylimitTrace = NaN;
if isnan(nametag)
nametag = num2str(unitID);
end
unitIN = find([struct.unitID] == unitID);
[Bursts, ~, ~, ~, ~] = BurstOrdered(struct(unitIN).timestamps, BurstISImax, preBurstISImin, TGA, TGB);
% ex ChansFromChan = [0]; ChansFromChan = [-1 0 1]; 
%[-32 -31 -30 -29 -28 -17 -16 -15 -14 -13 -2 -1 0 1 2 13 14 15 16 17 28 29 30 31 32];
% [-16 -15 -14 -1 0 1 14 15 16]

if isinf(gBursts)
    gBursts = length(Bursts);
end
for g = 1:gBursts
    if figBoo == 1
        f = figure;
set(gcf,'Position',[0 0 1100 850]);
layout1 = tiledlayout(5, 5, 'Padding', 'none', 'TileSpacing', 'compact');
title(layout1, nametag);
    end
for k = 1:length(ChansFromChan)
 if figBoo == 1
     nexttile
  hold on
[TraceData{g,k}, p(g, k)] = LongTraceRead([Bursts(g)+TrigMin, Bursts(g)+TrigMax], unitID, struct, ChansFromChan(k));
p(g,k).DataTipTemplate.DataTipRows(1).Format = '%5.6f';
   AddUnitToTrace([Bursts(g)+TrigMin, Bursts(g)+TrigMax], struct, unitID, ChansFromChan(k), 'm');

  %AddUnitToTrace ([trigger(trial)+TrigMin, trigger(trial)+TrigMax], struct, 234, 1, 'y');
 %xline(trigger(trial), 'b', 'LineWidth', 2, 'Label', 'random point');
 plot([Bursts(g)-.001; Bursts(g)], [-.0001;-.0001], 'b');
%     p.LineWidth = 2;
%     text(Bursts(g)-.04, -.00012, '50 ms', 'Color', 'blue');
 title(['ch ' num2str(struct(unitIN).channel + ChansFromChan(k))]);
  FormatFigure(NaN,NaN);
 end
end
FigureWrap(NaN, [nametag '_' num2str(g)], NaN, NaN, NaN, NaN, 8.5, 11);
f.PaperPositionMode = 'manual';
f.PaperUnits = 'inches';
f.PaperSize = [11 8.5];
print(nametag, '-dpsc', '-bestfit', '-append');
end
%  if ~isnan(ylimitTrace)
%    ylim(ylimitTrace);
%  end

 hold off

%%print([unitStr nametag], '-dpdf')%, '-painters');
FigureWrap(NaN, [nametag '_' num2str(g)], NaN, NaN, NaN, NaN, 8.5, 11);
f.PaperPositionMode = 'manual';
f.PaperUnits = 'inches';
f.PaperSize = [11 8.5];
print(nametag, '-dpsc', '-bestfit', '-append');
end