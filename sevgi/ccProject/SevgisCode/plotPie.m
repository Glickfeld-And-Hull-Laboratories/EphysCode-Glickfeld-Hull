function plotPie(counts, sLabels, arrColors, sName, sPath)

    globals; 

%     if strcmp(sPath,pathToSSToClickPsthFolder) || strcmp(sPath,pathToSSToLickPsthFolder)
%         newColors = [COLORS(8,1:3); COLOR_BLIND_FRIENDLY_RED; COLOR_BLIND_FRIENDLY_BLUE]; %COLORS(7,1:3); [.1 0 .9]]; % For SS Inc Dec [.8 .1 .2]
%     else
%         newColors = [COLORS(8,1:3); COLORS(1,1:3); COLOR_BLIND_FRIENDLY_GREEN; COLORS(3,1:3)]; % COLOR_BLIND_FRIENDLY_BLUE COLORS(1,1:3) COLORS(9,1:3) For CSs
%     end

    sEarlyvsLate = '';
    if ~isempty(EARLY_VS_LATE_LICK)
        if strcmp(EARLY_VS_LATE_LICK,EARLY_LICK)
            sEarlyvsLate = 'EarlyLicks';
        else
            sEarlyvsLate = 'LateLicks';
        end
    end

    labels = {};
    for i=1:length(counts)
        labels{length(labels)+1} = num2str(counts(i));
    end

    f = figure();
    ax = gca();
    pie(counts,labels);
    % set(ax,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5);        
    set(findobj(f,'type','text'),'FontSize',PLOT_FONT_SIZE, 'FontWeight', 'Bold');
    ax.Colormap = arrColors; % newColors(1:length(counts),:);
    print([sPath sName sEarlyvsLate 'Pie.tif'], '-dtiff', '-r200');
    exportgraphics(f,[sPath sName  sEarlyvsLate 'Pie.pdf'], 'ContentType', 'vector', 'Resolution', 1200);
    close all;

%     counts = [47 23];
    ratios = 100*counts/sum(counts);

    labels = {};
    for i=1:length(ratios)
        labels{length(labels)+1} = [num2str(ratios(i),'%.0f') ' % ' sLabels{i}];
    end

    f = figure();
    ax = gca();
    pie(ratios, labels);
    % set(ax,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5);        
    set(findobj(f,'type','text'),'FontSize',PLOT_FONT_SIZE, 'FontWeight', 'Bold');
    ax.Colormap = arrColors; % newColors(1:length(counts),:);
    print([sPath sName sEarlyvsLate 'PieRatios.tif'], '-dtiff', '-r200');
    exportgraphics(f,[sPath sName sEarlyvsLate 'PieRatios.pdf'], 'ContentType', 'vector', 'Resolution', 1200);
    close all;
end