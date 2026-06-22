
function [trialStruct, gratingRespMatrix, gratingOFFRespMatrix, resp, base] = createTrialStruct_ISN_CentSurr(stimStruct, goodUnitStruct, b)
    trialStruct = struct(); 

    % Create trial-by-trial structure
        for i = 1:length(stimStruct.timestamps)
            trialStruct(i).onset    = stimStruct.timestamps(i);
            trialStruct(i).offset   = stimStruct.timestamps(i) + stimStruct.stimDuration;
            trialStruct(i).centDir  = stimStruct.centerDirs(i);
            trialType = stimStruct.trialTypes(i); % Define condition: 0 = iso (grating), 1 = crossori
            
            if contains(trialType, ["iso0","iso90"])
                trialStruct(i).cond = 1;   % iso
            elseif contains(trialType, ["crs0","crs90"])
                trialStruct(i).cond = 2;   % cross
            else
                trialStruct(i).cond = 3;   % small
            end

        end


    nUnits      = length(goodUnitStruct);

    % Get unique center ori
    uniqueDirsCent  = unique(stimStruct.centerDirs);
    nDirsCent       = length(uniqueDirsCent);

    % Trial types
    uniqueTrialType  = [1 2 3]; % hard coded, corresponding to the iso, cross, small conditions

    nCon = length(uniqueTrialType);
    nTrials = length(trialStruct);

    
    binSize = 0.01; % 10 ms bins
    stimDuration = stimStruct.stimDuration; % Stimulus duration in seconds
    preStimTime = 0.2; % 200 ms before stimulus onset
    
    respBins = stimDuration / binSize; % 100 bins
    baseBins = preStimTime / binSize;  % 20 bins
    
    % Initialize resp and base as numeric arrays
    resp = cell(nUnits, nDirsCent, nCon);
    base = cell(nUnits, nDirsCent, nCon);

    % Initialize spikeMatrix and spikeOFFMatrix (grating only)
    gratingRespMatrix = cell(nUnits, nDirsCent);
    gratingOFFRespMatrix = cell(nUnits, nDirsCent);

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
            dirIdx   = find(uniqueDirsCent == trialStruct(j).centDir);      % Find corresponding direction index
            condIdx = find(uniqueTrialType == trialStruct(j).cond);      % Find corresponding condition

            % Append binned spike counts for each trial
            resp{i, dirIdx, condIdx} = [resp{i, dirIdx, condIdx}; respCounts];
            base{i, dirIdx, condIdx} = [base{i, dirIdx, condIdx}; baseCounts];

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
