            
                LickOnsets = FindLickOnsets(AllLicksAdj, .5);
%             RTs = [TrialStructRTtAdj.RTt];
%             RTs(isinf(RTs) | isnan(RTs)) = [];
%             TrainingData(g).(F1{p}).meanRT = nanmean(RTs);
%             TrainingData(g).(F1{p}).sterrRT = std(RTs)/sqrt(length(RTs));
    counterP = 1;
    counterR = 1;
    counterO = 1;
    LickOnsetPred = [];
    LickOnsetReact = [];
    LickOnsetOutside =[];
    for n = 1:length(LickOnsets)
        for k = 1:length(TrialStructRTtAdj)
             if strcmp({TrialStructRTtAdj(k).TrialType}, 'b')
                if LickOnsets(n) > (TrialStructRTtAdj(k).JuiceTime - .68 + .15)
                    if LickOnsets(n) <= (TrialStructRTtAdj(k).JuiceTime - .68 + .68 +.15)
                        LickOnsetPred(counterP).RecordTime = LickOnsets(n);
                        LickOnsetPred(counterP).TrialTime = LickOnsets(n)- (TrialStructRTtAdj(k).JuiceTime - .68);
                        counterP = counterP + 1;
                    end
                    if LickOnsets(n) > (TrialStructRTtAdj(k).JuiceTime - .68 + .68+.15)
                        if LickOnsets(n) <= (TrialStructRTtAdj(k).JuiceTime - .68 + .88 + .68)
                            LickOnsetReact(counterR).RecordTime = LickOnsets(n);
                            LickOnsetReact(counterR).TrialTime = LickOnsets(n)- (TrialStructRTtAdj(k).JuiceTime - .68);
                            counterR = counterR +1;
                        end
                    end
                    if LickOnsets(n) > (TrialStructRTtAdj(k).JuiceTime - .68 + .88 + .68)
                        if k < length(TrialStructRTtAdj)
                            if LickOnsets(n) < (TrialStructRTtAdj(k+1).FictiveJuice - 1)
                                LickOnsetOutside(counterO).RecordTime = LickOnsets(n);
                                LickOnsetOutside(counterO).TrialTime = LickOnsets(n)- (TrialStructRTtAdj(k).JuiceTime - .68);
                                counterO = counterO +1;
                            end
                        end
                    end
                end
            end
        end
    end
LickOnsetPred = LickOnsetPred;
LickOnsetReact = LickOnsetReact;
LickOnsetOutside = LickOnsetOutside;
%%%%%%%%%%%%%repeat for ToneAlone
    counterP = 1;
    counterR = 1;
    counterO = 1;
    LickOnsetPred = [];
    LickOnsetReact = [];
    LickOnsetOutside =[];
    for n = 1:length(LickOnsets)
        for k = 1:length(TrialStructRTtAdj)
             if strcmp({TrialStructRTtAdj(k).TrialType}, 't')
                if LickOnsets(n) > (TrialStructRTtAdj(k).ToneTime + .15)
                    if LickOnsets(n) <= (TrialStructRTtAdj(k).ToneTime + .68 +.15)
                        LickOnsetPred(counterP).RecordTime = LickOnsets(n);
                        LickOnsetPred(counterP).TrialTime = LickOnsets(n)- TrialStructRTtAdj(k).ToneTime;
                        counterP = counterP + 1;
                    end
                    if LickOnsets(n) > (TrialStructRTtAdj(k).JuiceTime - .68 + .68+.15)
                        if LickOnsets(n) <= (TrialStructRTtAdj(k).JuiceTime - .68 + .88 + .68)
                            LickOnsetReact(counterR).RecordTime = LickOnsets(n);
                            LickOnsetReact(counterR).TrialTime = LickOnsets(n)- TrialStructRTtAdj(k).ToneTime;
                            counterR = counterR +1;
                        end
                    end
                    if LickOnsets(n) > (TrialStructRTtAdj(k).JuiceTime - .68 + .88 + .68)
                        if k < length(TrialStructRTtAdj)
                            if LickOnsets(n) < (TrialStructRTtAdj(k+1).FictiveJuice - 1)
                                LickOnsetOutside(counterO).RecordTime = LickOnsets(n);
                                LickOnsetOutside(counterO).TrialTime = LickOnsets(n)- TrialStructRTtAdj(k).ToneTime;
                                counterO = counterO +1;
                            end
                        end
                    end
                end
            end
        end
    end
  ToneAloneLickOnsetPred = LickOnsetPred;
  ToneAloneLickOnsetReact = LickOnsetReact;
  ToneAloneLickOnsetOutside = LickOnsetOutside;




                figure

    nexttile % hist of lick times Naive
    hold on

    histogram ([ToneAloneLickOnsetPred.TrialTime], [0:.05:5], 'FaceAlpha', .5)
    histogram ([ToneAloneLickOnsetReact.TrialTime], [0:.05:5], 'FaceAlpha', .5)
    histogram ([ToneAloneLickOnsetOutside.TrialTime], [0:.05:5], 'FaceAlpha', .5)

   