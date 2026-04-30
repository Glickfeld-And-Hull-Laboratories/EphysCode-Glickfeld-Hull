function plotSSratesvsCSWRTTrialOutcome(csTimesRelease, ssTimesRelease, csTimesTarget, ssTimesTarget, csID, ssID, sFolderName, fixedHoldStartsAtTrial, allTrials, arrStimTurnedOnTrials, arrHitTrials, arrMissTrials, arrFaTrials, fixedOrRandom)

    globals;

    % Didn't want to make a big cell array to include all for code readibility
    % But this time variables expanded! No big deal!

    % HIT_n vs HIT_n+1 comparisons (1-1)
    pair00_RR_11={}; pair01_RR_11={}; pair10_RR_11={}; pair11_RR_11={}; pair00_RT_11={}; pair01_RT_11={}; pair10_RT_11={}; pair11_RT_11={}; 
                pair00_TR_11={}; pair01_TR_11={}; pair10_TR_11={}; pair11_TR_11={}; pair00_TT_11={}; pair01_TT_11={}; pair10_TT_11={}; pair11_TT_11={};
    % HIT_n vs MISS_n+1 comparisons (1-2)
    pair00_RR_12={}; pair01_RR_12={}; pair10_RR_12={}; pair11_RR_12={}; pair00_RT_12={}; pair01_RT_12={}; pair10_RT_12={}; pair11_RT_12={}; 
                pair00_TR_12={}; pair01_TR_12={}; pair10_TR_12={}; pair11_TR_12={}; pair00_TT_12={}; pair01_TT_12={}; pair10_TT_12={}; pair11_TT_12={};
    % HIT_n vs FA_n+1 comparisons (1-3)
    pair00_RR_13={}; pair01_RR_13={}; pair10_RR_13={}; pair11_RR_13={}; pair00_RT_13={}; pair01_RT_13={}; pair10_RT_13={}; pair11_RT_13={}; 
                pair00_TR_13={}; pair01_TR_13={}; pair10_TR_13={}; pair11_TR_13={}; pair00_TT_13={}; pair01_TT_13={}; pair10_TT_13={}; pair11_TT_13={};
    % MISS_n vs HIT_n+1 comparisons (2-1)
    pair00_RR_21={}; pair01_RR_21={}; pair10_RR_21={}; pair11_RR_21={}; pair00_RT_21={}; pair01_RT_21={}; pair10_RT_21={}; pair11_RT_21={}; 
                pair00_TR_21={}; pair01_TR_21={}; pair10_TR_21={}; pair11_TR_21={}; pair00_TT_21={}; pair01_TT_21={}; pair10_TT_21={}; pair11_TT_21={};
    % MISS_n vs MISS_n+1 comparisons (2-2)
    pair00_RR_22={}; pair01_RR_22={}; pair10_RR_22={}; pair11_RR_22={}; pair00_RT_22={}; pair01_RT_22={}; pair10_RT_22={}; pair11_RT_22={}; 
                pair00_TR_22={}; pair01_TR_22={}; pair10_TR_22={}; pair11_TR_22={}; pair00_TT_22={}; pair01_TT_22={}; pair10_TT_22={}; pair11_TT_22={};
    % MISS_n vs FA_n+1 comparisons (2-3)
    pair00_RR_23={}; pair01_RR_23={}; pair10_RR_23={}; pair11_RR_23={}; pair00_RT_23={}; pair01_RT_23={}; pair10_RT_23={}; pair11_RT_23={}; 
                pair00_TR_23={}; pair01_TR_23={}; pair10_TR_23={}; pair11_TR_23={}; pair00_TT_23={}; pair01_TT_23={}; pair10_TT_23={}; pair11_TT_23={};
    % FA_n vs HIT_n+1 comparisons (3-1)
    pair00_RR_31={}; pair01_RR_31={}; pair10_RR_31={}; pair11_RR_31={}; pair00_RT_31={}; pair01_RT_31={}; pair10_RT_31={}; pair11_RT_31={}; 
                pair00_TR_31={}; pair01_TR_31={}; pair10_TR_31={}; pair11_TR_31={}; pair00_TT_31={}; pair01_TT_31={}; pair10_TT_31={}; pair11_TT_31={};
    % FA_n vs MISS_n+1 comparisons (3-2)
    pair00_RR_32={}; pair01_RR_32={}; pair10_RR_32={}; pair11_RR_32={}; pair00_RT_32={}; pair01_RT_32={}; pair10_RT_32={}; pair11_RT_32={}; 
                pair00_TR_32={}; pair01_TR_32={}; pair10_TR_32={}; pair11_TR_32={}; pair00_TT_32={}; pair01_TT_32={}; pair10_TT_32={}; pair11_TT_32={};
    % FA_n vs FA_n+1 comparisons (3-3)
    pair00_RR_33={}; pair01_RR_33={}; pair10_RR_33={}; pair11_RR_33={}; pair00_RT_33={}; pair01_RT_33={}; pair10_RT_33={}; pair11_RT_33={}; 
                pair00_TR_33={}; pair01_TR_33={}; pair10_TR_33={}; pair11_TR_33={}; pair00_TT_33={}; pair01_TT_33={}; pair10_TT_33={}; pair11_TT_33={};
            
    if fixedOrRandom % 1=Fixed
        trialStart = fixedHoldStartsAtTrial;
        trialEnd = allTrials(end);

        indFixed = find(arrStimTurnedOnTrials==fixedHoldStartsAtTrial,1);
        arrStimTurnedOnTrials = arrStimTurnedOnTrials(indFixed:end)-fixedHoldStartsAtTrial+1;
    else    % 0=Random
        trialStart = 1;
        trialEnd = fixedHoldStartsAtTrial-1;
        
        arrStimTurnedOnTrials = arrStimTurnedOnTrials(1:fixedHoldStartsAtTrial-1);
    end

    % Reorganize Behavioral Outcomes
    behavioralOutcome = zeros(1,trialEnd-trialStart+1);
    for ind=1:length(behavioralOutcome)
        if ~isempty(find(arrHitTrials==trialStart+ind-1,1))
            behavioralOutcome(ind) = 1; % HIT
        elseif ~isempty(find(arrMissTrials==trialStart+ind-1,1))
            behavioralOutcome(ind) = 2; % MISS
        elseif ~isempty(find(arrFaTrials==trialStart+ind-1,1))
            behavioralOutcome(ind) = 3; % FA
        end
    end
     
    % Select previous and current trial's spike times for CS and SS around Release(R) and Target(T) behavioral events
    for ind1=1:length(behavioralOutcome)-1        
        trialN_CSRelease = csTimesRelease{ind1}; % CS in trial n
        trialN_SSRelease = ssTimesRelease{ind1}; % SS in trial n
        trialN_CSReleaseROI = trialN_CSRelease(trialN_CSRelease>=CS_ANALYSIS_RANGE(1)&trialN_CSRelease<=CS_ANALYSIS_RANGE(2));
        trialN_SSReleaseROI = trialN_SSRelease(trialN_SSRelease>=SS_ANALYSIS_RANGE(1)&trialN_SSRelease<=SS_ANALYSIS_RANGE(2));

        trialNP1_CSRelease = csTimesRelease{ind1+1}; % CS in trial n+1
        trialNP1_SSRelease = ssTimesRelease{ind1+1}; % SS in trial n+1        
        trialNP1_CSReleaseROI = trialNP1_CSRelease(trialNP1_CSRelease>=CS_ANALYSIS_RANGE(1)&trialNP1_CSRelease<=CS_ANALYSIS_RANGE(2));
        trialNP1_SSReleaseROI = trialNP1_SSRelease(trialNP1_SSRelease>=SS_ANALYSIS_RANGE(1)&trialNP1_SSRelease<=SS_ANALYSIS_RANGE(2));
                    
        indTarget = find(arrStimTurnedOnTrials==ind1,1);
        indP1Target = find(arrStimTurnedOnTrials==(ind1+1),1);
        clear trialN_CSTargetROI trialN_SSTargetROI trialNP1_CSTargetROI trialNP1_SSTargetROI;

        if ~isempty(indTarget)
            trialN_CSTarget = csTimesTarget{indTarget}; % CS in trial n
            trialN_SSTarget = ssTimesTarget{indTarget}; % SS in trial n
            trialN_CSTargetROI = trialN_CSTarget(trialN_CSTarget>=CS_ANALYSIS_RANGE(1)&trialN_CSTarget<=CS_ANALYSIS_RANGE(2));
            trialN_SSTargetROI = trialN_SSTarget(trialN_SSTarget>=SS_ANALYSIS_RANGE(1)&trialN_SSTarget<=SS_ANALYSIS_RANGE(2));
        end
        if ~isempty(indP1Target)
            trialNP1_CSTarget = csTimesTarget{indP1Target}; % CS in trial n+1
            trialNP1_SSTarget = ssTimesTarget{indP1Target}; % SS in trial n+1        
            trialNP1_CSTargetROI = trialNP1_CSTarget(trialNP1_CSTarget>=CS_ANALYSIS_RANGE(1)&trialNP1_CSTarget<=CS_ANALYSIS_RANGE(2));
            trialNP1_SSTargetROI = trialNP1_SSTarget(trialNP1_SSTarget>=SS_ANALYSIS_RANGE(1)&trialNP1_SSTarget<=SS_ANALYSIS_RANGE(2));
        end
        
        newPair_RR = {trialN_SSReleaseROI trialNP1_SSReleaseROI};
        newPair_RT = {}; newPair_TR = {}; newPair_TT = {};
        if exist('trialNP1_SSTargetROI','var')
            newPair_RT = {trialN_SSReleaseROI trialNP1_SSTargetROI};
        end
        if exist('trialN_SSTargetROI','var')
            newPair_TR = {trialN_SSTargetROI trialNP1_SSReleaseROI};
        end
        if exist('trialN_SSTargetROI','var') && exist('trialNP1_SSTargetROI','var')
            newPair_TT = {trialN_SSTargetROI trialNP1_SSTargetROI};
        end

        pair00_RR = {};    pair01_RR = {};    pair10_RR = {};    pair11_RR = {};
        pair00_RT = {};    pair01_RT = {};    pair10_RT = {};    pair11_RT = {};
        pair00_TR = {};    pair01_TR = {};    pair10_TR = {};    pair11_TR = {};
        pair00_TT = {};    pair01_TT = {};    pair10_TT = {};    pair11_TT = {};
        % Release(trial_n) to Release(trial_n+1)
        if isempty(trialN_CSReleaseROI) % Trial n has NO CS within the Region Of Interest (ROI)
            if isempty(trialNP1_CSReleaseROI) % Trial n+1 has NO CS within the Region Of Interest (ROI)
                % 0-0
                pair00_RR = newPair_RR;
            else                            % Trial n+1 has CS within the Region Of Interest (ROI)
                % 0-1
                pair01_RR = newPair_RR;
            end
        else                                % Trial n has CS within the Region Of Interest (ROI)
            if isempty(trialNP1_CSReleaseROI) % Trial n+1 has no CS within the Region Of Interest (ROI)
                % 1-0
                pair10_RR = newPair_RR;
            else                            % Trial n+1 has CS within the Region Of Interest (ROI)
                % 1-1
                pair11_RR = newPair_RR;
            end
        end

        % Release(trial_n) to Target(trial_n+1) --> means we are now comparing SS spikes around Release(R) event at trial_n and SS spikes around Target(T) event
        if exist('trialNP1_CSTargetROI','var')
            if isempty(trialN_CSReleaseROI) % Trial n has NO CS within the Region Of Interest (ROI)
                if isempty(trialNP1_CSTargetROI) % Trial n+1 has NO CS within the Region Of Interest (ROI)
                    % 0-0
                    pair00_RT = newPair_RT;
                else  % Trial n+1 has CS within the Region Of Interest (ROI)
                    % 0-1
                    pair01_RT = newPair_RT;
                end
            else                                % Trial n has CS within the Region Of Interest (ROI)
                if isempty(trialNP1_CSTargetROI) % Trial n+1 has no CS within the Region Of Interest (ROI)
                    % 1-0
                    pair10_RT = newPair_RT;
                else % Trial n+1 has CS within the Region Of Interest (ROI)
                    % 1-1
                    pair11_RT = newPair_RT;
                end
            end
        end

        % Target(trial_n) to Release(trial_n+1)
        if exist('trialN_CSTargetROI','var')
            if isempty(trialN_CSTargetROI) % Trial n has NO CS within the Region Of Interest (ROI)
                if isempty(trialNP1_CSReleaseROI) % Trial n+1 has NO CS within the Region Of Interest (ROI)
                    % 0-0
                    pair00_TR = newPair_TR;
                else                            % Trial n+1 has CS within the Region Of Interest (ROI)
                    % 0-1
                    pair01_TR = newPair_TR;
                end
            else                                % Trial n has CS within the Region Of Interest (ROI)
                if isempty(trialNP1_CSReleaseROI) % Trial n+1 has no CS within the Region Of Interest (ROI)
                    % 1-0
                    pair10_TR = newPair_TR;
                else                            % Trial n+1 has CS within the Region Of Interest (ROI)
                    % 1-1
                    pair11_TR = newPair_TR;
                end
            end
        end

        % Target(trial_n) to Target(trial_n+1)
        if exist('trialN_CSTargetROI','var') && exist('trialNP1_CSTargetROI','var')
            if isempty(trialN_CSTargetROI) % Trial n has NO CS within the Region Of Interest (ROI)
                if isempty(trialNP1_CSTargetROI) % Trial n+1 has NO CS within the Region Of Interest (ROI)
                    % 0-0
                    pair00_TT = newPair_TT;
                else                            % Trial n+1 has CS within the Region Of Interest (ROI)
                    % 0-1
                    pair01_TT = newPair_TT;
                end
            else                                % Trial n has CS within the Region Of Interest (ROI)
                if isempty(trialNP1_CSTargetROI) % Trial n+1 has no CS within the Region Of Interest (ROI)
                    % 1-0
                    pair10_TT = newPair_TT;
                else                            % Trial n+1 has CS within the Region Of Interest (ROI)
                    % 1-1
                    pair11_TT = newPair_TT;
                end
            end
        end

        if behavioralOutcome(ind1)==1 && behavioralOutcome(ind1+1)==1 % HIT-HIT
            % HIT-HIT TRIAL PAIRS
            % 00 means NoCS_n to NoCS_n+1
            % RR means compare Relase time around trial_n to Release time around trial n+1
            % last 11 means Hit trial_n to Hit trial_n+1
            [pair00_RR_11, pair01_RR_11, pair10_RR_11, pair11_RR_11, pair00_RT_11, pair01_RT_11, pair10_RT_11, pair11_RT_11, ...
                pair00_TR_11, pair01_TR_11, pair10_TR_11, pair11_TR_11, pair00_TT_11, pair01_TT_11, pair10_TT_11, pair11_TT_11] = ...
                addCellArrays(pair00_RR_11,pair01_RR_11, pair10_RR_11, pair11_RR_11, pair00_RT_11, pair01_RT_11, pair10_RT_11, pair11_RT_11, ...
                pair00_TR_11, pair01_TR_11, pair10_TR_11, pair11_TR_11, pair00_TT_11, pair01_TT_11, pair10_TT_11, pair11_TT_11, ...
                pair00_RR, pair01_RR, pair10_RR, pair11_RR, pair00_RT, pair01_RT, pair10_RT, pair11_RT, ...
                pair00_TR, pair01_TR, pair10_TR, pair11_TR, pair00_TT, pair01_TT, pair10_TT, pair11_TT);
        elseif behavioralOutcome(ind1)==1 && behavioralOutcome(ind1+1)==2 % HIT-MISS
            [pair00_RR_12, pair01_RR_12, pair10_RR_12, pair11_RR_12, pair00_RT_12, pair01_RT_12, pair10_RT_12, pair11_RT_12, ...
                pair00_TR_12, pair01_TR_12, pair10_TR_12, pair11_TR_12, pair00_TT_12, pair01_TT_12, pair10_TT_12, pair11_TT_12] = ...
                addCellArrays(pair00_RR_12,pair01_RR_12, pair10_RR_12, pair11_RR_12, pair00_RT_12, pair01_RT_12, pair10_RT_12, pair11_RT_12, ...
                pair00_TR_12, pair01_TR_12, pair10_TR_12, pair11_TR_12, pair00_TT_12, pair01_TT_12, pair10_TT_12, pair11_TT_12, ...
                pair00_RR, pair01_RR, pair10_RR, pair11_RR, pair00_RT, pair01_RT, pair10_RT, pair11_RT, ...
                pair00_TR, pair01_TR, pair10_TR, pair11_TR, pair00_TT, pair01_TT, pair10_TT, pair11_TT);
        elseif behavioralOutcome(ind1)==1 && behavioralOutcome(ind1+1)==3 % HIT-FA
            [pair00_RR_13, pair01_RR_13, pair10_RR_13, pair11_RR_13, pair00_RT_13, pair01_RT_13, pair10_RT_13, pair11_RT_13, ...
                pair00_TR_13, pair01_TR_13, pair10_TR_13, pair11_TR_13, pair00_TT_13, pair01_TT_13, pair10_TT_13, pair11_TT_13] = ...
                addCellArrays(pair00_RR_13,pair01_RR_13, pair10_RR_13, pair11_RR_13, pair00_RT_13, pair01_RT_13, pair10_RT_13, pair11_RT_13, ...
                pair00_TR_13, pair01_TR_13, pair10_TR_13, pair11_TR_13, pair00_TT_13, pair01_TT_13, pair10_TT_13, pair11_TT_13, ...
                pair00_RR, pair01_RR, pair10_RR, pair11_RR, pair00_RT, pair01_RT, pair10_RT, pair11_RT, ...
                pair00_TR, pair01_TR, pair10_TR, pair11_TR, pair00_TT, pair01_TT, pair10_TT, pair11_TT);
        elseif behavioralOutcome(ind1)==2 && behavioralOutcome(ind1+1)==1 % MISS-HIT
            [pair00_RR_21, pair01_RR_21, pair10_RR_21, pair11_RR_21, pair00_RT_21, pair01_RT_21, pair10_RT_21, pair11_RT_21, ...
                pair00_TR_21, pair01_TR_21, pair10_TR_21, pair11_TR_21, pair00_TT_21, pair01_TT_21, pair10_TT_21, pair11_TT_21] = ...
                addCellArrays(pair00_RR_21,pair01_RR_21, pair10_RR_21, pair11_RR_21, pair00_RT_21, pair01_RT_21, pair10_RT_21, pair11_RT_21, ...
                pair00_TR_21, pair01_TR_21, pair10_TR_21, pair11_TR_21, pair00_TT_21, pair01_TT_21, pair10_TT_21, pair11_TT_21, ...
                pair00_RR, pair01_RR, pair10_RR, pair11_RR, pair00_RT, pair01_RT, pair10_RT, pair11_RT, ...
                pair00_TR, pair01_TR, pair10_TR, pair11_TR, pair00_TT, pair01_TT, pair10_TT, pair11_TT);
        elseif behavioralOutcome(ind1)==2 && behavioralOutcome(ind1+1)==2 % MISS-MISS
            [pair00_RR_22, pair01_RR_22, pair10_RR_22, pair11_RR_22, pair00_RT_22, pair01_RT_22, pair10_RT_22, pair11_RT_22, ...
                pair00_TR_22, pair01_TR_22, pair10_TR_22, pair11_TR_22, pair00_TT_22, pair01_TT_22, pair10_TT_22, pair11_TT_22] = ...
                addCellArrays(pair00_RR_22,pair01_RR_22, pair10_RR_22, pair11_RR_22, pair00_RT_22, pair01_RT_22, pair10_RT_22, pair11_RT_22, ...
                pair00_TR_22, pair01_TR_22, pair10_TR_22, pair11_TR_22, pair00_TT_22, pair01_TT_22, pair10_TT_22, pair11_TT_22, ...
                pair00_RR, pair01_RR, pair10_RR, pair11_RR, pair00_RT, pair01_RT, pair10_RT, pair11_RT, ...
                pair00_TR, pair01_TR, pair10_TR, pair11_TR, pair00_TT, pair01_TT, pair10_TT, pair11_TT);
        elseif behavioralOutcome(ind1)==2 && behavioralOutcome(ind1+1)==3 % MISS-FA
            [pair00_RR_23, pair01_RR_23, pair10_RR_23, pair11_RR_23, pair00_RT_23, pair01_RT_23, pair10_RT_23, pair11_RT_23, ...
                pair00_TR_23, pair01_TR_23, pair10_TR_23, pair11_TR_23, pair00_TT_23, pair01_TT_23, pair10_TT_23, pair11_TT_23] = ...
                addCellArrays(pair00_RR_23,pair01_RR_23, pair10_RR_23, pair11_RR_23, pair00_RT_23, pair01_RT_23, pair10_RT_23, pair11_RT_23, ...
                pair00_TR_23, pair01_TR_23, pair10_TR_23, pair11_TR_23, pair00_TT_23, pair01_TT_23, pair10_TT_23, pair11_TT_23, ...
                pair00_RR, pair01_RR, pair10_RR, pair11_RR, pair00_RT, pair01_RT, pair10_RT, pair11_RT, ...
                pair00_TR, pair01_TR, pair10_TR, pair11_TR, pair00_TT, pair01_TT, pair10_TT, pair11_TT);
        elseif behavioralOutcome(ind1)==3 && behavioralOutcome(ind1+1)==1 % FA-HIT            
            [pair00_RR_31, pair01_RR_31, pair10_RR_31, pair11_RR_31, pair00_RT_31, pair01_RT_31, pair10_RT_31, pair11_RT_31, ...
                pair00_TR_31, pair01_TR_31, pair10_TR_31, pair11_TR_31, pair00_TT_31, pair01_TT_31, pair10_TT_31, pair11_TT_31] = ...
                addCellArrays(pair00_RR_31,pair01_RR_31, pair10_RR_31, pair11_RR_31, pair00_RT_31, pair01_RT_31, pair10_RT_31, pair11_RT_31, ...
                pair00_TR_31, pair01_TR_31, pair10_TR_31, pair11_TR_31, pair00_TT_31, pair01_TT_31, pair10_TT_31, pair11_TT_31, ...
                pair00_RR, pair01_RR, pair10_RR, pair11_RR, pair00_RT, pair01_RT, pair10_RT, pair11_RT, ...
                pair00_TR, pair01_TR, pair10_TR, pair11_TR, pair00_TT, pair01_TT, pair10_TT, pair11_TT);
        elseif behavioralOutcome(ind1)==3 && behavioralOutcome(ind1+1)==2 % FA-MISS
            [pair00_RR_32, pair01_RR_32, pair10_RR_32, pair11_RR_32, pair00_RT_32, pair01_RT_32, pair10_RT_32, pair11_RT_32, ...
                pair00_TR_32, pair01_TR_32, pair10_TR_32, pair11_TR_32, pair00_TT_32, pair01_TT_32, pair10_TT_32, pair11_TT_32] = ...
                addCellArrays(pair00_RR_32,pair01_RR_32, pair10_RR_32, pair11_RR_32, pair00_RT_32, pair01_RT_32, pair10_RT_32, pair11_RT_32, ...
                pair00_TR_32, pair01_TR_32, pair10_TR_32, pair11_TR_32, pair00_TT_32, pair01_TT_32, pair10_TT_32, pair11_TT_32, ...
                pair00_RR, pair01_RR, pair10_RR, pair11_RR, pair00_RT, pair01_RT, pair10_RT, pair11_RT, ...
                pair00_TR, pair01_TR, pair10_TR, pair11_TR, pair00_TT, pair01_TT, pair10_TT, pair11_TT);
        elseif behavioralOutcome(ind1)==3 && behavioralOutcome(ind1+1)==3 % FA-FA
            [pair00_RR_33, pair01_RR_33, pair10_RR_33, pair11_RR_33, pair00_RT_33, pair01_RT_33, pair10_RT_33, pair11_RT_33, ...
                pair00_TR_33, pair01_TR_33, pair10_TR_33, pair11_TR_33, pair00_TT_33, pair01_TT_33, pair10_TT_33, pair11_TT_33] = ...
                addCellArrays(pair00_RR_33,pair01_RR_33, pair10_RR_33, pair11_RR_33, pair00_RT_33, pair01_RT_33, pair10_RT_33, pair11_RT_33, ...
                pair00_TR_33, pair01_TR_33, pair10_TR_33, pair11_TR_33, pair00_TT_33, pair01_TT_33, pair10_TT_33, pair11_TT_33, ...
                pair00_RR, pair01_RR, pair10_RR, pair11_RR, pair00_RT, pair01_RT, pair10_RT, pair11_RT, ...
                pair00_TR, pair01_TR, pair10_TR, pair11_TR, pair00_TT, pair01_TT, pair10_TT, pair11_TT);
        end
    end
        
    plotSSRateChange(pair00_RR_11, pair01_RR_11, pair10_RR_11, pair11_RR_11, csID, ssID, sFolderName, '_HIT_Rel_HIT_Rel', 'from HIT_{n} Release to HIT_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_RT_11, pair01_RT_11, pair10_RT_11, pair11_RT_11, csID, ssID, sFolderName, '_HIT_Rel_HIT_Target', 'from HIT_{n} Release to HIT_{n+1} Target', fixedOrRandom);
    plotSSRateChange(pair00_TR_11, pair01_TR_11, pair10_TR_11, pair11_TR_11, csID, ssID, sFolderName, '_HIT_Target_HIT_Rel', 'from HIT_{n} Target to HIT_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_TT_11, pair01_TT_11, pair10_TT_11, pair11_TT_11, csID, ssID, sFolderName, '_HIT_Target_HIT_Target', 'from HIT_{n} Target to HIT_{n+1} Target', fixedOrRandom);

    plotSSRateChange(pair00_RR_12, pair01_RR_12, pair10_RR_12, pair11_RR_12, csID, ssID, sFolderName, '_HIT_Rel_MISS_Rel', 'from HIT_{n} Release to MISS_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_RT_12, pair01_RT_12, pair10_RT_12, pair11_RT_12, csID, ssID, sFolderName, '_HIT_Rel_MISS_Target', 'from HIT_{n} Release to MISS_{n+1} Target', fixedOrRandom);
    plotSSRateChange(pair00_TR_12, pair01_TR_12, pair10_TR_12, pair11_TR_12, csID, ssID, sFolderName, '_HIT_Target_MISS_Rel', 'from HIT_{n} Target to MISS_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_TT_12, pair01_TT_12, pair10_TT_12, pair11_TT_12, csID, ssID, sFolderName, '_HIT_Target_MISS_Target', 'from HIT_{n} Target to MISS_{n+1} Target', fixedOrRandom);

    plotSSRateChange(pair00_RR_13, pair01_RR_13, pair10_RR_13, pair11_RR_13, csID, ssID, sFolderName, '_HIT_Rel_FA_Rel', 'from HIT_{n} Release to FA_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_RT_13, pair01_RT_13, pair10_RT_13, pair11_RT_13, csID, ssID, sFolderName, '_HIT_Rel_FA_Target', 'from HIT_{n} Release to FA_{n+1} Target', fixedOrRandom);
    plotSSRateChange(pair00_TR_13, pair01_TR_13, pair10_TR_13, pair11_TR_13, csID, ssID, sFolderName, '_HIT_Target_FA_Rel', 'from HIT_{n} Target to FA_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_TT_13, pair01_TT_13, pair10_TT_13, pair11_TT_13, csID, ssID, sFolderName, '_HIT_Target_FA_Target', 'from HIT_{n} Target to FA_{n+1} Target', fixedOrRandom);

    plotSSRateChange(pair00_RR_21, pair01_RR_21, pair10_RR_21, pair11_RR_21, csID, ssID, sFolderName, '_MISS_Rel_HIT_Rel', 'from MISS_{n} Release to HIT_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_RT_21, pair01_RT_21, pair10_RT_21, pair11_RT_21, csID, ssID, sFolderName, '_MISS_Rel_HIT_Target', 'from MISS_{n} Release to HIT_{n+1} Target', fixedOrRandom);
    plotSSRateChange(pair00_TR_21, pair01_TR_21, pair10_TR_21, pair11_TR_21, csID, ssID, sFolderName, '_MISS_Target_HIT_Rel', 'from MISS_{n} Target to HIT_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_TT_21, pair01_TT_21, pair10_TT_21, pair11_TT_21, csID, ssID, sFolderName, '_MISS_Target_HIT_Target', 'from MISS_{n} Target to HIT_{n+1} Target', fixedOrRandom);

    plotSSRateChange(pair00_RR_22, pair01_RR_22, pair10_RR_22, pair11_RR_22, csID, ssID, sFolderName, '_MISS_Rel_MISS_Rel', 'from MISS_{n} Release to MISS_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_RT_22, pair01_RT_22, pair10_RT_22, pair11_RT_22, csID, ssID, sFolderName, '_MISS_Rel_MISS_Target', 'from MISS_{n} Release to MISS_{n+1} Target', fixedOrRandom);
    plotSSRateChange(pair00_TR_22, pair01_TR_22, pair10_TR_22, pair11_TR_22, csID, ssID, sFolderName, '_MISS_Target_MISS_Rel', 'from MISS_{n} Target to MISS_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_TT_22, pair01_TT_22, pair10_TT_22, pair11_TT_22, csID, ssID, sFolderName, '_MISS_Target_MISS_Target', 'from MISS_{n} Target to MISS_{n+1} Target', fixedOrRandom);
   
    plotSSRateChange(pair00_RR_23, pair01_RR_23, pair10_RR_23, pair11_RR_23, csID, ssID, sFolderName, '_MISS_Rel_FA_Rel', 'from MISS_{n} Release to FA_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_RT_23, pair01_RT_23, pair10_RT_23, pair11_RT_23, csID, ssID, sFolderName, '_MISS_Rel_FA_Target', 'from MISS_{n} Release to FA_{n+1} Target', fixedOrRandom);
    plotSSRateChange(pair00_TR_23, pair01_TR_23, pair10_TR_23, pair11_TR_23, csID, ssID, sFolderName, '_MISS_Target_FA_Rel', 'from MISS_{n} Target to FA_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_TT_23, pair01_TT_23, pair10_TT_23, pair11_TT_23, csID, ssID, sFolderName, '_MISS_Target_FA_Target', 'from MISS_{n} Target to FA_{n+1} Target', fixedOrRandom);

    plotSSRateChange(pair00_RR_31, pair01_RR_31, pair10_RR_31, pair11_RR_31, csID, ssID, sFolderName, '_FA_Rel_HIT_Rel', 'from FA_{n} Release to HIT_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_RT_31, pair01_RT_31, pair10_RT_31, pair11_RT_31, csID, ssID, sFolderName, '_FA_Rel_HIT_Target', 'from FA_{n} Release to HIT_{n+1} Target', fixedOrRandom);
    plotSSRateChange(pair00_TR_31, pair01_TR_31, pair10_TR_31, pair11_TR_31, csID, ssID, sFolderName, '_FA_Target_HIT_Rel', 'from FA_{n} Target to HIT_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_TT_31, pair01_TT_31, pair10_TT_31, pair11_TT_31, csID, ssID, sFolderName, '_FA_Target_HIT_Target', 'from FA_{n} Target to HIT_{n+1} Target', fixedOrRandom);

    plotSSRateChange(pair00_RR_32, pair01_RR_32, pair10_RR_32, pair11_RR_32, csID, ssID, sFolderName, '_FA_Rel_MISS_Rel', 'from FA_{n} Release to MISS_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_RT_32, pair01_RT_32, pair10_RT_32, pair11_RT_32, csID, ssID, sFolderName, '_FA_Rel_MISS_Target', 'from FA_{n} Release to MISS_{n+1} Target', fixedOrRandom);
    plotSSRateChange(pair00_TR_32, pair01_TR_32, pair10_TR_32, pair11_TR_32, csID, ssID, sFolderName, '_FA_Target_MISS_Rel', 'from FA_{n} Target to MISS_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_TT_32, pair01_TT_32, pair10_TT_32, pair11_TT_32, csID, ssID, sFolderName, '_FA_Target_MISS_Target', 'from FA_{n} Target to MISS_{n+1} Target', fixedOrRandom);
   
    plotSSRateChange(pair00_RR_33, pair01_RR_33, pair10_RR_33, pair11_RR_33, csID, ssID, sFolderName, '_FA_Rel_FA_Rel', 'from FA_{n} Release to FA_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_RT_33, pair01_RT_33, pair10_RT_33, pair11_RT_33, csID, ssID, sFolderName, '_FA_Rel_FA_Target', 'from FA_{n} Release to FA_{n+1} Target', fixedOrRandom);
    plotSSRateChange(pair00_TR_33, pair01_TR_33, pair10_TR_33, pair11_TR_33, csID, ssID, sFolderName, '_FA_Target_FA_Rel', 'from FA_{n} Target to FA_{n+1} Release', fixedOrRandom);
    plotSSRateChange(pair00_TT_33, pair01_TT_33, pair10_TT_33, pair11_TT_33, csID, ssID, sFolderName, '_FA_Target_FA_Target', 'from FA_{n} Target to FA_{n+1} Target', fixedOrRandom);
   
end