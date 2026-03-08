
iexp=26;
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
    LFP     = ReadBin(0, nSamp, metaLFP, lfFile.name, pwd);    % Load LFP (channels x samples)

% Parameters
    fs          = 2500; % Sampling frequency in Hz
    dz          = 20;       % 20 um between channels, vertically
    chnls       = 2:2:200;  % Only take even channels because NPX probe has two columns of staggered channels

% Cheby2 filter
    [Tb, Ta] = cheby2(4, 20, 2 * [8, 100] ./fs,   'bandpass');
    LFPdataChebFilt = filter(Tb, Ta, LFP);

% Notch filter
    f0 = 60;              % notch frequency
    Q  = 35;              % quality factor (controls bandwidth)
    w0 = 2*pi*f0/fs;
    alpha = sin(w0)/(2*Q);
    b0 = 1;
    b1 = -2*cos(w0);
    b2 = 1;
    a0 = 1 + alpha;
    a1 = -2*cos(w0);
    a2 = 1 - alpha;
    NotchB = [b0 b1 b2]/a0;
    NotchA = [a0 a1 a2]/a0;  
    LFPdataNotchFilt = filtfilt(NotchB, NotchA, LFPdataChebFilt);
    clear LFPdataChebFilt
   
% Despike
    dspk_std = 5;
    dspk_wdw = 4;
    LFPdataDespike = hampel(LFPdataNotchFilt, dspk_wdw, dspk_std);

    clear LFPdataNotchFilt
    LFPdata = LFPdataDespike;


% Load Stimulus On times
    stimStruct = createStimStruct_Wiesel(exptStruct);
    timestamps = stimStruct.timestamps{5};

% Set windows for baseline and stim on
    onWin       = .5;   % Stim On LFP window: 500 ms
    baseWin     = .5;   % Baseline window: 500 ms

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
        LFP_MinusMean = [stimLFP - mean(stimLFP,2)];
        all_LFPmm(:,:,is) = LFP_MinusMean;

        LFP_BlTrial = [stimLFP - mean(baseLFP,2)];
        all_LFPblTr(:,:,is) = LFP_BlTrial;

        if baseIdx(end)+1 ~= stimIdx(1)
            error('wrong baseline/stim windows')
        else; end
    end

    LFP = mean(all_stimLFP,3);  % Average across stim on windows, then subtract
    LFP_bl = (mean(all_stimLFP,3)-mean(all_baseLFP,3));  % Average across stim on windows and average across baselines, then subtract
    LFP_demean = (mean(all_LFPmm,3));  % Demeaned on a trial by trial basis, then averaged across stim on windows
    LFP_blTr = (mean(all_LFPblTr,3));  % Subtract avg baseline on a trial by trial basis, then averaged across stim on windows
    % To convert these to muV...  ./1000

figure;
movegui('center')
sgtitle('LFP individual trial (last trial), example demeaned LFP')
 subplot 221
    imagesc(stimLFP); colorbar
    subtitle('stimLFP, [nChannels x nSamples (time)]')
 subplot 222
    imagesc(mean(stimLFP,2)); colorbar
    subtitle('mean(stimLFP,2)')
 subplot 223
    imagesc(LFP_MinusMean); colorbar
    subtitle('LFP Minus Stim Mean')
 subplot 224
    imagesc(LFP_BlTrial); colorbar
    subtitle('LFP Minus Baseline')

figure;
movegui('center')
sgtitle('LFP averaged across trials')
 subplot 221
    imagesc(LFP); colorbar
    subtitle('mean(all stimLFP,3)')
 subplot 222
    imagesc(LFP_bl); colorbar
    subtitle('avg stim LFP across trials, then subtract avg bl')
 subplot 223
    imagesc(LFP_demean); colorbar
    subtitle('subtract stimLFP mean, trial by trial')
 subplot 224
    imagesc(LFP_blTr); colorbar
    subtitle('subtract bl period, tral by trial')    
 



% Compute CSD

fLFP = LFP_blTr; %all_LFPblTr;


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


% Csigma = 0.00033; % estimated conductivity for mouse cortex (double check this later)
% 
% 
% % Unit conversion
% CSDraw = 1000 * CSDraw .* Csigma; 

