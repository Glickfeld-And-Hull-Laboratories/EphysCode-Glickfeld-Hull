
%RecordingList
addpath(genpath('/Volumes/All_staff/home/marie/originalCode'));
addpath(genpath('/Volumes/All_staff/home/marie/Kilosort\Kilosort2-noCAR'));

% delayTimes = [0; .250; .5; 1; 2; 4];
toleran = .1;


% PathList = { '/Volumes/All_staff/home/marie/LaserCueCC/3701/4 sec delay/250121_200msLaserTrain' ... % 3701 day 1
%     '/Volumes/All_staff/home/marie/LaserCueCC/3701/4 sec delay/250122' ... % 3701 day 2
%     '/Volumes/All_staff/home/marie/LaserCueCC/3701/4 sec delay/250123' ... % 3701 day 3
%     '/Volumes/All_staff/home/marie/LaserCueCC/3701/4 sec delay/250124' ... % 3701 day 4
%     '/Volumes/All_staff/home/marie/LaserCueCC/3701/4 sec delay/250127' ... % 3701 day 5
%     '/Volumes/All_staff/home/marie/LaserCueCC/3701/4 sec delay/250128' ... % 3701 day 6
%     '/Volumes/All_staff/home/marie/LaserCueCC/3701/4 sec delay/250129' ... % 3701 day 7
%     '/Volumes/All_staff/home/marie/LaserCueCC/3701/4 sec delay/250130' ... % 3701 day 8
%     '/Volumes/All_staff/home/marie/LaserCueCC/3701/4 sec delay/250131' ... % 3701 day 9
%     '/Volumes/All_staff/home/marie/LaserCueCC/3701/4 sec delay/250201' ... % 3701 day 10
%     '/Volumes/All_staff/home/marie/LaserCueCC/3700/4 sec delay/250203_900ms'... % 3700 day 1
%     '/Volumes/All_staff/home/marie/LaserCueCC/3700/4 sec delay/250204' ... % 3700 day 2
%     '/Volumes/All_staff/home/marie/LaserCueCC/3700/4 sec delay/250205'... % 3700 day 3
%     '/Volumes/All_staff/home/marie/LaserCueCC/3700/4 sec delay/250207' ... % 3700 day 5
%     '/Volumes/All_staff/home/marie/LaserCueCC/3700/4 sec delay/250210' ... % 3700 day 6
%     '/Volumes/All_staff/home/marie/LaserCueCC/3700/4 sec delay/250211' ... % 3700 day 7
%     '/Volumes/All_staff/home/marie/LaserCueCC/3700/4 sec delay/250212' ... % 3700 day 8
%     '/Volumes/All_staff/home/marie/LaserCueCC/3700/4 sec delay/250213' ... % 3700 day 9
%     '/Volumes/All_staff/home/marie/LaserCueCC/BehaviorCurve_delay'};


PathList = {'\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\LaserCueCC\3701\2 dec delay\250210' ... % 3701 day 1
    '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\LaserCueCC\3701\2 dec delay\250211' ... % 3701 day 2
    '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\LaserCueCC\3701\2 dec delay\250212' ... % 3701 day 3
    '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\LaserCueCC\3701\2 dec delay\250213' ... % 3701 day 4
    '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\LaserCueCC\3701\2 dec delay\250214' ... % 3701 day 5
    '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\LaserCueCC\3701\2 dec delay\250217' ... % 3701 day 6
    '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\LaserCueCC\3701\2 dec delay\250218' ... % 3701 day 7
    '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff/home/marie/LaserCueCC/BehaviorCurve_delay'};

