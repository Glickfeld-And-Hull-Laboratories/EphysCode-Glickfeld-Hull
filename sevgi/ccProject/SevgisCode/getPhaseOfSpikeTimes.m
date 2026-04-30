% Adapted from arrangeSpikeRatesAccordingly() function
function [phasesAllUnitsAllTrials, ... % plvPerUnitPerTrial, 
    phaseAllUnitsPerTrial] = ...
    getPhaseOfSpikeTimes(cellSpikeTimes, allLicks)
        globals;

        plvPerUnitPerTrial = {};
        phasesPerUnitPerTrial = {};

        phasesAllUnitsAllTrials = [];

        if NORMALIZE_X_AXIS_FOR_EACH_LICK~=0

            for ind=1:length(cellSpikeTimes) % go through all units for the one recording day
                trialCount = length(cellSpikeTimes{ind});
                
                individualLicks = allLicks{ind};
                individualSpikeTimes = cellSpikeTimes{ind};    
                                                
                normIndividualSpikeTimes = normalizeXForEachLick(individualSpikeTimes, individualLicks);
                
                phasesPerTrial = {};
                plvPerTrial = -99*ones(1,length(normIndividualSpikeTimes));
                for indTrial=1:length(normIndividualSpikeTimes) % find phase for each trial
                    normSpikeTimePerTrial = normIndividualSpikeTimes{indTrial}';
                    normSpikeTimePerTrial = normSpikeTimePerTrial(normSpikeTimePerTrial>=0 & ...
                        normSpikeTimePerTrial<=FIRST_N_LICKS); % interested in first-three licks
                    phases = mod(normSpikeTimePerTrial, 1) * 2*pi;
                    phasesPerTrial{length(phasesPerTrial)+1} = phases;
                    phasesAllUnitsAllTrials = [phasesAllUnitsAllTrials phases];
                    % plvPerTrial(indTrial) = calculatePLV(phases);
                end

                phasesPerUnitPerTrial{length(phasesPerUnitPerTrial)+1} = phasesPerTrial;
                % plvPerUnitPerTrial{length(plvPerUnitPerTrial)+1} = plvPerTrial;            
            end
           
            % Now check if all units converge to each other throghout the session        
            % plvAllUnitsAvgPerTrial = -99*ones(1,trialCount);
            phaseAllUnitsPerTrial = cell(1,trialCount);
            for indTrial=1:trialCount
                temp = cellfun(@(x) x(indTrial), phasesPerUnitPerTrial);
                phaseAllUnitsPerTrial{indTrial} = cell2mat(temp);
                % plvAllUnitsAvgPerTrial(indTrial) = calculatePLV(phaseAllUnitsPerTrial);
            end
        end
end