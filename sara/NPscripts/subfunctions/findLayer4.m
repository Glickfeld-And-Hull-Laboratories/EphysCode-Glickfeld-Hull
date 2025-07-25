%% LFP and CSD analysis for V1, Sara Gannon
%
% Relevant literature:
% Niel, C.M., Stryper M.P. 'Highly selective receptive fields in mouse visual cortex.' Journal of Neuroscience, 2008. https://doi.org/10.1523/JNEUROSCI.0623-08.2008
% Speed et al. 2019 'Cortical State Fluctuations across Layers of V1 during Visual Spatial Perception'


function [layerStruct] = findLayer4(exptStruct,stimStruct,b);

% Get experiment info
    mouse   = exptStruct.mouse;
    date    = exptStruct.date;
    loc     = exptStruct.loc;

% Create path to neuropixel data
    dataPath = fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\', loc, 'Data', 'neuropixel', date);
    cd(dataPath)

% Navigate into imec folder
    matchingFolders = dir(fullfile(dataPath, [mouse '*']));  % Find folders in dataPath location that start with mouse name
    matchingFolder = matchingFolders(~contains({matchingFolder.name}, 'retinotopy'));   % Filter out folders that contain 'retinotopy' in the name

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
    cutoffhigh  = 300;
    [b, a] = butter(4, cutofflow/(Fs/2), 'low'); % Design filter (Butterworth, 4th order)
    LFPdata1=LFPdata;
    LFPdataFilt1 = filtfilt(b, a, LFPdata);
    LFPdata = (LFPdataFilt1-LFPdataFilt1(300,:));

