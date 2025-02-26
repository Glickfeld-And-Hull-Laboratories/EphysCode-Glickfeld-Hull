function [RecordingList] = RecordingListMakerLong(Structure)
n = 1;
counter = 1;
x = Structure(n).recordingID;
%I = find(x == '\', 1, 'last');
%x = x(I:end);
RecordingList(counter).ID = x;
counter = counter + 1;

for n =2:length(Structure)
    if ~strcmp(Structure(n-1).recordingID, Structure(n).recordingID)
        x = Structure(n).recordingID;
        %I = find(x == '\', 3, 'last');
        %x = x(I:end);
        RecordingList(counter).ID = x;
        counter = counter + 1;
    end
end

        