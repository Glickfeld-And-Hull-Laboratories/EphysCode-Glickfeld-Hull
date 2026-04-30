function plotCCGwRasterPSTHWMaster(unit, unitVSSpikeTimesWithMaster, unitVSSpikeTimesWithoutMaster)
    globals;

    globals;
    stepSize=10;
    tickSize=2;    % distance between trials on y-axis in the plot

    idsEmpty = cellfun(@isempty,(unitVSSpikeTimesWithMaster(:,5)));
    timeBWithMaster = cellfun(@max,(unitVSSpikeTimesWithMaster(~idsEmpty,5)));
    timeAWithMaster = [unitVSSpikeTimesWithMaster{~idsEmpty,3}]';
    durationWMaster = timeBWithMaster - timeAWithMaster;

    idsEmpty = cellfun(@isempty,(unitVSSpikeTimesWithoutMaster(:,4)));
    timeBWithoutMaster = cellfun(@max,(unitVSSpikeTimesWithoutMaster(~idsEmpty,4)));    
    timeAWithoutMaster = [timeBWithoutMaster-MASTER_SLAVE_SPIKE_DISTANCE];
    durationWoutMasterTemp = timeBWithoutMaster - timeAWithoutMaster;

    timeA = min(unitVSSpikeTimesWithMaster{1,3}, min(unitVSSpikeTimesWithoutMaster{1,4}));
    timeB = max(max(unitVSSpikeTimesWithMaster{end,5}), max(unitVSSpikeTimesWithoutMaster{end,4}));
    durationWhole = timeB - timeA;
    durationWoutMaster = durationWhole - sum(durationWMaster);

    idsEmpty = cellfun(@isempty,(unitVSSpikeTimesWithMaster(:,5)));
    spikeTimesWithMaster = [unitVSSpikeTimesWithMaster{~idsEmpty,5}];
    spikeRateWithMaster = length(spikeTimesWithMaster)/(size(unitVSSpikeTimesWithMaster,1)*MASTER_SLAVE_SPIKE_DISTANCE); %sum(durationWMaster);

    idsEmpty = cellfun(@isempty,(unitVSSpikeTimesWithoutMaster(:,4)));
    spikeTimesWithoutMaster = [unitVSSpikeTimesWithoutMaster{~idsEmpty,4}];
    spikeRateWithoutMaster = length(spikeTimesWithoutMaster)/(size(unitVSSpikeTimesWithoutMaster,1)*MASTER_SLAVE_SPIKE_DISTANCE); % sum(durationWoutMasterTemp); 

    

    f = figure;
    set(f,'defaultAxesColorOrder',[[0 0 0]; [0 0 0]]);
    f.Position = [globalX globalY globalW globalH];
    %%%%%%%%%%%%%%%%%%%%%%%%% WITH MASTER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(1,2,1);
    hold on
    %yyaxis left

    trialCount = size(unitVSSpikeTimesWithMaster,1);
    spikeRatesWMaster = zeros(trialCount,1);
    ylim([0 tickSize*trialCount]);
    
    arrSlaveUnitSpikeTimesWithMaster = [];
    arrSlaveUnitPreSpikeTimesWithMaster = [];

    for indSpike=1:trialCount             
        %%%%%%% POST SLAVE SPIKES %%%%%%%%%%%%%%%%%%%
        slaveUnitSpikeTimesWithMaster = unitVSSpikeTimesWithMaster{indSpike,5}-unitVSSpikeTimesWithMaster{indSpike,3};
        arrSlaveUnitSpikeTimesWithMaster = [arrSlaveUnitSpikeTimesWithMaster slaveUnitSpikeTimesWithMaster];

        numspikes=length(slaveUnitSpikeTimesWithMaster);
        xx=ones(stepSize*numspikes,1)*nan;
        yy=ones(stepSize*numspikes,1)*nan;

        %scale the time axis to ms
        xx(1:stepSize:stepSize*numspikes)=slaveUnitSpikeTimesWithMaster;
        xx(2:stepSize:stepSize*numspikes)=slaveUnitSpikeTimesWithMaster;
        yy(1:stepSize:stepSize*numspikes)=(indSpike-1)*tickSize;
        yy(2:stepSize:stepSize*numspikes)=yy(1:stepSize:stepSize*numspikes)+tickSize;
        plot(xx, yy, 'color', 'r', 'LineWidth',6); % plot spikes  in dark gray [.4 .4 .4]

        spikeRatesWMaster(indSpike)=numspikes/(MASTER_SLAVE_SPIKE_DISTANCE); % endOfTrial-startOfTrial 

        %%%%%%% PRE SLAVE SPIKES %%%%%%%%%%%%%%%%%%%
        slaveUnitPreSpikeTimesWithMaster = unitVSSpikeTimesWithMaster{indSpike,7}-unitVSSpikeTimesWithMaster{indSpike,3};
        arrSlaveUnitPreSpikeTimesWithMaster = [arrSlaveUnitPreSpikeTimesWithMaster slaveUnitPreSpikeTimesWithMaster];

        numspikes=length(slaveUnitPreSpikeTimesWithMaster);
        xx=ones(stepSize*numspikes,1)*nan;
        yy=ones(stepSize*numspikes,1)*nan;

        %scale the time axis to ms
        xx(1:stepSize:stepSize*numspikes)=slaveUnitPreSpikeTimesWithMaster;
        xx(2:stepSize:stepSize*numspikes)=slaveUnitPreSpikeTimesWithMaster;
        yy(1:stepSize:stepSize*numspikes)=(indSpike-1)*tickSize;
        yy(2:stepSize:stepSize*numspikes)=yy(1:stepSize:stepSize*numspikes)+tickSize;
        plot(xx, yy, 'color', 'r', 'LineWidth',6); % plot spikes  in dark gray [.4 .4 .4]

        preSpikeRatesWMaster(indSpike)=numspikes/(PRE_MASTER_SLAVE_SPIKE_DISTANCE); % endOfTrial-startOfTrial 
    end
    xlim([-PRE_MASTER_SLAVE_SPIKE_DISTANCE*1.05 MASTER_SLAVE_SPIKE_DISTANCE*1.05]);

    xt = get(gca,'ytick');    
    set(gca,'YTick',xt, 'yticklabel',xt/tickSize) % normalize back again to actual trial numbers

    for indGain=1:length(GAIN_CHANGE_MOMENTS)
        moment = GAIN_CHANGE_MOMENTS(indGain,3);
        power = GAIN_CHANGE_MOMENTS(indGain,2);
        indFirstSpike = find([unitVSSpikeTimesWithMaster{:,3}]>moment,1);        
        if ~isempty(indFirstSpike) && indFirstSpike>0
            yline(indFirstSpike*tickSize,'--r', ['Power = ' num2str(power,'%.2f') ' mW'],'LineWidth',2, 'FontWeight','bold', 'FontSize',PLOT_FONT_SIZE);
        end
    end
    
    xlabel('Time from master spike (s)');
    ylabel('Master spike index');
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
        
    yyaxis right    
    idsEmpty = cellfun(@isempty, unitVSSpikeTimesWithMaster(:,4));
    trialCount = sum(~idsEmpty);
    binCountsForward = histcounts(arrSlaveUnitSpikeTimesWithMaster,EDGES_MASTER_SLAVE_SPIKE_DISTANCE);
    binnedSpikeRatesWMaster = binCountsForward/(trialCount*BIN_SIZE_PSTH); % averaged over trials and specified bin
    edgesPltForward = EDGES_MASTER_SLAVE_SPIKE_DISTANCE(1:end-1)+(EDGES_MASTER_SLAVE_SPIKE_DISTANCE(2)-EDGES_MASTER_SLAVE_SPIKE_DISTANCE(1))/2;
    smtSpikeRatesWMaster = smooth(edgesPltForward,binnedSpikeRatesWMaster, SPIKE_SPAN, SMOOTH_TYPE_R);
    plot(edgesPltForward, smtSpikeRatesWMaster, 'LineWidth',1.4, 'Color', 'r');

    idsEmpty = cellfun(@isempty, unitVSSpikeTimesWithMaster(:,6));
    trialCount = sum(~idsEmpty);
    binCountsForward = histcounts(arrSlaveUnitPreSpikeTimesWithMaster,EDGES_PRE_MASTER_SLAVE_SPIKE_DISTANCE);
    binnedPreSpikeRatesWMaster = binCountsForward/(trialCount*BIN_SIZE_PSTH); % averaged over trials and specified bin
    edgesPltForward = EDGES_PRE_MASTER_SLAVE_SPIKE_DISTANCE(1:end-1)+(EDGES_PRE_MASTER_SLAVE_SPIKE_DISTANCE(2)-EDGES_PRE_MASTER_SLAVE_SPIKE_DISTANCE(1))/2;
    smtSpikeRatesWMaster2 = smooth(edgesPltForward,binnedPreSpikeRatesWMaster, SPIKE_SPAN, SMOOTH_TYPE_R);
    plot(edgesPltForward, smtSpikeRatesWMaster2, 'LineWidth',1.4, 'Color', 'r');
    %legend({['with MF rate = ' num2str(mean(binnedSpikeRatesWMaster),'%.2f') ' spk/s'],['witout MF rate = ' num2str(spikeRateWithoutMaster,'%.2f')]});
    ylabel('Spikes/s');
    ylim([0 max(max(smtSpikeRatesWMaster),max(smtSpikeRatesWMaster2))*1.5]);
    title([unit.neuronType '(Unit=' num2str(unit.id) ') VS ' unitVSSpikeTimesWithMaster{1,2} '(Unit=' num2str(unitVSSpikeTimesWithMaster{1,1}) ' pre-rate=' num2str(mean(binnedPreSpikeRatesWMaster),'%.2f') ' spk/s) post-rate=' num2str(mean(binnedSpikeRatesWMaster),'%.2f') ' spk/s)']);
    
    %%%%%%%%%%%%%%%%%%%%%%%%% WITHOUT MASTER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(1,2,2);
    hold on
    %yyaxis left

    trialCount = size(unitVSSpikeTimesWithoutMaster,1);
    spikeRatesWithoutMaster = zeros(trialCount,1);
    ylim([0 tickSize*trialCount]);

    arrSlaveUnitSpikeTimesWithoutMaster = [];
    timeAWithoutMaster = cellfun(@min,(unitVSSpikeTimesWithoutMaster(:,4))); 

    for indSpike=1:trialCount             
        slaveUnitSpikeTimesWithoutMaster = unitVSSpikeTimesWithoutMaster{indSpike,4}-timeAWithoutMaster(indSpike)+MASTER_SLAVE_SPIKE_DISTANCE; % nonsense but just to align first spikes
        arrSlaveUnitSpikeTimesWithoutMaster = [arrSlaveUnitSpikeTimesWithoutMaster slaveUnitSpikeTimesWithoutMaster];

        numspikes=length(slaveUnitSpikeTimesWithoutMaster);
        xx=ones(stepSize*numspikes,1)*nan;
        yy=ones(stepSize*numspikes,1)*nan;

        %scale the time axis to ms
        xx(1:stepSize:stepSize*numspikes)=slaveUnitSpikeTimesWithoutMaster;
        xx(2:stepSize:stepSize*numspikes)=slaveUnitSpikeTimesWithoutMaster;
        yy(1:stepSize:stepSize*numspikes)=(indSpike-1)*tickSize;
        yy(2:stepSize:stepSize*numspikes)=yy(1:stepSize:stepSize*numspikes)+tickSize;
        plot(xx, yy, 'color', 'r', 'LineWidth',6); % plot spikes  in dark gray [.4 .4 .4]

        spikeRatesWithoutMaster(indSpike)=numspikes/(MASTER_SLAVE_SPIKE_DISTANCE); % endOfTrial-startOfTrial        
    end
    xlim([-0.00005 MASTER_SLAVE_SPIKE_DISTANCE*1.05]);

    xt = get(gca,'ytick');    
    set(gca,'YTick',xt, 'yticklabel',xt/tickSize) % normalize back again to actual trial numbers

    for indGain=1:length(GAIN_CHANGE_MOMENTS)
        moment = GAIN_CHANGE_MOMENTS(indGain,3);
        power = GAIN_CHANGE_MOMENTS(indGain,2);
        indFirstSpike = find([unitVSSpikeTimesWithoutMaster{:,4}]>moment,1);        
        if ~isempty(indFirstSpike) && indFirstSpike>0
            yline(indFirstSpike*tickSize,'--r', ['Power = ' num2str(power,'%.2f') ' mW'],'LineWidth',2, 'FontWeight','bold', 'FontSize',PLOT_FONT_SIZE);
        end
    end
    
    xlabel('Time (s)');
    ylabel('Slave spike index');
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   

