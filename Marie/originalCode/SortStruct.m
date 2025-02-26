function SortedStruct = SortStruct(struct, field, order)
if length(struct) > 1
T = struct2table(struct); % convert the struct array to a table

sortedT = sortrows(T, field, order); % sort the table by 'DOB'

SortedStruct = table2struct(sortedT); % change it back to struct array if necessary
else
    SortedStruct = struct;
end
end