%%%% Raster core function %%%%%%%%%%%%
% spikeTimes (s): Spike times in sec
% markRelevantTimes (s): Mark behaviorally relevant times on the plot
% startTime, endTime: To calculate spike rate within a given period of time
% 
% SO 12/14/2022 Hull Lab
function spikeRates=plotRasterPreTimeNoMaster(unit, spikeTimes, laserOnsetTimesGLX, unitMaster, spikeTimesMaster) %, startTime, endTime)

    globals;
    stepSize=3;
    tickSize=5;    % distance between trials on y-axis in the plot
        
    f = figure;
    f.Position = [globalX globalY globalW globalH];
    hold on

    laserSwipeCount = length(spikeTimes);
    spikeRates = zeros(laserSwipeCount,1);
    spikeRatesMaster = zeros(laserSwipeCount,1);

    lineTriplet = [.3 .3 .3]; % gray line for spikes

    arrSpikeTimes = [];
    arrSpikeTimesMaster = [];

    for indLaser=1:laserSwipeCount 
        if ~isempty(spikeTimes{indLaser})            
            spikeTimesofTrial = spikeTimes{indLaser};
            indsPre = find(spikeTimesofTrial<0);
            spikeTimesMasterofTrial = spikeTimesMaster{indLaser};
            indsMasterPre = find(spikeTimesMasterofTrial<0);

            if ~isempty(indsPre) && ~isempty(indsMasterPre)
                tobeRemoved = [];
                for ii=1:length(indsPre)
                    slaveSpikeTime = spikeTimesofTrial(indsPre(ii));
                    if ~isempty(find(spikeTimesMasterofTrial<slaveSpikeTime,1)) % look if there is any MF earlier than this slave spike
                        tobeRemoved = [tobeRemoved indsPre(ii)];
                    end
                end
                if ~isempty(tobeRemoved)
                    spikeTimesofTrial = spikeTimesofTrial(setdiff(1:end,tobeRemoved)); % remove the ones following a MF spike
                end
            end

            arrSpikeTimes = [arrSpikeTimes; spikeTimesofTrial];
            numspikes=length(spikeTimesofTrial);
            xx=ones(stepSize*numspikes,1)*nan;
            yy=ones(stepSize*numspikes,1)*nan;

            %scale the time axis to ms
            xx(1:stepSize:stepSize*numspikes)=spikeTimesofTrial;
            xx(2:stepSize:stepSize*numspikes)=spikeTimesofTrial;
            yy(1:stepSize:stepSize*numspikes)=(indLaser-1)*tickSize;
            yy(2:stepSize:stepSize*numspikes)=yy(1:stepSize:stepSize*numspikes)+tickSize;
            plot(xx, yy, 'color', lineTriplet, 'LineWidth',1.2); % plot spikes  in dark gray [.4 .4 .4]
           
            spikeRates(indLaser)=numspikes/(PRE_TIME_LASER + POST_TIME_LASER); % endOfTrial-startOfTrial
        end

%         if ~isempty(spikeTimesMaster{indLaser})            
%             spikeTimesofTrial = spikeTimesMaster{indLaser};
%             arrSpikeTimesMaster = [arrSpikeTimesMaster; spikeTimesofTrial];
%             numspikes=length(spikeTimesofTrial);
%             xx=ones(stepSize*numspikes,1)*nan;
%             yy=ones(stepSize*numspikes,1)*nan;
% 
%             %scale the time axis to ms
%             xx(1:stepSize:stepSize*numspikes)=spikeTimesofTrial;
%             xx(2:stepSize:stepSize*numspikes)=spikeTimesofTrial;
%             yy(1:stepSize:stepSize*numspikes)=(indLaser-1)*tickSize;
%             yy(2:stepSize:stepSize*numspikes)=yy(1:stepSize:stepSize*numspikes)+tickSize;
%             plot(xx, yy, 'color', 'r', 'LineWidth',1.2);
%            
%             spikeRatesMaster(indLaser)=numspikes/(PRE_TIME_LASER + POST_TIME_LASER); % endOfTrial-startOfTrial
%         end
    end
    
%     if fixedHoldStartsAtTrial>0
%         yline(fixedHoldStartsAtTrial*tickSize,'k', 'LineWidth',3, 'alpha',0.5);
%     end
    xlim([-PRE_TIME_LASER*1.05 POST_TIME_LASER*1.05]);
    xt = get(gca,'ytick');    
    set(gca,'YTick',xt, 'yticklabel',xt/tickSize) % normalize back again to actual trial numbers
    
