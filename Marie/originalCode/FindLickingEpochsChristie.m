function [LickOnLickOFF, JuiceLicksOFF, JuiceLicksON] = FindLickingEpochsChristie(AllLicks, JuiceTimes)
quietBaseline = 2;
ILI = [.1 .175];
c = 1;
for n =2:length(AllLicks)
    if AllLicks(n)-AllLicks(n-1) > quietBaseline
        if (AllLicks(n+2) - AllLicks(n)) < .4
            LickOn(c,1) = AllLicks(n);
            c = c+1;
            k = 1;
            while (AllLicks(n+2+k) - (AllLicks(n+1+k)) < .4)
                k = k+1;
            end
            if (AllLicks(n+2+k) - (AllLicks(n+1+k)) > .5)
            LickOff(c-1,1) = AllLicks(n+1+k);
            else
                LickOff(c-1,1) = NaN;
            end
        end
        
    end
end
LickOnLickOFF = [LickOn LickOff];
JuiceLicksOFF=OrganizeLicks(JuiceTimes, LickOff);
JuiceLicksON=OrganizeLicks(JuiceTimes, LickOn);
            
        
        
       