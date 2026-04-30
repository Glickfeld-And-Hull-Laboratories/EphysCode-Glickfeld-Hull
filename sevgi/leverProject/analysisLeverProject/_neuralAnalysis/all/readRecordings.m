function arrRecordings = readRecordings()
    globalsAll;
    
    if exist(ALL_RECORDINGS_FILE,"file")
        recordings = whos("-file",ALL_RECORDINGS_FILE);        
        arrRecordings = cell(1,2);
        for indRec=1:length(recordings)
            load(ALL_RECORDINGS_FILE,recordings(indRec).name);
            recStruct.name = recordings(indRec).name;            
            eval(strcat('recStruct.unitGood=', recStruct.name, '.unitGood;'));
            eval(strcat('recStruct.leverHoldTimes=', recStruct.name, '.leverHoldTimes;'));
            eval(strcat('recStruct.leverReleaseTimesGLX=', recStruct.name, '.leverReleaseTimesGLX;'));
            eval(strcat('recStruct.targetStimTimesGLX=', recStruct.name, '.targetStimTimesGLX;'));
            eval(strcat('recStruct.baselineStimTimesGLX=', recStruct.name, '.baselineStimTimesGLX;'));
            eval(strcat('recStruct.trialCutIndex=', recStruct.name, '.trialCutIndex;'));
            eval(strcat('recStruct.allTrials=', recStruct.name, '.allTrials;'));
            eval(strcat('recStruct.arrHitTrials=', recStruct.name, '.arrHitTrials;'));
            eval(strcat('recStruct.arrFaTrials=', recStruct.name, '.arrFaTrials;'));
            eval(strcat('recStruct.arrMissTrials=', recStruct.name, '.arrMissTrials;'));
            eval(strcat('recStruct.arrStimTurnedOnTrials=', recStruct.name, '.arrStimTurnedOnTrials;'));
            eval(strcat('recStruct.arrReqHoldTimes=', recStruct.name, '.arrReqHoldTimes;'));
            eval(strcat('recStruct.arrReactTimes=', recStruct.name, '.arrReactTimes;'));
            eval(strcat('recStruct.tooFastTime=', recStruct.name, '.tooFastTime;'));
            eval(strcat('recStruct.reactTime=', recStruct.name, '.reactTime;'));
            eval(strcat('recStruct.preHoldTime=', recStruct.name, '.preHoldTime;'));
            eval(strcat('recStruct.fixedHoldStartsAtTrial=', recStruct.name, '.fixedHoldStartsAtTrial;'));
            eval(strcat('recStruct.softCut=', recStruct.name, '.softCut;'));
            eval(strcat('recStruct.softCutPartition=', recStruct.name, '.softCutPartition;'));

            arrRecordings{1,indRec} = recStruct;            
            eval(['clear ' recStruct.name]);
            clear recStruct
        end

        logger.info('mainAll', [num2str(length(recordings)) ' recordings are read from file ' ALL_RECORDINGS_FILE]);
    end
end