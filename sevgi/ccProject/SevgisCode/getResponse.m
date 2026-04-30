function [baselineFR, modulationFR, responseMagnitude] = ...
    getResponse(unitTimeStamps, arrBehavTimesSelected) %, pathToFolder, sMouseId, sLabel, day, unitID)

    globals;

    responseMagnitude = 0; % spk/s
    if FROM_CS_TO_SS
        potentiationRange = CS_POTENTIATION_RANGE_AROUND_ZERO;
    elseif FROM_CS_TO_SS == 2
        potentiationRange = SS_POTENTIATION_RANGE_FOR_UPDOWNBOUND;
    else
        if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
            potentiationRange = SS_POTENTIATION_RANGE_FOR_CLICK;
        elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
            potentiationRange = SS_POTENTIATION_RANGE_FOR_LICK;
        end        
    end

    spikeTimes = chunkAlignSpikeTimes(unitTimeStamps, arrBehavTimesSelected);        
    trialCount = length(spikeTimes); % should be same trial count for all units
    arrSpikeTimes = cell2mat(spikeTimes');
    binCounts = histcounts(arrSpikeTimes,EDGES); % optimumBinCount);                    
    meanSpikeRate = binCounts/(trialCount*BIN_SIZE_PSTH); % averaged over trials and specified bin size
    edgesPlt = EDGES(1:end-1)+(EDGES(2)-EDGES(1))/2;
    smtSpikeRates = smooth(edgesPlt,meanSpikeRate, SPIKE_SPAN, SMOOTH_TYPE_L);
                 
    indsBaseline = find(EDGES>=BASELINE_RANGE(1)&EDGES<=BASELINE_RANGE(2));
    baselineSpikeRate = smtSpikeRates(indsBaseline);
    indsPotentiationRange = find(EDGES>=potentiationRange(1)&EDGES<=potentiationRange(2));
    potentiationSpikeRate = smtSpikeRates(indsPotentiationRange);

    zScoredSpikeRatesPotentiation = (potentiationSpikeRate-mean(baselineSpikeRate))/std(baselineSpikeRate);
    [value pos]=max(abs(zScoredSpikeRatesPotentiation));

    baselineFR = mean(baselineSpikeRate);
    modulationFR = mean(potentiationSpikeRate);
    responseMagnitude = zScoredSpikeRatesPotentiation(pos);
    %{
        prePlot();
        edgesPlt = EDGES(1:end-1)+(EDGES(2)-EDGES(1))/2;
        smtSpikeRates = smooth(edgesPlt,meanSpikeRate, SPIKE_SPAN, SMOOTH_TYPE_L);
        plot(edgesPlt, smtSpikeRates, 'LineWidth',1.4);
        plot(edgesPlt, meanSpikeRate, 'LineWidth',1.4);
        xlim([-PRE_BEHAVIORAL_EVENT POST_BEHAVIORAL_EVENT_PLOT]);
        %postPlot('Time (s)', 'Spikes/s', -PRE_BEHAVIORAL_EVENT, POST_BEHAVIORAL_EVENT_PLOT, [], [], '', '');
    %}
    a=0;
end