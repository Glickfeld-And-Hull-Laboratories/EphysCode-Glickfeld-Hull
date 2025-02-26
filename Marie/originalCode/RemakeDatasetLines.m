F1 = fieldnames(SummaryStruct_1678);
F2 = fieldnames(SumSt_AllVars);
Fdiff = setdiff(F2, F1);

for n = 1:length(Fdiff)
SumSt_AllVars = rmfield(SumSt_AllVars, Fdiff(n));
end

for n = 1:length(SummaryStruct)
chan = SummaryStruct(n).BiggestWFstruct.chan;
chanMap = MEH_chanMap;
index = find([chanMap.chan] == chan);
SummaryStruct(n).BrainReg = chanMap(index).loc;
end

[RecordingList] = RecordingListMakerLong(SumSt_AllVars);
RecordingList(1).unnamed = 1665;
RecordingList(1).unnamed = 1666;
RecordingList(1).unnamed = 1665;
RecordingList(2).unnamed = 1666;
RecordingList(3).unnamed = 1672;
RecordingList(4).unnamed = 1672;
RecordingList(4).unnamed = 1674;
RecordingList(5).unnamed = 1667;
RecordingList(6).unnamed = 1667;
RecordingList(7).unnamed = 1668;
RecordingList(8).unnamed = 1673;
RecordingList(9).unnamed = 1673;
RecordingList(10).unnamed = 1669;
RecordingList(11).unnamed = 1669;
RecordingList(12).unnamed = 1670;

for n = 1:length(RecordingList)
cd(RecordingList(n).path);
d = dir('BrainLocation*.mat')
name = {d.name};
load(name, 'MEH_chanMap')
RecordingList(n).BrainReg = MEH_chanMap;
clear 'MEH_chanMap';
end


if ~isempty(RecordingList(n).RunningData)
cd(RecordingList(n).ID);
cd ..
fid = fopen('SpeedTimesAdj.txt');
SpeedTimesAdj = fscanf(fid, '%f');
fclose(fid);
RecordingList(n).RunningData.SpeedTimesAdj = SpeedTimesAdj;
cd(RecordingList(n).ID);
RunningStruct = RecordingList(n).RunningData;
save RunningStruct RunningStruct;
clear 'SpeedTimesAdj';
clear 'RunningStruct';
end

for n = 1:length(RecordingList)
cd(RecordingList(n).path);
load('RunningData.mat', 'RunningStruct')
RecordingList(n).RunningData = RunningStruct;
clear 'RunningStruct';
end