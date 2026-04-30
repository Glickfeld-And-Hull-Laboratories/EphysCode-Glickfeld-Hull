% clearvars -except Rlist CS Slave SumSt
% close all
% globals;

% behavDataForRecordingDays = Rlist;

% structUnitsPerRecordingDays = SumSt;
% cellTypes = {SumSt.CellType};
% cellC4Labels = {SumSt.c4_label};
% indTemp = find(strcmp({SumSt.CellType}, 'CS') & [SumSt.c4_confidence]>2);

% unitCSs = CS;

function [cellMasterTimesResponsivePerDay, cellMasterTimesNonResponsivePerDay, ...
    cellSlaveTimesPairedWJuiceRespCueResponsiveMasterPerDay, cellSlaveTimesPairedWJuiceRespCueNonResponsiveMasterPerDay, ...
    cellSlaveTimesPairedWJuiceNonRespCueResponsiveMasterPerDay, cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMasterPerDay, ...
    cellSlaveAllLicksJuiceRespCueResponsiveMasterPerDay, cellSlaveAllLicksJuiceRespCueNonResponsiveMasterPerDay, ...
    cellSlaveAllLicksJuiceNonRespCueResponsiveMasterPerDay, cellSlaveAllLicksJuiceNonRespCueNonResponsiveMasterPerDay] = ...
    checkMasterSlaveResponses(behavDataForRecordingDays, unitMasters, unitSlaves, paramMouseId, paramDay, modeAlignment)
    globals;
        
    recordingDayTrialsSelected = [];
    
    % arrNaiveRecordingDays = behavDataForRecordingDays([behavDataForRecordingDays.day] <= 3); % get only first three (Naive) days
    indsRecordingDays = find([behavDataForRecordingDays.mouse]==paramMouseId & ismember([behavDataForRecordingDays.day],paramDay));
    indsMasters = find(ismember([unitMasters.RecorNum], indsRecordingDays));
    
    currentMouseId = 0;
    currentDay = 0;

    nUnitActivated = 0;
    nUnitSuppressed = 0;
    nUnitNonResponsive = 0;

    cellMasterTimesResponsivePerDay = cell(1,length(paramDay));
    cellMasterTimesNonResponsivePerDay = cell(1,length(paramDay));
    
    cellSlaveTimesPairedWJuiceRespCueResponsiveMasterPerDay = cell(1,length(paramDay));
    cellSlaveTimesPairedWJuiceRespCueNonResponsiveMasterPerDay = cell(1,length(paramDay));
    cellSlaveTimesPairedWJuiceNonRespCueResponsiveMasterPerDay = cell(1,length(paramDay));
    cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMasterPerDay = cell(1,length(paramDay));

    cellSlaveAllLicksJuiceRespCueResponsiveMasterPerDay = cell(1,length(paramDay));
    cellSlaveAllLicksJuiceRespCueNonResponsiveMasterPerDay = cell(1,length(paramDay));
    cellSlaveAllLicksJuiceNonRespCueResponsiveMasterPerDay = cell(1,length(paramDay));
    cellSlaveAllLicksJuiceNonRespCueNonResponsiveMasterPerDay = cell(1,length(paramDay));

    if modeAlignment == MODE_ALIGNMENT_TO_CLICK
        sAlignedTo = 'click';
        if FROM_CS_TO_SS
            pathToMasterPsthFolder = pathToCSToClickPsthFolder;
            pathToSlavePsthFolder = pathToSSToClickPsthFolder;    
            sNeuronTypeMaster = NEURON_TYPE_CS;
            sNeuronTypeSlave = NEURON_TYPE_SS;
        else
            pathToMasterPsthFolder = pathToSSToClickPsthFolder;
            pathToSlavePsthFolder = pathToCSToClickPsthFolder;
            sNeuronTypeMaster = NEURON_TYPE_SS;
            sNeuronTypeSlave = NEURON_TYPE_CS;
        end
    elseif modeAlignment == MODE_ALIGNMENT_TO_LICK
        sAlignedTo = 'lick';
        if FROM_CS_TO_SS
            pathToMasterPsthFolder = pathToCSToLickPsthFolder;
            pathToSlavePsthFolder = pathToSSToLickPsthFolder;
            sNeuronTypeMaster = NEURON_TYPE_CS;
            sNeuronTypeSlave = NEURON_TYPE_SS;
        else
            pathToMasterPsthFolder = pathToSSToLickPsthFolder;
            pathToSlavePsthFolder = pathToCSToLickPsthFolder;
            sNeuronTypeMaster = NEURON_TYPE_SS;
            sNeuronTypeSlave = NEURON_TYPE_CS;
        end
    elseif modeAlignment == MODE_ALIGNMENT_TO_TONE
        sAlignedTo = 'tone';
        if FROM_CS_TO_SS
            pathToMasterPsthFolder = pathToCSToTonePsthFolder;
            pathToSlavePsthFolder = pathToSSToTonePsthFolder;
            sNeuronTypeMaster = NEURON_TYPE_CS;
            sNeuronTypeSlave = NEURON_TYPE_SS;
        else
            pathToMasterPsthFolder = pathToSlaveToTonePsthFolder;
            pathToSlavePsthFolder = pathToCSToTonePsthFolder;
            sNeuronTypeMaster = NEURON_TYPE_SS;
            sNeuronTypeSlave = NEURON_TYPE_CS;
        end
    end

    for indLoop=1:length(indsMasters)
        unitMaster = unitMasters(indsMasters(indLoop));
        recordingDayInd = unitMaster.RecorNum;
        behavDataForRecordingDay = behavDataForRecordingDays(recordingDayInd);
