% =============================================================
% Adapted from DemoReadSGLXData that came from SpikeGLX materials from Bill
% Karsh. Takes inputs of Juice delivery timestamps (extracted using CatGT)
% and and exported nidaq channel that has only analog4 (licking channel)
% and all digiital channels (could proably use only analog4 now, and would
% like to modify to use original nidaq channel). Export is made in SpikeGLX
% file viewer.
%
% FindLicksStateMachineAllLicks get licks between the current JuiceTime and
% the next JuiceTime. The first row is licks 30 seconds before the first
% JuiceTime (JuiceTime is empty) and the last JuiceTime has licks for the
% 30 seconds following the last Juice Time.
%
% FindLicks returns a cell array with one field containing each juice time
% and the other containing a vector with associated licktimes (tmin before
% and tmax after each delivery).
%
% MEH 4/25/22
%


function [JuiceLicks] = FindLicksNew(JuiceTimes, level1, level2)
%clear
%threshold = 1; % change this to change threshold for detecting licks
% Ask user for binary file
downsampleRate = 1000;
pre = 5; %pre-lick period in seconds

[binName,path] = uigetfile('*.bin', 'Select Binary File');
fprintf ('File chosen is %s ', path);
fprintf ('%s \n', binName);
tic 

% Parse the corresponding metafile
meta = ReadMeta(binName, path);
SampRateDS = SampRate(meta)/downsampleRate;
fTime = str2double(meta.fileTimeSecs);

JuiceLicks = cell(length(JuiceTimes)+1,5);
        
for m = 1:length(JuiceTimes)+1 % change to length(JuiceTimes) after testing
    
    %set samples to extract before and after juice delivery time
    if m == 1 %if it's the very first juicetime
        readMin = int64((JuiceTimes(1)- 30-pre)*SampRate(meta));
        trialStartTime = JuiceTimes(1)- 30-pre;
        if readMin < 0
           readMin = 0;
        end
        readMax = int64((JuiceTimes(1)-pre)*SampRate(meta));
    elseif m > length(JuiceTimes) %if it's the very last juice time
        readMin = int64((JuiceTimes(m-1)-pre)*SampRate(meta));
        trialStartTime = JuiceTimes(m-1) - pre;
        readMax = int64((JuiceTimes(m-1)+30-pre)*SampRate(meta));
        if readMax > fTime*SampRate(meta)
           readMax = fTime*SampRate(meta);
        end
    else %juicetime is neither first nor last
        if JuiceTimes(m)-JuiceTimes(m-1) > 60 %juicetime has too long of juice pause after to use next JuiceTime to end licking data
        readMin = int64((JuiceTimes(m-1)-pre)*SampRate(meta));
        trialStartTime = JuiceTimes(m-1)-pre;
        readMax = int64((JuiceTimes(m-1)+30-pre)*SampRate(meta));
        else %regular juicetime in the middle of the trial
        readMin = int64((JuiceTimes(m-1)- pre)*SampRate(meta));
        trialStartTime = JuiceTimes(m-1) - pre;
        readMax = int64((JuiceTimes(m)-pre)*SampRate(meta));
        end
    end
    
    fprintf('\n TrialStartTime = %d \n', round(trialStartTime));
    fprintf('JuiceIndex = %d \n', (m-1));
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
    plot(dataArray);
    hold on
    plot(thresholdData);
    licks = [];
    while ~isempty(indexLevelTwo) %check this is in the right units
             pointer = indexLevelOne(1);
             scatter(pointer, 1);
             indexBaseline = indexBaseline(indexBaseline > pointer);
             if ~isempty(indexBaseline) && (indexLevelTwo(1) < indexBaseline(1))
                 licks(1,count) = pointer;
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
                 
    clear LickTimes;
        if ~isempty(licks)
             LickTimes = (licks)/SampRateDS+trialStartTime;
             JuiceLicks{m,2} = LickTimes;
         else
             LickTimes = [NaN];
               fprintf('no licks for trial %d \n', (m-1));
               JuiceLicks{m,2} = LickTimes;
         end
if m == 1
JuiceLicks{1,1} = NaN;    
else
JuiceLicks{m,1} = JuiceTimes(m-1);
end

end
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


