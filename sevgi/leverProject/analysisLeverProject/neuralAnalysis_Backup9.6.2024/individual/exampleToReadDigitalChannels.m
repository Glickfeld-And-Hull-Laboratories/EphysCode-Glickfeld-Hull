clc
clearvars
close all

if ispc % If the OS is Windows
    pathToFolder = 'S:/Neuropixels/test_data/20240404_g0/';    
else
    pathToFolder = '/mnt/IsilonPerm/Neuropixels/test_data/20240404_g0/';
end

% Which digital word to read. 
% For imec, there is only 1 digital word, dw = 0.
% For NI, digital lines 0-15 are in word 1, lines 16-31 are in word 2, etc.
% (1-based for MATLAB)
dw = 1;

% Read these lines in dw (0-based).
% Which lines within the digital word, zero-based
% For 3B2 imec data: the sync pulse is stored in line 6.
dLineList = [0, 3, 5, 6]; % 0 synch, 3 reward timing, 5 trial start/stop (hold/release lever), 6 vis stim on/off

addpath('../lib/');

niBinFiles = dir([pathToFolder '*nidq.bin']);
niBinFile = niBinFiles(1);

% Parse the corresponding metafile
meta = readMeta(niBinFile.name, pathToFolder);

% Get first one second of data
t = str2double(meta.fileTimeSecs);
nSamp = floor(t * samplingRate(meta));

% 9 is only to get Digital channels
dataArray = readBin(0, nSamp, 9, meta, niBinFile.name, pathToFolder);

% **************** DIGITAL READ OUT *********************
dataArrayDigital = extractDigital(dataArray, meta, dw, dLineList);
% for i = 1:numel(dLineList)
%     figure
%     plot(dataArrayDigital(i,:));    
%     ylim([0 1.2]);
% end
fs = str2num(meta.niSampRate);
x = 0:1/fs:t-1/fs;
plot(x(1:50000000),dataArrayDigital(2,1:50000000))

%********** DIGITAL READ OUT *********************