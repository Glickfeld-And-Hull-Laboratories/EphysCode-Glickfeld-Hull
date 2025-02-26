function [LickOnCueReward, LickOnNocueReward, LickOnOutside] = LickOnSort(JuiceStruct)
a = 1;
b = 1;
LickOnNocueReward= [];
for n = 1:115
    Jtime = [JuiceStruct.JuiceTimes(n)];
    if ~isnan(Jtime)
            licks = cell2mat([JuiceStruct.ChristieOn(n)]);
            for k = 1:length(licks)
                if licks(k) < (Jtime - 1) %if lick onset is happening more than 300 ms before tone
                LickOnOutside(a,1) = licks(k);
                a = a + 1;
                elseif ((licks(k) > (Jtime - .7)) && (licks(k) < Jtime)) % if lick onset is happening between tone and reward
                    LickOnCueReward(b,1) = licks(k);
                    b = b+1;
                end
                if (k >1 && (licks(k-1) > Jtime- .7)) %if reward has already been consumed
                    LickOnOutside(a) = licks(k);
                    a = a+1;
                end
            end
        
    end
end
for n = 116:138
    licks = [JuiceStruct.ChristieOn(n)];
    LickOnNocueReward = [LickOnNocueReward; cell2mat(licks).'];    
end
end