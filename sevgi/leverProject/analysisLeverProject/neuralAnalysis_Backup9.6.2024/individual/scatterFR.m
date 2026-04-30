%%%% SCATTER Spike rates along the diagonal line to see the differences %%%%%%%%%%%%
% spikeRatesX: Spike rates on X axis
% spikeRatesY: Spike rates on Y axis
%
% SO 2/14/2023 Hull Lab
function scatterFR(spikeRatesX, spikeRatesY, unitID, neuronType, sXLabel, sYLabel, sTitle, strTrialType, sFileName)
        globals;
        f = figure;
        f.Position = [globalX globalY 2*globalW globalH];
        %color = linspace(1,10,length(meanSpikeRateFixedRelease));
        sz = 50; %linspace(1,100,length(meanSpikeRateFixedRelease));
        %alpha = linspace(0.3,1,length(spikeRatesX));
        % Compare spike rates of HOLD and RELEASE
        subplot(1,2,1);
        s = scatter(spikeRatesX,spikeRatesY, sz, 'green', 'filled');
        %s.AlphaData = alpha;
        %s.MarkerFaceAlpha = 'flat';
                
        hold on
        minFR = min([spikeRatesX spikeRatesY]);
        minFR = minFR*0.7;        
        maxFR = max([spikeRatesX spikeRatesY]);
        if minFR==0 % tricks for visualization purposes
            minFR = -maxFR/10;
        end
        maxFR = maxFR*1.2;
        diagonal = linspace(minFR, maxFR, length(spikeRatesX));
        plot(diagonal, diagonal, 'b--')
        xlim([minFR maxFR]);
        ylim([minFR maxFR]);
        xlabel(sXLabel);
        ylabel(sYLabel);
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5) 
                
        subplot(1,2,2);
        x=1:length(spikeRatesX);
        scatter(x,spikeRatesX,sz,"black","filled");
        hold on
        scatter(x,spikeRatesY,sz,"blue","filled");
        xlim([0 length(spikeRatesX)+5]);
        ylim([minFR maxFR]);
        xlabel('Trials');
        ylabel('Firing Rate (spk/s)');
        legend(sXLabel,sYLabel)
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   

        sgtitle([sTitle ' meanX=' num2str(mean(spikeRatesX),'%.2f') ' meanY=' num2str(mean(spikeRatesY),'%.2f') ' spk/s'])
        sFolder = [pathToFigureFolder num2str(unitID)];
        if ~isempty(neuronType)
            sFolder = [sFolder '_' neuronType];
        end
        print([sFolder '/' neuronType '_FR_' sFileName strTrialType '.tif'], '-dtiff', '-r200');
        close all;
end