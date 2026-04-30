function postPlot(fig, sXLabel, sYLabel, xMin, xMax, yMin, yMax, sTitle, sFile)

        globals;
        
        sEarlyvsLate = '';
        if ~isempty(EARLY_VS_LATE_LICK)
            if strcmp(EARLY_VS_LATE_LICK,EARLY_LICK)
                sEarlyvsLate = ' EarlyLicks';
            else
                sEarlyvsLate = ' LateLicks';
            end
        end

        set(gca,'box','off');     
        
        if ~isempty(sXLabel)
            xlabel(sXLabel);
        end

        if ~isempty(sYLabel)
            ylabel(sYLabel);
        end
        
        if ~isempty(xMin) && ~isempty(xMax) && xMin<xMax
            xlim([xMin xMax]);
        end
        
        if ~isempty(yMin) && ~isempty(yMax) && yMin<yMax
            % Get all line/scatter objects from the figure
            ax = gca;  % or specify: ax = fig.CurrentAxes;
            
            % Get all plotted data objects
            dataObjects = ax.Children;
            
            % Loop through and collect all Y data
            allY = [];
            for i = 1:length(dataObjects)
                if isprop(dataObjects(i), 'YData')
                    allY = [allY, dataObjects(i).YData(:)'];
                end
            end

            % Set ylim with some padding
            padding = 0.1 * (max(allY) - min(allY));
            dataDrivenYMin = min(allY) - padding;
            dataDrivenYMax = max(allY) + padding;
            % if we cannot use standart yLim, use data-driven guesses otherwise you cannot see the data plotted
            if 0 %yMin>dataDrivenYMin || yMax<dataDrivenYMax
                ylim([dataDrivenYMin, dataDrivenYMax]);
            else
                ylim([yMin yMax]);
            end
        end

        set(gca,'TickDir','out');
        set(gca,'FontName','Arial','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5);
        
        % Just to patch pwelch function's not-allowing-me-change-line-thickness
        a=gca;
        if ~isempty(a.Children) && length(a.Children)==1
            a.Children.LineWidth = 1.5;
        end
        title([sTitle sEarlyvsLate]);
        
        if ~isempty(xMin) && ~isempty(xMax) && MODE_ALIGNMENT==MODE_ALIGNMENT_TO_CLICK % contains(sFile,'alignedToclick')
            xline(-0.6827,'LineStyle','--','LineWidth',1.5,'Color','k');
        end
        
        try
            exportgraphics(fig,[sFile sEarlyvsLate '.pdf'], 'ContentType', 'vector', 'Resolution', 1200);
            print(fig,[sFile sEarlyvsLate '.tif'], '-dtiff', '-r200');   
            if ~isempty(fig)
                savefig(fig,[sFile sEarlyvsLate '.fig']);
            end
        catch e
            e.message
        end        
        close(fig);
end