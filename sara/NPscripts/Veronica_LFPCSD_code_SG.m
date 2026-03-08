
% 1) Load continuous LFP
% 2) Resample if needed
% 3) Cut into trials
% 4) Convert to 3D matrix
% 5) Clean LFP (filtering + smoothing)
% 6) Compute CSD (2nd spatial derivative)
% 7) Interpolate + smooth
% 8) Plot

%% Load and optional resample LFP from TDT stream
% 
% TDT_GetADC  (currently used inline as script block)
%
% Purpose:
%   Extract analog LFP data from TDT stream structure and
%   optionally resample to a desired sampling rate.
%
% Ooutputs:
%   TS     -> channels x time continuous LFP
%   dur    -> total duration (sec)
%   tbin   -> time resolution (sec/sample)
%   tvec   -> time vector (sec)
%   Nchan  -> number of channels
%   chan   -> channel indices used
% 

% Input checks
strm.fs = double(strm.fs);

if(~exist('SR','var') || isempty(SR))
    SR = strm.fs;    
end

if(~exist('chan','var') || isempty(chan))
    chan = 1:size(strm.data, 1);    
end
Nchan = length(chan);

% Time definition (original sampling grid) 
dur  = size(strm.data, 2) / strm.fs;   % total recording duration (sec)
tbin = 1/strm.fs;                     % seconds per sample
TV   = 0: tbin : dur-tbin;            % original time vector

% Extract selected channels
tsdata = double(strm.data(chan,:));
clear strm;

% Optional resampling
% If desired sampling rate equals original, skip resampling.
if(tbin == 1/SR)
    TS   = tsdata;
    tvec = TV;
else
    % Resample time base
    [~, tvec] = resample(TV, TV, SR, 'pchip');
    % Preallocate resampled matrix
    TS = nan(Nchan, length(tvec));
    % Resample each channel independently
    for(i=1:Nchan)
        TS(i,:) = resample(tsdata(i,:), TV, SR, 'pchip');
    end
    % NOTE: tbin reassigned to SR (kept unchanged from original code)
    tbin = SR;
end


%% Trial segmentation (continuous --> trial matrix)
% 
% Purpose:
%   Convert continuous LFP (TS) into trial-aligned matrices
%   based on event timestamps (tzero) and time window (tmwin).
%
% Result:
%   OBJ structure containing:
%       - TrialTime
%       - Channel trial matrices
%       - Channel averages
%

if(~isempty(tzero)) % Determine trial format
    if(~isvector(tzero)) % tzero = [start end] for each trial
        if(min(size(tzero)) ~= 2)
            error('tzero has to be a vector or a two column matrix!');
        end
        if(size(tzero, 1) == 2)
            tzero = transp(tzero);
        end
        OBJ.Ntrial = size(tzero, 1);
    else % Single event time per trial
        OBJ.Ntrial = length(tzero);
        tzero = [tzero(:), tzero(:)];
    end

    % Remove last trial (possible incomplete recording)
    OBJ.Ntrial = OBJ.Ntrial - 1;
    tpos  = nan(OBJ.Ntrial,3);
    tzero = tzero / 1000;  % convert ms → sec

    % Locate time indices for each trial
    for(t=1:OBJ.Ntrial)
        Ts = find(OBJ.tvec >= tzero(t,1) + tmwin(1), 1, 'first');
        Te = find(OBJ.tvec <= tzero(t,2) + tmwin(2), 1, 'last');
        if(~isempty(Ts) && ~isempty(Te))
            tpos(t,1) = Ts;
            tpos(t,2) = Te;
        else % Drop incomplete trials
            OBJ.Ntrial = OBJ.Ntrial - 1;
            tpos(end,:) = [];
        end
    end

    % Determine trial lengths
    tpos(:,3) = diff(tpos(:,1:2),1,2)+1;
    Tmat = nan(OBJ.Ntrial, max(tpos(:,3)));
    OBJ.TrialTime = tmwin(1) + (0:max(tpos(:,3))-1) * OBJ.tbin;
    OBJ.ChanName = cell(OBJ.Nchan,1);
    OBJ.ChanAvrg = nan(OBJ.Nchan, max(tpos(:,3)));

    % Extract trial data for each channel
    for(c=1:OBJ.Nchan)
        cnm = sprintf('CH_%.2d', OBJ.chan(c));
        OBJ.ChanName{c} = cnm;
        OBJ.(cnm) = Tmat;
        for(t=1:OBJ.Ntrial)
            if(~any(isnan(tpos(t,:))))
                OBJ.(cnm)(t,1:tpos(t,3)) = OBJ.TS(c,tpos(t,1):tpos(t,2));
            end
        end
        OBJ.ChanAvrg(c,:) = nanmean(OBJ.(cnm));
    end
end

LFP = OBJ;  % Rename structure

%% Reformat into 3D matrix
% LFPmat → [channels x time x trials]

% Convert dynamic channel fields into 3D matrix for processing
LFPmat = nan(LFP.Nchan, length(LFP.TrialTime), LFP.Ntrial);  % initialize

