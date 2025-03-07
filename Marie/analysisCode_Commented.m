%this code adds paths where I keep code
addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\originalCode'));
addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\Kilosort\Kilosort2-noCAR'));

% !!!!!!!!!!!!------- read this    -------------!!!!!!!!!!!
% you need to move to the folder \\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis
% to run the first sections of this code, because it is pulling data from
% files in that folder.

% in Command Window, type this to run CatGT and filter with a loccar 1,2
% filter for Kilosort and extract timestamps we need for syncing and
% behavior. More info on CatGT is found in the folder with the program and
% at Bill Karsh's online documentation.
%
% cd C:\Program Files\CatGTWinApp2.4\CatGT-win
% CatGT -dir=Z:/NeuropixelsAnalysis/AuditoryDay1/1697 -run=1697_240312_day2_noClick_click -g=0 -t=0 -prb=0 -ap -ni -loccar=1,2 -SY=0,384,6,500 -XD=2,0,0 -XD=2,7,0 -XD=2,6,0 -XD=2,1,0 -XD=2,2,0 -iXD=2,7,0 -iXD=2,6,0
% end Command Window

% this code gets the juice times and tone times we extracted and pulls them
% into Matlab as 'JuiceTimes' and 'ToneTimes'. This is the time of the Tone
% in mWorks, I think there is some delay before it is actually played.
JuiceTimes_folder = dir('*nidq.xd_2_1_0.txt');
fid = fopen(JuiceTimes_folder(1).name);
JuiceTimes = fscanf(fid, '%f');
fclose(fid);
ToneTimes_folder = dir('*nidq.xd_2_2_0.txt');
fid = fopen(ToneTimes_folder(1).name);
ToneTimes = fscanf(fid, '%f');
fclose(fid);

% this line removes tone times that were cued in mWorks but I hade the
% sound turned off at the computer, for big blocks of uncued reward.
ToneTimes = ToneTimes(ToneTimes > (15*60 + 50) | (ToneTimes > (7*60 + 31) & ToneTimes < (7*60 + 56)));

% this code just reorders the timestamps into Trial Struct, which has a
% line for each trial and specifies what kind it is. It also returns the
% other self-descriptive variables. 'FictiveJuice' as a stand-alone is just juice time on omission trials, but in other cases is both actual juice
% and times when juice would have been delivered but it was an omission
% trial.
[TrialStruct, JuiceAlone, ToneAlone, JuiceAfterTone, ToneBeforeJuice, FictiveJuice] = JuiceToneCreateTrialSt(JuiceTimes, ToneTimes);

% this is a visualization code, that shows several examples (here 20) of
% lick traces around the water delivery so you can se the level for what
% you want the threshold to be for lick detection. The baseline has some
% drift so it needs to be re-checked daily. Here I'm testing .8 as the
% threshold.
close all
FindLickLevels(JuiceTimes, 3, 5, 20, .8);

% I am detecting the licks, using .6 as the threshold for onset and .8 as
% the threshold it must reach to be considered a lick.
close all
[AllLicks, LickDetectParams, AllLickDurations] = FindAllLicks(JuiceTimes(1) - 30, JuiceTimes(end) + 30, .6, .8);

% visualizes lick durations and removes licks that are implausibly short or
% long (grooming)
figure
histogram(AllLickDurations, [0:.01:4]);
GroomTimeGridA = AllLicks(AllLickDurations >.2);
AllDurs_Groom = AllLickDurations(AllLickDurations >.2);
GroomTimeGridB = GroomTimeGridA + AllDurs_Groom;
AllLicks_noGroom = AllLicks(AllLickDurations <.2);
AllLickDurations_trim = AllLickDurations(AllLickDurations <.2);

%check the data
[LickOnsets, ~, ~] = FindLickOnsets_epochs(AllLicks_noGroom, 0.5, .21, 1);
[EpochOnsets, LickSecond, LickThird] = FindLickOnsets_epochs(AllLicks_noGroom, 0.5, .21, 3);
figure
RasterMatrix = OrganizeRasterEvents(JuiceTimes, AllLicks_noGroom, 5, 5, 'k');
FigureWrap('Lick Raster', 'Lick_Raster', 'time from reward', 'trial', NaN, NaN, NaN, NaN);

% Calculate SpeedTimes & SpeedValues to quantify movement. 100 ms bins is
% hard-coded in. 
[SpeedTimes, SpeedValues] = QuadratureDecoderFast_xid();
SpeedTimes = SpeedTimes.';

% save some data to sync with the Npyx file.
save SpeedTimes.txt SpeedTimes -ascii -double
save AllLicks.txt AllLicks_noGroom -ascii -double
% save GroomTimeGridA.txt GroomTimeGridA -ascii -double
% save GroomTimeGridB.txt GroomTimeGridB -ascii -double

