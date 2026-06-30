clear all; close all; clc
baseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';

iexp = 9; % Choose experiment
exptloc = 'LG'; %LG

[exptStruct] = createExptStruct(iexp,exptloc); % Load relevant times and directories for this experiment

%% Crop pupil video

cropPupil(exptStruct)

%% Analyze pupil video

analyzePupil(iexp, exptloc, 75)

%% Extract and sync nidaq signals to the imec sync pulse in the neural data stream

runCatGT_SG(exptStruct.date)    % Run CatGT to extract sync pulse times from nidaq and imec data
runTPrime_SG(exptStruct.date)   % Run TPrime to sync photodiode signal to spikes

% Wait like 30 minutes for this to finish running before continuing

%% Extract units from KS output

if exptloc == "LG" || iexp > 22
    cd(fullfile(baseDir, exptStruct.loc, 'Analysis', 'Neuropixel', exptStruct.date, 'kilosort4\')) % Navigate to KS_Output folder
else
    cd(fullfile(baseDir, exptStruct.loc, 'Analysis', 'Neuropixel', exptStruct.date, 'KS_Output\')) % Navigate to KS_Output folder
end

% Choose imec0.ap.bin file (I just choose the CatGT bin file)
[allUnitStruct, goodUnitStruct] = importKSdata_SG();
save(fullfile(baseDir, '\sara\Analysis\Neuropixel', [exptStruct.date], [exptStruct.date '_' exptStruct.mouse '_unitStructs.mat']), 'allUnitStruct', 'goodUnitStruct');

%% Load stimulus "on" timestamps

stimStruct = createStimStruct(exptStruct);
save(fullfile(baseDir, '\sara\Analysis\Neuropixel', [exptStruct.date], [exptStruct.date '_' exptStruct.mouse '_stimStruct.mat']), 'stimStruct');


%% Find layer boundaries using LFP data

firstChInBrain = 186;

% On Wiesel, run getCSD_V1_Wiesel.m for the relevant experiment, then...
load(fullfile(baseDir, '\sara\Analysis\Neuropixel', [exptStruct.date], [exptStruct.mouse '-' exptStruct.date '-findlayer4-CSD.mat']))

[L4_DepthShal, L4_DepthDeep, L4_shal_ch, L4_deep_ch] = alignCSDwithTemplate_L4_Aligned(CSDraw, Fs, dE*1000, exptStruct.depth,firstChInBrain);
    print(fullfile([baseDir, '\sara\Analysis\Neuropixel\', [exptStruct.date], '\' exptStruct.mouse '-' exptStruct.date '-layer4boundaries.pdf']),'-dpdf','-bestfit');
    save(fullfile(baseDir, '\sara\Analysis\Neuropixel\', [exptStruct.date], [exptStruct.date '_' exptStruct.mouse '_layerStruct.mat']), 'L4_DepthShal','L4_DepthDeep','L4_shal_ch','L4_deep_ch','firstChInBrain');

%% Plot STAs

% On Wiesel, run getSpatialRF_Wiesel for the relevant experiment, then...
getSpatialRF(iexp, exptloc)


%% Sort spikes into trials and bins
if iexp == 11 
    b = 4;
else
    b = 5; % What stimulus presentation block to use for RandDirFourPhase analysis?
end
[trialStruct, gratingRespMatrix, gratingRespOFFMatrix, resp, base] = createTrialStruct12Dir4Phase(stimStruct, goodUnitStruct, b);     
[f0mat, f1mat, f1overf0mat] = getF1_SG(gratingRespMatrix);
save(fullfile(baseDir, 'sara\\Analysis\Neuropixel', [exptStruct.date], [exptStruct.date '_' exptStruct.mouse '_F1F0.mat']), 'f0mat', 'f1mat', 'f1overf0mat');

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
    ylim([-3000 0])
    movegui('center')
    sgtitle([exptStruct.mouse ' ' exptStruct.date ', FR by depth'])
    print(fullfile([outDir, '\' exptStruct.mouse '-' exptStruct.date '-FRbyDepth.pdf']),'-dpdf','-bestfit');


%%

get12Dir4PhaseFits(resp,base,exptStruct,goodUnitStruct,1)






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












%% Marmoset expt
close all; clc; clear all
expt = 'g12';

% Get stim struct
    stimStruct = createStimStruct_marm(expt);

% Make goodUnitStruct
    spkFileName = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Data\fromNicholas\CrossOri_randDirFourPhase_V1_marmoset_LFP\' expt '\postphy_' expt '.mat'];
    load(spkFileName);

    % Initialize
    fs = 30000;

    if expt =='g17'
        goodIdx = find(strcmp({clustinfo.KSLabel}, 'good'));  % select good units    
    else
        goodIdx = find(strcmp([clustinfo.KSLabel], 'good'));  % select good units
    end

    nUnits = numel(goodIdx);
    goodUnitStruct = struct( ...
    'unitID', cell(1,nUnits), ...
    'timestamps', cell(1,nUnits), ...
    'channel', cell(1,nUnits), ...
    'depth', cell(1,nUnits), ...
    'group', cell(1,nUnits), ...
    'FR', cell(1,nUnits), ...
    'rank', cell(1,nUnits) ...
    );

    % Loop through good units
    for k = 1:nUnits
        i = goodIdx(k);  % index into clustinfo / gspikes
        ts = find(gspikes(i,:)) / fs;  % Extract spike timestamps (indices of nonzero entries)
        
        % Fill struct
        goodUnitStruct(k).unitID = clustinfo(i).cluster_id;
        goodUnitStruct(k).timestamps = ts;
        goodUnitStruct(k).channel = clustinfo(i).ch;
        goodUnitStruct(k).depth = clustinfo(i).depth;
        goodUnitStruct(k).group = clustinfo(i).KSLabel;
        goodUnitStruct(k).FR = clustinfo(i).fr;
        goodUnitStruct(k).rank = clustinfo(i).rank;
    end

% Get resp and base
    [trialStruct, gratingRespMatrix, gratingRespOFFMatrix, resp, base] = createTrialStruct12Dir4Phase(stimStruct, goodUnitStruct);     

% get12Dir4PhaseFits
        nCells  = size(resp,1);
    nDirs   = size(resp,2);
    nPhas   = size(resp,3);
    nStim   = (nDirs*(nPhas+1));
    
    % Initialize output arrays
    avg_resp_dir    = NaN(nCells, nDirs, nPhas, 2, 2); % Last dim: 1 = mean, 2 = SEM
    h_resp          = NaN(nCells, nDirs, nPhas, 2);
    p_resp          = NaN(nCells, nDirs, nPhas, 2);
    trialsperstim   = NaN(nDirs, nPhas, 2);
    
    
    mean_base_all = nan(nCells,1);  % Initialize for baseline means

    % Loop over all conditions
    for ic = 1:nCells
        all_baselines = [];

        for id = 1:nDirs
            for ip = 1:nPhas
                for is = 1:2 % Grating/Plaid
                    nTrials                 = size(resp{ic,id,ip,is}, 1);   % Get current condition's trial count
                    trialsperstim(id,ip,is) = nTrials;  % Store trial count for each stimulus condition into a matrix
    
                    if nTrials > 0
                        % Compute mean and SEM for response period
                        avg_resp_dir(ic,id,ip,is,1) = mean(sum(resp{ic,id,ip,is}, 2)); % Avg response in Hz
                        avg_resp_dir(ic,id,ip,is,2) = std(sum(resp{ic,id,ip,is}, 2)) / sqrt(nTrials); % SEM in Hz
    
                        % Convert response and baseline data into spike rates (Hz)
                        resp_cell_trials = sum(resp{ic,id,ip,is}, 2);  % Responses in Hz
                        base_cell_trials = sum(base{ic,id,ip,is}, 2) * 5; % Baselines in Hz

                        % Collect baseline spike rates for this condition
                        % and append to all other conditions
                        all_baselines    = [all_baselines; base_cell_trials];
    
                        % Perform t-test between response and baseline
                        if is == 1
                            [h_resp(ic,id,ip,is), p_resp(ic,id,ip,is)] = ttest(resp_cell_trials, base_cell_trials, 'tail', 'both', 'alpha', (0.05 / nDirs));
                        end
                    else
                        % Assign NaNs when no trials exist
                        avg_resp_dir(ic,id,ip,is,:) = NaN;
                        h_resp(ic,id,ip,is)         = NaN;
                        p_resp(ic,id,ip,is)         = NaN;
                    end
                end
            end
        end

        % Compute mean baseline across all conditions for this cell
        if ~isempty(all_baselines)
            mean_base_all(ic) = mean(all_baselines);
        end
    
        % Subtract from avg_resp_dir for this cell across all conditions
        avg_resp_dir(ic,:,:,:,1) = avg_resp_dir(ic,:,:,:,1) - mean_base_all(ic);
    end
    


    % Find cells significantly responsive to gratings
    resp_ind_dir = find(sum(h_resp(:,:,1,1), 2)); 
    
    % Do all fits at once
    [DSIstruct, ZpZcStruct, plaid_corr, gratingFitStruct, ZpZcPWdist, phaseModStruct] = bigFits(avg_resp_dir);
        
    % Get direction selectivity
        DSI         = DSIstruct.DSI;
        DSI_ind     = DSIstruct.DS_ind;
        gDSI        = DSIstruct.gDSI;
        DSI_maxInd  = DSIstruct.prefDir;

    % Get direction tuning curve fit
        dir_b_hat_all       = gratingFitStruct.b;
        k1_hat_all          = gratingFitStruct.k1;
        R1_hat_all          = gratingFitStruct.R1;
        R2_hat_all          = gratingFitStruct.R2;
        u1_hat_all          = gratingFitStruct.u1;
        u2_hat_all          = gratingFitStruct.u2;
        dir_sse_all         = gratingFitStruct.sse;
        dir_R_square_all    = gratingFitStruct.Rsq;
        dir_yfit_all        = gratingFitStruct.yfit;

    % Get partial correlations
        Zp = ZpZcStruct.Zp;
        Zc = ZpZcStruct.Zc;
        Rp = ZpZcStruct.Rp;
        Rc = ZpZcStruct.Rc;

    % Get PCI fit, get amplitude and baseline
        PCI             = phaseModStruct.PCI;
        yfit_all        = phaseModStruct.yfit;
        amp_hat_all     = phaseModStruct.amp;
        b_hat_all       = phaseModStruct.b;
        sse_all         = phaseModStruct.sse;
        R_square_all    = phaseModStruct.rsq;
    



       
% Plot FR by depth
    [avg_resp_dir, resp_ind_dir] = getResponses(resp, base);

figure(1);
    sgtitle([expt ', vis resp units by depth'])
    subplot 241
        depth_all   = [goodUnitStruct.depth];
        FR_all      = [goodUnitStruct.FR];
        depth_resp  = [goodUnitStruct(resp_ind_dir).depth];
        FR_resp   = [goodUnitStruct(resp_ind_dir).FR];
        scatter(FR_all, depth_all, 15, 'filled'); hold on
        scatter(FR_resp, depth_resp, 15, 'filled')
        % yline(-(-3500+2350),'r'); yline(-(-3500+2150),'r')
        ylim([0 4000])
        xlabel('avg FR')
        movegui('center')


% Get F1/F0
    [f0mat, f1mat, f1overf0mat] = getF1_SG(gratingRespMatrix);

    avg_F1F0 = mean(f1overf0mat,2);
    idx = sub2ind(size(f1overf0mat), (1:size(f1overf0mat,1))', DSI_maxInd(:));
    pref_F1F0 = f1overf0mat(idx);

figure(1);
    subplot 243
        depth_resp  = [goodUnitStruct(resp_ind_dir).depth];
        f1f0_resp   = pref_F1F0(resp_ind_dir);

        binSize = 200;                     % depth window size
        depthBins = 0:binSize:4000;
        meanF1 = nan(size(depthBins)-[0 1]);
        binCenters = depthBins(1:end-1) + binSize/2;
        for i = 1:length(depthBins)-1
            idx = depth_resp >= depthBins(i) & depth_resp <  depthBins(i+1);
            meanF1(i) = mean(f1f0_resp(idx), 'omitnan');
        end

        scatter(f1f0_resp, depth_resp, 15, 'filled'); hold on
        plot(meanF1, binCenters,'k', 'LineWidth', 3)
        % yline(-(-3500+2350),'r'); yline(-(-3500+2150),'r')
        ylim([0 4000])
        xlabel('F1/F0')
        movegui('center')
        subtitle('only vis resp cells')

% Get OSI
    for ic = 1:nCells
        resp = squeeze(avg_resp_dir(ic, :, 1, 1, 1));
        resp(resp < 0) = 0;
        [RprefDir, prefDirInd] = max(resp);
        nullInd = prefDirInd + 6;
        if nullInd > 12
            nullInd = nullInd - 12;
        end
        Rnull = resp(nullInd);
        if RprefDir + Rnull > 0
            DSI(ic) = (RprefDir - Rnull) / (RprefDir + Rnull);
        end
        oriResp = (resp(1:6) + resp(6 + 1:end)) / 2;
        [RprefOri, prefOriInd] = max(oriResp);
        orthInd = prefOriInd + 12 / 4;
        if orthInd > 6
            orthInd = orthInd - 6;
        end
        Rorth = oriResp(orthInd);
        if RprefOri + Rorth > 0
            OSI(ic) = (RprefOri - Rorth) / (RprefOri + Rorth);
        end
    end

figure(1);
    subplot 242
        depth_resp  = [goodUnitStruct(resp_ind_dir).depth];
        osi_resp   = OSI(resp_ind_dir);
        binSize = 200;                     % depth window size
        depthBins = 0:binSize:4000;
        meanOSI = nan(size(depthBins)-[0 1]);
        binCenters = depthBins(1:end-1) + binSize/2;
        for i = 1:length(depthBins)-1
            idx = depth_resp >= depthBins(i) & depth_resp <  depthBins(i+1);
            meanOSI(i) = mean(osi_resp(idx), 'omitnan');
        end
        scatter(osi_resp, depth_resp, 15, 'filled'); hold on
        % Plot averaged line
        plot(meanOSI, binCenters,'k', 'LineWidth', 3)
        % yline(-(-3500+2350),'r'); yline(-(-3500+2150),'r')
        ylim([0 4000])
        xlabel('OSI')
        movegui('center')
        subtitle('only vis resp cells')

print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\marmosetFromNicholas\',[ 'marmosetV1_' expt 'b'],'\cellsByDepth.pdf']),'-dpdf');

