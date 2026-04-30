function [integralValuesAfterRew, onsetPoint] = getIntegralAndOnsets(spikeRates)

        globals;

        edgesPlt = EDGES(1:end-1)+(EDGES(2)-EDGES(1))/2;                
        integralValuesAfterRew = zeros(1,size(spikeRates,1));
        onsetPoint = -99*ones(1,size(spikeRates,1));

        for ind=1:size(spikeRates,1)
            smtIndividualSpikeRates = smooth(edgesPlt,spikeRates(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
            indsIntegral = find(edgesPlt>=0 & edgesPlt<.2);
            values = smtIndividualSpikeRates(indsIntegral);
            integralValuesAfterRew(ind) = sum(values);
        end

        for ind=1:size(spikeRates,1)
            smtSpikeRates = smooth(edgesPlt,spikeRates(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
            [peak, pos] = max(abs(smtSpikeRates));
            indOnset = find(abs(smtSpikeRates(1:pos))>peak/2,1); % find the 1/2th of the ramping timepoint  
            if ~isempty(indOnset)
                onsetPoint(ind) = edgesPlt(indOnset);
            end
        end
end