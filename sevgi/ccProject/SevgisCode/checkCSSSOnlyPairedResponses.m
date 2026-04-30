% clearvars -except Rlist CS SS SumSt
% close all
% globals;

% behavDataForRecordingDays = Rlist;

% structUnitsPerRecordingDays = SumSt;
% cellTypes = {SumSt.CellType};
% cellC4Labels = {SumSt.c4_label};
% indTemp = find(strcmp({SumSt.CellType}, 'CS') & [SumSt.c4_confidence]>2);

% unitCSs = CS;

function [cellCSTimesResponsivePerDay, cellCSTimesNonResponsivePerDay, ...
    cellSSTimesPairedWJuiceRespCueResponsiveCSPerDay, cellSSTimesPairedWJuiceRespCueNonResponsiveCSPerDay, ...
    cellSSTimesPairedWJuiceNonRespCueResponsiveCSPerDay, cellSSTimesPairedWJuiceNonRespCueNonResponsiveCSPerDay, ...
    cellSSAllLicksJuiceRespCueResponsiveCSPerDay, cellSSAllLicksJuiceRespCueNonResponsiveCSPerDay, ...
    cellSSAllLicksJuiceNonRespCueResponsiveCSPerDay, cellSSAllLicksJuiceNonRespCueNonResponsiveCSPerDay, ...
    cellSSLickOnsetsJuiceRespCueResponsiveCSPerDay, cellSSLickOnsetsJuiceRespCueNonResponsiveCSPerDay, ...
    cellSSLickOnsetsJuiceNonRespCueResponsiveCSPerDay, cellSSLickOnsetsJuiceNonRespCueNonResponsiveCSPerDay,...
    cellSSCuesJuiceRespCueResponsiveCSPerDay, cellSSCuesJuiceRespCueNonResponsiveCSPerDay, ...
    cellSSCuesJuiceNonRespCueResponsiveCSPerDay, cellSSCuesJuiceNonRespCueNonResponsiveCSPerDay] = ...
    checkCSSSOnlyPairedResponses(behavDataForRecordingDays, unitCSs, unitSSs, paramMouseId, paramDay)
    globals;
        
    dayNext = 0;

    % arrNaiveRecordingDays = behavDataForRecordingDays([behavDataForRecordingDays.day] <= 3); % get only first three (Naive) days
    indsRecordingDays = find([behavDataForRecordingDays.mouse]==paramMouseId & ismember([behavDataForRecordingDays.day],paramDay));
    indsCSs = find(ismember([unitCSs.RecorNum], indsRecordingDays));
    
    cellCSTimesResponsive = {};
    cellSSTimesPairedWJuiceRespCueResponsiveCS = {};
    cellSSTimesPairedWJuiceRespCueNonResponsiveCS = {};
    cellCSTimesNonResponsive = {};
    cellSSTimesPairedWJuiceNonRespCueResponsiveCS = {};
    cellSSTimesPairedWJuiceNonRespCueNonResponsiveCS = {};

    cellSSAllLicksJuiceRespCueResponsiveCS = {};
    cellSSAllLicksJuiceRespCueNonResponsiveCS = {};
    cellSSAllLicksJuiceNonRespCueResponsiveCS = {};
    cellSSAllLicksJuiceNonRespCueNonResponsiveCS = {};

    cellSSLickOnsetsJuiceRespCueResponsiveCS = {};
    cellSSLickOnsetsJuiceRespCueNonResponsiveCS = {};
    cellSSLickOnsetsJuiceNonRespCueResponsiveCS = {};
    cellSSLickOnsetsJuiceNonRespCueNonResponsiveCS = {};

    cellSSCuesJuiceRespCueResponsiveCS = {};
    cellSSCuesJuiceRespCueNonResponsiveCS = {};
    cellSSCuesJuiceNonRespCueResponsiveCS = {};
    cellSSCuesJuiceNonRespCueNonResponsiveCS = {};
    
    cellSSpairedWithCSResponsive = {};
    cellSSpairedWithCSNonResponsive = {};

    nUnitActivated = 0;
    nUnitSuppressed = 0;
    nUnitNonResponsive = 0;

    cellCSTimesResponsivePerDay = cell(1,length(paramDay));
    cellCSTimesNonResponsivePerDay = cell(1,length(paramDay));
    
    cellSSTimesPairedWJuiceRespCueResponsiveCSPerDay = cell(1,length(paramDay));
    cellSSTimesPairedWJuiceRespCueNonResponsiveCSPerDay = cell(1,length(paramDay));
    cellSSTimesPairedWJuiceNonRespCueResponsiveCSPerDay = cell(1,length(paramDay));
    cellSSTimesPairedWJuiceNonRespCueNonResponsiveCSPerDay = cell(1,length(paramDay));

    cellSSAllLicksJuiceRespCueResponsiveCSPerDay = cell(1,length(paramDay));
    cellSSAllLicksJuiceRespCueNonResponsiveCSPerDay = cell(1,length(paramDay));
    cellSSAllLicksJuiceNonRespCueResponsiveCSPerDay = cell(1,length(paramDay));
    cellSSAllLicksJuiceNonRespCueNonResponsiveCSPerDay = cell(1,length(paramDay));

    cellSSLickOnsetsJuiceRespCueResponsiveCSPerDay = cell(1,length(paramDay));
    cellSSLickOnsetsJuiceRespCueNonResponsiveCSPerDay = cell(1,length(paramDay));
    cellSSLickOnsetsJuiceNonRespCueResponsiveCSPerDay = cell(1,length(paramDay));
    cellSSLickOnsetsJuiceNonRespCueNonResponsiveCSPerDay = cell(1,length(paramDay));

    cellSSCuesJuiceRespCueResponsiveCSPerDay = cell(1,length(paramDay));
    cellSSCuesJuiceRespCueNonResponsiveCSPerDay = cell(1,length(paramDay));
    cellSSCuesJuiceNonRespCueResponsiveCSPerDay = cell(1,length(paramDay));
    cellSSCuesJuiceNonRespCueNonResponsiveCSPerDay = cell(1,length(paramDay));

    if ~isempty(indsCSs)
        if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
            sAlignedTo = 'click';
            pathToCSPsthFolder = pathToCSToClickPsthFolder;
            pathToSSPsthFolder = pathToSSToClickPsthFolder;
        elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
            sAlignedTo = 'lick';
            pathToCSPsthFolder = pathToCSToLickPsthFolder;
            pathToSSPsthFolder = pathToSSToLickPsthFolder;
        elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_TONE
            sAlignedTo = 'tone';
            pathToCSPsthFolder = pathToCSToTonePsthFolder;
            pathToSSPsthFolder = pathToSSToTonePsthFolder;
        end
    
        unitCS = unitCSs(indsCSs(1));
        recordingDayInd = unitCS.RecorNum;
        behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);
        [arrBehavTimesSelected, recordingDayCellAllLicksSelected, lickOnsetsSelected, cueTimesSelected] = findBehavioralTimes(paramMouseId, paramDay, behavDataForRecordingDay);
    
        for indLoop=1:length(indsCSs)
                unitCS = unitCSs(indsCSs(indLoop));
                recordingDayInd = unitCS.RecorNum;
                behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);
    %         if behavDataForRecordingDay.TrainBoo==1
        
                mouseId = behavDataForRecordingDay.mouse;
                day = behavDataForRecordingDay.day;
                              
                % No need to run in every cycle of for loop - just run it anytime day index changed
    %             [arrBehavTimesSelected, recordingDayCellAllLicksSelected] = findBehavioralTimes(paramMouseId, paramDay, behavDataForRecordingDays);
                if ~isempty(arrBehavTimesSelected) 
             
                    csTimesAlignedSelected = chunkAlignSpikeTimes(unitCS.timestamps, arrBehavTimesSelected);
                    recordingDayCellAllLicksSelectedAligned = chunkAlignBehavTimes(recordingDayCellAllLicksSelected, arrBehavTimesSelected);                
                    lickOnsetsSelectedAligned = chunkAlignBehavTimes(lickOnsetsSelected, arrBehavTimesSelected);
                    cueTimesSelectedAligned = chunkAlignBehavTimes(cueTimesSelected, arrBehavTimesSelected);
                    
                    % Find the reward responsive CS
                    flagResponsive = isResponsive(unitCS.timestamps, behavDataForRecordingDay.TrialStruct);
                    
                    if flagResponsive == -1
                        if FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS == FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO
                            nUnitSuppressed = nUnitSuppressed + 1;
                            logger.info('checkCSSSResponses', ['RARE but Suppressed unit=' num2str(unitCS.unitID) ' day ' num2str(day) ' mouse ' num2str(mouseId)]);                        
                        end
                    elseif  flagResponsive == 1
                        nUnitActivated = nUnitActivated + 1;
