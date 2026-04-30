function plotPairedRaster(suppressedPairs_CS_SS, pairs, units, sPairAsst, sPairMain, ccgType, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrStimTurnedOnTrials, arrSelectedTrials, strTrialType)

    globals;
    if ~isempty(pairs)
        for iPair=1:length(pairs)
            unitPairAsst = units(find([units.id]==pairs(iPair,1)));
            unitPairMain = units(find([units.id]==pairs(iPair,2)));
            
            if ~isempty(unitPairAsst) && ~isempty(unitPairMain) && suppressedPairs_CS_SS(iPair) % is this a real pair-there is a suppression between them % && unitPairAsst.id==291 && unitPairMain.id == 285 %
                [spikeTimeAlignedToLeverHoldAsst, spikeTimeAlignedToLeverReleaseAsst, spikeTimeAlignedToTargetVisStimAsst, spikeTimeAlignedToBaselineVisStimAsst, ...
                spikeTimeofTrialAlignedToLeverReleaseAsst, spikeTimeofTrialwITIAlignedToLeverReleaseAsst, leverHoldTimesAlignedToLeverReleaseAsst,...
                leverHoldTimesAlignedToTargetVisStimAsst, leverReleaseTimesAlignedToTargetVisStimAsst, leverReleaseTimesAlignedToBaselineVisStimAsst, targetVisStimAlignedToLeverHoldAsst, targetVisStimAlignedToLeverReleaseAsst, baselineVisStimAlignedToLeverReleaseAsst, ...
                fixedHoldStartsAtRelativeTrialAsst, allTrialCountAsst] = chunkAlignSpikeTimes(unitPairAsst.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrStimTurnedOnTrials, arrSelectedTrials);
            
                [spikeTimeAlignedToLeverHoldMain, spikeTimeAlignedToLeverReleaseMain, spikeTimeAlignedToTargetVisStimMain, spikeTimeAlignedToBaselineVisStimMain, ...
                spikeTimeofTrialAlignedToLeverReleaseMain, spikeTimeofTrialwITIAlignedToLeverReleaseMain, leverHoldTimesAlignedToLeverReleaseMain,...
                leverHoldTimesAlignedToTargetVisStim, leverReleaseTimesAlignedToTargetVisStim, leverReleaseTimesAlignedToBaselineVisStim, targetVisStimAlignedToLeverHold, targetVisStimAlignedToLeverRelease, baselineVisStimAlignedToLeverRelease, ...
                fixedHoldStartsAtRelativeTrial, allTrialCount] = chunkAlignSpikeTimes(unitPairMain.spikeTimesSecs, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetVisStimChangeTimeGLX, baselineVisStimChangeTimeGLX, arrStimTurnedOnTrials, arrSelectedTrials);
        
                %******************************* PLOTTING for LEVER HOLD/RELEASE *************************************************
                logger.info('plotPairedRaster', ['Plotting LEVER HOLD/RELEASE PAIRED_RASTER for units ' sPairAsst '=' num2str(unitPairAsst.id) ' and ' sPairMain '=' num2str(unitPairMain.id) ' ' strTrialType]);

                str = '';
                if ~isempty(strTrialType)
                    str = ['(' num2str(length(arrSelectedTrials)) ' ' strTrialType ' trials)'];
                end
         
                startTimeHold = (leverHoldTimes-PRE_TIME_HOLD);
                startTimeHold = startTimeHold(arrSelectedTrials);
                endTimeHold = ((leverHoldTimes+POST_TIME_HOLD));
                endTimeHold = endTimeHold(arrSelectedTrials);
                
                startTimeRelease = (leverReleaseTimesGLX-PRE_TIME_RELEASE);
                startTimeRelease = startTimeRelease(arrSelectedTrials);
                endTimeRelease = ((leverReleaseTimesGLX+POST_TIME_RELEASE));
                endTimeRelease = endTimeRelease(arrSelectedTrials);

                plotRaster({spikeTimeAlignedToLeverHoldMain, spikeTimeAlignedToLeverReleaseMain}, ...
                    {[spikeTimeAlignedToLeverHoldAsst; targetVisStimAlignedToLeverHold],[spikeTimeAlignedToLeverReleaseAsst; targetVisStimAlignedToLeverRelease]},...
                    {startTimeHold,startTimeRelease}, {endTimeHold, endTimeRelease}, fixedHoldStartsAtRelativeTrial, {-PRE_TIME_HOLD, -PRE_TIME_RELEASE}, {POST_TIME_HOLD, POST_TIME_RELEASE}, {'Lever Hold aligned (CS spikes green, Target red marked)','Lever Release aligned (CS spikes green, Target red marked)'}, {'g','r'});
        

