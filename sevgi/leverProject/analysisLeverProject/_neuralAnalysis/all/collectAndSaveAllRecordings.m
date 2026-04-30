function collectAndSaveAllRecordings()
    globalsAll;
        
    if ~exist(ALL_RECORDINGS_FILE,"file")
        %recFolders=dir([pathToParentRec '20*']);
        for indFolder=1:length(RECORDINGS_TO_POOL)
            sFolderName = RECORDINGS_TO_POOL{indFolder}; %recFolders(indFolder).name;
            sUnitsAndVarsFilePattern = [pathToParentRec sFolderName '/data/unitsAndVars_*_part1.mat'];
            sUnitsAndVarsFile = dir(sUnitsAndVarsFilePattern);
            if ~isempty(sUnitsAndVarsFile)
                unitsAndVarsFilePath = [ pathToParentRec sFolderName '/data/' sUnitsAndVarsFile.name];
                load(unitsAndVarsFilePath,'unitGood', 'leverHoldTimes', 'leverReleaseTimesGLX', 'targetStimTimesGLX', 'baselineStimTimesGLX', ...
                        'trialCutIndex', 'allTrials', 'arrHitTrials', 'arrFaTrials', 'arrMissTrials', 'arrStimTurnedOnTrials', 'arrReqHoldTimes', 'arrReactTimes', ...
                        'tooFastTime', 'reactTime', 'preHoldTime', 'fixedHoldStartsAtTrial','softCut','softCutPartition','hardCut','hardCutPartition');
                sStructName = sUnitsAndVarsFile.name(1:end-4);
                eval(strcat(sStructName,'.unitGood=unitGood;'));
                eval(strcat(sStructName,'.leverHoldTimes=leverHoldTimes;'));
                eval(strcat(sStructName,'.leverReleaseTimesGLX=leverReleaseTimesGLX;'));
                eval(strcat(sStructName,'.targetStimTimesGLX=targetStimTimesGLX;'));
                eval(strcat(sStructName,'.baselineStimTimesGLX=baselineStimTimesGLX;'));
                eval(strcat(sStructName,'.trialCutIndex=trialCutIndex;'));
                eval(strcat(sStructName,'.allTrials=allTrials;'));
                eval(strcat(sStructName,'.arrHitTrials=arrHitTrials;'));
                eval(strcat(sStructName,'.arrFaTrials=arrFaTrials;'));
                eval(strcat(sStructName,'.arrMissTrials=arrMissTrials;'));
                eval(strcat(sStructName,'.arrStimTurnedOnTrials=arrStimTurnedOnTrials;'));
                eval(strcat(sStructName,'.arrReqHoldTimes=arrReqHoldTimes;'));
                eval(strcat(sStructName,'.arrReactTimes=arrReactTimes;'));
                eval(strcat(sStructName,'.tooFastTime=tooFastTime;'));
                eval(strcat(sStructName,'.reactTime=reactTime;'));
                eval(strcat(sStructName,'.preHoldTime=preHoldTime;'));
                eval(strcat(sStructName,'.fixedHoldStartsAtTrial=fixedHoldStartsAtTrial;'));
                eval(strcat(sStructName,'.softCut=softCut;'));
                eval(strcat(sStructName,'.softCutPartition=softCutPartition;'));
                eval(strcat(sStructName,'.hardCut=hardCut;'));
                eval(strcat(sStructName,'.hardCutPartition=hardCutPartition;'));
            else
                logger.info('mainAll', ['There is no such file! :' sUnitsAndVarsFilePattern]);
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