clear all
clear all global
close all

date = '250930';
mouse = 'i2781';
mwtime = '1410';  %1440 
chnls = 1:2:150;

fprintf([date ' ' mouse ' \n'])

%% Get stimulus on timestamps
% Sync signals
    mkdir(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' date])
    runCatGTret_SG(date)
    runTPrimeRet_SG(date)

% Load MW files
    rc = behavConstsAV;
    bName = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\Behavior\Data\data-' mouse '-' date '-' mwtime '.mat'];
    load(bName);

    ALLels = input.tGratingElevationDeg;
    elstim =[];
    for ii=1:length(ALLels)
        elstim = [elstim, cell2mat(ALLels(ii))];
    end
    ALLaz = input.tGratingAzimuthDeg;
    azstim =[];
    for ii=1:length(ALLels)
        azstim = [azstim, cell2mat(ALLaz(ii))];
    end

    stimElevation = elstim;
    stimAzimuth = azstim;
    % stimElevation   = cell2mat(cellfun(@double,input.tGratingElevationDeg));
    % stimAzimuth     = cell2mat(input.tGratingAzimuthDeg);

% Load stim on information (both MWorks signal and photodiode)
    cd (['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' date '\retinotopy' ])
    stimOnTimestampsMW  = table2array(readtable([date '_mworksStimOnSync.txt']));
    stimOnTimestampsPD  = table2array(readtable([date '_photodiodeSync.txt']));

% Lonely TTL removal
    lonelyThreshold = 0.1225; % 50 ms
    timeDiffs       = abs(diff(stimOnTimestampsPD));  % Compute pairwise differences efficiently
    hasNeighbor     = [false; timeDiffs < lonelyThreshold] | [timeDiffs < lonelyThreshold; false]; % Identify indices where a close neighbor exists
    filteredPD      = stimOnTimestampsPD(hasNeighbor);   % Keep only timestamps that have a neighbor within 50 ms

% Account for report of the monitor's refresh rate in the photodiode signal
    minInterval = 0.4; % Define a minimum separation threshold (should be longer than a refresh cycle but shorter than ISI)     
    leadingEdgesPD = filteredPD([true; diff(filteredPD) > minInterval]); % Extract the leading edges (first timestamp of each stimulus period)
    % [true; ...] ensures that the very first timestamp is always included because otherwise diff() returns an array that is one element shorter than the original.

% Check that PD signal starts at same time as MW signal; sometimes there are errant PD signals 
    firstMW = stimOnTimestampsMW(1); % Get the first MW timestamp
    leadingEdgesPD = leadingEdgesPD(leadingEdgesPD >= firstMW); % Remove any PD timestamps that occur before the first MW timestamp

    timestamps = leadingEdgesPD'; 

%% Load LFP data
% Choose LFP files
    CD = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Data\neuropixel\' date '\'];
    cd(CD);
    [LFPbinName,LFPpath] = uigetfile('*.lf.bin', 'Select LFP File');
    cd(LFPpath)

% Load LFP data (expected to be NPX data collected at 2500hz and reported in mV)
    lfFile      = dir(fullfile(pwd, '*imec0.lf.bin'));   % Get info on file that ends in imec0.lf.bin
    metaLFP     = ReadMeta(lfFile.name, pwd);       % Grab meta file from working directory
    LFPtime     = 0:1/str2double(metaLFP.imSampRate):str2double(metaLFP.fileTimeSecs);  % Time of each sample
    nSamp       = str2double(metaLFP.imSampRate)*str2double(metaLFP.fileTimeSecs); % Set number of samples to grab (as in, grabs all)
    LFPdata     = ReadBin(0, nSamp, metaLFP, lfFile.name, pwd);    % Load LFP (channels x samples)


%% Get retinotopic activity

% Parameters
Fs          = 2500; % Sampling frequency in Hz
cutoffhigh   = 300; % Cutoff frequency in Hz
[b, a] = butter(4, cutoffhigh/(Fs/2), 'low'); % Design filter (Butterworth, 4th order)

LFPdataFilt = filtfilt(b, a, LFPdata);
LFPdata = (LFPdataFilt-LFPdataFilt(383,:));
% 
% LFPdata = (LFPdata-LFPdata(383,:));
% 


% Set windows for baseline and stim on
    onWin       = 1;   % Stim On LFP window: 1s
    baseWin     = 0.5;   % Baseline window: 500 ms

% Create LFP window around Stim On times
    all_stimLFP = [];
    all_baseLFP = [];

    for is = 1:length(timestamps)
        % Find stim on window
        stimIdx             = find(timestamps(is)+onWin>LFPtime & LFPtime>=timestamps(is));     % Get sample indices for LFP stim on window
        stimLFP             = LFPdata(chnls,stimIdx);       % Create Stim On LFP variable with desired channels and sampling window
        all_stimLFP(:,:,is) = stimLFP;  
        tFromStimOn         = LFPtime(stimIdx);   % Get the real times of the samples (for x-axis)
        
        % Find baseline window
        baseIdx             = find(timestamps(is)>LFPtime & LFPtime>=(timestamps(is)-baseWin));
        baseLFP             = mean(LFPdata(chnls,baseIdx),2);
        all_baseLFP(:,is)   = baseLFP;

        if baseIdx(end)+1 ~= stimIdx(1)
            error('wrong baseline/stim windows')
        else; end
    end
    % Intended output: 'all_stimLFP' is [ nChannels x nSamples x nTrials ]
    % and 'all_baseLFP' is [ nChannels x nTrials ]

    baseLFP_forSub  = reshape(all_baseLFP,[size(all_baseLFP,1),1,size(all_baseLFP,2)]); % Reshape so that it will be automatically expanded along the nSamples dimension of the stimLFP during subtraction
    LFPbyTrial      = (all_stimLFP-baseLFP_forSub);  % Average across stim on windows and average across baselines, then subtract (it is currently in mV)

% Get average LFP for each retinotopic location
    uniqueEl    = unique(stimElevation);
    uniqueAz    = unique(stimAzimuth);
    nElevations = length(uniqueEl);
    nAzimuths   = length(uniqueAz);
    nStim       = nAzimuths*nElevations;

    stims = [];
    LFPbyStim = zeros(length(chnls), size(LFPbyTrial,2), nStim);  % Initialize as [ nChannels x onWin samples x nStimuli ]

    start=1;
    for ie = 1:nElevations
        indEl = find(stimElevation == uniqueEl(ie));
        for ia = 1:nAzimuths
            stims   = [stims; uniqueEl(ie) uniqueAz(ia)];
            indAz   = find(stimAzimuth == uniqueAz(ia));
            ind     = intersect(indEl,indAz);
            LFPbyStim(:,:,start) = mean(LFPbyTrial(:,:,ind),3);
            start=start+1;
        end
    end

    
   xTime        = 1:size(LFPbyStim,2);  % Get length of time axis
   yChannels    = 1:length(chnls);  % Get length of channel axis

   
   figure; % Line plots of absolute deflection, averaged across channels
   LFPbyStimAbs = squeeze(sum(abs(LFPbyStim), 1));  % [samples x stimuli]
   maxVal = max(LFPbyStimAbs(:));
   AUC = [];
   for is = 1:nStim
        subplot(nElevations,nAzimuths,is)
            plot(xTime,LFPbyStimAbs(:,is))
            hold on
            xlabel('time')
            ylabel('uV'); ylim([0 maxVal+100])
            AUC(is) = trapz(LFPbyStimAbs(125:375,is), 1); % AUC for for first 200 ms
        title(num2str(stims(is,:)))
   end
   [bAUC iAUC] = sort(AUC, 'descend');
   sgtitle(['Based on absolute deflection from 50 to 150ms: ' num2str(stims(iAUC(1),:))])
   movegui('center')
   print(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' date '\' date '_' mouse '_retinotopy_lineplot_HighFiltNormAfter.pdf'], '-dpdf','-bestfit')


 
 
stop
%% quickRet with spiking threshold
% ===================================================
%


% Choose spike files
    CD = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Data\neuropixel\' date '\'];
    cd(CD);
    [SPKbinName,SPKpath] = uigetfile('*.ap.bin', 'Select SPK File');
    cd(SPKpath)

    % Load spike data (expected to be NPX data collected at 2500hz and reported in mV)
    spkFile      = dir(fullfile(pwd, '*imec0.ap.bin'));   % Get info on file that ends in imec0.lf.bin
    metaSPK     = ReadMeta(spkFile.name, pwd);       % Grab meta file from working directory
    SPKtime     = 0:1/str2double(metaSPK.imSampRate):str2double(metaSPK.fileTimeSecs);  % Time of each sample
    nSamp       = str2double(metaSPK.imSampRate)*str2double(metaSPK.fileTimeSecs); % Set number of samples to grab (as in, grabs all)
    SPKdata     = ReadBin(0, nSamp, metaSPK, spkFile.name, pwd);    % Load spikes (channels x samples)

    figure()
        subplot 411
            ic = 30; %1:30:370
            plot(SPKtime(1:3000),SPKdata(ic,1:3000))
            hold on
            subtitle(['chnl ' num2str(ic)])
            % xlim([2000 2010])
            % ylim([-100 100])
            ylabel('uV')
       subplot 412
            ic = 60; %1:30:370
            plot(SPKtime(1:3000),SPKdata(ic,1:3000))
            hold on
            subtitle(['chnl ' num2str(ic)])
            ylabel('uV')
       subplot 413
            ic = 90; %1:30:370
            plot(SPKtime(1:3000),SPKdata(ic,1:3000))
            hold on
            subtitle(['chnl ' num2str(ic)])
            ylabel('uV')
       subplot 414
            ic = 120; %1:30:370
            plot(SPKtime(1:3000),SPKdata(ic,1:3000))
            hold on
            subtitle(['chnl ' num2str(ic)])
            ylabel('uV')     
    movegui('center')



% Parameters
Fs          = 30000; % Sampling frequency in Hz
cutofflow   = 150; % Cutoff frequency in Hz
cutoffhigh  = 300;
[b, a] = butter(4, cutofflow/(Fs/2), 'high'); % Design filter (Butterworth, 4th order)
[bb, aa] = butter(4, cutoffhigh/(Fs/2), 'high'); % Design filter (Butterworth, 4th order)

SPKdataFilt1 = filtfilt(b, a, SPKdata);
SPKdata = SPKdataFilt1;


% Set windows for baseline and stim on
    onWin       = 1;   % Stim On SPK window: 1s
    baseWin     = 0.5;   % Baseline window: 500 ms

% Create SPK window around Stim On times
    all_stimSPK = [];
    all_baseSPK = [];

    for is = 1:length(timestamps)
        % Find stim on window
        stimIdx             = find(timestamps(is)+onWin>SPKtime & SPKtime>=timestamps(is));     % Get sample indices for spike stim on window
        stimSPK             = SPKdata(chnls,stimIdx);       % Create Stim On SPK variable with desired channels and sampling window
        all_stimSPK(:,:,is) = stimSPK;  
        tFromStimOn         = SPKtime(stimIdx);   % Get the real times of the samples (for x-axis)
        
        % Find baseline window
        baseIdx             = find(timestamps(is)>SPKtime & SPKtime>=(timestamps(is)-baseWin));
        baseSPK             = mean(SPKdata(chnls,baseIdx),2);
        all_baseSPK(:,is) = baseSPK;

        if baseIdx(end)+1 ~= stimIdx(1)
            error('wrong baseline/stim windows')
        else; end
    end
    % Intended output: 'all_stimSPK' is [ nChannels x nSamples x nTrials ]
    % and 'all_baseSPK' is [ nChannels x nTrials ]

    baseSPK_forSub  = reshape(all_baseSPK,[size(all_baseSPK,1),1,size(all_baseSPK,2)]); % Reshape so that it will be automatically expanded along the nSamples dimension of the stimSPK during subtraction
    SPKbyTrial      = (all_stimSPK-baseSPK_forSub);  % Average across stim on windows and average across baselines, then subtract (it is currently in mV)


    threshold = -30;
    nCh   = size(SPKbyTrial,1);
    nSamp = size(SPKbyTrial,2);
    nStim = size(SPKbyTrial,3);
    
    nBins = 100;
    binSize = nSamp / nBins;  % should be 10 for your case
    
    spikeCount_binned = zeros(nCh, nBins, nStim);
    
    for ch = 1:nCh
        for stim = 1:nStim
            trace = squeeze(SPKbyTrial(ch,:,stim));
            below = trace < threshold;
    
            % Get downward crossings
            crossings = diff(below) == 1;
            
            % Find sample indices where crossings occur
            crossIdx = find(crossings);
    
            % Convert sample indices to bin indices
            binIdx = ceil(crossIdx / binSize);  % 1..nBins
            binIdx(binIdx < 1 | binIdx > nBins) = []; % safety
    
            % Count crossings per bin
            spikeCount_binned(ch,:,stim) = histcounts(binIdx, 0.5:1:(nBins+0.5));
        end
    end


% Get average SPK for each retinotopic location
    uniqueEl    = unique(stimElevation);
    uniqueAz    = unique(stimAzimuth);
    nElevations = length(uniqueEl);
    nAzimuths   = length(uniqueAz);
    nStim       = nAzimuths*nElevations;

    stims = [];
    SPKbyStim = zeros(length(chnls), size(spikeCount_binned,2), nStim);  % Initialize as [ nChannels x onWin samples x nStimuli ]

    start=1;
    for ie = 1:nElevations
        indEl = find(stimElevation == uniqueEl(ie));
        for ia = 1:nAzimuths
            stims   = [stims; uniqueEl(ie) uniqueAz(ia)];
            indAz   = find(stimAzimuth == uniqueAz(ia));
            ind     = intersect(indEl,indAz);
            SPKbyStim(:,:,start) = mean(spikeCount_binned(:,:,ind),3);
            start=start+1;
        end
    end

    
   xTime        = 1:size(spikeCount_binned,2);  % Get length of time axis
   yChannels    = 1:length(chnls);  % Get length of channel axis

   figure; % Waterfall plots
   for is = 1:nStim
        subplot(nElevations,nAzimuths,is)
            waterfall(xTime,yChannels,SPKbyStim(:,:,is))
            hold on
            % clim([-20 20])
            xlabel('time')
            ylabel('channel')
            % zlabel('amp (mV)'); zlim([-20 20])
        title(num2str(stims(is,:)))
   end
   movegui('center')
   % print(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' date '\' date '_' mouse '_retinotopy_spiking_waterfall_HighFiltNormAfter.pdf'], '-dpdf','-bestfit')
 

   figure; % Heat map of first 200 ms
   for is = 1:nStim
        subplot(nElevations,nAzimuths,is)
            imagesc(xTime,yChannels,SPKbyStim(:,:,is))
            hold on
            % clim([-20 20])
            xlabel('time (200 ms)')
            ylabel('channel')
            % xlim([0 500])
        title(num2str(stims(is,:)))
   end
   sgtitle('Heat map of first 200 ms after stimulus onset')
   movegui('center')
   % print(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' date '\' date '_' mouse '_retinotopy_spiking_imagesc_HighFiltNormAfter.pdf'], '-dpdf','-bestfit')

   
   figure; % Line plots of absolute deflection, averaged across channels
   SPKbyStimAbs = squeeze(sum(abs(SPKbyStim), 1));  % [samples x stimuli]
   maxVal = max(SPKbyStimAbs(:));
   minVal = min(SPKbyStimAbs(:));
   AUC = [];
   for is = 1:nStim
        subplot(nElevations,nAzimuths,is)
            plot(xTime,SPKbyStimAbs(:,is))
            hold on
            xlabel('time (1s total)')
            ylim([minVal maxVal])
            % xlim([0 20])
            AUC(is) = trapz(SPKbyStimAbs(5:10,is), 1); % AUC for for first 200 ms
        title(num2str(stims(is,:)))
   end
   [bAUC iAUC] = sort(AUC, 'descend');
   sgtitle(['Based on absolute deflection in first 200ms: ' num2str(stims(iAUC(1),:))])
   movegui('center')
   % print(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' date '\' date '_' mouse '_retinotopy_spiking_lineplot_HighFiltNormAfter.pdf'], '-dpdf','-bestfit')






       figure()
        subplot 411
            ic = 30; %1:30:370
            plot(SPKtime(1:3000),SPKbyTrial(15,1:3000,1))
            hold on
            subtitle(['chnl ' num2str(ic)])
            yline(-10)
            % xlim([2000 2010])
            % ylim([-100 100])
            ylabel('uV')
       subplot 412
            ic = 30; %1:30:370
            plot(SPKtime(1:3000),SPKbyTrial(15,1:3000,4))
            hold on
            subtitle(['chnl ' num2str(ic)])
            yline(-10)
            ylabel('uV')
       subplot 413
            ic = 90; %1:30:370
            plot(SPKtime(1:3000),SPKbyTrial(45,1:3000,1))
            hold on
            yline(-10)
            subtitle(['chnl ' num2str(ic)])
            ylabel('uV')
       subplot 414
            ic = 90; %1:30:370
            plot(SPKtime(1:3000),SPKbyTrial(45,1:3000,4))
            hold on
            yline(-10)
            subtitle(['chnl ' num2str(ic)])
            ylabel('uV')     
    movegui('center')