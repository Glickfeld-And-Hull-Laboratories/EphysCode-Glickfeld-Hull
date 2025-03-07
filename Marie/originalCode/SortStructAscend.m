function SortedStruct = SortStructAscend(struct, field)

T = struct2table(struct, 'AsArray', true); % convert the struct array to a table

sortedT = sortrows(T, field, 'ascend'); % sort the table by 'DOB'

SortedStruct = table2struct(sortedT); % change it back to struct array if necessary

end