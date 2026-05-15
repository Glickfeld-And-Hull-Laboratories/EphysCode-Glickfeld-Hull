
function [trialStruct, gratingRespMatrix, gratingOFFRespMatrix, resp, base, uniqueStims] = NPXcreateTrialStructMulti(stimStruct, goodUnitStruct)


trialStruct = struct(); 
binSize = 0.010; % 10 ms bins
preStimTime = 0.2; % 200 ms before stimulus onset
extractDuration = input('Time after stim onset to include for spike event extraction in seconds (e.g, for 100ms enter 0.100): ');
nExpts = length(stimStruct);
resp = cell(nExpts,1);
base = cell(nExpts,1);
uniqueStims = cell(nExpts,1);
gratingRespMatrix = cell(nExpts,1);
gratingOFFRespMatrix = cell(nExpts,1);
for i = 1:nExpts
    % Create trial-by-trial structure
    if isfield(stimStruct,'trialTypes')
        trialStruct(i).onset    = stimStruct(i).timestamps;
        trialStruct(i).offset   = stimStruct(i).timestamps + stimStruct(i).stimDuration;
        trialStruct(i).trialTypes = stimStruct(i).trialTypes;
        disp(['trialTypes is center surround stim identities for Experiment ' num2str(i)])
    elseif isfield(stimStruct,'centerDirs')
        trialStruct(i).onset    = stimStruct(i).timestamps;
        trialStruct(i).offset   = stimStruct(i).timestamps + stimStruct(i).stimDuration;
        trialStruct(i).trialTypes  = stimStruct(i).centerDirs;
        disp(['trialTypes is stim directions for Experiment ' num2str(i)])
    end

    nUnits      = length(goodUnitStruct);
    uniqueStims{i}  = unique([trialStruct(i).trialTypes]);
    nStims       = length(uniqueStims{i});

    % nTrials = length(trialStruct);

    % stimDuration = stimStruct.stimDuration; % Stimulus duration in seconds
    
    % respNBins = stimDuration / binSize; % 20 bins
    % baseNBins = preStimTime / binSize;  % 20 bins
    
    % Initialize resp and base as numeric arrays
    thisresp = cell(nUnits, nStims);
    thisbase = cell(nUnits, nStims);

    % Initialize spikeMatrix and spikeOFFMatrix (grating only)
    thisgratingRespMatrix = cell(nUnits, nStims);
    thisgratingOFFRespMatrix = cell(nUnits, nStims);
    nTrials = length([trialStruct(i).trialTypes]);
    % Sort spikes into trials
    for u = 1:nUnits
        unitSpikes = goodUnitStruct(u).timestamps; % Get spikes for the current unit
        for j = 1:nTrials % Loop through all trials
            onset           = trialStruct(i).onset(j);
            offset          = trialStruct(i).offset(j);
            trialSpikes     = unitSpikes(unitSpikes >= onset & unitSpikes < offset) - onset; % Get spikes for this trial
            trialOFFSpikes  = unitSpikes(unitSpikes >= (onset-preStimTime) & unitSpikes < onset) - onset; % Get spikes for baseline preceding this trial
            
            % Store list of spike times for the specific unit in trial
            % structure
            trialStruct(i).trialSpikes{u,j} = trialSpikes;
            trialStruct(i).trialOFFSpikes{u,j} = trialOFFSpikes;

            % Bin spikes into 10 ms bins
            respCounts = histcounts(trialSpikes, 0:binSize:extractDuration);
            baseCounts = histcounts(trialOFFSpikes, -preStimTime:binSize:0);

            % Get trial information
            stimIdx   = find(uniqueStims{i} == trialStruct(i).trialTypes(j));      % Find corresponding direction index
    
            % Append binned spike counts for each trial
            if isempty(thisresp{u, stimIdx})
                thisresp{u, stimIdx} = []; % Initialize
                thisbase{u, stimIdx} = [];
            end
            thisresp{u, stimIdx} = [thisresp{u, stimIdx}; respCounts];
            thisbase{u, stimIdx} = [thisbase{u, stimIdx}; baseCounts];

            % Store raw spike times for grating trials only
            if isempty(thisgratingRespMatrix{u, stimIdx})
                thisgratingRespMatrix{u, stimIdx} = {}; % Initialize cell array if empty
                thisgratingOFFRespMatrix{u, stimIdx} = {};
            end
            thisgratingRespMatrix{u, stimIdx}{end + 1} = trialSpikes;
            thisgratingOFFRespMatrix{u, stimIdx}{end + 1} = trialOFFSpikes;
        end
    end
    resp{i} = thisresp;
    base{i} = thisbase;
    gratingRespMatrix{i} = thisgratingRespMatrix;
    gratingOFFRespMatrix{i} = thisgratingOFFRespMatrix;
end

end
