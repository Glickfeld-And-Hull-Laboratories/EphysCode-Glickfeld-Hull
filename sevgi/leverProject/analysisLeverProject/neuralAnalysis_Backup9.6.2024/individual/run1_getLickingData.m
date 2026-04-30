% Run this file to get matlabGen_lickOnsetTimes.txt matlabGen_lickOffsetTimes.txt and lick frequency data under the directory
% Then, you ******NEED******* to run Tprime command to align these time points to imec sync channel
% 
% TPrime -syncperiod=1.0 -tostream=S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\20231018_g0_tcat.imec0.ap.xd_384_6_500.txt -fromstream=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\20231018_g0_tcat.nidq.xd_8_0_500.txt -events=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\20231018_g0_tcat.nidq.xd_8_5_0.txt,S:\Neuropixels\test_data\20231018_g0\TPrime_OUT\holdLever.txt -events=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\20231018_g0_tcat.nidq.xid_8_5_0.txt,S:\Neuropixels\test_data\20231018_g0\TPrime_OUT\releaseLever.txt -events=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\20231018_g0_tcat.nidq.xd_8_6_0.txt,S:\Neuropixels\test_data\20231018_g0\TPrime_OUT\visStimOn.txt -events=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\20231018_g0_tcat.nidq.xid_8_6_0.txt,S:\Neuropixels\test_data\20231018_g0\TPrime_OUT\visStimOff.txt
% -events=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\matlabGen_lickOnsetTimes.txt,S:\Neuropixels\test_data\20231018_g0\TPrime_OUT\lickOnsetTimes.txt -events=1,S:\Neuropixels\test_data\20231018_g0\CatGT_OUT\catgt_20231018_g0\matlabGen_lickOffsetTimes.txt,S:\Neuropixels\test_data\20231018_g0\TPrime_OUT\lickOffsetTimes.txt
% 

clc
clearvars
close all

SAVE_LOCAL = 1;
dateOfRecording = '20240403'; %'EphysRig8_20240313';

if ispc % If the OS is Windows
    pathToFolder = ['S:/Neuropixels/test_data/' dateOfRecording '_g0/'];
else
    if SAVE_LOCAL
        pathToParentRec = ['/mnt/DriveG/sevgi/Neuropixels/test_data/']; % to avoid network traffic on NB-LAMBDAHULL
    else
        pathToParentRec = ['/mnt/IsilonPerm/Neuropixels/test_data/'];
    end
    pathToFolder = [pathToParentRec dateOfRecording '_g0/'];    
end

downsampleRate = 100;
btw2Licks = 0.025; % sec -- min duration between two licks
minITI = 3; % some ITI value needed - ITI would never be less than 3 

% For an analog channel: gain correct saved channel ch (1-based for MATLAB).
ch = [5 7 8]; % 5(AI4)-Lickometer / 7(AI6)-Piezosensor / 8(AI7)-Photoresistor for Visual Stim on/off(AI7)

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
%plot(x, dataArrayAnalog(1,:));
% **************** ANALOG READ OUT **********************

% What is left smaller than mean value should give us baseline level
putativeBaseline = dataArrayAnalog(dataArrayAnalog<mean(dataArrayAnalog));
baselineMean = mean(putativeBaseline);
baselineStd = std(putativeBaseline);
loThreshold = baselineMean+3*baselineStd;
hiThreshold = 0.6; %baselineMean+15*baselineStd;
yline(loThreshold);
yline(hiThreshold);

indRobustLickEvents = find(dataArrayAnalog>hiThreshold);
plot(x(indRobustLickEvents),1.4*ones(1,length(indRobustLickEvents)),'*');
%%% Surround the licks with an impulse function to show detection of lick bouts
impulseFnc = zeros(1,length(x));
impulseFnc(indRobustLickEvents) = 1;
plot(x, impulseFnc*1.4);

indSubthresholdEvents = find(dataArrayAnalog>loThreshold & dataArrayAnalog<=hiThreshold);
%plot(x(indSubthresholdEvents),1.5*ones(1,length(indSubthresholdEvents)),'*');
%%% Surround the subthreshold moculations with an impulse function to show detection of modulations that could be related with movement of mount
impulseFncSubTh = zeros(1,length(x));
impulseFncSubTh(indSubthresholdEvents) = 1;

durationBetweenLicks_FSPoints = floor(btw2Licks*fs); % fs points
minITI_FSPoints = floor(minITI*fs);

%%%%%%%%%%%%%%%%%%%%%% Find lick ONSET/OFFSET Times %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

lickOnsetTimes = x(startOfOnes);
lickOffsetTimes = x(startOfZeros);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Find subthreshold movement related ONSET/OFFSET Times  %%%%%%%%%%%%%%%%%%%%%%%%%
countSubTh = 0;
startOfOnesSubTh = [];
startOfZerosSubTh = [];
indTSubTh=1;
while indTSubTh<length(impulseFncSubTh)
    if impulseFncSubTh(indTSubTh)==0
        countSubTh = countSubTh+1;
        if countSubTh==durationBetweenLicks_FSPoints % found a space between two licks
            nextOne = find(impulseFncSubTh(indTSubTh:end)>0,1);
            nextZero = find(impulseFncSubTh(indTSubTh+nextOne:end)==0,1);
            if ~isempty(nextOne)
                indTSubTh = indTSubTh + nextOne - 1; 
                indZero = indTSubTh + nextZero - 1;
                
                startOfOnesSubTh = [startOfOnesSubTh indTSubTh];
                startOfZerosSubTh = [startOfZerosSubTh indZero];
                countSubTh = 0;
                continue;
            end
        end
    end
    indTSubTh = indTSubTh+1;
end

subthresholdOnsetTimes = x(startOfOnesSubTh);
subthresholdOffsetTimes = x(startOfZerosSubTh);

pathToCatGTFolder = [pathToFolder 'CatGT_OUT/'];
niBinFiles = dir([pathToCatGTFolder 'catgt_*']);
niBinFile = niBinFiles(1);
pathToCatGTFolder = [pathToFolder 'CatGT_OUT/' niBinFile.name '/'];

[fileIDOnset, msg] = fopen([pathToCatGTFolder 'matlabGen_lickOnsetTimes.txt'],'w');
fprintf(fileIDOnset,'%10.13f\r\n',lickOnsetTimes);

[fileIDOffset, msg] = fopen([pathToCatGTFolder 'matlabGen_lickOffsetTimes.txt'],'w');
fprintf(fileIDOffset,'%10.13f\r\n',lickOffsetTimes);

[fileIDSubOnset, msg] = fopen([pathToCatGTFolder 'matlabGen_subthresholdOnsetTimes.txt'],'w');
fprintf(fileIDSubOnset,'%10.13f\r\n',subthresholdOnsetTimes);

[fileIDSubOffset, msg] = fopen([pathToCatGTFolder 'matlabGen_subthresholdOffsetTimes.txt'],'w');
fprintf(fileIDSubOffset,'%10.13f\r\n',subthresholdOffsetTimes);

[fileIDLickFreq, msg] = fopen([pathToCatGTFolder 'matlabGen_lickFreq.txt'],'w');
fprintf(fileIDLickFreq,'%10.13f\r\n',lickRates);

status = fclose('all')

% DON'T FORGET TO RUN TPRIME! YOU ******NEED******* to run Tprime command to align these time points to imec sync channel