%                         logger.info('checkCSSSResponses', ['Responsive unit=' num2str(unitCS.unitID) ' day ' num2str(day) ' mouse ' num2str(mouseId)]);                                        
                        [unitSS, trialsCueResponsive] = findPair(unitSSs, recordingDayInd, unitCS, arrBehavTimesSelected);
        
                        if ~isempty(unitSS)
                            % Save CS only if it has a paired SS
                            cellCSTimesResponsive{length(cellCSTimesResponsive)+1} = csTimesAlignedSelected;

                            ssTimesPairedWCueRespCS = chunkAlignSpikeTimes(unitSS.timestamps, arrBehavTimesSelected(logical(trialsCueResponsive)));
                            ssTimesPairedWCueNonRespCS = chunkAlignSpikeTimes(unitSS.timestamps, arrBehavTimesSelected(logical(~trialsCueResponsive)));
                            cellSSTimesPairedWJuiceRespCueResponsiveCS{length(cellSSTimesPairedWJuiceRespCueResponsiveCS)+1} = ssTimesPairedWCueRespCS;
                            cellSSTimesPairedWJuiceRespCueNonResponsiveCS{length(cellSSTimesPairedWJuiceRespCueNonResponsiveCS)+1} = ssTimesPairedWCueNonRespCS;
    
                            cellSSAllLicksJuiceRespCueResponsiveCS{length(cellSSAllLicksJuiceRespCueResponsiveCS)+1} = recordingDayCellAllLicksSelectedAligned(logical(trialsCueResponsive));
                            cellSSAllLicksJuiceRespCueNonResponsiveCS{length(cellSSAllLicksJuiceRespCueNonResponsiveCS)+1} = recordingDayCellAllLicksSelectedAligned(logical(~trialsCueResponsive));
    
                            cellSSLickOnsetsJuiceRespCueResponsiveCS{length(cellSSLickOnsetsJuiceRespCueResponsiveCS)+1} = lickOnsetsSelectedAligned(logical(trialsCueResponsive));
                            cellSSLickOnsetsJuiceRespCueNonResponsiveCS{length(cellSSLickOnsetsJuiceRespCueNonResponsiveCS)+1} = lickOnsetsSelectedAligned(logical(~trialsCueResponsive));
    
                            cellSSCuesJuiceRespCueResponsiveCS{length(cellSSCuesJuiceRespCueResponsiveCS)+1} = cueTimesSelectedAligned(logical(trialsCueResponsive));
                            cellSSCuesJuiceRespCueNonResponsiveCS{length(cellSSCuesJuiceRespCueNonResponsiveCS)+1} = cueTimesSelectedAligned(logical(~trialsCueResponsive));
    
                            cellSSpairedWithCSResponsive{length(cellSSpairedWithCSResponsive)+1} = {unitSS.unitID, unitCS.unitID};
                        end                              
                    elseif  flagResponsive == 0
                        nUnitNonResponsive = nUnitNonResponsive + 1;
