% =============================================================
% Adapted from DemoReadSGLXData that came from SpikeGLX materials from Bill
% Karsh. Takes inputs of Juice delivery timestamps (extracted using CatGT)
% and and exported nidaq channel that has only analog4 (licking channel)
% and all digiital channels (could proably use only analog4 now, and would
% like to modify to use original nidaq channel). Export is made in SpikeGLX
% file viewer.
%
% FindAllLicks finds licks from  TimeStart-30 to TimeEnd+30. 
%
% FindLicks returns a cell array with one field containing each juice time
% and the other containing a vector with associated licktimes (tmin before
% and tmax after each delivery).
%
% MEH 4/25/22
%


function [AllLicks, LickDetectParams, AllDurs] = FindAllLicks(TimeStart, TimeEnd, level1, level2)
LickDetectParams.level1 = level1;
LickDetectParams.level2 = level2;
%clear
%threshold = 1; % change this to change threshold for detecting licks
% Ask user for binary file
downsampleRate = 1000;


if length(dir('*nidq.bin')) ~= 1
    [binName,path] = uigetfile('*nidq.bin', 'Select Binary File');
end
if length(dir('*nidq.bin')) == 1
  binfolder = dir('*nidq.bin');
  binName = binfolder(1).name;
  path = binfolder(1).folder;
end

fprintf ('File chosen is %s ', path);
fprintf ('%s \n', binName);
tic 

% Parse the corresponding metafile
meta = ReadMeta(binName, path);
SampRateDS = SampRate(meta)/downsampleRate;
fTime = str2double(meta.fileTimeSecs);

if TimeStart <0
    TimeStart = 0;
end
TimeChunks = [TimeStart:30:TimeEnd];
TimeChunks(end) = TimeChunks(end-1)+30;
AllLicks = cell(length(TimeChunks)+1);
        
for m = 2:length(TimeChunks) % change to length(JuiceTimes) after testing
    
    %set samples to extract before and after juice delivery time
        readMin = int64(TimeChunks(m-1)*SampRate(meta));
        readMax = int64(TimeChunks(m)*SampRate(meta));
    
    fprintf('\n ChunkStartTime = %d \n', round(TimeChunks(m)));
    fprintf('Chunk n = %d \n', (m));
    toc;

    dataArray = ReadBin(readMin, readMax, meta, binName, path);

    % For an analog channel: gain correct saved channel ch (****1-based for MATLAB******).
        ch = 2;

    dataArray = GainCorrectNI(dataArray, [ch], meta);
  
    dataArray = dataArray(2,:); %If the exported data has different number or configuration of channels, this will need to be adjusted

    dataArray = downsample(dataArray, downsampleRate);

     if dataArray(1) > level1  %if mouse is in the middle of licking at the start of the period, cut that portion out until tongue returns to baseline
            belowlevel1 = dataArray < level1;
             newstart = find(belowlevel1,1);
             dataArray = dataArray(newstart:end); 
     end
    thresholdData = dataArray > level1;
    baselineData = dataArray <= level1;
       
    thresholdDataL2 = dataArray > level2;
            %JuiceLicks{m,5} = thresholdData; % for troubleshooting
    indexLevelOne = find(thresholdData);
    indexLevelTwo = find(thresholdDataL2);
    indexBaseline = find(baselineData);
    pointer = 1;
    count = 1;
    %plot(dataArray);
    hold on
    %plot(thresholdData);
    licks = [];
    durs = [];
    while ~isempty(indexLevelTwo) %check this is in the right units
             pointer = indexLevelOne(1);
             %scatter(pointer, 1);
             indexBaseline = indexBaseline(indexBaseline > pointer);
             if ~isempty(indexBaseline) && (indexLevelTwo(1) < indexBaseline(1))
                 licks(1,count) = pointer;
                 durs(1,count) = indexBaseline(1);
                 count = count + 1;
                 pointer = indexBaseline(1);
                 indexLevelOne = indexLevelOne(indexLevelOne > pointer);
                 indexLevelTwo = indexLevelTwo(indexLevelTwo > pointer);
             elseif ~isempty(indexBaseline) %if tongue position returns to baseline without crossing level 2, then move your pointer to when tongue returns to baseline
                 pointer = indexBaseline(1);
                 indexLevelOne = indexLevelOne(indexLevelOne > pointer);
                 indexLevelTwo = indexLevelTwo(indexLevelTwo > pointer);
             else
                 break
             end
    end
                 
   % clear LickTimes;
        if ~isempty(licks)
             %LickTimes = licks/SampRateDS + TimeChunks(m-1);
             JuiceLicks{m,2} = licks/SampRateDS + TimeChunks(m-1);
             JuiceLicks{m,3} = (durs - licks)/SampRateDS;
         else
             %LickTimes = [NaN];
               fprintf('no licks for trial %d \n', (m-1));
               JuiceLicks{m,2} = NaN;
               JuiceLicks{m,3} = NaN;
         end

JuiceLicks{m,1} = TimeChunks(m-1);


end
[AllLicks, AllDurs] = MakeAllLicks(JuiceLicks);
AllLicks = rmmissing(AllLicks);
AllDurs = rmmissing(AllDurs);
%licktimes = LickTimes;
%assignin('base', 'LickTimes', LickTimes);
end % DemoReadSGLXData

% ====================
% 

% =========================
% General Utility Functions
% =========================











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
% Return file time as double.
%
function fTime = FileTime(meta)
    if strcmp(meta.typeThis, 'imec')
        fTime = str2double(meta.fileTimeSecs);
    else
        fTime = str2double(meta.fileTimeSecs);
    end
end % fTime






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