% load all the data and put you back in the right place
cd(PathList{1})
load('Behavior.mat');
MasterStruct = Behavior.';
for n = 2:length(PathList)-1
    cd(PathList{n})
    load('Behavior.mat');
    MasterStruct = [MasterStruct; Behavior.'];
end
cd(PathList{length(PathList)})

%calculate the delay for every recording
for n = 1:length(MasterStruct)
    MasterStruct(n).delay = mean([MasterStruct(n).TrialStruct(strcmp({MasterStruct(n).TrialStruct.TrialType}, 'b')).JuiceTime] - [MasterStruct(n).TrialStruct(strcmp({MasterStruct(n).TrialStruct.TrialType}, 'b')).ToneTime]);
end

mouseList = unique([MasterStruct.Animal]);


% for every mouse, let's plot their behavior over time
% pre-calcs
% raster calc

for m = 1:length(mouseList)
    mouseStruct = MasterStruct([MasterStruct.Animal] == mouseList(m));
    delayTimes = uniquetol([mouseStruct.delay], toleran);
    [Lia, LocB] = ismembertol([mouseStruct.delay], delayTimes, toleran);
    for q = length(delayTimes):1
        mouseDelayStruct = mouseStruct(find(LocB == q));
    dayColors = parula(length(mouseDelayStruct)+1);
    for n = 1:length(mouseDelayStruct)
        dayLegend{n} = ['day ' num2str(mouseDelayStruct(n).Day)];
    end
    LickTimes = [];
    ToneTimes = [];
    TrialStruct = [];
    LicksPerDay = [1];
    TonesPerDay = [1];
    TrialsPerDay = [1];
    
    for n = 1:length(mouseDelayStruct)
        LickTimes = [LickTimes; [mouseDelayStruct(n).AllLicks] + (n-1)*10000];
        LicksPerDay(1,n+1) = length(LickTimes);
        ToneTimes = [ToneTimes; [mouseDelayStruct(n).ToneTimes].'+ (n-1)*10000];
        TonesPerDay(1,n+1) = length(ToneTimes);
        [ThisTrialStruct, ~, ~, ~, ~, ~] = JuiceToneCreateTrialSt([[mouseDelayStruct(n).JuiceTimes].'+ (n-1)*10000], [[mouseDelayStruct(n).ToneTimes].'+ (n-1)*10000]);
        TrialStruct = [TrialStruct; ThisTrialStruct.'];
        TrialsPerDay(1,n+1) = length(TrialStruct);
    end
    
    %RT calc
    [TrialStructRTt, TrialStructSortedt] = RTtone_delay(TrialStruct, LickTimes, .5, 8, mouseDelayStruct(1).delay);
    
    %locomotion calc
    for n = 1:length(mouseDelayStruct)
        if length(mouseDelayStruct(n).RunningStruct.SpeedTimes) > 3
            [RotHist(:,n), RotHistEdges, ~] = RunSpeedHistLines(mouseDelayStruct(n).ToneTimes, [mouseDelayStruct(n).RunningStruct.SpeedTimes], [mouseDelayStruct(n).RunningStruct.SpeedValues].', -5, 8);
        end
    end

% -------------     plots     ------------------

layout1 = tiledlayout('flow', 'TileSpacing', 'none', 'Padding', 'none');
% title(num2str(mouseList(m)))
nexttile     % raster plot
xline(0, 'g', 'LineWidth', 1);
xline(mouseDelayStruct(1).delay, 'b', 'LineWidth', 1);
RasterMatrix = OrganizeRasterEvents(ToneTimes, LickTimes, 5, 10, 'k');
for n = 1:length(TrialsPerDay)-1
    yline(TrialsPerDay(1,n), '--', ['day ' num2str(n)], 'Color', dayColors(n,:), 'LabelVerticalAlignment','bottom', 'LineWidth', 1, 'FontSize', 10);
end
xlim([-10 15]);
ylabel('trial')
xlabel('time from laser onset');
title('licks in trials')
legend({'opto onset'; 'reward'; 'lick'}, 'Location', 'northeastoutside');
legend('boxoff');
leg = legend;
leg.ItemTokenSize = [15, 18];
FormatFigure(NaN, NaN);


nexttile  % RT plot
hold on
yline(0, 'g');
yline(mouseDelayStruct(1).delay, 'b');
for n = 1:length(TrialStructRTt)
    if strcmp({TrialStructRTt(n).TrialType}, 'b')
        scatter(n, [TrialStructRTt(n).RTt], 'k')
    end
end
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
for n = 1:length(TrialsPerDay)-1
    xline(TrialsPerDay(1,n), '--', ['day ' num2str(n)], 'Color', dayColors(n,:) , 'LabelOrientation', 'horizontal', 'LineWidth', 1, 'FontSize', 10)
end
ylim([-2 10])
legend({'opto onset'; 'reward'; 'lick'}, 'Location', 'northeastoutside');
legend('boxoff');
leg = legend;
leg.ItemTokenSize = [15, 18];
ylabel('time of lick onset')
xlabel('trial');
title('reaction time')
FormatFigure(NaN, NaN)

% locomotion psth
nexttile
hold on

for n = 1:length(mouseDelayStruct)
    plot(RotHistEdges.', RotHist((1:end-1),n), 'Color', dayColors(n,:))
end

ylabel('speed cm/s');
xlabel('time from laser onset');
xline(mouseDelayStruct(1).delay, 'b');
xline(0, 'g');
title('locomotion');
legend(dayLegend, 'Location', 'northeastoutside');
legend('boxoff');
leg = legend;
leg.ItemTokenSize = [15, 18];
FormatFigure(NaN, NaN)

nexttile  %lick hist plot
hold on
for n = 1:length(mouseDelayStruct)
    [LickHistogram, LickHistEdges] = LickHist(mouseDelayStruct(n).ToneTimes.', mouseDelayStruct(n).AllLicks, [-5 8], .1, 'k', 0);
    plot(LickHistEdges(1:end-1), LickHistogram, 'Color', dayColors(n,:))
end
title('licking')
ylabel('licks/s')
xlabel('time from laser onset');
xline(mouseDelayStruct(1).delay, 'b');
xline(0, 'g');
legend(dayLegend, 'Location', 'northeastoutside');
legend('boxoff');
leg = legend;
leg.ItemTokenSize = [15, 18];
FormatFigure(NaN, NaN)
title(layout1, ['mouse = ' num2str(mouseList(m)) ';  delay = ' num2str(delayTimes(q)) ]);


% ----------- code will go here




FigureWrap(NaN, [num2str(mouseList(m)) '_' num2str(round(delayTimes)) '_sec'], NaN, NaN, NaN, NaN, 8.5, 11);

    end

end

% --------------------------------

AllTrialStruct = [];
AllLicks = [];
AllRunningData = [];
for n = 1:length(mouseDelayStruct)
    if n > 1
        timeMax = max([[AllTrialStruct.ToneTime].'; [AllTrialStruct.JuiceTime].'; AllLicks; [AllRunningData(:,1)]]);
        timeAdd = timeMax + 30;
    else
        timeAdd = 0;
    end
    i = length(AllTrialStruct) + 1;
    for k = 1:length(mouseDelayStruct(n))
        AllTrialStruct(i).day = mouseDelayStruct(n).day;
        AllTrialStruct(i).TrialType = mouseDelayStruct(n).TrialStruct(k).TrialType;
        AllTrialStruct(i).JuiceTime =mouseDelayStruct(n).TrialStruct(k).JuiceTime + timeAdd;
        AllTrialStruct(i).ToneTime = mouseDelayStruct(n).TrialStruct(k).ToneTime + timeAdd;
%         AllTrialStruct(i).MouseTrial = mouseDelayStruct(n).MouseTrialStruct(k).MouseTrial;
        AllTrialStruct(i).FictiveJuice = mouseDelayStruct(n).TrialStruct(k).FictiveJuice + timeAdd;
        i = i + 1;
    end
    AllLicks = [AllLicks; mouseDelayStruct(n).AllLicks + timeAdd];
AllRunningData = [AllRunningData; [[mouseDelayStruct(n).RunningStruct.SpeedTimes] + timeAdd] [mouseDelayStruct(n).RunningStruct.SpeedValues] ];
end


RTmat = ones(size(Delay500, 2), max(cellfun(@length, {Delay500.BRTt}))+1)*-1;
for n = 1:size(Delay500, 2)
    RTmat(n,1:length(Delay500(n).BRTt)) = [Delay500(n).BRTt];
end

ToneTime = ones(size(Delay500, 2), max(cellfun(@length, {Delay500.BRTt})))*-1;
for n = 1:size(Delay500, 2)
    ToneTime(n,1:length(Delay500(n).BRTt)) = [Delay500(n).MouseTrialStructBRTt.ToneTime];
end

clear RT
clear RSE
clear Rp
clear RotHist
clear LickHistogram
clear RotHistEdges
clear LickHistEdges
TrialWindow = 170;
c = 0;
while c <= floor(length(RTmat)/TrialWindow) - 1
    thisWindow = RTmat(:,c*TrialWindow+1:(c+1)*TrialWindow);
    for n = size(thisWindow, 1):-1:1
        if any(thisWindow(n,:) == -1)
            thisWindow(n,:) = [];
        end
    end
    Rp(c+1) = sum([thisWindow] < delay + .1, 'all')/(size(thisWindow, 1) * size(thisWindow, 2));
    thisWindow = thisWindow(~isinf([thisWindow]));
    thisWindow = thisWindow(~isnan([thisWindow]));
    RT(c+1) = nanmean([thisWindow], 'all');
    RSE(c+1) = nanstd([thisWindow])/sqrt(sum(logical(thisWindow)));
    thisWindow = ToneTime(:,c*TrialWindow+1:(c+1)*TrialWindow);
    Trigger = reshape(thisWindow, [size(thisWindow, 1) * size(thisWindow,2), 1]);
    Trigger = Trigger(Trigger ~= -1);
    if length(AllRunningData(:,1) > 3)
    [RotHist(c+1,:), RotHistEdges, ~] = RunSpeedHistLines(Trigger, [AllRunningData(:,1)].', [AllRunningData(:,2)].', -.5, 1.5);
    else
        RotHist(c+1,:) = [];
    end
    [LickHistogram(c+1,:), LickHistEdges] = LickHist(Trigger, AllLicks, [-.5 1.5], .1, 'k', 0);
    c = c+1;
end

colors = parula(size(RotHist, 1));
figure
nexttile
hold on
for n = 1:size(RotHist, 1)
    plot(RotHistEdges, RotHist(n,:), 'Color', colors(n,:))
end
legend;
legend('boxoff');
xlim([-.5 1.5]);
FigureWrap(NaN, 'rotatry_over_time', NaN, NaN, NaN, NaN, NaN, NaN);

colors = parula(size(RotHist, 1));
figure
nexttile
hold on
for n = 1:size(LickHistogram, 1)
    plot(LickHistEdges(1:end-1), LickHistogram(n,:), 'Color', colors(n,:))
end
legend;
legend('boxoff');
xlim([-.5 1.5]);
FigureWrap(NaN, 'licking_over_time', NaN, NaN, NaN, NaN, NaN, NaN);

figure
for n = 1:size(LickHistogram, 1)
    nexttile
    hold on
    plot(RotHistEdges, RotHist(n,:), 'k')
    plot(LickHistEdges(1:end-1), LickHistogram(n,:), 'Color', colors(n,:))
    xlim([-.5 1.5]);
    FormatFigure(NaN, NaN)
end
FigureWrap(NaN, 'licking_over_time', NaN, NaN, NaN, NaN, 15, 2.2);




figure
nexttile
hold on
shadedErrorBar2([1:TrialWindow:length(RT)*TrialWindow], RT, RSE, 'LineProp', {'k'});
% plot([1:TrialWindow:length(RT)*TrialWindow], RT);
yline(.5, 'c');
ylim([0 3]);
ylabel('reaction time (s)');
xlabel('paired trials');
FormatFigure(NaN, NaN);
nexttile
hold on
plot([1:TrialWindow:length(RT)*TrialWindow], Rp, 'k');
ylim([0 1]);
ylabel('% prediction');
xlabel('paired trials');
FigureWrap(NaN, 'all_mice_learning', NaN, NaN, NaN, NaN, 2.5, 2);



