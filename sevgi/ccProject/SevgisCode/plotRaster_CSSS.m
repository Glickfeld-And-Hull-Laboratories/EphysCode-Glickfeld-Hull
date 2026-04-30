function plotRaster_CSSS(behavDataForRecordingDays, unitCSs, unitSSs, paramMouseId, paramDay, modeTraining)
    globals;
            
    indsRecordingDays = find([behavDataForRecordingDays.mouse]==paramMouseId & ismember([behavDataForRecordingDays.day],paramDay));
    indsCSs = find(ismember([unitCSs.RecorNum], indsRecordingDays));
    
    nUnitActivated = 0;
    nUnitSuppressed = 0;
    nUnitNonResponsive = 0;

%     if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
%         sAlignedTo = 'click';
%         pathToCSPsthFolder = pathToCSToClickPsthFolder;
%         pathToSSPsthFolder = pathToSSToClickPsthFolder;
%     elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
%         sAlignedTo = 'lick';
%         pathToCSPsthFolder = pathToCSToLickPsthFolder;
%         pathToSSPsthFolder = pathToSSToLickPsthFolder;
%     end

    for indLoop=1:length(indsCSs)
        unitCS = unitCSs(indsCSs(indLoop));
        recordingDayInd = unitCS.RecorNum;
        behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);
        recordingDayTrials = behavDataForRecordingDay.TrialStruct;
        recordingDayLickOnsets = behavDataForRecordingDay.LickOnsets;

        mouseId = behavDataForRecordingDay.mouse;
        day = behavDataForRecordingDay.day;

        % Patch to correct NaN values in TrialType
        lickOnsetTrialTypes = {recordingDayLickOnsets.TrialType};
        nanIdsCell = cellfun(@ (x) any(isnan(x)),lickOnsetTrialTypes, UniformOutput=true);
        %[lickOnsetTrialTypes{nanIdsCell}] = deal('');
        lickOnsetTrialTypes = lickOnsetTrialTypes(~nanIdsCell); % Ignore NaN lick onset entries
        recordingDayLickOnsets = recordingDayLickOnsets(~nanIdsCell); % Ignore NaN lick onset entries
        
        indsSelectedRespCSTrials = ismember({recordingDayTrials.TrialType},TRIALS_TO_INCLUDE_CS_RESPONSIVE_TO_CLICK);
        indsSelectedRespCSLickOnsets = ismember(lickOnsetTrialTypes,TRIALS_TO_INCLUDE_CS_RESPONSIVE_TO_CLICK);

        if modeTraining==1 % NAIVE DAYS ANALYZED
            indsSelectedTrials = ismember({recordingDayTrials.TrialType},TRIALS_TO_INCLUDE_NAIVE_DAY_ANALYSES);            
            indsSelectedLickOnsets = ismember(lickOnsetTrialTypes,TRIALS_TO_INCLUDE_NAIVE_DAY_ANALYSES);
        elseif modeTraining==2 % HABITUATION DAYS ANALYZED
            indsSelectedTrials = ismember({recordingDayTrials.TrialType},TRIALS_TO_INCLUDE_HABITUATION_DAY_ANALYSES);            
            indsSelectedLickOnsets = ismember(lickOnsetTrialTypes,TRIALS_TO_INCLUDE_HABITUATION_DAY_ANALYSES);
        elseif modeTraining==3 % EXPERT DAYS ANALYZED
            indsSelectedTrials = ismember({recordingDayTrials.TrialType},TRIALS_TO_INCLUDE_EXPERT_DAY_ANALYSES);
            indsSelectedLickOnsets = ismember(lickOnsetTrialTypes,TRIALS_TO_INCLUDE_EXPERT_DAY_ANALYSES);
        end

        recordingDayTrialsSelected = recordingDayTrials(indsSelectedTrials);
        recordingDayLickOnsetsSelected = recordingDayLickOnsets(indsSelectedLickOnsets);

        if ~isempty(recordingDayTrialsSelected)
            % All trials to be able to see everything on raster plots            
            if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
                trialTypes = {recordingDayTrials.TrialType};
                arrTimes = [recordingDayTrials.JuiceTime];  
                arrToneTimes = [recordingDayTrials.ToneTime];
                toneTimesAligned = chunkAlignSpikeTimes(arrToneTimes, arrTimes);

                recordingDayRespCSSelected = recordingDayTrials(indsSelectedRespCSTrials);
                arrTimesRespCSSelected = [recordingDayRespCSSelected.JuiceTime];                
                sLabel1 = 'aligned to click';
                path = pathToCSRasterToClickFolder;
                pathSS = pathToSSRasterToClickFolder;
            elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
                trialTypes = {recordingDayLickOnsets.TrialType};
                arrTimes = [recordingDayLickOnsets.time];
                toneTimesAligned = [];

                recordingDayRespCSSelected = recordingDayLickOnsets(indsSelectedRespCSLickOnsets);
                arrTimesRespCSSelected = [recordingDayRespCSSelected.time];
                sLabel1 = 'aligned to lick';
                path = pathToCSRasterToLickFolder;
                pathSS = pathToSSRasterToLickFolder;
            end

            % since we always check reward responsive CSs! it should not change based on which behavioral event we align
            csTimesAlignedRewSelected = chunkAlignSpikeTimes(unitCS.timestamps, [recordingDayRespCSSelected.JuiceTime]); %arrTimesRespCSSelected);
            csTimesAligned = chunkAlignSpikeTimes(unitCS.timestamps, arrTimes);            

            if length(csTimesAlignedRewSelected)>(TRIALS_TO_COMPARE+TRIALS_TO_TRIM)
                trialSlice = [length(csTimesAlignedRewSelected)-TRIALS_TO_COMPARE-TRIALS_TO_TRIM:length(csTimesAlignedRewSelected)-TRIALS_TO_TRIM];
            else
                trialSlice = [1:length(csTimesAlignedRewSelected)];
            end
            flagResponsive = isResponsive(csTimesAlignedRewSelected, trialSlice);
            
            if flagResponsive == -1
                nUnitSuppressed = nUnitSuppressed + 1;
                sLabel2 = 'SUPRESSED';
                logger.info('plotRaster_CSSS', ['RARE but Suppressed unit=' num2str(unitCS.unitID) ' day ' num2str(behavDataForRecordingDay.day) ' mouse ' num2str(behavDataForRecordingDay.mouse)]);
            elseif flagResponsive == 1
                nUnitActivated = nUnitActivated + 1;
                sLabel2 = 'Responsive';
                logger.info('plotRaster_CSSS', ['Responsive unit=' num2str(unitCS.unitID) ' day ' num2str(behavDataForRecordingDay.day) ' mouse ' num2str(behavDataForRecordingDay.mouse)]);
            elseif flagResponsive == 0
                nUnitNonResponsive = nUnitNonResponsive + 1;
                sLabel2 = 'NonResponsive';
                logger.info('plotRaster_CSSS', ['Non responsive unit=' num2str(unitCS.unitID) ' day ' num2str(behavDataForRecordingDay.day) ' mouse ' num2str(behavDataForRecordingDay.mouse)]);
            end

            colorCodes = getColorCodesForTrialTypes(trialTypes, 0);                
            sTitle = [sLabel2 ' CS time ' sLabel1 ' on day ' num2str(behavDataForRecordingDay.day) ' mouse=' num2str(behavDataForRecordingDay.mouse)];
            sFile = [path 'mouse' num2str(behavDataForRecordingDay.mouse) '_day_' num2str(behavDataForRecordingDay.day) '_' unitCS.c4_label '_' num2str(unitCS.unitID) '.tif'];
