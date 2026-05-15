clear all; close all; clc; clear global;

iexp = 9; % Choose experiment
refractoryViolationThresh   = 0.002;     % 2 ms
nExpts = 1;

%% read data from ks4 and phy2
[exptStruct] = iniExptStruct(iexp); % get exptStruct

baseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
fPathBaseIn = fullfile(baseDir, '\jerry\analysis\neuropixel',exptStruct.mouse,exptStruct.date,'kilosort4');
cd(fPathBaseIn);
plotCentral = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\jerry\analysis\neuropixel\plot_central';
fout = fullfile(baseDir, '\jerry\analysis\neuropixel',exptStruct.mouse,exptStruct.date,'analysis_output');
mkdir(fout);

[cluster_struct,~,~,~,~,~,goodUnitStruct,~,allUnitStruct] = ImportKSdata_TH();  % Marie's function to tidy up ks4 and phy2 outputs for further analysis

%% pull info out of mWorks data

stimStruct = NPXcreateStimStructMulti(exptStruct); % pull stim information

[trialStruct, gratingRespMatrix, gratingRespOFFMatrix, resp, base, uniqueStims] = NPXcreateTrialStructMulti(stimStruct, goodUnitStruct);   % organize neural and stim data into trial structure 

%% find neural data metadata

% Initialize and extract meta file info for waveform analysis
fullDataPath    = fullfile(baseDir, exptStruct.loc, 'analysis', 'neuropixel', exptStruct.mouse,exptStruct.date); % Navigate to experiment directory
dirContents     = dir(fullDataPath); % Get names of all files and folders in the experiment directory
runFolders      = {dirContents([dirContents.isdir] & ~ismember({dirContents.name}, {'.', '..'})).name}; % Get the names of all folders in experiment directory
metaMask        = startsWith(runFolders, 'catgt', 'IgnoreCase', false) & ~contains(runFolders, 'ret', 'IgnoreCase', true);   % Logical mask for folders starting with 'catgt' and not containing 'ret'
% ^ Choose catgt folder for the experimental run (not retinotopy run).
% The catgt folder is created as an output of syncing stimulus
% information to neural data.    
metaFolder      = runFolders(metaMask); % Get the name of the folder that matches the above criteria
if length(metaFolder) > 1
    for i = 1:length(metaFolder)
        disp([num2str(i) ': ' metaFolder{i}])
    end
    runChoice = input('Multiple run folders detected, choose the one to analyze: ');
    metaFolder = metaFolder(runChoice); 
end

runFolderName = cell2mat(metaFolder);

% Change currenty directory to the 
cd(fullfile(fullDataPath,runFolderName))

% Find the waveform file
binfolder       = dir('*ap.bin');
binName         = binfolder.name;
path            = binfolder.folder;

%% get responsive cells
% nExpt = length(trialStruct);
% if nExpt > 1
%     tempTrialStruct = struct();
%     tempOnset = [];
%     tempOffset = [];
%     tempTrialTypes = [];
%     tempTrialSpikes = [];
%     tempTrialOFFSpikes = [];
%     for i = 1:nExpt
% 
%     end
% end


nCells = size(resp,1);
nStimTypes = size(resp,2);
nTimeBinsBase = size(base{1,1},2); % Stimulus duration in 10 ms bin size -- i.e., 100ms / 10ms
nTimeBinsResp = stimStruct.stimDuration/0.010; % Stimulus duration in 10 ms bin size -- i.e., 100ms / 10ms

% next step gets the number of 
resp_cell = cellfun(@(x) x(:,3:102), resp{1,1}, 'UniformOutput', false); % Response period (0.020s - 1.020s)
base_cell = cellfun(@(x) x, base{1,1}, 'UniformOutput', false); % Baseline period (-200ms - 0ms)

maxTrials = max(cellfun(@(x) size(x,1), resp_cell(:))); % Find max trial count across conditions

resp_numeric = nan(nCells, nStimTypes, maxTrials, nTimeBinsResp);
base_numeric = nan(nCells, nStimTypes, maxTrials, nTimeBinsBase);


for ic = 1:nCells
    for id = 1:nStimTypes
        if ~isempty(resp_cell{ic,id})
            nTrials = size(resp_cell{ic,id},1);
            resp_numeric(ic,id,1:nTrials,:) = resp_cell{ic,id}; % Assign data
        end
        if ~isempty(base_cell{ic,id})
            nTrials = size(base_cell{ic,id},1);
            base_numeric(ic,id,1:nTrials,:) = base_cell{ic,id};
        end
    end