%         if behavDataForRecordingDay.TrainBoo==1
            recordingDayTrials = behavDataForRecordingDay.TrialStruct;
            recordingDayLickOnsets = behavDataForRecordingDay.LickOnsets;
            recordingDayCellAllLicks = behavDataForRecordingDay.cellAllLicks;
    
            mouseId = behavDataForRecordingDay.mouse;
            day = behavDataForRecordingDay.day;
                    
            % If mouse or day changed, do collective plottings for all Masters and Slaves gathered
            if currentMouseId ~= mouseId || currentDay ~= day
                if currentMouseId~=0 && ~isempty(cellMasterTimesResponsive)
                    sMouseId = '';
                    if ~isempty(currentMouseId) && currentMouseId~=0
                        sMouseId = ['mouse' num2str(currentMouseId)];
                    end
    
                    nTotalUnits = nUnitActivated+nUnitSuppressed+nUnitNonResponsive;
                    percentageActivated = 100*nUnitActivated/nTotalUnits;
                    logger.info('checkMasterSlaveResponses', ['Activated units=' num2str(percentageActivated,'%.2f') ' % '...
                        'Suppressed units = ' num2str(100*nUnitSuppressed/nTotalUnits,'%.2f') ' % Non-responsive units = ' num2str(100*nUnitNonResponsive/nTotalUnits,'%.2f') ' % ' ...
                        'day ' num2str(currentDay) ' mouse ' num2str(currentMouseId)]);
                    
                    % Plot RESPONSIVE Masters and their paired Slaves PSTHs
                    if ~isempty(cellMasterTimesResponsive)
                        sPercentageActivated = '';
                        if ~isempty(percentageActivated)
                            sPercentageActivated = num2str(percentageActivated,'%.2f');
                        end
                        
