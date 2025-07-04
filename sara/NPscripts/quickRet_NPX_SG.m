clear all
clear all global
close all

date = '250702';
mouse = 'i2761';
mwtime = '1520';   
chnls = 1:2:220;

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
    lonelyThreshold = 0.05; % 50 ms
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
cutofflow   = 150; % Cutoff frequency in Hz
cutoffhigh  = 300;
[b, a] = butter(4, cutofflow/(Fs/2), 'low'); % Design filter (Butterworth, 4th order)
[bb, aa] = butter(4, cutoffhigh/(Fs/2), 'low'); % Design filter (Butterworth, 4th order)

LFPdata1=LFPdata;
%LFPdataNorm = (LFPdata-LFPdata(300,:));
LFPdataFilt1 = filtfilt(b, a, LFPdata);
%LFPdataFilt2 = filtfilt(bb, aa, LFPdata);

LFPdata = LFPdataFilt1;
LFPdata = (LFPdata-LFPdata(300,:));


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

   figure; % Waterfall plots
   for is = 1:nStim
        subplot(nElevations,nAzimuths,is)
            waterfall(xTime,yChannels,LFPbyStim(:,:,is))
            hold on
            clim([-20 20])
            xlabel('time')
            ylabel('channel')
            zlabel('amp (mV)'); zlim([-20 20])
        title(num2str(stims(is,:)))
   end
   movegui('center')
   print(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' date '\' date '_' mouse '_retinotopy_waterfall_HighFiltNormAfter.pdf'], '-dpdf','-bestfit')
 

   figure; % Heat map of first 200 ms
   for is = 1:nStim
        subplot(nElevations,nAzimuths,is)
            imagesc(xTime,yChannels,LFPbyStim(:,:,is))
            hold on
            clim([-20 20])
            xlabel('time (200 ms)')
            ylabel('channel')
            xlim([0 500])
        title(num2str(stims(is,:)))
   end
   sgtitle('Heat map of first 200 ms after stimulus onset')
   movegui('center')
   print(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' date '\' date '_' mouse '_retinotopy_imagesc_HighFiltNormAfter.pdf'], '-dpdf','-bestfit')

   
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
            AUC(is) = trapz(LFPbyStimAbs(1:500,is), 1); % AUC for for first 200 ms
        title(num2str(stims(is,:)))
   end
   [bAUC iAUC] = sort(AUC, 'descend');
   sgtitle(['Based on absolute deflection in first 200ms: ' num2str(stims(iAUC(1),:))])
   movegui('center')
   print(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\' date '\' date '_' mouse '_retinotopy_lineplot_HighFiltNormAfter.pdf'], '-dpdf','-bestfit')


 
 