% in Command Window, type this to run TPrime sync the data collected on the probe with data collected on the nidaq
% More info on TPrime is found in the folder with the program and
% at Bill Karsh's online documentation.
%
cd C:\Program Files\TPrimeWinApp\TPrime-win
TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\240716_1697_day25_Npx_g0_tcat.imec0.ap.xd_384_6_500.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\240716_1697_day25_Npx_g0_tcat.nidq.xd_2_0_500.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\240716_1697_day25_Npx_g0_tcat.nidq.xd_2_1_0.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\JuiceTimesAdj.txt
TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\240716_1697_day25_Npx_g0_tcat.imec0.ap.xd_384_6_500.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\240716_1697_day25_Npx_g0_tcat.nidq.xd_2_0_500.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\240716_1697_day25_Npx_g0_tcat.nidq.xd_2_2_0.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\ToneTimesAdj.txt
TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\240716_1697_day25_Npx_g0_tcat.imec0.ap.xd_384_6_500.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\240716_1697_day25_Npx_g0_tcat.nidq.xd_2_0_500.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\AllLicks.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\AllLicksAdj.txt
TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\240716_1697_day25_Npx_g0_tcat.imec0.ap.xd_384_6_500.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\240716_1697_day25_Npx_g0_tcat.nidq.xd_2_0_500.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\SpeedTimes.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1697\240716_1697_day25_Npx_g0_analysis\SpeedTimesAdj.txt

%%%%%%%

% We are going to run much of the previous sections again to get the synced
% copies of relevant timestamps, usually with the same variable name
% appended with 'Adj'. At some point in concatenated analysis I drop the 'Adj' again
% becasue it just gets long to type.
fid = fopen('JuiceTimesAdj.txt');
JuiceTimesAdj = fscanf(fid, '%f');
fclose(fid);
fid = fopen('ToneTimesAdj.txt');
ToneTimesAdj = fscanf(fid, '%f');
fclose(fid);
fid = fopen('AllLicksAdj.txt');
AllLicksAdj = fscanf(fid, '%f');
fclose(fid);
fid = fopen('SpeedTimesAdj.txt');
SpeedTimesAdj = fscanf(fid, '%f');
fclose(fid);

ToneTimesAdj = ToneTimesAdj(ToneTimesAdj > (15*60 + 50) | (ToneTimesAdj > (7*60 + 31) & ToneTimesAdj < (7*60 + 56)));

[TrialStructAdj, JuiceAloneAdj, ToneAloneAdj, JuiceAfterToneAdj, ToneBeforeJuiceAdj, FictiveJuiceAdj] = JuiceToneCreateTrialSt(JuiceTimesAdj, ToneTimesAdj);
[RunMetaData, Index_stay_cell, Index_move_cell, Index_forwardrun_cell, still_TGA, still_TGB, move_TGA, move_TGB] = find_behavStatesMEH(SpeedTimesAdj, SpeedValues);

% [FirstJuiceLicksAdj, FirstJuiceEpochsAdj] = ExtractFirstJuice3(TrialStructAdj, AllLicksAdj); %these define licking epochs as 1 lick
% [NoJuiceLicksAdj, NoJuiceEpochsAdj] = ExtractNoJuice(TrialStructAdj, AllLicksAdj); %these define licking epochs as 1 lick
% LickOnsetsAdj = FindLickingEpochs(AllLicksAdj, 1, .21); %defines licking epochs as 1 lick
% EpochOnsetsAdj = FindLickingEpochs(AllLicksAdj, 3, .21); %defines licking epochs as 1 lick
[LickOnsets, ~, ~] = FindLickOnsets_epochs(AllLicksAdj, 0.5, .21, 1);
[EpochOnsets, LickSecond, LickThird] = FindLickOnsets_epochs(AllLicksAdj, 0.5, .21, 3);

%stopped here 240712

% Move to the C4 folder, where kilosort output and C4 output are! 

% Import data from Kilosort. There are several version of this code
% 'ImportKSdata...' that run with different versions of phy/phyllum/C4.
% Between choices I made and choices Alvaro made it was kind of a pain.
% This is an older version:  [AllUnitStruct, GoodUnitStruct, MultiUnitStruct, GoodANDmuaStruct] = ImportKSdataPhyllum();
[AllUnitStruct, GoodUnitStruct, MultiUnitStruct, GoodANDmuaStruct, loc] = ImportKSdataPhyllumC4_mod();

% just sort by location on the probe and what kind of units I'm looking at.
% I really only use the GoodUnitStructSorted from now on.
GoodUnitStructSorted = SortStruct(GoodUnitStruct, 'channel', 'descend');
GoodANDmuaStructSorted = SortStruct(GoodANDmuaStruct, 'channel', 'descend');
AllUnitStructSorted = SortStruct(AllUnitStruct, 'channel', 'descend');

