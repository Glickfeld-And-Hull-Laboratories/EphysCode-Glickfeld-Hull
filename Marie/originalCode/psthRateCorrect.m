function [N, edges] = psthRateCorrect(struct, min, max, binwidth, trigger, m, TGA, TGB, TimeLim1, TimeLim2, color, plotBoo, SD, SDboo)
[N_corr, ~, ~, ~] =  psthINDEX_CorCorrect(struct, min, max, binwidth, trigger, m, TGA, TGB, TimeLim1, TimeLim2,  color, 0, SD, SDboo);
[N_straight, edges, ~] = psthINDEX_TG(struct, min, max, binwidth, trigger, m, TGA, TGB, TimeLim1, TimeLim2,  color, 0, SD, SDboo);
% title1 = n;           % collect unitIDs as strings for titling the graph
title2 = m;
N = N_straight - N_corr;

if ~plotBoo==0
    %figure
    plot(edges,N, 'Color', color);
strTitle = [num2str(title1) ' vs ' num2str(title2)];
title(['trigger' ' & ' num2str(m) ' from ' num2str(TimeLim1) ' to ' num2str(TimeLim2)]);
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


