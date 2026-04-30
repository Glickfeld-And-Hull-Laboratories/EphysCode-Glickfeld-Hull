function plotSSRateChange(pair00, pair01, pair10, pair11, csID, ssID, sFolderName, sFileName, sTitle, fixedOrRandom)
    globals;
    
    SPAN = 0.2;
    BIN_SIZE_FR = 0.002; % sec = 2 ms
    EDGES_FR = SS_ANALYSIS_RANGE(1)-BIN_SIZE_FR:BIN_SIZE_FR:SS_ANALYSIS_RANGE(2)+BIN_SIZE_FR;
    EDGES_TO_PLOT_FR = EDGES_FR(1:end-1)+BIN_SIZE_FR/2; % shift to the center of bins while plotting

    % ************ 0-0 Pair (NoCS-NoCS trial pairs) ***************
    if ~isempty(pair00)
        spikeTimes00_1 = cell2mat(pair00(:,1));
        binCounts00_1 = histcounts(spikeTimes00_1,EDGES_FR);
        spikeTimes00_2 = cell2mat(pair00(:,2));
        binCounts00_2 = histcounts(spikeTimes00_2,EDGES_FR);
        binCounts00 = binCounts00_2-binCounts00_1; % Firing rate difference from trial n+1 to trial n
        trialCount00 = length(pair00);
        spikeRates00 = binCounts00/(trialCount00*BIN_SIZE_FR); % averaged over trials and specified bin
    end
    % ************ 0-1 Pair (NoCS-CS trial pairs) ***************
    if ~isempty(pair01)
        spikeTimes01_1 = cell2mat(pair01(:,1));
        binCounts01_1 = histcounts(spikeTimes01_1,EDGES_FR);
        spikeTimes01_2 = cell2mat(pair01(:,2));
        binCounts01_2 = histcounts(spikeTimes01_2,EDGES_FR);
        binCounts01 = binCounts01_2-binCounts01_1; % Firing rate difference from trial n+1 to trial n
        trialCount01 = length(pair01);
        spikeRates01 = binCounts01/(trialCount01*BIN_SIZE_FR); % averaged over trials and specified bin
    end
    % ************ 1-0 Pair (CS-NoCS trial pairs) ***************
    if ~isempty(pair10)
        spikeTimes10_1 = cell2mat(pair10(:,1));
        binCounts10_1 = histcounts(spikeTimes10_1,EDGES_FR);
        spikeTimes10_2 = cell2mat(pair10(:,2));
        binCounts10_2 = histcounts(spikeTimes10_2,EDGES_FR);
        binCounts10 = binCounts10_2-binCounts10_1; % Firing rate difference from trial n+1 to trial n    
        trialCount10 = length(pair10);
        spikeRates10 = binCounts10/(trialCount10*BIN_SIZE_FR); % averaged over trials and specified bin
    end
    % ************ 1-0 Pair (CS-NoCS trial pairs) ***************
    if ~isempty(pair11)
        spikeTimes11_1 = cell2mat(pair11(:,1));
        binCounts11_1 = histcounts(spikeTimes11_1,EDGES_FR);
        spikeTimes11_2 = cell2mat(pair11(:,2));
        binCounts11_2 = histcounts(spikeTimes11_2,EDGES_FR);
        binCounts11 = binCounts11_2-binCounts11_1; % Firing rate difference from trial n+1 to trial n    
        trialCount11 = length(pair11);
        spikeRates11 = binCounts11/(trialCount11*BIN_SIZE_FR); % averaged over trials and specified bin
    end

    % ****************** PLOTTING *******************************
    flag00 = exist("spikeRates00","var");
    flag01 = exist("spikeRates01","var");
    flag10 = exist("spikeRates10","var");
    flag11 = exist("spikeRates11","var");

    size00 = size(pair00,1);
    size01 = size(pair01,1);
    size10 = size(pair10,1);
    size11 = size(pair11,1);

    if flag00 && size00>=MIN_SAMPLE_SIZE && ((flag01 && size01>=MIN_SAMPLE_SIZE) || (flag10 && size10>=MIN_SAMPLE_SIZE) || (flag11 && size11>=MIN_SAMPLE_SIZE))
        f = figure;
        f.Position = [globalX globalY globalW globalH];
        hold on
        grid on
    
        %scatter(EDGES_TO_PLOT_FR, spikeRates10, [] ,'red','filled','MarkerFaceAlpha',.6);
        allDataPoints = [];
        legends = {};
        compareAny=0;
        if flag00 && size00>=MIN_SAMPLE_SIZE && PLOT_00
            ySmoothed_00 = smooth(spikeRates00, SPAN, SMOOTH_TYPE);
            plot(EDGES_TO_PLOT_FR,ySmoothed_00,'b','LineWidth',1.5);
            allDataPoints = [ySmoothed_00];
            legends = {['0-0 (blue) n=' num2str(size(pair00,1))]};
        end
        if flag01 && size01>=MIN_SAMPLE_SIZE && PLOT_01
            ySmoothed_01 = smooth(spikeRates01, SPAN, SMOOTH_TYPE);
            plot(EDGES_TO_PLOT_FR,ySmoothed_01,'Color', [0.4660 0.6740 0.1880],'LineWidth',1.5);
            allDataPoints = [allDataPoints; ySmoothed_01];
            legends = [legends {['0-1 (green) n=' num2str(size(pair01,1))]}];
            compareAny=1;
        end
        if flag10 && size10>=MIN_SAMPLE_SIZE && PLOT_10
            ySmoothed_10 = smooth(spikeRates10, SPAN, SMOOTH_TYPE);
            plot(EDGES_TO_PLOT_FR,ySmoothed_10,'r','LineWidth',1.5);
            allDataPoints = [allDataPoints; ySmoothed_10];
            legends = [legends {['1-0 (red) n=' num2str(size(pair10,1))]}];
            compareAny=1;
        end
        if flag11 && size11>=MIN_SAMPLE_SIZE && PLOT_11
            ySmoothed_11 = smooth(spikeRates11, SPAN, SMOOTH_TYPE);
            plot(EDGES_TO_PLOT_FR,ySmoothed_11,'m','LineWidth',1.5);
            allDataPoints = [allDataPoints; ySmoothed_11];
            legends = [legends {['1-1 (magenta) n=' num2str(size(pair11,1))]}];
            compareAny=1;
        end   
        
        if compareAny % If any of the comparison is generated other than 0-0, then generate and save this plot
            legend(legends);
            
            if fixedOrRandom
                sTxt = 'Fixed';
            else
                sTxt = 'Random';
            end
            
            title([sTxt ' SS (' ssID ') rate change based on CS (' csID ') ' sTitle]);
            xlim([SS_ANALYSIS_RANGE(1)+0.01 SS_ANALYSIS_RANGE(2)-0.01]); % to avoid edges cos moving average just got crazy around the edges    
            minYLim = min(allDataPoints);
            maxYLim = max(allDataPoints);   
            if minYLim~=0 && maxYLim~=0
                ylim([minYLim*1.1 maxYLim*1.1]);
            end
            xlabel('Time from event (s)');
            ylabel('SS rate change (sp/s)');
            set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE) 

            sFileName = ['SS_' ssID '_RateChangeBasedon_CS_' csID sFileName '_SSrange' num2str(SS_ANALYSIS_RANGE(2)) '_' sTxt];
            sFullPath = [pathToFigureFolder sFolderName '/' csID '_' ssID '/'];
            if ~exist(sFullPath)
                mkdir(sFullPath);
            end        
            print([sFullPath sFileName '.tif'], '-dtiff', '-r200');
        end
    end
end