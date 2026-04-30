% return type of cell based on its response properties around the behavioral event (t=0)
% spike rates along the edges comes aligned to the selected behavioral event at time=0

function type = classifyCellbyResponse(spikeRates, edges)
    globals;

    edgeIndsPre = find(edges>=PRE_WINDOW_RESPONSE_PROP(1) & edges<PRE_WINDOW_RESPONSE_PROP(2));
    edgeIndsPeri = find(edges>=PERI_WINDOW_RESPONSE_PROP(1) & edges<=PERI_WINDOW_RESPONSE_PROP(2));
    
    spikeRatesPre = spikeRates(edgeIndsPre);
    spikeRatesPeri = spikeRates(edgeIndsPeri);
    maxSpikeRate = mean(spikeRatesPre)+4*std(spikeRatesPre); % Increased activity if higher than mean baseline + 4*std
    minSpikeRate = mean(spikeRatesPre)-4*std(spikeRatesPre); % Decreased activity if lower than mean baseline + 4*std

    typeI = 0; typeD = 0;

    if any(spikeRatesPeri>=maxSpikeRate) % INCREASED
        typeI = RESPONSE_INCREASING;
    end
    
    if any(spikeRatesPeri<=minSpikeRate) % DECREASED
        typeD = RESPONSE_DECREASING;
    end

    type = RESPONSE_NO_CHANGE_OR_MIXED;
    if typeI~=RESPONSE_NO_CHANGE_OR_MIXED && typeD~=RESPONSE_NO_CHANGE_OR_MIXED % If both INCREASED and DECREASED, then mixed response
        type = RESPONSE_NO_CHANGE_OR_MIXED;
    elseif typeI~=RESPONSE_NO_CHANGE_OR_MIXED
        type = typeI;
    elseif typeD~=RESPONSE_NO_CHANGE_OR_MIXED
        type = typeD;
    end
end