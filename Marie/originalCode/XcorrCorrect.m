function [N, edges] = XcorrCorrect(struct, xmin, xmax, bwidth, unit1, unit2, TimeGridA, TimeGridB, limMin, limMax, color, plotBoo, SD, SDboo) 
Iunit1 = unit1;        % this function works with INDEX
Iunit2 = unit2;

title1 = [struct(Iunit1).unitID];           % collect unitIDs as strings for titling the graph
title2 = [struct(Iunit2).unitID];

[N, edges] = XcorrFastINDEX_TG(struct, xmin, xmax, bwidth, unit1, unit2, TimeGridA, TimeGridB, limMin, limMax, color, 0, SD, 0);

[Nccc, ~] = XcorrFastINDEX_CorCorrect(struct, xmin, xmax, bwidth, unit1, unit2, TimeGridA, TimeGridB, limMin, limMax, color, 0, SD, 0);

N = N-Nccc;

if ~plotBoo==0
    %figure
    plot(edges,N, 'Color', color);
strTitle = [num2str(title1) ' vs ' num2str(title2)];
title([num2str(title1) ' & ' num2str(title2) ' from ' num2str(limMin) ' to ' num2str(limMax)]);
box off;
%xline(0,'b');
%ax.TickDir = 'out'
ax = gca; 
ax.TickDir = 'out';
ax.FontName = 'Calibri';%, 'FixedWidth';
ax.FontSize = 18;
%yticklabels(yticks/L1/bwidth);
%tiledlayout(flow);
end

if ~SDboo == 0
[meanLine, stdevLine] = StDevLine(N, edges, -.005);
yline(meanLine + SD*stdevLine, 'g', 'LineWidth', 2);
if (meanLine - SD*stdevLine) >0
yline((meanLine - 2*stdevLine), 'y', 'LineWidth', 2);
end
end



end