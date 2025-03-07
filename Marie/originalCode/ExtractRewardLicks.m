function [RewardLickOnset, RewardEpochOnset] = ExtractRewardLicks(TrialStructAdjRTt, LickOnsets, LickEpochOnsets)
%AllLicks and LickOnsets are from Meta Lick. All Licks is all licks, Lick
%onsets is all licks that occur after a threshold of no licking. Recommend
%using LickEpochOnsets, only onsets that begin a bout of three or more
%licks, as this will ensure return is relatively reward-free, though might
%miss some reward-free onsets.

RewardLickOnset = [];
for i =2:length(TrialStructAdjRTt)-1
    if ~strcmp(TrialStructAdjRTt(i).TrialType, 't')
        LickOnsetsAfterJuice = LickOnsets(LickOnsets > TrialStructAdjRTt(i).FictiveTone);
        if length(LickOnsetsAfterJuice)>1
            LickOnsetsAfterJuice = LickOnsetsAfterJuice(1);
        end
        if LickOnsetsAfterJuice < TrialStructAdjRTt(i+1).FictiveTone
                RewardLickOnset = [RewardLickOnset; LickOnsetsAfterJuice];
        end
    end
    
end

RewardEpochOnset = [];
for i =2:length(TrialStructAdjRTt)-1
    if ~strcmp(TrialStructAdjRTt(i).TrialType, 't')
        LickEpochOnsetsAfterJuice = LickEpochOnsets(LickEpochOnsets > TrialStructAdjRTt(i).FictiveTone);
        if length(LickEpochOnsetsAfterJuice)>1
            LickEpochOnsetsAfterJuice = LickEpochOnsetsAfterJuice(1);
        end
        if LickEpochOnsetsAfterJuice < TrialStructAdjRTt(i+1).FictiveTone
                RewardEpochOnset = [RewardEpochOnset; LickEpochOnsetsAfterJuice];
        end
    end 
end

end