%                         logger.info('checkCSSSResponses', ['Non responsive unit=' num2str(unitCS.unitID) ' day ' num2str(day) ' mouse ' num2str(mouseId)]);                        
                        [unitSS, trialsCueResponsive] = findPair(unitSSs, recordingDayInd, unitCS, arrBehavTimesSelected);
    
                        if ~isempty(unitSS)
                            % Save CS only if it has a paired SS
                            cellCSTimesNonResponsive{length(cellCSTimesNonResponsive)+1} = csTimesAlignedSelected;

                            ssTimesPairedWCueRespCS = chunkAlignSpikeTimes(unitSS.timestamps, arrBehavTimesSelected(logical(trialsCueResponsive)));
                            ssTimesPairedWCueNonRespCS = chunkAlignSpikeTimes(unitSS.timestamps, arrBehavTimesSelected(logical(~trialsCueResponsive)));
    
                            cellSSTimesPairedWJuiceNonRespCueResponsiveCS{length(cellSSTimesPairedWJuiceNonRespCueResponsiveCS)+1} = ssTimesPairedWCueRespCS;
                            cellSSTimesPairedWJuiceNonRespCueNonResponsiveCS{length(cellSSTimesPairedWJuiceNonRespCueNonResponsiveCS)+1} = ssTimesPairedWCueNonRespCS;
    
                            cellSSAllLicksJuiceNonRespCueResponsiveCS{length(cellSSAllLicksJuiceNonRespCueResponsiveCS)+1} = recordingDayCellAllLicksSelectedAligned(logical(trialsCueResponsive));
                            cellSSAllLicksJuiceNonRespCueNonResponsiveCS{length(cellSSAllLicksJuiceNonRespCueNonResponsiveCS)+1} = recordingDayCellAllLicksSelectedAligned(logical(~trialsCueResponsive));
    
                            cellSSLickOnsetsJuiceNonRespCueResponsiveCS{length(cellSSLickOnsetsJuiceNonRespCueResponsiveCS)+1} = lickOnsetsSelectedAligned(logical(trialsCueResponsive));
                            cellSSLickOnsetsJuiceNonRespCueNonResponsiveCS{length(cellSSLickOnsetsJuiceNonRespCueNonResponsiveCS)+1} = lickOnsetsSelectedAligned(logical(~trialsCueResponsive));
    
                            cellSSCuesJuiceNonRespCueResponsiveCS{length(cellSSCuesJuiceNonRespCueResponsiveCS)+1} = cueTimesSelectedAligned(logical(trialsCueResponsive));
                            cellSSCuesJuiceNonRespCueNonResponsiveCS{length(cellSSCuesJuiceNonRespCueNonResponsiveCS)+1} = cueTimesSelectedAligned(logical(~trialsCueResponsive));
    
                            cellSSpairedWithCSNonResponsive{length(cellSSpairedWithCSNonResponsive)+1} = {unitSS.unitID, unitCS.unitID};
                        end                
                    end
                end
                
                % If mouse or day changed, do collective plottings for all CSs gathered        
                if (indLoop+1)<=length(indsCSs)
                    unitCSNext = unitCSs(indsCSs(indLoop+1));
                    recordingDayIndNext = unitCSNext.RecorNum;
                    behavDataForRecordingDayNext = behavDataForRecordingDays(recordingDayIndNext);
                    dayNext = behavDataForRecordingDayNext.day;                    
                end

                % If day changed, do collective plottings for all CSs and SSs gathered
                if dayNext ~= day ||  (indLoop+1)==length(indsCSs)   
                        % Get the next day's behavioral data
                        if (indLoop+1)<=length(indsCSs)
                            [arrBehavTimesSelected, recordingDayCellAllLicksSelected, lickOnsetsSelected, cueTimesSelected] = findBehavioralTimes(paramMouseId, paramDay, behavDataForRecordingDayNext);
                        end

                        nTotalUnits = nUnitActivated+nUnitSuppressed+nUnitNonResponsive;
                        percentageActivated = 100*nUnitActivated/nTotalUnits;
                        logger.info('checkCSSSResponses', ['Activated units=' num2str(percentageActivated,'%.2f') ' % '...
                            'Suppressed units = ' num2str(100*nUnitSuppressed/nTotalUnits,'%.2f') ' % Non-responsive units = ' num2str(100*nUnitNonResponsive/nTotalUnits,'%.2f') ' % ' ...
                            'day ' num2str(day) ' mouse ' num2str(mouseId)]);
                        
                        % Plot RESPONSIVE CSs and their paired SSs PSTHs
                        if ~isempty(cellCSTimesResponsive)
                            sPercentageActivated = '';
                            if ~isempty(percentageActivated)
                                sPercentageActivated = num2str(percentageActivated,'%.2f');
                            end
                        
