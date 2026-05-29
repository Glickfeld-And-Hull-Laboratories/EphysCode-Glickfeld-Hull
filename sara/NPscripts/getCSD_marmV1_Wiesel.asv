
%% getCSD_marmV1_Wiesel
close all; clear all;
iexp=6;

doSpikes = 0;
%%

expts = {'g01','g06','g12','g17','tss2','tss6','tss7'};

% Create path to neuropixel data
    dataPath = fullfile('/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/sara/Data/fromNicholas/CrossOri_randDirFourPhase_V1_marmoset_LFP/', expts{iexp}); % For Wiesel
    cd(dataPath)


% Load LFP data (expected to be NPX data collected at 2500hz and reported in mV)
    lfFile      = dir(fullfile(pwd, '*imec0.lf.bin'));   % Get info on file that ends in imec0.lf.bin
    metaLFP     = ReadMeta(lfFile.name, pwd);       % Grab meta file from working directory
    LFPtime     = 0:1/str2double(metaLFP.imSampRate):str2double(metaLFP.fileTimeSecs);  % Time of each sample
    nSamp       = str2double(metaLFP.imSampRate)*str2double(metaLFP.fileTimeSecs); % Set number of samples to grab (as in, grabs all)
    LFPdata     = ReadBin(0, nSamp, metaLFP, lfFile.name, pwd);    % Load LFP (channels x samples)
    LFPdataraw  = LFPdata;



% Parameters
    Fs          = 2500; % Sampling frequency in Hz
    dz          = 20;       % 20 um between channels, vertically
    chnls       = 2:2:330;  % Only take even channels because NPX probe has two columns of staggered channels
    cutofflow   = 150; % Cutoff frequency in Hz
    [b, a] = butter(4, cutofflow/(Fs/2), 'low'); % Design filter (Butterworth, 4th order)
    LFPdataFilt1 = filtfilt(b, a, LFPdata);
    % 60Hhz notch filter
    d = designfilt('bandstopiir','FilterOrder',2,'HalfPowerFrequency1',59,'HalfPowerFrequency2',61,'DesignMethod','butter','SampleRate',Fs);
    LFPdataFilt2 = filtfilt(d,LFPdataFilt1);
    clear LFPdataFilt1
    d = designfilt('bandstopiir','FilterOrder',2,'HalfPowerFrequency1',119,'HalfPowerFrequency2',121,'DesignMethod','butter','SampleRate',Fs);
    LFPdata = filtfilt(d,LFPdataFilt2);
    clear LFPdataFilt2



% Load Stimulus On times
    stimTimesMat = dir(fullfile(pwd,'*.mat'));
    
    for i = 1:length(stimTimesMat)
        load(stimTimesMat(i).name)
    end

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
    

% Set windows for baseline and stim on
    onWin       = .25;   % Stim On LFP window: 500 ms
    baseWin     = .25;   % Baseline window: 500 ms


% Create LFP window around Stim On times
    all_stimLFP = [];
    all_baseLFP = [];
    all_LFP     = [];
    all_LFPblTr = [];
    for is = 1:length(timestamps)
        % Find stim on window
        stimIdx             = find(timestamps(is)+onWin>LFPtime & LFPtime>=timestamps(is));     % Get sample indices for LFP stim on window
        stimLFP             = LFPdata(chnls,stimIdx(1:625));       % Create Stim On LFP variable with desired channels and sampling window
        stimLFPraw          = LFPdataraw(chnls,stimIdx(1:625)); 
        all_stimLFP(:,:,is) = stimLFP;
        tFromStimOn         = LFPtime(stimIdx(1:625));   % Get the real times of the samples (for x-axis)
        
        % Find baseline window
        baseIdx             = find(timestamps(is)>LFPtime & LFPtime>=(timestamps(is)-baseWin));
        baseLFP             = LFPdata(chnls,baseIdx(1:625));
        all_baseLFP(:,:,is)   = baseLFP;

        LFP_BlTrial = [stimLFP - mean(baseLFP,2)];
        all_LFPblTr(:,:,is) = LFP_BlTrial;

%         if baseIdx(end)+1 ~= stimIdx(1)
%             error('wrong baseline/stim windows')
%         else; end
    end

    LFP_blTr = (mean(all_LFPblTr(:,:,:),3));  % Subtract avg baseline on a trial by trial basis, then averaged across stim on windows
    fLFP = LFP_blTr;
%     fLFP = mean(all_stimLFP,3);
% 


%% spike PSTHs

if doSpikes == 1

% PARAMETERS
fs_spike   = 30000;     % <-- FIX THIS if different
binSize    = 0.01;      % 10 ms bins
win        = [-baseWin onWin];   % e.g. [-0.25 0.25]