% just a channel map so I can utilize the channels position in space
load MEH_chanMap

% calculate reaction times from the tone, wiht .5 seconds of no licking
% required before a reaction
[TrialStructRTtAdj, TrialStructSortedtAdj] = RTtone(TrialStructAdj, AllLicksAdj, .5);

% plot the reaction times
%RT plots
figure
hold on
for n = 1:length(TrialStructRTtAdj)
if strcmp({TrialStructRTtAdj(n).TrialType}, 't')
scatter(n, [TrialStructRTtAdj(n).RTt], 'g')
end
end
for n = 1:length(TrialStructRTtAdj)
if strcmp({TrialStructRTtAdj(n).TrialType}, 'j')
scatter(n, [TrialStructRTtAdj(n).RTt], 'b')
end
end
for n = 1:length(TrialStructRTtAdj)
if strcmp({TrialStructRTtAdj(n).TrialType}, 'b')
scatter(n, [TrialStructRTtAdj(n).RTt], 'k')
end
end

% this is just code to save the matlab figure and the pdf version of the
% figure
FigureWrap('RTt scatter', 'RTt_scatter', 'trial', 'reaction time" from cue', NaN, NaN, NaN, NaN);

% adjust a few parameters here in this code before starting to create the
% structure that will be passed into project-level analysis
%FIX THIS BEFORE RUNNING!!
TrainingData_1697(25).AllLicks = AllLicksAdj;
TrainingData_1697(25).LickDetectParams = LickDetectParams;
TrainingData_1697(25).TrialStruct = TrialStructAdj;
TrainingData_1697(25).loc = what().path;
%check before saving!!
save TrainingData_1697 TrainingData_1697

% Make lists of cells by cell type that the classifier pulled out with
% reasonable confidence
CS = GoodUnitStructSorted(strcmp({GoodUnitStructSorted.c4_label}, 'PkC_cs'));
CS = CS([CS.c4_confidence] > 2);
SS = GoodUnitStructSorted(strcmp({GoodUnitStructSorted.c4_label}, 'PkC_ss'));
SS = SS([SS.c4_confidence] > 2);
MF = GoodUnitStructSorted(strcmp({GoodUnitStructSorted.c4_label}, 'MFB'));
MF = MF([MF.c4_confidence] > 2);
MLI = GoodUnitStructSorted(strcmp({GoodUnitStructSorted.c4_label}, 'MLI'));
MLI = MLI([MLI.c4_confidence] > 2);
Gol = GoodUnitStructSorted(strcmp({GoodUnitStructSorted.c4_label}, 'GoC'));

% check what the cell types are doing
figure
[N, edges, L1] = meanPSTH(JuiceTimesAdj, CS, -.1, .3, .005, [0 inf], 4, 'b', 1, 0, 0, 0);
hold on
[N, edges, L1] = meanPSTH(ToneTimesAdj, CS, -.1, .3, .005, [0 inf], 4, 'g', 1, 0, 0, 0);
xlabel('time from all tone & reward');
figure
[N, edges] = cellHeatMap(CS, JuiceTimesAdj, [-.1 .25], .005, [0 inf], 0, 0, 1, 1, NaN);
xlabel('time from all reward');
figure
[N, edges] = cellHeatMap(CS, ToneTimesAdj, [-.1 .2], .005, [0 inf], 0, 0, 1, 1, NaN);
xlabel('time from all tone');
figure
[N, edges] = cellHeatMap(SS, LickOnsets, [-.5 1.5], .01, [0 inf], 0, 0, 1, 1, NaN);
xlabel('time from lick onset');
figure
[N, edges] = cellHeatMap(SS, ToneTimesAdj, [-.2 1], .005, [0 inf], 0, 0, 1, 1, NaN);
figure
xlabel('time from all tone');
[N, edges, L1] = meanPSTH(LickOnsets, CS, -1, .5, .005, [0 inf], 4, 'k', 1, 0, 0, 0);
xlabel('time from lick onset');
figure
[N, edges, L1] = meanPSTH(JuiceTimesAdj, MLI, -.1, .5, .005, [0 inf], 4, 'b', 1, 0, 0, 0);
hold on
[N, edges, L1] = meanPSTH(ToneTimesAdj, MLI, -.1, .5, .005, [0 inf], 4, 'g', 1, 0, 0, 0);
xlabel('time from all reward or tone');
figure
[N, edges, L1] = meanPSTH(JuiceTimesAdj, SS, -.1, .5, .005, [0 inf], 4, 'b', 1, 0, 0, 0);
hold on
[N, edges, L1] = meanPSTH(ToneTimesAdj, SS, -.1, .5, .005, [0 inf], 4, 'g', 1, 0, 0, 0);
xlabel('time from all reward or tone');

