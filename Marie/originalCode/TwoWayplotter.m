%Nstruct = cell2struct({SumSt_AllVars_limBrReg.ToneAloneRespN}, 'ToneAloneRespN', color, overlay);
%edgesstruct = cell2struct({SumSt_AllVars_limBrReg.ToneAloneResp_edges}, 'edges');

function legend_tilecounter = TypeRegionPlotter(title_, RegionsListCell, CellTypeList, NsField, edgesField, meanboo, singleboo, BigStruct, color, overlay, varagin)

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
    CellTypeNs = NsCell(strcmp({BigStruct.CellType}, CellTypeList{k}));
    CellTypeedges = edgesCell(strcmp({BigStruct.CellType}, CellTypeList{k}));
    
for n = 1:length(RegionsListCell)
    tilecounter = tilecounter +1;
    nexttile(tilecounter)
    hold on
    title([CellTypeList{1,k} ' in ' RegionsListCell{1,n}])
    
    Struct = CellTypeStruct(strcmp({CellTypeStruct.BrainReg}, RegionsListCell{n}));
    NsTypeRegion = CellTypeNs(strcmp({CellTypeStruct.BrainReg}, RegionsListCell{n}));
    edgesTypeRegion = CellTypeedges(strcmp({CellTypeStruct.BrainReg}, RegionsListCell{n}));
    
    if ~isempty(NsTypeRegion)
    if singleboo
        for m = 1:length(Struct)
            plot(edgesTypeRegion{m}(1:end-1), NsTypeRegion{m});
        end
    end
    if meanboo == 1
            Mean = nanmean(cell2mat(NsTypeRegion));
            plot(edgesTypeRegion{1}(1:end-1), Mean, color{p,1})
    end
    end
            legend_tilecounter{tilecounter, 1} = [legend_tilecounter{tilecounter, 1}; {[NsField{p,1} ' n = ' num2str(length(NsTypeRegion))]}];
            YLimCell{tilecounter, 1} = get(gca,'YLim');
            if isempty(NsTypeRegion)
                YLimCell{tilecounter, 1} = [];
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
        ylim([Ymin, Ymax]);
        FormatFigure; 
        ylabel('Hz');
        xlabel('sec');
        lgd = legend(legend_tilecounter{r, 1}, 'Location', 'best', 'Box','off');
        lgd.FontSize = 5;
        
        
    end
end
print(title_, '-bestfit', '-dpsc', '-painters');

end


