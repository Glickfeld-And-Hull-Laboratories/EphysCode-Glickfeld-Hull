%%%% PLOT RASTER PSTH %%%%%%%%%%%%
% spikeTimesSec: Spike times in sec
%
% SO 10/24/2022 Hull Lab
function plotRasterLeverVisStim(unitID, neuronCategory, neuronType, layer, channel, allTrialCount, spikeTimeAlignedToLeverHold, spikeTimeAlignedToLeverRelease, spikeTimeAlignedToTargetVisStim, spikeTimeAlignedToBaselineVisStim, ...
    targetVisStimAlignedToLeverHold, targetVisStimAlignedToLeverRelease, baselineVisStimAlignedToLeverRelease, leverHoldTimesAlignedToTargetVisStim, leverReleaseTimesAlignedToTargetVisStim, leverReleaseTimesAlignedToBaselineVisStim, ...
    fixedHoldStartsAtRelativeTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrStimTurnedOnTrials, arrSelectedTrials, strTrialType)

        globals;
        
        sPrintFolder = [pathToFigureFolder neuronCategory '/' num2str(unitID)];
        if ~isempty(neuronType)
            sPrintFolder = [sPrintFolder '_' neuronType];
        end
        
        str = '';
        if ~isempty(strTrialType)
            str = ['(' num2str(length(arrSelectedTrials)) ' ' strTrialType ' trials)'];
        end

        if ~all(cellfun(@isempty,spikeTimeAlignedToLeverHold)) || ~all(cellfun(@isempty,spikeTimeAlignedToLeverRelease))
            %******************************* PLOTTING for LEVER HOLD/RELEASE *************************************************
            logger.info('plotRasterLeverVisStim', ['Plotting LEVER HOLD/RELEASE for unit=' num2str(unitID) ' ' strTrialType]);
            
            startTimeHold = (leverHoldTimes-PRE_TIME_HOLD);
            startTimeHold = startTimeHold(arrSelectedTrials);
            endTimeHold = ((leverHoldTimes+POST_TIME_HOLD));
            endTimeHold = endTimeHold(arrSelectedTrials);
    
            startTimeRelease = (leverReleaseTimesGLX-PRE_TIME_RELEASE);
            startTimeRelease = startTimeRelease(arrSelectedTrials);
            endTimeRelease = ((leverReleaseTimesGLX+POST_TIME_RELEASE));
            endTimeRelease = endTimeRelease(arrSelectedTrials);
    
            plotRaster({spikeTimeAlignedToLeverHold, spikeTimeAlignedToLeverRelease}, {[targetVisStimAlignedToLeverHold],[targetVisStimAlignedToLeverRelease]},...
            {startTimeHold,startTimeRelease}, {endTimeHold, endTimeRelease}, fixedHoldStartsAtRelativeTrial, {-PRE_TIME_HOLD, -PRE_TIME_RELEASE}, {POST_TIME_HOLD, POST_TIME_RELEASE}, {'Lever Hold aligned (Target Stim red marked)','Lever Release aligned (Target red marked)'}, {'r'});
            sgtitle(['Unit=' num2str(unitID) ' ' neuronType ' (' layer ' ch=' num2str(channel) ') trials=' num2str(allTrialCount) ' ' str])
            print([sPrintFolder '/' neuronType '_raster_holdReleaseAligned_' strTrialType '_xlim_' num2str(PRE_TIME_RELEASE) '_' num2str(POST_TIME_RELEASE) '.tif'], '-dtiff', '-r200');
        else
            logger.info('plotRasterLeverVisStim', ['NO SPIKES to plot! LEVER HOLD/RELEASE for unit=' num2str(unitID) ' ' strTrialType]);
        end

        if ~all(cellfun(@isempty,spikeTimeAlignedToTargetVisStim)) || ~all(cellfun(@isempty,spikeTimeAlignedToBaselineVisStim))
            %******************************************* PLOTTING for BASELINE/TARGET VISUAL STIMULI ******************************
            logger.info('plotRasterPSTH', ['Plotting BASELINE/TARGET VISUAL STIMULI for unit=' num2str(unitID) ' ' strTrialType]);
                                  
            %%%%%%%%%%%%%%%%%%%%%% RASTER - Target Stim Aligned Spikes %%%%%%%%%%%%%%%%%%%
            startTimeTarget = ones(1,allTrialCount)*-1;
            startTimeTarget(arrStimTurnedOnTrials) = targetVisStimChangeTimeGLX-PRE_TIME_VIS_STIM;
            startTimeTarget = startTimeTarget(arrSelectedTrials); % Include only selected trials        
            endTimeTarget = ones(1,allTrialCount)*-1;
            endTimeTarget(arrStimTurnedOnTrials) = targetVisStimChangeTimeGLX+POST_TIME_VIS_STIM;
            endTimeTarget = endTimeTarget(arrSelectedTrials); % Include only selected trials
            
            startTimeBaseline = ones(1,allTrialCount)*-1;
            startTimeBaseline(arrStimTurnedOnTrials) = baselineVisStimChangeTimeGLX-PRE_TIME_VIS_STIM;
            startTimeBaseline = startTimeBaseline(arrSelectedTrials);  % Include only selected trials        
            endTimeBaseline = ones(1,allTrialCount)*-1;
            endTimeBaseline(arrStimTurnedOnTrials) = baselineVisStimChangeTimeGLX+POST_TIME_VIS_STIM;
            endTimeBaseline = endTimeBaseline(arrSelectedTrials); % Include only selected trials
            
            plotRaster({spikeTimeAlignedToTargetVisStim, spikeTimeAlignedToBaselineVisStim}, {[leverHoldTimesAlignedToTargetVisStim; leverReleaseTimesAlignedToTargetVisStim],[leverReleaseTimesAlignedToBaselineVisStim]},...
            {startTimeTarget,startTimeBaseline}, {endTimeTarget, endTimeBaseline}, fixedHoldStartsAtRelativeTrial, {-PRE_TIME_VIS_STIM, -PRE_TIME_VIS_STIM}, {POST_TIME_VIS_STIM, POST_TIME_VIS_STIM}, {'Target Stim aligned (Hold(blue) and Release(magenta) marked)','Baseline Stim aligned (Lever Release blue marked)'}, {'b', 'm'});
        
            sgtitle(['Unit=' num2str(unitID) ' ' neuronType ' (' layer ' ch=' num2str(channel) ') trials=' num2str(allTrialCount) ' ' str])
            print([sPrintFolder '/' neuronType '_raster_targetBaselineStimAligned_' strTrialType '_xlim_' num2str(PRE_TIME_VIS_STIM) '_' num2str(POST_TIME_VIS_STIM) '.tif'], '-dtiff', '-r200');
        else
            logger.info('plotRasterLeverVisStim', ['NO SPIKES to plot! BASELINE/TARGET VISUAL STIMULI for unit=' num2str(unitID) ' ' strTrialType]);
        end
        
        close all
end