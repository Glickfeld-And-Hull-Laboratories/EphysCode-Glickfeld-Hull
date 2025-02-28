addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\originalCode'));
addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\Kilosort\Kilosort2-noCAR'));
% MEH ran this analysis to deal with missing locomotor data

load('data-i3700-250213-1310.mat')
animal= 3700;
day = 9;
nameString = [num2str(animal) '_day' num2str(day)];
nameStringSpace = [num2str(animal) ' day' num2str(day)];

JuiceTimes = double(cell2mat(input.MEHJuiceTime));
ToneTimes = double(cell2mat(input.MEHToneTime));
%TrialStart = double(cell2mat(input.MEHTrialStart))/100000;
[TrialStruct, JuiceAlone, LaserAlone, JuiceAfterLaser, LaserBeforeJuice, ~] = JuiceToneCreateTrialSt(JuiceTimes, ToneTimes);

delay = mean([TrialStruct(strcmp({TrialStruct.TrialType}, 'b')).JuiceTime] - [TrialStruct(strcmp({TrialStruct.TrialType}, 'b')).ToneTime]);

LickTimes = [];
% LickValues = [];
for n = 1:length(input.lickometerTimesUs)
    LickTimes = [LickTimes; cell2mat(input.lickometerTimesUs(n)).'];
end
LickTimes = double(LickTimes) / 1000000;
[EpochOnsets, LickSecond, LickThird] = FindLickOnsets_epochs(LickTimes, 0.5, .21, 3);


figure
nexttile
RasterMatrix = OrganizeRasterEvents(ToneTimes, LickTimes, 10, 10, 'k');
xlim([-10 10]);
xline(delay, 'b');
xline(0, 'g');
    ylabel('trial')
    xlabel('time from laser onset');
    title('licks in trials')
    FormatFigure(NaN, NaN);
    
[TrialStructRTt, TrialStructSortedt] = RTtone(TrialStruct, LickTimes, .5, 6);

%RT plots
nexttile
hold on
for n = 1:length(TrialStructRTt)
if strcmp({TrialStructRTt(n).TrialType}, 't')
scatter(n, [TrialStructRTt(n).RTt], 'g')
end
end
for n = 1:length(TrialStructRTt)
if strcmp({TrialStructRTt(n).TrialType}, 'j')
scatter(n, [TrialStructRTt(n).RTt], 'b')
end
end
for n = 1:length(TrialStructRTt)
if strcmp({TrialStructRTt(n).TrialType}, 'b')
scatter(n, [TrialStructRTt(n).RTt], 'k')
end
end

ylim([-.5 8])
yline(delay, 'b');
yline(0, 'g');
    ylabel('time of lick onset')
    xlabel('trial');
    title('reaction time')
FormatFigure(NaN, NaN)


QuadratureTimes = [];
QuadratureValues = [];
for n = 1:length(input.quadratureTimesUs)
    QuadratureTimes = [QuadratureTimes; double(cell2mat(input.quadratureTimesUs(n))).'/1000000];
end
for n = 1:length(input.quadratureValues)
    QuadratureValues = [QuadratureValues; cell2mat(input.quadratureValues(n)).'];
end

[SpeedTimes, SpeedValues] = QuadratureDecoderMworks(QuadratureTimes, QuadratureValues);
[RunMetaData, Index_stay_cell, Index_move_cell, Index_forwardrun_cell, still_TGA, still_TGB, move_TGA, move_TGB] = find_behavStatesMEH(SpeedTimes, SpeedValues);

if ~isempty(SpeedTimes)
  [RotHist, RotHistEdges, ~] = RunSpeedHistLines(ToneTimes, SpeedTimes,  SpeedValues.', -5, 8);
  nexttile
    plot(RotHistEdges.', RotHist(1:end-1), 'k')
     xline(0, 'g');
  xline(delay, 'b');
    ylabel('speed cm/s');
    xlabel('time from laser onset');
    title('locomotion');
    FormatFigure(NaN, NaN)
else
    nexttile
     xline(0, 'g');
  xline(delay, 'b');
    ylabel('speed cm/s');
    xlabel('time from laser onset');
    title('locomotion');
    FormatFigure(NaN, NaN)
end
    
    [LickHistogram, LickHistEdges] = LickHist(ToneTimes.', LickTimes, [-5 8], .1, 'k', 0);
 nexttile
  plot(LickHistEdges(1:end-1), LickHistogram, 'k')
  xline(0, 'g');
  xline(delay, 'b');
  ylabel('licks/s')
    xlabel('time from laser onset');
    FormatFigure(NaN, NaN)

% if Licking Data is present
if ~isempty(still_TGA)
for n = 1:length(still_TGA)
if ~isempty(find(still_TGA(n) < LickTimes & LickTimes < still_TGB(n)))
qsc_TGA(n) = NaN;
qsc_TGB(n) = NaN;
else
qsc_TGA(n) = still_TGA(n);
qsc_TGB(n) = still_TGB(n);
end
end
qsc_TGA = rmmissing(qsc_TGA);
qsc_TGB = rmmissing(qsc_TGB);
else
    qsc_TGA = [];
    qsc_TGB = [];
end
%
%else this 
%for n = 1:length(still_TGA)
%qsc_TGA(n) = still_TGA(n);
%qsc_TGB(n) = still_TGB(n);
 
RunningStruct.SpeedTimes = SpeedTimes;
RunningStruct.SpeedValues = SpeedValues;
RunningStruct.qsc_TGA = qsc_TGA;
RunningStruct.qsc_TGB = qsc_TGB;
RunningStruct.move_TGA = move_TGA;
RunningStruct.move_TGB = move_TGB;
RunningStruct.RunMetaData = RunMetaData;
RunningStruct.loc = what().path;
FigureWrap(nameStringSpace, nameString, NaN, NaN, NaN, NaN, 2.2, 8.5);


Behavior.loc = what().path;
Behavior.AllLicks = LickTimes;
Behavior.TrialStruct = TrialStruct;
Behavior.ToneTimes = ToneTimes;
Behavior.JuiceTimes = JuiceTimes;
Behavior.RunningStruct = RunningStruct;
Behavior.Animal = animal;
Behavior.Day = day;

save('Behavior', 'Behavior');

save('Workspace');

%SAVE THIS SCRIPT AS analysisCode!!!!!


% MEH ran this analysis to deal with missing locomotor data

load('data-i3700-250212-1147.mat')
animal= 3700;
day = 8;
nameString = [num2str(animal) '_day' num2str(day)];
nameStringSpace = [num2str(animal) ' day' num2str(day)];

JuiceTimes = double(cell2mat(input.MEHJuiceTime));
ToneTimes = double(cell2mat(input.MEHToneTime));
%TrialStart = double(cell2mat(input.MEHTrialStart))/100000;
[TrialStruct, JuiceAlone, LaserAlone, JuiceAfterLaser, LaserBeforeJuice, ~] = JuiceToneCreateTrialSt(JuiceTimes, ToneTimes);

delay = mean([TrialStruct(strcmp({TrialStruct.TrialType}, 'b')).JuiceTime] - [TrialStruct(strcmp({TrialStruct.TrialType}, 'b')).ToneTime]);

LickTimes = [];
% LickValues = [];
for n = 1:length(input.lickometerTimesUs)
    LickTimes = [LickTimes; cell2mat(input.lickometerTimesUs(n)).'];
end
LickTimes = double(LickTimes) / 1000000;
[EpochOnsets, LickSecond, LickThird] = FindLickOnsets_epochs(LickTimes, 0.5, .21, 3);


figure
nexttile
RasterMatrix = OrganizeRasterEvents(ToneTimes, LickTimes, 10, 10, 'k');
xlim([-10 10]);
xline(delay, 'b');
xline(0, 'g');
    ylabel('trial')
    xlabel('time from laser onset');
    title('licks in trials')
    FormatFigure(NaN, NaN);
    
[TrialStructRTt, TrialStructSortedt] = RTtone(TrialStruct, LickTimes, .5, 6);

%RT plots
nexttile
hold on
for n = 1:length(TrialStructRTt)
if strcmp({TrialStructRTt(n).TrialType}, 't')
scatter(n, [TrialStructRTt(n).RTt], 'g')
end
end
for n = 1:length(TrialStructRTt)
if strcmp({TrialStructRTt(n).TrialType}, 'j')
scatter(n, [TrialStructRTt(n).RTt], 'b')
end
end
for n = 1:length(TrialStructRTt)
if strcmp({TrialStructRTt(n).TrialType}, 'b')
scatter(n, [TrialStructRTt(n).RTt], 'k')
end
end

ylim([-.5 8])
yline(delay, 'b');
yline(0, 'g');
    ylabel('time of lick onset')
    xlabel('trial');
    title('reaction time')
FormatFigure(NaN, NaN)


QuadratureTimes = [];
QuadratureValues = [];
for n = 1:length(input.quadratureTimesUs)
    QuadratureTimes = [QuadratureTimes; double(cell2mat(input.quadratureTimesUs(n))).'/1000000];
end
for n = 1:length(input.quadratureValues)
    QuadratureValues = [QuadratureValues; cell2mat(input.quadratureValues(n)).'];
end

[SpeedTimes, SpeedValues] = QuadratureDecoderMworks(QuadratureTimes, QuadratureValues);
[RunMetaData, Index_stay_cell, Index_move_cell, Index_forwardrun_cell, still_TGA, still_TGB, move_TGA, move_TGB] = find_behavStatesMEH(SpeedTimes, SpeedValues);

if ~isempty(SpeedTimes)
  [RotHist, RotHistEdges, ~] = RunSpeedHistLines(ToneTimes, SpeedTimes,  SpeedValues.', -5, 8);
  nexttile
    plot(RotHistEdges.', RotHist(1:end-1), 'k')
     xline(0, 'g');
  xline(delay, 'b');
    ylabel('speed cm/s');
    xlabel('time from laser onset');
    title('locomotion');
    FormatFigure(NaN, NaN)
else
    nexttile
     xline(0, 'g');
  xline(delay, 'b');
    ylabel('speed cm/s');
    xlabel('time from laser onset');
    title('locomotion');
    FormatFigure(NaN, NaN)
end
    
    [LickHistogram, LickHistEdges] = LickHist(ToneTimes.', LickTimes, [-5 8], .1, 'k', 0);
 nexttile
  plot(LickHistEdges(1:end-1), LickHistogram, 'k')
  xline(0, 'g');
  xline(delay, 'b');
  ylabel('licks/s')
    xlabel('time from laser onset');
    FormatFigure(NaN, NaN)

% if Licking Data is present
if ~isempty(still_TGA)
for n = 1:length(still_TGA)
if ~isempty(find(still_TGA(n) < LickTimes & LickTimes < still_TGB(n)))
qsc_TGA(n) = NaN;
qsc_TGB(n) = NaN;
else
qsc_TGA(n) = still_TGA(n);
qsc_TGB(n) = still_TGB(n);
end
end
qsc_TGA = rmmissing(qsc_TGA);
qsc_TGB = rmmissing(qsc_TGB);
else
    qsc_TGA = [];
    qsc_TGB = [];
end
%
%else this 
%for n = 1:length(still_TGA)
%qsc_TGA(n) = still_TGA(n);
%qsc_TGB(n) = still_TGB(n);
 
RunningStruct.SpeedTimes = SpeedTimes;
RunningStruct.SpeedValues = SpeedValues;
RunningStruct.qsc_TGA = qsc_TGA;
RunningStruct.qsc_TGB = qsc_TGB;
RunningStruct.move_TGA = move_TGA;
RunningStruct.move_TGB = move_TGB;
RunningStruct.RunMetaData = RunMetaData;
RunningStruct.loc = what().path;
FigureWrap(nameStringSpace, nameString, NaN, NaN, NaN, NaN, 2.2, 8.5);


Behavior.loc = what().path;
Behavior.AllLicks = LickTimes;
Behavior.TrialStruct = TrialStruct;
Behavior.ToneTimes = ToneTimes;
Behavior.JuiceTimes = JuiceTimes;
Behavior.RunningStruct = RunningStruct;
Behavior.Animal = animal;
Behavior.Day = day;

save('Behavior', 'Behavior');

save('Workspace');

%SAVE THIS SCRIPT AS analysisCode!!!!!