%                             trialCounts = unique(cellfun(@length,cellCSTimesResponsive));
%                             sTitle = ['(Resp)' NEURON_TYPE_CS ' (n=' num2str(length(cellCSTimesResponsive)) ' t=' num2str(sum(trialCounts)) ') day ' num2str(day) ' ' num2str(mouseId)];
%                             sFile = [pathToCSPsthFolder 'mouse' num2str(mouseId) '_day' num2str(day) '_' NEURON_TYPE_CS '_Resp_' sAlignedTo '.tif'];
%                             plotComparisonPSTHs(cellCSTimesResponsive, NEURON_TYPE_CS, sTitle, sFile, [], [], 0, COLORS(11, :), [], []);
                        end

                        % SS times paired with a CS which is responsive to juice and responsive to cue
                        if ~isempty(cellSSTimesPairedWJuiceRespCueResponsiveCS)
%                             sTitle = ['(JResp_CResp)' NEURON_TYPE_SS ' (n=' num2str(length(cellSSTimesPairedWJuiceRespCueResponsiveCS)) ') rate aligned to ' sAlignedTo ' on day ' num2str(day) ' mouse ' num2str(mouseId)];
%                             sFile = [pathToSSPsthFolder 'mouse' num2str(mouseId) '_day' num2str(day) '_' NEURON_TYPE_SS '_JRespCResp_' sAlignedTo '.tif'];
    %                         plotComparisonPSTHs(cellSSTimesPairedWJuiceRespCueResponsiveCS, NEURON_TYPE_SS, sTitle, sFile, [], cellSSpairedWithCSResponsive, 0, COLORS(8,:), [], []);
                        end

                        % SS times paired with a CS which is responsive to juice but non-responsive to cue
                        if ~isempty(cellSSTimesPairedWJuiceRespCueNonResponsiveCS)
