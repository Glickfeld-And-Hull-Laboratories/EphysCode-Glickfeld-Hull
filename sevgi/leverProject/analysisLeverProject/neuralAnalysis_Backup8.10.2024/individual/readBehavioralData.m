function [arrHitTrials, arrFaTrials, arrMissTrials, arrStimTurnedOnTrials, arrReqHoldTimes, arrReactTimes, tooFastTime, reactTime, preHoldTime, fixedHoldStartsAtTrial, omissionTrials, nonOmissionTrials] = readBehavioralData(trialCutIndex)
    globals;
    
    arrHitTrials = [];
    arrFaTrials = [];
    arrMissTrials = [];
    arrStimTurnedOnTrials = [];
    arrReqHoldTimes = [];
    arrReactTimes = [];
    trialSinceReset = -1;
    
    dirStruct = dir([pathToRecFolder 'data-i' MOUSE_ID '*.mat']);
    [~,arrDays] = sort([dirStruct.datenum]);
    if ~isempty(arrDays)
        for nDay=1:length(arrDays)
            fileName = dirStruct(arrDays(nDay)).name;
            fullFilename = [pathToRecFolder fileName];
            data = load(fullFilename);
            input = data.input;
            hitInds = find(strcmp(input.trialOutcomeCell, 'success'));
            faInds = find(strcmp(input.trialOutcomeCell, 'failure'));
            missInds = find(strcmp(input.trialOutcomeCell, 'ignore'));
            stimTurnedOn = find(cell2mat(input.tStimTurnedOn));
            reqHoldTimes = cell2mat(input.tTotalReqHoldTimeMs);
            reactTimes = cell2mat(input.reactTimesMs);
            %rewardInds=find(~cellfun(@isempty,input.tNRewards));        

            if trialSinceReset~=-1 % that means we have more than one behavioral data file
                hitInds = hitInds + trialSinceReset; % so add up trial numbers
                faInds = faInds + trialSinceReset;
                missInds = missInds + trialSinceReset;
                stimTurnedOn = stimTurnedOn + trialSinceReset;
            end

            arrHitTrials = [arrHitTrials hitInds];
            arrFaTrials = [arrFaTrials faInds];
            arrMissTrials = [arrMissTrials missInds];
            stimTurnedOnwMiss = sort([stimTurnedOn setdiff(missInds, stimTurnedOn)]);
            arrStimTurnedOnTrials = [arrStimTurnedOnTrials stimTurnedOnwMiss]; % cos stimTurnedOnTrials did not include missTrials on MWorks system
            arrReactTimes = [arrReactTimes reactTimes];
            arrReqHoldTimes = [arrReqHoldTimes reqHoldTimes];
            trialSinceReset = input.trialSinceReset;

            indsEmpty = cellfun(@isempty,input.tRewardOmissionTrial);
            cellOfIntegersOnly = cellfun(@num2str,input.tRewardOmissionTrial.','UniformOutput',0);
            omissionTrials = find(cell2mat(cellfun(@(x) strcmp(x,'1'),cellOfIntegersOnly,'UniformOutput',0)));
            nonOmissionTrials = find(cell2mat(cellfun(@(x) strcmp(x,'0'),cellOfIntegersOnly,'UniformOutput',0)));
        end
        tooFastTime = double(input.tooFastTimeMs);
        reactTime = double(input.reactTimeMs);
        preHoldTime = double(input.preHoldTimeMs);
        fixedHoldStartsAtTrial = find(cell2mat(input.tRandReqHoldTimeMs)==0,1);
        if isempty(fixedHoldStartsAtTrial) 
            fixedHoldStartsAtTrial=-1; % means all random delay trials, so that further functions understands that there will be no fixed delay trials to plot
        end

        if (SOFT_CUT~=Inf || HARD_CUT~=Inf) && ~isempty(trialCutIndex) % that means we soft-cut this recording and trial count hinted from SpikeGLX system            
            if SOFT_CUT_PARTITION==1 || HARD_CUT_PARTITION==1 % Get the first part of the recording
                trialInds = 1:trialCutIndex;
            else % get the rest
                trialInds = trialCutIndex:length(arrReqHoldTimes);
            end

            arrReqHoldTimes = arrReqHoldTimes(trialInds);
            arrReactTimes = arrReactTimes(trialInds); % return react time as a whole cos its trial indexes are used everywhere in the code

            % Realign trial indices
            arrHitTrials = intersect(arrHitTrials,trialInds)-trialInds(1)+1;
            arrFaTrials = intersect(arrFaTrials,trialInds)-trialInds(1)+1;
            arrMissTrials= intersect(arrMissTrials,trialInds)-trialInds(1)+1;
            arrStimTurnedOnTrials = intersect(arrStimTurnedOnTrials,trialInds)-trialInds(1)+1;

            if isempty(find(trialInds==fixedHoldStartsAtTrial)) % If we miss fixed delay change point, set it to -1 so that we know remainings'll be all fixed delay trials 
                fixedHoldStartsAtTrial = 1;
            end
        end
    else
        logger.error('readBehavioralData', ['UPPS! Behavioral Data not found under:' pathToRecFolder 'data-i' MOUSE_ID '*.mat'])
    end
end