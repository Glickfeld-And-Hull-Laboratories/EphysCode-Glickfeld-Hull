%%%% Raster core function %%%%%%%%%%%%
% spikeTimes (s): Spike times in sec
% markRelevantTimes (s): Mark behaviorally relevant times on the plot
% startTime, endTime: To calculate spike rate within a given period of time
% 
% SO 12/14/2022 Hull Lab
function spikeRates=plotRaster(unit, spikeTimes, laserOnsetTimesGLX) %, startTime, endTime)

    globals;
    stepSize=3;
    tickSize=10;    % distance between trials on y-axis in the plot
    magnEffect = 1.1;

    f = figure;
    f.Position = [globalX globalY globalW globalH];
    hold on

    laserSwipeCount = length(spikeTimes);
    spikeRates = zeros(laserSwipeCount,1);

    lineTriplet = [.3 .3 .3]; % gray line for spikes

%     alpha = 0.5;
%     rgbQuartet = {};
%     for iColor=1:length(colors)
%         if colors{iColor}=='r'
%             rgbQuartet{iColor} = [1 0 0 alpha];
%         elseif colors{iColor}=='b'
%             rgbQuartet{iColor} = [0 0 1 alpha];
%         elseif colors{iColor}=='m'
%             rgbQuartet{iColor} = [1 0 1 alpha];
%         end
%     end

    arrSpikeTimes = [];

    for indLaser=1:laserSwipeCount 
        if ~isempty(spikeTimes{indLaser})
            arrSpikeTimes = [arrSpikeTimes; spikeTimes{indLaser}];
            numspikes=length(spikeTimes{indLaser});
            xx=ones(stepSize*numspikes,1)*nan;
            yy=ones(stepSize*numspikes,1)*nan;

            %scale the time axis to ms
            xx(1:stepSize:stepSize*numspikes)=spikeTimes{indLaser};
            xx(2:stepSize:stepSize*numspikes)=spikeTimes{indLaser};
            yy(1:stepSize:stepSize*numspikes)=(indLaser-1)*tickSize;
            yy(2:stepSize:stepSize*numspikes)=yy(1:stepSize:stepSize*numspikes)+tickSize;
            plot(xx, yy, 'color', lineTriplet, 'LineWidth',5); % plot spikes  in dark gray [.4 .4 .4]
           
            spikeRates(indLaser)=numspikes/(PRE_TIME_LASER + POST_TIME_LASER); % endOfTrial-startOfTrial
        end
    end
    
