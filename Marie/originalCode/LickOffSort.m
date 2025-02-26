%function takes JuiceStruct, which has juice times and vectors of lick off
%times, and sorts it into different cicumstances of licking off.
function [LickOffCueReward, LickOffNocueReward, LickOffOutside] = LickOffSort(JuiceStruct)
a = 1;
b = 1;
LickOffNocueReward= [];
rewardtaken = 0;
for n = 1:115
    rewardtaken = 0;
    Jtime = [JuiceStruct.JuiceTimes(n)];
    if ~isnan(Jtime)
            licks = cell2mat([JuiceStruct.ChristieOff(n)]);
            for k = 1:length(licks)
                if (licks(k) < (Jtime ) && rewardtaken == 0) %if lick offset is happening before water, do nothing and check the next lick
                    LickOffOutside(a,1) = licks(k);
                    a = a + 1;
                elseif ((licks(k) > (Jtime)) && rewardtaken == 0) % if lick offset is after water and it's the first one after water
                    LickOffCueReward(b,1) = licks(k);
                    b = b+1;
                    rewardtaken = 1;
                elseif ((licks(k) > (Jtime)) && rewardtaken == 1) %if lick offset if after water and water has been taken before previous offset
                    LickOffOutside(a,1) = licks(k);
                    a = a + 1;
                end
                
            end
        
    end
end
for n = 116:138
    licks = [JuiceStruct.ChristieOn(n)];
    LickOffNocueReward = [LickOffNocueReward; cell2mat(licks).'];    
end
end