%                             sTitle = ['(JResp_CNonResp)' NEURON_TYPE_SS ' (n=' num2str(length(cellSSTimesPairedWJuiceRespCueNonResponsiveCS)) ') rate aligned to ' sAlignedTo ' on day ' num2str(day) ' mouse ' num2str(mouseId)];
%                             sFile = [pathToSSPsthFolder 'mouse' num2str(mouseId) '_day' num2str(day) '_' NEURON_TYPE_SS '_JRespCNonResp_' sAlignedTo '.tif'];
    %                         plotComparisonPSTHs(cellSSTimesPairedWJuiceRespCueNonResponsiveCS, NEURON_TYPE_SS, sTitle, sFile, [], cellSSpairedWithCSResponsive, 0, COLORS(8,:), [], []);
                        end                        
                        
        
                        % Plot NON-RESPONSIVE CSs and their paired SSs PSTHs
                        if ~isempty(cellCSTimesNonResponsive)
%                             trialCounts = unique(cellfun(@length,cellCSTimesNonResponsive));
%                             sTitle = ['(NonResp)' NEURON_TYPE_CS ' (n=' num2str(length(cellCSTimesNonResponsive)) ' t=' num2str(sum(trialCounts)) ') day ' num2str(day) ' ' num2str(mouseId)];
%                             sFile = [pathToCSPsthFolder 'mouse' num2str(mouseId) '_day' num2str(day) '_' NEURON_TYPE_CS '_NonResp_' sAlignedTo '.tif'];                    
%                             plotComparisonPSTHs(cellCSTimesNonResponsive, NEURON_TYPE_CS, sTitle, sFile, [], [], 0, COLORS(11, :), [], []);
                        end      
                        % SS times paired with a CS which is non-responsive to juice but responsive to cue
                        if ~isempty(cellSSTimesPairedWJuiceNonRespCueResponsiveCS)
%                             sTitle = ['(JNonResp_CResp)' NEURON_TYPE_SS ' (n=' num2str(length(cellSSTimesPairedWJuiceNonRespCueResponsiveCS)) ') rate aligned to ' sAlignedTo ' on day ' num2str(day) ' mouse ' num2str(mouseId)];
%                             sFile = [pathToSSPsthFolder 'mouse' num2str(mouseId) '_day' num2str(day) '_' NEURON_TYPE_SS '_JNonRespCResp_' sAlignedTo '.tif'];
%                             plotComparisonPSTHs(cellSSTimesPairedWJuiceNonRespCueResponsiveCS, NEURON_TYPE_SS, sTitle, sFile, [], cellSSpairedWithCSResponsive, 0, COLORS(8,:), [], []);
                        end

                        % SS times paired with a CS which is non-responsive to juice and non-responsive to cue
                        if ~isempty(cellSSTimesPairedWJuiceNonRespCueNonResponsiveCS)
