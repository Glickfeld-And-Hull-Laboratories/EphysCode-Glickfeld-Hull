
function [trialStruct, gratingRespMatrix, gratingOFFRespMatrix, resp, base, uniqueStims] = NPXcreateTrialStruct(stimStruct, goodUnitStruct)
    trialStruct = struct(); 

    % Create trial-by-trial structure
    for i = 1:length(stimStruct.timestamps)
        trialStruct(i).onset    = stimStruct.timestamps(i);
        trialStruct(i).offset   = stimStruct.timestamps(i) + stimStruct.stimDuration;
        trialStruct(i).trialTypes = stimStruct.trialTypes(i);
        % trialStruct(i).stimDir  = stimStruct.stimStimdirection(i);
    end

    nUnits      = length(goodUnitStruct);

    % Get unique stim types
    uniqueStims  = unique(stimStruct.trialTypes);
    nStims       = length(uniqueStims);

    % nTrials = length(trialStruct);

    binSize = 0.010; % 10 ms bins
    % stimDuration = stimStruct.stimDuration; % Stimulus duration in seconds
    extractDuration = input('Time after stim onset to include for spike event extraction in seconds (e.g, for 100ms enter 0.100): ');
    preStimTime = 0.2; % 200 ms before stimulus onset
    
    % respNBins = stimDuration / binSize; % 20 bins
    % baseNBins = preStimTime / binSize;  % 20 bins
    
    % Initialize resp and base as numeric arrays
    resp = cell(nUnits, nStims);
    base = cell(nUnits, nStims);

    % Initialize spikeMatrix and spikeOFFMatrix (grating only)
    gratingRespMatrix = cell(nUnits, nStims);
    gratingOFFRespMatrix = cell(nUnits, nStims);

    % Sort spikes into trials
    for i = 1:nUnits
        unitSpikes = goodUnitStruct(i).timestamps; % Get spikes for the current unit
        
        for j = 1:length(trialStruct) % Loop through all trials
            onset           = trialStruct(j).onset;
            offset          = trialStruct(j).offset;
            trialSpikes     = unitSpikes(unitSpikes >= onset & unitSpikes < offset) - onset; % Get spikes for this trial
            trialOFFSpikes  = unitSpikes(unitSpikes >= (onset-preStimTime) & unitSpikes < onset) - onset; % Get spikes for baseline preceding this trial
            
            % Store list of spike times for the specific unit in trial
            % structure
            trialStruct(j).trialSpikes{i} = trialSpikes;
            trialStruct(j).trialOFFSpikes{i} = trialOFFSpikes;

            % Bin spikes into 10 ms bins
            respCounts = histcounts(trialSpikes, 0:binSize:extractDuration);
            baseCounts = histcounts(trialOFFSpikes, -preStimTime:binSize:0);

            % Get trial information
            stimIdx   = find(uniqueStims == trialStruct(j).trialTypes);      % Find corresponding direction index
    
            % Append binned spike counts for each trial
            if isempty(resp{i, stimIdx})
                resp{i, stimIdx} = []; % Initialize
                base{i, stimIdx} = [];
            end
            resp{i, stimIdx} = [resp{i, stimIdx}; respCounts];
            base{i, stimIdx} = [base{i, stimIdx}; baseCounts];

            % Store raw spike times for grating trials only
            if isempty(gratingRespMatrix{i, stimIdx})
                gratingRespMatrix{i, stimIdx} = {}; % Initialize cell array if empty
                gratingOFFRespMatrix{i, stimIdx} = {};
            end
            gratingRespMatrix{i, stimIdx}{end + 1} = trialSpikes;
            gratingOFFRespMatrix{i, stimIdx}{end + 1} = trialOFFSpikes;
        end
    end

end
