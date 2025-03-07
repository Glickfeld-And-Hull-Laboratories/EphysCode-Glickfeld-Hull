%see below for more

for n = 1:4
[FR, WF, wfStructStruct] = CellCharWorkupDrugStruct(GoodUnitStructSorted(n).unitID, AllUnitStruct, LaserStimAdj, TimeGridA, TimeGridB, -.05, .05, -.05, .05, [1560 1660], [5300 5800], DrugLinesStruct, [0 .075], .001, 'k', 'earlyVsBlockerEffect', NaN, NaN, NaN, NaN, MEH_chanMap);
wfStructStruct.TGTimeLim1FR = FR;
ImmBlockVsLateBlock_MasterWFstruct(n) = wfStructStruct;
close all
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
SummaryStruct(counter).handID = 'MLI_laser';
[FR, channel, TimeLim1, wfStructStruct, Nisi, edgesISI, Nacg, edgesACG] = ACGandWFTL(MLI_laser(n), AllUnitStruct, NaN, TimeGridB, -.05, .05, [0 .1], [0 LaserStimAdj(1)], .001, 'k', 'baselineACGWF', MEH_chanMap, 1);
SummaryStruct(counter).unit = MLI_laser(n);
SummaryStruct(counter).channel = channel;
SummaryStruct(counter).FR = FR;
SummaryStruct(counter).wfStructStruct = wfStructStruct.TGlim1WFs;
SummaryStruct(counter).TimeLimit = TimeLim1;
SummaryStruct(counter).Nisi = Nisi;
SummaryStruct(counter).edgesISI = edgesISI;
SummaryStruct(counter).Nacg= Nacg;
SummaryStruct(counter).edgesACG = edgesACG;
SummaryStruct(counter).recordingID = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\NeuropixelsAnalysis\DH12_21_12_01g2_KSsimilarityTesting\2.0usual_1_1000';
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
SummaryStruct(counter).recordingID = 'Z:\NeuropixelsAnalysis\ckitAi40\1658\1658_220731_g1\1658_220731_g1_loccar1_2\1658_220731_g1_Filtered';
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
