function h = cellHeatMapN(edges, length, N, ColorLimits)

  h = heatmap(edges(1:end-1), [1:length], N);
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

YLabels =  [1:length];
% Convert each number in the array into a string
CustomYLabels = string(YLabels);
% Replace all but the fifth elements by spaces
%CustomYLabels(mod(YLabels,5) ~= 0) = " ";

%CustomYLabels = {struct.channel};
%CustomYLabels = cellfun(@num2str, CustomYLabels, 'UniformOutput', false);
% Set the 'XDisplayLabels' property of the heatmap 
% object 'h' to the custom x-axis tick labels


% Set the 'XDisplayLabels' property of the heatmap 
% object 'h' to the custom x-axis tick labels
h.YDisplayLabels = CustomYLabels;
end
