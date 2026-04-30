function [arrModulations, arrModulationMagnitudeRew, arrModulationMagnitudeCue, isSinusoidal, localMaxs, localMins] = ...
            getSignificantModulations(spikeRates)

        globals; 

        edgesPlt = EDGES(1:end-1)+(EDGES(2)-EDGES(1))/2;

        indsBaseline = find(EDGES>=BASELINE_RANGE(1)&EDGES<=BASELINE_RANGE(2));
        indsModulationRangeRew = find(EDGES>=MODULATION_RANGE_FOR_REWARD(1)&EDGES<=MODULATION_RANGE_FOR_REWARD(2));
        indsModulationRangeCue = find(EDGES>=MODULATION_RANGE_FOR_CUE(1)&EDGES<=MODULATION_RANGE_FOR_CUE(2));
               
        arrModulations = zeros(1,size(spikeRates,1));
        arrModulationMagnitudeRew = zeros(1,size(spikeRates,1));
        arrModulationMagnitudeCue = zeros(1,size(spikeRates,1));

        isSinusoidal = -1*ones(size(spikeRates,1),1); % 1=Sinusoidal -1= Ramp, trapezoid or anything else
        localMaxs = zeros(size(spikeRates,1),4); % num of cells x num of licks
        localMins = zeros(size(spikeRates,1),4); 
                
        for ind=1:size(spikeRates,1)

            % First smooth then check Inc/Dec otherwise positive fluctuations dominating and causing no Decreasers!
            smtIndividualSpikeRate = smooth(edgesPlt,spikeRates(ind,:), SPIKE_SPAN_LARGE, SMOOTH_TYPE_L);

            if NORMALIZE_X_AXIS_FOR_EACH_LICK == 1 && MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
                indX_Start = find(edgesPlt>=0,1);
                indX_End = indX_Start + find(edgesPlt(indX_Start:end)>=3,1) - 1;
                smtFROnly3Licks = smtIndividualSpikeRate(indX_Start:indX_End);
                [acf,lags] = xcorr(smtFROnly3Licks,'coeff'); % autocorrelation hints the sinosoidal pattern
    %             f = prePlot();grid on;stem(lags,acf);
    %             hold on; stem(lags(lags>0),derivXCorr);            
                [pks,locs] = findpeaks(acf(lags>0)); % if there are peaks, then the function is sinosoidal
                if ~isempty(locs)
                    isSinusoidal(ind) = 1;
                    for indLick=0:3 % interested in only first 4 licks
                        indX_Start = find(edgesPlt>=indLick,1);
                        indX_End = indX_Start + find(edgesPlt(indX_Start:end)>=indLick+1,1) - 1;
                        smtFR_LickSpecific = smtIndividualSpikeRate(indX_Start:indX_End);
          %             f = prePlot();grid on; plot(smtFR_LickSpecific);
                        [pksMax,locsMax] = findpeaks(smtFR_LickSpecific);
                        [pksMin,locsMin] = findpeaks(smtFR_LickSpecific*-1);
                        [~, indMax] = max(pksMax);
                        [~, indMin] = max(pksMin);
                        halfWay = floor(length(smtFR_LickSpecific)/2);
    
                        maxTunesTo = 1; % tunes to first half of the inter lick interval
                        if locsMax(indMax)>halfWay
                           maxTunesTo = 2; % tunes to second half of the inter lick interval
                        end
    
                        minTunesTo = 1; % tunes to first half of the inter lick interval
                        if locsMin(indMin)>halfWay
                           minTunesTo = 2; % tunes to second half of the inter lick interval
                        end
    
                        localMaxs(ind,indLick+1) = maxTunesTo;
                        localMins(ind,indLick+1) = minTunesTo;
                    end
                end
            end
            %{
             f = prePlot();grid on;
             plot(edgesPlt, spikeRates(ind,:), 'LineWidth',1, 'Color', [0 0 0.8 0.8]);
             plot(edgesPlt, smtIndividualSpikeRate, 'LineWidth',1, 'Color', [.8 0 0 0.8]);
            %}                
                
            baselineSpikeRate = smtIndividualSpikeRate(indsBaseline);                
            modulationRangeSpikeRateRew = smtIndividualSpikeRate(indsModulationRangeRew);
            modulationRangeSpikeRateCue = smtIndividualSpikeRate(indsModulationRangeCue);

            zScoredSpikeRatesModulationRew = (modulationRangeSpikeRateRew-mean(baselineSpikeRate))/std(baselineSpikeRate);
            zScoredSpikeRatesModulationCue = (modulationRangeSpikeRateCue-mean(baselineSpikeRate))/std(baselineSpikeRate);
            zScoredSpikeRatesBaseline = (baselineSpikeRate-mean(baselineSpikeRate))/std(baselineSpikeRate);
            stdLevel = STD_LEVEL_FOR_RESPONSIVENESS*std(zScoredSpikeRatesBaseline); 
            whichOneRew = abs(zScoredSpikeRatesModulationRew)>=stdLevel; % absolute suppression or activation amount should be bigger than 5*STD
            maxResponseRew = max(zScoredSpikeRatesModulationRew(whichOneRew));
            minResponseRew = min(zScoredSpikeRatesModulationRew(whichOneRew));                
            if abs(maxResponseRew)>abs(minResponseRew) % Decide according to strongest response
                arrModulations(ind) = 1;    
                arrModulationMagnitudeRew(ind) = maxResponseRew;
            elseif abs(maxResponseRew)<abs(minResponseRew)
                arrModulations(ind) = -1;
                arrModulationMagnitudeRew(ind) = minResponseRew;
            elseif any(zScoredSpikeRatesModulationRew(whichOneRew)>0) % Activation
                arrModulations(ind) = 1;    
                arrModulationMagnitudeRew(ind) = maxResponseRew;
            elseif any(zScoredSpikeRatesModulationRew(whichOneRew)<0) % Suppression
                arrModulations(ind) = -1;
                arrModulationMagnitudeRew(ind) = minResponseRew;
            end

            whichOneCue = abs(zScoredSpikeRatesModulationCue)>=stdLevel; % absolute suppression or activation amount should be bigger than 5*STD
            maxResponseCue = max(zScoredSpikeRatesModulationCue(whichOneCue));
            minResponseCue = min(zScoredSpikeRatesModulationCue(whichOneCue));                
            if abs(maxResponseCue)>abs(minResponseCue) % Decide according to strongest response
%                     arrModulations(ind) = 1;    
                arrModulationMagnitudeCue(ind) = maxResponseCue;
            elseif abs(maxResponseCue)<abs(minResponseCue)
%                     arrModulations(ind) = -1;
                arrModulationMagnitudeCue(ind) = minResponseCue;
            elseif any(zScoredSpikeRatesModulationCue(whichOneCue)>0) % Activation
%                     arrModulations(ind) = 1;    
                arrModulationMagnitudeCue(ind) = maxResponseCue;
            elseif any(zScoredSpikeRatesModulationCue(whichOneCue)<0) % Suppression
%                     arrModulations(ind) = -1;
                arrModulationMagnitudeCue(ind) = minResponseCue;
            end
        end
end