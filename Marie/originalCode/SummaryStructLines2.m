%see below for more

for n = 1:length(GoodUnitStructSorted)
[FR, WF, wfStructStruct] = CellCharWorkupDrugStruct(GoodUnitStructSorted(n).unitID, AllUnitStruct, LaserStimAdj, TimeGridA, TimeGridB, -.05, .05, -.05, .15, [0 DrugLinesStruct(1).time], [DrugLinesStruct(2).time DrugLinesStruct(4).time], DrugLinesStruct, [0 .075], .001, 'k', 'acsfVSgabazine', NaN, NaN, NaN, NaN, MEH_chanMap);
wfStructStruct.TGTimeLim1FR = FR;
acsfVSgabazine_MasterWFstruct(n) = wfStructStruct;
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
    if abs(max(WF)) > abs(min(WF))
    WF = -WF;
    end
end
[~, mini] = min(WF);
if mini <20 || mini > 40
    fprintf('error error error')
else
    WFaligned = WF(mini-20:mini+50); %minimum of normalized waveform is at index 21
end
SummaryStruct(n).BiggestWFstruct.alignedWF = WFaligned;
end


counter = 1;
for n = 1:length(PC_SS)
SummaryStruct(counter).handID = 'SS';
[FR, channel, TimeLim1, wfStructStruct, Nisi, edgesISI, Nacg, edgesACG] = ACGandWFTL(PC_SS(n).SS, AllUnitStruct, NaN, NaN, -.3, .3, [0 .1], [0 300], .001, 'k', 'baselineACGWF', MEH_chanMap, 1);
SummaryStruct(counter).unit = PC_SS(n).SS;
SummaryStruct(counter).channel = channel;
SummaryStruct(counter).FR = FR;
SummaryStruct(counter).wfStructStruct = wfStructStruct.TGlim1WFs;
SummaryStruct(counter).TimeLimit = TimeLim1;
SummaryStruct(counter).Nisi = Nisi;
SummaryStruct(counter).edgesISI = edgesISI;
SummaryStruct(counter).Nacg= Nacg;
SummaryStruct(counter).edgesACG = edgesACG;
SummaryStruct(counter).recordingID = 'Z:\NeuropixelsAnalysis\DH\ChR2_2022\1651\1651_22062_g0\loccar10_20_KS2.0nocarReal_1651_220628\1651_22062_g0_FirstOrderBW';
SummaryStruct(counter).LaserStimAdj = LaserStimAdj;
SummaryStruct(counter).DrugLinesStruct = DrugLinesStruct;
index = find([AllUnitStructSorted.unitID] == PC_SS(n).SS);
SummaryStruct(counter).timestamps = AllUnitStructSorted(index).timestamps;
counter = counter + 1;
end

for n = 1:length(SS_CS)
SummaryStruct(counter).handID = 'SSpause';
[FR, channel, TimeLim1, wfStructStruct, Nisi, edgesISI, Nacg, edgesACG] = ACGandWFTL(SS_CS(n).SS, AllUnitStruct, NaN, TimeGridB, -.1, .1, [0 .1], [0 LaserStimAdj(1)], .001, 'k', 'baselineACGWF', MEH_chanMap, 1);
SummaryStruct(counter).unit = SS_CS(n).SS;
SummaryStruct(counter).channel = channel;
SummaryStruct(counter).FR = FR;
SummaryStruct(counter).wfStructStruct = wfStructStruct.TGlim1WFs;
SummaryStruct(counter).TimeLimit = TimeLim1;
SummaryStruct(counter).Nisi = Nisi;
SummaryStruct(counter).edgesISI = edgesISI;
SummaryStruct(counter).Nacg= Nacg;
SummaryStruct(counter).edgesACG = edgesACG;
SummaryStruct(counter).recordingID = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\NeuropixelsAnalysis\DH\ChR2_2022\1652\1652_220718a_g2\r1652_220718a_g2_NoCarForReal_Loccar1_2\1652_220718a_g2_FirstOrderBW';
SummaryStruct(counter).LaserStimAdj = LaserStimAdj;
SummaryStruct(counter).DrugLinesStruct = DrugLinesStruct;
index = find([AllUnitStructSorted.unitID] == SS_CS(n).SS);
SummaryStruct(counter).timestamps = AllUnitStructSorted(index).timestamps;
counter = counter + 1;
end


