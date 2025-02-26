function [time, MainWaveforms, MultiChanWFStruct, Scale, Waveforms, shiftTime, TSset1] = MultiChanWFbreak(struct, dataLength, n, timeLim, TimeGridA, TimeGridB, unit, map, color, PlotSamps, PlotMean, ScalePass)
%map is structure with each row being a channel and fields chan, xcoord,
%ycoord, typically MEH_chanMap
%PlotSamps is 1 to plot waveforms, 0 to just pass them out.
%can pass NAN for TG to turn TG off.

index = find([struct.unitID] == unit); %% n changes to index in struct pointing to specified unit
CenterChan = struct(index).channel;

%figure
%set(gcf,'Position',[500 100 500 800]);

index = find([struct.unitID] == unit); %% n changes to index in struct pointing to specified unit
timestamps = [struct(index).timestamps];  %% Make vector, TimeStamps, that has timestamps from unit.

timestamps = timestamps(timestamps < timeLim(2)); %time limit timestamps
timestamps = timestamps(timestamps > timeLim(1));

% remake time grid within time limits
if ~isnan(TimeGridA)
TimeGridWindow = TimeGridB(1)-TimeGridA(1);         
TimeGridB = TimeGridB((TimeGridB < timeLim(2)) & (TimeGridB > timeLim(1)));
TimeGridA = TimeGridB - TimeGridWindow;
if (TimeGridB(1)-TimeGridWindow)< timeLim(1)
    TimeGridA(1) = timeLim(1);
end
timestamps = TimeGridUnit(TimeGridA, TimeGridB, timestamps); %take only timestamps between TimeGridA points and TimeGridB points
end

% dataLength = how much data to extract (waveform length)
% n = how many waveforms to extract
% timestamps = when unit is firing
% ch = channel in SPIKEGLX NOTATION- zero-based

% Ask user for binary file
if length(dir('*ap.bin')) ~= 1
    [binName,path] = uigetfile('*ap.bin', 'Select Binary File');
end
if length(dir('*ap.bin')) == 1
  binfolder = dir('*ap.bin');
  binName = binfolder(1).name;
  path = binfolder(1).folder;
end
    
% Parse the corresponding metafile
meta = ReadMeta(binName, path);
step = floor(length(timestamps)/n);

timestamps = (timestamps - .002); % catch the begining of the waveform
nSamp = floor(dataLength * SampRate(meta));
nSamp = int64(nSamp);
timestep = 1/SampRate(meta);
time = 0:timestep:dataLength-1/SampRate(meta);

% Get first one second of data = 1
if step > 0
    fprintf('\nStep size is %i, %i waveforms plotted and averaged\n', step, n);
for i = 1:n
  randn(i,1) = randi([(((i-1)*step)+1),(i*step)]); %pick which spike from each 
end
TSindex = randn;
end

if step == 0
    TSindex = [1:length(timestamps)].';
    if ~isempty(timestamps)
    %warning('\n Not enough spikes to compute average. All available spikes are used')
    fprintf('\nNot enough spikes to perform planned calculation. %i spikes are averaged and plotted\n', length(timestamps))
    f = warndlg('Not enough spikes available perform planned mean WF calculation. Available spikes are averaged and plotted');
    else
    fprintf('\nNo spikes in window. Avg WF = 0.\n')
    f = warndlg('No spikes in WF mean calculation window. AvgWF = 0');
    end
end

TSset1 = timestamps(TSindex); %set timestamps we will sample on every channel (unaligned)

figure

[time, MainWaveforms] = GetWaveformsAtTimes(dataLength, CenterChan, TSset1);SampleWaveformsTimeLimTGzerogo(TimeGridA, TimeGridB, struct, dataLength, n, timeLim, unit, CenterChan); %first we want to get size of unit so we can scale



%[AlignMode, AlignI, Alignt] = AlignPrep(MainWaveforms)

if isnan(ScalePass) %create scaling factor if it wasn't passed in
ScaleMax = max(max(MainWaveforms));
ScaleMin = min(min(MainWaveforms));
Scale = ScaleMax-ScaleMin;
%close gcf
else
    Scale = ScalePass;
    %MainWaveforms = NaN;
end

figure
[AlignedWaveforms, shiftTime, ~, ~] = AlignWaveformsXcorr(MainWaveforms, 20); %20 bins (2/3 msec) maximum shift, as long as there is a sensible shift to make
%close gcf




NewTimes = TSset1 + shiftTime; % + shiftTime; %align timestamps

