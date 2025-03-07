function FigureWrap(title_, saveas_, xlabel_, ylabel_, xlim_, ylim_, W, H)

FormatFigure(W, H)
if ~isnan(title_)
title(title_);
end
if ~isnan(ylabel_)
ylabel(ylabel_);
end
if ~isnan(xlabel_)
xlabel(xlabel_);
end
if ~isnan(ylim_)
ylim(ylim_);
end
if ~isnan(xlim_)
xlim(xlim_);
end
saveas(gcf,saveas_)
print(saveas_, '-dpdf', '-painters');
%print(saveas_, '-depsc', '-painters');

end