for(c=1:LFP.Nchan)
    lcnm = sprintf('CH_%.2d', LFP.chan(c));
    LFPmat(c,:,:) = LFP.(lcnm)';
end

%% Load LFP and format into a 3D matrix

% Choose experiment
    iexp = 26; 
    exptloc = 'V1'; %LG

% Get experiment info
    baseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
    [exptStruct] = createExptStruct(iexp,exptloc); % Load relevant times and directories for this experiment
    mouse   = exptStruct.mouse;
    date    = exptStruct.date;
    loc     = exptStruct.loc;

% Create path to neuropixel data
    dataPath = fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', loc, 'Data', 'neuropixel', date);
    cd(dataPath)

% Navigate into imec folder
    matchingFolders = dir(fullfile(dataPath, [mouse '*']));  % Find folders in dataPath location that start with mouse name
    matchingFolder = matchingFolders(~contains({matchingFolders.name}, 'retinotopy'));   % Filter out folders that contain 'retinotopy' in the name

    if numel(matchingFolder) == 1 && matchingFolder(1).isdir    % If there is only one folder that starts with mouse name
        cd(fullfile(dataPath, matchingFolder(1).name));         % Change directory
    else
        error('Expected one folder for mouse %s, but found %d', mouse, numel(matchingFolder));  % Throw error if there is > or < than 1 folder that starts with mouse name and does not contain 'retinotopy'
    end

% Parameters
    depth       = exptStruct.depth;
    dz          = 20;       % 20 um between channels, vertically
    chnls       = 2:2:200;  % Only take even channels because NPX probe has two columns of staggered channels
    fs = 2500;  % Sampling rate (Hz), modify if different

% Load LFP data (expected to be NPX data collected at 2500hz and reported in mV)
    lfFile      = dir(fullfile(pwd, '*imec0.lf.bin'));   % Get info on file that ends in imec0.lf.bin
    metaLFP     = ReadMeta(lfFile.name, pwd);       % Grab meta file from working directory
    LFPtime     = 0:1/str2double(metaLFP.imSampRate):str2double(metaLFP.fileTimeSecs);  % Time of each sample
    nSamp       = str2double(metaLFP.imSampRate)*str2double(metaLFP.fileTimeSecs); % Set number of samples to grab (as in, grabs all)
    LFPdata     = ReadBin(0, nSamp, metaLFP, lfFile.name, pwd);    % Load LFP (channels x samples)

    cutofflow   = 150; % Cutoff frequency in Hz
    [b, a] = butter(4, cutofflow/(fs/2), 'low'); % Design filter (Butterworth, 4th order)
    LFPdataFilt1 = filtfilt(b, a, LFPdata);
    LFPdata = (LFPdataFilt1-LFPdataFilt1(300,:));
    clear LFPdataFilt1
    
% Load Stimulus On times
    stimStruct = createStimStruct(exptStruct);
    timestamps = stimStruct.timestamps{5};


% Set windows for baseline and stim on
    onWin       = .15;   % Stim On LFP window: 500 ms
    baseWin     = .15;   % Baseline window: 500 ms

% Create LFP window around Stim On times
    all_stimLFP = [];
    all_baseLFP = [];
    all_LFP     = [];
    for is = 1:length(timestamps)
        % Find stim on window
        stimIdx             = find(timestamps(is)+onWin>LFPtime & LFPtime>=timestamps(is));     % Get sample indices for LFP stim on window
        stimLFP             = LFPdata(chnls,stimIdx);       % Create Stim On LFP variable with desired channels and sampling window
        all_stimLFP(:,:,is) = stimLFP;
        tFromStimOn         = LFPtime(stimIdx);   % Get the real times of the samples (for x-axis)
        
        % Find baseline window
        baseIdx             = find(timestamps(is)>LFPtime & LFPtime>=(timestamps(is)-baseWin));
        baseLFP             = LFPdata(chnls,baseIdx);
        all_baseLFP(:,:,is)   = baseLFP;

        % Concatenate in time: baseline first, then stim
        fullLFP = [baseLFP stimLFP];
        all_LFP(:,:,is) = fullLFP;

        LFPnorm = stimLFP - mean(baseLFP,2);
        all_LFPnorm(:,:,is) = LFPnorm;

        if baseIdx(end)+1 ~= stimIdx(1)
            error('wrong baseline/stim windows')
        else; end
    end

    LFP = (mean(all_stimLFP,3)-mean(all_baseLFP,2));  % Average across stim on windows and average across baselines, then subtract and convert to muV

% ======================================
% ====  from my old CSD code ==========

 % Set windows for baseline and stim on
    onWin       = .2;   % Stim On LFP window: 100 ms
    baseWin     = .1;   % Baseline window: 100 ms

% Create LFP window around Stim On times
    all_stimLFP=[];
    all_baseLFP=[];
    for is = 1:200 %1:length(timestamps)
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

    LFP = (mean(all_stimLFP,3)-mean(all_baseLFP,2))./1000;  % Average across stim on windows and average across baselines, then subtract and convert to muV
