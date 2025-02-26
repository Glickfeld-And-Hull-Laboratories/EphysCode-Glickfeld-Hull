%see below for more

for n = 1:length(GoodUnitStructSorted)
[FR, WF, wfStructStruct] = CellCharWorkupDrugStruct(GoodUnitStructSorted(n).unitID, AllUnitStruct, LaserStimAdj, TimeGridA, TimeGridB, -.05, .05, -.05, .05, [0 1020], [4800 inf], DrugLinesStruct, [0 .075], .001, 'k', 'trash', NaN, NaN, NaN, NaN, MEH_chanMap);
wfStructStruct.TGTimeLim1FR = FR;
ImmBlockVsLateBlock_MasterWFstruct_1000wf(n) = wfStructStruct;
close all
end

for n = 1:length(MLI_laser)
[FR, WF, wfStructStruct] = CellCharWorkupDrugStruct(MLI_laser(n), AllUnitStruct, LaserStimAdj, TimeGridA, TimeGridB, -.1, .1, -.05, .05, [0 inf], [NaN NaN], DrugLinesStruct, [0 .075], .001, 'k', 'trash', NaN, NaN, NaN, NaN, MEH_chanMap);
wfStructStruct.TGTimeLim1FR = FR;
MasterWFstruct_MLI_1000(n) = wfStructStruct;
close all
end

for n = 1:length(DEhandID)
ImmBlockVsLateBlock_MasterWFstruct_MF_beyondDrug(n).handID = 'MF_beyondDrug';
end


for n = 1:length(SummaryStruct)
SummaryStruct(n).BiggestWFstruct = BestWFfinderPlotter2(SummaryStruct(n), 0);
end
for n = 1:length(SummaryStruct)
WF = SummaryStruct(n).BiggestWFstruct.WF;
[~ ,MAXi] = max(WF);
[~, MINi] = min(WF);
if MAXi < MINi
WF = -WF;
end
[~, mini] = min(WF);
if mini <20 || mini > 40
fprint('error error error')
else
WFaligned = WF(mini-20:mini+50); %minimum of normalized waveform is at index 21
end
SummaryStruct(n).BiggestWFstruct.alignedWF = WFaligned;
end


counter = 1;
for n = 1:length(MLI_laser)
SummaryStruct(counter).handID = 'MLI';
[FR, channel, TimeLim1, wfStructStruct, Nisi, edgesISI, Nacg, edgesACG] = ACGandWFTL(MLI_laser(n), AllUnitStruct, NaN, TimeGridB, -.1, .1, [0 .1], [0 LaserStimAdj(1)], .001, 'k', 'baselineACGWF', MEH_chanMap, 1);
SummaryStruct(counter).unit = MLI_laser(n);
SummaryStruct(counter).channel = channel;
SummaryStruct(counter).FR = FR;
SummaryStruct(counter).wfStructStruct = wfStructStruct.TGlim1WFs;
SummaryStruct(counter).TimeLimit = TimeLim1;
SummaryStruct(counter).Nisi = Nisi;
SummaryStruct(counter).edgesISI = edgesISI;
SummaryStruct(counter).Nacg= Nacg;
SummaryStruct(counter).edgesACG = edgesACG;
SummaryStruct(counter).recordingID = 'Z:\All_Staff\home\marie\NeuropixelsAnalysis\ckitAi40\1658\1658_220801_g2\1658_220801_g2_loccar1_2\1658_220801_g2_Filtered';
SummaryStruct(counter).LaserStimAdj = LaserStimAdj;
SummaryStruct(counter).DrugLinesStruct = DrugLinesStruct;
index = find([AllUnitStructSorted.unitID] == MLI_laser(n));
SummaryStruct(counter).timestamps = AllUnitStructSorted(index).timestamps;
counter = counter + 1;
end