end

% Find significantly responsive cells
% nCell x nDir x nTrial
resp_cell_trials = sum(resp_numeric,4); % convert to spike rate per trial (Hz). No need to divide because this is total count of spikes within a 1s window, so the Hz number is the same
base_cell_trials = sum(base_numeric,4) /0.2 ; % convert to Hz because taking 200ms window before trial onset as baseline

h_resp = nan(nCells, nStimTypes);
p_resp = nan(nCells, nStimTypes);

for id = 1:nStimTypes
    [h_resp(:,id), p_resp(:,id)] = ttest2(...
        squeeze(resp_cell_trials(:,id,:)),...
        squeeze(base_cell_trials(:,id,:)),...
        'dim', 2, 'tail','right', 'alpha', 0.05./(nStimTypes));
end

% Make an index of cells significantly responsive to gratings
resp_ind_dir = find(sum(h_resp(:,:),2)); 

resp_ind_dir = 1:length(goodUnitStruct);

%% cell inclusion criteria

cort_cells_ind = find([goodUnitStruct.depth] >= 1200); % only cortical cells
nSpikesByCell = arrayfun(@(x) length(x.timestamps), goodUnitStruct);
SpkThreshedInd = find(nSpikesByCell > 1500); % find cells that had more than 1500 spikes
resp_cort_ind = intersect(intersect(resp_ind_dir,cort_cells_ind),SpkThreshedInd);
includeCells = intersect(intersect(resp_ind_dir,cort_cells_ind),SpkThreshedInd); % index of cells that were responsive, cortical, and nSpikes > 1500

%% extract spike events before and after trial onset
nTrials = length(trialStruct.onset);

onsets = [trialStruct.onset];
offsets = [trialStruct.offset];
tBeforeStimOnset = 0.300;
tAfterStimOnset = 1.000;
nCells = length(includeCells);
unitXtrialSpikesBef = cell(nCells,nTrials); 
unitXtrialSpikesAft = cell(nCells,nTrials); 
uXtSpikesWithinTrial = cell(nCells,nTrials); 

tic
parpool("Threads", 20)   % Start parallel pool processing
for ic = 1:length(includeCells)
    thisCellind = includeCells(ic);
    fprintf(['\nCell ' num2str(thisCellind) '\n']);
    % channel = goodUnitStruct(thisCellind).channel + 1;
    thisCellTS = goodUnitStruct(thisCellind).timestamps; % all events for iCell
    for iTrial = 1:nTrials
        thisTrialAftSpikesTS = thisCellTS(thisCellTS > onsets(iTrial) & thisCellTS < onsets(iTrial) + tAfterStimOnset); % absolute timestamps of spike events in each trial
        thisTrialBefSpikesTS = thisCellTS(thisCellTS > onsets(iTrial) - tBeforeStimOnset & thisCellTS < onsets(iTrial));
        unitXtrialSpikesBef{ic,iTrial} = thisTrialBefSpikesTS;
        unitXtrialSpikesAft{ic,iTrial} = thisTrialAftSpikesTS;
        withinTrialTS = vertcat(thisTrialBefSpikesTS,thisTrialAftSpikesTS) - onsets(iTrial); % find timestamp of spikes relative to trial onset (for easier plotting later)
        if ~isempty(withinTrialTS)
            uXtSpikesWithinTrial{ic,iTrial} = withinTrialTS;
        end
    end
end

testTimer = toc;
delete(gcp("nocreate"));

uXtSpikesWithinTrial = cellfun(@transpose,uXtSpikesWithinTrial, 'UniformOutput', false);
unitXtrialSpikesBef = cellfun(@transpose,unitXtrialSpikesBef, 'UniformOutput', false);
unitXtrialSpikesAft = cellfun(@transpose,unitXtrialSpikesAft, 'UniformOutput', false);
%% find trial indices of all stim types

stimTrialIdx = cell(2,nStimTypes);
allTrialIdentity = stimStruct.centerDirs;

for i = 1:nStimTypes
   thisStimTrialIdx = find(allTrialIdentity == uniqueStims(i)); 
   stimTrialIdx{1,i} = thisStimTrialIdx;
   stimTrialIdx{2,i} = uniqueStims(i);
end

%% plot example raster 

ic = max(nCells)-1; % example cell
stimIdx = 6; % example direction
depth = exptStruct.depth + goodUnitStruct(ic).depth;

% Get spike times for the specified unit and direction
spikeTimes  = uXtSpikesWithinTrial(ic, stimTrialIdx{1,stimIdx}); % Spikes in baseline

