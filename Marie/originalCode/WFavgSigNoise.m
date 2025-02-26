% =============================================================
% Simple helper functions and MATLAB structures demonstrating
% how to read and manipulate SpikeGLX meta and binary files.
%
% The most important part of the demo is ReadMeta().
% Please read the comments for that function. Use of
% the 'meta' structure will make your data handling
% much easier!
%af

% timeLim = [0, inf] where 0 is begining to use and inf is the max. S, AvgWvF, SigNoise, MAD,
function [SigNoise2, AvgWvF, StDev] = WFavgSigNoiseNew(TimeGridA, TimeGridB, struct, AllBinary, dataLength, timeLim, unit)

plotON = 1;
plotSAMPLE = 1;
WholeRecord = 1; %if you want the noise to be calculated from the whole sample via MAD

index = find([struct.unitID] == unit); %% n changes to index in struct pointing to specified unit
timestamps = [struct(index).timestamps];  %% Make vector, TimeStamps, that has timestamps from unit.
channel = struct(index).channel;

channel = channel;
chan = channel;

title1 = ['Unit ' num2str(unit)];
title2 = ['chan ' num2str(chan)];
if isnan(timeLim)
    timeLim = [0 inf];
end
title3 = [num2str(timeLim(1))];
title4 = [ num2str(timeLim(2))];

if ~isnan(TimeGridA)
    title5 = ' TG';
else
    title5 = '';
end
title_ = [title1 ' on ' title2 ' between ' title3 ' and ' title4 title5];



if (~isnan(timeLim))
    timestamps = timestamps(timestamps < timeLim(2)); %time limit timestamps
    timestamps = timestamps(timestamps > timeLim(1));
end

% remake time grid within time limits
if (~isnan(TimeGridA))
    TimeGridWindow = TimeGridB(1)-TimeGridA(1);         
    TimeGridB = TimeGridB((TimeGridB < timeLim(2)) & (TimeGridB > timeLim(1)));
    TimeGridA = TimeGridB - TimeGridWindow;
    if (TimeGridB(1)-TimeGridWindow)< timeLim(1)
        TimeGridA(1) = timeLim(1);
    end

    timestamps = TimeGridUnit(TimeGridA, TimeGridB, timestamps); %take only timestamps between TimeGridA points and TimeGridB points
end

if length(timestamps)> 50000 %if there are so many spikes that we don't want to average them all
    n = 25000
end
if length(timestamps) < 50000 %if we do want to average all the spikes
    n = length(timestamps)
end

% dataLength = how much data to extract (waveform length)
% n = how many waveforms to extract
% timestamps = when unit is firing
% ch = channel in SPIKEGLX NOTATION- zero-based

% Ask user for binary file
if length(dir('*.bin')) ~= 1
    [binName,path] = uigetfile('*.bin', 'Select Binary File');
end
if length(dir('*.bin')) == 1
  binfolder = dir('*.bin');
  binName = binfolder(1).name;
  path = binfolder(1).folder;
end
    

% Parse the corresponding metafile
meta = ReadMeta(binName, path);

chan = chan +1;

if WholeRecord == 1
%    nSamp = SampRate(meta)*timestamps(end);
%    nSamp = int64(nSamp);
%    samp0 = timestamps(1)*SampRate(meta);
%    samp0 = int64(samp0);
%    ForNoise = ReadBin(samp0, nSamp, meta, binName, path);
%    readnoise = 'readnoise'
% % % change y values to volts
% For an analog channel: gain correct saved channel ch (1-based for MATLAB).
ch = chan;
dw = 1;% For a digital channel: read this digital word dw in the saved file (1-based). For imec data there is never more than one saved digital word.
    if strcmp(meta.typeThis, 'imec')
        AllBinaryGainCorrect = GainCorrectIM(AllBinary, [ch], meta);
    else
        AllBinaryGainCorrect = GainCorrectNI(AllBinary, [ch], meta);
    end
    
    ForNoise = AllBinaryGainCorrect(chan,:);
   NoiseMedian = median(ForNoise)
   imhere = 'imhere';
   MAD = median(abs(ForNoise - NoiseMedian));  
   sizeMAD = size(MAD);
   sizeForNoise = size(ForNoise);
else 
   MAD = NaN;
end



length(timestamps)



