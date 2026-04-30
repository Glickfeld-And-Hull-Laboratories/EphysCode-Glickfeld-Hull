function sortedStruct = sortStruct(struct, field)
    if length(struct)>1
        tempTable = struct2table(struct); % convert the struct array to a table
        sortedTable = sortrows(tempTable, field, 'descend'); % 'ascend'); 
        sortedStruct = table2struct(sortedTable); % change it back to struct array if necessary
    else
        sortedStruct = struct;
    end
end