%                         sTitle = ['(Resp)' sNeuronTypeMaster '(n=' num2str(length(cellMasterTimesResponsive)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId ' (' sPercentageActivated ' %  responsive for the last ' num2str(TRIALS_TO_COMPARE) ' trials)'];
%                         sFile = [pathToMasterPsthFolder sMouseId '_day' num2str(currentDay) '_firstVSlast' num2str(TRIALS_TO_COMPARE) '_' sNeuronTypeMaster '_Resp_' sAlignedTo '.tif'];
    %                     plotComparisonPSTHs(cellMasterTimesResponsive, sNeuronTypeMaster, sTitle, sFile, [], [], 0, COLORS(11, :));
        
                        % Slave times paired with a Master which is responsive to juice and responsive to cue
                        if ~isempty(cellSlaveTimesPairedWJuiceRespCueResponsiveMaster)
%                             sTitle = ['(JResp_CResp)' sNeuronTypeSlave ' (n=' num2str(length(cellSlaveTimesPairedWJuiceRespCueResponsiveMaster)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId];
%                             sFile = [pathToSlavePsthFolder sMouseId '_day' num2str(currentDay) '_' sNeuronTypeSlave '_JRespCResp_' sAlignedTo '.tif'];
    %                         plotComparisonPSTHs(cellSlaveTimesPairedWJuiceRespCueResponsiveMaster, sNeuronTypeSlave, sTitle, sFile, [], cellSlavepairedWithMasterResponsive, 0, COLORS(8,:));
                        end

                        % Slave times paired with a Master which is responsive to juice but non-responsive to cue
                        if ~isempty(cellSlaveTimesPairedWJuiceRespCueNonResponsiveMaster)
%                             sTitle = ['(JResp_CNonResp)' sNeuronTypeSlave ' (n=' num2str(length(cellSlaveTimesPairedWJuiceRespCueNonResponsiveMaster)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId];
%                             sFile = [pathToSlavePsthFolder sMouseId '_day' num2str(currentDay) '_' sNeuronTypeSlave '_JRespCNonResp_' sAlignedTo '.tif'];
    %                         plotComparisonPSTHs(cellSlaveTimesPairedWJuiceRespCueNonResponsiveMaster, sNeuronTypeSlave, sTitle, sFile, [], cellSlavepairedWithMasterResponsive, 0, COLORS(8,:));
                        end                        
                    end
    
                    % Plot NON-RESPONSIVE Masters and their paired Slaves PSTHs
                    if ~isempty(cellMasterTimesNonResponsive)
%                         sTitle = ['(NonResp)' sNeuronTypeMaster ' (n=' num2str(length(cellMasterTimesNonResponsive)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId ' (non-responsive for the last ' num2str(TRIALS_TO_COMPARE) ' trials)'];
%                         sFile = [pathToMasterPsthFolder sMouseId '_day' num2str(currentDay) '_firstVSlast' num2str(TRIALS_TO_COMPARE) '_' sNeuronTypeMaster '_NonResp_' sAlignedTo '.tif'];                    
    %                     plotComparisonPSTHs(cellMasterTimesNonResponsive, sNeuronTypeMaster, sTitle, sFile, [], [], 0, COLORS(11, :));
                            
                        % Slave times paired with a Master which is non-responsive to juice but responsive to cue
                        if ~isempty(cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster)
%                             sTitle = ['(JNonResp_CResp)' sNeuronTypeSlave ' (n=' num2str(length(cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId];
%                             sFile = [pathToSlavePsthFolder sMouseId '_day' num2str(currentDay) '_' sNeuronTypeSlave '_JNonRespCResp_' sAlignedTo '.tif'];
%                             plotComparisonPSTHs(cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster, sNeuronTypeSlave, sTitle, sFile, [], cellSlavepairedWithMasterResponsive, 0, COLORS(8,:));
                        end

                        % Slave times paired with a Master which is non-responsive to juice and non-responsive to cue
                        if ~isempty(cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster)
%                             sTitle = ['(JNonResp_CNonResp)' sNeuronTypeSlave ' (n=' num2str(length(cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId];
%                             sFile = [pathToSlavePsthFolder sMouseId '_day' num2str(currentDay) '_' sNeuronTypeSlave '_JNonRespCNonResp_' sAlignedTo '.tif'];
%                             plotComparisonPSTHs(cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster, sNeuronTypeSlave, sTitle, sFile, [], cellSlavepairedWithMasterResponsive, 0, COLORS(8,:));
                        end
                    end
                    
                    dayInd = find(ismember(paramDay,currentDay)); % find which day's data processed
                    cellSlaveTimesPairedWJuiceRespCueResponsiveMasterPerDay{dayInd} = cellSlaveTimesPairedWJuiceRespCueResponsiveMaster;
                    cellSlaveTimesPairedWJuiceRespCueNonResponsiveMasterPerDay{dayInd} = cellSlaveTimesPairedWJuiceRespCueNonResponsiveMaster;
                    cellSlaveTimesPairedWJuiceNonRespCueResponsiveMasterPerDay{dayInd} = cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster;
                    cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMasterPerDay{dayInd} = cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster;

                    cellSlaveAllLicksJuiceRespCueResponsiveMasterPerDay{dayInd} = cellSlaveAllLicksJuiceRespCueResponsiveMaster;
                    cellSlaveAllLicksJuiceRespCueNonResponsiveMasterPerDay{dayInd} = cellSlaveAllLicksJuiceRespCueNonResponsiveMaster;
                    cellSlaveAllLicksJuiceNonRespCueResponsiveMasterPerDay{dayInd} = cellSlaveAllLicksJuiceNonRespCueResponsiveMaster;
                    cellSlaveAllLicksJuiceNonRespCueNonResponsiveMasterPerDay{dayInd} = cellSlaveAllLicksJuiceNonRespCueNonResponsiveMaster;
                    
                    cellMasterTimesResponsivePerDay{dayInd} = cellMasterTimesResponsive;
                    cellMasterTimesNonResponsivePerDay{dayInd} = cellMasterTimesNonResponsive;
                end
    
                cellMasterTimesResponsive = {};
                cellSlaveTimesPairedWJuiceRespCueResponsiveMaster = {};
                cellSlaveTimesPairedWJuiceRespCueNonResponsiveMaster = {};
                cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster = {};
                cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster = {};

                cellSlaveAllLicksJuiceRespCueResponsiveMaster = {};
                cellSlaveAllLicksJuiceRespCueNonResponsiveMaster = {};
                cellSlaveAllLicksJuiceNonRespCueResponsiveMaster = {};
                cellSlaveAllLicksJuiceNonRespCueNonResponsiveMaster = {};
                
                cellSlavepairedWithMasterResponsive = {};
                cellSlavepairedWithMasterNonResponsive = {};
    
                cellMasterTimesNonResponsive = {};
                cellSlaveTimesNonResponsive = {};
    
                cellFirstSpikeLatency = {};
                cellSecondSpikeLatency = {};
                currentMouseId=mouseId;
                currentDay = day;
    
                nUnitActivated = 0;
                nUnitSuppressed = 0;
                nUnitNonResponsive = 0;
            end
    
            % Patch to correct NaN values in TrialType
            trialTypes = {recordingDayTrials.TrialType};
            outcomeTypes = {recordingDayTrials.Outcome};
            nanIdsCell = cellfun(@ (x) any(isnan(x)),trialTypes, UniformOutput=true);
            nanIdsOutcomeCell = cellfun(@ (x) any(isnan(x)),outcomeTypes, UniformOutput=true);
            recordingDayTrials = recordingDayTrials(~nanIdsCell & ~nanIdsOutcomeCell); % Ignore NaN lick onset entries

            lickOnsetTrialTypes = {recordingDayLickOnsets.TrialType};
            lickOnsetOutcomeTypes = {recordingDayLickOnsets.Outcome};
            nanIdsCell = cellfun(@ (x) any(isnan(x)),lickOnsetTrialTypes, UniformOutput=true);
            nanIdsOutcomeCell = cellfun(@ (x) any(isnan(x)),lickOnsetOutcomeTypes, UniformOutput=true);
            %[lickOnsetTrialTypes{nanIdsCell}] = deal('');
%             lickOnsetTrialTypes = lickOnsetTrialTypes(~nanIdsCell & ~nanIdsOutcomeCell); % Ignore NaN lick onset entries
%             lickOnsetOutcomeTypes = lickOnsetOutcomeTypes(~nanIdsCell & ~nanIdsOutcomeCell); % Ignore NaN lick onset entries
            recordingDayLickOnsets = recordingDayLickOnsets(~nanIdsCell & ~nanIdsOutcomeCell); % Ignore NaN lick onset entries
            recordingDayCellAllLicks = recordingDayCellAllLicks(~nanIdsCell & ~nanIdsOutcomeCell);
%             recordingDayAllLicks
                            
            [arrBehavTimesSelected, recordingDayCellAllLicksSelected] = findBehavioralTimes(paramMouseId, paramDay, modeAlignment, recordingDayTrials, recordingDayLickOnsets, recordingDayCellAllLicks); %, lickOnsetTrialTypes, lickOnsetOutcomeTypes);
            if ~isempty(arrBehavTimesSelected) 
         
                csTimesAlignedSelected = chunkAlignSpikeTimes(unitMaster.timestamps, arrBehavTimesSelected);
                recordingDayCellAllLicksSelectedAligned = chunkAlignBehavTimes(recordingDayCellAllLicksSelected, arrBehavTimesSelected);                
                % Find the reward responsive Master
                flagResponsive = isResponsive(unitMaster.timestamps, recordingDayTrials);
                
                if flagResponsive == -1
                    if FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESlave == FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESlave_MONO
                        nUnitSuppressed = nUnitSuppressed + 1;
                        logger.info('checkMasterSlaveResponses', ['RARE but Suppressed unit=' num2str(unitMaster.unitID) ' day ' num2str(behavDataForRecordingDay.day) ' mouse ' num2str(behavDataForRecordingDay.mouse)]);
                    elseif FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESlave == FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESlave_DUAL
                        % for dual comparison, this means TRIAL_TYPE_2 had higher activity so put them into Non-responsive category cos there will be no
                        % non-responsives while comparing two trial type responses
                        nUnitNonResponsive = nUnitNonResponsive + 1;
                        logger.info('checkMasterSlaveResponses', ['Less responsive unit=' num2str(unitMaster.unitID) ' day ' num2str(behavDataForRecordingDay.day) ' mouse ' num2str(behavDataForRecordingDay.mouse)]);
                        cellMasterTimesNonResponsive{length(cellMasterTimesNonResponsive)+1} = csTimesAlignedSelected; 
                        [unitSlave, trialsCueResponsive] = findPair(unitSlaves, recordingDayInd, unitMaster, arrBehavTimesSelected, modeAlignment);

                        if ~isempty(unitSlave)
                            ssTimesPairedWCueRespMaster = chunkAlignSpikeTimes(unitSlave.timestamps, arrBehavTimesSelected(logical(trialsCueResponsive)));
                            ssTimesPairedWCueNonRespMaster = chunkAlignSpikeTimes(unitSlave.timestamps, arrBehavTimesSelected(logical(~trialsCueResponsive)));
                            cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster{length(cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster)+1} = ssTimesPairedWCueRespMaster;
                            cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster{length(cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster)+1} = ssTimesPairedWCueNonRespMaster;

                            cellSlaveAllLicksJuiceNonRespCueResponsiveMaster{length(cellSlaveAllLicksJuiceNonRespCueResponsiveMaster)+1} = recordingDayCellAllLicksSelectedAligned(logical(trialsCueResponsive));
                            cellSlaveAllLicksJuiceNonRespCueNonResponsiveMaster{length(cellSlaveAllLicksJuiceNonRespCueNonResponsiveMaster)+1} = recordingDayCellAllLicksSelectedAligned(logical(~trialsCueResponsive));

                            cellSlavepairedWithMasterNonResponsive{length(cellSlavepairedWithMasterNonResponsive)+1} = {unitSlave.unitID, unitMaster.unitID};
                        end
                    end
                elseif  flagResponsive == 1
                    nUnitActivated = nUnitActivated + 1;
                    logger.info('checkMasterSlaveResponses', ['Responsive unit=' num2str(unitMaster.unitID) ' day ' num2str(behavDataForRecordingDay.day) ' mouse ' num2str(behavDataForRecordingDay.mouse)]);
                    cellMasterTimesResponsive{length(cellMasterTimesResponsive)+1} = csTimesAlignedSelected;                
                    [unitSlave, trialsCueResponsive] = findPair(unitSlaves, recordingDayInd, unitMaster, arrBehavTimesSelected, modeAlignment);
    
                    if ~isempty(unitSlave)
                        ssTimesPairedWCueRespMaster = chunkAlignSpikeTimes(unitSlave.timestamps, arrBehavTimesSelected(logical(trialsCueResponsive)));
                        ssTimesPairedWCueNonRespMaster = chunkAlignSpikeTimes(unitSlave.timestamps, arrBehavTimesSelected(logical(~trialsCueResponsive)));
                        cellSlaveTimesPairedWJuiceRespCueResponsiveMaster{length(cellSlaveTimesPairedWJuiceRespCueResponsiveMaster)+1} = ssTimesPairedWCueRespMaster;
                        cellSlaveTimesPairedWJuiceRespCueNonResponsiveMaster{length(cellSlaveTimesPairedWJuiceRespCueNonResponsiveMaster)+1} = ssTimesPairedWCueNonRespMaster;

                        cellSlaveAllLicksJuiceRespCueResponsiveMaster{length(cellSlaveAllLicksJuiceRespCueResponsiveMaster)+1} = recordingDayCellAllLicksSelectedAligned(logical(trialsCueResponsive));
                        cellSlaveAllLicksJuiceRespCueNonResponsiveMaster{length(cellSlaveAllLicksJuiceRespCueNonResponsiveMaster)+1} = recordingDayCellAllLicksSelectedAligned(logical(~trialsCueResponsive));

                        cellSlavepairedWithMasterResponsive{length(cellSlavepairedWithMasterResponsive)+1} = {unitSlave.unitID, unitMaster.unitID};
                    end                              
                elseif  flagResponsive == 0 && FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESlave == FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESlave_MONO
                    nUnitNonResponsive = nUnitNonResponsive + 1;
                    logger.info('checkMasterSlaveResponses', ['Non responsive unit=' num2str(unitMaster.unitID) ' day ' num2str(behavDataForRecordingDay.day) ' mouse ' num2str(behavDataForRecordingDay.mouse)]);
                    cellMasterTimesNonResponsive{length(cellMasterTimesNonResponsive)+1} = csTimesAlignedSelected;
                    [unitSlave, trialsCueResponsive] = findPair(unitSlaves, recordingDayInd, unitMaster, arrBehavTimesSelected, modeAlignment);

                    if ~isempty(unitSlave)
                        ssTimesPairedWCueRespMaster = chunkAlignSpikeTimes(unitSlave.timestamps, arrBehavTimesSelected(logical(trialsCueResponsive)));
                        ssTimesPairedWCueNonRespMaster = chunkAlignSpikeTimes(unitSlave.timestamps, arrBehavTimesSelected(logical(~trialsCueResponsive)));

                        cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster{length(cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster)+1} = ssTimesPairedWCueRespMaster;
                        cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster{length(cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster)+1} = ssTimesPairedWCueNonRespMaster;

                        cellSlaveAllLicksJuiceNonRespCueResponsiveMaster{length(cellSlaveAllLicksJuiceNonRespCueResponsiveMaster)+1} = recordingDayCellAllLicksSelectedAligned(logical(trialsCueResponsive));
                        cellSlaveAllLicksJuiceNonRespCueNonResponsiveMaster{length(cellSlaveAllLicksJuiceNonRespCueNonResponsiveMaster)+1} = recordingDayCellAllLicksSelectedAligned(logical(~trialsCueResponsive));

                        cellSlavepairedWithMasterNonResponsive{length(cellSlavepairedWithMasterNonResponsive)+1} = {unitSlave.unitID, unitMaster.unitID};
                    end                
                end
            end
%         end
    end
    
    % To plot the last batch
    if exist('cellMasterTimesResponsive','var') && ~isempty(cellMasterTimesResponsive)
        nTotalUnits = nUnitActivated+nUnitSuppressed+nUnitNonResponsive;
        percentageActivated = 100*nUnitActivated/nTotalUnits;
        logger.info('checkMasterSlaveResponses', ['Activated units=' num2str(percentageActivated,'%.2f') ' % '...
            'Suppressed units = ' num2str(100*nUnitSuppressed/nTotalUnits,'%.2f') ' % Non-responsive units = ' num2str(100*nUnitNonResponsive/nTotalUnits,'%.2f') ' % ' ...
            'day ' num2str(currentDay) ' mouse ' num2str(currentMouseId)]);                
        
        % Plot RESPONSIVE Masters and their paired Slaves PSTHs
        if ~isempty(cellMasterTimesResponsive)
            sMouseId = '';
            if ~isempty(currentMouseId) && currentMouseId~=0
                sMouseId = ['mouse' num2str(currentMouseId)];
            end

            sPercentageActivated = '';
            if ~isempty(percentageActivated)
                sPercentageActivated = num2str(percentageActivated,'%.2f');
            end
            
%             sTitle = ['(Resp)' sNeuronTypeMaster ' (n=' num2str(length(cellMasterTimesResponsive)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId ' (' sPercentageActivated ' %  responsive for the last ' num2str(TRIALS_TO_COMPARE) ' trials)'];
%             sFile = [pathToMasterPsthFolder sMouseId '_day' num2str(currentDay) '_firstVSlast' num2str(TRIALS_TO_COMPARE) '_' sNeuronTypeMaster '_Resp_' sAlignedTo '.tif'];
%             plotComparisonPSTHs(cellMasterTimesResponsive, sNeuronTypeMaster, sTitle, sFile, [], [], 0, COLORS(11, :));

            % Slave times paired with a Master which is responsive to juice and responsive to cue
            if ~isempty(cellSlaveTimesPairedWJuiceRespCueResponsiveMaster)
%                 sTitle = ['(JResp_CResp)' sNeuronTypeSlave ' (n=' num2str(length(cellSlaveTimesPairedWJuiceRespCueResponsiveMaster)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId];
%                 sFile = [pathToSlavePsthFolder sMouseId '_day' num2str(currentDay) '_' sNeuronTypeSlave '_JRespCResp_' sAlignedTo '.tif'];
%                         plotComparisonPSTHs(cellSlaveTimesPairedWJuiceRespCueResponsiveMaster, sNeuronTypeSlave, sTitle, sFile, [], cellSlavepairedWithMasterResponsive, 0, COLORS(8,:));
            end

            % Slave times paired with a Master which is responsive to juice but non-responsive to cue
            if ~isempty(cellSlaveTimesPairedWJuiceRespCueNonResponsiveMaster)
%                 sTitle = ['(JResp_CNonResp)' sNeuronTypeSlave ' (n=' num2str(length(cellSlaveTimesPairedWJuiceRespCueNonResponsiveMaster)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId];
%                 sFile = [pathToSlavePsthFolder sMouseId '_day' num2str(currentDay) '_' sNeuronTypeSlave '_JRespCNonResp_' sAlignedTo '.tif'];
%                         plotComparisonPSTHs(cellSlaveTimesPairedWJuiceRespCueNonResponsiveMaster, sNeuronTypeSlave, sTitle, sFile, [], cellSlavepairedWithMasterResponsive, 0, COLORS(8,:));
            end

        end

        % Plot NON-RESPONSIVE Masters and their paired Slaves PSTHs
        if ~isempty(cellMasterTimesNonResponsive)
%             sTitle = ['(NonResp)' sNeuronTypeMaster ' (n=' num2str(length(cellMasterTimesNonResponsive)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId ' (non-responsive for the last ' num2str(TRIALS_TO_COMPARE) ' trials)'];
%             sFile = [pathToMasterPsthFolder sMouseId '_day' num2str(currentDay) '_firstVSlast' num2str(TRIALS_TO_COMPARE) '_' sNeuronTypeMaster '_NonResp_' sAlignedTo '.tif'];                    
%             plotComparisonPSTHs(cellMasterTimesNonResponsive, sNeuronTypeMaster, sTitle, sFile, FIRST_VS_LAST, [], 0, COLORS(11, :));

            % Slave times paired with a Master which is non-responsive to juice but responsive to cue
            if ~isempty(cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster)
%                 sTitle = ['(JNonResp_CResp)' sNeuronTypeSlave ' (n=' num2str(length(cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId];
%                 sFile = [pathToSlavePsthFolder sMouseId '_day' num2str(currentDay) '_' sNeuronTypeSlave '_JNonRespCResp_' sAlignedTo '.tif'];
%                         plotComparisonPSTHs(cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster, sNeuronTypeSlave, sTitle, sFile, [], cellSlavepairedWithMasterResponsive, 0, COLORS(8,:));
            end

            % Slave times paired with a Master which is non-responsive to juice and non-responsive to cue
            if ~isempty(cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster)
%                 sTitle = ['(JNonResp_CNonResp)' sNeuronTypeSlave ' (n=' num2str(length(cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster)) ') rate aligned to ' sAlignedTo ' on day ' num2str(currentDay) ' ' sMouseId];
%                 sFile = [pathToSlavePsthFolder sMouseId '_day' num2str(currentDay) '_' sNeuronTypeSlave '_JNonRespCNonResp_' sAlignedTo '.tif'];
%                         plotComparisonPSTHs(cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster, sNeuronTypeSlave, sTitle, sFile, [], cellSlavepairedWithMasterResponsive, 0, COLORS(8,:));
            end

        end      

        dayInd = find(ismember(paramDay,currentDay)); % find which day's data processed
        cellSlaveTimesPairedWJuiceRespCueResponsiveMasterPerDay{dayInd} = cellSlaveTimesPairedWJuiceRespCueResponsiveMaster;
        cellSlaveTimesPairedWJuiceRespCueNonResponsiveMasterPerDay{dayInd} = cellSlaveTimesPairedWJuiceRespCueNonResponsiveMaster;
        cellSlaveTimesPairedWJuiceNonRespCueResponsiveMasterPerDay{dayInd} = cellSlaveTimesPairedWJuiceNonRespCueResponsiveMaster;
        cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMasterPerDay{dayInd} = cellSlaveTimesPairedWJuiceNonRespCueNonResponsiveMaster;

        cellSlaveAllLicksJuiceRespCueResponsiveMasterPerDay{dayInd} = cellSlaveAllLicksJuiceRespCueResponsiveMaster;
        cellSlaveAllLicksJuiceRespCueNonResponsiveMasterPerDay{dayInd} = cellSlaveAllLicksJuiceRespCueNonResponsiveMaster;
        cellSlaveAllLicksJuiceNonRespCueResponsiveMasterPerDay{dayInd} = cellSlaveAllLicksJuiceNonRespCueResponsiveMaster;
        cellSlaveAllLicksJuiceNonRespCueNonResponsiveMasterPerDay{dayInd} = cellSlaveAllLicksJuiceNonRespCueNonResponsiveMaster;

        cellMasterTimesResponsivePerDay{dayInd} = cellMasterTimesResponsive;
        cellMasterTimesNonResponsivePerDay{dayInd} = cellMasterTimesNonResponsive;
    end

end