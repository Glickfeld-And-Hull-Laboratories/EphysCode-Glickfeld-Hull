function [TraceData, p] = UHDgranCelltsPicker(unitID, struct, BurstISImax, preBurstISImin, TGA, TGB, ChansFromChan, TrigMin, TrigMax, gBursts, figBoo, nametag1)
%gBursts can be small or inf for all
% ylimitTrace = NaN;
% ex ChansFromChan = [0]; ChansFromChan = [-1 0 1];
%[-32 -31 -30 -29 -28 -17 -16 -15 -14 -13 -2 -1 0 1 2 13 14 15 16 17 28 29 30 31 32];
% [-16 -15 -14 -1 0 1 14 15 16]

unitIN = find([struct.unitID] == unitID);
[Bursts, ~, ~, ~, ~] = BurstOrdered(struct(unitIN).timestamps, BurstISImax, preBurstISImin, TGA, TGB);
if isinf(gBursts)
    gBursts = length(Bursts);
end

for q = 1:length(ChansFromChan)
    if isnan(nametag1)
        nametag = [num2str(unitID) ' ChanRel ' num2str(ChansFromChan(q))];
    else
        nametag = [nametag1 ' ' num2str(unitID) ' ChanRel ' num2str(ChansFromChan(q))];
    end
    
    sheetCounter = 0;
    for g = 1:gBursts
        if g == 1 || mod(g,15) == 0
            sheetCounter = sheetCounter + 1;
            f = figure;
            set(gcf,'Position',[0 0 1100 850]);
            layout1 = tiledlayout(5, 5, 'Padding', 'none', 'TileSpacing', 'compact');
            title(layout1, nametag);
        end
        nexttile
        hold on
        [TraceData{g,q}, p(g, q)] = LongTraceRead([Bursts(g)+TrigMin, Bursts(g)+TrigMax], unitID, struct, ChansFromChan(q));
        p(g,q).DataTipTemplate.DataTipRows(1).Format = '%5.6f';
        AddUnitToTrace([Bursts(g)+TrigMin, Bursts(g)+TrigMax], struct, unitID, ChansFromChan(q), 'm');
        plot([Bursts(g)-.001; Bursts(g)], [-.0001;-.0001], 'b');
        title(['ch ' num2str(struct(unitIN).channel + ChansFromChan(q))]);
        FormatFigure(NaN,NaN);
        
        if mod(g,15) == 14 || g == gBursts
            FigureWrap(NaN, [nametag '_' num2str(sheetCounter)], NaN, NaN, NaN, NaN, 8.5, 11);
            f.PaperPositionMode = 'manual';
            f.PaperUnits = 'inches';
            f.PaperSize = [11 8.5];
            print(nametag1, '-dpsc', '-bestfit', '-append');
        end
    end
end
end


