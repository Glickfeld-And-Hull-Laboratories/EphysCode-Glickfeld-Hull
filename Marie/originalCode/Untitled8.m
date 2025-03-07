
JuiceTimes_folder = dir('*nidq.XD_2_1_0.txt');
fid = fopen(JuiceTimes_folder(1).name);
JuiceTimes = fscanf(fid, '%f');
fclose(fid);
ToneTimes_folder = dir('*nidq.XD_2_3_0.txt');
fid = fopen(ToneTimes_folder(1).name);
ToneTimes = fscanf(fid, '%f');
fclose(fid);

addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\originalCode'));
addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\Kilosort\Kilosort2-noCAR'));

[TrialStruct, JuiceAlone, ToneAlone, JuiceAfterTone, ToneBeforeJuice, FictiveJuice] = JuiceToneCreateTrialSt(JuiceTimes, ToneTimes);

FindLickLevels(JuiceTimes, 3, 5, 20, .8);
[AllLicks, LickDetectParams, AllLickDurations] = FindAllLicks(TrialStruct(1).FictiveJuice - 30, TrialStruct(end).FictiveJuice + 30, .7, .9);
figure
histogram(AllLickDurations, [0:.01:4]);
GroomTimeGridA = AllLicks(AllLickDurations >.2);
AllDurs_Groom = AllLickDurations(AllLickDurations >.2);
GroomTimeGridB = GroomTimeGridA + AllDurs_Groom;
AllLicks_noGroom = AllLicks(AllLickDurations <.2);
AllLickDurations_trim = AllLickDurations(AllLickDurations <.2);

figure
RasterMatrix = OrganizeRasterEvents(ToneTimes, AllLicks_noGroom, 5, 5, 'k');
FigureWrap('Lick Raster', 'Lick_Raster', 'time from tone', 'trial', NaN, NaN, NaN, NaN);
figure
RasterMatrix = OrganizeRasterEvents(JuiceAlone, AllLicks_noGroom, 5, 5, 'k');
FigureWrap('Lick Raster', 'Lick_Raster_juice_Alone', 'time from juice alone', 'trial', [-5 5], NaN, NaN, NaN);
figure
RasterMatrix = OrganizeRasterEvents(ToneAlone, AllLicks_noGroom, 5, 5, 'k');
FigureWrap('Lick Raster', 'Lick_Raster_Tone_Alone', 'time from tone alone', 'trial', [-5 5], NaN, NaN, NaN);
figure
RasterMatrix = OrganizeRasterEvents(ToneBeforeJuice, AllLicks, 5, 5, 'k');
FigureWrap('Lick Raster', 'Lick_Raster_ToneBeforeJuice', 'time from ToneBeforeJuice', 'trial', [-5 5], NaN, NaN, NaN);

%TrialLicks = FindLicksTrialStruct(TrialStruct, .5, .7);

save AllLicks.txt AllLicks_noGroom -ascii -double

%%%% this is command for CatGT
cd C:\Program Files\TPrimeWinApp\TPrime-win
TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240221_day7_waterWithClick_g0\1693_240221_day7_waterWithClick_g0_tcat.imec0.ap.SY_384_6_500.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240221_day7_waterWithClick_g0\1693_240221_day7_waterWithClick_g0_tcat.nidq.XD_2_0_0.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240221_day7_waterWithClick_g0\1693_240221_day7_waterWithClick_g0_tcat.nidq.XD_2_1_0.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240221_day7_waterWithClick_g0\JuiceTimesAdj.txt
TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240221_day7_waterWithClick_g0\1693_240221_day7_waterWithClick_g0_tcat.imec0.ap.SY_384_6_500.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240221_day7_waterWithClick_g0\1693_240221_day7_waterWithClick_g0_tcat.nidq.XD_2_0_0.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240221_day7_waterWithClick_g0\1693_240221_day7_waterWithClick_g0_tcat.nidq.XD_2_3_0.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240221_day7_waterWithClick_g0\ToneTimesAdj.txt

TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240221_day7_waterWithClick_g0\1693_240221_day7_waterWithClick_g0_tcat.imec0.ap.SY_384_6_500.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240221_day7_waterWithClick_g0\1693_240221_day7_waterWithClick_g0_tcat.nidq.XD_2_0_0.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240221_day7_waterWithClick_g0\AllLicks.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240221_day7_waterWithClick_g0\AllLicksAdj.txt
% TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240207_day1_g1\1693_240207_day1_g1_tcat.imec0.ap.SY_384_6_500.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240207_day1_g1\1693_240207_day1_g1_tcat.nidq.XD_2_0_0.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240207_day1_g1\GroomTimeGridA.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240207_day1_g1\GroomTimeGridAAdj.txt
% TPrime -syncperiod=1.000000 -tostream=Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240207_day1_g1\1693_240207_day1_g1_tcat.imec0.ap.SY_384_6_500.txt -fromstream=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240207_day1_g1\1693_240207_day1_g1_tcat.nidq.XD_2_0_0.txt -events=1,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240207_day1_g1\GroomTimeGridB.txt,Z:\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240207_day1_g1\GroomTimeGridBAdj.txt

%%%%%%%

fid = fopen('JuiceTimesAdj.txt');
JuiceTimesAdj = fscanf(fid, '%f');
fclose(fid);
fid = fopen('ToneTimesAdj.txt');
ToneTimesAdj = fscanf(fid, '%f');
fclose(fid);
fid = fopen('AllLicksAdj.txt');
AllLicksAdj = fscanf(fid, '%f');
fclose(fid);
% fid = fopen('GroomTimeGridAAdj.txt');
% GroomTimeAAdj = fscanf(fid, '%f');
% fclose(fid);
% fid = fopen('GroomTimeGridBAdj.txt');
% GroomTimeBAdj = fscanf(fid, '%f');
% fclose(fid);


[TrialStructAdj, JuiceAloneAdj, ToneAloneAdj, JuiceAfterToneAdj, ToneBeforeJuiceAdj, FictiveJuiceAdj] = JuiceToneCreateTrialSt(JuiceTimesAdj, ToneTimesAdj);

% [FirstJuiceLicksAdj, FirstJuiceEpochsAdj] = ExtractFirstJuice3(TrialStructAdj, AllLicksAdj); %these define licking epochs as 1 lick
% [NoJuiceLicksAdj, NoJuiceEpochsAdj] = ExtractNoJuice(TrialStructAdj, AllLicksAdj); %these define licking epochs as 1 lick
% LickOnsetsAdj = FindLickingEpochs(AllLicksAdj, 1, .21); %defines licking epochs as 1 lick
% EpochOnsetsAdj = FindLickingEpochs(AllLicksAdj, 3, .21); %defines licking epochs as 1 lick
[LickOnsets, ~, ~] = FindLickOnsets_epochs(AllLicksAdj, 0.5, .21, 1);
[EpochOnsets, LickSecond, LickThird] = FindLickOnsets_epochs(AllLicksAdj, 0.5, .21, 3);



[AllUnitStruct, GoodUnitStruct, MultiUnitStruct, GoodANDmuaStruct] = ImportKSdataPhyllum();

GoodUnitStructSorted = SortStruct(GoodUnitStruct, 'channel', 'descend');
GoodANDmuaStructSorted = SortStruct(GoodANDmuaStruct, 'channel', 'descend');
AllUnitStructSorted = SortStruct(AllUnitStruct, 'channel', 'descend');
load MEH_chanMap


figure
RasterMatrix = OrganizeRasterEvents(JuiceAfterToneAdj(), AllLicksAdj, 2, 3, 'c');
figure
GeneralHist(JuiceTimesAdj, AllLicksAdj, -2, 3, .05, 'c', 1, 1);
hold on
GeneralHist(ToneAloneAdj+ .682, AllLicksAdj, -2, 3, .05, 'g', 1, 1);

%TrialStructAdj = SummaryStruct(n).TrialStructAdj; %??
J = [TrialStructAdj.TrialType].' == 'j';
T = [TrialStructAdj.TrialType].' == 't';
B = [TrialStructAdj.TrialType].' == 'b';

Temp = [TrialStructAdj.JuiceTime].';
JuiceAloneAdj = Temp(J);
JuiceAfterToneAdj = Temp(B);