% find pairs of Sspk & Cspk. 
% this code finds potential pairs and allows a human to check them all.
counter = 1;
close all
for k = 1:length([GoodUnitStructSorted.unitID])
    if GoodUnitStructSorted(k).FR > 20 & ~strcmp({GoodUnitStructSorted(k).c4_label}, 'MF')
unit = GoodUnitStructSorted(k).unitID;
index = find([GoodUnitStructSorted.unitID] == unit);
m = index;
     
for n = 1:length(GoodUnitStructSorted)
    if abs(GoodUnitStructSorted(n).depth - GoodUnitStructSorted(index).depth) < 1000
        if strcmp(GoodUnitStructSorted(n).layer, 'GrC_layer')
        else
        if GoodUnitStructSorted(n).FR<4
        [N, edges] = XcorrFastINDEX_TG(GoodUnitStructSorted, -.05, .05, .001, n, m, NaN, NaN, 0, inf, 'k', 0, 4, 0);        
        %xCorrStructNewLimitsLine(AllUnitStruct, -.02, .02, .001, GoodUnitStructSorted(n).unitID, unit, 0, inf, 'k', 3, 1);
        if min(N) < 10
            figure
            plot(edges, N);
           title([num2str(GoodUnitStructSorted(n).unitID) ' & ' num2str(GoodUnitStructSorted(m).unitID)])
        SS_CS(counter).CS = GoodUnitStructSorted(n).unitID;
        SS_CS(counter).SS = GoodUnitStructSorted(m).unitID;
        counter = counter + 1;
        end
        end
        %end
    end
    end
end
    end
end

close all
for n = 1:length(SS_CS)
    figure
    p = find([GoodUnitStructSorted.unitID] == SS_CS(n).CS);
    q =  find([GoodUnitStructSorted.unitID] == SS_CS(n).SS);
            [N, edges] = XcorrFastINDEX_TG(GoodUnitStructSorted, -.05, .05, .001, p, q, NaN, NaN, 0, inf, 'k', 1, 4, 0);        
end

% Using the preceeding code, you have identified potential pairs and
% deleted any that are not true pairs. Now we will make a record of which pairs go together in our main structure.

for n = 1:length(SS_CS)
index = find([GoodUnitStructSorted.unitID] == SS_CS(n).SS);
GoodUnitStructSorted(index).PC_pair = SS_CS(n).CS;
index = find([GoodUnitStructSorted.unitID] == SS_CS(n).CS);
GoodUnitStructSorted(index).PC_pair = SS_CS(n).SS;
end

% start makign the structure we'll use to concatenate data for
% project-level analysis
Summary_noWF_1697_day25 = GoodUnitStructSorted;
for n = 1:length(Summary_noWF_1697_day25)
Summary_noWF_1697_day25(n).loc = loc();
end

% Use real-time notes to know which juice deliveries were audible and which
% were silent.
JuiceTimes_sil = JuiceTimesAdj(JuiceTimesAdj < (8*60 + 13));
JuiceTimes_clk = JuiceTimesAdj(JuiceTimesAdj > (8*60 + 13));

% Make 'Time Grids' (TG) A & B to show when animals were quiescent.
for n = 1:length(still_TGA)
if ~isempty(find(still_TGA(n) < AllLicksAdj & AllLicksAdj < still_TGB(n)))
qsc_TGA(n) = NaN;
qsc_TGB(n) = NaN;
else
qsc_TGA(n) = still_TGA(n);
qsc_TGB(n) = still_TGB(n);
end
end
qsc_TGA = rmmissing(qsc_TGA);
qsc_TGB = rmmissing(qsc_TGB);
 
% Make a structure that has all the data about locomotion
RunningStruct.SpeedTimesAdj = SpeedTimesAdj;
RunningStruct.SpeedValues = SpeedValues;
RunningStruct.qsc_TGA = qsc_TGA;
RunningStruct.qsc_TGB = qsc_TGB;
RunningStruct.move_TGA = move_TGA;
RunningStruct.move_TGB = move_TGB;
RunningStruct.still_TGA = still_TGA;
RunningStruct.still_TGB = still_TGB;
RunningStruct.RunMetaData = RunMetaData;
RunningStruct.loc = what().path;

% Make a structure that has all the behavioral data for this recording.
RecordingList_1697_day25.loc = loc();
RecordingList_1697_day25.AllLicks = AllLicksAdj;
RecordingList_1697_day25.TrialStruct = TrialStructRTtAdj;
RecordingList_1697_day25.ToneTimes = ToneTimesAdj;
RecordingList_1697_day25.JuiceTimes = JuiceTimesAdj;
RecordingList_1697_day25.JuiceTimes_clk = JuiceTimes_clk;
RecordingList_1697_day25.JuiceTimes_sil = JuiceTimes_sil;
RecordingList_1697_day25.NoJuiceClk = [];
RecordingList_1697_day25.RunningStruct = RunningStruct;

