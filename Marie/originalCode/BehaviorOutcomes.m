function BehaviorOutcomesStruct = BehaviorOutcomes(TrialStructRTt, minRT, maxRT, TrainingDay, animal)
RTs = [TrialStructRTt.RTt];
MeanRTt = nanmean(RTs(minRT <RTs & RTs<maxRT));

MissRate = 1- length(RTs(minRT <RTs & RTs<maxRT))/length([TrialStructRTt.RTt]);

BehaviorOutcomesStruct.TrainingDay = TrainingDay;
BehaviorOutcomesStruct.TrialStruct = TrialStructRTt;
BehaviorOutcomesStruct.MeanRTt = MeanRTt;
BehaviorOutcomesStruct.MissRate = MissRate;
BehaviorOutcomesStruct.recordingID = pwd;
BehaviorOutcomesStruct.animal = animal;
BehaviorOutcomesStruct.MetaParams.minRT = minRT;
BehaviorOutcomesStruct.MetaParams.maxRT = maxRT;
end