%                             sTitle = ['(JNonResp_CNonResp)' NEURON_TYPE_SS ' (n=' num2str(length(cellSSTimesPairedWJuiceNonRespCueNonResponsiveCS)) ') rate aligned to ' sAlignedTo ' on day ' num2str(day) ' mouse ' num2str(mouseId)];
%                             sFile = [pathToSSPsthFolder 'mouse' num2str(mouseId) '_day' num2str(day) '_' NEURON_TYPE_SS '_JNonRespCNonResp_' sAlignedTo '.tif'];
%                             plotComparisonPSTHs(cellSSTimesPairedWJuiceNonRespCueNonResponsiveCS, NEURON_TYPE_SS, sTitle, sFile, [], cellSSpairedWithCSResponsive, 0, COLORS(8,:), [], []);
                        end                        
                        
                        dayInd = find(ismember(paramDay,day)); % find which day's data processed
                        cellSSTimesPairedWJuiceRespCueResponsiveCSPerDay{dayInd} = cellSSTimesPairedWJuiceRespCueResponsiveCS;
                        cellSSTimesPairedWJuiceRespCueNonResponsiveCSPerDay{dayInd} = cellSSTimesPairedWJuiceRespCueNonResponsiveCS;
                        cellSSTimesPairedWJuiceNonRespCueResponsiveCSPerDay{dayInd} = cellSSTimesPairedWJuiceNonRespCueResponsiveCS;
                        cellSSTimesPairedWJuiceNonRespCueNonResponsiveCSPerDay{dayInd} = cellSSTimesPairedWJuiceNonRespCueNonResponsiveCS;
    
                        cellSSAllLicksJuiceRespCueResponsiveCSPerDay{dayInd} = cellSSAllLicksJuiceRespCueResponsiveCS;
                        cellSSAllLicksJuiceRespCueNonResponsiveCSPerDay{dayInd} = cellSSAllLicksJuiceRespCueNonResponsiveCS;
                        cellSSAllLicksJuiceNonRespCueResponsiveCSPerDay{dayInd} = cellSSAllLicksJuiceNonRespCueResponsiveCS;
                        cellSSAllLicksJuiceNonRespCueNonResponsiveCSPerDay{dayInd} = cellSSAllLicksJuiceNonRespCueNonResponsiveCS;

                        cellSSLickOnsetsJuiceRespCueResponsiveCSPerDay{dayInd} = cellSSLickOnsetsJuiceRespCueResponsiveCS;
                        cellSSLickOnsetsJuiceRespCueNonResponsiveCSPerDay{dayInd} = cellSSLickOnsetsJuiceRespCueNonResponsiveCS;
                        cellSSLickOnsetsJuiceNonRespCueResponsiveCSPerDay{dayInd} = cellSSLickOnsetsJuiceNonRespCueResponsiveCS;
                        cellSSLickOnsetsJuiceNonRespCueNonResponsiveCSPerDay{dayInd} = cellSSLickOnsetsJuiceNonRespCueNonResponsiveCS;
                        
                        cellSSCuesJuiceRespCueResponsiveCSPerDay{dayInd} = cellSSCuesJuiceRespCueResponsiveCS;
                        cellSSCuesJuiceRespCueNonResponsiveCSPerDay{dayInd} = cellSSCuesJuiceRespCueNonResponsiveCS;
                        cellSSCuesJuiceNonRespCueResponsiveCSPerDay{dayInd} = cellSSCuesJuiceNonRespCueResponsiveCS;
                        cellSSCuesJuiceNonRespCueNonResponsiveCSPerDay{dayInd} = cellSSCuesJuiceNonRespCueNonResponsiveCS;

                        cellCSTimesResponsivePerDay{dayInd} = cellCSTimesResponsive;
                        cellCSTimesNonResponsivePerDay{dayInd} = cellCSTimesNonResponsive;
                            
                        cellCSTimesResponsive = {};
                        cellSSTimesPairedWJuiceRespCueResponsiveCS = {};
                        cellSSTimesPairedWJuiceRespCueNonResponsiveCS = {};
                        cellCSTimesNonResponsive = {};
                        cellSSTimesPairedWJuiceNonRespCueResponsiveCS = {};
                        cellSSTimesPairedWJuiceNonRespCueNonResponsiveCS = {};
        
                        cellSSAllLicksJuiceRespCueResponsiveCS = {};
                        cellSSAllLicksJuiceRespCueNonResponsiveCS = {};
                        cellSSAllLicksJuiceNonRespCueResponsiveCS = {};
                        cellSSAllLicksJuiceNonRespCueNonResponsiveCS = {};

                        cellSSLickOnsetsJuiceRespCueResponsiveCS = {};
                        cellSSLickOnsetsJuiceRespCueNonResponsiveCS = {};
                        cellSSLickOnsetsJuiceNonRespCueResponsiveCS = {};
                        cellSSLickOnsetsJuiceNonRespCueNonResponsiveCS = {};

                        cellSSCuesJuiceRespCueResponsiveCS = {};
                        cellSSCuesJuiceRespCueNonResponsiveCS = {};
                        cellSSCuesJuiceNonRespCueResponsiveCS = {};
                        cellSSCuesJuiceNonRespCueNonResponsiveCS = {};
                        
                        cellSSpairedWithCSResponsive = {};
                        cellSSpairedWithCSNonResponsive = {};
                    
                        nUnitActivated = 0;
                        nUnitSuppressed = 0;
                        nUnitNonResponsive = 0;
                end
                
    %         end
    %         end
        end
    end
end