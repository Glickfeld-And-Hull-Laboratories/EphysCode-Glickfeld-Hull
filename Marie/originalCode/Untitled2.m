for n = 1:18
SummaryStruct(n).NormBiggestAligned = [SummaryStruct(n).BiggestWFstruct.NormBiggestAligned];
[MAX, maxi] = max(SummaryStruct(n).NormBiggestAligned(20:end));
maxi = maxi + 20;
[MIN, mini] = min(SummaryStruct(n).NormBiggestAligned);
SummaryStruct(n).WFh = MAX-MIN;
SummaryStruct(n).WFw = maxi-mini;
end
figure 
hold on
for n = 1:18
if strcmp(SummaryStruct(n).handID, 'MLI_laser')
scatter(SummaryStruct(n).WFw, SummaryStruct(n).WFh, 'r');
end
if ~strcmp(SummaryStruct(n).handID, 'MLI_laser')
scatter(SummaryStruct(n).WFw, SummaryStruct(n).WFh, 'k');
end
end
xlabel('WF width');
ylabel('WF height')
title('WF characteristics');
FormatFigure
saveas(gca, 'WFh_WFw')
print('WFh_WFw', '-depsc','-painters')