figure;
hold on
% Loop over each trial and plot the spikes
for trialIdx = 1:length(spikeTimes)
    % Get spike times for this trial
    trialSpikeTimes     = spikeTimes{trialIdx};

    % Y-axis position for this trial
    yPosition = trialIdx; 
    
    % Plot **stimulus-related spikes** (stimulus duration--0 to 1s)
    plot(trialSpikeTimes, yPosition * ones(size(trialSpikeTimes)), 'k.', 'MarkerSize', 5);
end

xlabel('Time (s)');
ylabel('Trial Number');
title(uniqueStims(stimIdx));
ylim([0 length(spikeTimes) + 1]);
xlim([-.25 1.1]); % Shows baseline (-.2 to 0s) and stimulus (0 to 1s)
% Plot stimulus onset line at **0s**
xline(0, 'r', 'LineWidth', 2); 
hold off

cells2include = includeCells(max(nCells)-3:max(nCells));

for ic = cells2include'  % These are example cells I handpicked 
    depth = exptStruct.depth + goodUnitStruct(ic).depth;
    uIdx = find(includeCells == ic);
    fig = figure;
        for i=1:nStimTypes
            subplot(6,3,i)
                plotRaster_TH(uXtSpikesWithinTrial,stimTrialIdx, uIdx,i)        
        end
    sgtitle(['unit '  num2str(ic) ', depth= ' num2str(depth)])
    set(gcf, 'Position', get(0, 'Screensize'));
    movegui('center')
end

%% spike events of ALL the cells
% nTrials = length(trialStruct);
% 
% onsets = [trialStruct.onset];
% offsets = [trialStruct.offset];
% tBeforeStimOnset = 0.200;
% tAfterStimOnset = 1.2;
% nCells = length(goodUnitStruct);
% unitXtrialSpikesBef = cell(nCells,nTrials); 
% unitXtrialSpikesAft = cell(nCells,nTrials); 
% uXtSpikesWithinTrial = cell(nCells,nTrials); 
% 
% tic
% parpool("Threads", 20)   % Start parallel pool processing
% for ic = 1:length(goodUnitStruct)
%     fprintf(['\nCell ' num2str(ic) '\n']);
%     % channel = goodUnitStruct(thisCellind).channel + 1;
%     thisCellTS = goodUnitStruct(ic).timestamps; % all events for iCell
%     for iTrial = 1:nTrials
%         thisTrialAftSpikesTS = thisCellTS(thisCellTS > onsets(iTrial) & thisCellTS < onsets(iTrial) + tAfterStimOnset); % absolute timestamps of spike events in each trial
%         thisTrialBefSpikesTS = thisCellTS(thisCellTS > onsets(iTrial) - tBeforeStimOnset & thisCellTS < onsets(iTrial));
%         unitXtrialSpikesBef{ic,iTrial} = thisTrialBefSpikesTS;
%         unitXtrialSpikesAft{ic,iTrial} = thisTrialAftSpikesTS;
%         withinTrialTS = vertcat(thisTrialBefSpikesTS,thisTrialAftSpikesTS) - onsets(iTrial); % find timestamp of spikes relative to trial onset (for easier plotting later)
%         if ~isempty(withinTrialTS)
%             uXtSpikesWithinTrial{ic,iTrial} = withinTrialTS;
%         end
%     end
% end
% 
% testTimer = toc;
% delete(gcp("nocreate"));
% 
% uXtSpikesWithinTrial = cellfun(@transpose,uXtSpikesWithinTrial, 'UniformOutput', false);


%% firing rate over time
% chunk every 10 trials to plot both baseline and evoked FR over trials
% baseline is 200ms preceding trial
% resp is 20ms to 1.020ms after stim onset
close all
chunkLength = 1; % 5 trials in a chunk
ylineDrug = floor(780/chunkLength);

% nChunks = floor((nTrials-2)/chunkLength); 
FRoTrBase = nan(nCells,nChunks);
FRoTrResp = nan(nCells,nChunks);

for ic = 1:nCells
    for it = 1:nChunks
        % trialsInChunk = (2+(it-1)*chunkLength:1+it*chunkLength); % 2 because skipping 1st trial
        thisTrials = uXtSpikesWithinTrial(ic,it);
        thisTrialsVector = [thisTrials{:}];
        nSpikesBase = sum(thisTrialsVector < 0);
        nSpikesResp = sum(thisTrialsVector > 0);
        FRoTrBase(ic,it) = nSpikesBase / (0.300 * chunkLength);
        FRoTrResp(ic,it) = nSpikesResp / (1.000 * chunkLength);
    end
