%TrainingData creation:
% JuiceTimes_folder = dir('*nidq.XD_2_1_0.txt');
% fid = fopen(JuiceTimes_folder(1).name);
% JuiceTimes = fscanf(fid, '%f');
% fclose(fid);
% ToneTimes_folder = dir('*nidq.XD_2_3_0.txt');
% fid = fopen(ToneTimes_folder(1).name);
% ToneTimes = fscanf(fid, '%f');
% fclose(fid);
% [TrialStruct, JuiceAlone, ToneAlone, JuiceAfterTone, ToneBeforeJuice, FictiveJuice] = JuiceToneCreateTrialSt(JuiceTimes, ToneTimes);
% FindLickLevels(JuiceTimes, 3, 5, 20, 1);
% [AllLicks, LickDetectParams] = FindAllLicks(TrialStruct(1).FictiveJuice - 30, TrialStruct(end).FictiveJuice, .8, 1);
% save AllLicks.txt AllLicks -ascii -double
% TrainingData(1).animal = '1690'
% TrainingData(9).day7.AllLicks = AllLicks;
% TrainingData(9).day7.LickDetectParams = LickDetectParams;
% TrainingData(9).day7.TrialStruct = TrialStruct;
% TrainingData(9).day7.loc = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\NeuropixelsAnalysis\AuditoryDayN\1667\230119_1667_g2.WorkspaceLicks.mat';
% 




%g = mouse
%p = day/field
F1 = fieldnames(TrainingData);
for g = 1:length(TrainingData)
    if ~isempty(TrainingData(g))
        TempCell = struct2cell(TrainingData(g));
    end
    for p = 2:length(TempCell)
        if ~isempty(TempCell{p})
            TempTrialStruct = TempCell{p}.TrialStruct;
            [TrainingData(g).(F1{p}).TrialStruct, ~] = RTtone(TempTrialStruct, TempCell{p}.AllLicks, .5);
            TrainingData(g).(F1{p}).LickOnsets = FindLickOnsets([TempCell{p}.AllLicks], .5);
            RTs = [TrainingData(g).(F1{p}).TrialStruct.RTt];
            RTs(isinf(RTs) | isnan(RTs)) = [];
            TrainingData(g).(F1{p}).meanRT = nanmean(RTs);
            TrainingData(g).(F1{p}).sterrRT = std(RTs)/sqrt(length(RTs));
    counterP = 1;
    counterR = 1;
    counterO = 1;
    LickOnsetPred = [];
    LickOnsetReact = [];
    LickOnsetOutside =[];
    for n = 1:length(TrainingData(g).(F1{p}).LickOnsets)
        for k = 1:length(TrainingData(g).(F1{p}).TrialStruct)
            if strcmp({TrainingData(g).(F1{p}).TrialStruct(k).TrialType}, 'b')
                if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).ToneTime + .15)
                    if TrainingData(g).(F1{p}).LickOnsets(n) <= (TrainingData(g).(F1{p}).TrialStruct(k).ToneTime + .68 +.15)
                        LickOnsetPred(counterP).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
                        LickOnsetPred(counterP).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).ToneTime;
                        counterP = counterP + 1;
                    end
                    if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).ToneTime + .68+.15)
                        if TrainingData(g).(F1{p}).LickOnsets(n) <= (TrainingData(g).(F1{p}).TrialStruct(k).ToneTime + .88 + .68)
                            LickOnsetReact(counterR).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
                            LickOnsetReact(counterR).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).ToneTime;
                            counterR = counterR +1;
                        end
                    end
                    if TrainingData(g).(F1{p}).LickOnsets(n) > (TrainingData(g).(F1{p}).TrialStruct(k).ToneTime + .88 + .68)
                        if k < length(TrainingData(g).(F1{p}).TrialStruct)
                            if TrainingData(g).(F1{p}).LickOnsets(n) < (TrainingData(g).(F1{p}).TrialStruct(k+1).FictiveJuice - 1)
                                LickOnsetOutside(counterO).RecordTime = TrainingData(g).(F1{p}).LickOnsets(n);
                                LickOnsetOutside(counterO).TrialTime = TrainingData(g).(F1{p}).LickOnsets(n)- TrainingData(g).(F1{p}).TrialStruct(k).ToneTime;
                                counterO = counterO +1;
                            end
                        end
                    end
                end
            end
        end
    end
    Num_b_trials = length(TrainingData(g).(F1{p}).TrialStruct(strcmp({TrainingData(g).(F1{p}).TrialStruct.TrialType}, 'b')))
    TrainingData(g).(F1{p}).LickOnsetPred = LickOnsetPred;
    TrainingData(g).(F1{p}).LickOnsetReact = LickOnsetReact;
    TrainingData(g).(F1{p}).LickOnsetOutside = LickOnsetOutside;
    TrainingData(g).(F1{p}).PredPerc = length(LickOnsetPred)/Num_b_trials;
    TrainingData(g).(F1{p}).ReactPerc = length(LickOnsetReact)/Num_b_trials;
    TrainingData(g).(F1{p}).MissPerc = (Num_b_trials-length(LickOnsetPred)-length(LickOnsetReact))/Num_b_trials;
    
