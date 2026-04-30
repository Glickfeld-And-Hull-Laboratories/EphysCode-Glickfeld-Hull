function behavDataForRecordingDays = doubleCheckLicks(behavDataForRecordingDays)

    globals;

    cellAllLicksRT = {};
    for i=1:length(behavDataForRecordingDays)
        lickOnsets = behavDataForRecordingDays(i).LickOnsets;
        allLicks = behavDataForRecordingDays(i).AllLicks;
        trialStruct = behavDataForRecordingDays(i).TrialStruct;
        indCell = num2cell([1:length(trialStruct)]);
        [trialStruct.TrialInd] = deal(indCell{:});

        j=1;
        while j<=length(lickOnsets)
            lickOnset1 = lickOnsets(j).time;            
            indLickOnset1 = find(lickOnset1==allLicks);
            if j == 1 && indLickOnset1 > 1 % delete all unregistered licks before the first lick onset
                allLicks = allLicks(indLickOnset1:end);
                j = j-1; % start from beginning again
            else
                if j<length(lickOnsets)
                    lickOnset2 = lickOnsets(j+1).time;
                    indLickOnset2 = find(lickOnset2==allLicks);
                else
                    indLickOnset2 = length(allLicks)+1; % some hypothetical index to be able to process last lick onset and its corresponding all licks
                end

                if indLickOnset2-indLickOnset1 < NUMBER_OF_LICKS_FOR_A_BOUT % There should be min 3 licks in a bout
                    allLicks(indLickOnset1)=[];
                    lickOnsets(j) = [];
                    j = j-1;
                else
                    boutLicks = allLicks(indLickOnset1:indLickOnset2-1);
                    ili = diff(boutLicks); % if there is any licks  counted in the bout
                    if any(ili>MAX_ILI)
                        indViolations = find(ili>MAX_ILI);
                        allLicks(indLickOnset1+indViolations(1):(indLickOnset2-1)) = []; % if there is a violation of ILI, delete the rest of the licks within the bout                        
                        j = j-1;
                    else
                        allLickTimes = allLicks(indLickOnset1:indLickOnset2-1);
                        juiceTimeNow = lickOnsets(j).time-lickOnsets(j).RTj;
                        if strcmp(lickOnsets(j).TrialType,'j') || strcmp(lickOnsets(j).TrialType,'b')
                            indFound = find([trialStruct.JuiceTime]==juiceTimeNow);
                        else
                            indFound = find([trialStruct.FictiveJuice]==juiceTimeNow); % all other trial types that may not have Juice Time goes here
                        end
                        if ~isempty(indFound)
                            lickOnsets(j).TrialInd = trialStruct(indFound).TrialInd;
                        else
                            lickOnsets(j).TrialInd = 0;
                        end
                        cellAllLicksRT{j} = allLickTimes; %-juiceTime;
                    end
                end
            end
            j=j+1;
        end

        behavDataForRecordingDays(i).TrialStruct = trialStruct;
        behavDataForRecordingDays(i).LickOnsets = lickOnsets; % reassign updated lists
        behavDataForRecordingDays(i).AllLicks = allLicks;
        behavDataForRecordingDays(i).cellAllLicks = cellAllLicksRT;
        cellAllLicksRT = {};
    end
end