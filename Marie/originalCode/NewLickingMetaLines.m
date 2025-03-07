[JuiceLicks] = FindLicksNew(JuiceTimes, level1, level2); %pre-lick period is hard-coded in as 5;
AllLicks; %make list of all licks
[LickOnLickOFF, JuiceLicksOFF, JuiceLicksON] = FindLickingEpochsChristie(AllLicks, JuiceTimes); %use all licks to get lists of on and off for licking epochs
[LickOffCueReward, LickOffNocueReward, LickOffOutside] = LickOffSort(JuiceStruct);
[LickOnCueReward, LickOnNocueReward, LickOnOutside] = LickOnSort(JuiceStruct);
%timeAdj all lick lists
figure
hold on
for n = 1:length(Tester)
if ~isempty(Tester(n).CSpair) || ~isempty(Tester(n).PutSS)
LinePSTH(LickCueReward, Tester(n).unitID, Tester, -2, 8, .1, [0 inf], 'm', 1);
end
end