% Expands cell array two-level
function [cellC, lengthsPerMousePerDay] =expandCellArray(cellA, whichMouseDay)

    lengthsPerMousePerDay = 0;
    if nargin==1 % isempty(whichMouseDay) % By default, get all mice all days
        lengths = cellfun(@(x) cellfun(@length,x), cellA, UniformOutput=false);
        lengthsPerMousePerDay = cell2mat(lengths);
        % lengthsPerMouse = sum(lengthsPerMousePerDay, 2);
        cellB = [cellA{:}];
        cellC = [cellB{:}];
    else
        cellC = {};
        for i=1:length(whichMouseDay)
            cellSelectedMouseDay = cellA{whichMouseDay(i,1)}{whichMouseDay(i,2)};
            cellC = [cellC cellSelectedMouseDay];
        end
    end
end