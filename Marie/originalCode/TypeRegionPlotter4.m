

function [legend_tilecounter, Nedges, f, NsTypeRegion] = TypeRegionPlotter4(title_, RegionsListCell, CellTypeList, range, NsField, edgesField, meanboo, errorboo, singleboo, zBoo, BigStruct, color, overlay, varagin)
%example calls: (all brain regions)
%[legend_tilecounter, Nedges] = TypeRegionPlotter4('tester', NaN, {'B'}, [-.5 1.5], 'ToneBeforeJuice_N ', 'ToneBeforeJuice_edges', 0,0, 1, 0, MLIsTyped.', 'm', 0); 
% Crus2
% [legend_tilecounter, Nedges] = TypeRegionPlotter4('tester', {'Crus2'}, {'B'}, [-.5 1.5], 'ToneBeforeJuice_N ', 'ToneBeforeJuice_edges', 0,0, 1, 0, MLIsTyped.', 'm', 0); 
% [legend_tilecounter, Nedges] = TypeRegionPlotter4('tester', {'Crus2', 'PM'}, {'A', 'B', 'b'}, NaN, {'JuiceAlone_N'; 'ToneBeforeJuice_N'}, {'JuiceAlone_edges'; 'ToneBeforeJuice_edges'}, 1, 1, 0, 1, MLIsTyped.', {'m'; 'g'}, 0);
%[legend_tilecounter, Nedges] = TypeRegionPlotter4('tester', {'Crus2', 'PM'}, {'A', 'B', 'b'}, NaN, {'JuiceAlone_N'; 'ToneBeforeJuice_N'}, {'JuiceAlone_edges'; 'ToneBeforeJuice_edges'}, 1, 1, 0, 1, MLIsTyped.', {'m'; 'g'}, 1, legend_tilecounter);



PatSat = .1; %patch saturation for error bars

NsField = cellstr(NsField);
edgesField = cellstr(edgesField);

if ~iscell(color)
if ~isnan(color)
color = cellstr(color);
end
end

if overlay == 0
f = figure;
set(gcf,'Position',[20 50 800 1200]);
layout1 = tiledlayout(length(CellTypeList), length(RegionsListCell), 'TileSpacing', 'compact', 'Padding', 'none');
if length(RegionsListCell) >1
title(layout1, title_, 'FontSize', 22, 'FontName', 'Arial', 'FontWeight', 'bold');
end
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
    CellTypeNs = NsCell(strcmp({BigStruct.CellType}, CellTypeList{k}));
    CellTypeedges = edgesCell(strcmp({BigStruct.CellType}, CellTypeList{k}));

for n = 1:length(RegionsListCell)
    tilecounter = tilecounter +1;
    nexttile(tilecounter)
    hold on
    
    if iscell(RegionsListCell)
    title([CellTypeList{1,k} ' in ' RegionsListCell{1,n}])
    Struct = CellTypeStruct(strcmp({CellTypeStruct.BrainReg}, RegionsListCell{n}));
    NsTypeRegion = CellTypeNs(strcmp({CellTypeStruct.BrainReg}, RegionsListCell{n}));
    edgesTypeRegion = CellTypeedges(strcmp({CellTypeStruct.BrainReg}, RegionsListCell{n}));
    %edges2 = edgesTypeRegion{1}(1:end-1);
    else
    Struct = CellTypeStruct;
    NsTypeRegion = CellTypeNs;
    edgesTypeRegion = CellTypeedges;
    end
    %remove any cells that are NaN or empty in the N column
    NotNaNBoo = cellfun(@isnan, NsTypeRegion, 'UniformOutput', 0);
    NotNaNBoo = cell2mat(NotNaNBoo);
    if size(NotNaNBoo,2 >= 1)
    NotNaNBoo = ~(NotNaNBoo(:,1));
    Struct = Struct(NotNaNBoo);
    NsTypeRegion = NsTypeRegion(NotNaNBoo);
    edgesTypeRegion = edgesTypeRegion(NotNaNBoo);
    NotEmptyBoo = ~cellfun(@isempty, NsTypeRegion);
    Struct = Struct(NotEmptyBoo);
    NsTypeRegion = NsTypeRegion(NotEmptyBoo);
    edgesTypeRegion = edgesTypeRegion(NotEmptyBoo);
    end
 if ~isempty(NsTypeRegion) | size(NotNaNBoo,2) >= 1 %skip most of this if no qualifying cells
    edges2 = edgesTypeRegion{1};
    if length(edges2) == length(NsTypeRegion{1})+1
        edges2 = edges2(1:end-1);
    end
    
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
    
    
    if singleboo
        if ~zBoo
        for m = 1:length(Struct)
            if iscell(color)
            plot(edges2, NsTypeRegion{m}, color{p,1});
            else
            plot(edges2, NsTypeRegion{m}) 
            end
        end
        end
        if zBoo
        for m = 1:length(Struct)
            if iscell(color)
            %plot(edges2, (NsTypeRegion{m}-mean(NsTypeRegion{m}(1:100))/std(NsTypeRegion{m}(1:100))), 'Color', color{p,:});
            plot(edges2, ((NsTypeRegion{m}-mean(NsTypeRegion{m}(1:100)))/std(NsTypeRegion{m}(1:100))));
            %plot(edges2, (NsTypeRegion{m}));
            else
            plot(edges2, (NsTypeRegion{m}-mean(NsTypeRegion{m}(1:100)))/std(NsTypeRegion{m}(1:100)));   
            end
            Nedges(tilecounter).Z(:,m) =((NsTypeRegion{m}-mean(NsTypeRegion{m}(1:100)))/std(NsTypeRegion{m}(1:100)));
            Nedges(tilecounter).edges(:,m) = edges2;
        end
        end
    end
    if meanboo == 1 && errorboo == 0
          Mean = nanmean(cell2mat(NsTypeRegion));
        if zBoo
            plot(edges2, (Mean-mean(Mean(1:100)))/std(Mean(1:100)), 'Color', color{p,1}, 'LineWidth', 2);
        else
             plot(edges2, Mean, color{p,1}, 'LineWidth', 2);
        end
    end
    if meanboo == 1 && errorboo == 1
            Mean = mean(cell2mat(NsTypeRegion));
            StError = std(cell2mat(NsTypeRegion))/sqrt(size(cell2mat(NsTypeRegion),1));
                if zBoo
                    %Mean = zscore(Mean);
                    %StError = zscore(StError);
                    %shadedErrorBar2(edges2, Mean, StError, 'lineProps', color{p,1}, 'transparent',1, 'patchSaturation', PatSat);
                    baselineBinsN = round(length(Mean)/10); %use first 1/10th of time as baseline
                    plot(edges2, (Mean-mean(Mean(1:baselineBinsN)))/std(Mean(1:baselineBinsN)), color{p,1});
                    %shadedErrorBar2(edges2, (Mean-mean(Mean(1:100))/std(cell2mat(NsTypeRegion), StError/mean(Mean(1:100)), 'lineProps', color{p,1}, 'transparent',1, 'patchSaturation', PatSat);
                else
            if length(Mean)>1
            shadedErrorBar2(edges2, Mean, StError, 'lineProps', color{p,1}, 'transparent',1, 'patchSaturation', PatSat);
            else
            plot(edges2, cell2mat(NsTypeRegion), color{p,1});
            end
                end
    end
            if iscell(RegionsListCell)
            legend_tilecounter{tilecounter, 1} = [legend_tilecounter{tilecounter, 1}; {[NsField{p,1}(1:end-2) ' Type ' CellTypeList{k} ' in ' RegionsListCell{n} ' n = ' num2str(size(cell2mat(NsTypeRegion),1))]}];
            else
            legend_tilecounter{tilecounter, 1} = [legend_tilecounter{tilecounter, 1}; {[NsField{p,1}(1:end-2) ' Type ' CellTypeList{k} ' n = ' num2str(size(cell2mat(NsTypeRegion),1))]}];
            end
            YLimCell{tilecounter, 1} = get(gca,'YLim');
            if meanboo ==1
            Nedges(tilecounter).N = Mean;
            Nedges(tilecounter).StErr = StError;
                if length(Mean) == 1
                    Nedges(tilecounter).N = cell2mat(NsTypeRegion);
                    Nedges(tilecounter).StErr = NaN;
                end
            Nedges(tilecounter).edges = edgesTypeRegion{1}(1:end);
            Nedges(tilecounter).Region =RegionsListCell(n);
            Nedges(tilecounter).CellType = CellTypeList(k);
            else
            Nedges(tilecounter).Region =RegionsListCell(n);
            Nedges(tilecounter).CellType = CellTypeList(k); 
            end
 else
                YLimCell{tilecounter, 1} = [];
                Nedges(tilecounter).N = [];
                Nedges(tilecounter).edges = [];
                Nedges(tilecounter).Z = [];
                Nedges(tilecounter).Region =RegionsListCell(n);
                Nedges(tilecounter).CellType = CellTypeList(k);
                scatter(0,0)
                 if iscell(RegionsListCell)
                legend_tilecounter{tilecounter, 1} = [legend_tilecounter{tilecounter, 1}; {[NsField{p,1}(1:end-2) ' Type ' CellTypeList{k} ' in ' RegionsListCell{n} ' n = ' num2str(0)]}];
                 else
                legend_tilecounter{tilecounter, 1} = [legend_tilecounter{tilecounter, 1}; {[NsField{p,1}(1:end-2) ' Type ' CellTypeList{k} ' n = ' num2str(0)]}];
                end
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
        if zBoo == 1
            ylabel('z-score')
        else
        ylabel('Hz');
        end
        xlabel('sec');
        lgd = legend(legend_tilecounter{r, 1}, 'Location', 'best', 'Box','off');
        lgd.FontSize = 5;
        
        
    end
end
saveas(gca,title_)
print(title_, '-bestfit', '-dpsc', '-painters');
print(title_, '-bestfit', '-dpdf', '-painters');

end


