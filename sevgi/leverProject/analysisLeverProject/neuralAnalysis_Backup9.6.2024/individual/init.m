function [arrHitTrials, arrFaTrials, arrMissTrials, arrStimTurnedOnTrials, arrReqHoldTimesMWorksMs, arrReactTimesMWorksMs, tooFastTime, reactTime, preHoldTimeMs, fixedHoldStartsAtTrial, ...
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

        count=0;
        minLength = min(length(leverHoldTimesGLX),length(leverReleaseTimesGLX));
        diffRelHold = leverReleaseTimesGLX(1:minLength)-leverHoldTimesGLX(1:minLength);

        while any(diffRelHold<0)
            indNegativeDiff = find(diffRelHold<0);
            logger.error('init',['DISCREPANCY TYPE 1: Release times cannot be smaller than Hold times! Release time= ' num2str(leverReleaseTimesGLX(indNegativeDiff(1))) ' at location:' num2str(indNegativeDiff(1))]);
            leverReleaseTimesGLX(indNegativeDiff(1)) = [];            
            count = count+1;
            minLength = min(length(leverHoldTimesGLX),length(leverReleaseTimesGLX));
            diffRelHold = leverReleaseTimesGLX(1:minLength)-leverHoldTimesGLX(1:minLength);
            if count>5
                logger.error('init',['After trying ' num2str(count) ' times for DISCREPANCY TYPE 1 (Release times cannot be smaller than Hold times!) quit, since there must be some other problem']);
                exit 1
            end
        end

        if length(leverHoldTimesGLX)~=length(leverReleaseTimesGLX)
            % Who has the glitch! If duplicates less than a ms, ignore the second data point cos it cannot be true - the mouse cannot press (or release) faster than a ms
            diffHolds = diff(leverHoldTimesGLX);
            indGlitches = find(diffHolds<.001);
            if ~isempty(indGlitches)
                leverHoldTimesGLX = leverHoldTimesGLX(setdiff(1:end,indGlitches+1)); % Eliminate the next elements of glitch indices, get the first arriving data point
                logger.info('init',['Glitched data points (less than ms difference between holds!) eliminated from leverHoldTimes at indices:' num2str(indGlitches+1)]);
            end

            if length(leverHoldTimesGLX)~=length(leverReleaseTimesGLX) % if still different, check leverRelease too
                diffReleases = diff(leverReleaseTimesGLX);
                indGlitches = find(diffReleases<.001);
                if ~isempty(indGlitches)
                    leverReleaseTimesGLX = leverReleaseTimesGLX(setdiff(1:end,indGlitches+1)); % Eliminate the next elements of glitch indices, get the first arriving data point
                    logger.info('init',['Glitched data points (less than ms difference between releases!) eliminated from leverReleaseTimes at indices:' num2str(indGlitches+1)]);
                end
                
                if length(leverHoldTimesGLX)~=length(leverReleaseTimesGLX) % if still different, check leverRelease too
                   minLen =  min(length(leverHoldTimesGLX),length(leverReleaseTimesGLX));
                   for indLev=1:minLen
                       diffRelHold = leverReleaseTimesGLX(indLev)-leverHoldTimesGLX(indLev);
                       if diffRelHold<.001 % The difference between release and hold CANNOT be less than 1 ms - Unfortunately CatGT's duration parameter does not work!
                           logger.info('init',['Glitched data points (less than ms difference between holds and releases!) eliminated from leverReleaseTimes:' num2str(leverReleaseTimesGLX(indLev)) ' at indices:' num2str(indLev)]);
                           leverReleaseTimesGLX(indLev) = [];
                       end
                       if length(leverHoldTimesGLX)==length(leverReleaseTimesGLX) 
                           break;
                       end
                   end
                end
            end        
        end
        
        if length(leverHoldTimesGLX)~=length(leverReleaseTimesGLX) 
            logger.error('init',['CANNOT Align HOLD/RELEASE times from SpikeGLX! Manual curation is needed! Holds: ' num2str(length(leverHoldTimesGLX)) ' Releases: ' num2str(length(leverReleaseTimesGLX) )]);
            exit 1
        else
        
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
           
            visStimDurationGLX = 1000*(baselineStimTimesGLX-targetStimTimesGLX); % ms
                    
            %%%%%%%%%%%% Read Behavioral Data from MWorks-LabJack system %%%%%%%%%%%%%        
            [arrHitTrials, arrFaTrials, arrMissTrials, arrStimTurnedOnTrials, arrReqHoldTimesMWorksMs, arrHoldStartsMWorksMs, arrReactTimesMWorksMs, tooFastTime, reactTime, preHoldTimeMs, fixedHoldStartsAtTrial, omissionTrials, nonOmissionTrials] = readBehavioralData(trialCutIndex); % hint trial count from SpikeGLX system when we're soft-cutting the record
            
            %%%%%%%%%%%%%%%%%%%%%%%% IMPORTANT !!! - ALIGN ACC TO PREHOLD TIME defined in LabJack %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            leverHoldTimes = leverHoldTimesGLX - preHoldTimeMs/1000; % actual press initiation starts in the beginning of preHoldTime, so shift time back!
            arrReqHoldTimesMWorksMs = arrReqHoldTimesMWorksMs + preHoldTimeMs; % Total req hold times did not included preHoldTime in HoldAndDetectConstant8.xml, so add it here
            %%%%%%%%%%%%%%%%%%%%%%%% ALIGN ACC TO PREHOLD TIME defined in LabJack %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            arrHoldStartsMWorksMs = double(arrHoldStartsMWorksMs) - preHoldTimeMs;
            diffOfStartFor2systemsMs = leverHoldTimes(1)*1000-arrHoldStartsMWorksMs(1);
            arrHoldStartsMWorksMs = arrHoldStartsMWorksMs + diffOfStartFor2systemsMs; % To ajdust these two systems's timestamps
    
            %%%%%%%%%%%%%%%%%%%%%%% MANUAL CURATION FOR 20240328 recording, it has extra element in arrReactTimes %%%%%%%%%%%%%%%%%%%%%%%%%
            % NO NEED THESE COS I CUT THE RECORDING AT TRIAL=100
    %         arrReactTimesMWorksMs = [arrReactTimesMWorksMs(1:127) arrReactTimesMWorksMs(129:end)];
    %         arrReqHoldTimesMWorksMs = [arrReqHoldTimesMWorksMs(1:127) arrReqHoldTimesMWorksMs(129:end)];
    %         arrHoldStartsMWorksMs = [arrHoldStartsMWorksMs(1:127) arrHoldStartsMWorksMs(129:end)];
    %         indFaulty = find(arrFaTrials==128);
    %         arrFaTrials = [arrFaTrials(1:indFaulty-1) arrFaTrials(indFaulty+1:end)];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            leverHoldTimesMs = leverHoldTimes*1000;
            latencyof2systemsOnHoldMs = leverHoldTimesMs-arrHoldStartsMWorksMs;
            logger.info('main', ['Mean latencyof2systemsOnHoldMs=' num2str(mean(latencyof2systemsOnHoldMs),'%.2f')]);
    
            targetStimTimesMWorksMs = (double(arrHoldStartsMWorksMs) + arrReqHoldTimesMWorksMs);
            
            %%%%% FIND REACTION TIMES IN SPIKE GLX %%%%%%%%%%%%%%%%%%%%        
            leverReleaseTimesMs = leverReleaseTimesGLX*1000;
            targetStimTimesGLXMs = targetStimTimesGLX*1000;
            arrStimTurnedOnTrialsGLXMs = zeros(1,length(leverHoldTimesMs));
            for iStim=1:length(targetStimTimesGLXMs)
                indTrial = find(targetStimTimesGLXMs(iStim)>leverHoldTimesMs & targetStimTimesGLXMs(iStim)<leverReleaseTimesMs);
                if indTrial>iStim % some of the trials could not have visual cue - False alarms
                    for iFa=iStim:indTrial-1
                        if arrStimTurnedOnTrialsGLXMs(iFa)==0
                            arrStimTurnedOnTrialsGLXMs(iFa) = leverHoldTimesMs(iStim)+arrReqHoldTimesMWorksMs(iStim); % The time when visual cue is planned to show but couldn't since this is a FA trial. leverHoldTimes shifted back by preHold time so no worries!
                        end
                    end
                end
                arrStimTurnedOnTrialsGLXMs(indTrial) = targetStimTimesGLXMs(iStim);
            end
    
            latencyof2systemsOnCueMs = arrStimTurnedOnTrialsGLXMs - targetStimTimesMWorksMs;
            logger.info('main', ['Mean latencyof2systemsOnCueMs=' num2str(mean(latencyof2systemsOnCueMs(arrHitTrials)))]); % get only Hit trials cos I'm filling up fa trials in th eabove loop from Mworks system since SpikeGLX has no clue about when would a cue appear in fa trials
    
            arrReactTimesGLXMs = (leverReleaseTimesMs - arrStimTurnedOnTrialsGLXMs); % to ms
            latencyof2systemsOnReactionTimeMs = arrReactTimesGLXMs-double(arrReactTimesMWorksMs);
            logger.info('main', ['Mean latencyof2systemsOnReactionTimeMs=' num2str(mean(latencyof2systemsOnReactionTimeMs(arrHitTrials)))]);
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
            lenMWorks = length(arrReqHoldTimesMWorksMs);
            holdReleaseDiffTimeGLXMs = leverReleaseTimesMs -leverHoldTimesMs ; % ms
            lenSpGLX = length(holdReleaseDiffTimeGLXMs);
            if lenMWorks~=lenSpGLX % Started MWorks first, then SpikeGLX OR Stopped SpikeGLX first,then MWorks    
                logger.error('init',['CANNOT Align trials from two system! Manual curation is needed! MWorks: ' num2str(lenMWorks) ' SpikeGLX: ' num2str(lenSpGLX)]);
                exit -1
            else
                %candidateStimTurnedOnTrialsGLX = find(holdReleaseTimeGLX-arrReqHoldTimes-LATENCY_MWorks>0 ); % include hits exclude fa and misses            
                candidateStimTurnedOnTrialsGLX = find(holdReleaseDiffTimeGLXMs-LAG_SGLX>arrReqHoldTimesMWorksMs); % include every trial that has visual stim change %  & holdReleaseTimeGLX<(reactTime+preHoldTime+tooFastTime)
                
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

         end
end