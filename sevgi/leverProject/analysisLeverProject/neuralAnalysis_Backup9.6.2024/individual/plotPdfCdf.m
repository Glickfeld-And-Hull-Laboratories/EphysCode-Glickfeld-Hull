function plotPdfCdf(distr1, distr2, unitID, neuronType, sTitle, strTrialType, sXLabel, sLegend1, sLegend2, sFileName, xLim)
        globals;

        nBins = 50;
        minFR = min([distr1 distr2]);
        minFR = minFR*0.9;
        if minFR==0
            minFR = -10;
        end
        maxFR = max([distr1 distr2]);
        maxFR = maxFR*1.1;
        binSize = 0.75;
        edges = minFR-binSize:binSize:maxFR+binSize;

        f = figure;
        f.Position = [globalX globalY 2*globalW globalH];
        subplot(1,2,1);
        hold on
        
        %histogram(distr1, edges, 'FaceColor', 'k');  
        h1 = histfit(distr1, nBins, 'poisson');
        h1(1).FaceColor = [.4 .4 .4]; % Grey        
        h1(1).EdgeColor = 'k'; % Black
        h1(1).FaceAlpha = 0.5;
        h1(2).Color = [.4 .4 .4];
        h2 = histfit(distr2, nBins, 'poisson');
        h2(1).FaceColor = 'b';
        h2(1).EdgeColor = 'k';
        h2(1).FaceAlpha = 0.5;
        h2(2).Color = 'b';
        xlabel(sXLabel);
        ylabel('Freq.');
        if ~isempty(xLim)
            xlim([-maxFR/100 xLim]);
        else
            xlim([-maxFR/100 maxFR]);
        end
        legend(sLegend1, '', sLegend2, '')
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)  

        subplot(1,2,2);
        [h1,stats1] = cdfplot(distr1);
        h1.LineWidth = 1.5;
        h1.Color = 'k';
        hold on
        [h2,stats2] = cdfplot(distr2);
        h2.LineWidth = 1.5;
        h2.Color = 'b';
        xlabel(sXLabel);
        ylabel('F(x)');
        if ~isempty(xLim)
            xlim([-1 xLim]);
        else
            xlim([-1 maxFR]);
        end
        legend(sLegend1, sLegend2, 'Location', 'southeast');
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)  

        sgtitle([sTitle ' mean1=' num2str(mean(distr1),'%.2f') ' mean2=' num2str(mean(distr2),'%.2f')])

        sFolder = [pathToFigureFolder num2str(unitID)];
        if ~isempty(neuronType)
            sFolder = [sFolder '_' neuronType];
        end

        print([sFolder '/' neuronType '_' sFileName strTrialType '.tif'], '-dtiff', '-r200');
        close all;
end