%%%% Plot Raster %%%%%%%%%%%%
% spikeTimes (s): Spike times in sec
% markBehavRelevantTimes (s): Mark behaviorally relevant times on the plot
% startTime, endTime: To calculate spike rate within a given period of time
% 
% SO 1/25/2023 Hull Lab
function plotRaster(spikeTimes, markBehavRelevantTimes, startTime, endTime, fixedHoldStartsAtTrial, xLimMin, xLimMax, sTitle, colors)
    globals;
    
    f = figure;
    f.Position = [globalX globalY globalW globalH];                        
    %%%%%%%%%%%%%%%%%%%%%% RASTER - Lever Hold Aligned Spikes %%%%%%%%%%%%%%%%%%%    
    subplot(2,1,1)
    hold on
    spikeRates = raster(spikeTimes{1}, markBehavRelevantTimes{1}, startTime{1}, endTime{1}, fixedHoldStartsAtTrial, colors);
    ylabel('Trial index');
    xlabel('Time (s)');
    set(gca,'TickDir','out');        
    %set(gca,'XColor','none')        
    xlim([xLimMin{1} xLimMax{1}]);
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
    title([sTitle{1} ' ' num2str(mean(spikeRates),'%.2f') ' spk/s']);
    
    %plotRaster(spikeTimeAlignedToLeverHold, [targetVisStimAlignedToLeverHold], startTime, endTime, fixedHoldStartsAtRelativeTrial, -PRE_TIME_HOLD, POST_TIME_HOLD, 'Lever Hold aligned (Target Stim red marked)');
    %%%%%%%%%%%%%%%%%%%%%% RASTER - Lever Release Aligned Spikes %%%%%%%%%%%%%%%%%%%
    subplot(2,1,2)
    hold on
    spikeRates = raster(spikeTimes{2}, markBehavRelevantTimes{2}, startTime{2}, endTime{2}, fixedHoldStartsAtTrial, colors);
    ylabel('Trial index');
    xlabel('Time (s)');
    set(gca,'TickDir','out');        
    %set(gca,'XColor','none')        
    xlim([xLimMin{2} xLimMax{2}]);
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
    title([sTitle{2} ' ' num2str(mean(spikeRates),'%.2f') ' spk/s']);
    
    %plotRaster(spikeTimeAlignedToLeverRelease, [targetVisStimAlignedToLeverRelease; baselineVisStimAlignedToLeverRelease], startTime, endTime, fixedHoldStartsAtRelativeTrial, -PRE_TIME_RELEASE, POST_TIME_RELEASE, 'Lever Release aligned (Target red, Baseline black marked)');        

    %**************************************************************************************    
%     hold on
%     spikeRates = raster(spikeTimes, markBehavRelevantTimes, startTime, endTime, fixedHoldStartsAtTrial);
%     ylabel('Trial index');
%     xlabel('Time (s)');
%     set(gca,'TickDir','out');        
%     %set(gca,'XColor','none')        
%     xlim([xLimMin xLimMax]);
%     set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
%     title([sTitle ' ' num2str(mean(spikeRates),'%.2f') ' spk/s'])
end