% Look at loaded LFP data
    figure()
    n=1;
    for ic = 170:2:190
        subplot(11,1,n)
        plot(LFPtime(1:end-1),LFPdata(ic,:))
        hold on
        subtitle(['chnl ' num2str(ic)])
        xlim([2000 2010])
        ylim([-100 100])
        ylabel('mV')
        if n == 11
            xlabel('40 s window')
        end
        n=n+1;
    end
    movegui('center')
    % Set figure properties for printing
    fig = gcf; % Get current figure
    set(fig, 'PaperPositionMode', 'auto'); % Auto scale the figure to the page
    set(fig, 'PaperSize', [8.5 11]); % Set the paper size to standard letter size (8.5 x 11 inches)
    set(fig, 'PaperPosition', [0 0 8.5 11]); % Adjust the position and size of the figure on the page
    sgtitle([mouse ' ' date ', LFP example traces'])
    print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\' loc '\Analysis\Neuropixel\' date '\' mouse '-' date '-LFPrawtraces.pdf']),'-dpdf')


    fs = 2500; % Sampling frequency
    low_cutoff = 1;   % Low cutoff frequency in Hz
    high_cutoff = 200; % High cutoff frequency in Hz
    order = 4; % Filter order -- affects the "smoothness" of the cutoff
    
    % Design Butterworth bandpass filter
    [b, a] = butter(order/2, [low_cutoff high_cutoff] / (fs/2), 'bandpass');
    
    % Apply the filter using filtfilt for zero-phase filtering
    filtered_LFP = filtfilt(b, a, LFPdata')'; % Transpose before and after to maintain dimensions

    LFPdata_og = LFPdata;
    LFPdata = filtered_LFP;


% Load Stimulus On times
    timestamps = stimStruct.timestamps{b};

% Set probe tip depth, distance between channels, and which channels to use
    depth       = exptStruct.depth;
    dz          = 20;       % 20 um between channels, vertically
    chnls       = 2:2:200;  % Only take even channels because NPX probe has two columns of staggered channels

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

% Determine depth to be plotted
    maxDepth = -1000; % Set maximum depth to plot (in m)
    numChannels = size(LFP, 1); % Total channels (assumed to be 100)
    depths = linspace(depth, depth + (numChannels - 1) * dz, numChannels);    % Compute actual depth values for each channel
    % Find channels that are shallower than maxDepth
    validIdx = find(depths >= maxDepth);  % Select channels shallower than maxDepth
    % Extract the LFP subset and update depth values
    LFP = LFP(validIdx, :);
    depth_subset = depths(validIdx);  % Update depth axis

% Plot LFP as a function of depth
    xx = tFromStimOn-tFromStimOn(1);    % X-axis will be relative timepoints (starting at 0) instead of experiment times

    z   = depth:dz:depth+(dz*length(chnls));
    v   = 1; % interpolation factor
    figure
    subplot 221
        clear gca; which gca -all
        imagesc(xx, depth_subset, interp2(LFP,v))
        hold on
        set(gca,'YDir','normal');
        ylim([depth_subset(3) depth_subset(end-2)])
        xlabel('time (s)')
        ylabel('depth')
        title('LFP (\muV)')
        colormap('hot')
        h = colorbar;
        h.Ticks =  h.Limits;
        movegui('center')

% Use Guassian filter to smooth LFP before computing CSD
    sigma       = 15; % Standard deviation for smoothing (adjust if needed)
    LFP_smooth  = imgaussfilt(LFP, sigma, 'FilterSize', 25);  % 2D Gaussian smoothing; adjust the kernel size (final value, if needed)

% Plot LFP as a function of depth
    z       = depth:dz:depth+(dz*length(chnls));
    v       = 2; % interpolation factor
    [mLFP, peakLFP] = min(mean(LFP_smooth,2),[],"all");
    subplot 222
        imagesc(xx, depth_subset, interp2(LFP_smooth,v))
        hold on
        set(gca,'YDir','normal');
        yline(z(peakLFP));
        ylim([depth_subset(3) depth_subset(end-2)])
        xlabel('time (s)')
        ylabel('depth')
        title('smooth LFP (\muV)')
        colormap('hot')
        h = colorbar;
        h.Ticks =  h.Limits;
        movegui('center')

 % Compute second derivative for CSD using unsmoothed LFP
    CSD = diff(LFP, 2, 1) / dz^2;  
    
% Smooth CSD
    sigma       = 5; % Standard deviation for smoothing (adjust if needed)
    CSD_smooth  = imgaussfilt(CSD, sigma, 'FilterSize', 15);  % 2D Gaussian smoothing

% Plot CSD as a function of depth
    z = depth:dz:depth+(dz*length(chnls)-1);
    v = 1; % Interpolation factor
    [mCSD, peakCSD] = max(mean(CSD_smooth,2),[],"all");
    subplot 223
        imagesc(xx, depth_subset(2:end-1), interp2(CSD_smooth, v))  % Exclude first and last rows due to second derivative
        hold on
        set(gca,'YDir','normal');
        yline(z(peakCSD));
        ylim([depth_subset(3) depth_subset(end-2)])
        xlabel('Time (s)')
        ylabel('Depth (um)')
        title('CSD (\muA/mm^3)')
        colormap('jet') 
        h = colorbar;
        h.Ticks = h.Limits;
        movegui('center')
        
% Compute second derivative for CSD using smoothed LFP
    CSD = diff(LFP_smooth, 2, 1) / dz^2;  
    
% Smooth CSD
    sigma       = 5; % Standard deviation for smoothing (adjust if needed)
    CSD_smooth  = imgaussfilt(CSD, sigma, 'FilterSize', 15);  % 2D Gaussian smoothing

% Plot CSD as a function of depth
    z = depth:dz:depth+(dz*length(chnls)-1);
    v = 1; % Interpolation factor
    [mCSD, peakCSD] = max(mean(CSD_smooth,2),[],"all");
    subplot 224
        imagesc(xx, depth_subset(2:end-1), interp2(CSD_smooth, v))  % Exclude first and last rows due to second derivative
        hold on
        set(gca,'YDir','normal');
        yline(z(peakCSD));
        ylim([depth_subset(3) depth_subset(end-2)])
        xlabel('Time (s)')
        ylabel('Depth (um)')
        title('CSD (\muA/mm^3)')
        colormap('jet') 
        h = colorbar;
        h.Ticks = h.Limits;
        movegui('center')
        
        sgtitle({[mouse ' ' date], ['probe tip ' num2str(depth) ', avgd ' num2str(is) ' stimuli']})
        print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\' loc '\Analysis\Neuropixel\' date '\' mouse '-' date '-findLayer4.pdf']),'-dpdf','-bestfit')


      

   layerStruct.LFPtime = LFPtime;
   layerStruct.LFPdata = LFPdata;

end


%%


% Load LFP data
% Assume LFP is a matrix (nChannels x nTimepoints), sampled at fs Hz
fs = 2500;  % Sampling rate (Hz), modify if different
LFP = LFPdata(chnls,1:10000);

% Define depth values
depths = depth + (0:size(LFP,1)-1) * 20; % Each channel is 20m apart

% Compute Power Spectrum using Welch's Method
freqs = 1:200; % Extended frequency range for analysis
nFFT = 2^nextpow2(size(LFP, 2));        % nFFT is the number of points used for the FFT calculation in pwelch. FFT runs faster when nFFT is a power of 2 due to the way MATLAB optimizes its FFT algorithm
[pxx, f] = pwelch(LFP', hamming(1024), [], nFFT, fs);

% Extract power in different frequency bands
deltaPower = mean(pxx(f >= 1 & f <= 4, :), 1);
thetaPower = mean(pxx(f >= 4 & f <= 10, :), 1);
spindlePower = mean(pxx(f >= 7 & f <= 14, :), 1);
lowGammaPower = mean(pxx(f >= 30 & f <= 80, :), 1);
ripplePower = mean(pxx(f >= 140 & f <= 200, :), 1);

% Plot Power Across Channels
figure;
    subplot(3,2,1);
        plot(deltaPower, depths, 'c');
        ylabel('Channel'); xlabel('Power');
        title('delta (1-4 Hz) power by channel');
        gca.YDir = 'reverse';   
    subplot(3,2,2);
        plot(thetaPower, depths, 'b');
        ylabel('Channel'); xlabel('Power');
        title('theta (4-10 Hz) power by channel');
        gca.YDir = 'reverse'; 
    subplot(3,2,3);
        plot(spindlePower, depths, 'm');
        ylabel('Channel'); xlabel('Power');
        title('"spindle" (7-14 Hz) power by channel');
        gca.YDir = 'reverse';
    subplot(3,2,4);
        plot(lowGammaPower, depths, 'k');
        ylabel('Channel'); xlabel('Power');
        title('low gamma (30-80 Hz) power by channel');
        gca.YDir = 'reverse';
    subplot(3,2,5);
        plot(ripplePower, depths, 'r');
        ylabel('Channel'); xlabel('Power');
        title('"ripple" (140-200 Hz) power by channel');
        gca.YDir = 'reverse';
        movegui('center')

sgtitle({[mouse ' ' date], ['probe tip ' num2str(depth) ', LFP power spectrum analysis']})
    % Set figure properties for printing
    fig = gcf; % Get current figure
    set(fig, 'PaperPositionMode', 'auto'); % Auto scale the figure to the page
    set(fig, 'PaperSize', [8.5 11]); % Set the paper size to standard letter size (8.5 x 11 inches)
    set(fig, 'PaperPosition', [0 0 8.5 11]); % Adjust the position and size of the figure on the page
print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\' loc '\Analysis\Neuropixel\' date '\' mouse '-' date '-LFPpowerspectrum.pdf']),'-dpdf')




%% Compare different visualizations of power spectrum
fs      = 2500; % Sampling rate
nFFT    = 2^nextpow2(size(LFP,2)); % Optimal FFT length

channel     = 50; % Pick a channel to analyze
lfp_signal  = LFP(channel, :);

% Compute FFT Power Spectrum
X           = fft(lfp_signal, nFFT);
f_fft       = (0:nFFT/2-1)*(fs/nFFT); % Frequency axis
power_fft   = abs(X(1:nFFT/2)).^2; % Compute power

% Compute Welch Power Spectrum
[pxx, f_pwelch] = pwelch(lfp_signal, hamming(1024), [], nFFT, fs);

% Compute pspectrum Power Spectrum
[psd_pspectrum, f_pspectrum] = pspectrum(lfp_signal, fs);

% Plot All Spectra
figure;

% Raw FFT
    subplot(3,1,1);
    plot(f_fft, power_fft, 'r');
    xlabel('Frequency (Hz)'); ylabel('Power');
    title('Raw FFT Power Spectrum');
    xlim([0 200]); % Focus on relevant frequencies
    grid on;
% Welch Power Spectrum
    subplot(3,1,2);
    plot(f_pwelch, pxx, 'b');
    xlabel('Frequency (Hz)'); ylabel('Power');
    title('Welch Power Spectrum');
    xlim([0 200]);
    grid on;
% pspectrum Power Spectrum
    subplot(3,1,3);
    plot(f_pspectrum, psd_pspectrum, 'g');
    xlabel('Frequency (Hz)'); ylabel('Power');
    title('pspectrum Power Spectrum');
    xlim([0 200]);
    grid on;
    legend('pspectrum Estimate');

