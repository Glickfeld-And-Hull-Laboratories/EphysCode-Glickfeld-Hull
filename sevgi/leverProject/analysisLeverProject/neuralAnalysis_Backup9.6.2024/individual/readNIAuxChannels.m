
clc
clearvars
close all

downsampleRate = 100;

% For an analog channel: gain correct saved channel ch (1-based for MATLAB).
ch = [5 7 8 9]; % 5(AI4)-Lickometer 7(AI6)-Piezosensor 8(AI7)-Photoresistor for Visual Stim on/off(AI7), 9(8 in SpikeGLX)-Digital channels
photoResistorChannel=3; % read Photoresistor
digitalChannel=4; % read digital

digChannel = 3; % 1-synch 2-reward 3-lever hold/release 4-Vis stim on/off

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

%%%%%%%%%%%%% Read Photoresistor  %%%%%%%%%%%%%
%dataArray = readBin(0, nSamp, ch(photoResistorChannel), meta, niBinFile.name, pathToFolder);
%dataArrayDS = downsample(dataArray', downsampleRate)';
fs = str2num(meta.niSampRate);
x = 0:1/fs:t-1/fs;
%xDowned = downsample(x', downsampleRate)';
%dataArrayDS = dataArrayDS - mean(dataArrayDS);
%indsHiPhotoResistor = find(dataArray>1000);
figure
%plot(xDowned, dataArrayDS);

%dataArrayAnalogPlt = (dataArray - min(dataArray))/(max(dataArray)-min(dataArray));
%dataArrayAnalogPlt = dataArrayAnalogPlt(1:500*fs); % Get first 300 sec
%plot(dataArrayAnalogPlt);
hold on
digChannel = 3;
dataArrayDG = readBin(0, nSamp, ch(digitalChannel), meta, niBinFile.name, pathToFolder);
dataArrayDigital = extractDigital(dataArrayDG, meta, dw, dLineList);
dataArrayDigitalPlt = dataArrayDigital(digChannel,:);
dataArrayDigitalPlt = (dataArrayDigitalPlt-min(dataArrayDigitalPlt))/(max(dataArrayDigitalPlt)-min(dataArrayDigitalPlt));
%dataArrayDigitalPlt = dataArrayDigitalPlt(1:500*fs); % Get first 300 sec
plot(x, dataArrayDigital);
a=0;
% loop = 1;
% diffArr = [];
% dataArrayAngTemp = dataArrayAnalogPlt;
% dataArrayDigTemp = dataArrayDigitalPlt;
% while loop
%     indsAnlgHi = find(dataArrayAngTemp>.5,1);
%     indsDigHi = find(dataArrayDigTemp>.5,1);
%     difference = indsAnlgHi - indsDigHi;
%     diffArr = [diffArr; difference/(fs/1000)];
%     
%     if (indsAnlgHi+75000)<length(dataArrayAngTemp)
%         indsAnlgLo = find(dataArrayAngTemp(indsAnlgHi+75000:end)<.5,1);
%         if (indsAnlgHi+indsAnlgLo+75000)<length(dataArrayAngTemp)
%             dataArrayAngTemp = dataArrayAngTemp(indsAnlgHi+indsAnlgLo+75000:end);
%         else
%             break
%         end
%     else
%         break
%     end
% 
%     if (indsDigHi+75000)<length(dataArrayDigTemp)
%         indsDigLo = find(dataArrayDigTemp(indsDigHi+75000:end)<.5,1); % shift .3 s(75000 samples) further to get rid of glitches
%         if (indsDigHi+indsDigLo+75000)<length(dataArrayDigTemp)
%             dataArrayDigTemp = dataArrayDigTemp(indsDigHi+indsDigLo+75000:end);
%         else
%             break
%         end
%     else
%         break
%     end
% 
% %     figure
% %     plot(dataArrayAngTemp);
% %     hold on
% %     plot(dataArrayDigTemp);
% end
% %%%%%%%%%%%%% Read Photoresistor  %%%%%%%%%%%%%
% mean(abs(diffArr))

dataArrayDG = readBin(0, nSamp, ch(digitalChannel), meta, niBinFile.name, pathToFolder);
%dataArrayAnalog = downsample(dataArray', downsampleRate)';

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
dataArrayDigital = extractDigital(dataArrayDG, meta, dw, dLineList);
% for i = 1:numel(dLineList)
%     figure
%     plot(dataArrayDigital(i,:));    
%     ylim([0 1.2]);
% end

fs = str2num(meta.niSampRate);
len = length(dataArrayDigital(digChannel,:));
x = 1/fs:1/fs:len/fs;

photoResistor = dataArrayDigital(digChannel,:);
photoResistor = photoResistor-mean(photoResistor);
plot(x,photoResistor,'r')
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
    