%                 f = figure;
%                 f.Position = [globalX globalY globalW globalH];                        
%                 %%%%%%%%%%%%%%%%%%%%%% RASTER - Lever Hold Aligned Spikes %%%%%%%%%%%%%%%%%%%
%                 
%                 subplot(2,1,1)
%                 plotRaster(spikeTimeAlignedToLeverHoldMain, [spikeTimeAlignedToLeverHoldAsst; targetVisStimAlignedToLeverHold], startTime, endTime, fixedHoldStartsAtRelativeTrial, -PRE_TIME_HOLD, POST_TIME_HOLD, 'Lever Hold aligned (CS spikes red, Target black marked)');
%                 %%%%%%%%%%%%%%%%%%%%%% RASTER - Lever Release Aligned Spikes %%%%%%%%%%%%%%%%%%%
%                 startTime = (leverReleaseTimesGLX-PRE_TIME_RELEASE);
%                 startTime = startTime(arrSelectedTrials);
%                 endTime = ((leverReleaseTimesGLX+POST_TIME_RELEASE));
%                 endTime = endTime(arrSelectedTrials);
%                 subplot(2,1,2)
%                 plotRaster(spikeTimeAlignedToLeverReleaseMain, [spikeTimeAlignedToLeverReleaseAsst; targetVisStimAlignedToLeverRelease], startTime, endTime, fixedHoldStartsAtRelativeTrial, -PRE_TIME_RELEASE, POST_TIME_RELEASE, 'Lever Release aligned (CS spikes red, Target black marked)');        
                sgtitle(['Units ' unitPairAsst.neuronType '=' num2str(unitPairAsst.id) ' (' unitPairAsst.layer ') & ' unitPairMain.neuronType '=' num2str(unitPairMain.id) ' (' unitPairMain.layer ') trials=' num2str(allTrialCount) ' ' str])
                print([pathToFigureFolder ccgType '/PairedRaster_' num2str(unitPairAsst.id) 'and' num2str(unitPairMain.id) '_holdReleaseAligned_' strTrialType '_xlim_' num2str(PRE_TIME_RELEASE) '_' num2str(POST_TIME_RELEASE) '.tif'], '-dtiff', '-r200');
                
                %******************************************* PLOTTING for BASELINE/TARGET VISUAL STIMULI ******************************
                logger.info('plotPairedRaster', ['Plotting BASELINE/TARGET VISUAL STIMULI PAIRED_RASTER for units ' sPairAsst '=' num2str(unitPairAsst.id) ' and ' sPairMain '=' num2str(unitPairMain.id) ' ' strTrialType]);

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
                
                plotRaster({spikeTimeAlignedToTargetVisStimMain, spikeTimeAlignedToBaselineVisStimMain}, ...
                    {[spikeTimeAlignedToTargetVisStimAsst; leverHoldTimesAlignedToTargetVisStim],[spikeTimeAlignedToBaselineVisStimAsst; leverReleaseTimesAlignedToBaselineVisStim]},...
                    {startTimeTarget,startTimeBaseline}, {endTimeTarget, endTimeBaseline}, fixedHoldStartsAtRelativeTrial, {-PRE_TIME_VIS_STIM, -PRE_TIME_VIS_STIM}, {POST_TIME_VIS_STIM, POST_TIME_VIS_STIM}, {'Target Stim aligned (CS spikes green, Lever Hold blue marked)', 'Baseline Stim aligned (CS spikes green, Lever Release blue marked)'}, {'g','b'});
        
                
%                 f = figure;
%                 f.Position = [globalX globalY globalW globalH];                        
%                 %%%%%%%%%%%%%%%%%%%%%% RASTER - Target Stim Aligned Spikes %%%%%%%%%%%%%%%%%%%
%                 startTime = ones(1,allTrialCount)*-1;
%                 startTime(arrStimTurnedOnTrials) = targetVisStimChangeTimeGLX-PRE_TIME_VIS_STIM;
%                 startTime = startTime(arrSelectedTrials); % Include only selected trials
% 
%                 endTime = ones(1,allTrialCount)*-1;
%                 endTime(arrStimTurnedOnTrials) = targetVisStimChangeTimeGLX+POST_TIME_VIS_STIM;
%                 endTime = endTime(arrSelectedTrials); % Include only selected trials
% 
%                 subplot(2,1,1)
%                 plotRaster(spikeTimeAlignedToTargetVisStimMain, [spikeTimeAlignedToTargetVisStimAsst; leverHoldTimesAlignedToTargetVisStim], startTime, endTime, fixedHoldStartsAtRelativeTrial, -PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM, 'Target Stim aligned (CS spikes red, Lever Hold black marked)');                
%                 %%%%%%%%%%%%%%%%%%%%%% RASTER - Baseline Stim Aligned Spikes %%%%%%%%%%%%%%%%%%%
%                 %startTime = baselineVisStimChangeTimeGLX-PRE_TIME_VIS_STIM;
%                 startTime = ones(1,allTrialCount)*-1;
%                 startTime(arrStimTurnedOnTrials) = baselineVisStimChangeTimeGLX-PRE_TIME_VIS_STIM;
%                 startTime = startTime(arrSelectedTrials);  % Include only selected trials
%                 %endTime = baselineVisStimChangeTimeGLX+POST_TIME_VIS_STIM;
%                 endTime = ones(1,allTrialCount)*-1;
%                 endTime(arrStimTurnedOnTrials) = baselineVisStimChangeTimeGLX+POST_TIME_VIS_STIM;
%                 endTime = endTime(arrSelectedTrials); % Include only selected trials
%                 subplot(2,1,2)
%                 plotRaster(spikeTimeAlignedToBaselineVisStimMain, [spikeTimeAlignedToBaselineVisStimAsst; leverReleaseTimesAlignedToBaselineVisStim], startTime, endTime, fixedHoldStartsAtRelativeTrial, -PRE_TIME_VIS_STIM, POST_TIME_VIS_STIM, 'Baseline Stim aligned (CS spikes red, Lever Release black marked)');
                sgtitle(['Units ' unitPairAsst.neuronType '=' num2str(unitPairAsst.id) ' (' unitPairAsst.layer ') & ' unitPairMain.neuronType '=' num2str(unitPairMain.id) ' (' unitPairMain.layer ') trials=' num2str(allTrialCount) ' ' str])
                print([pathToFigureFolder ccgType '/PairedRaster_' num2str(unitPairAsst.id) 'and' num2str(unitPairMain.id) '_targetBaselineAligned_' strTrialType '_xlim_' num2str(PRE_TIME_RELEASE) '_' num2str(POST_TIME_RELEASE) '.tif'], '-dtiff', '-r200');
            end
        end
    end    
end