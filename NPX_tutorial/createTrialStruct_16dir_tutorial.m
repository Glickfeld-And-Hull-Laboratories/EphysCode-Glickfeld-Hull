
function [trialStruct, gratingRespMatrix, gratingOFFRespMatrix, resp, base] = createTrialStruct_16dir_tutorial(stimStruct, goodUnitStruct, b)
    trialStruct = struct(); 

    % Create trial-by-trial structure
    for i = 1:length(stimStruct.timestamps{b})
        trialStruct(i).onset    = stimStruct.timestamps{b}(i);
        trialStruct(i).offset   = stimStruct.timestamps{b}(i) + stimStruct.stimDuration;
        trialStruct(i).stimDir  = stimStruct.stimDirection(i);
    end

    nUnits      = length(goodUnitStruct);

    % Get unique directions
    uniqueDirs  = unique(stimStruct.stimDirection);
    nDirs       = length(uniqueDirs);

    nTrials = length(trialStruct);

    binSize = 0.01; % 10 ms bins
    stimDuration = stimStruct.stimDuration; % Stimulus duration in seconds
    preStimTime = 0.2; % 200 ms before stimulus onset
    
    respBins = stimDuration / binSize; % 100 bins
    baseBins = preStimTime / binSize;  % 20 bins
    
    % Initialize resp and base as numeric arrays
    resp = cell(nUnits, nDirs);
    base = cell(nUnits, nDirs);

    % Initialize spikeMatrix and spikeOFFMatrix (grating only)
    gratingRespMatrix = cell(nUnits, nDirs);
    gratingOFFRespMatrix = cell(nUnits, nDirs);

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
            respCounts = histcounts(trialSpikes, 0:binSize:stimDuration);
            baseCounts = histcounts(trialOFFSpikes, -preStimTime:binSize:0);

            % Get trial information
            dirIdx   = find(uniqueDirs == trialStruct(j).stimDir);      % Find corresponding direction index
    
            % Append binned spike counts for each trial
            if isempty(resp{i, dirIdx})
                resp{i, dirIdx} = []; % Initialize
                base{i, dirIdx} = [];
            end
            resp{i, dirIdx} = [resp{i, dirIdx}; respCounts];
            base{i, dirIdx} = [base{i, dirIdx}; baseCounts];

            % Store raw spike times for grating trials only
            if isempty(gratingRespMatrix{i, dirIdx})
                gratingRespMatrix{i, dirIdx} = {}; % Initialize cell array if empty
                gratingOFFRespMatrix{i, dirIdx} = {};
            end
            gratingRespMatrix{i, dirIdx}{end + 1} = trialSpikes;
            gratingOFFRespMatrix{i, dirIdx}{end + 1} = trialOFFSpikes;
        end
    end

end
