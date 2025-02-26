function [N, edges] = cellHeatMap(struct, trigger, xlim, bwidth, timeLim, SDboo, sdBaseLim, AbsValBoo, plotBoo, ColorLimits)
%struct already limited to units of interest

N = [];
for n = 1:length(struct)
    [addthis(1,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger, n, struct, xlim(1), xlim(2), bwidth, timeLim, 4, 'k', NaN, 0, 0);
    if SDboo == 1
        [meanLine, stdevLine] = StDevLine(addthis, edges, sdBaseLim);
        addthis = (addthis - meanLine)/stdevLine;
        if AbsValBoo == 1
            addthis = abs(addthis);
        end
    end
    N(n,:) = addthis;
end
if plotBoo
    h = heatmap(edges(1:end-1), [1:length(struct)], N);
h.Colormap = parula;
h.GridVisible = 'off';
if ~isnan(ColorLimits)
h.ColorLimits = ColorLimits;
end

XLabels = edges(1:end-1);
% Convert each number in the array into a string
CustomXLabels = string(XLabels);
% Replace all but the fifth elements by spaces
CustomXLabels(mod(XLabels,.1) ~= 0) = " ";
index0 = find(edges < .00001 & edges > -.00001);
CustomXLabels(index0) = '0';
% Set the 'XDisplayLabels' property of the heatmap 
% object 'h' to the custom x-axis tick labels
h.XDisplayLabels = CustomXLabels;

YLabels =  [1:length(struct)];
% Convert each number in the array into a string
CustomYLabels = string(YLabels);
% Replace all but the fifth elements by spaces
%CustomYLabels(mod(YLabels,5) ~= 0) = " ";

CustomYLabels = {struct.channel};
CustomYLabels = cellfun(@num2str, CustomYLabels, 'UniformOutput', false);
% Set the 'XDisplayLabels' property of the heatmap 
% object 'h' to the custom x-axis tick labels


% Set the 'XDisplayLabels' property of the heatmap 
% object 'h' to the custom x-axis tick labels
h.YDisplayLabels = CustomYLabels;

end
end
