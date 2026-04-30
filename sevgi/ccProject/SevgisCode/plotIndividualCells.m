function plotIndividualCells(spikeRates, edgesPlt, individualLickRates, edgesLickPlt, ...
    arrModulations, ... %arrModulationMagnitudeCue, arrModulationMagnitudeRew, isSinusoidal, localMaxs, localMins, ...
    dayDepths, sTitle, sFile)
    
    globals;

%     smtSpikeRates = zeros(size(spikeRates,1), size(spikeRates,2));

%     if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
%         for ind=1:size(spikeRates,1)
%             if arrModulationMagnitudeCue(ind)~=0
%                 f = prePlot();
%                 smtSpikeRates = spikeRates(ind,:)'; %smooth(edgesPlt,spikeRates(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
%                 if arrModulationMagnitudeCue(ind)>0 % if Increasing or Decreasing its firing rate                        
%                     plot(edgesPlt, smtSpikeRates, 'LineWidth',1, 'Color', [.8 0 0 0.8]); %COLORS(indColors(mod(ind,length(indColors)-1)+1),:));
%                 elseif arrModulationMagnitudeCue(ind)<0
%                     plot(edgesPlt, smtSpikeRates, 'LineWidth',1, 'Color', [0 0 .8 0.8]);
%                 end        
% 
%                 plotLickRatesYRight(individualLickRates, edgesLickPlt);
%                 
%                 postPlot(f, 'Time (s)', 'Spikes/s', -PRE_BEHAVIORAL_EVENT, POST_BEHAVIORAL_EVENT, [], [], ...
%                     ['i=' num2str(ind) ' dep=' num2str(dayDepths(ind)) ' ' sTitle], [sFile '_CueMod_' num2str(ind) '_dep' num2str(dayDepths(ind),'%.0f')]);
%             end
%         end            
%     end
                
    for ind=1:size(spikeRates,1)
%         if arrModulationMagnitudeRew(ind)~=0
            f = prePlot();
            smtSpikeRates = spikeRates(ind,:)'; %smtSpikeRates = smooth(edgesPlt,spikeRates(ind,:), SPIKE_SPAN_LARGE, SMOOTH_TYPE_L);
            % changed arrModulationMagnitudeRew into arrModulations since arrModulationMagnitudeRew may still be positive but decreasing! It does not have any
            % sign information in it
            if arrModulations(ind)>0 %arrModulationMagnitudeRew(ind)>0 % if Increasing or Decreasing its firing rate                        
                plot(edgesPlt, smtSpikeRates, 'LineWidth',1, 'Color', [.8 0 0 0.8]); %COLORS(indColors(mod(ind,length(indColors)-1)+1),:));
            elseif arrModulations(ind)<0 %arrModulationMagnitudeRew(ind)<0
                plot(edgesPlt, smtSpikeRates, 'LineWidth',1, 'Color', [0 0 .8 0.8]);
            else
                plot(edgesPlt, smtSpikeRates, 'LineWidth',1, 'Color', [0.8 0.8 .8 0.8]); % no rew/lick modulation - just plot to observe
            end

            plotLickRatesYRight(individualLickRates, edgesLickPlt);
        
            postPlot(f, 'Time (s)', 'Spikes/s', -PRE_BEHAVIORAL_EVENT, POST_BEHAVIORAL_EVENT, [], [], ...
                ['i=' num2str(ind) ' dep=' num2str(dayDepths(ind)) ' ' sTitle], [sFile '_RewMod_' num2str(ind) '_dep' num2str(dayDepths(ind),'%.0f')]);
%         end
    end 
end