%             [arrFirstSpikeLatency, arrSecondSpikeLatency] = 
            plotRaster(unitCS.unitID, unitCS.c4_label, unitCS.layer, unitCS.channel, csTimesAligned, toneTimesAligned, sTitle, sFile, colorCodes);
        
            [unitSS, trialsCueResponsive] = findPair(unitSSs, recordingDayInd, unitCS.PCpair, arrTimes);
            if ~isempty(unitSS)
                ssTimesAligned = chunkAlignSpikeTimes(unitSS.timestamps, arrTimes);
                colorCodes = getColorCodesForTrialTypes(trialTypes, 1);
                sTitle = ['SS w' sLabel2 ' CS ' sLabel1 ' on day ' num2str(behavDataForRecordingDay.day) ' mouse=' num2str(behavDataForRecordingDay.mouse)];
                sFile = [pathSS 'mouse' num2str(behavDataForRecordingDay.mouse) '_day_' num2str(behavDataForRecordingDay.day) '_' unitSS.c4_label '_' num2str(unitSS.unitID) '_' sLabel2 '.tif'];
                plotRaster(unitSS.unitID, unitSS.c4_label, unitSS.layer, unitSS.channel, ssTimesAligned, toneTimesAligned, sTitle, sFile, colorCodes);                        
            end  

            % cellFirstSpikeLatency{length(cellFirstSpikeLatency)+1} = arrFirstSpikeLatency;
            % cellSecondSpikeLatency{length(cellSecondSpikeLatency)+1} = arrSecondSpikeLatency;

            % if ~isempty(arrFirstSpikeLatency)
            %     sTitle = ['CS first spike latency aligned to juice on day ' num2str(behavDataForRecordingDay.day) ' mouse=' num2str(behavDataForRecordingDay.mouse)];
            %     sFile = [pathToLatencyFolder '/firstSpike_' unitCS.c4_label '_' num2str(unitCS.unitID) 'day' num2str(behavDataForRecordingDay.day) 'mouse' num2str(behavDataForRecordingDay.mouse)  '.tif'];
            %     scatterDataByNormalizedTrialNumbers(arrFirstSpikeLatency, 'Normalized trial number', 'Latency (s)', sTitle, sFile);
            % end
            % 
            % if ~isempty(arrSecondSpikeLatency)
            %     sTitle = ['CS second spike latency aligned to juice on day ' num2str(behavDataForRecordingDay.day) ' mouse=' num2str(behavDataForRecordingDay.mouse)];
            %     sFile = [pathToLatencyFolder '/secondSpike_' unitCS.c4_label '_' num2str(unitCS.unitID) 'day' num2str(behavDataForRecordingDay.day) 'mouse' num2str(behavDataForRecordingDay.mouse)  '.tif'];
            %     scatterDataByNormalizedTrialNumbers(arrSecondSpikeLatency, 'Normalized trial number', 'Latency (s)', sTitle, sFile);
            % end 
        end
    end
end