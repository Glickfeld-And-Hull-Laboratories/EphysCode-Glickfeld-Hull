% 1/8/2024 SO: Appends new spike times into a cell array of cell arrays
function cellSpikeTime = appendCellArrayofCellArrays(cellSpikeTime, newSpikeTime)
    if ~isempty(newSpikeTime)
        if ~isempty(cellSpikeTime)
            cellSpikeTime(end+1) = {newSpikeTime}; % adding into a cell array of cell array                
        else
            cellSpikeTime = {newSpikeTime};
        end
    end
end