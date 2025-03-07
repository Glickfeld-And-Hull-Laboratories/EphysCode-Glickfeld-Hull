for n = 24:48
if strcmp(Ss_MLI_noPutCS(n).handID, 'MLI')
if strcmp(Ss_MLI_noPutCS(n).MLIexpertID, 'ccg')
    figure
    nexttile
            plot(Ss_MLI_noPutCS(n).BiggestWFstruct.alignedWF/-min(Ss_MLI_noPutCS(n).BiggestWFstruct.alignedWF), 'Color', ParulaColors(n-23,:), 'LineWidth', 1)
    title(['Unit ' num2str(Ss_MLI_noPutCS(n).unitID) ' fires at ' num2str(Ss_MLI_noPutCS(n).FR) ' expert ID ' Ss_MLI_noPutCS(n).MLIexpertID])
    nexttile
    hold on
for k= 1:length(Ss_MLI_noPutCS)
if strcmp(Ss_MLI_noPutCS(k).handID, 'SSpause') & strcmp(Ss_MLI_noPutCS(n).recordingID, Ss_MLI_noPutCS(k).recordingID)
    xCorrStructNewLimitsLineINDEX(Ss_MLI_noPutCS, -.02, .02, .0005, n, k, 0, 1000, 'k', 1, 4, 0);
end
end
end
end
hold off
end

for n = 24:48
if strcmp(Ss_MLI_noPutCS(n).handID, 'MLI')
if strcmp(Ss_MLI_noPutCS(n).MLIexpertID, 'layer')
    figure
    nexttile
            plot(Ss_MLI_noPutCS(n).BiggestWFstruct.alignedWF/-min(Ss_MLI_noPutCS(n).BiggestWFstruct.alignedWF), 'Color', ParulaColors(n-23,:), 'LineWidth', 1)
    title(['Unit ' num2str(Ss_MLI_noPutCS(n).unitID) ' fires at ' num2str(Ss_MLI_noPutCS(n).FR) ' expert ID ' Ss_MLI_noPutCS(n).MLIexpertID])
    FormatFigure
    nexttile
    hold on
for k= 1:length(Ss_MLI_noPutCS)
if strcmp(Ss_MLI_noPutCS(k).MLIexpertID, 'ccg') & strcmp(Ss_MLI_noPutCS(n).recordingID, Ss_MLI_noPutCS(k).recordingID)
    xCorrStructNewLimitsLineINDEX(Ss_MLI_noPutCS, -.02, .02, .0005, n, k, 0, 1000, 'k', 1, 4, 0);
    FormatFigure
end
end
end
end
hold off
end