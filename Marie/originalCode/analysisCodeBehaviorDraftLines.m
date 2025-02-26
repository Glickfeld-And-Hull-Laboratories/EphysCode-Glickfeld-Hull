
addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\originalCode'));
addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\Kilosort\Kilosort2-noCAR'));

JuiceTimes_folder = dir('*nidq.xd_2_1_0.txt');
fid = fopen(JuiceTimes_folder(1).name);
JuiceTimes = fscanf(fid, '%f');
fclose(fid);
ToneTimes_folder = dir('*nidq.xd_2_2_0.txt');
fid = fopen(ToneTimes_folder(1).name);
ToneTimes = fscanf(fid, '%f');
fclose(fid);

ToneTimes = ToneTimes(ToneTimes > (20*60 + 0));
JuiceTimes_sil = JuiceTimes(JuiceTimes < (9*60 + 00) | JuiceTimes > (76*60 + 16));
JuiceTimes_clk = JuiceTimes(JuiceTimes > (9*60 + 00) & JuiceTimes < (76*60 + 16));
NoJuiceClk = [];



% % load AllLicks no groom saved previously
fid = fopen('AllLicks.txt');
AllLicks = fscanf(fid, '%f');
fclose(fid);
% % or 
close all
FindLickLevels(JuiceTimes, 3, 5, 20, .8);

% close all
% [AllLicks, LickDetectParams, AllLickDurations] = FindAllLicks(JuiceTimes(1) - 30, JuiceTimes(end) + 30, .6, .8);
% figure
% histogram(AllLickDurations, [0:.01:4]);
% GroomTimeGridA = AllLicks(AllLickDurations >.2);
% AllDurs_Groom = AllLickDurations(AllLickDurations >.2);
% GroomTimeGridB = GroomTimeGridA + AllDurs_Groom;
% AllLicks_noGroom = AllLicks(AllLickDurations <.2);
% AllLicks = AllLickDurations(AllLickDurations <.2);

[SpeedTimes, SpeedValues] = QuadratureDecoderFast_xid();
SpeedTimes = SpeedTimes.';
[RunMetaData, Index_stay_cell, Index_move_cell, Index_forwardrun_cell, still_TGA, still_TGB, move_TGA, move_TGB] = find_behavStatesMEH(SpeedTimesAdj, SpeedValues);
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

BehaviorList.loc = loc();
BehaviorList.AllLicks = AllLicksAdj;
BehaviorList.ToneTimes = ToneTimesAdj;
BehaviorList.JuiceTimes = JuiceTimesAdj;
BehaviorList.JuiceTimes_clk = JuiceTimes_clk;
BehaviorList.JuiceTimes_sil = JuiceTimes_sil;
BehaviorList.NoJuiceClk = NoJuiceClk;
BehaviorList.RunningStruct = RunningStruct;
BehaviorList.mouse = 1697;
BehaviorList.day = 26;
BehaviorList.date = 240718;

save BehavorWorkspace