% Get first one second of data = 1
%if length(timestamps)> 15000 %if there are so many spikes that we don't want to averaget them all
%    n = 10000;

if length(timestamps)> 50000 %if there are so many spikes that we don't want to average them all
step = floor(length(timestamps)/n)
randhi = 0; %set first randhi which will be taken as randlow to be 0;
random = zeros(n);
randTS = zeros(n);
for i = 1:n
    randlow = randhi+1;
    randhi = randlow + step -1;
  randn = randi([randlow,randhi]);
  random(i) = randn;
  randTS(i,1) = timestamps(randn);
end
reporter = 'finishedRandom'

timestamps = randTS;
end

timestamps = (timestamps - .001); % catch the begining of the waveform
nSamp = floor(dataLength * SampRate(meta));
nSamp = int64(nSamp);
Waveforms = zeros(nSamp, n);
timestep = 1/SampRate(meta);
time = 0:timestep:dataLength-1/SampRate(meta);
SampleTS = zeros(n,1);
% Get first one second of data = 1
%if length(timestamps)> 15000 %if there are so many spikes that we don't want to averaget them all
%    n = 10000;

for i = 1:n
samp0 = (timestamps(i) - timeLim(1))*SampRate(meta);
samp0 = int64(samp0);
SampleTS(i) = timestamps(i);


dataArray = AllBinaryGainCorrect(:,samp0:(nSamp + samp0-1));
% % % change y values to volts
% For an analog channel: gain correct saved channel ch (1-based for MATLAB).
ch = chan;

Waveforms(:,i) = dataArray(chan,:).';
end



%get average waveform
AvgWvF = avgeWaveforms(Waveforms);
if isnan(MAD)

end

sdevMulitplier = 3;

WFrange = max(AvgWvF)- min(AvgWvF)
if isnan(MAD)
S = std(Waveforms-AvgWvF);
StDev = mean(S);
SigNoise1 = WFrange/(sdevMulitplier*StDev)
else
    StDev = (MAD/.6745);    %Estimate of 1 STDEV of noise distribution
    SigNoise2 = WFrange/(sdevMulitplier*StDev)
end
%figure
hold on
if plotON == 1
    figure
   hold on 

plot(time, AvgWvF, 'r');
plot(time, (AvgWvF + StDev), ':');
plot(time, (AvgWvF - StDev), ':');
hold off
    
title(title_);
%xticks([0 30 60 90 120 150])
%xticklabels({'0' '.001','.002','.003', '.004', '.005'})
box off;
%ax.TickDir = 'out'
ax = gca; 
ax.TickDir = 'out';
ax.FontName = 'Calibri'; 'FixedWidth';
ax.FontSize = 18;

end

if plotSAMPLE ==1
   m = 100; % number of samples to plot

   IndexToPlot = randi(n,m); 
hold on
for p = 1:m
    plot(time, Waveforms(:,IndexToPlot(p)), 'k');
end
plot(time, AvgWvF, 'r');
plot(time, (AvgWvF + 2*StDev), 'm');
plot(time, (AvgWvF - 2*StDev), 'm');

end

end

% =========================
% General Utility Functions
% =========================


% =========================================================
% Parse ini file returning a structure whose field names
% are the metadata left-hand-side tags, and whose right-
% hand-side values are MATLAB strings. We remove any
% leading '~' characters from tags because MATLAB uses
% '~' as an operator.
%
% If you're unfamiliar with structures, the benefit
% is that after calling this function you can refer
% to metafile items by name. For example:
%
%   meta.fileCreateTime  // file create date and time
%   meta.nSavedChans     // channels per timepoint
%
% All of the values are MATLAB strings, but you can
% obtain a numeric value using str2double(meta.nSavedChans).
% More complicated parsing of values is demonstrated in the
% utility functions below.
%
function [meta] = ReadMeta(binName, path)

    % Create the matching metafile name
    [dumPath,name,dumExt] = fileparts(binName);
    metaName = strcat(name, '.meta');

    % Parse ini file into cell entries C{1}{i} = C{2}{i}
    fid = fopen(fullfile(path, metaName), 'r');
% -------------------------------------------------------------
%    Need 'BufSize' adjustment for MATLAB earlier than 2014
%    C = textscan(fid, '%[^=] = %[^\r\n]', 'BufSize', 32768);
    C = textscan(fid, '%[^=] = %[^\r\n]');