end
        end
    end


F1 = fieldnames(TrainingData);
allRTs = cell(1,length(F1)-1);
counter_aRT = 1;
for g = 1:length(TrainingData)
    counter_mRT = 1;
meanRT = [];
sterrRT = [];
    for p = 2:length(F1)
        if ~isempty(TrainingData(g).(F1{p}))
            if p == 2
                figure
            end
            meanRT(counter_mRT)= TrainingData(g).(F1{p}).meanRT;
            sterrRT(counter_mRT) = TrainingData(g).(F1{p}).sterrRT;
            PredPerc(counter_mRT) = TrainingData(g).(F1{p}).PredPerc;
            ReactPerc(counter_mRT) = TrainingData(g).(F1{p}).ReactPerc;
            MissPerc(counter_mRT) = TrainingData(g).(F1{p}).MissPerc;
            counter_mRT = counter_mRT + 1;
            RTs = [TrainingData(g).(F1{p}).TrialStruct.RTt];
            RTs(isinf(RTs) | isnan(RTs)) = [];
            allRTs{:, p-1} = [allRTs{:, p-1}; RTs.'];
    nexttile % hist of lick times Naive
    hold on
    if ~isempty([TrainingData(g).(F1{p}).LickOnsetPred])
    histogram ([TrainingData(g).(F1{p}).LickOnsetPred.TrialTime], [0:.05:45], 'FaceAlpha', .5)
    end
    if ~isempty([TrainingData(g).(F1{p}).LickOnsetReact])
    histogram ([TrainingData(g).(F1{p}).LickOnsetReact.TrialTime], [0:.05:45], 'FaceAlpha', .5)
    end
    if ~isempty([TrainingData(g).(F1{p}).LickOnsetOutside])
    histogram ([TrainingData(g).(F1{p}).LickOnsetOutside.TrialTime], [0:.05:45], 'FaceAlpha', .5)
    end
    xline(0, 'g');
    xline(.682, 'c');
    xlim([-1 5])
    title([TrainingData(g).(F1{1}) ' ' F1{p}]);
    title([F1{p}]);
    xlabel('time from cue (s)');
    ylabel('n lick onsets');
   FormatFigure(NaN,NaN);
    if p == 2
        legend({'Predict'; 'React'; 'Outside Trial'; 'cue'; 'reward'}, 'Location', 'westoutside')
    legend('boxoff')
    end
%FigureWrap('Naive Mice', 'Trained_LickingResp', 'time from cue', 'n reactions', NaN, NaN);  

        end
    end
        nexttile 
        errorbar(meanRT, sterrRT)
        xlabel('day');
        ylabel('mean reaction time');
        title('mean reaction time');
        FormatFigure(NaN, NaN);
        nexttile
        hold on
        plot(PredPerc);
        plot(ReactPerc);
        plot(MissPerc);
        xlabel('day');
        ylabel('liklihood of response type');
        title('response type liklihood');
        FigureWrap(NaN, [TrainingData(g).(F1{1}) '_' F1{p}], NaN, NaN, NaN, NaN, 4, 7.5);
   
end
    figure
allMeanRTs = cellfun(@mean, allRTs);
allStErrRTs = cellfun(@nanStErr, allRTs);
errorbar(allMeanRTs, allStErrRTs)
FigureWrap('meanRT Trained Animals', 'meanRT_trained', 'training day', '"reaction time" from cue', NaN, NaN, NaN, NaN);
