function FormatFigure(H, W)
YLIM = get(gca,'YLim');
XLIM = get(gca,'XLim');

if isnan(H) & isnan(W)
    H=2;
    W=2.2;
end
set(gcf,'PaperUnits','inches');
set(gcf,'PaperPosition',[0 0 W H]); %[0 0 width height]

 screenposition = get(gcf,'Position');
set(gcf, 'PaperPosition',[0 0 W H], 'PaperUnits', 'Inches', 'PaperSize',[W H]);
% %set(gcf, 'PaperPosition',[0 0 4 2.25], 'PaperUnits', 'Inches', 'PaperSize',[4 2.25]);
% set(gcf, 'PaperUnits', 'Inches', 'PaperSize', [1 1]);


ax = gca; 
if isgraphics(ax, 'axes')
ax.Box = 'off';

ax.TickDir = 'out';
ax.FontName = 'Arial';
ax.FontName = 'Arial';
ax.FontSize = 10;
ax.TitleFontSizeMultiplier = 1;
ax.LabelFontSizeMultiplier = 1;
ax.LineWidth = 0.5;
ax.XColor = 'k';
ax.YColor = 'k';
ax.Title.Color = 'k';
ax.Color = 'None';
ax.TitleFontWeight = 'normal';
ax.TickLength = [0.02 0.035];
end
end
%ylim(YLIM);
%xlim(XLIM);


%ax.XMinorTick = 'on';
%ax.YMinorTick = 'on';
%ax.XTick = [0 .001];
%ax.YTick = [0 20 40 60];
%ax.YTick = 0:10:100;
%ax.XTickLabel = {'0','','20',''};
% ax.TickLength = [0.02 0.035];
%legend({'Line 1','Line 2','Line 3'},'FontSize',12);
%ax.Legend.TextColor = 'red';
