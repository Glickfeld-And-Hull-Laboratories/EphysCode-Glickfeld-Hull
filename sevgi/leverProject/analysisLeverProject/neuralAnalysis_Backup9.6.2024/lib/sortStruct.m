function sortedStruct = sortStruct(structVar, field)
    if length(structVar)>1
        tempTable = struct2table(structVar); % convert the struct array to a table
        ids=tempTable.(1);
        if iscell(ids) % that means there's an empty row in the table, if not returns double array - found it stupid! yess, me too
            idx  =  cellfun(@isempty,ids); % Find empty rows if any
            tempTable(idx,:) = [] ; 
        end
        sortedTable = sortrows(tempTable, field, 'descend'); % 'ascend'); 
        sortedStruct = table2struct(sortedTable); % change it back to struct array if necessary
    else
        sortedStruct = structVar;
    end
end