edges      = win(1):binSize:win(2);
tCenters   = edges(1:end-1) + binSize/2;

nCells     = size(gspikes,1);
nTrials    = length(timestamps);
nBins      = length(tCenters);

% Output: cells x trials x time
PSTH = zeros(nCells, nTrials, nBins);

% LOOP
for iCell = 1:nCells
    
    % Convert spike indices to seconds
    spkIdx   = find(gspikes(iCell,:));   % get spike sample indices
    spkTimes = spkIdx / fs_spike;        % convert to seconds
    
    for iTrial = 1:nTrials
        
        % Align spikes to this trial
        alignedSpikes = spkTimes - timestamps(iTrial);
        
        % Keep spikes in window
        alignedSpikes = alignedSpikes(alignedSpikes >= win(1) & alignedSpikes <= win(2));
        
        % Bin
        PSTH(iCell,iTrial,:) = histcounts(alignedSpikes, edges);
        
    end
end

% OPTIONAL: convert to firing rate (Hz)
PSTH_rate = PSTH / binSize;



    
figure;
    imagesc(squeeze(mean(PSTH,2))); clim([0 .1])

grat = find(stimdef(:,2) == 0);
plaid = find(stimdef(:,2) == 1);

figure;
    unit = 117;
    sgtitle(['expt ' expts{iexp} ', unit ' num2str(unit)])
    subplot(3,3,1)
        plot(1:50,squeeze(mean(mean(PSTH(unit,grat,:),2),1)))
        xline(25)
        xline(29,'r')
        subtitle(['all grating trials, n=' num2str(length(grat))])
    subplot(3,3,4)
        plot(1:50,squeeze(mean(mean(PSTH(unit,plaid,:),2),1)))
        xline(25)
        xline(29,'r')
        subtitle(['all plaid trials, n=' num2str(length(plaid))])
    subplot(3,3,2)
        plot(1:50,squeeze(mean(mean(PSTH(unit,1:150,:),2),1)))
        xline(25)
        xline(29,'r')
        subtitle('trials 1:150')
    subplot(3,3,5)
        plot(1:50,squeeze(mean(mean(PSTH(unit,151:300,:),2),1)))
        xline(25)
        xline(29,'r')
        subtitle('trials 151:300')
    subplot(3,3,8)
        plot(1:50,squeeze(mean(mean(PSTH(unit,301:451,:),2),1)))
        xline(25)
        xline(29,'r')
        subtitle('trials 301:450')
    subplot(3,3,3)
        plot(1:50,squeeze(mean(mean(PSTH(unit,451:500,:),2),1)))
        xline(25)
        xline(29,'r')
        subtitle('trials 451:500')
    subplot(3,3,6)
        plot(1:50,squeeze(mean(mean(PSTH(unit,501:651,:),2),1)))
        xline(25)
        xline(29,'r')
        subtitle('trials 501:650')
    subplot(3,3,9)
        plot(1:50,squeeze(mean(mean(PSTH(unit,651:700,:),2),1)))
        xline(25)
        xline(29,'r')
        subtitle('trials 651:700')
    print(fullfile(['/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/sara/Analysis/Neuropixel/marmosetFromNicholas/',['marmosetV1_' expts{iexp} 'b'], '/' expts{iexp} '-singleCells_byTrialChunks-cell' num2str(unit) '.pdf']),'-dpdf')

else 
end


%% LFP chunks and CSD analysis

figure;
    subplot 241
        imagesc(mean(all_LFPblTr(:,:,1:50),3)); hold on
        xline(0.06*2500,'r')
        subtitle('trials 1:50')
        ylabel('channels (every other)')
        xlabel('time (s)')
        set(gca,'TickDir','out')
        set(gca,'YDir','normal')
    subplot 242
        imagesc(mean(all_LFPblTr(:,:,51:100),3))
        xline(0.06*2500,'r')
        subtitle('trials 51:100')
        xlabel('time (s)')
        set(gca,'TickDir','out')
        set(gca,'YDir','normal')
    subplot 243
        imagesc(mean(all_LFPblTr(:,:,101:150),3))
        xline(0.06*2500,'r')
        subtitle('trials 101:150')
        xlabel('time (s)')
        set(gca,'TickDir','out')
        set(gca,'YDir','normal')
    subplot 244
        imagesc(mean(all_LFPblTr(:,:,151:200),3))
        xline(0.06*2500,'r')
        subtitle('trials 151:200')
        xlabel('time (s)')
        set(gca,'TickDir','out')
        set(gca,'YDir','normal')
    subplot 245
        imagesc(mean(all_LFPblTr(:,:,551:600),3))
        xline(0.06*2500,'r')
        subtitle('trials 551:600')
        xlabel('time (s)')
        set(gca,'TickDir','out')
        set(gca,'YDir','normal')
