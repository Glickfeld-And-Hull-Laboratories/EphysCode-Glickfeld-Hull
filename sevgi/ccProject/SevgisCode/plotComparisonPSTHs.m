function [spikeRatesPre, spikeRatesPost] = ...
    plotComparisonPSTHs(spikeRates, arrModulations, cellGroupNames, ... %arrModulationMagnitudeRew, arrModulationMagnitudeCue, isSinusoidal, localMaxs, localMins, ...
    individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, sCellType, sTitle, sFile, sXLabel, cellSSpairedWithCS, bSuperImpose, dayDepths)

    globals;
    
    spikeRatesPre = [];
    spikeRatesPost = [];
    
    if ~isempty(spikeRates)
                    
        %%%%%%%%%%%%%%%% PSTH FIRST VS LAST TRIALS %%%%%%%%%%%%%%%%%%%%%%%
        f = [];
        if ~bSuperImpose
            f = prePlot();
        end

        if FIRST_VS_LAST
            [spikeRatesPre, ~, ~, p1] = plotPSTH(spikeRatesFirstPart, arrModulations, ... %arrModulationMagnitudeRew, arrModulationMagnitudeCue, ...                
                individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, [], [], 1, dayDepths); %[1:TRIALS_FIRST]                        
            [spikeRatesPost, ~, ~, p2] = plotPSTH(spikeRatesLastPart, arrModulations, ... %arrModulationMagnitudeRew, arrModulationMagnitudeCue, ...
                individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, [], [], 1, dayDepths);
            legend([p1(1), p2(1)], ['First ' num2str(TRIALS_FIRST) ' trials'], ['Last ' num2str(TRIALS_TO_COMPARE) ' trials']);
        else % No slicing, plot all trials
            [spikeRatesPre, indInc, indDec, indOthers, p] = ...
                plotPSTH(spikeRates, arrModulations, ... %arrModulationMagnitudeRew, arrModulationMagnitudeCue, isSinusoidal, localMaxs, localMins, ...
                individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, sTitle, sFile, 1, dayDepths);
            if FLAG_PLOT_INDIVIDUAL_CELLS && ~isempty(cellSSpairedWithCS)
                arrLegends = string(vertcat(cellSSpairedWithCS{:}));
                strLegend = arrayfun(@(row)['SS ' arrLegends{row,1} ' - CS ' arrLegends{row,2}], (1:size(arrLegends,1)), UniformOutput=false);            
                legend(strLegend);
            else
                strLegend = {};
                if ~isempty(cellGroupNames)
                    numOfCells = [length(indInc), length(indDec), length(indOthers)];
                    for indLeg=1:length(cellGroupNames)                        
                        if numOfCells(indLeg)~=0
                            strLegend = {strLegend{:}, [cellGroupNames{indLeg} ' n = ' num2str(numOfCells(indLeg))]};  
                        end                        
                    end
                    if ~isempty(strLegend)
                        legend(p(p~=0), strLegend);
                    end
                end
            end
            spikeRatesPost = [];
        end
        
        if strcmp(sCellType,NEURON_TYPE_SS)  
            if FLAG_NORM_FR
                MIN_SS = MIN_Z_SS_YLIM; %-1.5; %min([spikeRatesPre; spikeRatesPost])*1.1; %.95;            
                MAX_SS = MAX_Z_SS_YLIM; %1.5; %max([spikeRatesPre; spikeRatesPost])*2; %1.05;
            else
                MIN_SS = MIN_SS_YLIM; %80;
                MAX_SS = MAX_SS_YLIM; %105;
            end

            minYLim = MIN_SS;
            maxYLim = MAX_SS;
        elseif strcmp(sCellType,NEURON_TYPE_CS)
            minYLim = MIN_CS_YLIM;
            maxYLim = MAX_CS_YLIM; % 13;
        else
            minYLim = MIN_Z_YLIM;
            maxYLim = MAX_Z_YLIM;
        end
        
        if ~bSuperImpose
            postPlot(f, sXLabel, 'Spikes/s', -PRE_BEHAVIORAL_EVENT_PLOT, POST_BEHAVIORAL_EVENT_PLOT, minYLim, maxYLim, sTitle, sFile);
        end
        %%%%%%%%%%%%%%%% PSTH FIRST VS LAST TRIALS %%%%%%%%%%%%%%%%%%%%%%%
    end
end