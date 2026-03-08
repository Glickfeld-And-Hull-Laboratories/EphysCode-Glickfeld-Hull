%% LFP spectrolaminar analysis for V1, Sara Gannon
%
% Relevant literature:
% Mendoza-Halliday et al. 'A ubiquitous spectrolaminar motif of  local field potential power across the  primate cortex.' Nature Neuroscience, 2023. https://doi.org/10.1038/s41593-023-01554-7



for iexp = [25 24 23 22 21 20 19 18] %26 25 24 23 22 21 20 19 18 13 11

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
    cutofflow   = 150; % Cutoff frequency in Hz
    [b, a] = butter(4, cutofflow/(Fs/2), 'low'); % Design filter (Butterworth, 4th order)
    LFPdataFilt1 = filtfilt(b, a, LFPdata);
    LFPdata = (LFPdataFilt1-LFPdataFilt1(300,:));
    clear LFPdataFilt1

% Set probe tip depth, distance between channels, and which channels to use
    depth       = exptStruct.depth;
    dz          = 20;       % 20 um between channels, vertically
    chnls       = 2:2:200;  % Only take even channels because NPX probe has two columns of staggered channels
    fs = 2500;  % Sampling rate (Hz), modify if different
    
% Load Stimulus On times
    stimStruct = createStimStruct_Wiesel(exptStruct);
    firstTs = stimStruct.timestamps{1};
    timestamps = (firstTs+0.5):1:(firstTs+0.5+1199);

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
        fullLFP = [baseLFP stimLFP];
        all_LFP(:,:,is) = fullLFP;

        if baseIdx(end)+1 ~= stimIdx(1)
            error('wrong baseline/stim windows')
        else; end
    end


    gammaPower_norm = [];
    alphabetaPower_norm = [];

    for is = 1:size(all_LFP,3)  % nStim

        LFP = squeeze(all_LFP(:,:,is));
        
        % Compute Power Spectrum using Welch's Method
        nFFT = 2^nextpow2(size(LFP, 2));        % nFFT is the number of points used for the FFT calculation in pwelch. FFT runs faster when nFFT is a power of 2 due to the way MATLAB optimizes its FFT algorithm
        [pxx, f] = pwelch(LFP', hamming(1024), [], nFFT, fs);
        
        powerSpectra  = pxx'; % [nChannels x nFrequencies]
        freqs          = f;% frequency vector
        
        % Normalize at each frequency across channels
        powerSpectra_norm = powerSpectra ./ max(powerSpectra, [], 1);
        % max(...,[],1) → max across channels
        % Each frequency column gets scaled by its strongest channel
        % Now values range 0–1 per frequency
        
        % Then compute band power from the normalized spectrum:
        gammaIdx     = freqs >= 50 & freqs <= 150;
        alphabetaIdx = freqs >= 10 & freqs <= 30;
        
        gammaPower_norm(:,is)     = mean(powerSpectra_norm(:,gammaIdx), 2);
        alphabetaPower_norm(:,is) = mean(powerSpectra_norm(:,alphabetaIdx), 2);
    end    


    n = length(timestamps);
    gammaPower_normAvg = mean(gammaPower_norm,2);
    gammaPower_normStd = std(gammaPower_norm,0,2);
    gammaPower_normSem = std(gammaPower_norm,0,2)./sqrt(n);
    alphabetaPower_normAvg = mean(alphabetaPower_norm,2);
    alphabetaPower_normStd = std(alphabetaPower_norm,0,2);
    alphabetaPower_normSem = std(alphabetaPower_norm,0,2)./sqrt(n);


    % Define depth values
    depths = depth + (0:size(LFP,1)-1) * 20; % Each channel is 20m apart


    figure;
        subplot(3,1,1)
            hold on
            shadedErrorBar(depths, gammaPower_normAvg, gammaPower_normSem, 'lineprops','r');
            shadedErrorBar(depths, alphabetaPower_normAvg, alphabetaPower_normSem, 'lineprops','b');
            ylabel('Relative Power');
            xlabel('Depth (\mum)');
            set(gca,'XDir','reverse');   % flip so superficial at top
            legend('Gamma','Alpha-Beta');
            title('SEM');
        subplot(3,1,2)
            hold on
            shadedErrorBar(depths, gammaPower_normAvg, gammaPower_normStd, 'lineprops','r');
            shadedErrorBar(depths, alphabetaPower_normAvg, alphabetaPower_normStd, 'lineprops','b');
            ylabel('Relative Power');
            xlabel('Depth (\mum)');
            set(gca,'XDir','reverse');   % flip so superficial at top
            legend('Gamma','Alpha-Beta');
            title('STD');
        subplot(3,1,3)
            hold on
            shadedErrorBar(depths, gammaPower_normAvg, gammaPower_normStd./2, 'lineprops','r');
            shadedErrorBar(depths, alphabetaPower_normAvg, alphabetaPower_normStd./2, 'lineprops','b');
            ylabel('Relative Power');
            xlabel('Depth (\mum)');
            set(gca,'XDir','reverse');   % flip so superficial at top
            legend('Gamma','Alpha-Beta');
            title('STD/2');

        sgtitle('Normalized Band Power, Gamma & Alpha-Beta');
        print(fullfile(['/home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home/' loc '/Analysis/Neuropixel/' date '/' mouse '-' date '-findLayer4-RFmapping-Maier.pdf']),'-dpdf','-bestfit')

    
       layerStruct.LFPtime = LFPtime;
       layerStruct.LFPdata = LFPdata;
       layerStruct.gammaPower = gammaPower_norm;
       layerStruct.alphabetaPower = alphabetaPower_norm;

end