%     subplot 246
%         imagesc(mean(all_LFPblTr(:,:,601:650),3))
%         xline(0.06*2500,'r')
%         subtitle('trials 601:650')
%         xlabel('time (s)')
%         set(gca,'TickDir','out')
%         set(gca,'YDir','normal')
%     subplot 247
%         imagesc(mean(all_LFPblTr(:,:,651:700),3))
%         xline(0.06*2500,'r')
%         subtitle('trials 651:700')
%         xlabel('time (s)')
%         set(gca,'TickDir','out')
%         set(gca,'YDir','normal')
    subplot 248
        imagesc(mean(all_LFPblTr(:,:,:),3))
        xline(0.06*2500,'r')
        subtitle('all trials')
        xlabel('time (s)')
        set(gca,'TickDir','out')
        set(gca,'YDir','normal')
    movegui('center')
    sgtitle([expts{iexp}])
    print(fullfile(['/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/sara/Analysis/Neuropixel/marmosetFromNicholas/',['marmosetV1_' expts{iexp} 'b'], '/' expts{iexp} '-findSurface-LFPbyChannel_byTrialChunks.pdf']),'-dpdf')


% CSD analysis


%  Dimensions 
    Nchan  = size(fLFP, 1);
    Ntime  = size(fLFP, 2);
    Ntrial = size(fLFP, 3);
    
    dE = 0.020; % spacing of electrode probes in mm. Assumes a constant spacing for now

% Channel spacing (mm)
    CH_spacing = (0 : Nchan-1) * dE;
    CH_step    = median(CH_spacing);

% Preallocate
    CSDmat = nan(Nchan-2, Ntime, Ntrial);

% Compute spatial second derivative per trial
    for(t=1:Ntrial)
    
        tLFP = squeeze(fLFP(:,:,t))';  % Transpose to time x channel
    
        % Build discrete Laplacian matrix 
        out = nan(Nchan-2, Nchan);
        for(i=1:Nchan-2)
            for(j=1:Nchan)
                if(i == j-1)
                    out(i,j) = -2/CH_step^2;
    
                elseif(abs(i-j+1) == 1)
                    out(i,j) = 1/CH_step^2;
    
                else
                    out(i,j) = 0;
                end
            end
        end
    
        % Apply second derivative
        tCSD = out * tLFP';
        CSDmat(:,:,t) = tCSD;
    end

% Trial averaging
    if(Ntrial > 1)
        CSDraw = squeeze(mean(CSDmat,3));
    else
        CSDraw = CSDmat;
    end

t = (0:size(CSDraw,2)-1)/Fs;   % time vector in seconds
depth = -3500;
yLFP = (0:size(fLFP,1)-1)*20 + depth;
yCSD = (1:size(CSDraw,1)-1)*20 + depth;


figure;
movegui('center')
    subplot 231
        imagesc(t, yLFP, stimLFP); hold on; colorbar  
        xline(0.06, 'c')
        yline(-180)
        subtitle('LFP raw, one trial')
        ylabel('channels (every other)')
        xlabel('time (s)')
        set(gca,'TickDir','out')
        set(gca,'YDir','normal')
    subplot 232
        imagesc(t, yLFP, fLFP); hold on; colorbar  
        xline(0.06, 'c')
        yline(-180)
        subtitle('LFP, averaged all trials')
        ylabel('channels (every other)')
        xlabel('time (s)')
        set(gca,'TickDir','out')
        set(gca,'YDir','normal')
    subplot 233
        imagesc(t, yCSD, -CSDraw); hold on; colorbar
        xline(0.06,'c')
        yline(-180)
%         yline(yCSD(sumMinIdx),'b')
        subtitle('current source density')
        ylabel('channels (every other)')
        xlabel('time (s)')
        set(gca,'TickDir','out')
        set(gca,'YDir','normal')
    sgtitle([expts{iexp}])
    print(fullfile(['/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/sara/Analysis/Neuropixel/marmosetFromNicholas/',['marmosetV1_' expts{iexp} 'b'], '/' expts{iexp} '-findLayer4-CSD.pdf']),'-dpdf')

%     save(fullfile(['/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/' loc '/Analysis/Neuropixel/' date '/' mouse '-' date '-findLayer4-CSD.mat']), 'fLFP', 'CSDraw','chnls', 'Fs', 'dE', 'depth')

