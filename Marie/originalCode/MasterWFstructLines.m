[FR, WF, wfStructStruct] = CellCharWorkup(GoodANDmuaStructSorted(n).unitID, AllUnitStruct, LaserStimAdj, TimeGridA, TimeGridB, -.05, .05, -.05, .05, [0 inf], [NaN NaN], [0 .075], .001, 'k', 'nodrug', NaN, NaN, NaN, NaN, MEH_chanMap);
wfStructStruct.TGTimeLim1FR = FR;
MasterWFstruct(n) = wfStructStruct;


for n = 1:53
[FR, WF, wfStructStruct] = CellCharWorkup(GoodUnitStructSorted(n).unitID, AllUnitStruct, LaserStimAdj, TimeGridA, TimeGridB, -.05, .05, -.05, .05, [3530 4000], [5500 inf], [0 .075], .001, 'k', 'ImmEXBlockVsLateEXBlock', NaN, NaN, NaN, NaN, MEH_chanMap);
wfStructStruct.TGTimeLim1FR = FR;
ImmBlockVsLateBlock_MasterWFstruct(n) = wfStructStruct;
close all