%%%% PLOT PSTH %%%%%%%%%%%%
% spikeTimesAligned: Spike times in sec
%
% SO 4/18/2025 Hull Lab
function [spikeRates] = plotHistogram(arrData, xMin, xMax, sXLabel, sYLabel, sTitle, sFile, bSuperImpose)
        globals;

        binSize = 1; %0.05; % sec = 5 ms
        edges = -xMin-binSize:binSize:xMax+binSize;
        edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;

        if ~bSuperImpose
            f = figure;
            f.Position = [globalX globalY globalW globalH];
            hold on  
        end

%         smtRate = zeros(length(cellData), length(edgesPlt));
%         for ind=1:length(cellData)
%             trialCount = length(cellData{ind});
%             binCounts = histcounts(cellData{ind},edges);
%             dataRate = binCounts/(trialCount*binSize);
%             smtRate(ind,:) = smooth(edgesPlt,dataRate, SPIKE_SPAN, SMOOTH_TYPE_L);            
%         end

        binCounts = histcounts(arrData,edges);
        dataRate = binCounts/binSize;
%         smtRate = smooth(edgesPlt,dataRate, SPIKE_SPAN, SMOOTH_TYPE_L); 
        plot(edgesPlt, dataRate, 'LineWidth',2.5); %, 'Color', 'b');
            
        if ~bSuperImpose
            set(gca,'box','off');                
            ylabel(sYLabel);
            xlabel(sXLabel);
            xlim([xMin 50]);
            xline(mean(arrData),'--',num2str(mean(arrData),'%.1f'));
            ylim([0 70]);
            set(gca,'TickDir','out');
            set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5);
            title(sTitle);            
            print([sFile '.tif'], '-dtiff', '-r200');       
            exportgraphics(f,[sFile '.pdf'], 'ContentType', 'vector', 'Resolution', 1200);
            savefig(f,[sFile '.fig']);
            close all;
        end
end