
clc
clearvars
close all

downsampleRate = 100;

% For an analog channel: gain correct saved channel ch (1-based for MATLAB).
ch = [5 7 8 9]; % 5(AI4)-Lickometer 7(AI6)-Piezosensor 8(AI7)-Photoresistor for Visual Stim on/off(AI7), 9(8 in SpikeGLX)-Digital channels
digitalChannel=4; % read digital
whichDigChannel = 3; % 1-synch 2-reward 3-lever hold/release 4-Vis stim on/off

% Which digital word to read. 
% For imec, there is only 1 digital word, dw = 0.
% For NI, digital lines 0-15 are in word 1, lines 16-31 are in word 2, etc.
% (1-based for MATLAB)
dw = 1;

% Read these lines in dw (0-based).
% Which lines within the digital word, zero-based
% For 3B2 imec data: the sync pulse is stored in line 6.
dLineList = [0, 3, 5, 6]; % 0 synch, 3 reward, 5 hold/release lever, 6 Vis stim ON/OFF

addpath('../lib/');
%pathToFolder = 'S:/Neuropixels/test_data/20200921_g0/';
%pathToFolder = 'S:/Neuropixels/test_data/20220901_1_g0/';

dateOfRecording = '20240320';
if ispc % If the OS is Windows
    pathToFolder = ['S:/Neuropixels/test_data/' dateOfRecording '_g0/'];
else
    pathToFolder = ['/mnt/IsilonPerm/Neuropixels/test_data/' dateOfRecording '_g0/'];
end

niBinFiles = dir([pathToFolder '*nidq.bin']);
niBinFile = niBinFiles(1);

% Parse the corresponding metafile
meta = readMeta(niBinFile.name, pathToFolder);

% Get first one second of data
t = str2double(meta.fileTimeSecs);
nSamp = floor(t * samplingRate(meta));
fs = str2num(meta.niSampRate);
x = 0:1/fs:t-1/fs;

dataArrayDG = readBin(0, nSamp, ch(digitalChannel), meta, niBinFile.name, pathToFolder);
dataArrayDigital = extractDigital(dataArrayDG, meta, dw, dLineList);
dataArrayDigitalPlt = dataArrayDigital(whichDigChannel,:);

figure
plot(x, dataArrayDigitalPlt);

    

