function [maxIndices, maxValues] = getMaxSpikesForPolarPlot(smtSpikeRates, arrModulationMagnitudeRew, individualLickRates)

    globals;

    nFirstLicks = POST_BEHAVIORAL_EVENT-1; % cos it starts at zero %5; %10;
    edgesPlt = EDGES(1:end-1)+(EDGES(2)-EDGES(1))/2;
    edgesLickPlt = EDGES_LICK(1:end-1)+(EDGES_LICK(2)-EDGES_LICK(1))/2;
    maxIndices = zeros(size(smtSpikeRates,1),nFirstLicks); % find first ten licks
    maxValues = zeros(size(smtSpikeRates,1),nFirstLicks);
        
    for indGl=1:size(smtSpikeRates,1)
        if arrModulationMagnitudeRew(indGl)~=0
            ind = 1;
            for ind0=0:nFirstLicks
                indLick1 = find(edgesLickPlt>ind0,1); % edgesPlt is aligned each lick cycle 0-first lick 1-second lick etc.
                indLick2 = find(edgesLickPlt>ind0+1,1);
                if indLick2+2>size(individualLickRates,2) % tackle boundary issues
                    maxIndForLick2 = size(individualLickRates,2);
                else
                    maxIndForLick2 = indLick2+2;
                end
                [val11, indLick11] = max(individualLickRates(indGl, indLick1-2:indLick1+2)); % check around to catch where exactly the lick happened                
                [val22, indLick22] = max(individualLickRates(indGl, indLick2-2:maxIndForLick2)); % check around to catch where exactly the lick happened
                if val11>0 && val22>0 % if there was actually any licks
                    indExactLick1 = indLick1-2+indLick11-1;
                    indExactLick2 = indLick2-2+indLick22-1;
                    indExactSpike1 = find(edgesPlt>=edgesLickPlt(indExactLick1),1); % go back to spike rate resolution
                    indExactSpike2 = find(edgesPlt>=edgesLickPlt(indExactLick2),1);
                    if isempty(indExactSpike2)
                        indExactSpike2 = length(edgesPlt); % handle case where no second lick found
                    end
                    [val, indMax] = max(smtSpikeRates(indGl,indExactSpike1:indExactSpike2)); % span the range+-thresholds between first and second lick 
                    maxIndices(indGl, ind) = edgesPlt(indExactSpike1+indMax-1);
                    maxValues(indGl, ind) = val;
                end
                ind = ind+1;
            end
        end
    end

end