%     yyaxis right
%     binCountsWithoutMaster = histcounts(arrSlaveUnitSpikeTimesWithoutMaster,EDGES_MASTER_SLAVE_SPIKE_DISTANCE);
%     binnedSpikeRatesWithoutMaster = binCountsWithoutMaster/(trialCount*BIN_SIZE_PSTH); % averaged over trials and specified bin
%     edgesPlt = EDGES_MASTER_SLAVE_SPIKE_DISTANCE(1:end-1)+(EDGES_MASTER_SLAVE_SPIKE_DISTANCE(2)-EDGES_MASTER_SLAVE_SPIKE_DISTANCE(1))/2;
%     smtSpikeRatesWithoutMaster = smooth(edgesPlt,binnedSpikeRatesWithoutMaster, SPIKE_SPAN, SMOOTH_TYPE_R);
%     %plot(edgesPltForward(2:end-1), smtSpikeRatesWMaster(2:end-1), 'LineWidth',1.4, 'Color', 'r');
%     plot(edgesPlt, smtSpikeRatesWithoutMaster, 'LineWidth',1.4, 'Color', 'r');
%     %legend({['without MF rate = ' num2str(mean(binnedSpikeRatesWithoutMaster),'%.2f') ' spk/s'],['witout MF rate = ' num2str(spikeRateWithoutMaster,'%.2f')]});
%     ylabel('Spikes/s');
%     ylim([0 max(smtSpikeRatesWithoutMaster)*1.5]);
    title([unitVSSpikeTimesWithoutMaster{1,2} '(Unit=' num2str(unitVSSpikeTimesWithoutMaster{1,1}) ' spike count=' num2str(length(spikeTimesWithoutMaster)) ' rate=' num2str(spikeRateWithoutMaster,'%.2f') ' spk/s)']);

    print([pathToCCGWRasterPSTH '/' 'raster_' num2str(unit.id) '_' num2str(unitVSSpikeTimesWithMaster{1,1}) '_' num2str(MASTER_SLAVE_SPIKE_DISTANCE*1000) 'ms.tif'], '-dtiff', '-r100');
    close all;
end