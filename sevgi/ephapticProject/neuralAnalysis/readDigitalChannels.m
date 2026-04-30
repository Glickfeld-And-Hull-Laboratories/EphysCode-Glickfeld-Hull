
clc
clearvars
close all

downsampleRate = 100;

digitalChannel=9; % read digital
whichDigChannel = [6, 7]; % 6 & 7 rotary encoder

% Which digital word to read. 
% For imec, there is only 1 digital word, dw = 0.
% For NI, digital lines 0-15 are in word 1, lines 16-31 are in word 2, etc.
% (1-based for MATLAB)
dw = 1;

% Read these lines in dw (0-based).
% Which lines within the digital word, zero-based
% For 3B2 imec data: the sync pulse is stored in line 6.
dLineList = [0, 3, 5, 6]; % 0 synch, 3 reward, 5 hold/release lever, 6 Vis stim ON/OFF

addpath('lib/');
%pathToFolder = 'S:/Neuropixels/test_data/20200921_g0/';
%pathToFolder = 'S:/Neuropixels/test_data/20220901_1_g0/';

dateOfRecording = '20241211_ephaptic_3601_g1';
pathToFolder = ['/mnt/DdriveL/sevgi/Neuropixels/ephapticRecordings/' dateOfRecording '/'];

metaFiles = dir([pathToFolder '*nidq.meta']);
metaFile = metaFiles(1);

% Parse the corresponding metafile
meta = readMeta(metaFile.name, pathToFolder);

% Get first one second of data
t = str2double(meta.fileTimeSecs);
nSamp = floor(t * samplingRate(meta));
fs = str2num(meta.niSampRate);
x = 0:1/fs:t-1/fs;

niBinFiles = dir([pathToFolder '*nidq.bin']);
niBinFile = niBinFiles(1);

dataArrayDG = readNIBin(0, nSamp, digitalChannel, meta, niBinFile.name, pathToFolder);
dataArrayDigital = extractDigital(dataArrayDG, meta, dw, whichDigChannel);
dataArrayDigital1 = double(dataArrayDigital(1,:));
dataArrayDigital2 = double(dataArrayDigital(2,:));

ind1 = 1; % 500000;
ind2 = length(x); %2500000;
figure
plot(x(ind1:ind2), dataArrayDigital1(ind1:ind2));
hold on
plot(x(ind1:ind2), dataArrayDigital2(ind1:ind2)+.1);
ylim([-.1 1.2])

    