% % Padding
% CSDraw = padarray(CSDraw, [1 0], NaN);
% 
% 
% % Interpolation
% ip = 10; % interpolation factor for upsampling data, default is a upsampling factor of 10. Leave empty, or set as 0 or 1 if not upsampling is desired
% if(any(ip > 1))
%     if(length(ip) == 2)
%         NewTime = linspace(1, Ntime, ip(2)*Ntime);
%     else
%         NewTime = 1:Ntime;
%     end
%     NewChan = linspace(1, Nchan, ip(1)*Nchan);
%     [Tip, Cip] = meshgrid(NewTime, NewChan);
%     CSD = interp2(CSDraw, Tip, Cip, 'spline');
% else
%     CSD = CSDraw;
% end


figure;
 subplot 221
    imagesc(CSDraw); colorbar







%%  This works.... kind of

iexp=23;
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

% Parameters
    Fs          = 2500; % Sampling frequency in Hz
    dz          = 20;       % 20 um between channels, vertically
    chnls       = 2:2:200;  % Only take even channels because NPX probe has two columns of staggered channels
    cutofflow   = 150; % Cutoff frequency in Hz
    [b, a] = butter(4, cutofflow/(Fs/2), 'low'); % Design filter (Butterworth, 4th order)
    LFPdataFilt1 = filtfilt(b, a, LFPdata);
    LFPdata = (LFPdataFilt1-LFPdataFilt1(300,:));
    clear LFPdataFilt1

% Load Stimulus On times
    stimStruct = createStimStruct_Wiesel(exptStruct);
    timestamps = stimStruct.timestamps{5};

% Set windows for baseline and stim on
    onWin       = .5;   % Stim On LFP window: 500 ms
    baseWin     = .5;   % Baseline window: 500 ms

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
        LFP_MinusMean = [stimLFP - mean(stimLFP,2)];
        all_LFPmm(:,:,is) = LFP_MinusMean;

        LFP_BlTrial = [stimLFP - mean(baseLFP,2)];
        all_LFPblTr(:,:,is) = LFP_BlTrial;

        if baseIdx(end)+1 ~= stimIdx(1)
            error('wrong baseline/stim windows')
        else; end
    end

    LFP = mean(all_stimLFP,3);  % Average across stim on windows, then subtract
    LFP_bl = (mean(all_stimLFP,3)-mean(all_baseLFP,3));  % Average across stim on windows and average across baselines, then subtract
    LFP_demean = (mean(all_LFPmm,3));  % Demeaned on a trial by trial basis, then averaged across stim on windows
    LFP_blTr = (mean(all_LFPblTr,3));  % Subtract avg baseline on a trial by trial basis, then averaged across stim on windows
    % To convert these to muV...  ./1000

figure;
movegui('center')
sgtitle('LFP individual trial (last trial), example demeaned LFP')
 subplot 221
    imagesc(stimLFP); colorbar
    subtitle('stimLFP, [nChannels x nSamples (time)]')
 subplot 222
    imagesc(mean(stimLFP,2)); colorbar
    subtitle('mean(stimLFP,2)')
 subplot 223
    imagesc(LFP_MinusMean); colorbar
    subtitle('LFP Minus Stim Mean')
 subplot 224
    imagesc(LFP_BlTrial); colorbar
    subtitle('LFP Minus Baseline')

figure;
movegui('center')
sgtitle('LFP averaged across trials')
 subplot 221
    imagesc(LFP); colorbar
    subtitle('mean(all stimLFP,3)')
 subplot 222
    imagesc(LFP_bl); colorbar
    subtitle('avg stim LFP across trials, then subtract avg bl')
 subplot 223
    imagesc(LFP_demean); colorbar
    subtitle('subtract stimLFP mean, trial by trial')
 subplot 224
    imagesc(LFP_blTr); colorbar
    subtitle('subtract bl period, tral by trial')    
 



%


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

% 
% Csigma = 0.00033; % estimated conductivity for mouse cortex (double check this later)
% 
% 
% % Unit conversion
% CSDraw = 1000 * CSDraw .* Csigma; 
% 
% % Padding
% CSDraw = padarray(CSDraw, [1 0], NaN);
% 
% 
% 
% % Interpolation
% ip = 10; % interpolation factor for upsampling data, default is a upsampling factor of 10. Leave empty, or set as 0 or 1 if not upsampling is desired
% if(any(ip > 1))
%     if(length(ip) == 2)
%         NewTime = linspace(1, Ntime, ip(2)*Ntime);
%     else
%         NewTime = 1:Ntime;
%     end
%     NewChan = linspace(1, Nchan, ip(1)*Nchan);
%     [Tip, Cip] = meshgrid(NewTime, NewChan);
%     CSD = interp2(CSDraw, Tip, Cip, 'spline');
% else
%     CSD = CSDraw;
% end


figure;

    imagesc(-CSDraw); colorbar







    