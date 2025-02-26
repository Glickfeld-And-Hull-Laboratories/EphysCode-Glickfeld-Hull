% for n = 1:length(RecordingList) do this loop manually
cd(RecordingList(n).path);
cd('C4');
%d = dir('C4workspace.mat');
%name = {d.name};
%temp = load(name{1:end}, 'GoodUnitStruct');
[~, GoodUnitStruct, ~, ~, ~] = ImportKSdataPhyllumC4_mod();
for k = 1:length(SumSt)
    if SumSt(k).RecorNum == n
        for p = 1:length(GoodUnitStruct)
        if SumSt(k).unitID == GoodUnitStruct(p).unitID
            SumSt(k).c4_label = GoodUnitStruct(p).c4_label;
            SumSt(k).c4_confidence = GoodUnitStruct(p).c4_confidence;
        end
        end
    end
end
for k = 1:length(MLIsA)
    if MLIsA(k).RecorNum == n
                for p = 1:length(GoodUnitStruct)
        if MLIsA(k).unitID == GoodUnitStruct(p).unitID
            MLIsA(k).c4_label = GoodUnitStruct(p).c4_label;
            MLIsA(k).c4_confidence = GoodUnitStruct(p).c4_confidence;
        end
                end
    end
end
for k = 1:length(MLIsB)
    if MLIsB(k).RecorNum == n
                for p = 1:length(GoodUnitStruct)
        if MLIsB(k).unitID == GoodUnitStruct(p).unitID
            MLIsB(k).c4_label = GoodUnitStruct(p).c4_label;
            MLIsB(k).c4_confidence = GoodUnitStruct(p).c4_confidence;
        end
                end
    end
end

%to add to any struct from SumSt;
%modify this
struct = MLIs;
for k = 1:length(struct)
        for p = 1:length(SumSt)
        if struct(k).unitID == SumSt(p).unitID
            struct(k).c4_label = SumSt(p).c4_label;
            struct(k).c4_confidence = SumSt(p).c4_confidence;
        end
        end
end
%finish by modifying this
MLIs = struct;