figure; 
    subplot 221
        imagesc(LFP)
% ======================================

% all_LFP is [channels x time x trials]

LFPmat = LFP; %all_LFPnorm; % all_LFP

%% LFP preprocessing
% 
% Purpose: Preprocess LFP before CSD
%
% Order per channel & trial:
%   1) Despike (Hampel)
%   2) Notch filter (line noise removal)
%   3) Bandpass filter
%   4) Demean
%   5) Optional spatial/temporal smoothing
%
% Input:
%   LFPmat  -> channels x time x trials
%
% Output:
%   fLFP    -> same size, filtered
% 

% Get dimensions
Nchan  = size(LFPmat, 1);
Ntime  = size(LFPmat, 2);
Ntrial = size(LFPmat, 3);

% Preallocate
fLFP = nan(Nchan, Ntime, Ntrial);

% Temporal filtering loop

% For now, no notch filter and just use cheby filter. No despiking
do_despike = 0;
do_demean = 1;
[Tb, Ta] = cheby2(4, 20, 2 * [8, 100] ./fs,   'bandpass');

for(c=1:Nchan)
    parfor(t=1:Ntrial)        
        LFPtrace = squeeze(LFPmat(c,:,t));
       
        if(do_despike == 1) % remove spikes from the signal
            LFPtrace = hampel(LFPtrace, dspk_wdw, dspk_std);
        end
       
        % % apply notch filter to remove line noise
        % if(~isempty(Notch))
        %     LFPtrace = filtfilt(NotchB, NotchA, LFPtrace);
        % end
       
        % filter
        LFPtrace = filter(Tb, Ta, LFPtrace);

        % subtract mean and scale
        if(do_demean == 1)
            LFPtrace = LFPtrace-mean(LFPtrace);
        end
       
        fLFP(c,:,t) = LFPtrace;
    end
end

avg_fLFP = mean(fLFP,3);
avg_LFPmat =  mean(LFPmat,3);

figure; 
    subplot 221
        imagesc(avg_fLFP)
    subplot 222
        imagesc(avg_LFPmat)

% ====================

% % Optional smoothing
% if(~isempty(sm2D))
%     if(length(sm2D) == 1)  % Create Gaussian kernel if 1D smoothing
%         smwin = sm2D;
%         Half_BW   = round(4*smwin);
%         x         = -Half_BW : Half_BW;
%         GaussKrnl = (1/(sqrt(2*pi)*smwin)) * exp(-1*((x.^2) / (2*smwin^2)));
%     end
%     for(t=1:Ntrial)
%         if(length(sm2D) == 2)
%             % 2D smoothing across channels and time
%             tLFP = squeeze(fLFP(:,:,t));
%             fLFP(:,:,t) = imgaussfilt(tLFP, sm2D);
%         elseif(length(sm2D) == 1)
%             % 1D smoothing across channels only
%             parfor(i=1:Ntime)
%                 tLFP = squeeze(fLFP(:,i,t))';
%                 fLFP(:,i,t) = conv(tLFP, GaussKrnl, 'same');
%             end
%         end
%     end
% end


%% CSD calculation
% 
% Purpose: Compute CSD via discrete second spatial derivative
%
% Input:
%   fLFP  -> channels x time x trials
%
% Output:
%   CSD      -> interpolated CSD
%   CSDraw   -> raw CSD (trial-averaged)
% 

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

    % Optional pre-smoothing
    % if(length(pre_sm) == 1)
    %     for(i=1:Nchan)
    %         tLFP(:,i) = conv(tLFP(:,i), GaussKrnl, 'same');
    %     end
    % elseif(length(pre_sm) == 2)
    %     tLFP = imgaussfilt(tLFP, pre_sm);
    % end

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


Csigma = 0.00033; % estimated conductivity for mouse cortex (double check this later)


% Unit conversion
CSDraw = 1000 * CSDraw .* Csigma; 

% Padding
CSDraw = padarray(CSDraw, [1 0], NaN);

% switch pad
%     case 'dup'
%         CSDraw = padarray(CSDraw, [1 0],'replicate');
%     case 'nan'
%         CSDraw = padarray(CSDraw, [1 0], NaN);
%     case 'zero'
%         CSDraw = padarray(CSDraw, [1 0]);
% end

ip = 10; % interpolation factor for upsampling data, default is a upsampling factor of 10. Leave empty, or set as 0 or 1 if not upsampling is desired

% Interpolation
if(any(ip > 1))
    if(length(ip) == 2)
        NewTime = linspace(1, Ntime, ip(2)*Ntime);
    else
        NewTime = 1:Ntime;
    end
    NewChan = linspace(1, Nchan, ip(1)*Nchan);
    [Tip, Cip] = meshgrid(NewTime, NewChan);
    CSD = interp2(CSDraw, Tip, Cip, 'spline');
else
    CSD = CSDraw;
end


fimagesc(CSDraw)
