clear all; close all; clc
baseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
iexp = 25; % Choose experiment

[exptStruct] = createExptStruct(iexp); % Load relevant times and directories for this experiment

%% Crop pupil video

cropPupil(exptStruct)

%% Extract and sync nidaq signals to the imec sync pulse in the neural data stream

runCatGT_SG(exptStruct.date)    % Run CatGT to extract sync pulse times from nidaq and imec data
runTPrime_SG(exptStruct.date)   % Run TPrime to sync photodiode signal to spikes

% Wait like 30 minutes for this to finish running before continuing

%% Extract units from KS output

cd(fullfile(baseDir, exptStruct.loc, 'Analysis', 'Neuropixel', exptStruct.date, 'KS_Output\')) % Navigate to KS_Output folder

% Choose imec0.ap.bin file (I just choose the CatGT bin file)
[allUnitStruct, goodUnitStruct] = importKSdata_SG();
save(fullfile(baseDir, '\sara\Analysis\Neuropixel', [exptStruct.date], [exptStruct.date '_' exptStruct.mouse '_unitStructs.mat']), 'allUnitStruct', 'goodUnitStruct');


%% Load stimulus "on" timestamps

stimStruct = createStimStruct(exptStruct);

%% Find layer boundaries using LFP data

b = 1;  % What stimulus presentation block to use for layer mapping?
[layerStruct] = findLayer4(exptStruct, stimStruct, b);


%% Sort spikes into trials and bins
if iexp == 11 
    b = 4;
else
    b = 5; % What stimulus presentation block to use for RandDirFourPhase analysis?
end
[trialStruct, gratingRespMatrix, gratingRespOFFMatrix, resp, base] = createTrialStruct12Dir4Phase(stimStruct, goodUnitStruct, b);     
[f0mat, f1mat, f1overf0mat] = getF1_SG(gratingRespMatrix);
save(fullfile(baseDir, '\sara\Analysis\Neuropixel', [exptStruct.date], [exptStruct.date '_' exptStruct.mouse '_F1F0.mat']), 'f0mat', 'f1mat', 'f1overf0mat');

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
    depth_all   = exptStruct.depth + [goodUnitStruct.depth];
    depth_resp  = exptStruct.depth + [goodUnitStruct(resp_ind_dir).depth];
    FR_all      = [goodUnitStruct.FR];
    FR_resp   = [goodUnitStruct(resp_ind_dir).FR];
    scatter(FR_all, depth_all, 15, 'filled')
    hold on
    scatter(FR_resp, depth_resp, 15, 'filled')
    xlim([-5 50]); 
    xlabel('avg FR')
    ylim([-5000 0])
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
% max amplitude waveform across contact sites.

%fs_threshold    = 0.35;
num_samples     = 100;
refractoryViolationThresh = 0.002;  % 2 ms

[spikingStruct, waveformStruct] = singleCellSpikeAnalysis(exptStruct, goodUnitStruct, refractoryViolationThresh, num_samples);
save(fullfile(baseDir, '\sara\Analysis\Neuropixel', [exptStruct.date], [exptStruct.date '_' exptStruct.mouse '_spikeAnalysis.mat']), 'spikingStruct', 'waveformStruct');


% Plot single cell spike analysis
if ~exist(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\' exptStruct.mouse '-' exptStruct.date '_singleCellSpikeAnalysis']), 'dir')
        mkdir(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\' exptStruct.mouse '-' exptStruct.date '_singleCellSpikeAnalysis']));
    end
outDir=(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\' exptStruct.mouse '-' exptStruct.date '_singleCellSpikeAnalysis']);

% Plot single cell spike analyses
nCells = length(waveformStruct);
figure;
x = 1:size(waveformStruct(1).allsamps,1);
i=1;
for ic = 1:nCells
    subplot(8,3,i)
        isiProb     = spikingStruct(ic).isiProb;
        isiEdges    = spikingStruct(ic).isiEdges;
        bar(isiEdges(1:end-1), isiProb, 'histc'); hold on
        xlabel('interspike interval (s)');
        ylabel('probability');
        title(['cell ' num2str(ic) '- interspike interval']);        
    subplot(8,3,i+1)
        acCounts        = spikingStruct(ic).acCounts;
        acBinCenters    = spikingStruct(ic).acBins;
        bar(acBinCenters, acCounts, 'hist'); hold on
        xline(refractoryViolationThresh)
        xline(-refractoryViolationThresh)
        xlabel('time from spike');
        ylabel('count');
        title('autocorrelogram, no binning');
        title([num2str(spikingStruct(ic).refViolations) '/' num2str(spikingStruct(ic).nSpikesUsed) ' spike violations'])
    subplot(8,3,i+2)
        waveforms   = [waveformStruct(ic).allsamps];
        wvStd       = std(waveforms,0,2);
        wvSEM       = wvStd/sqrt(num_samples);
        wvAvg       = [waveformStruct(ic).average];
        plot(wvAvg); hold on
        shadedErrorBar(x,wvAvg,wvSEM)
        xline([waveformStruct(ic).minIdx],'b')
        xline([waveformStruct(ic).maxIdx],'r')
        yline([waveformStruct(ic).baseline],'k')
        title(['PtT dist = ' sprintf('%.2f ms', waveformStruct(ic).PtTdist * 1000)])   % I only want 2 decimal places after 0
    i=i+3;
    if i == 25
        movegui('center')
        print(fullfile([outDir, '\' exptStruct.mouse '-' exptStruct.date '-unit' num2str(ic-7) 'to' num2str(ic) '.pdf']),'-dpdf','-fillpage');
        close all
        i=1;
        figure;
    end
    if ic == nCells
        movegui('center')
        print(fullfile([outDir, '\' exptStruct.mouse '-' exptStruct.date '-until' num2str(ic) '.pdf']),'-dpdf','-fillpage');
        close all
    end
end







