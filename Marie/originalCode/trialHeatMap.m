function [N, edges] = trialHeatMap(struct, trigger, xlim, bwidth, timeLim, ZscoreBoo, SDBaseLim, plotBoo, ColorLimits)
%struct already limited to units of interest

N = [];
for n = 1:length(struct)
for g = 1:length(trigger)
    [addthis(1,:), edges] = OneUnitHistStructTimeLimLineINDEX(trigger(g), n, struct, xlim(1), xlim(2), bwidth, timeLim, 4, 'k', NaN, 0, 0);

    if n == 1
    N(g,:) = addthis;
    else
        N(g,:) = [N(g,:) + addthis];
    end
end
end
N = N/length(struct);
%here!!!!
    if ZscoreBoo == 1
        for g = 1:length(trigger)
        [meanLine, stdevLine] = StDevLine(N(g,:), edges, SDBaseLim);
        N(g,:) = (N(g,:) - meanLine)/stdevLine;
        end
    end
    
    %end here
if plotBoo
    h = heatmap(edges(1:end-1), [1:length(trigger)], N);
h.Colormap = parula;
h.GridVisible = 'off';
if ~isnan(ColorLimits)
h.ColorLimits = ColorLimits;

XLabels = edges(1:end-1);
% Convert each number in the array into a string
CustomXLabels = string(XLabels);
% Replace all but the fifth elements by spaces
CustomXLabels(mod(XLabels,.1) ~= 0) = " ";
% Set the 'XDisplayLabels' property of the heatmap 
% object 'h' to the custom x-axis tick labels
h.XDisplayLabels = CustomXLabels;

YLabels = [1:length(trigger)];
% Convert each number in the array into a string
CustomYLabels = string(YLabels);
% Replace all but the fifth elements by spaces
CustomYLabels(mod(YLabels,5) ~= 0) = " ";
% Set the 'XDisplayLabels' property of the heatmap 
% object 'h' to the custom x-axis tick labels
h.YDisplayLabels = CustomYLabels;
end
end