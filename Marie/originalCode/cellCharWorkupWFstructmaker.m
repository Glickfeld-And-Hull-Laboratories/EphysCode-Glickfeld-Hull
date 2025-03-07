for n =1:length(molLayer)
[FR, WF, wfStructStruct] = CellCharWorkupDrugStruct(molLayer(n), AllUnitStruct, LaserStimAdj, TimeGridA, TimeGridB, -.05, .05, -.05, .05, [0 DrugLinesStruct(2).time], [DrugLinesStruct(3).time inf], DrugLinesStruct, [0 .075], .001, 'k', 'trash', NaN, NaN, NaN, NaN, MEH_chanMap);
wfStructStruct.TGTimeLim1FR = FR;
ImmBlockVsLateBlock_MasterWFstruct_molLayer(n) = wfStructStruct;
close all
end