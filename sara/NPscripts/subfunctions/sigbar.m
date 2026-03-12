% to draw significance bars

function sigbar(x1,x2,y,p)

ax = gca;
yr = diff(ax.YLim);

line([x1 x2],[y y],'Color','k','LineWidth',1.2)
line([x1 x1],[y-0.015*yr y],'Color','k','LineWidth',1.2)
line([x2 x2],[y-0.015*yr y],'Color','k','LineWidth',1.2)

text(mean([x1 x2]),  y+0.3, [p2star(p) ' p=' num2str(round(p,3))], ...
    'HorizontalAlignment','center','FontSize',10)

end