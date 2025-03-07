function [trialStruct, spikeMatrix, spikeOFFMatrix] = createTrialStruct(stimStruct, goodUnitStruct)
    trialStruct = struct(); 

    % Create trial-by-trial structure
    for i = 1:length(stimStruct.timestamps)
        trialStruct(i).onset        = stimStruct.timestamps(i);
        trialStruct(i).direction    = stimStruct.directions(i);
        trialStruct(i).offset       = stimStruct.timestamps(i) + stimStruct.duration;
    end

    % Get unique directions & trials per direction
    uniqueDirs  = unique(stimStruct.directions);
    nDirs       = length(uniqueDirs);
    nUnits      = length(goodUnitStruct);
    
    % Count trials per direction
    trialsPerDir = zeros(nDirs, 1);
    for d = 1:nDirs
        trialsPerDir(d) = sum(stimStruct.directions == uniqueDirs(d));
    end
    maxTrials = max(trialsPerDir);

    % Initialize spikeMatrix as a cell array (units x directions)
    spikeMatrix     = cell(nUnits, nDirs);
    spikeOFFMatrix  = cell(nUnits, nDirs);

    % Sort spikes into trials and populate spikeMatrix
    for i = 1:nUnits
        unitSpikes = goodUnitStruct(i).timestamps; % Get spikes for the current unit
        
        for j = 1:length(trialStruct) % Loop through all trials
            onset           = trialStruct(j).onset;
            offset          = trialStruct(j).offset;
            trialSpikes     = unitSpikes(unitSpikes >= onset & unitSpikes < offset) - onset; % Get spikes for this trial
            trialOFFSpikes  = unitSpikes(unitSpikes >= (onset-0.5) & unitSpikes < onset) - onset; % Get spikes for baseline preceding this trial
            
            % Determine direction index
            dirIdx = find(uniqueDirs == trialStruct(j).direction, 1);
            
            % Store trial spikes in the spikeMatrix for the appropriate unit and direction
            spikeMatrix{i, dirIdx}{end + 1}     = trialSpikes; % Append trial spikes to corresponding cell for each trial
            spikeOFFMatrix{i, dirIdx}{end + 1}  = trialOFFSpikes; % Append trial spikes to corresponding cell for each trial

            % Store spikes in the trial structure for the specific unit and trial
            trialStruct(j).unitSpikesByTrial{i}             = trialSpikes;
            trialStruct(j).unitSpikesByTrial_baseline{i}    = trialOFFSpikes;
        end
    end
end
