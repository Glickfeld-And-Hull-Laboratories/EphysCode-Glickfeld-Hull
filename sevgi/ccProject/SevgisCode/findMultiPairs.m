function unitSlaves = findMultiPairs(unitSlavesAll, cellMouseDayUnitID)
        globals; 
        
        % recordingDayInd
        arrIndSlave = [];
        if ~isempty(cellMouseDayUnitID)
            for indMaster=1:length(cellMouseDayUnitID)
                sMouseDayUnitID = cellMouseDayUnitID(indMaster);
                cellTemp = split(sMouseDayUnitID,'_');
                mouseId = str2num(cellTemp{1});
                recordingDayInd = str2num(cellTemp{2});
                unitID = str2num(cellTemp{3});

                for i=1:length(unitSlavesAll)                    
                    % get only paired units
                    indSlave = find([unitSlavesAll(i).RecorNum]==recordingDayInd & [unitSlavesAll(i).PCpair]==unitID);                    
                    if ~isempty(indSlave)
                        arrIndSlaves = [arrIndSlaves indSlave];
                    end
                end
            end
        end
        
        unitSlaves = unitSlavesAll(arrIndSlave);        
end