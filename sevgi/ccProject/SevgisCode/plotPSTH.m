%%%% PLOT PSTH %%%%%%%%%%%%
% spikeTimesAligned: Spike times in sec
%
% SO 4/18/2025 Hull Lab
function [meanSpikeRate, indInc, indDec, indOthers, plt] = ...
    plotPSTH(spikeRates, arrModulations, ... %arrModulationMagnitudeRew, arrModulationMagnitudeCue, isSinusoidal, localMaxs, localMins, ...
    individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, sTitle, sFile, bSuperImpose, dayDepths)
            % cellSpikeTimes
        globals;

        plt = [];        
        indInc = [];
        indDec = [];
        indOthers = [];
        
        edgesPlt = EDGES(1:end-1)+(EDGES(2)-EDGES(1))/2;
        edgesLickPlt = EDGES_LICK(1:end-1)+(EDGES_LICK(2)-EDGES_LICK(1))/2;

        yForLickOnset = MIN_YLIM+abs(MIN_YLIM)*.1;
        meanSpikeRate = mean(spikeRates,1,'omitnan');
        
        %%%%%%%%%%%%%%%%%%%%%% PSTH - Spikes with Behavioral Event Aligned %%%%%%%%%%%%%%%%%%%        
                
        if FLAG_PLOT_INDIVIDUAL_CELLS
            plotIndividualCells(spikeRates, edgesPlt, individualLickRates, edgesLickPlt, ...
                arrModulations, ... %arrModulationMagnitudeCue, arrModulationMagnitudeRew, isSinusoidal, localMaxs, localMins, ...
                dayDepths, sTitle, sFile);
        end

        if ~bSuperImpose
            prePlot();            
        end

        if FLAG_PLOT_INC_DEC
            indInc = find(arrModulations==1);
            meanSpikeRateInc = mean(spikeRates(indInc,:),1);
            smtSpikeRatesInc = smooth(edgesPlt,meanSpikeRateInc, SPIKE_SPAN, SMOOTH_TYPE_L);
                
            indDec = find(arrModulations==-1);
            meanSpikeRateDec = mean(spikeRates(indDec,:),1);
            smtSpikeRatesDec = smooth(edgesPlt,meanSpikeRateDec, SPIKE_SPAN, SMOOTH_TYPE_L);

            indOthers = find(arrModulations==0);
            meanSpikeRateOthers = mean(spikeRates(indOthers,:),1);
            smtSpikeRatesOthers = smooth(edgesPlt,meanSpikeRateOthers, SPIKE_SPAN, SMOOTH_TYPE_L);
            
            if FLAG_ERROR_BARS
                hold on; % some nonsense duplication - old figure looses hold-on once we plot individual plots in between creating a plot and plotting the curves afterwards
                
                % PUT ERROR BARS FOR INCREASERS
                plotErrorBars(spikeRates(indInc,:), edgesPlt, COLOR_BLIND_FRIENDLY_RED);

                % PUT ERROR BARS FOR DECREASERS
                plotErrorBars(spikeRates(indDec,:), edgesPlt, COLOR_BLIND_FRIENDLY_BLUE);
                %pause(0.5);                            

                % PUT ERROR BARS FOR OTHERS FIRST SO THEY STAY ON THE VERY BACKGROUND LAYER
                plotErrorBars(spikeRates(indOthers,:), edgesPlt, [0.25 0.25 0.25]);
            end

            if ~isempty(indInc)
                plt(1) = plot(edgesPlt, smtSpikeRatesInc, 'LineWidth',1.5, 'Color', [COLOR_BLIND_FRIENDLY_RED ALPHA]) ; %[.8 .1 .2 ALPHA]);
                % plot(edgesPlt, spikeRates(indDec,:), 'LineWidth',0.5); %, 'Color', [COLOR_BLIND_FRIENDLY_RED ALPHA]) ;
            end
            if ~isempty(indDec)
                plt(2) = plot(edgesPlt, smtSpikeRatesDec, 'LineWidth',1.5, 'Color', [COLOR_BLIND_FRIENDLY_BLUE ALPHA]); %[.1 0 .9 ALPHA]);
                % plot(edgesPlt, spikeRates(indDec,:), 'LineWidth',0.5); %, 'Color', [COLOR_BLIND_FRIENDLY_BLUE ALPHA]);
            end
            if ~isempty(indOthers)
                plt(3) = plot(edgesPlt, smtSpikeRatesOthers, 'LineWidth',1.5, 'Color', COLORS(10,:)) ; %[.8 .1 .2 ALPHA]);
                % plot(edgesPlt, spikeRates(indDec,:), 'LineWidth',0.5); %, 'Color', [COLOR_BLIND_FRIENDLY_RED ALPHA]) ;
            end

        else
            meanSpikeRate = mean(spikeRates,1, 'omitnan');
            smtSpikeRates = smooth(edgesPlt,meanSpikeRate, SPIKE_SPAN, SMOOTH_TYPE_L);
            hold on;

            if FLAG_ERROR_BARS
                plotErrorBars(spikeRates, edgesPlt, COLOR_BLIND_FRIENDLY_PURPLE);
            end

            plot(edgesPlt, smtSpikeRates, 'LineWidth',2.5, 'Color', COLOR_BLIND_FRIENDLY_PURPLE); %sColor);
        end
        
        if ~isempty(individualLickRates) && PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES == PLOT_LICK_RATE
            plotLickRatesYRight(individualLickRates, edgesLickPlt);
        elseif PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES == PLOT_LICK_ONSETS
            errorbar(meanLickOnsets,yForLickOnset,semLickOnsets,"horizontal","o","MarkerSize",8,...
                "MarkerEdgeColor","black","MarkerFaceColor",[0 0 0], 'CapSize',18, 'LineWidth',1, 'Color','k');
        elseif PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES == PLOT_CUE_TIMES
            errorbar(meanCues,yForLickOnset,semCues,"horizontal","o","MarkerSize",8,...
                "MarkerEdgeColor","black","MarkerFaceColor",[0 0 0], 'CapSize',18, 'LineWidth',1, 'Color','k');
        end          
    
        if ~bSuperImpose
            postPlot([], 'Time (s)', 'Spikes/s', -PRE_BEHAVIORAL_EVENT, POST_BEHAVIORAL_EVENT, [], [], [sTitle ' FR=' num2str(mean(meanSpikeRate),'%.2f') ' spk/s'], sFile);
        end      

end