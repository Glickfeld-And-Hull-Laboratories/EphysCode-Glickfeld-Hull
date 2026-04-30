function [unitGood,unitMua,unitNoise] = saveUnits(unitList)

    globals;
    unitsAndVarsPath = strcat(pathToUnitsDataFolder,UNITS_AND_VARS_FILE_NAME);
    if length(unitList)>1
        unitGood = unitList{1};
        unitMua = unitList{2};
        unitNoise = unitList{3};
    end

    if length(unitList)==3  % Update all units % ~exist(unitsAndVarsPath,'file')
        if UNIT_OF_INTEREST== -1 % dont bother to save if you're observing only one unit            
            save(unitsAndVarsPath,'unitGood','unitMua','unitNoise', '-v7.3');
            logger.info('saveUnit', [num2str(length(unitGood)) ' units are saved into :' unitsAndVarsPath]);            
        end
    elseif length(unitList)==1  % Update only one unit
        unit = unitList(1);
        load(unitsAndVarsPath,'unitGood', 'unitMua', 'unitNoise');
        unitId = find([unitGood.id]==unit.id);
        if ~isempty(unitId)
            unitGood(unitId) = unit;
        else
            unitId = find([unitMua.id]==unit.id);
            if ~isempty(unitId)
                unitMua(unitId) = unit;
            else
                unitId = find([unitNoise.id]==unit.id);
                if ~isempty(unitId)
                    unitNoise(unitId) = unit;
                end
            end
        end
        save(unitsAndVarsPath,'unitGood','unitMua','unitNoise', '-v7.3');
    end
end