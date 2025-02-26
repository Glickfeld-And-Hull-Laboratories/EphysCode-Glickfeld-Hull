for n = 1:length(RecordingList)
cd(RecordingList(n).path);
d = dir('BrainLocation*.mat')
name = {d.name};
load(name{1:end}, 'MEH_chanMap')
RecordingList(n).BrainReg = MEH_chanMap;
clear 'MEH_chanMap';
end
for n = 1:length(SumSt)
for m = 1:length(RecordingList)
if strcmp(SumSt(n).recordingID, RecordingList(m).path)
SumSt(n).RecorNum = m;
end
end
end