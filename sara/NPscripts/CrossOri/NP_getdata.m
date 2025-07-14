clear all; close all; clc
base = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
iexp = 14; % Choose experiment

[exptStruct] = createExptStruct(iexp); % Load relevant times and directories for this experiment

%% Run CatGT to extract sync pulse times from nidaq and imec data

runCatGT_SG(exptStruct.date)
% Wait like 30 minutes for this to finish running before continuing

%% Run TPrime to sync photodiode signal to spikes

runTPrime_SG(exptStruct.date)

%% Extract units from KS output

cd(fullfile(base, exptStruct.loc, 'Analysis', 'Neuropixel', exptStruct.date, 'KS_Output\')) % Navigate to KS_Output folder

% Choose imec0.ap.bin file (I just choose the CatGT bin file)
[allUnitStruct, goodUnitStruct] = importKSdata_SG();

%% Load stimulus "on" timestamps

stimStruct = createStimStruct(exptStruct);

%% Find layer boundaries using LFP data

b = 1;  % What stimulus presentation block to use for layer mapping?
[layerStruct] = findLayer4(exptStruct, stimStruct, b);


%% Sort spikes into trials and bins

b = 5; % What stimulus presentation block to use for RandDirFourPhase analysis?
[trialStruct, gratingRespMatrix, gratingRespOFFMatrix, resp, base] = createTrialStruct12Dir4Phase(stimStruct, goodUnitStruct, b);     
[f0mat, f1mat, f1overf0mat] = getF1_SG(gratingRespMatrix);

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

outDir=(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' exptStruct.date]);

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
    sgtitle([exptStruct.mouse ' ' exptStruct.date ', FR by depth'])
    print(fullfile([outDir, '\' exptStruct.mouse '-' exptStruct.date '-FRbyDepth.pdf']),'-dpdf','-bestfit');


%%

get12Dir4PhaseFits(resp,base,exptStruct)






%% Plot grating rasters for all neurons
if ~exist(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\' exptStruct.mouse '-' exptStruct.date '_gratingRasters']), 'dir')
        mkdir(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\' exptStruct.mouse '-' exptStruct.date '_gratingRasters']));
    end
outDir=(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\' exptStruct.mouse '-' exptStruct.date '_gratingRasters']);

close all
for ic = 1:length(goodUnitStruct)
    depth = -2000 + goodUnitStruct(ic).depth;
figure;
    for i=1:12
        subplot(4,3,i)
            plotRaster_SG(gratingRespMatrix, gratingRespOFFMatrix, ic,i)
    end
    sgtitle(['unit '  num2str(ic) ', depth=' num2str(depth)])
    movegui('center')
    print(fullfile([outDir, '\' exptStruct.mouse '-' exptStruct.date '-depth' num2str(-depth) '-unit' num2str(ic) '.pdf']),'-dpdf','-bestfit');
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






