function [NewStruct] = rmmissingStruct(Struct)
Table = struct2table(Struct);
Removed = rmmissing(Table);
NewStruct = table2struct(Removed);
end