
clear all; close all; clc

%goal: load what Nicholas sent and turn into resp variable

   % Load data from experiment. Each experiment file contains one
    % variable, resp, that is nCells by nDir by nPhase by Grating/Plaid by
    % nTrials by Time (in 10 ms bins). For example, 310x12x4x2x13x120.
    % Grating type only has the first phase filled in.

iexp    = 1;
runloc  = 1;    % Where is this script being run? 1 == Hubel, 2 == Wiesel

%%

expts = {'g01'};
%expts = {'g01','g06','g12','g17','tss2','tss4','tss6','tss7','elf1'};

if runloc == 1    % Hubel
    dirBase = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff';
elseif runloc == 2    % Wiesel
    dirBase = 'home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff';
else
    error('Location not valid. 1 == Hubel, 2 == Wiesel.')
end

% Create path to neuropixel data
    dataPath = fullfile(dirBase,'home','sara','Data','fromNicholas','CrossOri_randDirFourPhase_V1_marmoset_LFP', expts{iexp});
    cd(dataPath)

    
% Load Stimulus On times
    load(fullfile(pwd,['stimdef_' expts{iexp} '.mat']))

    % Loads  stimdef   -  [nTrials x  6 stim features]
    % (stimulus info from Nicholas)
    %
    %   stim conditions:
    %       1 - stim on time
    %       2 - type (0, gratings,  1, plaids)
    %       3 - direction
    %       4 - phase
    %       5 - SF
    %       6 - TF

    timestamps = squeeze(stimdef(:,1));


% Load spike times
    load(fullfile(pwd,['postphy_' expts{iexp} '.mat']))

    % Loads  gspikes/gspikes4ph   -  [nCells x  nSamples]
    % (spike info from Nicholas)
    %

    if exist('gspikes4ph','var')
        gspikes = gspikes4ph;
        clear gspikes4ph
    end
 

% Turn into variable, 'resp'
    baseWin = 0.2;
    onWin = 1.0;
    fs_spike   = 30000;     % sampling rate
    binSize    = 0.01;      % 10 ms bins
    win        = [-baseWin onWin];   % e.g. [-0.25 0.25]
    
    edges      = win(1):binSize:win(2);
    tCenters   = edges(1:end-1) + binSize/2;
    
    nCells     = size(gspikes,1);
    nTrials    = length(timestamps);
    nBins      = length(tCenters);
    
    % Extract condition labels
    stimType = stimdef(:,2);   % 0 = grating, 1 = plaid
    stimDir  = stimdef(:,3);   % directions (e.g., 12 values)
    stimPhas = stimdef(:,4);   % phases (e.g., 4 values)
    
    dirs   = unique(stimDir);
    phases = unique(stimPhas);
    
    nDir   = length(dirs);
    nPhase = length(phases);

    % Count trials per condition (assumes balanced design)
    nTrialsPerCond = sum(stimType==0 & stimDir==dirs(1) & stimPhas==phases(1));

    % Compute PSTH (cells x trials x time)
    PSTH = zeros(nCells, nTrials, nBins);
    for iCell = 1:nCells
        % Convert spike indices to seconds
        spkIdx   = find(gspikes(iCell,:));
        spkTimes = spkIdx / fs_spike;
        for iTrial = 1:nTrials
            alignedSpikes = spkTimes - timestamps(iTrial); % Align spikes to trial onset
            alignedSpikes = alignedSpikes(alignedSpikes >= win(1) & alignedSpikes <= win(2)); % Keep spikes in window
            PSTH(iCell,iTrial,:) = histcounts(alignedSpikes, edges); % Bin spikes
            
        end
    end


    
    % Preallocate
    resp = nan(nCells, nDir, nPhase, 2, nTrialsPerCond, nBins);
    
    % Loop over conditions
    for iType = 1:2  % 1 = grating, 2 = plaid
        if iType == 1
            typeVal = 0;
        else
            typeVal = 1;
        end
        for iDir = 1:nDir
            for iPh = 1:nPhase
                % For gratings: only fill phase = 1
                if iType == 1 && iPh > 1
                    continue
                end
                idx = find(stimType == typeVal & stimDir  == dirs(iDir) & stimPhas == phases(iPh));    % Find matching trials 
                nT = min(length(idx), nTrialsPerCond);    % Safety: handle unequal trial counts
                % Fill resp
                resp(:, iDir, iPh, iType, 1:nT, :) = reshape(PSTH(:, idx(1:nT), :), [nCells 1 1 1 nT nBins]);
                
            end
        end
    end


    
%%
    % 
    % save( ...
    % fullfile( ...
    %     dirBase, ...
    %     'home', ...
    %     'sara', ...
    %     'Data', ...
    %     'fromNicholas', ...
    %     'CrossOri_randDirFourPhase_V1_marmoset', ...
    %     [expts{iexp} '.mat']), ...
    % 'resp');


%% plot grating rasters
    
    % Windows
    stimWin = [0 onWin];
    baseWin = [-baseWin 0];
    
    % Initialize
    gratingRespMatrix     = cell(nCells, nDir);
    gratingOFFRespMatrix  = cell(nCells, nDir);
    
    for iCell = 1:nCells
        
        % Convert spikes to seconds
        spkIdx   = find(gspikes(iCell,:));
        spkTimes = spkIdx / fs_spike;
        
        for iDir = 1:nDir
            
            % Get grating trials for this direction
            idx = find(stimType == 0 & stimDir == dirs(iDir));
            
            for k = 1:length(idx)
                t0 = timestamps(idx(k));
                
                % Align spikes
                aligned = spkTimes - t0;
                
                % Stimulus spikes
                stimSpikes = aligned(aligned >= stimWin(1) & aligned < stimWin(2));
                
                % Baseline spikes
                baseSpikes = aligned(aligned >= baseWin(1) & aligned < baseWin(2));
                
                % Store
                gratingRespMatrix{iCell, iDir}{k}    = stimSpikes;
                gratingRespOFFMatrix{iCell, iDir}{k} = baseSpikes;
            end
        end
    end

    % Plot grating rasters for all neurons
    if ~exist(fullfile(dirBase,'home','sara','Analysis','Neuropixel','marmosetFromNicholas', ['marmosetV1_' expts{iexp}], [expts{iexp} '_gratingRasters']), 'dir')
            mkdir(fullfile(dirBase,'home','sara','Analysis','Neuropixel','marmosetFromNicholas', ['marmosetV1_' expts{iexp}], [expts{iexp} '_gratingRasters']));
        end
    outDir=(fullfile(dirBase,'home','sara','Analysis','Neuropixel','marmosetFromNicholas', ['marmosetV1_' expts{iexp}], [expts{iexp} '_gratingRasters']));
    

    close all
    for ic = 1:nCells
    figure;
        for i=1:12
            subplot(4,3,i)
                plotRaster_SG(gratingRespMatrix, gratingRespOFFMatrix, ic,i)
        end
        sgtitle(['unit '  num2str(ic)])
        movegui('center')
        print(fullfile(outDir, [expts{iexp} '-unit' num2str(ic) '.pdf']),'-dpdf','-bestfit');
        close all
    end

