function collectAndSaveAllRecordings()
    globalsAll;
        
    if ~exist(ALL_RECORDINGS_FILE,"file")
        if RECORDING_DAY_OF_INTEREST~=-1 %~strcmp(RECORDING_DAY_OF_INTEREST,'')            
            sFolderName = RECORDING_DAY_OF_INTEREST;
            sUnitsAndVarsFilePattern = [pathToParentRec sFolderName '/data/unitsAndVars_*.mat'];
            sUnitsAndVarsFile = dir(sUnitsAndVarsFilePattern);
            if ~isempty(sUnitsAndVarsFile)
                unitsAndVarsFilePath = [ pathToParentRec sFolderName '/data/' sUnitsAndVarsFile.name];
                load(unitsAndVarsFilePath, 'unitGood'); %, 'leverHoldTimes', 
                sStructName = sUnitsAndVarsFile.name(1:end-4);
                eval(strcat(sStructName,'.unitGood=unitGood;'));                
            else
                logger.info('mainAll', ['There is no such file! :' sUnitsAndVarsFilePattern]);
            end
        else
            for indFolder=1:length(RECORDINGS_TO_POOL)
                sFolderName = RECORDINGS_TO_POOL{indFolder}; %recFolders(indFolder).name;
                sUnitsAndVarsFilePattern = [pathToParentRec sFolderName '/data/unitsAndVars_*.mat'];
                sUnitsAndVarsFile = dir(sUnitsAndVarsFilePattern);
                if ~isempty(sUnitsAndVarsFile)
                    unitsAndVarsFilePath = [ pathToParentRec sFolderName '/data/' sUnitsAndVarsFile.name];
                    load(unitsAndVarsFilePath, 'unitGood');
                    sStructName = sUnitsAndVarsFile.name(1:end-4);
%                     inds = strfind(sFolderName,'_');
%                     searchFolderName = sFolderName(1:inds(end)-1);
%                     cellsMatch = strfind([RECORDINGS_MOUSE_IDS(:,1)],searchFolderName);
%                     indMatch = find(~cellfun(@isempty,cellsMatch));
%                     mouseId = RECORDINGS_MOUSE_IDS{indMatch,3};

%                     eval(strcat(sStructName,'.mouseId=mouseId;'));
                    eval(strcat(sStructName,'.unitGood=unitGood;'));                    
                else
                    logger.info('mainAll', ['There is no such file! :' sUnitsAndVarsFilePattern]);
                end
            end
        end
        
        cellUnitsAndVars = who('unitsAndVars_*');
        
        % Save units and variables coming from each recording day
        for indVars=1:length(cellUnitsAndVars)
            allFile = dir(ALL_RECORDINGS_FILE);
            if isempty(allFile)
                save(ALL_RECORDINGS_FILE, cellUnitsAndVars{indVars});
            else
                save(ALL_RECORDINGS_FILE, cellUnitsAndVars{indVars},'-append');
            end
            eval(['clear ' cellUnitsAndVars{indVars}]);
            logger.info('mainAll', [cellUnitsAndVars{indVars} ' saved into ' ALL_RECORDINGS_FILE]);
        end
    end
end