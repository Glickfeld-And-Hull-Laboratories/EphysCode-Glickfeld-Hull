function formatSaveFigure(f, sFolderName, sFileName)
    
    globals;

    f.Position = [globalX globalY globalW globalH]; 
    grid on;
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',30);
    print([sFolderName sFileName '.tif'], '-dtiff', '-r120');
%           exportgraphics(f,[pathToFigureFolder SS_MLI '/CCG_' num2str(unitOfInterestSS.id) 'wrt' num2str(unitOfInterestMLI.id) '_' BASELINE '_VS_' FIRST_DRUG '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);

%     print([sFolderName sFileName], '-dpdf', '-painters');
    %print(saveas_, '-depsc', '-painters');
    close all;
end