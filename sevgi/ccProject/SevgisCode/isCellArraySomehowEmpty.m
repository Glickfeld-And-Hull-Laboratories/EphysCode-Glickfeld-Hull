function flag = isCellArraySomehowEmpty(cellA)
    flag = 0;
    if isempty(cellA)
        flag=1;
    elseif iscell(cellA)
        indEmpty = cellfun(@isempty,cellA,UniformOutput=false);
        flag = all(cell2mat(indEmpty));
    end
end