for n = 1:length(DEmli)
SummaryStruct(counter).handID = 'DEmli';
[FR, channel, TimeLim1, wfStructStruct, Nisi, edgesISI, Nacg, edgesACG] = ACGandWFTL(DEmli(n), AllUnitStruct, NaN, TimeGridB, -.05, .05, [0 .1], [0 LaserStimAdj(1)], .001, 'k', 'baselineACGWF', MEH_chanMap, 1);
SummaryStruct(counter).unit = DEmli(n);
SummaryStruct(counter).channel = channel;
SummaryStruct(counter).FR = FR;
SummaryStruct(counter).wfStructStruct = wfStructStruct.TGlim1WFs;
SummaryStruct(counter).TimeLimit = TimeLim1;
SummaryStruct(counter).Nisi = Nisi;
SummaryStruct(counter).edgesISI = edgesISI;
SummaryStruct(counter).Nacg= Nacg;
SummaryStruct(counter).edgesACG = edgesACG;
SummaryStruct(counter).recordingID = 'Z:\All_Staff\home\marie\NeuropixelsAnalysis\ckitAi40\1658\1658_220801_g2\1658_220801_g2_loccar1_2\1658_220801_g2_Filtered';
SummaryStruct(counter).LaserStimAdj = LaserStimAdj;
SummaryStruct(counter).DrugLinesStruct = DrugLinesStruct;
index = find([GoodUnitStructSorted.unitID] == DEmli(n));
SummaryStruct(counter).timestamps = GoodUnitStructSorted(index).timestamps;
counter = counter + 1;
end

counter = 1;
for n = 1:length([PCstruct.SS])
SummaryStruct(counter).handID = 'PCpause';
[FR, channel, TimeLim1, wfStructStruct, Nisi, edgesISI, Nacg, edgesACG] = ACGandWFTL(PCstruct(n).SS, AllUnitStruct, NaN, TimeGridB, -.05, .05, [0 .1], [0 LaserStimAdj(1)], .001, 'k', 'baselineACGWF_PC', MEH_chanMap, 1);
SummaryStruct(counter).unit = PCstruct(n).SS;
SummaryStruct(counter).channel = channel;
SummaryStruct(counter).FR = FR;
SummaryStruct(counter).wfStructStruct = wfStructStruct.TGlim1WFs;
SummaryStruct(counter).TimeLimit = TimeLim1;
SummaryStruct(counter).Nisi = Nisi;
SummaryStruct(counter).edgesISI = edgesISI;
SummaryStruct(counter).Nacg= Nacg;
SummaryStruct(counter).edgesACG = edgesACG;
SummaryStruct(counter).recordingID = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\NeuropixelsAnalysis\DH\DH12\DH12_21_12_01\NewDH12_loccar1_2\DH12_21_12_01_g1_Filtered';
SummaryStruct(counter).LaserStimAdj = LaserStimAdj;
SummaryStruct(counter).DrugLinesStruct = DrugLinesStruct;
index = find([AllUnitStructSorted.unitID] == PCstruct(n).SS);
SummaryStruct(counter).timestamps = AllUnitStructSorted(index).timestamps;
counter = counter + 1;
end







for n = 1:length(SummaryStruct)
SummaryStruct(n).NormBiggestAligned = [SummaryStruct(n).BiggestWFstruct.NormBiggestAligned];
TF = islocalmax(SummaryStruct(n).NormBiggestAligned, 'MinProminence', 1);
maxi = 19+find(TF(20:end),1); %because they are aligned to trough at index = 20;
MAX = SummaryStruct(n).NormBiggestAligned(maxi);
%[MAX, maxi] = max(SummaryStruct(n).NormBiggestAligned);
[MIN, mini] = min(SummaryStruct(n).NormBiggestAligned);
SummaryStruct(n).WFh = MAX-MIN;
SummaryStruct(n).WFw = maxi-mini;
end



for n = 1:length(SummaryStruct)

[MAX, maxi] = max(SummaryStruct(n).NormBiggestAligned);
[MIN, mini] = min(SummaryStruct(n).NormBiggestAligned);
SummaryStruct(n).WFh_old = MAX-MIN;
SummaryStruct(n).WFw_old = maxi-mini;
end
