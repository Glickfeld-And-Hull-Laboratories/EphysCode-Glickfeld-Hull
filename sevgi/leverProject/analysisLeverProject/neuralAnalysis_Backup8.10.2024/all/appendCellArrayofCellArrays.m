% 1/8/2024 SO: Appends new spike times into a cell array of cell arrays
function cellSpikeTime = appendCellArrayofCellArrays(cellSpikeTime, newSpikeTime)
    if ~isempty(newSpikeTime)
        if ~isempty(cellSpikeTime)
            cellSpikeTime(end+1:end+length(newSpikeTime)) = newSpikeTime; % adding into a cell array of cell array                

            % You can also use this technique to append at the end of a cell array
            %unitsOfSpecTypeForAllRec(indNeuronType) = {[unitsOfSpecTypeForAllRec{indNeuronType}, unitsOfSpecType]};
        else
            cellSpikeTime = newSpikeTime;
        end
    end
end