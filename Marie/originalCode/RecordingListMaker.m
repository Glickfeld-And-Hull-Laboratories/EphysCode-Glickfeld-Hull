function [RecordingList] = RecordingListMaker(Structure)
n = 1;
counter = 1;
x = Structure(n).recordingID;
RecordingList(counter).path = x;
I = find(x == '\', 1, 'last');
x = x(I:end);
RecordingList(counter).ID = x;
 RecordingList(counter).ID = x;
        %RecordingList(counter).AllLicksAdj = Structure(n).AllLicksAdj;
        %RecordingList(counter).TrialStructAdj = Structure(n).TrialStructAdj;
        RecordingList(counter).LaserStimAdj = Structure(n).LaserStimAdj;
        RecordingList(counter).DrugLinesStruct = Structure(n).DrugLinesStruct;
counter = counter + 1;

for n =2:length(Structure)
    if ~strcmp(Structure(n-1).recordingID, Structure(n).recordingID)
        x = Structure(n).recordingID;
        RecordingList(counter).path = x;
        I = find(x == '\', 3, 'last');
        x = x(I:end);
        RecordingList(counter).ID = x;
        %RecordingList(counter).AllLicksAdj = Structure(n).AllLicksAdj;
        %RecordingList(counter).TrialStructAdj = Structure(n).TrialStructAdj;
         RecordingList(counter).LaserStimAdj = Structure(n).LaserStimAdj;
        RecordingList(counter).DrugLinesStruct = Structure(n).DrugLinesStruct;
        counter = counter + 1;
    end
end

        