for n = 1:length(Golgi_layer)
SummaryStruct(counter).handID = 'Golgi_layer';
[FR, channel, TimeLim1, wfStructStruct, Nisi, edgesISI, Nacg, edgesACG] = ACGandWFTL(Golgi_layer(n), AllUnitStruct, NaN, TimeGridB, -.05, .05, [0 .1], [0 LaserStimAdj(1)], .001, 'k', 'baselineACGWF', MEH_chanMap, 1);
SummaryStruct(counter).unit = Golgi_layer(n);
SummaryStruct(counter).channel = channel;
SummaryStruct(counter).FR = FR;
SummaryStruct(counter).wfStructStruct = wfStructStruct.TGlim1WFs;
SummaryStruct(counter).TimeLimit = TimeLim1;
SummaryStruct(counter).Nisi = Nisi;
SummaryStruct(counter).edgesISI = edgesISI;
SummaryStruct(counter).Nacg= Nacg;
SummaryStruct(counter).edgesACG = edgesACG;
SummaryStruct(counter).recordingID = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\NeuropixelsAnalysis\DH\ChR2_2022\1652\1652_220718a_g2\r1652_220718a_g2_NoCarForReal_Loccar1_2\1652_220718a_g2_FirstOrderBW';
SummaryStruct(counter).LaserStimAdj = LaserStimAdj;
SummaryStruct(counter).DrugLinesStruct = DrugLinesStruct;
index = find([GoodUnitStructSorted.unitID] == Golgi_layer(n));
SummaryStruct(counter).timestamps = GoodUnitStructSorted(index).timestamps;
counter = counter + 1;
end

counter = 1;
for n = 1:length([PCstruct.SS])
SummaryStruct(counter).handID = 'PCpause';
[FR, channel, TimeLim1, wfStructStruct, Nisi, edgesISI, Nacg, edgesACG] = ACGandWFTL(PCstruct(n).SS, AllUnitStruct, NaN, TimeGridB, -.05, .05, [0 .1], [0 300], .001, 'k', 'baselineACGWF_PC', MEH_chanMap, 1);
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

counter = 1;
for n = 1:length(ExpertGolgi)
SummaryStructGolgi(counter).handID = 'expertGolgi';
[FR, channel, TimeLim1, wfStructStruct, Nisi, edgesISI, Nacg, edgesACG] = ACGandWFTL(ExpertGolgi(n), AllUnitStruct, NaN, TimeGridB, -.3, .3, [0 .1], [0 LaserStimAdj(1)], .001, 'k', 'baselineACGWF', MEH_chanMap, 1);
SummaryStructGolgi(counter).unit = ExpertGolgi(n);
SummaryStructGolgi(counter).channel = channel;
SummaryStructGolgi(counter).FR = FR;
SummaryStructGolgi(counter).wfStructStruct = wfStructStruct.TGlim1WFs;
SummaryStructGolgi(counter).TimeLimit = TimeLim1;
SummaryStructGolgi(counter).Nisi = Nisi;
SummaryStructGolgi(counter).edgesISI = edgesISI;
SummaryStructGolgi(counter).Nacg= Nacg;
SummaryStructGolgi(counter).edgesACG = edgesACG;
SummaryStructGolgi(counter).recordingID = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\marie\NeuropixelsAnalysis\DH\ChR2_2022\1651\1651_22062_g0\loccar10_20_KS2.0nocarReal_1651_220628\1651_220628_filter';
SummaryStructGolgi(counter).LaserStimAdj = LaserStimAdj;
SummaryStructGolgi(counter).DrugLinesStruct = DrugLinesStruct;
index = find([AllUnitStructSorted.unitID] == ExpertGolgi(n));
SummaryStructGolgi(counter).timestamps = AllUnitStructSorted(index).timestamps;
counter = counter + 1;
end


for n = 1:length(SummaryStructGolgi)
SummaryStructGolgi(n).BiggestWFstruct = BestWFfinderPlotter2(SummaryStructGolgi(n), 0);
end
for n = 1:length(SummaryStructGolgi)
WF = SummaryStructGolgi(n).BiggestWFstruct.WF;
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
SummaryStructGolgi(n).BiggestWFstruct.alignedWF = WFaligned;
end

counter = 1;
for n = 1:length(ExpertGolgi)
SummaryStructGolgi(counter).handID = 'expertGolgi';
[FR, channel, TimeLim1, wfStructStruct, Nisi, edgesISI, Nacg, edgesACG] = ACGandWFTL(ExpertGolgi(n), AllUnitStruct, NaN, TimeGridB, -.3, .3, [0 .1], [0 LaserStimAdj(1)], .001, 'k', 'baselineACGWF', MEH_chanMap, 1);
SummaryStructGolgi(counter).unit = ExpertGolgi(n);
SummaryStructGolgi(counter).channel = channel;
SummaryStructGolgi(counter).FR = FR;
SummaryStructGolgi(counter).wfStructStruct = wfStructStruct.TGlim1WFs;
SummaryStructGolgi(counter).TimeLimit = TimeLim1;
SummaryStructGolgi(counter).Nisi = Nisi;
SummaryStructGolgi(counter).edgesISI = edgesISI;
SummaryStructGolgi(counter).Nacg= Nacg;
SummaryStructGolgi(counter).edgesACG = edgesACG;
counter = counter + 1;
end


