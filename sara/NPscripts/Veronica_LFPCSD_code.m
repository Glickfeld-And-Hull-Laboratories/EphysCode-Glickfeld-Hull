
%function [TS, dur, tbin, tvec, Nchan, chan] = TDT_GetADC(strm, chan, SR)

% TDT_GetADC - read in and resample analog channel
%
% DESCRIPTION
% Get the analog time series data from a TDT stream object and resample it
% if needed to a desired temporal resolution
%
% SYNTAX
% [TS, dur, tbin, tvec] = TDT_GetADC(strm, chan, SR)
%
%   Input:
%         <strm>    TDT stream object (i.e. struct in tdt.streams) that is
%                   obtained when reading in TDT data with TDTbin2mat
%
%         <chan>    channel numbers to output (if not specified all data is used
%        
%         <SR>      sample rate (time bins per millisecond)
%
% wolf zinke, Aug 2017

%
% ===== get LFP data =====
%

% check input arguments
strm.fs = double(strm.fs);

if(~exist('SR','var') || isempty(SR))
    SR = strm.fs;    
end

if(~exist('chan','var') || isempty(chan))
    chan = 1:size(strm.data, 1);    
end
Nchan = length(chan);

% get time information
dur  = size(strm.data, 2) / strm.fs;
tbin = 1/strm.fs;
TV   = 0: tbin : dur-tbin;  

% extract channels
tsdata = double(strm.data(chan,:));
clear strm;

%resample time series
if(tbin == 1/SR)
    TS   = tsdata;
    tvec = TV;
else
    [~, tvec] = resample(TV, TV, SR, 'pchip'); % get data size
    TS = nan(Nchan, length(tvec));  % pre-allocate output data
   
    for(i=1:Nchan)
        TS(i,:) = resample(tsdata(i,:), TV, SR, 'pchip');
    end
   
    tbin = SR;
end 

%end


%
% ===== calculate CSD =====
%

[OBJ.TS, OBJ.dur, OBJ.tbin, OBJ.tvec, OBJ.Nchan, OBJ.chan] = TDT_GetADC(TDT_LFP, chan, SR);

if(~isempty(tzero))
    if(~isvector(tzero))
    % tzero defines start and end of a trial    
        if(min(size(tzero)) ~= 2)
            error('tzero has to be a vector or a two column matrix!');
        end
        if(size(tzero, 1) == 2)
            tzero = transp(tzero);
        end
        OBJ.Ntrial = size(tzero, 1);
    else
    % only time stamps of one event given    
        OBJ.Ntrial = length(tzero);
        tzero = [tzero(:), tzero(:)]; 
    end
    OBJ.Ntrial= OBJ.Ntrial-1; % Removes last trial due to possibility of nan values after task end
    tpos = nan(OBJ.Ntrial,3);
    tzero = tzero / 1000; %converts ms to sec

    % get position index for start and end of each trial
    % only use trials that are complete
    for(t=1:OBJ.Ntrial)
        Ts = find(OBJ.tvec >= tzero(t,1) + tmwin(1), 1, 'first');
        Te = find(OBJ.tvec <= tzero(t,2) + tmwin(2), 1, 'last');
        if(~isempty(Ts) && ~isempty(Te))
            tpos(t,1) = Ts;
            tpos(t,2) = Te;
        else
            OBJ.Ntrial = OBJ.Ntrial - 1;
            tpos(end,:) = [];
        end
    end
   
    tpos(:,3) = diff(tpos(:,1:2),1,2)+1; % get maximal trial size

    Tmat = nan(OBJ.Ntrial, max(tpos(:,3))); % pre-allocate

    OBJ.TrialTime = tmwin(1) + (0:max(tpos(:,3))-1) * OBJ.tbin;
   
    OBJ.ChanName = cell(OBJ.Nchan,1);
    OBJ.ChanAvrg = nan(OBJ.Nchan, max(tpos(:,3)));

    % loop over channels
    for(c=1:OBJ.Nchan)
        cnm = sprintf('CH_%.2d', OBJ.chan(c));
        OBJ.ChanName{c} = cnm;
        OBJ.(cnm)       = Tmat;

        % extract data chunks for each trial
        for(t=1:OBJ.Ntrial)
            if(~any(isnan(tpos(t,:))))
                OBJ.(cnm)(t,1:tpos(t,3)) = OBJ.TS(c,tpos(t,1):tpos(t,2));
            end
        end
        OBJ.ChanAvrg(c,:) = nanmean(OBJ.(cnm));
    end
end

LFP = OBJ;
%have to reassign everything just produced by trial2mat code to LFP.

LFPmat = nan(LFP.Nchan, length(LFP.TrialTime), LFP.Ntrial);

% loop over channels
for(c=1:LFP.Nchan)
    lcnm = sprintf('CH_%.2d', LFP.chan(c));
    LFPmat(c,:,:) = LFP.(lcnm)';
end

% LFPmatfilt  = ND_PreProcLFP(LFPmat, SR, 1, [60 180], 'cheby', [3 6], 1);
% [CSDipfilt, CSDfilt] = wz_GetCSD(LFPmatfilt,[],'dup', [50, 10], [1, 0.75], 2, 1);
% ^ turned the above functions into scripts below



%% LFP preprocessing

% function fLFP = ND_PreProcLFP(LFP, SR, do_demean, Notch, type, sm2D, do_despike)

% ND_PreProcLFP - preprocess LFP signals
%
% DESCRIPTION
%      Apply pre-processing of raw LFP data,
%      i.e. filter and smooth the data.
%
% SYNTAX
%     fLFP = ND_PreProcLFP(LFP, SR, do_demean, Notch, type, sm2D, do_despike)
%
% INPUT
%     <LFP>          input LFP data. Could be single channel data (1D),
%                    a channel matrix 2D with where each row represent a channel,
%                    or a 3D matrix: channel x time x trial
%
%     <SR>           Sampling rate (default: 1000)
%
%     <do_demean>    demean each LFP channel
%
%     <Notch>        create a Notch filter to remove the frequencies specified here
%
%     <type>         Filter type: 'butter' or 'cheby'. If empty, no filter is applied
%
%     <sm2D>         apply gaussian smoothing.
%                    Specify a single number to define a kernel applied
%                    only across channels, specify to numbers to apply an
%                    asymmetric filtering across channels and time
%
%     <do_despike>   De-spike LFP signal with a Hample filter
%
% ToDo:
%       - !!! Ensure that smoothing windows are specified in ms and mm (or channel)
%       - pass filter frequencies and orders as argument
%
% wolf zinke, Dec 2017


% check input arguments

if(~exist('SR','var') || isempty(SR))
    SR = 1000; % LFP sampling frequency
end

if(~exist('do_demean','var') || isempty(do_demean))
    do_demean = 0; % apply de-meaning to LFP
end

if(~exist('Notch','var'))
    Notch = 60; % create Notch filter for this frequency
end

if(~exist('type','var'))
    type = [];
end

if(~exist('sm2D','var'))
    sm2D = []; % apply de-meaning to LFP
end

if(~exist('do_despike','var') || isempty(do_despike))
    do_despike = 0; % apply de-meaning to LFP
end

dspk_std = 5;
dspk_wdw = 4;

Ta = [];
Tb = [];

% prepare filter
% notch
if(~isempty(Notch))
    [NotchB, NotchA] = ND_NotchFilter(60, SR);
end

if(~isempty(type))
    switch type
        case 'butter'  % butterworth
            % [NL, DL] = butter(4, 2*100/SR, 'low');
            % [NH, DH] = butter(2, 2*8/SR,   'high');
            % Ta = conv(DL, DH);
            % Tb = conv(NL, NH);
           
            [Tb, Ta] = butter(4, 2 * [8, 100] ./ SR,   'bandpass');

        case 'cheby'  % Chebyshev Type II
            % [NL, DL] = cheby2(4, 20, 2*100/SR, 'low');
            % [NH, DH] = cheby2(2, 20, 2*8/SR,   'high');
            % Ta = conv(DL, DH);
            % Tb = conv(NL, NH);
           
            [Tb, Ta] = cheby2(4, 20, 2 * [8, 100] ./ SR,   'bandpass');
           
        otherwise
            error('Filter %s unknown or NIY!', type);
    end
end

% temporal filtering
Nchan  = size(LFP, 1);
Ntime  = size(LFP, 2);
Ntrial = size(LFP, 3);  

fLFP = nan(Nchan, Ntime, Ntrial); % pre-allocate

for(c=1:Nchan)
    parfor(t=1:Ntrial)        
        LFPtrace = squeeze(LFP(c,:,t));
       
        if(do_despike == 1) % remove spikes from the signal
            LFPtrace = hampel(LFPtrace, dspk_wdw, dspk_std);
        end
       
        % apply notch filter to remove line noise
        if(~isempty(Notch))
            LFPtrace = filtfilt(NotchB, NotchA, LFPtrace);
        end
       
        % filter
        if(~isempty(type))
            % LFPtrace = filter(NH, DH, LFPtrace);
            % LFPtrace = filter(NL, DL, LFPtrace);
            % LFPtrace = filtfilt(Tb, Ta, LFPtrace);
            LFPtrace = filter(Tb, Ta, LFPtrace);
        end
       
        % subtract mean and scale
        if(do_demean == 1)
            LFPtrace = LFPtrace-mean(LFPtrace);
        end
       
        fLFP(c,:,t) = LFPtrace;
    end
end

% apply smoothing
if(~isempty(sm2D))
    % create an asymmetric 2D kernel
    if(length(sm2D) == 1)
        smwin = sm2D;

        % temporal smoothing of LFP if desired
        Half_BW   = round(4*smwin);
        x         = -Half_BW : Half_BW;
        GaussKrnl = (1/(sqrt(2*pi)*smwin)) * exp(-1*((x.^2) / (2*smwin^2)));
    end
   
    for(t=1:Ntrial)
        if(length(sm2D) == 2)
        % 2D
            tLFP        = squeeze(fLFP(:,:,t));            
            fLFP(:,:,t)  = imgaussfilt(tLFP, sm2D);
           
        elseif(length(sm2D) == 1)
        % 1D across channels
            parfor(i=1:Ntime)
                tLFP        = squeeze(fLFP(:,i,t))';
                fLFP(:,i,t) = conv(tLFP, GaussKrnl, 'same');
            end
        end
    end
end
%end




%% Calculate CSD 


% function [CSD, CSDraw] = wz_GetCSD(LFPmat, dE, pad, ip, pre_sm, post_sm, do_plot)

% wz_GetCSD - calculate current source density for a linear electrode array
%
% DESCRIPTION
% Calculate CSD, based on code provided by the group of Alex Maier (by the
% courtesy of K. Dougherty) and which is based on CSDplotter by Klas Pettersen:
%
%     Pettersen, K.H., Devor, A., Ulbert, I., Dale, A.M., & Einevoll, G.T. (2006).
%     Current-source density estimation based on inversion of electrostatic forward solution:
%     effects of finite extent of neuronal activity and conductivity discontinuities.
%     Journal of Neuroscience Methods, 154(1), 116-133.
%
% SYNTAX
%       [CSD, CSDraw] = wz_GetCSD(LFPmat, dE, pad, ip, pre_sm, post_sm, do_plot)
%
%   Input:
%         <LFPmat>   input 3D matrix: channel x time x trial
%
%         <dE>       spacing of electrode probes in mm. Assumes a constant spacing for now.
%
%         <pad>      method for CSD padding:
%                       'none' - CSD has 2 rows less than LFP input (default)
%                       'dup'  - CSD will be padded with duplicating the first and last row
%                       'nan'  - CSD will be padded with flanking rows containing NaNs
%                       'zero  - CSD will be padded with flanking rows containing zeros
%
%         <pre_sm>   apply smoothing of LFP prior with this window size to CSD calculation,
%                    default is empty, do not smooth. Use a two-element vector to apply
%                    an asymmetric 2D gaussian smoothing across channels and time. If only one
%                    number is specified a temporal smoothing is applied.    
%
%         <post_sm>  apply smoothing across channels (columns) of the CSD after interpolation,
%                    default is empty, do not smooth. Use a two-element vector to apply
%                    an asymmetric 2D gaussian smoothing across channels and time. If only one
%                    number is specified the smoothing is applied across channels.                    
%
%         <ip>       upsample the data to a higher resolution using spline interpolation.
%                    If a single value is specified it will use this as factor to increase sampling in
%                    the y direction (channel probes) in y direction (depth) by this factor,
%                    if two values are specified it applies the first as upsampling factor for
%                    y/columns (channel probes) and the other for rows (time).
%
%        <do_plot>   plot the data
%
%
% wolf zinke, Sep 2017

Csigma = 0.00040; % [S/m] (estimated conductivity for macaque cortex based on Logothetis et al. 2007) times 1000 (to get it to  [nanoA/microm^3])
% Csigma   = 0.00035;

colscheme = 'dfireice';

% check input arguments
if(~exist('dE','var') || isempty(dE))
    dE = 0.1;    % default 100 micrometer spacing
end

if(~exist('pad','var') || isempty(pad))
    pad = 'none';    % default 100 micrometer spacing
end

if(~exist('pre_sm','var'))
    pre_sm = []; % smoothing of LFP prior to CSD calculation, default is empty, do not smooth.
end

if(~exist('post_sm','var'))
    post_sm = []; % smoothing CSD across channels, default is empty, do not smooth.
end

if(~exist('ip','var'))
    ip = 10; % interpolation factor for upsampling data, default is a upsampling factor of 10. Leave empty, or set as 0 or 1 if not upsampling is desired
end

if(~exist('do_plot','var') || isempty(do_plot))
    do_plot = 0; % plot the data
end

% % get information
% assume a matrix format of channel x time x trial
Nchan  = size(LFPmat, 1);
Ntime  = size(LFPmat, 2);
Ntrial = size(LFPmat, 3);

if(length(pre_sm) == 1)
    % smwin = pre_sm/Ntime;  % for loess filter, uses proportion of data points
    smwin = pre_sm;
   
    % temporal smoothing of LFP if desired
    Half_BW   = round(4*smwin);
    x         = -Half_BW : Half_BW;
    GaussKrnl = (1/(sqrt(2*pi)*smwin)) * exp(-1*((x.^2) / (2*smwin^2)));
end

CH_spacing = (0 : Nchan-1) * dE;
CH_step    = median(CH_spacing);

% calculate CSD
CSDmat = nan(Nchan-2, Ntime, Ntrial);

for(t=1:Ntrial)
    tLFP = squeeze(LFPmat(:,:,t))'; % get LFP potentials for current trial across all channels

    if(length(pre_sm) == 1)
        for(i=1:Nchan)
            tLFP(:,i) = conv(tLFP(:,i), GaussKrnl, 'same');
        end
       
    elseif(length(pre_sm) == 2)
        tLFP = imgaussfilt(tLFP, pre_sm);
    end
   
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

    tCSD = out* tLFP';
    CSDmat(:,:,t) = tCSD;
end  % for(t=1:Ntrial)

% get the trial average
if(Ntrial > 1)
    CSDraw = squeeze(mean(CSDmat,3));
else
    CSDraw = CSDmat;
end

% transform CSD unit
CSDraw = 1000 * CSDraw .* Csigma;  % convert CSD to [nanoA/microm^3]

% pad CSD array
switch pad
    case 'dup' % Pad by repeating top and bottom row.
        CSDraw = padarray(CSDraw, [1 0],'replicate');

    case 'nan' % pad by adding a row with NaNs to top and bottom
        CSDraw = padarray(CSDraw, [1 0], NaN);

    case 'zero' % pad by adding a row with zeros to top and bottom
        CSDraw = padarray(CSDraw, [1 0]);
end

% interpolate CSD across channels
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

% smooth across channels
if(~isempty(post_sm))
    if(length(post_sm) == 1)
        % smwin = post_sm / (dE*Nchan);  % for loess filter, uses proportion of data points
        smwin = (post_sm/dE) * Nchan;
       
        Half_BW   = round(4*smwin);
        x         = -Half_BW : Half_BW;
        GaussKrnl = (1/(sqrt(2*pi)*smwin)) * exp(-1*((x.^2) / (2*smwin^2)));
       
        for(i=1:Ntime)
            % CSD(i,:) = smooth(CSD(i,:), smwin, 'loess');
            CSD(:, i) = conv(CSD(:,i), GaussKrnl, 'same');
        end
       
    elseif(length(post_sm) == 2)
        for(i=1:Ntime)
            CSD(:, i) = imgaussfilt(CSD(:,i), post_sm);
        end
    end
end

% plot LFP and CSD
if(do_plot)

    figure('Position', [300, 50, 1200, 600]);
    [ha] = tight_subplot(1, 3, 0.05, 0.1, 0.05);

    % =========================================================================
    % LFP
    subplot(ha(1));

    if(Ntrial > 1)
        LFP_ChanAvrg = squeeze(mean(LFPmat,3));
    else
        LFP_ChanAvrg = LFPmat;
    end

    wz_joyplot(LFP_ChanAvrg, 1:Ntime);
    hold on;

    title('LFP');

    % =========================================================================
    % CSD TS
    subplot(ha(2));

    wz_joyplot(CSDraw, 1:Ntime);
    hold on;

    title('CSD');

    % =========================================================================
    % CSD
    subplot(ha(3));
    hold on;

    % pcolor(LFP.TrialTime, 2:(LFP.Nchan-1), flipud(CSDsm));
    % shading interp;
   
    imagesc(1:size(CSD,2), 1:size(CSD,1), flipud(CSD));

    minmax = max(abs(prctile(CSD(:),[0.001,99.999]))) * [-1 1];
    caxis(minmax)

    colormap(twowaycol(256, colscheme));

    set(gca,'TickDir','out');
    axis tight
% end