%     for indGain=1:length(GAIN_CHANGE_MOMENTS)
%         moment = GAIN_CHANGE_MOMENTS(indGain,3);
%         power = GAIN_CHANGE_MOMENTS(indGain,2);
%         indGainOnset = find(laserOnsetTimesGLX>moment,1);
%         yline(indGainOnset*tickSize,'--b', ['Power = ' num2str(power,'%.2f') ' mW'],'LineWidth',3, 'FontWeight','bold', 'FontSize',PLOT_FONT_SIZE);
%     end

    globalDuration = -1;
    for indGain=1:length(GAIN_CHANGE_MOMENTS_BASELINE)
        moment = GAIN_CHANGE_MOMENTS_BASELINE(indGain,3);
        power = GAIN_CHANGE_MOMENTS_BASELINE(indGain,2);
        duration = GAIN_CHANGE_MOMENTS_BASELINE(indGain,4);
        indGainOnset = find(laserOnsetTimesGLX>moment,1);
        if duration~=globalDuration
            globalDuration = duration;
            durTxt = [' Dur=' num2str(duration,'%.2f') ' ms'];            
            plot([0 duration/1000], [1+indGainOnset*tickSize 1+indGainOnset*tickSize],'-', 'LineWidth',3, 'Color', [.7 .4 0.6 0.9]);
        else
            durTxt = '';
        end        
        yline(indGainOnset*tickSize,'--', ['Pow=' num2str(power,'%.2f') ' mW' durTxt],'LineWidth',0.5, 'FontWeight','bold', 'FontSize',8, 'Color', [.7 .4 0 0.1]);
    end
    
    indFirstDrugMoment = find(laserOnsetTimesGLX>MOMENT_OF_1ST_DRUG_PUT_IN,1);
    yline(indFirstDrugMoment*tickSize,'-', [FIRST_DRUG ' Put In'], 'LineWidth',3, 'FontWeight','bold', 'FontSize',PLOT_FONT_SIZE, 'Color', [1 0 0 0.9]);

    globalDuration = -1;
    for indGain=1:length(GAIN_CHANGE_MOMENTS_1)
        moment = GAIN_CHANGE_MOMENTS_1(indGain,3);
        power = GAIN_CHANGE_MOMENTS_1(indGain,2);
        duration = GAIN_CHANGE_MOMENTS_1(indGain,4);
        indGainOnset = find(laserOnsetTimesGLX>moment,1);
        if duration~=globalDuration
            globalDuration = duration;
            durTxt = [' Dur=' num2str(duration,'%.2f') ' ms'];
            plot([0 duration/1000], [1+indGainOnset*tickSize 1+indGainOnset*tickSize],'-', 'LineWidth',3, 'Color', [.7 .4 0.6 0.9]);
        else
            durTxt = '';
        end        
        yline(indGainOnset*tickSize,'--', ['Pow=' num2str(power,'%.2f') ' mW' durTxt],'LineWidth',0.5, 'FontWeight','bold', 'FontSize',8, 'Color', [.7 .4 0 0.1]);
    end

    indSecondDrugMoment = find(laserOnsetTimesGLX>MOMENT_OF_2ND_DRUG_PUT_IN,1);
    yline(indSecondDrugMoment*tickSize,'-', [SECOND_DRUG ' Put In'], 'LineWidth',3, 'FontWeight','bold', 'FontSize',PLOT_FONT_SIZE, 'Color', [0 0 1 0.9]);

    globalDuration = -1;
    for indGain=1:length(GAIN_CHANGE_MOMENTS_2)
        moment = GAIN_CHANGE_MOMENTS_2(indGain,3);
        power = GAIN_CHANGE_MOMENTS_2(indGain,2);
        duration = GAIN_CHANGE_MOMENTS_2(indGain,4);
        indGainOnset = find(laserOnsetTimesGLX>moment,1);
        if duration~=globalDuration
            globalDuration = duration;
            durTxt = [' Dur=' num2str(duration,'%.2f') ' ms'];
            plot([0 duration/1000], [1+indGainOnset*tickSize 1+indGainOnset*tickSize],'-', 'LineWidth',3, 'Color', [.7 .4 0.6 0.9]);
        else
            durTxt = '';
        end        
        yline(indGainOnset*tickSize,'--', ['Pow=' num2str(power,'%.2f') ' mW' durTxt],'LineWidth',0.5, 'FontWeight','bold', 'FontSize',8, 'Color', [.7 .4 0 0.1]);
    end

    xlabel('Time (s)');
    ylabel('Trials');
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)

    yyaxis right
    binCounts = histcounts(arrSpikeTimes,EDGES_PSTH_LASER);
    binnedSpikeRates = binCounts/(laserSwipeCount*BIN_SIZE_PSTH); % averaged over trials and specified bin
    edgesPlt = EDGES_PSTH_LASER(1:end-1)+(EDGES_PSTH_LASER(2)-EDGES_PSTH_LASER(1))/2;
    smtSpikeRates = smooth(edgesPlt,binnedSpikeRates, SPIKE_SPAN, SMOOTH_TYPE_R);
    plot(edgesPlt(2:end-1), smtSpikeRates(2:end-1), 'LineWidth',3, 'LineStyle','-', 'Color', 'k');
    ylabel('Spikes/s');
    %ylim([0 max(smtSpikeRates)*1.1]);
    title(['Slave Unit=' num2str(unit.id) '(' unit.neuronType ') FR=' num2str(mean(spikeRates),'%.2f') ' spk/s with no preceeding MF spikes before time zero']);
    
    print([pathToRasterPSTH '/rasterPsth_' num2str(unit.id) '.tif'], '-dtiff', '-r100');
    close all;
end