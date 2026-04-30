function scatterDataByNormalizedTrialNumbers(variableAlongSessions, sXLabel, sYLabel, sTitle, sFile)
    globals;

    f = figure;
    f.Position = [globalX globalY globalW globalH];
    hold on 

    if iscell(variableAlongSessions)
        for ind=1:length(variableAlongSessions)
            variableAlongSession = variableAlongSessions{ind};
            if ~isempty(variableAlongSession)
                trialNumber = length(variableAlongSession);
                normTrials = linspace(1, 100, trialNumber);  % Normalized x-axis [1, 100]
                myScatter(normTrials, variableAlongSession);
            end
        end
    else
        trialNumber = length(variableAlongSessions);
        normTrials = linspace(1, 100, trialNumber);  % Normalized x-axis [1, 100]
        myScatter(normTrials, variableAlongSessions);
    end

    set(gca,'box','off');
                    
    ylabel(sYLabel);
    xlabel(sXLabel);
    ylim([0 1]);
    set(gca,'TickDir','out');
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5);
    title(sTitle);            
    print(sFile, '-dtiff', '-r200');       
    close all;
end