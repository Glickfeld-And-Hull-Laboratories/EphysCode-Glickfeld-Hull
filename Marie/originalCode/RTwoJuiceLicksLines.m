for n = 1:length(AllGoodUnitsLessThan3hz)
for k = 1:length(AllGoodUnitsLessThan3hz(n).JuiceTimesAdj)
tonetime = AllGoodUnitsLessThan3hz(n).JuiceTimesAdj(k) -.698;
licktimes = AllGoodUnitsLessThan3hz(n).AllLicksAdj(find(AllGoodUnitsLessThan3hz(n).AllLicksAdj > tonetime & AllGoodUnitsLessThan3hz(n).AllLicksAdj <= tonetime + 5));
if ~isempty(licktimes)
RT(k) = licktimes(1)-tonetime;
else
RT(k) = NaN;
end
end
AllGoodUnitsLessThan3hz(n).RTs = RT;
clear RT;
end


for n = 1:length(AllGoodUnitsLessThan3hz)
    counterR = 1;
    counterN = 1;
    LickInitReward = [];
    LickInitNoreward = [];
for k = 2:length(AllGoodUnitsLessThan3hz(n).AllLicksAdj)
    
if (AllGoodUnitsLessThan3hz(n).AllLicksAdj(k) - (AllGoodUnitsLessThan3hz(n).AllLicksAdj(k-1))) > 1
    JuiceTimeIndex = (find(AllGoodUnitsLessThan3hz(n).JuiceTimesAdj > AllGoodUnitsLessThan3hz(n).AllLicksAdj(k)-5 & AllGoodUnitsLessThan3hz(n).JuiceTimesAdj < AllGoodUnitsLessThan3hz(n).AllLicksAdj(k)+5));
    if length(JuiceTimeIndex) > 1
        fprintf(['error in n = ' num2str(n) ' near time ' num2str(AllGoodUnitsLessThan3hz(n).AllLicksAdj(k)) '\n'])
        JuiceTimeIndex = JuiceTimeIndex(1);
    end
    JuiceTime = AllGoodUnitsLessThan3hz(n).JuiceTimesAdj(JuiceTimeIndex);
        if (AllGoodUnitsLessThan3hz(n).AllLicksAdj(k) >= JuiceTime & AllGoodUnitsLessThan3hz(n).AllLicksAdj(k-1) < JuiceTime)
    LickInitReward(counterR) = (AllGoodUnitsLessThan3hz(n).AllLicksAdj(k));
    counterR = counterR + 1;
    elseif AllGoodUnitsLessThan3hz(n).AllLicksAdj(k) < JuiceTime
        if JuiceTimeIndex > 1 & find(AllGoodUnitsLessThan3hz(n).AllLicksAdj > AllGoodUnitsLessThan3hz(n).JuiceTimesAdj(JuiceTimeIndex-1))
        LickInitNoreward(counterN) = (AllGoodUnitsLessThan3hz(n).AllLicksAdj(k));
        counterN = counterN +1;
        end
    end
end
end
 AllGoodUnitsLessThan3hz(n).LickInitReward = LickInitReward;
 AllGoodUnitsLessThan3hz(n).LickInitNoreward = LickInitNoreward;
clear LickInitReward LickInitNoreward
end

counterIDn = 1;
UniqueRecordingIndex = [1];
AllGoodUnitsLessThan3hz(1).recordingIDn = counterIDn;
for n = 2:length(AllGoodUnitsLessThan3hz)
    if strcmp(AllGoodUnitsLessThan3hz(n).recordingLabel, AllGoodUnitsLessThan3hz(n-1).recordingLabel)
        AllGoodUnitsLessThan3hz(n).recordingIDn = counterIDn;
    else
        counterIDn = counterIDn + 1;
        AllGoodUnitsLessThan3hz(n).recordingIDn = counterIDn;
        UniqueRecordingIndex(counterIDn) = n;
       
    end
end
       
        