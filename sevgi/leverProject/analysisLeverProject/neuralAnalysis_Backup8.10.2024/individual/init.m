function [arrHitTrials, arrFaTrials, arrMissTrials, arrStimTurnedOnTrials, arrReqHoldTimes, arrReactTimes, tooFastTime, reactTime, preHoldTime, fixedHoldStartsAtTrial, ...
    leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, ...
    trialCutIndex, omissionTrials, nonOmissionTrials] = init()

        globals;
        %%%%%%%%%%%% Read Behavioral measures %%%%%%%%%%
        
        fHoldId = fopen([pathTPrime HOLD_LEVER_TXT]);
        leverHoldTimesGLX = fscanf(fHoldId, '%f')'; % seconds
        fclose(fHoldId);
        
        fReleaseId = fopen([pathTPrime RELEASE_LEVER_TXT]);
        leverReleaseTimesGLX = fscanf(fReleaseId, '%f')'; % seconds
        fclose(fReleaseId);
        
        fVisOnId = fopen([pathTPrime VIS_STIM_ON_TXT]);
        targetStimTimesGLX = fscanf(fVisOnId, '%f')'; % seconds
        fclose(fVisOnId);
        
        fVisOffId = fopen([pathTPrime VIS_STIM_OFF_TXT]);
        baselineStimTimesGLX = fscanf(fVisOffId, '%f')'; % seconds
        fclose(fVisOffId);
        
        fLickOnsetId = fopen([pathTPrime LICK_ONSET_TXT]);
        if fLickOnsetId~=-1
            lickOnsetTimesGLX = fscanf(fLickOnsetId, '%f')'; % seconds
            fclose(fLickOnsetId);
        else
            lickOnsetTimesGLX = [];
        end        
        
        fLickOffsetId = fopen([pathTPrime LICK_OFFSET_TXT]);
        if fLickOffsetId~=-1
            lickOffsetTimesGLX = fscanf(fLickOffsetId, '%f')'; % seconds
            fclose(fLickOffsetId);
        else
            lickOffsetTimesGLX = [];
        end
        
        fRewardOnsetId = fopen([pathTPrime REWARD_ONSET_TXT]);
        if fRewardOnsetId~=-1
            rewardOnsetTimesGLX = fscanf(fRewardOnsetId, '%f')'; % seconds
            fclose(fRewardOnsetId);
        else
            rewardOnsetTimesGLX = [];
        end
        
        fRewardOffsetId = fopen([pathTPrime REWARD_OFFSET_TXT]);
        if fRewardOffsetId~=-1
            rewardOffsetTimesGLX = fscanf(fRewardOffsetId, '%f')'; % seconds
            fclose(fRewardOffsetId);
        else
            rewardOffsetTimesGLX = [];
        end
        
        % SOFT_CUT or HARD_CUT processing
        trialCutIndex = [];
        if SOFT_CUT~=Inf || HARD_CUT~=Inf  % If there is a soft or hard cut point of the recording
            if SOFT_CUT~=Inf 
                CUT_POINT = SOFT_CUT;
                PARTITION = SOFT_CUT_PARTITION;
            elseif HARD_CUT~=Inf
                CUT_POINT = HARD_CUT;
                PARTITION = SOFT_CUT_PARTITION;
            end
        
            if PARTITION==1 % Get the first part of the recording
                indTimes = find(leverHoldTimesGLX>0 & leverHoldTimesGLX<=CUT_POINT);
                leverHoldTimesGLX = leverHoldTimesGLX(indTimes);
        
                indTimes = find(leverReleaseTimesGLX>0 & leverReleaseTimesGLX<=CUT_POINT);
                leverReleaseTimesGLX = leverReleaseTimesGLX(indTimes);
        
                indTimes = find(targetStimTimesGLX>0 & targetStimTimesGLX<=CUT_POINT);
                targetStimTimesGLX = targetStimTimesGLX(indTimes);
        
                indTimes = find(baselineStimTimesGLX>0 & baselineStimTimesGLX<=CUT_POINT);
                baselineStimTimesGLX = baselineStimTimesGLX(indTimes);
                
                indTimes = find(lickOnsetTimesGLX>0 & lickOnsetTimesGLX<=CUT_POINT);
                lickOnsetTimesGLX = lickOnsetTimesGLX(indTimes);
        
                indTimes = find(lickOffsetTimesGLX>0 & lickOffsetTimesGLX<=CUT_POINT);
                lickOffsetTimesGLX = lickOffsetTimesGLX(indTimes);
        
                indTimes = find(rewardOnsetTimesGLX>0 & rewardOnsetTimesGLX<=CUT_POINT);
                rewardOnsetTimesGLX = rewardOnsetTimesGLX(indTimes);
        
                indTimes = find(rewardOffsetTimesGLX>0 & rewardOffsetTimesGLX<=CUT_POINT);
                rewardOffsetTimesGLX = rewardOffsetTimesGLX(indTimes);
        
                trialCutIndex = length(leverHoldTimesGLX);
            else % get the rest
                indTimes = find(leverHoldTimesGLX>CUT_POINT);
                trialCutIndex = indTimes(1);
                leverHoldTimesGLX = leverHoldTimesGLX(indTimes);
        
                indTimes = find(leverReleaseTimesGLX>CUT_POINT);
                leverReleaseTimesGLX = leverReleaseTimesGLX(indTimes);
        
                indTimes = find(targetStimTimesGLX>CUT_POINT);
                targetStimTimesGLX = targetStimTimesGLX(indTimes);
        
                indTimes = find(baselineStimTimesGLX>CUT_POINT);
                baselineStimTimesGLX = baselineStimTimesGLX(indTimes);
        
                indTimes = find(lickOnsetTimesGLX>CUT_POINT);
                lickOnsetTimesGLX = lickOnsetTimesGLX(indTimes);
        
                indTimes = find(lickOffsetTimesGLX>CUT_POINT);
                lickOffsetTimesGLX = lickOffsetTimesGLX(indTimes);
        
                indTimes = find(rewardOnsetTimesGLX>CUT_POINT);
                rewardOnsetTimesGLX = rewardOnsetTimesGLX(indTimes);
        
                indTimes = find(rewardOffsetTimesGLX>CUT_POINT);
                rewardOffsetTimesGLX = rewardOffsetTimesGLX(indTimes);
            end
        end
        
        holdReleaseTimeGLX = 1000*(leverReleaseTimesGLX-leverHoldTimesGLX); % ms
        visStimDurationGLX = 1000*(baselineStimTimesGLX-targetStimTimesGLX); % ms
        
        %%%%%%%%%%%% Read Behavioral Data from MWorks-LabJack system %%%%%%%%%%%%%
        
        [arrHitTrials, arrFaTrials, arrMissTrials, arrStimTurnedOnTrials, arrReqHoldTimes, arrReactTimes, tooFastTime, reactTime, preHoldTime, fixedHoldStartsAtTrial, omissionTrials, nonOmissionTrials] = readBehavioralData(trialCutIndex); % hint trial count from SpikeGLX system when we're soft-cutting the record
        
        %%%%%%%%%%%%%%%%%%%%%%% MANUAL CURATION FOR 20221104 recording, cos it had 2 behavioral data files%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % leverHoldTimesGLX1 = leverHoldTimesGLX(1:94);% removed last one from the first session's (it was 95 trials) cos will shift one
        % leverHoldTimesGLX2 = leverHoldTimesGLX(96:end-1);
        % leverHoldTimesGLX = [0 leverHoldTimesGLX1 leverHoldTimesGLX2]; % Manual curation: added one trial in front, removed one from the first session's
        % 
        % leverReleaseTimesGLX1 = leverReleaseTimesGLX(1:94);% removed last one from the first session's (it was 95 trials) cos will shift one
        % leverReleaseTimesGLX2 = leverReleaseTimesGLX(96:end-1);
        % leverReleaseTimesGLX = [0 leverReleaseTimesGLX1 leverReleaseTimesGLX2]; % Manual curation: added one trial in front, removed one from the first session's
        % 
        % holdReleaseTimeGLX = 1000*(leverReleaseTimesGLX-leverHoldTimesGLX); % ms % Calculate again after manual curation
        
        %%%%%%% SANITY CHECK!: Is there any inconcistency between these two system(MWorks-SpikeGLX) in terms of behavior %%%%%%%%%%%%%%%
        lenMWorks = length(arrReqHoldTimes);
        lenSpGLX = length(holdReleaseTimeGLX);
        if lenMWorks~=lenSpGLX % Started MWorks first, then SpikeGLX OR Stopped SpikeGLX first,then MWorks    
            logger.error('main',['CANNOT Align trials from two system! Manual curation is needed! MWorks: ' num2str(lenMWorks) ' SpikeGLX: ' num2str(lenSpGLX)]);
            exit 1
        else
            %candidateStimTurnedOnTrialsGLX = find(holdReleaseTimeGLX-arrReqHoldTimes-LATENCY_MWorks>0 ); % include hits exclude fa and misses
            candidateStimTurnedOnTrialsGLX = find(holdReleaseTimeGLX-LAG_SGLX>arrReqHoldTimes); % include every trial that has visual stim change %  & holdReleaseTimeGLX<(reactTime+preHoldTime+tooFastTime)
            
            if length(candidateStimTurnedOnTrialsGLX)~= length(arrStimTurnedOnTrials)
                logger.error('main',['StimTurnedOnTrial numbers are different on two systems! Probably latency of MWorks changed! Number of StimTurnedOn trials MWorks arrStimTurnedOnTrials: ' num2str(length(arrStimTurnedOnTrials)) ' SpikeGLX candidateStimTurnedOnTrials: ' num2str(length(candidateStimTurnedOnTrialsGLX))]);
            elseif length(targetStimTimesGLX)~= length(arrStimTurnedOnTrials) || length(baselineStimTimesGLX)~= length(arrStimTurnedOnTrials)
                logger.error('main',['StimTurnedOnTrial numbers are different on two systems! Number of StimTurnedOn trials MWorks arrStimTurnedOnTrials: ' num2str(length(arrStimTurnedOnTrials)) ' SpikeGLX targetStimTimes: ' num2str(length(targetStimTimesGLX)) ' visStimOffTimes: ' num2str(length(baselineStimTimesGLX))]);
            elseif candidateStimTurnedOnTrialsGLX==arrStimTurnedOnTrials
                logger.info('main','StimTurnedOnTrial numbers are equally aligned.'); 
                
                % Compare react times
                %reactTimesGLX = 1000*(leverReleaseTimesGLX(candidateStimTurnedOnTrialsGLX)-targetStimTimesGLX);
                %reactTimesMWorks = arrReactTimes(arrStimTurnedOnTrials); % get only stim on trial's react times cos GLX cannot know the react times os stim-not-yet-on trial's react times
        
                % Is this OVERKILL !!! I observed different lags for hit/miss trials between SpikeGLX and MWorks! It turned out to be coding specific to the dataset which is bullshit!
        %         candidateHitTrialsGLX = find(holdReleaseTimeGLX-LAG_SGLX>arrReqHoldTimes+tooFastTime & holdReleaseTimeGLX-LAG_SGLX<reactTime);
        %         if length(candidateHitTrialsGLX)~=length(arrHitTrials)
        %             error(['HitTrials numbers are different on two systems! Probably latency/tooFastTime of MWorks changed! Number of Hit trials MWorks: ' num2str(lenght(arrHitTrials)) ' SpikeGLX: ' num2str(length(candidateHitTrialsGLX))]);
        %         elseif candidateHitTrialsGLX==arrHitTrials
        %             candidateHitTrialInds = find(visStimDurationGLX>tooFastTime); % other way to double-check hit trial numbers
        %             candidateHitTrialsGLX2 = candidateStimTurnedOnTrialsGLX(candidateHitTrialInds);
        %             if candidateHitTrialsGLX2~=arrHitTrials
        %                 error('Something is WRONG! candidateHitTrials2~=arrHitTrials');
        %             else
        %                 disp('HURRAAAY! Hit trial numbers match on both system.');
        %             end
        %         end
            end
        end
        %%%%%%% SANITY CHECK!: Is there any inconcistency between these two system(MWorks-SpikeGLX) in terms of behavior %%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%% IMPORTANT !!! - ALIGN ACC TO PREHOLD TIME defined in LabJack %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        leverHoldTimes = leverHoldTimesGLX - preHoldTime/1000; % actual press initiation starts in the beginning of preHoldTime, so shift time back!
        %%%%%%%%%%%%%%%%%%%%%%%% ALIGN ACC TO PREHOLD TIME defined in LabJack %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end