end
FRoTrBase_Norm = zscore(FRoTrBase')';
FRoTrResp_Norm = zscore(FRoTrResp')';

figure
imagesc(FRoTrBase)
hold on
title(['Baseline FR over time (' num2str(chunkLength) ' trials a chunk)'])
xlabel('Trial Chunk index')
ylabel('Cell index')
xline(ylineDrug,"LineWidth",1,"Color",'r')
hold off


figure
imagesc(FRoTrResp)
hold on
title(['Evoked FR over time (' num2str(chunkLength) ' trials a chunk)'])
xlabel('Trial Chunk index')
ylabel('Cell index')
xline(ylineDrug,"LineWidth",1,"Color",'r')
hold off

figure
imagesc(FRoTrBase_Norm)
hold on
title(['Normalized Baseline FR over time (' num2str(chunkLength) ' trials a chunk)'])
xlabel('Trial Chunk index')
ylabel('Cell index')
xline(ylineDrug,"LineWidth",1,"Color",'r')
hold off

figure
imagesc(FRoTrResp_Norm)
hold on
title(['Normalized Evoked FR over time (' num2str(chunkLength) ' trials a chunk)'])
xlabel('Trial Chunk index')
ylabel('Cell index')
xline(ylineDrug,"LineWidth",1,"Color",'r')
hold off

%% ISI CDF

ctrlTrialThresh = 500;
drugTrialThresh = 1300;
nPlotCutoff = 6;

ctrlBase = unitXtrialSpikesBef(:,1:ctrlTrialThresh);
drugBase = unitXtrialSpikesBef(:,drugTrialThresh:end);
ctrlResp = unitXtrialSpikesAft(:,1:ctrlTrialThresh);
drugResp = unitXtrialSpikesAft(:,drugTrialThresh:end);

ctrlbaseISIbyTrial = cellfun(@diff,ctrlBase,'UniformOutput',false);
drugbaseISIbyTrial = cellfun(@diff,drugBase,'UniformOutput',false);
ctrlrespISIbyTrial = cellfun(@diff,ctrlResp,'UniformOutput',false);
drugrespISIbyTrial = cellfun(@diff,drugResp,'UniformOutput',false);

ISIctrlBase = cell(nCells,1);
ISIdrugBase = cell(nCells,1);
ISIctrlResp = cell(nCells,1);
ISIdrugResp = cell(nCells,1);

for i = 1:nCells
    ISIctrlBase{i,1} = [ctrlbaseISIbyTrial{i,:}];
    ISIdrugBase{i,1} = [drugbaseISIbyTrial{i,:}];
    ISIctrlResp{i,1} = [ctrlrespISIbyTrial{i,:}];
    ISIdrugResp{i,1} = [drugrespISIbyTrial{i,:}];
end

nfigs = num2str(floor(nCells/nPlotCutoff) + 1);
[x1,y1] = subplotn(nPlotCutoff);
counter = 0;
for ic = 1:nCells
    plotinfig = mod(ic,nPlotCutoff);
    if plotinfig == 1
        figure
        tiledlayout(x1,y1)
        counter = counter+1;
    end
        nexttile
        hold on
        cdfplot(ISIctrlBase{ic,1})
        cdfplot(ISIdrugBase{ic,1})
        title(['Cell ' num2str(ic) ' depth -' num2str(1800 - goodUnitStruct(includeCells(ic)).depth)])
        hold off
    if plotinfig == 0 || ic == nCells
        hold on
        legend('control','drug','Location','northeastoutside')
        currFig = num2str(counter);
        sgtitle(['Baseline ISI CDF Fig ' currFig '/' nfigs])
        hold off
        set(gcf, 'Position', get(0, 'Screensize'));
        movegui('center')
        print(gcf,fullfile(fout,['BaseISICDF_fig' num2str(counter)]),'-dpdf','-fillpage');
    end
end

counter = 0;
for ic = 1:nCells
    plotinfig = mod(ic,nPlotCutoff);
    if plotinfig == 1
        figure
        tiledlayout(x1,y1)
        counter = counter+1;
    end
        nexttile
        hold on
        cdfplot(ISIctrlResp{ic,1})
        cdfplot(ISIdrugResp{ic,1})
        title(['Cell ' num2str(ic) ' depth -' num2str(1800 - goodUnitStruct(includeCells(ic)).depth)])
        hold off
    if plotinfig == 0 || ic == nCells
        hold on
        legend('control','drug','Location','northeastoutside')
        currFig = num2str(counter);
        sgtitle(['Evoked ISI CDF Fig ' currFig '/' nfigs])
        hold off
        set(gcf, 'Position', get(0, 'Screensize'));
        movegui('center')
        print(gcf,fullfile(fout,['EvokedISICDF_fig' num2str(counter)]),'-dpdf','-fillpage');
    end
end

% figure
% hold on
% cdfplot(ISIctrlBase{1,1})
% cdfplot(ISIdrugBase{1,1})
% legend({"control","drug"})
% hold off
% 
% figure
% hold on
% cdfplot(ISIctrlResp{1,1})
% cdfplot(ISIdrugResp{1,1})
% legend({"control","drug"})
% hold off
%% summarizing above ctrl vs drug ISI
% for each cell, find average ISI of drug/control, then scatter compare
% base vs evoked

avgCtrlBase = cellfun(@mean,ISIctrlBase);
avgDrugBase = cellfun(@mean,ISIdrugBase);

avgCtrlResp = cellfun(@mean,ISIctrlResp);
avgDrugResp = cellfun(@mean,ISIdrugResp);

baseISIratio = avgDrugBase ./ avgCtrlBase;
respISIratio = avgDrugResp ./ avgCtrlResp;
baseISIratio = [baseISIratio(1:15)' baseISIratio(17:28)']'; % getting rid of outlier for i3347
respISIratio = [respISIratio(1:15)' respISIratio(17:28)']'; % getting rid of outlier for i3347
meanbase = mean(baseISIratio);
meanresp = mean(respISIratio);

[h,p] = ttest(baseISIratio,respISIratio);

figure
scatter(1,baseISIratio,"o","blue")
hold on
scatter(2,respISIratio,"o","blue")
for i = 1:nCells
    plot([1 2], [baseISIratio respISIratio], '-', 'Color', [0.5 0.5 0.5 0.4]);
end
plot(1,meanbase,".","Color","red","MarkerSize",20)
plot(2,meanresp,".","Color","red","MarkerSize",20)
xticks([1,2])
xlim([0,3])
ylim([0,2])
xticklabels({'base','evoked'})
ylabel('Avg Drug ISI/Avg Ctrl ISI')
hold off

[h1,p1,ci1,stats1] = ttest(baseISIratio, 1);
[h2,p2,ci2,stats2] = ttest(respISIratio, 1);


%% firing synchrony measurement
dT = 0.005; % how many seconds two spikes would need to be within to be considered synchronous
winSize = 20; % in seconds
overlap = 0.2;

exptStart = stimStruct.timestamps(1);
exptEnd = stimStruct.timestamps(end);

exptTimestamps = cell(nCells,1);
for ic = 1:nCells % get all includeCells' spike event timestamps within experiement
    thisCellSpikes = goodUnitStruct(includeCells(ic)).timestamps;
    exptTimestamps{ic} = thisCellSpikes(thisCellSpikes<exptEnd&thisCellSpikes>exptStart);
end

exptWindow = [exptStart exptEnd];
exptLength = exptEnd - exptStart;
nKer = getNKernels(exptLength,winSize,winSize*overlap);

sttc_mat = nan(nCells,nCells,nKer);
sttc_long = nan(nCells*(nCells-1)/2,nKer);
counter = 0;
for i = 1:nCells
    for j = i+1:nCells
        sttc_vector = getSTTC(exptTimestamps{i},exptTimestamps{j},exptWindow,dT,winSize,overlap);
        sttc_mat(i,j,:) = sttc_vector;
        sttc_mat(j,i,:) = sttc_vector;  % fill both sides
        counter = counter + 1;
        sttc_long(counter,:) = sttc_vector;
    end
end

popSTTC = nanmean(sttc_long,1);
figure
plot(popSTTC)
hold on
xline(780*2/(winSize-winSize*overlap),"r")
hold off
title('Population average STTC over time')
xlabel('Kernel Index')
ylabel('Coefficient')

figure
hold on
for i = 1:size(sttc_long,1)
    plot(sttc_long(i,:),"Color",[0.5 0.5 0.5],'LineWidth',0.1)
end
plot(popSTTC,'Color','r','LineWidth',1)
title('STTC over time')
hold off
xline(780*2/(winSize-winSize*overlap),"r")
xlabel('Kernel Index')
ylabel('Coefficient')


%% tuning 



