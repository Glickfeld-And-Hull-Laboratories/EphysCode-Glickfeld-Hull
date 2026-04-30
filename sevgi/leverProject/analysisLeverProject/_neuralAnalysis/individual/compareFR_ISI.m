%%%% Check if there is any trend/change in firing rates %%%%%%%%%%%%
% spikeTimesSec: Spike times in sec
%
% SO 1/20/2023 Hull Lab
function compareFR_ISI(unitID, neuronType, layer, channel, spikeTimesSec, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrStimTurnedOnTrials, arrSelectedTrials, strTrialType)
        globals;
        
        BIN_SIZE = 0.003; % sec = 3 ms
        EDGES_HOLD = -PRE_TIME_HOLD-BIN_SIZE:BIN_SIZE:POST_TIME_HOLD+BIN_SIZE;
        EDGES_RELEASE = -PRE_TIME_RELEASE-BIN_SIZE:BIN_SIZE:POST_TIME_RELEASE+BIN_SIZE;
        EDGES_VIS_STIM = -PRE_TIME_VIS_STIM-BIN_SIZE:BIN_SIZE:POST_TIME_VIS_STIM+BIN_SIZE;

        allTrialCount = length(leverHoldTimes);
        allTrials = [1:allTrialCount];
               
        isiHold = cell(1,allTrialCount);
        isiHoldBefore = cell(1,allTrialCount);
        isiHoldAfter = cell(1,allTrialCount);
        isiRelease = cell(1,allTrialCount);
        isiReleaseBefore = cell(1,allTrialCount);
        isiReleaseAfter = cell(1,allTrialCount);
        isiTargetStimChange = cell(1,allTrialCount);
        isiTargetStimChangeBefore = cell(1,allTrialCount);
        isiTargetStimChangeAfter = cell(1,allTrialCount);
        isiBaselineStimChange = cell(1,allTrialCount);
        isiBaselineStimChangeBefore = cell(1,allTrialCount);
        isiBaselineStimChangeAfter = cell(1,allTrialCount);

        spikeRatesHold = UNDEFINED*ones(allTrialCount,length(EDGES_HOLD)-1);
        spikeRatesHoldBefore = UNDEFINED*ones(allTrialCount,length(EDGES_HOLD)-1);
        spikeRatesHoldAfter = UNDEFINED*ones(allTrialCount,length(EDGES_HOLD)-1);

        spikeRatesRelease = UNDEFINED*ones(allTrialCount, length(EDGES_RELEASE)-1);
        spikeRatesReleaseBefore = UNDEFINED*ones(allTrialCount, length(EDGES_RELEASE)-1);
        spikeRatesReleaseAfter = UNDEFINED*ones(allTrialCount, length(EDGES_RELEASE)-1);

        spikeRatesTargetStimChange = UNDEFINED*ones(allTrialCount, length(EDGES_VIS_STIM)-1);
        spikeRatesTargetStimChangeBefore = UNDEFINED*ones(allTrialCount, length(EDGES_VIS_STIM)-1);
        spikeRatesTargetStimChangeAfter = UNDEFINED*ones(allTrialCount, length(EDGES_VIS_STIM)-1);

        spikeRatesBaselineStimChange = UNDEFINED*ones(allTrialCount, length(EDGES_VIS_STIM)-1);
        spikeRatesBaselineStimChangeBefore = UNDEFINED*ones(allTrialCount, length(EDGES_VIS_STIM)-1);
        spikeRatesBaselineStimChangeAfter = UNDEFINED*ones(allTrialCount, length(EDGES_VIS_STIM)-1);
        
        logger.info('compareFR_ISI', ['compareFR_ISI is started for unit=' num2str(unitID)]);

        for indTrial=1:allTrialCount
            % get spikeTimes between hold and release
            if isempty(arrSelectedTrials) || (~isempty(arrSelectedTrials) && ismember(indTrial,arrSelectedTrials))
                trSpikeTimesHold = spikeTimesSec(spikeTimesSec>(leverHoldTimes(indTrial)-PRE_TIME_HOLD) & spikeTimesSec<(leverHoldTimes(indTrial)+POST_TIME_HOLD))-leverHoldTimes(indTrial); 
                
                spikeRatesHold(indTrial,:) = histcounts(trSpikeTimesHold,EDGES_HOLD)/BIN_SIZE'; % averaged along the specified bin
                spikeRatesHoldBefore(indTrial,:) = histcounts(trSpikeTimesHold(trSpikeTimesHold<0),EDGES_HOLD)/BIN_SIZE'; % averaged along the specified bin
                spikeRatesHoldAfter(indTrial,:) = histcounts(trSpikeTimesHold(trSpikeTimesHold>=0),EDGES_HOLD)/BIN_SIZE'; % averaged along the specified bin
                
                isiHold(indTrial) = {diff(trSpikeTimesHold)};
                isiHoldBefore(indTrial) = {diff(trSpikeTimesHold(trSpikeTimesHold<0))}; % get the ones before the behavioral event that are aligned for
                isiHoldAfter(indTrial) = {diff(trSpikeTimesHold(trSpikeTimesHold>=0))}; % get the ones after the behavioral event that are aligned for
                                
                trSpikeTimesRelease = spikeTimesSec(spikeTimesSec>(leverReleaseTimesGLX(indTrial)-PRE_TIME_RELEASE) & spikeTimesSec<(leverReleaseTimesGLX(indTrial)+POST_TIME_RELEASE))-leverReleaseTimesGLX(indTrial);

                spikeRatesRelease(indTrial,:) = histcounts(trSpikeTimesRelease,EDGES_RELEASE)/BIN_SIZE'; % averaged along the specified bin
                spikeRatesReleaseBefore(indTrial,:) = histcounts(trSpikeTimesRelease(trSpikeTimesRelease<0),EDGES_RELEASE)/BIN_SIZE'; % averaged along the specified bin
                spikeRatesReleaseAfter(indTrial,:) = histcounts(trSpikeTimesRelease(trSpikeTimesRelease>=0),EDGES_RELEASE)/BIN_SIZE'; % averaged along the specified bin
                
                isiRelease(indTrial) = {diff(trSpikeTimesRelease)};
                isiReleaseBefore(indTrial) = {diff(trSpikeTimesRelease(trSpikeTimesRelease<0))};
                isiReleaseAfter(indTrial) = {diff(trSpikeTimesRelease(trSpikeTimesRelease>=0))};
                
                % get if any visual stim change happened between lever hold and release of this trial    
                if any(arrStimTurnedOnTrials==indTrial) % if target visual stim turned on in this trial
                    indVisStimOnTrial = find(arrStimTurnedOnTrials==indTrial);

                    trSpikeTimesTargetStimChange = spikeTimesSec(spikeTimesSec>(targetVisStimChangeTimeGLX(indVisStimOnTrial)-PRE_TIME_VIS_STIM) & spikeTimesSec<(targetVisStimChangeTimeGLX(indVisStimOnTrial)+POST_TIME_VIS_STIM))-targetVisStimChangeTimeGLX(indVisStimOnTrial);                     

                    spikeRatesTargetStimChange(indTrial,:) = histcounts(trSpikeTimesTargetStimChange,EDGES_VIS_STIM)/BIN_SIZE';
                    spikeRatesTargetStimChangeBefore(indTrial,:) = histcounts(trSpikeTimesTargetStimChange(trSpikeTimesTargetStimChange<0),EDGES_VIS_STIM)/BIN_SIZE';
                    spikeRatesTargetStimChangeAfter(indTrial,:) = histcounts(trSpikeTimesTargetStimChange(trSpikeTimesTargetStimChange>=0),EDGES_VIS_STIM)/BIN_SIZE';

                    isiTargetStimChange(indTrial) = {diff(trSpikeTimesTargetStimChange)};
                    isiTargetStimChangeBefore(indTrial) = {diff(trSpikeTimesTargetStimChange(trSpikeTimesTargetStimChange<0))};
                    isiTargetStimChangeAfter(indTrial) = {diff(trSpikeTimesTargetStimChange(trSpikeTimesTargetStimChange>=0))};
                    
                    trSpikeTimesBaselineStimChange = spikeTimesSec(spikeTimesSec>(baselineVisStimChangeTimeGLX(indVisStimOnTrial)-PRE_TIME_VIS_STIM) & spikeTimesSec<(baselineVisStimChangeTimeGLX(indVisStimOnTrial)+POST_TIME_VIS_STIM))-baselineVisStimChangeTimeGLX(indVisStimOnTrial);                     
                    
                    spikeRatesBaselineStimChange(indTrial,:) = histcounts(trSpikeTimesBaselineStimChange,EDGES_VIS_STIM)/BIN_SIZE';
                    spikeRatesBaselineStimChangeBefore(indTrial,:) = histcounts(trSpikeTimesBaselineStimChange(trSpikeTimesBaselineStimChange<0),EDGES_VIS_STIM)/BIN_SIZE';
                    spikeRatesBaselineStimChangeAfter(indTrial,:) = histcounts(trSpikeTimesBaselineStimChange(trSpikeTimesBaselineStimChange>=0),EDGES_VIS_STIM)/BIN_SIZE';

                    isiBaselineStimChange(indTrial) = {diff(trSpikeTimesBaselineStimChange)};
                    isiBaselineStimChangeBefore(indTrial) = {diff(trSpikeTimesBaselineStimChange(trSpikeTimesBaselineStimChange<0))};
                    isiBaselineStimChangeAfter(indTrial) = {diff(trSpikeTimesBaselineStimChange(trSpikeTimesBaselineStimChange>=0))};
                end
            end
        end
                
        logger.info('compareFR_ISI', ['will evaluate FRs for unit=' num2str(unitID)]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%% Evaluate MEAN FIRING RATES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if fixedHoldStartsAtTrial>0 % if session is mixed with random/fixed trials
            spikeRatesRandHold = spikeRatesHold(1:fixedHoldStartsAtTrial-1,:);
            spikeRatesRandHoldBefore = spikeRatesHoldBefore(1:fixedHoldStartsAtTrial-1,:);
            spikeRatesRandHoldAfter = spikeRatesHoldAfter(1:fixedHoldStartsAtTrial-1,:);

            spikeRatesFixedHold = spikeRatesHold(fixedHoldStartsAtTrial:end,:);
            spikeRatesFixedHoldBefore = spikeRatesHoldBefore(fixedHoldStartsAtTrial:end,:);
            spikeRatesFixedHoldAfter = spikeRatesHoldAfter(fixedHoldStartsAtTrial:end,:);
            
            spikeRatesRandRelease = spikeRatesRelease(1:fixedHoldStartsAtTrial-1,:);
            spikeRatesRandReleaseBefore = spikeRatesReleaseBefore(1:fixedHoldStartsAtTrial-1,:);
            spikeRatesRandReleaseAfter = spikeRatesReleaseAfter(1:fixedHoldStartsAtTrial-1,:);

            spikeRatesFixedRelease = spikeRatesRelease(fixedHoldStartsAtTrial:end,:);
            spikeRatesFixedReleaseBefore = spikeRatesReleaseBefore(fixedHoldStartsAtTrial:end,:);
            spikeRatesFixedReleaseAfter = spikeRatesReleaseAfter(fixedHoldStartsAtTrial:end,:);
            
            spikeRatesRandTargetStimChange = spikeRatesTargetStimChange(1:fixedHoldStartsAtTrial-1,:);
            spikeRatesRandTargetStimChangeBefore = spikeRatesTargetStimChangeBefore(1:fixedHoldStartsAtTrial-1,:);
            spikeRatesRandTargetStimChangeAfter = spikeRatesTargetStimChangeAfter(1:fixedHoldStartsAtTrial-1,:);

            spikeRatesFixedTargetStimChange = spikeRatesTargetStimChange(fixedHoldStartsAtTrial:end,:);
            spikeRatesFixedTargetStimChangeBefore = spikeRatesTargetStimChangeBefore(fixedHoldStartsAtTrial:end,:);
            spikeRatesFixedTargetStimChangeAfter = spikeRatesTargetStimChangeAfter(fixedHoldStartsAtTrial:end,:);
            
            spikeRatesRandBaselineStimChange = spikeRatesBaselineStimChange(1:fixedHoldStartsAtTrial-1,:);
            spikeRatesRandBaselineStimChangeBefore = spikeRatesBaselineStimChangeBefore(1:fixedHoldStartsAtTrial-1,:);
            spikeRatesRandBaselineStimChangeAfter = spikeRatesBaselineStimChangeAfter(1:fixedHoldStartsAtTrial-1,:);

            spikeRatesFixedBaselineStimChange = spikeRatesBaselineStimChange(fixedHoldStartsAtTrial:end,:);
            spikeRatesFixedBaselineStimChangeBefore = spikeRatesBaselineStimChangeBefore(fixedHoldStartsAtTrial:end,:);
            spikeRatesFixedBaselineStimChangeAfter = spikeRatesBaselineStimChangeAfter(fixedHoldStartsAtTrial:end,:);
            
        else % fixedHoldStartsAtTrial==0 means only random trials
            spikeRatesRandHold = spikeRatesHold; % All random trials
            spikeRatesRandHoldBefore = spikeRatesHoldBefore;
            spikeRatesRandHoldAfter = spikeRatesHoldAfter;

            spikeRatesRandRelease = spikeRatesRelease;
            spikeRatesRandReleaseBefore = spikeRatesReleaseBefore;
            spikeRatesRandReleaseAfter = spikeRatesReleaseAfter;

            spikeRatesRandTargetStimChange = spikeRatesTargetStimChange;
            spikeRatesRandTargetStimChangeBefore = spikeRatesTargetStimChangeBefore;
            spikeRatesRandTargetStimChangeAfter = spikeRatesTargetStimChangeAfter;

            spikeRatesRandBaselineStimChange = spikeRatesBaselineStimChange;
            spikeRatesRandBaselineStimChangeBefore = spikeRatesBaselineStimChangeBefore;
            spikeRatesRandBaselineStimChangeAfter = spikeRatesBaselineStimChangeAfter;
        end
        
        meanSpikeRateRandHold = mean(spikeRatesRandHold,2)';
        meanSpikeRateRandHold = meanSpikeRateRandHold(meanSpikeRateRandHold~=UNDEFINED); % eliminate nonselected trials
        meanSpikeRateRandHoldBefore = mean(spikeRatesRandHoldBefore,2)';
        meanSpikeRateRandHoldBefore = meanSpikeRateRandHoldBefore(meanSpikeRateRandHoldBefore~=UNDEFINED);
        meanSpikeRateRandHoldAfter = mean(spikeRatesRandHoldAfter,2)';
        meanSpikeRateRandHoldAfter = meanSpikeRateRandHoldAfter(meanSpikeRateRandHoldAfter~=UNDEFINED);
        
        meanSpikeRateFixedHold = mean(spikeRatesFixedHold,2)';
        meanSpikeRateFixedHold = meanSpikeRateFixedHold(meanSpikeRateFixedHold~=UNDEFINED);
        meanSpikeRateFixedHoldBefore = mean(spikeRatesFixedHoldBefore,2)';
        meanSpikeRateFixedHoldBefore = meanSpikeRateFixedHoldBefore(meanSpikeRateFixedHoldBefore~=UNDEFINED);
        meanSpikeRateFixedHoldAfter = mean(spikeRatesFixedHoldAfter,2)';
        meanSpikeRateFixedHoldAfter = meanSpikeRateFixedHoldAfter(meanSpikeRateFixedHoldAfter~=UNDEFINED);
        
        meanSpikeRateRandRelease = mean(spikeRatesRandRelease,2)';
        meanSpikeRateRandRelease = meanSpikeRateRandRelease(meanSpikeRateRandRelease~=UNDEFINED);
        meanSpikeRateRandReleaseBefore = mean(spikeRatesRandReleaseBefore,2)';
        meanSpikeRateRandReleaseBefore = meanSpikeRateRandReleaseBefore(meanSpikeRateRandReleaseBefore~=UNDEFINED);
        meanSpikeRateRandReleaseAfter = mean(spikeRatesRandReleaseAfter,2)';
        meanSpikeRateRandReleaseAfter = meanSpikeRateRandReleaseAfter(meanSpikeRateRandReleaseAfter~=UNDEFINED);
        
        meanSpikeRateFixedRelease = mean(spikeRatesFixedRelease,2)';
        meanSpikeRateFixedRelease = meanSpikeRateFixedRelease(meanSpikeRateFixedRelease~=UNDEFINED);
        meanSpikeRateFixedReleaseBefore = mean(spikeRatesFixedReleaseBefore,2)';
        meanSpikeRateFixedReleaseBefore = meanSpikeRateFixedReleaseBefore(meanSpikeRateFixedReleaseBefore~=UNDEFINED);
        meanSpikeRateFixedReleaseAfter = mean(spikeRatesFixedReleaseAfter,2)';
        meanSpikeRateFixedReleaseAfter = meanSpikeRateFixedReleaseAfter(meanSpikeRateFixedReleaseAfter~=UNDEFINED);
        
        meanSpikeRateRandTargetStimChange = mean(spikeRatesRandTargetStimChange,2)';
        meanSpikeRateRandTargetStimChange = meanSpikeRateRandTargetStimChange(meanSpikeRateRandTargetStimChange~=UNDEFINED);
        meanSpikeRateRandTargetStimChangeBefore = mean(spikeRatesRandTargetStimChangeBefore,2)';
        meanSpikeRateRandTargetStimChangeBefore = meanSpikeRateRandTargetStimChangeBefore(meanSpikeRateRandTargetStimChangeBefore~=UNDEFINED);
        meanSpikeRateRandTargetStimChangeAfter = mean(spikeRatesRandTargetStimChangeAfter,2)';
        meanSpikeRateRandTargetStimChangeAfter = meanSpikeRateRandTargetStimChangeAfter(meanSpikeRateRandTargetStimChangeAfter~=UNDEFINED);
        
        meanSpikeRateFixedTargetStimChange = mean(spikeRatesFixedTargetStimChange,2)';
        meanSpikeRateFixedTargetStimChange = meanSpikeRateFixedTargetStimChange(meanSpikeRateFixedTargetStimChange~=UNDEFINED);
        meanSpikeRateFixedTargetStimChangeBefore = mean(spikeRatesFixedTargetStimChangeBefore,2)';
        meanSpikeRateFixedTargetStimChangeBefore = meanSpikeRateFixedTargetStimChangeBefore(meanSpikeRateFixedTargetStimChangeBefore~=UNDEFINED);
        meanSpikeRateFixedTargetStimChangeAfter = mean(spikeRatesFixedTargetStimChangeAfter,2)';
        meanSpikeRateFixedTargetStimChangeAfter = meanSpikeRateFixedTargetStimChangeAfter(meanSpikeRateFixedTargetStimChangeAfter~=UNDEFINED);
        
        meanSpikeRateRandBaselineStimChange = mean(spikeRatesRandBaselineStimChange,2)';
        meanSpikeRateRandBaselineStimChange = meanSpikeRateRandBaselineStimChange(meanSpikeRateRandBaselineStimChange~=UNDEFINED);
        meanSpikeRateRandBaselineStimChangeBefore = mean(spikeRatesRandBaselineStimChangeBefore,2)';
        meanSpikeRateRandBaselineStimChangeBefore = meanSpikeRateRandBaselineStimChangeBefore(meanSpikeRateRandBaselineStimChangeBefore~=UNDEFINED);
        meanSpikeRateRandBaselineStimChangeAfter = mean(spikeRatesRandBaselineStimChangeAfter,2)';
        meanSpikeRateRandBaselineStimChangeAfter = meanSpikeRateRandBaselineStimChangeAfter(meanSpikeRateRandBaselineStimChangeAfter~=UNDEFINED);
                
        meanSpikeRateFixedBaselineStimChange = mean(spikeRatesFixedBaselineStimChange,2)';
        meanSpikeRateFixedBaselineStimChange = meanSpikeRateFixedBaselineStimChange(meanSpikeRateFixedBaselineStimChange~=UNDEFINED);
        meanSpikeRateFixedBaselineStimChangeBefore = mean(spikeRatesFixedBaselineStimChangeBefore,2)';
        meanSpikeRateFixedBaselineStimChangeBefore = meanSpikeRateFixedBaselineStimChangeBefore(meanSpikeRateFixedBaselineStimChangeBefore~=UNDEFINED);
        meanSpikeRateFixedBaselineStimChangeAfter = mean(spikeRatesFixedBaselineStimChangeAfter,2)';
        meanSpikeRateFixedBaselineStimChangeAfter = meanSpikeRateFixedBaselineStimChangeAfter(meanSpikeRateFixedBaselineStimChangeAfter~=UNDEFINED);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Evaluate ISIs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        logger.info('compareFR_ISI', ['will evaluate ISIs for unit=' num2str(unitID)]);

        nonSelectedTrials = setdiff(allTrials,arrSelectedTrials); % eliminate non-selected trials        
        countEmptyBefFixed = sum(nonSelectedTrials<fixedHoldStartsAtTrial);
        fixedHoldStartsAtRelativeTrial = fixedHoldStartsAtTrial-countEmptyBefFixed; % Find relative fixed trial number when empty cells removed
        isiHold(nonSelectedTrials) = []; % remove empty cells, leave only selected trials as hit,fa,miss
        isiHoldBefore(nonSelectedTrials) = [];
        isiHoldAfter(nonSelectedTrials) = [];
        isiRelease(nonSelectedTrials) = [];
        isiReleaseBefore(nonSelectedTrials) = [];
        isiReleaseAfter(nonSelectedTrials) = [];
        isiTargetStimChange(nonSelectedTrials) = [];
        isiTargetStimChangeBefore(nonSelectedTrials) = [];
        isiTargetStimChangeAfter(nonSelectedTrials) = [];
        isiBaselineStimChange(nonSelectedTrials) = [];
        isiBaselineStimChangeBefore(nonSelectedTrials) = [];
        isiBaselineStimChangeAfter(nonSelectedTrials) = [];
        
        if fixedHoldStartsAtRelativeTrial>0 % if session is mixed with random/fixed trials
            isiRandHold = isiHold(1:fixedHoldStartsAtRelativeTrial-1)';
            isiRandHoldBefore = isiHoldBefore(1:fixedHoldStartsAtRelativeTrial-1)';
            isiRandHoldAfter = isiHoldAfter(1:fixedHoldStartsAtRelativeTrial-1)';

            isiFixedHold = isiHold(fixedHoldStartsAtRelativeTrial:end)';
            isiFixedHoldBefore = isiHoldBefore(fixedHoldStartsAtRelativeTrial:end)';
            isiFixedHoldAfter = isiHoldAfter(fixedHoldStartsAtRelativeTrial:end)';

            isiRandRelease = isiRelease(1:fixedHoldStartsAtRelativeTrial-1)';
            isiRandReleaseBefore = isiReleaseBefore(1:fixedHoldStartsAtRelativeTrial-1)';
            isiRandReleaseAfter = isiReleaseAfter(1:fixedHoldStartsAtRelativeTrial-1)';

            isiFixedRelease = isiRelease(fixedHoldStartsAtRelativeTrial:end)';
            isiFixedReleaseBefore = isiReleaseBefore(fixedHoldStartsAtRelativeTrial:end)';
            isiFixedReleaseAfter = isiReleaseAfter(fixedHoldStartsAtRelativeTrial:end)';

            isiRandTargetStimChange = isiTargetStimChange(1:fixedHoldStartsAtRelativeTrial-1)';
            isiRandTargetStimChangeBefore = isiTargetStimChangeBefore(1:fixedHoldStartsAtRelativeTrial-1)';
            isiRandTargetStimChangeAfter = isiTargetStimChangeAfter(1:fixedHoldStartsAtRelativeTrial-1)';

            isiFixedTargetStimChange = isiTargetStimChange(fixedHoldStartsAtRelativeTrial:end)';
            isiFixedTargetStimChangeBefore = isiTargetStimChangeBefore(fixedHoldStartsAtRelativeTrial:end)';
            isiFixedTargetStimChangeAfter = isiTargetStimChangeAfter(fixedHoldStartsAtRelativeTrial:end)';

            isiRandBaselineStimChange = isiBaselineStimChange(1:fixedHoldStartsAtRelativeTrial-1)';
            isiRandBaselineStimChangeBefore = isiBaselineStimChangeBefore(1:fixedHoldStartsAtRelativeTrial-1)';
            isiRandBaselineStimChangeAfter = isiBaselineStimChangeAfter(1:fixedHoldStartsAtRelativeTrial-1)';

            isiFixedBaselineStimChange = isiBaselineStimChange(fixedHoldStartsAtRelativeTrial:end)';
            isiFixedBaselineStimChangeBefore = isiBaselineStimChangeBefore(fixedHoldStartsAtRelativeTrial:end)';
            isiFixedBaselineStimChangeAfter = isiBaselineStimChangeAfter(fixedHoldStartsAtRelativeTrial:end)';
        else % fixedHoldStartsAtRelativeTrial==0 means only random trials
            isiRandHold = isiHold'; % All random trials
            isiRandHoldBefore = isiHoldBefore';
            isiRandHoldAfter = isiHoldAfter';

            isiRandRelease = isiRelease';
            isiRandReleaseBefore = isiReleaseBefore';
            isiRandReleaseAfter = isiReleaseAfter';

            isiRandTargetStimChange = isiTargetStimChange';
            isiRandTargetStimChangeBefore = isiTargetStimChangeBefore';
            isiRandTargetStimChangeAfter = isiTargetStimChangeAfter';

            isiRandBaselineStimChange = isiBaselineStimChange';
            isiRandBaselineStimChangeBefore = isiBaselineStimChangeBefore';
            isiRandBaselineStimChangeAfter = isiBaselineStimChangeAfter';
        end

        if fixedHoldStartsAtRelativeTrial>0
            arrISIFixedHold = cell2mat(isiFixedHold)'*1000; % from sec to msec
            arrISIFixedHoldBefore = cell2mat(isiFixedHoldBefore)'*1000; % from sec to msec
            arrISIFixedHoldAfter = cell2mat(isiFixedHoldAfter)'*1000; % from sec to msec

            arrISIFixedRelease = cell2mat(isiFixedRelease)'*1000; % from sec to msec
            arrISIFixedReleaseBefore = cell2mat(isiFixedReleaseBefore)'*1000; % from sec to msec
            arrISIFixedReleaseAfter = cell2mat(isiFixedReleaseAfter)'*1000; % from sec to msec

            arrISIFixedTargetStimChange = cell2mat(isiFixedTargetStimChange)'*1000; % from sec to msec
            arrISIFixedTargetStimChangeBefore = cell2mat(isiFixedTargetStimChangeBefore)'*1000; % from sec to msec
            arrISIFixedTargetStimChangeAfter = cell2mat(isiFixedTargetStimChangeAfter)'*1000; % from sec to msec

            arrISIFixedBaselineStimChange = cell2mat(isiFixedBaselineStimChange)'*1000; % from sec to msec
            arrISIFixedBaselineStimChangeBefore = cell2mat(isiFixedBaselineStimChangeBefore)'*1000; % from sec to msec
            arrISIFixedBaselineStimChangeAfter = cell2mat(isiFixedBaselineStimChangeAfter)'*1000; % from sec to msec
        end

        arrISIRandHold = cell2mat(isiRandHold)'*1000; % from sec to msec
        arrISIRandHoldBefore = cell2mat(isiRandHoldBefore)'*1000; % from sec to msec
        arrISIRandHoldAfter = cell2mat(isiRandHoldAfter)'*1000; % from sec to msec

        arrISIRandRelease = cell2mat(isiRandRelease)'*1000; % from sec to msec
        arrISIRandReleaseBefore = cell2mat(isiRandReleaseBefore)'*1000; % from sec to msec
        arrISIRandReleaseAfter = cell2mat(isiRandReleaseAfter)'*1000; % from sec to msec

        arrISIRandTargetStimChange = cell2mat(isiRandTargetStimChange)'*1000; % from sec to msec
        arrISIRandTargetStimChangeBefore = cell2mat(isiRandTargetStimChangeBefore)'*1000; % from sec to msec
        arrISIRandTargetStimChangeAfter = cell2mat(isiRandTargetStimChangeAfter)'*1000; % from sec to msec

        arrISIRandBaselineStimChange = cell2mat(isiRandBaselineStimChange)'*1000; % from sec to msec
        arrISIRandBaselineStimChangeBefore = cell2mat(isiRandBaselineStimChangeBefore)'*1000; % from sec to msec
        arrISIRandBaselineStimChangeAfter = cell2mat(isiRandBaselineStimChangeAfter)'*1000; % from sec to msec

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Firing Rate STATS AND PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        logger.info('compareFR_ISI', ['will do stats and plotting FRs for unit=' num2str(unitID)]);

        sGlobalTitle = ['Unit=' num2str(unitID) ' ' neuronType ' (' layer ' ch=' num2str(channel) ') '];
        str = '';
        if ~isempty(strTrialType)
            str = ['(' num2str(length(arrSelectedTrials)) ' ' strTrialType ' trials)'];
        end        
              
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   TTEST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compare Release vs Hold in Random delay trials
        [h,p] = ttest(meanSpikeRateRandHold,meanSpikeRateRandRelease);
        if h==1 % significant difference between distributions   
            [r,pCorr] = corrcoef(meanSpikeRateRandHold,meanSpikeRateRandRelease);
            sTitle = [sGlobalTitle '(random del.) HOLD VS RELEASE (p=' num2str(p,'%.2f')];
            if pCorr(1,2)<=P_VALUE_THRESHOLD
                sTitle = [sTitle ' r=' num2str(r(1,2),'%.2f')];
            end
            sTitle = [sTitle ')' str];
            scatterFR(meanSpikeRateRandHold, meanSpikeRateRandRelease, unitID, neuronType, 'Mean Hold FR on rand trials', 'Mean Release FR on rand trials', sTitle, strTrialType, 'Rand_HoldVsRelease');
        end

        % Compare Release vs Hold in Fixed delay trials
        [h,p] = ttest(meanSpikeRateFixedHold,meanSpikeRateFixedRelease);
        if h==1 % significant difference between distributions
            [r,pCorr] = corrcoef(meanSpikeRateFixedHold,meanSpikeRateFixedRelease);
            sTitle = [sGlobalTitle '(fixed del.) HOLD VS RELEASE (p=' num2str(p,'%.2f')];
            if pCorr(1,2)<=P_VALUE_THRESHOLD
                sTitle = [sTitle ' r=' num2str(r(1,2),'%.2f')];
            end
            sTitle = [sTitle ')' str];
            scatterFR(meanSpikeRateFixedHold, meanSpikeRateFixedRelease, unitID, neuronType, 'Mean Hold FR on fixed trials', 'Mean Release FR on fixed trials', sTitle, strTrialType, 'Fixed_HoldVsRelease');
        end

        % Compare FR's during Target vs Baseline Stim change in Random trials
        [h,p] = ttest(meanSpikeRateRandTargetStimChange,meanSpikeRateRandBaselineStimChange);
        if h==1 % significant difference between distributions   
            [r,pCorr] = corrcoef(meanSpikeRateRandTargetStimChange,meanSpikeRateRandBaselineStimChange);
            sTitle = [sGlobalTitle '(random del.) TARGET VS BASELINE (p=' num2str(p,'%.2f')];
            if pCorr(1,2)<=P_VALUE_THRESHOLD
                sTitle = [sTitle ' r=' num2str(r(1,2),'%.2f')];
            end
            sTitle = [sTitle ')' str];
            scatterFR(meanSpikeRateRandTargetStimChange, meanSpikeRateRandBaselineStimChange, unitID, neuronType, 'Mean Target Stim change FR on rand trials', 'Mean Baseline Stim change FR on rand trials', sTitle, strTrialType, 'Rand_TargetVsBaseline');
        end

        % Compare FR's during Target vs Baseline Stim change in Fixed trials
        [h,p] = ttest(meanSpikeRateFixedTargetStimChange,meanSpikeRateFixedBaselineStimChange);
        if h==1 % significant difference between distributions 
            [r,pCorr] = corrcoef(meanSpikeRateFixedTargetStimChange,meanSpikeRateFixedBaselineStimChange);
            sTitle = [sGlobalTitle '(fixed del.) TARGET VS BASELINE (p=' num2str(p,'%.2f')];
            if pCorr(1,2)<=P_VALUE_THRESHOLD
                sTitle = [sTitle ' r=' num2str(r(1,2),'%.2f')];
            end
            sTitle = [sTitle ')' str];
            scatterFR(meanSpikeRateFixedTargetStimChange, meanSpikeRateFixedBaselineStimChange, unitID, neuronType, 'Mean Target Stim change FR on fixed trials', 'Mean Baseline Stim change FR on fixed trials', sTitle, strTrialType, 'Fixed_TargetVsBaseline');
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   KSTEST2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compare HOLD FRs in Random vs Fixed trials
        testPlot(meanSpikeRateRandHold, meanSpikeRateFixedHold, unitID, neuronType, strTrialType, sGlobalTitle, str, 'RAND vs FIXED delay on Hold', 'Firing Rate (spk/s)', 'Random delay', 'Fixed Delay', 'FR_RandVsFixed_Hold', []);
        
        % Compare RELEASE FRs in Random vs Fixed trials
        testPlot(meanSpikeRateRandRelease, meanSpikeRateFixedRelease, unitID, neuronType, strTrialType, sGlobalTitle, str, 'RAND vs FIXED delay on Release', 'Firing Rate (spk/s)', 'Random delay', 'Fixed Delay', 'FR_RandVsFixed_Release', []);
         
        % Compare TARGET Stim change FRs in Random vs Fixed trials
        testPlot(meanSpikeRateRandTargetStimChange, meanSpikeRateFixedTargetStimChange, unitID, neuronType, strTrialType, sGlobalTitle, str, 'RAND vs FIXED delay on TargetStimChange', 'Firing Rate (spk/s)', 'Random delay', 'Fixed Delay', 'FR_RandVsFixed_TargetStimChange', []);

        % Compare BASELINE Stim change FRs in Random vs Fixed trials
        testPlot(meanSpikeRateRandBaselineStimChange, meanSpikeRateFixedBaselineStimChange, unitID, neuronType, strTrialType, sGlobalTitle, str, 'RAND vs FIXED delay on BaselineStimChange', 'Firing Rate (spk/s)', 'Random delay', 'Fixed Delay', 'FR_RandVsFixed_BaselineStimChange', []);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FR COMPARISON of BEFORE VS AFTER EVENTS %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compare FRs BEFORE vs AFTER the RAND HOLD event
        testPlot(meanSpikeRateRandHoldBefore, meanSpikeRateRandHoldAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Rand Hold BEFORE vs AFTER', 'Firing Rate (spk/s)', 'Before the event', 'After the event', 'FR_RandHold_BeforeVsAfter', []);

        % Compare FRs BEFORE vs AFTER the FIXED HOLD event
        testPlot(meanSpikeRateFixedHoldBefore, meanSpikeRateFixedHoldAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Fixed Hold BEFORE vs AFTER', 'Firing Rate (spk/s)', 'Before the event', 'After the event', 'FR_FixedHold_BeforeVsAfter', []);

        % Compare FRs BEFORE vs AFTER the RAND RELEASE event
        testPlot(meanSpikeRateRandReleaseBefore, meanSpikeRateRandReleaseAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Rand Release BEFORE vs AFTER', 'Firing Rate (spk/s)', 'Before the event', 'After the event', 'FR_RandRelease_BeforeVsAfter', []);

        % Compare FRs BEFORE vs AFTER the FIXED RELEASE event
        testPlot(meanSpikeRateFixedReleaseBefore, meanSpikeRateFixedReleaseAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Fixed Release BEFORE vs AFTER', 'Firing Rate (spk/s)', 'Before the event', 'After the event', 'FR_FixedRelease_BeforeVsAfter', []);

        % Compare FRs BEFORE vs AFTER the RAND TARGET stim change event
        testPlot(meanSpikeRateRandTargetStimChangeBefore, meanSpikeRateRandTargetStimChangeAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Rand TargetStimChange BEFORE vs AFTER', 'Firing Rate (spk/s)', 'Before the event', 'After the event', 'FR_RandTarget_BeforeVsAfter', []);

        % Compare FRs BEFORE vs AFTER the FIXED TARGET stim change event
        testPlot(meanSpikeRateFixedTargetStimChangeBefore, meanSpikeRateFixedTargetStimChangeAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Fixed TargetStimChange BEFORE vs AFTER', 'Firing Rate (spk/s)', 'Before the event', 'After the event', 'FR_FixedTarget_BeforeVsAfter', []);

        % Compare FRs BEFORE vs AFTER the RAND BASELINE stim change event
        testPlot(meanSpikeRateRandBaselineStimChangeBefore, meanSpikeRateRandBaselineStimChangeAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Rand BaselineStimChange BEFORE vs AFTER', 'Firing Rate (spk/s)', 'Before the event', 'After the event', 'FR_RandBaseline_BeforeVsAfter', []);

        % Compare FRs BEFORE vs AFTER the FIXED BASELINE stim change event
        testPlot(meanSpikeRateFixedBaselineStimChangeBefore, meanSpikeRateFixedBaselineStimChangeAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Fixed BaselineStimChange BEFORE vs AFTER', 'Firing Rate (spk/s)', 'Before the event', 'After the event', 'FR_FixedBaseline_BeforeVsAfter', []);

        %%%%%%%%%%%%%%%%%%% Definetely you would want to compare BEFORE ISIs of RAND vs FIXED RELEASE %%%%%%%%%%%%%%%%%%%%%%
        testPlot(meanSpikeRateRandReleaseBefore, meanSpikeRateFixedReleaseBefore, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Release BEFORE on Rand vs Fixed', 'Firing Rate (spk/s)', 'Random delay', 'Fixed Delay', 'FR_ReleaseBefore_RandVsFixed', []);

        %%%%%%%%%%%%%%%%%%% Definetely you would want to compare AFTER ISIs of RAND vs FIXED RELEASE %%%%%%%%%%%%%%%%%%%%%%
        testPlot(meanSpikeRateRandReleaseAfter, meanSpikeRateFixedReleaseAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Release AFTER on Rand vs Fixed', 'Firing Rate (spk/s)', 'Random delay', 'Fixed Delay', 'FR_ReleaseAfter_RandVsFixed', []);

        %%%%%%%%%%%%%%%%%%% Less exciting one: compare BEFORE ISIs of RAND vs FIXED HOLD %%%%%%%%%%%%%%%%%%%%%%
        testPlot(meanSpikeRateRandHoldBefore, meanSpikeRateFixedHoldBefore, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Hold BEFORE on Rand vs Fixed', 'Firing Rate (spk/s)', 'Random delay', 'Fixed Delay', 'FR_HoldBefore_RandVsFixed', []);

        %%%%%%%%%%%%%%%%%%% Less exciting one: compare AFTER ISIs of RAND vs FIXED HOLD %%%%%%%%%%%%%%%%%%%%%%
        testPlot(meanSpikeRateRandHoldAfter, meanSpikeRateFixedHoldAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Hold AFTER on Rand vs Fixed', 'Firing Rate (spk/s)', 'Random delay', 'Fixed Delay', 'FR_HoldAfter_RandVsFixed', []);

        %%%%%%%%%%%%%%%%%%% Definetely you would want to compare BEFORE ISIs of RAND vs FIXED TARGET %%%%%%%%%%%%%%%%%%%%%%
        testPlot(meanSpikeRateRandTargetStimChangeBefore, meanSpikeRateFixedTargetStimChangeBefore, unitID, neuronType, strTrialType, sGlobalTitle, str, 'TargetStimChange BEFORE on Rand vs Fixed', 'Firing Rate (spk/s)', 'Random delay', 'Fixed Delay', 'FR_TargetBefore_RandVsFixed', []);

        %%%%%%%%%%%%%%%%%%% Definetely you would want to compare AFTER ISIs of RAND vs FIXED TargetStimChange %%%%%%%%%%%%%%%%%%%%%%
        testPlot(meanSpikeRateRandTargetStimChangeAfter, meanSpikeRateFixedTargetStimChangeAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'TargetStimChange AFTER on Rand vs Fixed', 'Firing Rate (spk/s)', 'Random delay', 'Fixed Delay', 'FR_TargetAfter_RandVsFixed', []);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ISI STATS AND PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        logger.info('compareFR_ISI', ['will do stats and plotting ISIs for unit=' num2str(unitID)]);

        % Compare Random HOLD vs Release trials
        testPlot(arrISIRandHold, arrISIRandRelease, unitID, neuronType, strTrialType, sGlobalTitle, str, '(random del.) HOLD VS RELEASE', 'ISI (ms)', 'Hold', 'Release', 'ISI_Rand_HoldVsRelease', [X_LIM_ISI]);

        % Compare Fixed HOLD vs Release trials
        testPlot(arrISIFixedHold, arrISIFixedRelease, unitID, neuronType, strTrialType, sGlobalTitle, str, '(fixed del.) HOLD VS RELEASE', 'ISI (ms)', 'Hold', 'Release', 'ISI_Fixed_HoldVsRelease', [X_LIM_ISI]);

        % Compare Random TARGET vs BASELINE trials
        testPlot(arrISIRandTargetStimChange, arrISIRandBaselineStimChange, unitID, neuronType, strTrialType, sGlobalTitle, str, '(random del.) TARGET VS BASELINE', 'ISI (ms)', 'Target stim. change', 'Baseline stim. change', 'ISI_Rand_TargetVsBaseline', [X_LIM_ISI]);

        % Compare Fixed TARGET vs BASELINE trials
        testPlot(arrISIFixedTargetStimChange, arrISIFixedBaselineStimChange, unitID, neuronType, strTrialType, sGlobalTitle, str, '(fixed del.) TARGET VS BASELINE', 'ISI (ms)', 'Target stim. change', 'Baseline stim. change', 'ISI_Fixed_TargetVsBaseline', [X_LIM_ISI]);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compare HOLD ISIs in Random vs Fixed trials
        testPlot(arrISIRandHold, arrISIFixedHold, unitID, neuronType, strTrialType, sGlobalTitle, str, 'RAND vs FIXED delay on Hold', 'ISI (ms)', 'Random delay', 'Fixed Delay', 'ISI_RandVsFixed_Hold', [X_LIM_ISI]);

        % Compare RELEASE FRs in Random vs Fixed trials
        testPlot(arrISIRandRelease, arrISIFixedRelease, unitID, neuronType, strTrialType, sGlobalTitle, str, 'RAND vs FIXED delay on Release', 'ISI (ms)', 'Random delay', 'Fixed Delay', 'ISI_RandVsFixed_Release', [X_LIM_ISI]);
         
        % Compare TARGET Stim change FRs in Random vs Fixed trials
        testPlot(arrISIRandTargetStimChange, arrISIFixedTargetStimChange, unitID, neuronType, strTrialType, sGlobalTitle, str, 'RAND vs FIXED delay on TargetStimChange', 'ISI (ms)', 'Random delay', 'Fixed Delay', 'ISI_RandVsFixed_TargetStimChange', [X_LIM_ISI]);

        % Compare BASELINE Stim change FRs in Random vs Fixed trials
        testPlot(arrISIRandBaselineStimChange, arrISIFixedBaselineStimChange, unitID, neuronType, strTrialType, sGlobalTitle, str, 'RAND vs FIXED delay on BaselineStimChange', 'ISI (ms)', 'Random delay', 'Fixed Delay', 'ISI_RandVsFixed_BaselineStimChange', [X_LIM_ISI]);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ISI COMPARISON of BEFORE VS AFTER EVENTS %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compare ISIs BEFORE vs AFTER the RAND HOLD event
        testPlot(arrISIRandHoldBefore, arrISIRandHoldAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Rand Hold BEFORE vs AFTER', 'ISI (ms)', 'Before the event', 'After the event', 'ISI_RandHold_BeforeVsAfter', [X_LIM_ISI]);
    
        % Compare ISIs BEFORE vs AFTER the RAND RELEASE event
        testPlot(arrISIRandReleaseBefore, arrISIRandReleaseAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Rand Release BEFORE vs AFTER', 'ISI (ms)', 'Before the event', 'After the event', 'ISI_RandRelease_BeforeVsAfter', [X_LIM_ISI]);

        % Compare ISIs BEFORE vs AFTER the RAND TARGET Stim change event
        testPlot(arrISIRandTargetStimChangeBefore, arrISIRandTargetStimChangeAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Rand Target stim change BEFORE vs AFTER', 'ISI (ms)', 'Before the event', 'After the event', 'ISI_RandTarget_BeforeVsAfter', [X_LIM_ISI]);

        % Compare ISIs BEFORE vs AFTER the RAND BASELINE Stim change event
        testPlot(arrISIRandBaselineStimChangeBefore, arrISIRandBaselineStimChangeAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Rand Baseline stim change BEFORE vs AFTER', 'ISI (ms)', 'Before the event', 'After the event', 'ISI_RandBaseline_BeforeVsAfter', [X_LIM_ISI]);

        % Compare ISIs BEFORE vs AFTER the Fixed HOLD event
        testPlot(arrISIFixedHoldBefore, arrISIFixedHoldAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Fixed Hold BEFORE vs AFTER', 'ISI (ms)', 'Before the event', 'After the event', 'ISI_FixedHold_BeforeVsAfter', [X_LIM_ISI]);
    
        % Compare ISIs BEFORE vs AFTER the Fixed RELEASE event
        testPlot(arrISIFixedReleaseBefore, arrISIFixedReleaseAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Fixed Release BEFORE vs AFTER', 'ISI (ms)', 'Before the event', 'After the event', 'ISI_FixedRelease_BeforeVsAfter', [X_LIM_ISI]);

        % Compare ISIs BEFORE vs AFTER the Fixed TARGET Stim change event
        testPlot(arrISIFixedTargetStimChangeBefore, arrISIFixedTargetStimChangeAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Fixed Target stim change BEFORE vs AFTER', 'ISI (ms)', 'Before the event', 'After the event', 'ISI_FixedTarget_BeforeVsAfter', [X_LIM_ISI]);

        % Compare ISIs BEFORE vs AFTER the Fixed BASELINE Stim change event
        testPlot(arrISIFixedBaselineStimChangeBefore, arrISIFixedBaselineStimChangeAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Fixed Baseline stim change BEFORE vs AFTER', 'ISI (ms)', 'Before the event', 'After the event', 'ISI_FixedBaseline_BeforeVsAfter', [X_LIM_ISI]);

        %%%%%%%%%%%%%%%%%%%%%%%%% Definetely you would want to compare BEFORE ISIs of RAND vs FIXED RELEASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        testPlot(arrISIRandReleaseBefore, arrISIFixedReleaseBefore, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Release BEFORE on Rand vs Fixed', 'ISI (ms)', 'Rand delay', 'Fixed Delay', 'ISI_ReleaseBefore_RandVsFixed', [X_LIM_ISI]);

        %%%%%%%%%%%%%%%%%%%%%%%%% Definetely you would want to compare AFTER ISIs of RAND vs FIXED RELEASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        testPlot(arrISIRandReleaseAfter, arrISIFixedReleaseAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Release AFTER on Rand vs Fixed', 'ISI (ms)', 'Rand delay', 'Fixed Delay', 'ISI_ReleaseAfter_RandVsFixed', [X_LIM_ISI]);

        %%%%%%%%%%%%%%%%%%%%%%%%% And then less exciting one: compare BEFORE ISIs of RAND vs FIXED HOLD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        testPlot(arrISIRandHoldBefore, arrISIFixedHoldBefore, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Hold BEFORE on Rand vs Fixed', 'ISI (ms)', 'Rand delay', 'Fixed Delay', 'ISI_HoldBefore_RandVsFixed', [X_LIM_ISI]);

        %%%%%%%%%%%%%%%%%%%%%%%%% And then less exciting one: compare AFTER ISIs of RAND vs FIXED HOLD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        testPlot(arrISIRandHoldAfter, arrISIFixedHoldAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'Hold AFTER on Rand vs Fixed', 'ISI (ms)', 'Rand delay', 'Fixed Delay', 'ISI_HoldAfter_RandVsFixed', [X_LIM_ISI]);

        %%%%%%%%%%%%%%%%%%%%%%%%% Definetely you would want to compare BEFORE ISIs of RAND vs FIXED TARGET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        testPlot(arrISIRandTargetStimChangeBefore, arrISIFixedTargetStimChangeBefore, unitID, neuronType, strTrialType, sGlobalTitle, str, 'TargetStimChange BEFORE on Rand vs Fixed', 'ISI (ms)', 'Rand delay', 'Fixed Delay', 'ISI_TargetBefore_RandVsFixed', [X_LIM_ISI]);

        %%%%%%%%%%%%%%%%%%%%%%%%% Definetely you would want to compare AFTER ISIs of RAND vs FIXED TARGET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        testPlot(arrISIRandTargetStimChangeAfter, arrISIFixedTargetStimChangeAfter, unitID, neuronType, strTrialType, sGlobalTitle, str, 'TargetStimChange AFTER on Rand vs Fixed', 'ISI (ms)', 'Rand delay', 'Fixed Delay', 'ISI_TargetAfter_RandVsFixed', [X_LIM_ISI]);

end