% -------------------------------------------------------------
    fclose(fid);

    % New empty struct
    meta = struct();

    % Convert each cell entry into a struct entry
    for i = 1:length(C{1})
        tag = C{1}{i};
        if tag(1) == '~'
            % remake tag excluding first character
            tag = sprintf('%s', tag(2:end));
        end
        meta = setfield(meta, tag, C{2}{i});
    end
end % ReadMeta


% =========================================================
% Read nSamp timepoints from the binary file, starting
% at timepoint offset samp0. The returned array has
% dimensions [nChan,nSamp]. Note that nSamp returned
% is the lesser of: {nSamp, timepoints available}.
%
% IMPORTANT: samp0 and nSamp must be integers.
%
function dataArray = ReadBin(samp0, nSamp, meta, binName, path)

    nChan = str2double(meta.nSavedChans);

    nFileSamp = str2double(meta.fileSizeBytes) / (2 * nChan);
    samp0 = max(samp0, 0);
    %samp0
    %nSamp = samp0+nSamp;
    nSamp = min(nSamp, nFileSamp - samp0);
    %nSamp
    %nSamp-samp0 

    sizeA = [nChan, nSamp];

    fid = fopen(fullfile(path, binName), 'rb');
    fseek(fid, samp0 * 2 * nChan, 'bof');
    dataArray = fread(fid, sizeA, 'int16=>double');
    fclose(fid);
end % ReadBin


% =========================================================
% Return an array [lines X timepoints] of uint8 values for
% a specified set of digital lines.
%
% - dwReq is the one-based index into the saved file of the
%    16-bit word that contains the digital lines of interest.
% - dLineList is a zero-based list of one or more lines/bits
%    to scan from word dwReq.
%
function digArray = ExtractDigital(dataArray, meta, dwReq, dLineList)
    % Get channel index of requested digital word dwReq
    if strcmp(meta.typeThis, 'imec')
        [AP, LF, SY] = ChannelCountsIM(meta);
        if SY == 0
            fprintf('No imec sync channel saved\n');
            digArray = [];
            return;
        else
            digCh = AP + LF + dwReq;
        end
    else
        [MN,MA,XA,DW] = ChannelCountsNI(meta);
        if dwReq > DW
            fprintf('Maximum digital word in file = %d\n', DW);
            digArray = [];
            return;
        else
            digCh = MN + MA + XA + dwReq;
        end
    end
    [~,nSamp] = size(dataArray);
    digArray = zeros(numel(dLineList), nSamp, 'uint8');
    for i = 1:numel(dLineList)
        digArray(i,:) = bitget(dataArray(digCh,:), dLineList(i)+1, 'int16');
    end
end % ExtractDigital


% =========================================================
% Return sample rate as double.
%
function srate = SampRate(meta)
    if strcmp(meta.typeThis, 'imec')
        srate = str2double(meta.imSampRate);
    else
        srate = str2double(meta.niSampRate);
    end
end % SampRate


% =========================================================
% Return a multiplicative factor for converting 16-bit
% file data to voltage. This does not take gain into
% account. The full conversion with gain is:
%
%   dataVolts = dataInt * fI2V / gain.
%
% Note that each channel may have its own gain.
%
function fI2V = Int2Volts(meta)
    if strcmp(meta.typeThis, 'imec')
        fI2V = str2double(meta.imAiRangeMax) / 512;
    else
        fI2V = str2double(meta.niAiRangeMax) / 32768;
    end
end % Int2Volts


% =========================================================
% Return array of original channel IDs. As an example,
% suppose we want the imec gain for the ith channel stored
% in the binary data. A gain array can be obtained using
% ChanGainsIM() but we need an original channel index to
% do the look-up. Because you can selectively save channels
% the ith channel in the file isn't necessarily the ith
% acquired channel, so use this function to convert from
% ith stored to original index.
%
% Note: In SpikeGLX channels are 0-based, but MATLAB uses
% 1-based indexing, so we add 1 to the original IDs here.
%
function chans = OriginalChans(meta)
    if strcmp(meta.snsSaveChanSubset, 'all')
        chans = (1:str2double(meta.nSavedChans));
    else
        chans = str2num(meta.snsSaveChanSubset);
        chans = chans + 1;
    end
end % OriginalChans


