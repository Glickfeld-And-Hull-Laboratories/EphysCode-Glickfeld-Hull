
function [stimStruct] = createStimStruct_marm(expt)

    % Load stimulus information
        % stimdef   -  [nTrials x  6 stim features] (stimulus info from Nicholas)
        %
        %   stim conditions:
        %       1 - stim on time
        %       2 - type (0, gratings,  1, plaids)
        %       3 - direction
        %       4 - phase
        %       5 - SF
        %       6 - TF

    folder = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Data\fromNicholas\CrossOri_randDirFourPhase_V1_marmoset_LFP\' expt];
    
    files = dir(fullfile(folder, 'stimdef*'));  % match anything starting with stimdef
    
    % sanity check (optional but good practice)
    if isempty(files)
        error('No stimdef file found');
    elseif length(files) > 1
        error('Multiple stimdef files found');
    end
    
    bName = fullfile(folder, files(1).name);
    load(bName);
    

        stimBlocks      = stimdef(:,1);
        stimDirections  = stimdef(:,3);
        maskPhase       = stimdef(:,4);
        maskContrast    = stimdef(:,2);  % (0, gratings,  1, plaids)

    % Create stimStruct
        stimStruct.timestamps       = stimBlocks;   % Cell array (number of stim blocks long) containing all stim on timestamps within each block
        stimStruct.stimDirection    = stimDirections;
        stimStruct.maskPhase        = maskPhase;
        stimStruct.maskContrast     = maskContrast;
        stimStruct.stimDuration     = 1;    % Stimulus duration in seconds

    warning('*createStimStruct* I am hard coding stimulus duration for now. Assumes 1s on, 1s off.')
end

