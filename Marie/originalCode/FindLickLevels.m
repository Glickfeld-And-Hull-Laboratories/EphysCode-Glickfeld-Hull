function FindLickLevels(JuiceTimes, tmin, tmax, n, testThresh)
%clear
%threshold = 1; % change this to change threshold for detecting licks
% Ask user for binary file

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
colors = distinguishable_colors(n); % a file from matlab sharing that generates different colors


% Parse the corresponding metafile
meta = ReadMeta(binName, path);

fTime = str2double(meta.fileTimeSecs);

Prelim = cell(length(JuiceTimes),5);
%figure
%hold on
for m = 1:n  % replace 'n' with 'length(JuiceTimes' to go back to function FindLicksStateMach % change to length(JuiceTimes) after testing
    figure
    fprintf('\n JuiceTime = %d \n', round(JuiceTimes(m)));
    fprintf('JuiceIndex = %d \n', m);
    toc;
    
    readMin = int64((JuiceTimes(m)- tmin )*SampRate(meta));
    if readMin < 0
        readMin = 0;
    end
                        %JuiceLicks{m,3}= readMin; % for troubleshooting

    readMax = int64((JuiceTimes(m) + tmax )*SampRate(meta));
    if readMax > fTime*SampRate(meta)
         readMax = fTime*SampRate(meta);
    end
                        %JuiceLicks{m,4}=readMax; % for troubleshooting

    dataArray = ReadBin(readMin, readMax, meta, binName, path);

    % For an analog channel: gain correct saved channel ch (1-based for MATLAB).
        ch = 2;

    dataArray = GainCorrectNI(dataArray, [ch], meta);
    
    dataArray = dataArray(2,:); %If the exported data has different number or configuration of channels, this will need to be adjusted. Also change ch = right above this.
    

    Prelim{m,3} = dataArray;
    % [smArray, ~] = smoothdata(JuiceLicks{m,3},'gaussian', 70000); %get dataArray from MEHreadGLX and smooth it
    hold on
    plot(dataArray, 'Color', colors(m,:));
    xline(tmin*SampRate(meta));
    tmin*SampRate(meta);
    SampRate(meta);
    
    %%%%
    thresholdData = dataArray > testThresh;
    hold on
    thresholdData = thresholdData * testThresh;
    ylim([min(dataArray), max(dataArray)]);
    plot(thresholdData);

  
 



end
hold off
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


