% =============================================================
% Simple helper functions and MATLAB structures demonstrating
% how to read and manipulate SpikeGLX meta and binary files.
%
% The most important part of the demo is ReadMeta().
% Please read the comments for that function. Use of
% the 'meta' structure will make your data handling
% much easier!
%af

%Use gain-adjusted struct and take in matchign time limits from
%binaryStruct

% timeLim = [0, inf] where 0 is begining to use and inf is the max. S, AvgWvF, SigNoise, MAD,
function [WaveformMatrix, SaneSpikes] = WaveFormAvgSetChan2(TimeGridC, TimeGridD, BinaryStruct, struct, rez, timeLim, unit)
%chan is channel from phy, 0-based
%*****THIS CODE WORKS WITH TIMESTAMPS AS SAMPLES, NOT TIMES**************
%Be sure your timeLim is the same as the timeLim for
%BinaryStruct/AllBinaryFilt

dataLength = 0.006; %optimized for C4 data sharing, also see "% catch the begining of the waveform"
chanSpan = 20; %for a 200 micron radius, C4 data sharing

% Parse the corresponding metafile
% Ask user for binary file
if length(dir('*.bin')) ~= 1
    [binName,path] = uigetfile('*.bin', 'Select Binary File');
end
if length(dir('*.bin')) == 1
  binfolder = dir('*.bin');
  binName = binfolder(1).name;
  path = binfolder(1).folder;
end
meta = ReadMeta(binName, path);

origTimeLim = timeLim;
origTGc = TimeGridC;
origTGd = TimeGridD;

index = find([struct.unitID] == unit); %% n changes to index in struct pointing to specified unit
timestamps = [struct(index).timestamps];  %% Make vector, TimeStamps, that has timestamps from unit.
mainChannel = [struct(index).channel];


if (isinf(timeLim(2)) || isnan(timeLim(1)))
    timeLim = [0 timestamps(length(timestamps))];
else 
timeLim = uint32(timeLim * SampRate(meta));
end

TimeGridC = uint32(TimeGridC * SampRate(meta));
TimeGridD = uint32(TimeGridD * SampRate(meta));
dataLength = uint32(dataLength * SampRate(meta));

SaneSpikes = SaneSpikesC4(struct, origTimeLim, origTGc, origTGd, unit);
SaneBoo = SaneSpikes(:,2);
timestamps = timestamps(find(SaneBoo));

timestamps = timestamps(timestamps < (timeLim(2) - (.0031*SampRate(meta)))); %time limit timestamps with enough room to collect the waveforms within the time limits
timestamps = timestamps(timestamps > (timeLim(1) + (.0031*SampRate(meta))));


if length(timestamps) > 50000 %if there are so many spikes that we don't want to average them all
    n = 25000
end
if length(timestamps) < 50000 %if we do want to average all the spikes
    n = length(timestamps)
end



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

timestamps = randTS;
end

timestamps = (timestamps - (.003*SampRate(meta))); % catch the begining of the waveform
nSamp = dataLength;
nSamp = uint32(nSamp);
Waveforms = zeros(nSamp, n);
SampleTS = zeros(n,1);

%for i = 1:n
%samp0 = (timestamps(i)- timeLim(1));
%SampleTS(i) = timestamps(i);
%end


ch = mainChannel + 1; %switch from channel number to Matlab Index
counter = 1;
for r = (ch - chanSpan):(ch + chanSpan)
if ((r > 0) && ( r < length([rez.ycoord])))
dataArray = [BinaryStruct(r).Binary];

for q = 1:n
samp0 = (timestamps(q)- timeLim(1)); %In case there is any data we are cutting from the begining of the file, both here and when we made the filtered binary
timestamps(q);

Waveforms(:,q) = dataArray(samp0:samp0 + nSamp-1);
end

%get average waveform
AvgWvF = avgeWaveforms(Waveforms);
WaveformMatrix(counter,:) = AvgWvF;
counter  = counter + 1;
end
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