Temp = [TrialStructAdj.ToneTime].';
ToneAloneAdj = Temp(T);
ToneBeforeJuiceAdj = Temp(B);
% 
% OneUnitHistStructTimeLimLineINDEX(JuiceAfterToneAdj, GoodUnitStruct(1).unitID, AllUnitStruct, -2, 3, .05, [0 inf], 4, 'k', NaN, 1, 0);
% %etc
% ToneAloneFJ = ToneAloneAdj + .683;
% EventStruct(1).ts = JuiceAloneAdj;
% EventStruct(1).Name = 'JuiceAloneAdj';
% EventStruct(1).Color = 'b';
% EventStruct(2).ts = JuiceAfterToneAdj;
% EventStruct(2).Name = 'JuiceAfterToneAdj';
% EventStruct(2).Color = 'k';
% EventStruct(3).ts = ToneAloneFJ;
% EventStruct(3).Name = 'ToneAloneFJ';
% EventStruct(3).Color = 'g';
% EventStruct(4).ts = EpochOnsetsAdj;
% EventStruct(4).Name = 'EpochOnsetsAdj';
% EventStruct(4).Color = 'm';
% EventStruct(5).ts = NoJuiceEpochsAdj;
% EventStruct(5).Name = 'NoJuiceEpochAdj';
% EventStruct(5).Color = 'r';
% EventStruct(6).ts = FirstJuiceEpochsAdj;
% EventStruct(6).Name = 'FirstJuiceEpochAdj';
% EventStruct(6).Color = 'c';

%[RTsOneSec, JuiceLicks] =findRT(JuiceLicks);
%AllLicks = MakeAllLicks(JuiceLicks);
%NoJuice = ExtractNoJuice(JuiceLicks);

[TrialStructRTt, TrialStructSortedt] = RTtone(TrialStruct, AllLicks_noGroom, .5);
[TrialStructRTtAdj, TrialStructSortedtAdj] = RTtone(TrialStructAdj, AllLicksAdj, .5);

% BehaviorOutcomesStruct = BehaviorOutcomes(TrialStructRTtAdj, .2, 3, 5, 1693); %(TrialStructRTt, minRT, maxRT, TrainingDay, animal)

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



FirstJuice = ExtractFirstJuice(JuiceLicks);
save FirstLicksEpochs.txt FirstLicksEpochs -ascii -double
save AllLicks.txt AllLicks -ascii -double
save RTsOneSec.txt RTsOneSec -ascii -double
save NoJuice.txt NoJuice -ascii -double
save FirstJuice.txt FirstJuice -ascii -double
save JuiceAlone.txt JuiceAlone -ascii -double
save JuiceAfterTone.txt JuiceAfterTone -ascii -double



