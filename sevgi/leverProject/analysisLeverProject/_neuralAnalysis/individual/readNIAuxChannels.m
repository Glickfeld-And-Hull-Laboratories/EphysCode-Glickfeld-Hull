
clc
clearvars
close all

downsampleRate = 100;

% For an analog channel: gain correct saved channel ch (1-based for MATLAB).
ch = [5 7 8]; % 5(AI4)-Lickometer 7(AI6)-Piezosensor 8(AI7)-Photoresistor for Visual Stim on/off(AI7)
chInd = [1 2 3];

% Which digital word to read. 
% For imec, there is only 1 digital word, dw = 0.
% For NI, digital lines 0-15 are in word 1, lines 16-31 are in word 2, etc.
% (1-based for MATLAB)
dw = 1;

% Read these lines in dw (0-based).
% Which lines within the digital word, zero-based
% For 3B2 imec data: the sync pulse is stored in line 6.
dLineList = [0, 3, 5, 6]; % 0 synch, 5 trial start/stop (hold/release lever)

addpath('../lib/');
%pathToFolder = 'S:/Neuropixels/test_data/20200921_g0/';
%pathToFolder = 'S:/Neuropixels/test_data/20220901_1_g0/';
pathToFolder = 'S:/Neuropixels/test_data/20231018_g0/';

niBinFiles = dir([pathToFolder '*nidq.bin']);
niBinFile = niBinFiles(1);

% Parse the corresponding metafile
meta = readMeta(niBinFile.name, pathToFolder);

% Get first one second of data
t = 2368;
nSamp = floor(t * samplingRate(meta));
dataArray = readBin(0, nSamp, ch(1), meta, niBinFile.name, pathToFolder);
dataArrayDS = downsample(dataArray', downsampleRate)';
% clear dataArrayBulk
% **************** ANALOG READ OUT **********************
dataArrayAnalog = gainCorrectNI(dataArray, [1], meta);

fs = str2num(meta.niSampRate);
x = 0:1/fs:t-1/fs;

figure
plot(x, dataArrayAnalog(1,:));
% figure
% plot(dataArray(ch(2),:));
% **************** ANALOG READ OUT **********************

% **************** DIGITAL READ OUT *********************
dataArrayDigital = extractDigital(dataArray, meta, dw, dLineList);
% for i = 1:numel(dLineList)
%     figure
%     plot(dataArrayDigital(i,:));    
%     ylim([0 1.2]);
% end
fs = str2num(meta.niSampRate);
x = 1/fs:1/fs:3884.634918;
plot(x(1:50000000),dataArrayDigital(2,1:50000000))

%********** DIGITAL READ OUT *********************

save('NI_AuxChannels','dataArrayDigital'); %'dataArrayAnalog',
    

