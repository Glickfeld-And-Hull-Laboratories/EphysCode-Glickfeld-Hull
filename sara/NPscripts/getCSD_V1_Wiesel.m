
function getCSD_V1_Wiesel(iexp)

for iexp = [26 25 24 23 22 21 20 19 18 ]
exptloc = 'V1'; %LG

    [exptStruct] = createExptStruct(iexp,exptloc); % Load relevant times and directories for this experiment
    clearvars -except iexp exptloc exptStruct

% Get experiment info
    mouse   = exptStruct.mouse;
    date    = exptStruct.date;
    loc     = exptStruct.loc;

% Create path to neuropixel data
    dataPath = fullfile('/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/',loc, 'Data', 'neuropixel', date); % For Wiesel
    cd(dataPath)

% Navigate into imec folder
    matchingFolders = dir(fullfile(dataPath, [mouse '*']));  % Find folders in dataPath location that start with mouse name
    matchingFolder = matchingFolders(~contains({matchingFolders.name}, 'retinotopy'));   % Filter out folders that contain 'retinotopy' in the name

    if numel(matchingFolder) == 1 && matchingFolder(1).isdir    % If there is only one folder that starts with mouse name
        cd(fullfile(dataPath, matchingFolder(1).name));         % Change directory
    else
        error('Expected one folder for mouse %s, but found %d', mouse, numel(matchingFolder));  % Throw error if there is > or < than 1 folder that starts with mouse name and does not contain 'retinotopy'
    end

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
    chnls       = 2:2:220;  % Only take even channels because NPX probe has two columns of staggered channels
    cutofflow   = 150; % Cutoff frequency in Hz
    [b, a] = butter(4, cutofflow/(Fs/2), 'low'); % Design filter (Butterworth, 4th order)
    LFPdataFilt1 = filtfilt(b, a, LFPdata);
    LFPdata = (LFPdataFilt1-LFPdataFilt1(300,:));
    clear LFPdataFilt1

% Load Stimulus On times
    stimStruct = createStimStruct_Wiesel(exptStruct);
    timestamps = stimStruct.timestamps{5};

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
        stimLFP             = LFPdata(chnls,stimIdx);       % Create Stim On LFP variable with desired channels and sampling window
        stimLFPraw          = LFPdataraw(chnls,stimIdx); 
        all_stimLFP(:,:,is) = stimLFP;
        tFromStimOn         = LFPtime(stimIdx);   % Get the real times of the samples (for x-axis)
        
        % Find baseline window
        baseIdx             = find(timestamps(is)>LFPtime & LFPtime>=(timestamps(is)-baseWin));
        baseLFP             = LFPdata(chnls,baseIdx);
        all_baseLFP(:,:,is)   = baseLFP;

        LFP_BlTrial = [stimLFP - mean(baseLFP,2)];
        all_LFPblTr(:,:,is) = LFP_BlTrial;

        if baseIdx(end)+1 ~= stimIdx(1)
            error('wrong baseline/stim windows')
        else; end
    end

    LFP_blTr = (mean(all_LFPblTr,3));  % Subtract avg baseline on a trial by trial basis, then averaged across stim on windows
    fLFP = LFP_blTr;

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
yLFP = (0:size(fLFP,1)-1)*20 + exptStruct.depth;
yCSD = (1:size(CSDraw,1)-1)*20 + exptStruct.depth;


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
    sgtitle([mouse ' ' date ', expt ' num2str(iexp)])
    print(fullfile(['/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/' loc '/Analysis/Neuropixel/' date '/' mouse '-' date '-findLayer4-CSD.pdf']),'-dpdf','-bestfit')


end


end