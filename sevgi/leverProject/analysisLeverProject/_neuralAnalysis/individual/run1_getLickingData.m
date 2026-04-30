% Run this file to get matlabGen_lickOnsetTimes.txt matlabGen_lickOffsetTimes.txt and lick frequency data under the directory
% Then, you ******NEED******* to run Tprime command to align these time points to imec sync channel
% 
% TPrime -syncperiod=1.0 -tostream=S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\20231018_g0_tcat.imec0.ap.xd_384_6_500.txt -fromstream=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\20231018_g0_tcat.nidq.xd_8_0_500.txt -events=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\20231018_g0_tcat.nidq.xd_8_5_0.txt,S:\Neuropixels\test_data\20231018_g0\TPrime_OUT\holdLever.txt -events=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\20231018_g0_tcat.nidq.xid_8_5_0.txt,S:\Neuropixels\test_data\20231018_g0\TPrime_OUT\releaseLever.txt -events=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\20231018_g0_tcat.nidq.xd_8_6_0.txt,S:\Neuropixels\test_data\20231018_g0\TPrime_OUT\visStimOn.txt -events=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\20231018_g0_tcat.nidq.xid_8_6_0.txt,S:\Neuropixels\test_data\20231018_g0\TPrime_OUT\visStimOff.txt
% -events=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\matlabGen_lickOnsetTimes.txt,S:\Neuropixels\test_data\20231018_g0\TPrime_OUT\lickOnsetTimes.txt -events=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\matlabGen_lickOffsetTimes.txt,S:\Neuropixels\test_data\20231018_g0\TPrime_OUT\lickOffsetTimes.txt
% 

clc
clearvars
close all

pathToFolder = 'S:/Neuropixels/test_data/20231115_g0/';

downsampleRate = 100;
btw2Licks = 0.025; % sec -- min duration between two licks
minITI = 3; % some ITI value needed - ITI would never be less than 3 

% For an analog channel: gain correct saved channel ch (1-based for MATLAB).
ch = [5 7 8]; % 5(AI4)-Lickometer 7(AI6)-Piezosensor 8(AI7)-Photoresistor for Visual Stim on/off(AI7)

% Which digital word to read. 
% For imec, there is only 1 digital word, dw = 0.
% For NI, digital lines 0-15 are in word 1, lines 16-31 are in word 2, etc.
% (1-based for MATLAB)
dw = 1;

% Read these lines in dw (0-based).
% Which lines within the digital word, zero-based
% For 3B2 imec data: the sync pulse is stored in line 6.
%dLineList = [0, 5, 6]; % 0 synch, 5 trial start/stop (hold/release lever)

addpath('../lib/');

niBinFiles = dir([pathToFolder '*nidq.bin']);
niBinFile = niBinFiles(1);

% Parse the corresponding metafile
meta = readMeta(niBinFile.name, pathToFolder);

% Get first one second of data
t = str2double(meta.fileTimeSecs);
nSamp = floor(t * samplingRate(meta));
dataArray = readBin(0, nSamp, ch(1), meta, niBinFile.name, pathToFolder);
dataArrayDS = downsample(dataArray', downsampleRate)';
% clear dataArrayBulk

% **************** ANALOG READ OUT **********************
dataArrayAnalog = gainCorrectNI(dataArray, [1], meta);

% *************** PLOT **************************
fs = str2num(meta.niSampRate);
x = 0:1/fs:t-1/fs;
figure
hold on;
plot(dataArrayAnalog(1,:));
% **************** ANALOG READ OUT **********************

% What is left smaller than mean value should give us baseline level
putativeBaseline = dataArrayAnalog(dataArrayAnalog<mean(dataArrayAnalog));
baselineMean = mean(putativeBaseline);
baselineStd = std(putativeBaseline);
loThreshold = baselineMean+3*baselineStd;
hiThreshold = 0.6; %baselineMean+15*baselineStd;
yline(loThreshold);
yline(hiThreshold);

indOnsets = find(dataArrayAnalog>loThreshold);
%plot(x(indOnsets),1.5*ones(1,length(indOnsets)),'*');

indRobustLicks = find(dataArrayAnalog>hiThreshold);
%plot(x(indRobustLicks),1.4*ones(1,length(indRobustLicks)),'*');

impulseFnc = zeros(1,length(x));
impulseFnc(indRobustLicks) = 1;
plot(impulseFnc*1.4);

indsZeros = find(impulseFnc==0); % Find moments between licks
diffIndsZeros = diff(indsZeros);
durationBetweenLicks_FSPoints = floor(btw2Licks*fs); % fs points
minITI_FSPoints = floor(minITI*fs);
count = 0;
startOfOnes = [];
startOfZeros = [];
indT=1;
lickRates = [];
lastLRcalculated = 0;
while indT<length(impulseFnc)
    if impulseFnc(indT)==0
        count = count+1;
        if count==durationBetweenLicks_FSPoints % found a space between two licks
            nextOne = find(impulseFnc(indT:end)>0,1);
            nextZero = find(impulseFnc(indT+nextOne:end)==0,1);
            if ~isempty(nextOne)
                indT = indT + nextOne - 1; 
                indZero = indT + nextZero - 1;
                if ~isempty(startOfOnes) && ~isempty(startOfZeros) && (indT-startOfOnes(end))>minITI_FSPoints % trial ended, calculate lick rate
                    if lastLRcalculated+1~=length(startOfOnes)
                        trialDuration_FSPoints = startOfZeros(end)-startOfOnes(lastLRcalculated+1);
                        lickCount = length(startOfOnes)-lastLRcalculated;
                        lickRate = lickCount/(trialDuration_FSPoints/fs);
                        lickRates = [lickRates lickRate];
                        lastLRcalculated = length(startOfOnes);
                    end
                end
                startOfOnes = [startOfOnes indT];
                startOfZeros = [startOfZeros indZero];
                count = 0;
                continue;
            end
        end
    end
    indT = indT+1;
end

%indsBetweenLicks = strfind(impulseFnc,btwLickZeros);
%plot(indsBetweenLicks, 1.5, '*');
lickOnsetTimes = x(startOfOnes);
lickOffsetTimes = x(startOfZeros);

% dataOnsets = dataArrayAnalog(indOnsets);
% dataRobustLicks = dataArrayAnalog(indRobustLicks);
% diffRobustLicks = diff(dataRobustLicks);

pathToCatGTFolder = [pathToFolder 'CatGT_OUT/'];
niBinFiles = dir([pathToCatGTFolder 'catgt_*']);
niBinFile = niBinFiles(1);
pathToCatGTFolder = [pathToFolder 'CatGT_OUT/' niBinFile.name '/'];

fileIDOnset = fopen([pathToCatGTFolder 'matlabGen_lickOnsetTimes.txt'],'w');
fprintf(fileIDOnset,'%10.13f\r\n',lickOnsetTimes);

fileIDOffset = fopen([pathToCatGTFolder 'matlabGen_lickOffsetTimes.txt'],'w');
fprintf(fileIDOffset,'%10.13f\r\n',lickOffsetTimes);

fileIDOffset = fopen([pathToCatGTFolder 'matlabGen_lickFreq.txt'],'w');
fprintf(fileIDOffset,'%10.13f\r\n',lickRates);
% DON'T FORGET TO RUN TPRIME! YOU ******NEED******* to run Tprime command to align these time points to imec sync channel



