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

% Navigate into imec folder
    matchingFolder = dir(fullfile(dataPath, [mouse '*']));  % Find folders in dataPath location that start with mouse name
    
    if numel(matchingFolder) == 1 && matchingFolder(1).isdir    % If there is only one folder that starts with mouse name
        cd(fullfile(dataPath, matchingFolder(1).name));         % Change directory
    else
        error('Expected one folder for mouse %s, but found %d', mouse, numel(matchingFolder));  % Throw error if there is > or < than 1 folder that starts with mouse name
    end

% Load LFP data (expected to be NPX data collected at 2500hz and reported in mV)
    lfFile      = dir(fullfile(pwd, '*imec0.lf.bin'));   % Get info on file that ends in imec0.lf.bin
    metaLFP     = ReadMeta(lfFile.name, pwd);       % Grab meta file from working directory
    LFPtime     = 0:1/str2double(metaLFP.imSampRate):str2double(metaLFP.fileTimeSecs);  % Time of each sample
    nSamp       = str2double(metaLFP.imSampRate)*str2double(metaLFP.fileTimeSecs); % Set number of samples to grab (as in, grabs all)
    LFPdata     = ReadBin(0, nSamp, metaLFP, lfFile.name, pwd);    % Load LFP (channels x samples)



% Look at loaded LFP data
    figure()
    n=1;
    for ic = 1:30:330
        subplot(11,1,n)
        plot(LFPtime(1:end-1),LFPdata(ic,:))
        hold on
        subtitle(['chnl ' num2str(ic)])
        xlim([1000 1010])
        ylim([-100 100])
        ylabel('mV')
        if n == 11
            xlabel('40 ms window')
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

% Plot LFP as a function of depth
    xx = tFromStimOn-tFromStimOn(1);    % X-axis will be relative timepoints (starting at 0) instead of experiment times

    z   = depth:dz:depth+(dz*length(chnls));
    v   = 1; % interpolation factor
    figure
    subplot 221
        imagesc(xx, z, interp2(LFP,v))
        set(gca,'YDir','normal');
        ylim([z(3) z(end-2)])
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
    v       = 1; % interpolation factor
    [mLFP, peakLFP] = min(mean(LFP_smooth,2),[],"all");
    subplot 222
        imagesc(xx, z, interp2(LFP_smooth,v))
        hold on
        set(gca,'YDir','normal');
        yline(z(peakLFP));
        ylim([z(3) z(end-2)])
        xlabel('time (s)')
        ylabel('depth')
        title('smooth LFP (\muV)')
        colormap('hot')
        h = colorbar;
        h.Ticks =  h.Limits;
        movegui('center')
        
% Compute second derivative for CSD
    CSD = diff(LFP_smooth, 2, 1) / dz^2;  
    
% Smooth CSD
    sigma       = 5; % Standard deviation for smoothing (adjust if needed)
    CSD_smooth  = imgaussfilt(CSD, sigma, 'FilterSize', 15);  % 2D Gaussian smoothing

% Plot CSD as a function of depth
    z = depth:dz:depth+(dz*length(chnls)-1);
    v = 1; % Interpolation factor
    [mCSD, peakCSD] = max(mean(CSD_smooth,2),[],"all");
    subplot 223
        imagesc(xx, z(2:end-1), interp2(CSD_smooth, v))  % Exclude first and last rows due to second derivative
        hold on
        set(gca,'YDir','normal');
        yline(z(peakCSD));
        ylim([z(3) z(end-2)])
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
LFP = LFPdata(:,1:10000);

% Compute Power Spectrum using Welch's Method
freqs = 1:200; % Extended frequency range for analysis
nFFT = 2^nextpow2(size(LFP, 2));
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
        plot(deltaPower, 1:size(LFP,1), 'c');
        ylabel('Channel'); xlabel('Power');
        title('Delta (1-4 Hz) Power by Channel');
        gca.YDir = 'reverse';   
    subplot(3,2,2);
        plot(thetaPower, 1:size(LFP,1), 'b');
        ylabel('Channel'); xlabel('Power');
        title('Theta (4-10 Hz) Power by Channel');
        gca.YDir = 'reverse'; 
    subplot(3,2,3);
        plot(spindlePower, 1:size(LFP,1), 'm');
        ylabel('Channel'); xlabel('Power');
        title('Spindle (7-14 Hz) Power by Channel');
        gca.YDir = 'reverse';
    subplot(3,2,4);
        plot(lowGammaPower, 1:size(LFP,1), 'k');
        ylabel('Channel'); xlabel('Power');
        title('Low Gamma (30-80 Hz) Power by Channel');
        gca.YDir = 'reverse';
    subplot(3,2,5);
        plot(ripplePower, 1:size(LFP,1), 'r');
        ylabel('Channel'); xlabel('Power');
        title('Ripple (140-200 Hz) Power by Channel');
        gca.YDir = 'reverse';
        movegui('center')


