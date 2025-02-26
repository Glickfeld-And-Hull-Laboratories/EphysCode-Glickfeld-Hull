n = 1;
counter = 1;
RecordingIDlist(counter).recording = SumSt(n).recordingID;
%RecordingIDlist(counter).TrainingDay = SumSt(n).TrainingDay;
RecordingIDlist(counter).SS_pause = 0;
RecordingIDlist(counter).CS_pause = 0;
RecordingIDlist(counter).MLI_layer = 0;
RecordingIDlist(counter).MLI_ccg = 0;
RecordingIDlist(counter).MF = 0;
RecordingIDlist(counter).Golgi = 0;
RecordingIDlist(counter).SS_nopair = 0;
RecordingIDlist(counter).CS_nopair = 0;
if strcmp(SumSt(n).handID, 'SS_pause')
RecordingIDlist(counter).SS_pause = RecordingIDlist(counter).SS_pause +1;
end
if strcmp(SumSt(n).handID, 'CS_pause')
RecordingIDlist(counter).CS_pause = RecordingIDlist(counter).CS_pause +1;
end
if strcmp(SumSt(n).handID, 'MLI')
if strcmp(SumSt(n).MLIexpertID, 'ccg')
RecordingIDlist(counter).MLI_ccg = RecordingIDlist(counter).MLI_ccg +1;
end
if strcmp(SumSt(n).MLIexpertID, 'layer')
RecordingIDlist(counter).MLI_layer = RecordingIDlist(counter).MLI_layer +1;
end
end
if strcmp(SumSt(n).handID, 'MF')
RecordingIDlist(counter).MF = RecordingIDlist(counter).MF +1;
end
if strcmp(SumSt(n).handID, 'Golgi')
RecordingIDlist(counter).Golgi = RecordingIDlist(counter).Golgi +1;
end
if strcmp(SumSt(n).handID, 'SS_noPair')
RecordingIDlist(counter).SS_nopair = RecordingIDlist(counter).SS_nopair +1;
end
if strcmp(SumSt(n).handID, 'CS_noPair')
RecordingIDlist(counter).CS_nopair = RecordingIDlist(counter).CS_nopair +1;
end
n = n+1;
%counter = counter + 1;


for n = 2:length(SumSt)
    n
if ~strcmp(SumSt(n-1).recordingID, SumSt(n).recordingID)
    counter = counter+1
RecordingIDlist(counter).recording = SumSt(n).recordingID;
%RecordingIDlist(counter).TrainingDay = SumSt(n).TrainingDay;
RecordingIDlist(counter).SS_pause = 0;
RecordingIDlist(counter).CS_pause = 0;
RecordingIDlist(counter).MLI_layer = 0;
RecordingIDlist(counter).MLI_ccg = 0;
RecordingIDlist(counter).MF = 0;
RecordingIDlist(counter).Golgi = 0;
RecordingIDlist(counter).SS_nopair = 0;
RecordingIDlist(counter).CS_nopair = 0;
end
if strcmp(SumSt(n).handID, 'SS_pause')
RecordingIDlist(counter).SS_pause = RecordingIDlist(counter).SS_pause +1;
end
if strcmp(SumSt(n).handID, 'CS_pause')
RecordingIDlist(counter).CS_pause = RecordingIDlist(counter).CS_pause +1;
end
if strcmp(SumSt(n).handID, 'MLI')
if strcmp(SumSt(n).MLIexpertID, 'ccg')
RecordingIDlist(counter).MLI_ccg = RecordingIDlist(counter).MLI_ccg +1;
end
if strcmp(SumSt(n).MLIexpertID, 'layer')
RecordingIDlist(counter).MLI_layer = RecordingIDlist(counter).MLI_layer +1;
end
end
if strcmp(SumSt(n).handID, 'MF')
RecordingIDlist(counter).MF = RecordingIDlist(counter).MF +1;
end
if strcmp(SumSt(n).handID, 'Golgi')
RecordingIDlist(counter).Golgi = RecordingIDlist(counter).Golgi +1;
end
if strcmp(SumSt(n).handID, 'SS_noPair')
RecordingIDlist(counter).SS_nopair = RecordingIDlist(counter).SS_nopair +1;
end
if strcmp(SumSt(n).handID, 'CS_noPair')
RecordingIDlist(counter).CS_nopair = RecordingIDlist(counter).CS_nopair +1;
end
end
