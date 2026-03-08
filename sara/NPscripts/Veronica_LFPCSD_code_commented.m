
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
for(c=1:Nchan)
    parfor(t=1:Ntrial)  % Parallel across trials

        LFPtrace = squeeze(LFPmat(c,:,t));  % Extract single trace (1 x time)

        if(do_despike == 1)  % Despike
            LFPtrace = hampel(LFPtrace, dspk_wdw, dspk_std);
        end

        if(~isempty(Notch))   % Notch filter
            LFPtrace = filtfilt(NotchB, NotchA, LFPtrace);
        end

        if(~isempty(type))  % Bandpass filter
            LFPtrace = filter(Tb, Ta, LFPtrace);
        end

        if(do_demean == 1)  % Demean 
            LFPtrace = LFPtrace - mean(LFPtrace);
        end

        fLFP(c,:,t) = LFPtrace;  % Store
    end
end

% Optional smoothing
if(~isempty(sm2D))
    if(length(sm2D) == 1)  % Create Gaussian kernel if 1D smoothing
        smwin = sm2D;
        Half_BW   = round(4*smwin);
        x         = -Half_BW : Half_BW;
        GaussKrnl = (1/(sqrt(2*pi)*smwin)) * exp(-1*((x.^2) / (2*smwin^2)));
    end
    for(t=1:Ntrial)
        if(length(sm2D) == 2)
            % 2D smoothing across channels and time
            tLFP = squeeze(fLFP(:,:,t));
            fLFP(:,:,t) = imgaussfilt(tLFP, sm2D);
        elseif(length(sm2D) == 1)
            % 1D smoothing across channels only
            parfor(i=1:Ntime)
                tLFP = squeeze(fLFP(:,i,t))';
                fLFP(:,i,t) = conv(tLFP, GaussKrnl, 'same');
            end
        end
    end
end


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

% Channel spacing (mm)
CH_spacing = (0 : Nchan-1) * dE;
CH_step    = median(CH_spacing);

% Preallocate
CSDmat = nan(Nchan-2, Ntime, Ntrial);

% Compute spatial second derivative per trial
for(t=1:Ntrial)

    tLFP = squeeze(fLFP(:,:,t))';  % Transpose to time x channel

    % Optional pre-smoothing
    if(length(pre_sm) == 1)
        for(i=1:Nchan)
            tLFP(:,i) = conv(tLFP(:,i), GaussKrnl, 'same');
        end
    elseif(length(pre_sm) == 2)
        tLFP = imgaussfilt(tLFP, pre_sm);
    end

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

% Unit conversion
CSDraw = 1000 * CSDraw .* Csigma;

% Padding
switch pad
    case 'dup'
        CSDraw = padarray(CSDraw, [1 0],'replicate');
    case 'nan'
        CSDraw = padarray(CSDraw, [1 0], NaN);
    case 'zero'
        CSDraw = padarray(CSDraw, [1 0]);
end

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



