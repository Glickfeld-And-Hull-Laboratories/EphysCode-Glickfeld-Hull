%Nstruct = cell2struct({SumSt_AllVars_limBrReg.ToneAloneRespN}, 'ToneAloneRespN', color, overlay);
%edgesstruct = cell2struct({SumSt_AllVars_limBrReg.ToneAloneResp_edges}, 'edges');

function [legend_tilecounter, Nedges, f] = TypeRegionPlotter(title_, RegionsListCell, CellTypeList, range, NsField, edgesField, meanboo, errorboo, singleboo, NormBoo, BigStruct, color, overlay, varagin)

PatSat = .1; %patch saturation for error bars

NsField = cellstr(NsField);
edgesField = cellstr(edgesField);
color = cellstr(color); 

if overlay == 0
f = figure;
set(gcf,'Position',[20 50 800 1200]);
layout1 = tiledlayout(length(CellTypeList), length(RegionsListCell), 'TileSpacing', 'compact', 'Padding', 'none');
title(layout1, title_, 'FontSize', 22, 'FontName', 'Arial', 'FontWeight', 'bold');
legend_tilecounter = cell(length(CellTypeList) * length(RegionsListCell),1);
else
    legend_tilecounter = varagin;
    f = gcf;
end

for p = 1:length(NsField)

AllFields = fieldnames(BigStruct);
FieldsToRemove = setdiff(AllFields, NsField{p,1});
NsCell = struct2cell(rmfield(BigStruct, FieldsToRemove)).';

AllFields = fieldnames(BigStruct);
FieldsToRemove = setdiff(AllFields, edgesField{p,1});
edgesCell = struct2cell(rmfield(BigStruct, FieldsToRemove)).';
   
tilecounter = 0;

if p >1
    overlay = 1;
end


for k = 1:length(CellTypeList)
    CellTypeStruct = BigStruct(strcmp({BigStruct.CellType}, CellTypeList{k}));
    (strcmp({BigStruct.CellType}, CellTypeList{k}))
    CellTypeNs = NsCell(strcmp({BigStruct.CellType}, CellTypeList{k}));
    CellTypeedges = edgesCell(strcmp({BigStruct.CellType}, CellTypeList{k}));


    
for n = 1:length(RegionsListCell)
    tilecounter = tilecounter +1;
    nexttile(tilecounter)
    hold on
    % title([CellTypeList{1,k} ' in ' RegionsListCell{1,n}])
    if ~isnan(RegionsListCell)
    Struct = CellTypeStruct(strcmp({CellTypeStruct.BrainReg}, RegionsListCell{n}));
    sum(strcmp({CellTypeStruct.BrainReg}, RegionsListCell{n}))
    NsTypeRegion = CellTypeNs(strcmp({CellTypeStruct.BrainReg}, RegionsListCell{n}));
    edgesTypeRegion = CellTypeedges(strcmp({CellTypeStruct.BrainReg}, RegionsListCell{n}));
    else
        Struct = CellTypeStruct;
        NsTypeRegion = CellTypeNs;
        edgesTypeRegion = CellTypeedges;
    end
    %edges2 = edgesTypeRegion{1}(1:end-1);
    edges2 = edgesTypeRegion{1};
    
    %adjust for range if nessesary
    if ~isnan(range)
    if edges2(1) < range(1) | edges2(end) > range(2)
        indexR1 = find(edges2 >= range(1), 1, 'first');
        indexR2 = find(edges2 <= range(2), 1, 'last');
        edges2 = edges2(indexR1:indexR2);
        for m = 1:length(Struct)
            %edgesTypeRegion{m} = edgesTypeRegion{m}(indexR1:indexR2); 
            NsTypeRegion{m} = NsTypeRegion{m}(indexR1:indexR2);
        end
    end
    end
    
    
    if ~isempty(edgesTypeRegion)
        
    if ~isempty(NsTypeRegion)
    if singleboo
        if ~NormBoo
        for m = 1:length(Struct)
            plot(edges2, NsTypeRegion{m});
        end
        end
        if NormBoo
        for m = 1:length(Struct)
            plot(edges2, NsTypeRegion{m}/mean(NsTypeRegion{m}(1:20)));
        end
        end
    end
    if meanboo == 1 && errorboo == 0
          Mean = nanmean(cell2mat(NsTypeRegion));
        if NormBoo
            plot(edges2, Mean/mean(Mean(1:20)), color{p,1}, 'LineWidth', 2)
        else
             plot(edges2, Mean, color{p,1}, 'LineWidth', 2)
        end
    end
    if meanboo == 1 && errorboo == 1
            Mean = nanmean(cell2mat(NsTypeRegion));
            if NormBoo == 1                         % added 250218 MEH
                Mean = Mean/mean(Mean(1:20));
            end
            StError = nanstd(cell2mat(NsTypeRegion)/mean(Mean(1:20)))/sqrt(size(rmmissing(cell2mat(NsTypeRegion)),1));
            if length(Mean)>1
                size(edges2)
                size(Mean)
                size(StError)
            shadedErrorBar2(edges2, Mean, StError, 'lineProps', color{p,1}, 'transparent',1, 'patchSaturation', PatSat);
            else
            plot(edgesTypeRegion{1}(1:end), cell2mat(NsTypeRegion), color{p,1});
            end
    end
    end
            legend_tilecounter{tilecounter, 1} = [legend_tilecounter{tilecounter, 1}; {[NsField{p,1} ' n = ' num2str(length(NsTypeRegion))]}];
            YLimCell{tilecounter, 1} = get(gca,'YLim');
            if meanboo ==1
            Nedges(tilecounter).N = Mean;
            Nedges(tilecounter).edges = edgesTypeRegion{1}(1:end);
            Nedges(tilecounter).Region =RegionsListCell(n);
            Nedges(tilecounter).CellType = CellTypeList(k);
            else Nedges = [];
            end
            if isempty(NsTypeRegion)
                YLimCell{tilecounter, 1} = [];
                Nedges(tilecounter).N = [];
                Nedges(tilecounter).edges = [];
                Nedges(tilecounter).Region =RegionsListCell(n);
                Nedges(tilecounter).CellType = CellTypeList(k);
            end
            
            
    else
        YLimCell{tilecounter, 1} = [];
        legend_tilecounter{tilecounter, 1} = [];
   end
end
end
end
%adjust axes and insert legend
for q = 0:length(CellTypeList)-1
    width = length(RegionsListCell);
    starttile = (q)*width + 1;
    Ymax = max(cell2mat(cellfun(@nanmax, YLimCell(starttile:starttile+width-1), 'UniformOutput', 0)));
    Ymin = min(cell2mat(cellfun(@nanmin, YLimCell(starttile:starttile+width-1), 'UniformOutput', 0)));
    
    for r = starttile:starttile+width-1
        nexttile(r)
        if ~isempty([Ymin Ymax])
        %ylim([Ymin, Ymax]);
        end
        FormatFigure(NaN, NaN); 
        ylabel('Hz');
        xlabel('sec');
        lgd = legend(legend_tilecounter{r, 1}, 'Location', 'best', 'Box','off');
        lgd.FontSize = 5;
        
        
    end
end
saveas(gca,title_)
print(title_, '-bestfit', '-dpsc', '-painters');

end


