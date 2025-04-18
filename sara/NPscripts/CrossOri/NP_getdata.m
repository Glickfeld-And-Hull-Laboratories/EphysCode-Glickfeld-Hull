clear all; close all; clc
base = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
iexp = 4; % Choose experiment

[exptStruct] = createExptStruct(iexp); % Load relevant times and directories for this experiment

%% Run CatGT to extract sync pulse times from nidaq and imec data

runCatGT_SG(exptStruct.date)
% Wait like 30 minutes for this to finish running before continuing

%% Run TPrime to sync photodiode signal to spikes

runTPrime_SG(exptStruct.date)

%% Extract units from KS output

cd ([base exptStruct.loc '\Analysis\Neuropixel\' exptStruct.date '\KS_Output']) % Navigate to KS_Output folder

% Choose imec0.ap.bin file (I just choose the CatGT bin file)
[allUnitStruct, goodUnitStruct] = importKSdata_SG();

%% Load stimulus "on" timestamps

stimStruct = createStimStruct(exptStruct);

%% Find layer boundaries using LFP data

b = 1;  % What stimulus presentation block to use for layer mapping?
[layerStruct] = findLayer4(exptStruct, stimStruct, b);


%% Sort spikes into trials and bins

b = 2; % What stimulus presentation block to use for RandDirFourPhase analysis?
[trialStruct, gratingRespMatrix, gratingRespOFFMatrix, resp, base] = createTrialStruct12Dir4Phase(stimStruct, goodUnitStruct, b);     

% gratingRespMatrix: This is a nUnits x nDirections cell array, where each element 
% contains a cell array of spike times for each trial. For example, 
% spikeMatrix{unitIdx, dirIdx} will contain a cell array with each cell 
% corresponding to the spike times of a trial for the specified unit and 
% direction. 
% gratingOFFRespMatrix is the 0.2s preceding each trial (what I am calling the
% "baseline" period)

% resp and base are cell arrays size nUnits x nDirs x nPhas x 2
% (grating/plaid). Each element is then nTrials x Time (in bins of 10 ms)

%%
outDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\250328\');

[avg_resp_dir, resp_ind_dir] = getResponses(resp, base);

figure;
subplot 221
    depth_all   = -2000 + [goodUnitStruct.depth];
    depth_resp  = -2000 + [goodUnitStruct(resp_ind_dir).depth];
    FR_all      = [goodUnitStruct.FR];
    FR_resp   = [goodUnitStruct(resp_ind_dir).FR];
    scatter(FR_all, depth_all, 15, 'filled')
    hold on
    scatter(FR_resp, depth_resp, 15, 'filled')
    xlim([-5 50]); 
    xlabel('avg FR')
    ylim([-2000 0])
    movegui('center')
    sgtitle([mouse ' ' date ', FR by depth'])
    print(fullfile([outDir, '\i2753-250328-FRbyDepth.pdf']),'-dpdf','-bestfit');


%%









%% Plot grating rasters for all neurons
outDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\250328\i2753-250328_gratingRasters');

close all
for ic = 1:82
    depth = -2000 + goodUnitStruct(ic).depth;
figure;
    for i=1:12
        subplot(4,3,i)
            plotRaster_SG(gratingRespMatrix, gratingRespOFFMatrix, ic,i)
    end
    sgtitle(['unit '  num2str(ic) ', depth=' num2str(depth)])
    movegui('center')
    print(fullfile([outDir, '\i2753-250328-depth' num2str(-depth) '-unit' num2str(ic) '.pdf']),'-dpdf','-bestfit');
    close all
end

%% Extract information about waveform
% Get mean and std waveform over time, calculate peak-to-trough time of the
% max amplitude waveform across contact sites. Using fast-spiking
% threshold, sort units into fast-spiking or regular-spiking.

ksDir           = ([cd '\KS_Output']);    % Navigate back to KS directory
imecFile         = ([cd '\catgt_i2746-250211-12DirTest-1sOn1sOff_g0\i2746-250211-12DirTest-1sOn1sOff_g0_tcat.imec0.ap.bin']); 
fs_threshold    = 0.35;
num_samples     = 50; 

[waveformStruct] = createWaveformStruct(ksDir, imecFile, fs_threshold, num_samples);


%% Plot waveforms for each cell

unitIdx = 5;

figure;
plotWaveform_SG(waveformStruct,unitIdx);






