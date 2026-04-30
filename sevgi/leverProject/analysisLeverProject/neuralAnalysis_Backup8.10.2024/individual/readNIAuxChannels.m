
clc
clearvars
close all

downsampleRate = 100;

% For an analog channel: gain correct saved channel ch (1-based for MATLAB).
ch = [5 7 9]; % 5(AI4)-Lickometer 7(AI6)-Piezosensor 8(AI7)-Photoresistor for Visual Stim on/off(AI7), 9(8 in SpikeGLX)-Digital channels
whichChannel=3; % read digital
digChannel = 3; % 1-synch 2-reward 3-lever hold/release 4-Vis stim on/off

% Which digital word to read. 
% For imec, there is only 1 digital word, dw = 0.
% For NI, digital lines 0-15 are in word 1, lines 16-31 are in word 2, etc.
% (1-based for MATLAB)
dw = 1;

% Read these lines in dw (0-based).
% Which lines within the digital word, zero-based
% For 3B2 imec data: the sync pulse is stored in line 6.
dLineList = [0, 3, 5, 6]; % 0 synch, 3 reward, 5 hold/release lever, 5 Vis stim ON/OFF

addpath('../lib/');
%pathToFolder = 'S:/Neuropixels/test_data/20200921_g0/';
%pathToFolder = 'S:/Neuropixels/test_data/20220901_1_g0/';

if ispc % If the OS is Windows
    pathToFolder = 'S:/Neuropixels/test_data/20240404_g0/';    
else
    pathToFolder = '/mnt/IsilonPerm/Neuropixels/test_data/20240404_g0/';
end

niBinFiles = dir([pathToFolder '*nidq.bin']);
niBinFile = niBinFiles(1);

% Parse the corresponding metafile
meta = readMeta(niBinFile.name, pathToFolder);

% Get first one second of data
t = str2double(meta.fileTimeSecs);
nSamp = floor(t * samplingRate(meta));
dataArray = readBin(0, nSamp, ch(whichChannel), meta, niBinFile.name, pathToFolder);
dataArrayDS = downsample(dataArray', downsampleRate)';
% clear dataArrayBulk
% % **************** ANALOG READ OUT **********************
% dataArrayAnalog = gainCorrectNI(dataArray, [1], meta);
% 
% fs = str2num(meta.niSampRate);
% x = 0:1/fs:t-1/fs;
% 
% figure
% plot(x, dataArrayAnalog(1,:));
% % figure
% % plot(dataArray(ch(2),:));
% % **************** ANALOG READ OUT **********************

% **************** DIGITAL READ OUT *********************
dataArrayDigital = extractDigital(dataArray, meta, dw, dLineList);
% for i = 1:numel(dLineList)
%     figure
%     plot(dataArrayDigital(i,:));    
%     ylim([0 1.2]);
% end

fs = str2num(meta.niSampRate);
len = length(dataArrayDigital(digChannel,:));
x = 1/fs:1/fs:len/fs;

plot(x,dataArrayDigital(digChannel,:),'b')
ylim([0 1.2]);
hold on
hi=[16.513581
25.441281
36.371629
46.530350
60.812925
70.328616
81.916234
3679.370718
3688.542654
3701.235255
3780.147536
];
lo=[16.936614
25.968112
38.261359
3682.688466
3691.854042
3701.424612
3780.218375
];
plot(hi, 1.05*ones(1,length(hi)), 'r*');
plot(lo, 1.05*ones(1,length(lo)), 'k*');

%********** DIGITAL READ OUT *********************

save('NI_AuxChannels','dataArrayDigital'); %'dataArrayAnalog',
    