%[TrialStructRTt, TrialStructSortedt] = RTtone(TrialStruct, AllLicks, .5);
figure
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
FigureWrap('RTt scatter', 'RTt_scatter', 'trial', 'reaction time" from cue', NaN, NaN, NaN, NaN);
% 
% %FIX THIS BEFORE RUNNING!!
% TrainingData_1693(6).AllLicks = AllLicksAdj;
% TrainingData_1693(6).LickDetectParams = LickDetectParams;
% TrainingData_1693(6).TrialStruct = TrialStructAdj;
% TrainingData_1693(6).loc = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\NeuropixelsAnalysis\AuditoryDay1\1693\1693_240207_day1_g1';
% %check before saving!!
% save TrainingData_1693 TrainingData_1693
% %add to TrainingData
% TrainingData(1).animal = 1693;
% TrainingData(1).day1 = TrainingData_1693(1);
% TrainingData(1).day2 = TrainingData_1693(2);
% TrainingData(1).day3 = TrainingData_1693(3);
% TrainingData(1).day4 = TrainingData_1693(4);
% TrainingData(1).day5 = TrainingData_1693(5);
% TrainingData(1).day6 = TrainingData_1693(6);
% 
% %g = mouse
% %p = day/field
% F1 = fieldnames(TrainingData);
% for g = 1:length(TrainingData)
%     if ~isempty(TrainingData(g))
%         TempCell = struct2cell(TrainingData(g));
%     end
%     for p = 2:length(TempCell)
%         if ~isempty(TempCell{p})
%             TempTrialStruct = TempCell{p}.TrialStruct;
%             [TrainingData(g).(F1{p}).TrialStruct, ~] = RTtone(TempTrialStruct, TempCell{p}.AllLicks, .5);
%             TrainingData(g).(F1{p}).LickOnsets = FindLickOnsets([TempCell{p}.AllLicks], .5);
%             RTs = [TrainingData(g).(F1{p}).TrialStruct.RTt];
%             RTs(isinf(RTs) | isnan(RTs)) = [];
%             TrainingData(g).(F1{p}).meanRT = nanmean(RTs);
%             TrainingData(g).(F1{p}).sterrRT = std(RTs)/sqrt(length(RTs));
%     counterP = 1;
%     counterR = 1;
%     counterO = 1;
%     LickOnsetPred = [];
%     LickOnsetReact = [];
%     LickOnsetOutside =[];
%     for n = 1:length(TrainingData(g).(F1{p}).LickOnsets)
%         for k = 1:length(TrainingData(g).(F1{p}).TrialStruct)
%             if strcmp({TrainingData(g).(F1{p}).TrialStruct(k).TrialType}, 'b')
%                 if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).ToneTime + .15)
%                     if TrainingData(g).(F1{p}).LickOnsets(n) <= (TrainingData(g).(F1{p}).TrialStruct(k).ToneTime + .68 +.15)
%                         LickOnsetPred(counterP).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
%                         LickOnsetPred(counterP).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).ToneTime;
%                         counterP = counterP + 1;
%                     end
%                     if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).ToneTime + .68+.15)
%                         if TrainingData(g).(F1{p}).LickOnsets(n) <= (TrainingData(g).(F1{p}).TrialStruct(k).ToneTime + .88 + .68)
%                             LickOnsetReact(counterR).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
%                             LickOnsetReact(counterR).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).ToneTime;
%                             counterR = counterR +1;
%                         end
%                     end
%                     if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).ToneTime + .88 + .68)
%                         if k < length(TrainingData(g).(F1{p}).TrialStruct)
%                             if TrainingData(g).(F1{p}).LickOnsets(n) < (TrainingData(g).(F1{p}).TrialStruct(k+1).FictiveJuice - 1)
%                                 LickOnsetOutside(counterO).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
%                                 LickOnsetOutside(counterO).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).ToneTime;
%                                 counterO = counterO +1;
%                             end
%                         end
%                     end
%                 end
%             end
%         end
%     end
%     Num_b_trials = length(TrainingData(g).(F1{p}).TrialStruct(strcmp({TrainingData(g).(F1{p}).TrialStruct.TrialType}, 'b')))
%     TrainingData(g).(F1{p}).LickOnsetPred = LickOnsetPred;
%     TrainingData(g).(F1{p}).LickOnsetReact = LickOnsetReact;
%     TrainingData(g).(F1{p}).LickOnsetOutside = LickOnsetOutside;
%     TrainingData(g).(F1{p}).PredPerc = length(LickOnsetPred)/Num_b_trials;
%     TrainingData(g).(F1{p}).ReactPerc = length(LickOnsetReact)/Num_b_trials;
%     TrainingData(g).(F1{p}).MissPerc = (Num_b_trials-length(LickOnsetPred)-length(LickOnsetReact))/Num_b_trials;
%     
% end
%         end
%     end
% 
% 
% F1 = fieldnames(TrainingData);
% allRTs = cell(1,length(F1)-1);
% ballRTs = cell(1,length(F1)-1);
% counter_aRT = 1;
% for g = 1:length(TrainingData)
%     counter_mRT = 1;
% meanRT = [];
% sterrRT = [];
%     for p = 2:length(F1)
%         if ~isempty(TrainingData(g).(F1{p}))
%             if p == 2
%                 f = figure
%             end
%             meanRT(counter_mRT)= TrainingData(g).(F1{p}).meanRT;
%             sterrRT(counter_mRT) = TrainingData(g).(F1{p}).sterrRT;
%             PredPerc(counter_mRT) = TrainingData(g).(F1{p}).PredPerc;
%             ReactPerc(counter_mRT) = TrainingData(g).(F1{p}).ReactPerc;
%             MissPerc(counter_mRT) = TrainingData(g).(F1{p}).MissPerc;
%             counter_mRT = counter_mRT + 1;
%             RTs = [TrainingData(g).(F1{p}).TrialStruct.RTt];
%             bRTs = RTs(strcmp({TrainingData(g).(F1{p}).TrialStruct.TrialType}, 'b')); %only RTts on 'b' trials
%             RTs(isinf(RTs) | isnan(RTs)) = [];
%             bRTs(isinf(bRTs) | isnan(bRTs)) = [];
%             allRTs{:, p-1} = [allRTs{:, p-1}; RTs.'];
%             ballRTs{:, p-1} = [ballRTs{:, p-1}; bRTs.']; %both all RTs
%     nexttile % hist of lick times Naive
%     hold on
%     if ~isempty([TrainingData(g).(F1{p}).LickOnsetPred])
%     histogram ([TrainingData(g).(F1{p}).LickOnsetPred.TrialTime], [0:.05:45], 'FaceAlpha', .5)
%     end
%     if ~isempty([TrainingData(g).(F1{p}).LickOnsetReact])
%     histogram ([TrainingData(g).(F1{p}).LickOnsetReact.TrialTime], [0:.05:45], 'FaceAlpha', .5)
%     end
%     if ~isempty([TrainingData(g).(F1{p}).LickOnsetOutside])
%     histogram ([TrainingData(g).(F1{p}).LickOnsetOutside.TrialTime], [0:.05:45], 'FaceAlpha', .5)
%     end
%     xline(0, 'g');
%     xline(.682, 'c');
%     xlim([-1 5])
%     title([TrainingData(g).(F1{1}) ' ' F1{p}]);
%     title([F1{p}]);
%     xlabel('time from cue (s)');
%     ylabel('n lick onsets');
%     FormatFigure(NaN, NaN);
%    
%     if p == 2
%         legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'}, 'Location', 'westoutside')
%     legend('boxoff')
%     end
% %FigureWrap('Naive Mice', 'Trained_LickingResp', 'time from cue', 'n reactions', NaN, NaN);  
% end
%     end
% end
%  nexttile
%         hold on
%         plot(PredPerc);
%         plot(ReactPerc);
%         plot(MissPerc);
%         xlabel('day');
%         ylabel('liklihood of response type');
%         title('response type liklihood');
%         FormatFigure(NaN, NaN);
%    
%         nexttile 
%         errorbar(ballMeanRTs, ballStErrRTs)
%         xlabel('day');
%         ylabel('mean reaction time');
%         title('mean reaction time');
%         FormatFigure(NaN, NaN);
%         
% nexttile
% T = table(round(PredPerc.', 2), round(ReactPerc.', 2),  round(MissPerc.', 2), 'VariableNames', {'Pred'; 'React'; 'Miss'});
% % Get the table in string form.
% TString = evalc('disp(T)');
% % Use TeX Markup for bold formatting and underscores.
% TString = strrep(TString,'<strong>','\bf');
% TString = strrep(TString,'</strong>','\rm');
% TString = strrep(TString,'_','\_');
% % Get a fixed-width font.
% FixedWidth = get(0,'FixedWidthFontName');
% % Output the table using the annotation command.
% annotation(f,'Textbox','String',TString,'Interpreter','Tex','FontName',FixedWidth,'Units','Normalized','LineStyle', 'none', 'Position',[.67 0 .6 .25]);
% FigureWrap(NaN, [num2str(TrainingData(g).(F1{1})) '_' F1{p}], NaN, NaN, NaN, NaN, 7, 7);
% 
%       
%        
% 
% figure
% allMeanRTs = cellfun(@mean, allRTs);
% allStErrRTs = cellfun(@nanStErr, allRTs);
% errorbar(allMeanRTs, allStErrRTs)
% figure
% ballMeanRTs = cellfun(@mean, ballRTs);
% ballStErrRTs = cellfun(@nanStErr, ballRTs);
% errorbar(ballMeanRTs, ballStErrRTs)
% FigureWrap('meanRT Trained Animals bTrials', 'meanRT_trained_bTrials', 'training day', 'reaction time from cue', NaN, NaN, NaN, NaN);

close all
for n = 1:length(GoodUnitStructSorted)
if ~strcmp({GoodUnitStructSorted(n).layer}, 'GrC_layer') & ~strcmp({GoodUnitStructSorted(n).layer}, 'PC_GrC_interface')
    if GoodUnitStructSorted(n).FR > 3
        figure
        nexttile
        [N, edges] = OneUnitHistStructTimeLimLineINDEX(JuiceAfterToneAdj, n, GoodUnitStructSorted, -1.1, .5, .025, [0 inf], 4, 'k', NaN, 1, 0);
        hold on
        [N, edges] = OneUnitHistStructTimeLimLineINDEX(JuiceTimesAdj(125:end), n, GoodUnitStructSorted, -1.1, .5, .025, [0 inf], 4, 'm', NaN, 1, 0);
nexttile
        [N, edges] = OneUnitHistStructTimeLimLineINDEX(LickOnsets, n, GoodUnitStructSorted, -1.1, .5, .025, [0 inf], 4, 'k', NaN, 1, 0);
    end
end
end
