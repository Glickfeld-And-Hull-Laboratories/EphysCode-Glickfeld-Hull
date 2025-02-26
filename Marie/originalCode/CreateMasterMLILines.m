%Create Master MLI struct lines
%not perfect yet but faster than scratch
%check MEH_chanMap against phy
%attend to TimeLims and labels

Tester = getTrueDepth(GoodUnitStruct, 1100.8.0, 75);

for n = 1:length(Tester)
Tester(n).LaserOn = LaserStimAdj;
Tester(n).LaserOff = LaserStimOffAdj;
end


for n = 1:length(Tester)
Tester(n).JuiceTimes = JuiceTimesAdj;
Tester(n).DrugStruct = DrugStruct;
Tester(n).MLIboo = NaN;
end

[INHcells, EXCcells, RespCellsStruct] = LoopPSTHresp([Tester.unitID].', Tester, LaserStimAdj, -.3, .15, [0 inf], .01, 'k', 'tester', 2);

for n = 1:length(RespCellsStruct)
RespCellsStruct(n).CCGid = NaN;
RespCellsStruct(n).PCpairExample = NaN;
end

for n = 1:length(RespCellsStruct)
[~, ~, MultiChanWFStruct] = MultiChanWF(AllUnitStruct, .003, 100, [0 inf], TimeGridA, TimeGridB, RespCellsStruct(n).unitID, MEH_chanMap, 'k', 0, 0, NaN);
RespCellsStruct(n).MultiChanWF = MultiChanWFStruct;
RespCellsStruct(n).RawDataFile = '1638day1ish_21_11_10_g0_t0.imec0.ap.bin';
end

[NoiseDataOrig, NoiseMetaDataOrig] = NoiseSnips([0 inf], 30, 1);
[NoiseAnalysisOrig] = NoiseOnEveryChannel(NoiseDataOrig, MEH_chanMap);

RespCellsStruct = MultiChan_sig2noise(RespCellsStruct, NoiseAnalysisOrig);
RespCellsStruct(find([RespCellsStruct.unitID]==457)).PCpairExample = 462;

for n = 1:length(RespCellsStruct)
if ~isnan(RespCellsStruct(n).PCpairExample)
RespCellsStruct(n).CCGid = 1;
else
RespCellsStruct(n).CCGid = 0;
end
end

for n = 1:length(RespCellsStruct)
if RespCellsStruct(n).INHlatency <= .02 | RespCellsStruct(n).CCGid == 1
RespCellsStruct(n).MLIboo = 1;
else
RespCellsStruct(n).MLIboo = 0;
end
end

%rename RespCellsStruct to GoodUnitAnalysis

for n = 1:length(GoodUnitAnalysis)
GoodUnitAnalysis(n).NoiseMetaData = NoiseMetaDataOrig;
GoodUnitAnalysis(n).RecordingID = 'DH6_210924g1';
end

counter = 1;
for n = 1:length(GoodUnitAnalysis)
if GoodUnitAnalysis(n).MLIboo == 1
MLIstruct(counter) = GoodUnitAnalysis(n);
counter = counter + 1
end
end

for n = 1:length(GoodUnitAnalysis)
GoodUnitAnalysis(n).TimeLim = [0 inf];
end