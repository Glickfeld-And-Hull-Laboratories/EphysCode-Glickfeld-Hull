for n = 1:length(MF_forlongWF)
LongWF(n).unit = MF_forlongWF(n);
LongWF(n).TimeLim1 = [0 DrugLinesStruct(1).time];
[LongWF(n).time, ~, LongWF(n).MultiChanWFStruct, LongWF(n).Scale] = MultiChanWF(AllUnitStruct, .007, 100, LongWF(n).TimeLim1, TimeGridA, TimeGridB, MF_forlongWF(n), MEH_chanMap, 'g', 1, 1, NaN);
[LongWF(n).time, ~, LongWF(n).MultiChanWFStruct_50msStimPre, ~] = MultiChanWF(AllUnitStruct, .007, 100, LongWF(n).TimeLim1, TimeGridB, TimeGridB+.05, MF_forlongWF(n), MEH_chanMap, 'g', 1, 1, NaN);
LongWF(n).TimeLim2 = [DrugLinesStruct(2).time DrugLinesStruct(3).time];
[~, ~, LongWF(n).MultiChanWFStruct_LateBlock, ~] = MultiChanWF(AllUnitStruct, .007, 100, LongWF(n).TimeLim2, TimeGridA, TimeGridB, MF_forlongWF(n), MEH_chanMap, 'm', 0, 1, LongWF(n).Scale);
[~, ~, LongWF(n).MultiChanWFStruct_50msStimPost, ~] = MultiChanWF(AllUnitStruct, .007, 100, LongWF(n).TimeLim2, TimeGridA, TimeGridB, MF_forlongWF(n), MEH_chanMap, 'm', 0, 1, LongWF(n).Scale);
end