% =========================================================
% Return counts of each imec channel type that compose
% the timepoints stored in binary file.
%
function [AP,LF,SY] = ChannelCountsIM(meta)
    M = str2num(meta.snsApLfSy);
    AP = M(1);
    LF = M(2);
    SY = M(3);
end % ChannelCountsIM

% =========================================================
% Return counts of each nidq channel type that compose
% the timepoints stored in binary file.
%
function [MN,MA,XA,DW] = ChannelCountsNI(meta)
    M = str2num(meta.snsMnMaXaDw);
    MN = M(1);
    MA = M(2);
    XA = M(3);
    DW = M(4);
end % ChannelCountsNI


% =========================================================
% Return gain for ith channel stored in the nidq file.
%
% ichan is a saved channel index, rather than an original
% (acquired) index.
%
function gain = ChanGainNI(ichan, savedMN, savedMA, meta)
    if ichan <= savedMN
        gain = str2double(meta.niMNGain);
    elseif ichan <= savedMN + savedMA
        gain = str2double(meta.niMAGain);
    else
        gain = 1;
    end
end % ChanGainNI


% =========================================================
% Return gain arrays for imec channels.
%
% Index into these with original (acquired) channel IDs.
%
function [APgain,LFgain] = ChanGainsIM(meta)

    if isfield(meta,'imDatPrb_dock')
        [AP,LF,~] = ChannelCountsIM(meta);
        % NP 2.0; APgain = 80 for all channels
        APgain = zeros(AP,1,'double');
        APgain = APgain + 80;
        % No LF channels, set gain = 0
        LFgain = zeros(LF,1,'double');
    else
        % 3A or 3B data?
        % 3A metadata has field "typeEnabled" which was replaced
        % with "typeImEnabled" and "typeNiEnabled" in 3B.
        % The 3B imro table has an additional field for the
        % high pass filter enabled/disabled
        if isfield(meta,'typeEnabled')
            % 3A data
            C = textscan(meta.imroTbl, '(%*s %*s %*s %d %d', ...
                'EndOfLine', ')', 'HeaderLines', 1 );
        else
            % 3B data
            C = textscan(meta.imroTbl, '(%*s %*s %*s %d %d %*s', ...
                'EndOfLine', ')', 'HeaderLines', 1 );
        end
        APgain = double(cell2mat(C(1)));
        LFgain = double(cell2mat(C(2)));
    end
end % ChanGainsIM


% =========================================================
% Having acquired a block of raw nidq data using ReadBin(),
% convert values to gain-corrected voltages. The conversion
% is only applied to the saved-channel indices in chanList.
% Remember saved-channel indices are in range [1:nSavedChans].
% The dimensions of the dataArray remain unchanged. ChanList
% examples:
%
%   [1:MN]      % all MN chans (MN from ChannelCountsNI)
%   [2,6,20]    % just these three channels
%
function dataArray = GainCorrectNI(dataArray, chanList, meta)

    [MN,MA] = ChannelCountsNI(meta);
    fI2V = Int2Volts(meta);

    for i = 1:length(chanList)
        j = chanList(i);    % index into timepoint
        conv = fI2V / ChanGainNI(j, MN, MA, meta);
        dataArray(j,:) = dataArray(j,:) * conv;
    end
end


% =========================================================
% Having acquired a block of raw imec data using ReadBin(),
% convert values to gain-corrected voltages. The conversion
% is only applied to the saved-channel indices in chanList.
% Remember saved-channel indices are in range [1:nSavedChans].
% The dimensions of the dataArray remain unchanged. ChanList
% examples:
%
%   [1:AP]      % all AP chans (AP from ChannelCountsIM)
%   [2,6,20]    % just these three channels
%
function dataArray = GainCorrectIM(dataArray, chanList, meta)

    % Look up gain with acquired channel ID
    chans = OriginalChans(meta);
    [APgain,LFgain] = ChanGainsIM(meta);
    nAP = length(APgain);
    nNu = nAP * 2;

    % Common conversion factor
    fI2V = Int2Volts(meta);

    for i = 1:length(chanList)
        j = chanList(i);    % index into timepoint
        k = chans(j);       % acquisition index
        if k <= nAP
            conv = fI2V / APgain(k);
        elseif k <= nNu
            conv = fI2V / LFgain(k - nAP);
        else
            continue;
        end
        dataArray(j,:) = dataArray(j,:) * conv;
    end
end