%     if fixedHoldStartsAtTrial>0
%         yline(fixedHoldStartsAtTrial*tickSize,'k', 'LineWidth',3, 'alpha',0.5);
%     end
    xlim([-PRE_TIME_LASER*1.05 POST_TIME_LASER*1.05]);
    xt = get(gca,'ytick');    
    set(gca,'YTick',xt, 'yticklabel',xt/tickSize) % normalize back again to actual trial numbers
    
    globalDuration = -1;
    for indGain=1:length(GAIN_CHANGE_MOMENTS_BASELINE)
        moment = GAIN_CHANGE_MOMENTS_BASELINE(indGain,3);
        power = GAIN_CHANGE_MOMENTS_BASELINE(indGain,2);
        duration = GAIN_CHANGE_MOMENTS_BASELINE(indGain,4);
        indGainOnset = find(laserOnsetTimesGLX>moment,1);
        if duration~=globalDuration
            globalDuration = duration;           
            % Draw laser duration lines everytime duration changes
            plot([0 duration/1000], [1+indGainOnset*tickSize 1+indGainOnset*tickSize],'-', 'LineWidth',10, 'Color', [.4 .4 0.6 0.4]);
            text(duration/1000,1+indGainOnset*tickSize+10, [num2str(duration) ' ms'],'FontSize',20, 'Color', [.4 .4 1]);
            %patch([0 duration/1000 duration/1000 0], [1+indGainOnset*tickSize 1+indGainOnset*tickSize 1+(indGainOnset*tickSize)+magnEffect 1+(indGainOnset*tickSize)+magnEffect], 'blue', 'FaceAlpha',0.3, 'EdgeColor', 'none'); % fill between
        end        
        if power~=0
            yline(indGainOnset*tickSize,'--', ['Pow=' num2str(power,'%.2f') ' mW'],'LineWidth',0.5, 'FontWeight','bold', 'FontSize',8, 'Color', [.7 .4 0 0.1]);        
        end
    end
    
    indFirstDrugMoment = find(laserOnsetTimesGLX>MOMENT_OF_1ST_DRUG_PUT_IN,1);
    yline(indFirstDrugMoment*tickSize,'-', [FIRST_DRUG ' Wash-In'],'LineWidth',3, 'FontWeight','bold', 'FontSize',PLOT_FONT_SIZE, 'Color', [1 0 0 0.9]);

    globalDuration = -1;
    for indGain=1:length(GAIN_CHANGE_MOMENTS_1)
        moment = GAIN_CHANGE_MOMENTS_1(indGain,3);
        power = GAIN_CHANGE_MOMENTS_1(indGain,2);
        duration = GAIN_CHANGE_MOMENTS_1(indGain,4);
        indGainOnset = find(laserOnsetTimesGLX>moment,1);
        if duration~=globalDuration
            globalDuration = duration;
            % Draw laser duration lines everytime duration changes
            plot([0 duration/1000], [1+indGainOnset*tickSize 1+indGainOnset*tickSize],'-', 'LineWidth',10, 'Color', [.4 .4 0.6 0.4]);
            text(duration/1000,1+indGainOnset*tickSize, [num2str(duration) ' ms'],'FontSize',20,'Color', [.4 .4 1]);
            %patch([0 duration/1000 duration/1000 0], [1+indGainOnset*tickSize 1+indGainOnset*tickSize 1+(indGainOnset*tickSize)+magnEffect 1+(indGainOnset*tickSize)+magnEffect], 'blue', 'FaceAlpha',0.3, 'EdgeColor', 'none'); % fill between
        end    
        if power~=0
            yline(indGainOnset*tickSize,'--', ['Pow=' num2str(power,'%.2f') ' mW'],'LineWidth',0.5, 'FontWeight','bold', 'FontSize',8, 'Color', [.7 .4 0 0.1]);
        end
    end

    if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
        indSecondDrugMoment = find(laserOnsetTimesGLX>MOMENT_OF_2ND_DRUG_PUT_IN,1);
        yline(indSecondDrugMoment*tickSize,'-', [SECOND_DRUG ' Wash-In'],'LineWidth',3, 'FontWeight','bold', 'FontSize',PLOT_FONT_SIZE, 'Color', [0 0 1 0.9]);
    
        globalDuration = -1;
        for indGain=1:length(GAIN_CHANGE_MOMENTS_2)
            moment = GAIN_CHANGE_MOMENTS_2(indGain,3);
            power = GAIN_CHANGE_MOMENTS_2(indGain,2);
            duration = GAIN_CHANGE_MOMENTS_2(indGain,4);
            indGainOnset = find(laserOnsetTimesGLX>moment,1);
            if isempty(indGainOnset)
                indGainOnset = length(laserOnsetTimesGLX);
            end
            if duration~=globalDuration
                globalDuration = duration;
                % Draw laser duration lines everytime duration changes
                plot([0 duration/1000], [1+indGainOnset*tickSize 1+indGainOnset*tickSize],'-', 'LineWidth',10, 'Color', [.4 .4 0.6 0.4]);
                text(duration/1000,1+indGainOnset*tickSize, [num2str(duration) ' ms'],'FontSize',20,'Color', [.4 .4 1]);
                %patch([0 duration/1000 duration/1000 0], [1+indGainOnset*tickSize 1+indGainOnset*tickSize 1+(indGainOnset*tickSize)+magnEffect 1+(indGainOnset*tickSize)+magnEffect], 'blue', 'FaceAlpha',0.3, 'EdgeColor', 'none'); % fill between
            end   
            if power~=0
                yline(indGainOnset*tickSize,'--', ['Pow=' num2str(power,'%.2f') ' mW'],'LineWidth',0.5, 'FontWeight','bold', 'FontSize',8, 'Color', [.7 .4 0 0.1]);
            end
        end
    end

    xlabel('Time (s)');
    ylabel('Trials');
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)

%     % PSTH PART
%     yyaxis right
%     binCounts = histcounts(arrSpikeTimes,EDGES_PSTH_LASER);
%     binnedSpikeRates = binCounts/(laserSwipeCount*BIN_SIZE_PSTH); % averaged over trials and specified bin
%     edgesPlt = EDGES_PSTH_LASER(1:end-1)+(EDGES_PSTH_LASER(2)-EDGES_PSTH_LASER(1))/2;
%     smtSpikeRates = smooth(edgesPlt,binnedSpikeRates, 0.2, SMOOTH_TYPE_R);
%     plot(edgesPlt(2:end-1), smtSpikeRates(2:end-1), 'LineWidth',3, 'LineStyle','-', 'Color', 'k');
%     ylabel('Spikes/s');

    %ylim([0 max(smtSpikeRates)*1.1]);
    title(['Unit=' num2str(unit.id) '(' unit.neuronType ') FR=' num2str(mean(spikeRates),'%.2f') ' spk/s']);
    
    print([pathToRasterPSTH '/rasterPsth_' num2str(unit.id) '.tif'], '-dtiff', '-r100');
    exportgraphics(f,[pathToRasterPSTH '/rasterPsth_' num2str(unit.id) '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
    close all;
end