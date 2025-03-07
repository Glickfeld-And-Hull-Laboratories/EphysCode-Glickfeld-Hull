function [NoJuiceLickOnset, NoJuiceEpochOnset] = ExtractNoJuice(TrialStructAdjRTt, LickOnsets, LickEpochOnsets)
%AllLicks and LickOnsets are from Meta Lick. All Licks is all licks, Lick
%onsets is all licks that occur after a threshold of no licking. Recommend
%using LickEpochOnsets, only onsets that begin a bout of three or more
%licks, as this will ensure return is relatively reward-free, though might
%miss some reward-free onsets.

NoJuiceLickOnset = [];
for i =2:length(TrialStructAdjRTt)-1
    if ~strcmp(TrialStructAdjRTt(i).TrialType, 't')
        LickOnsetsAfterJuice = LickOnsets(LickOnsets > TrialStructAdjRTt(i).JuiceTime);
        if length(LickOnsetsAfterJuice)>1
            LickOnsetsAfterJuice = LickOnsetsAfterJuice(2:end);
        end
        LicksOnsetsBetweenJuice = LickOnsetsAfterJuice(LickOnsetsAfterJuice < TrialStructAdjRTt(i+1).ToneTime);
        if ~isempty(LicksOnsetsBetweenJuice)
                NoJuiceLickOnset = [NoJuiceLickOnset; LicksOnsetsBetweenJuice];
        end
    end
    
end

NoJuiceEpochOnset = [];
for i =2:length(TrialStructAdjRTt)-1
    if ~strcmp(TrialStructAdjRTt(i).TrialType, 't')
        LickEpochOnsetsAfterJuice = LickEpochOnsets(LickEpochOnsets > TrialStructAdjRTt(i).JuiceTime);
        if length(LickEpochOnsetsAfterJuice)>1
            LickEpochOnsetsAfterJuice = LickEpochOnsetsAfterJuice(2:end);
        end
        LickEpochOnsetsBetweenJuice = LickEpochOnsetsAfterJuice(LickEpochOnsetsAfterJuice < TrialStructAdjRTt(i+1).ToneTime);
        if ~isempty(LickEpochOnsetsBetweenJuice)
                NoJuiceEpochOnset = [NoJuiceEpochOnset; LickEpochOnsetsBetweenJuice];
        end
    end 
end

end