testerShiftTime = NaN;
figure
figure

    MapIndexCenter = find ([map.chan] == CenterChan);
    counter = 0;
    figure
for j = (CenterChan - 6):(CenterChan + 6)%for each chan we want to examine
if ~isempty(NewTimes)
    if j < 0
        continue
    end
    if j == 191 % create bug to match the one in phy where it skips the spot for channel 191 but doesn't skip it's number
        continue
    end
    if j > 382
        continue
    end
    jIndex = find ([map.chan] == j); %get index of map for the channel of interest
    counter = counter + 1;
    X = map(jIndex).xcoord - map(MapIndexCenter).xcoord;
    Y = map(jIndex).ycoord - map(MapIndexCenter).ycoord;
    %scatter(X,Y);

chan = j;
[time, Waveforms] = GetWaveformsAtTimes(.006, j, NewTimes);


%AvgWvF = avgeWaveforms(Waveforms);
sz = size(Waveforms);
numrows = sz(1);
numcolumns = sz(1,2);
AvgWvF = (sum(Waveforms, 2))/(numcolumns);
MultiChanWFStruct(counter).X = X;
MultiChanWFStruct(counter).Y = Y;
MultiChanWFStruct(counter).AvgWf = AvgWvF;
MultiChanWFStruct(counter).Scale = Scale;
MultiChanWFStruct(counter).Chan = (map(jIndex).chan);
MultiChanWFStruct(counter).TimeLim = timeLim;
MultiChanWFStruct(counter).TimeGridboo = TimeGridA(1)/TimeGridA(1);
MultiChanWFStruct(counter).N_wf = length(TSindex);

%figure
hold on
if PlotSamps == 1
  
   
    for s = 1:size(Waveforms,2)
plot(time+X/5000, Waveforms(:,s)+Y*Scale/30, 'Color', [.5 .5 .5]);
    end
end
if PlotMean == 1
    hold on
plot(time+X/5000, AvgWvF+Y*Scale/30, color);


if isnan(ScalePass) %assuming Scale would have been passed in if this was the first time plotting this data and we would want to print the channel info
textx = time(end/3) + X/5000;
texty = max(AvgWvF + Y*Scale/30)+20*(std(std(Waveforms)));
text(textx, texty, num2str(map(jIndex).chan)); 
end


end

else
jIndex = find ([map.chan] == j); %get index of map for the channel of interest
X = map(jIndex).xcoord - map(MapIndexCenter).xcoord;
Y = map(jIndex).ycoord - map(MapIndexCenter).ycoord;
MultiChanWFStruct(j).X = X;
MultiChanWFStruct(j).Y = Y;
MultiChanWFStruct(j).AvgWf = 0;
MultiChanWFStruct(j).Scale = 0;
MultiChanWFStruct(counter).Chan = (map(jIndex).chan);
MultiChanWFStruct(counter).TimeLim = timeLim;
MultiChanWFStruct(counter).TimeGridboo = TimeGridA(1)/TimeGridA(1);
MultiChanWFStruct(counter).N_wf = length(TSindex);
end
end
%plot([-.008, -.005], [-.0008, -.0008], 'k', 'LineWidth', 1);
%plot([-.008, -.008], [-.0008, -.0007], 'k', 'LineWidth', 1);
if isnan(ScalePass)  %assuming Scale would have been passed in if this was the first time plotting this data and we would want to print the channel info
f = gca;
Xzero = f.XLim(1);
Yzero = f.YLim(1);
plot([Xzero, Xzero+.003], [Yzero, Yzero], 'k', 'LineWidth', 1); %3 ms line
plot([Xzero, Xzero], [Yzero, Yzero + .0005], 'k', 'LineWidth', 1); %1/2 mV line
text(Xzero + .0005, Yzero - .0001, '3 msec');
h = text(Xzero - .0007, Yzero + .00015, '0.5 mV');
set(h,'Rotation',90);
end
axis off
FormatFigure
title([num2str(unit) ' on ' num2str(CenterChan)]);
end
%saveas(gca, [num2str(unit) ' WFarray']);
%print([num2str(unit) ' WFarray'], '-depsc');


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
    f = fseek(fid, samp0 * 2 * nChan, 'bof');
    if f ~=0
        fprintf('error at MultiChanWF line 268')
    end
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




%SampleWaveformsTimeLimNewzerogo(struct, dataLength, n, timeLim, unit, chan, xshift, yshift)