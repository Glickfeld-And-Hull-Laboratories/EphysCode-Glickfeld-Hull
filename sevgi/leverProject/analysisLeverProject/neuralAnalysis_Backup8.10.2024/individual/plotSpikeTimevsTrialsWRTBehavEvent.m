function plotSpikeTimevsTrialsWRTBehavEvent(spikesTopLeft, spikesTopRight, spikesBottomLeft, spikesBottomRight, sTitle, sXLabel, sYLabel, sGeneralTitle, sFolder, sFileName, strTrialType)

        globals;
        SPAN = 0.5;

        f = figure;
        f.Position = [globalX globalY globalW globalH];

        %****************************************************************%

        subplot(2,2,1)
        hold on
        grid on
        if ~isempty(spikesTopLeft)
            x = [1:length(spikesTopLeft)];
            y = cellfun(@mean,spikesTopLeft);
            y(isnan(y))= 0;
            scatter(x,y,[],'black','filled','MarkerFaceAlpha',.6);
            ySmoothed = smooth(y, SPAN, SMOOTH_TYPE); %'moving');
            plot(x,ySmoothed,'k','LineWidth',1.5);
    
    %         p = polyfit(x,y,1);
    %         yfit = p(1)*x+p(2);        
    %         plot(x,yfit,'k-.','LineWidth',1.5); 
    %         y1 = polyval(p,x);
    %         plot(x,yfit,'r.','LineWidth',1.5);
            
            minY = min(y);
            maxY = max(y);
            % Align equally around zero
            if abs(minY)>abs(maxY)
                maxY = abs(minY);
            else
                minY = -abs(maxY);
            end   
            if minY==maxY
                maxY = minY+1;
            end
            ylim([minY*1.1 maxY*1.1]);
            xlabel(sXLabel);
            ylabel(sYLabel{1});
            
            sCorrTitle = '';
            [r,pCorr] = corrcoef(x,y);
            if pCorr(1,2)<=P_VALUE_THRESHOLD
                sCorrTitle = [' r=' num2str(r(1,2),'%.2f')];
            end
            arrSpikesTopLeft = cell2mat(spikesTopLeft);
            title([sTitle{1} ' mean=' num2str(mean(arrSpikesTopLeft),'%.2f') sCorrTitle]);
        end
        %****************************************************************%

        subplot(2,2,2)
        hold on
        grid on
        x = [1:length(spikesTopRight)];
        y = cellfun(@mean,spikesTopRight);
        y(isnan(y))= 0;
        scatter(x,y,[],'black','filled','MarkerFaceAlpha',.6);
        ySmoothed = smooth(y, SPAN, SMOOTH_TYPE);
        plot(x,ySmoothed,'k','LineWidth',1.5);        
        minY = min(y);
        maxY = max(y);
        % Align equally around zero
        if abs(minY)>abs(maxY)
            maxY = abs(minY);
        else
            minY = -abs(maxY);
        end        
        ylim([minY*1.1 maxY*1.1]);
        xlabel(sXLabel);
        ylabel(sYLabel{2});    
        
        sCorrTitle = '';
        [r,pCorr] = corrcoef(x,y);
        if pCorr(1,2)<=P_VALUE_THRESHOLD
            sCorrTitle = [' r=' num2str(r(1,2),'%.2f')];
        end
        arrSpikesTopRight = cell2mat(spikesTopRight);
        title([sTitle{2} ' mean=' num2str(mean(arrSpikesTopRight),'%.2f') sCorrTitle]);

        %****************************************************************%
        
        subplot(2,2,3)
        hold on
        grid on
        if ~isempty(spikesBottomLeft)
            x = [1:length(spikesBottomLeft)];
            y = cellfun(@mean,spikesBottomLeft);
            y(isnan(y))= 0;
            scatter(x,y,[],'black','filled','MarkerFaceAlpha',.6);
            ySmoothed = smooth(y, SPAN, SMOOTH_TYPE);
            plot(x,ySmoothed,'k','LineWidth',1.5);        
            minY = min(y);
            maxY = max(y);
            % Align equally around zero
            if abs(minY)>abs(maxY)
                maxY = abs(minY);
            else
                minY = -abs(maxY);
            end        
            ylim([minY*1.1 maxY*1.1]);
            xlabel(sXLabel);
            ylabel(sYLabel{3});    
            
            sCorrTitle = '';
            [r,pCorr] = corrcoef(x,y);
            if pCorr(1,2)<=P_VALUE_THRESHOLD
                sCorrTitle = [' r=' num2str(r(1,2),'%.2f')];
            end
            arrSpikesBottomLeft = cell2mat(spikesBottomLeft);
            title([sTitle{3} ' mean=' num2str(mean(arrSpikesBottomLeft),'%.2f') sCorrTitle]);
        end
        %****************************************************************%

        subplot(2,2,4)
        hold on
        grid on
        
        if ~isempty(spikesBottomRight)
            x = [1:length(spikesBottomRight)];
            y = cellfun(@mean,spikesBottomRight);
            y(isnan(y))= 0;
            scatter(x,y,[],'black','filled','MarkerFaceAlpha',.6);
            ySmoothed = smooth(y, SPAN, SMOOTH_TYPE);
            plot(x,ySmoothed,'k','LineWidth',1.5);        
            minY = min(y);
            maxY = max(y);
            % Align equally around zero
            if abs(minY)>abs(maxY)
                maxY = abs(minY);
            else
                minY = -abs(maxY);
            end        
            ylim([minY*1.1 maxY*1.1]);
            xlabel(sXLabel);
            ylabel(sYLabel{4});    
            
            sCorrTitle = '';
            [r,pCorr] = corrcoef(x,y);
            if pCorr(1,2)<=P_VALUE_THRESHOLD
                sCorrTitle = [' r=' num2str(r(1,2),'%.2f')];
            end
            arrSpikesBottomRight = cell2mat(spikesBottomRight);
            title([sTitle{4} ' mean=' num2str(mean(arrSpikesBottomRight),'%.2f') sCorrTitle]);
        end

        sgtitle([sGeneralTitle ' ' strTrialType ' trials'])        
        print([pathToFigureFolder sFolder '/' sFileName '_' strTrialType '.tif'], '-dtiff', '-r200');                
end
