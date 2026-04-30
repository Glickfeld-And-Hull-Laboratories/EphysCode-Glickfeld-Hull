function [dayAllSSIDsAllMice, phase, radius, indTunedAndHasPower] = checkIOTransformationsForEachTrainingPhase(...
    miceVSDays, behavDataForRecordingDays, unitMFs, unitSSs, sLabel, selectSSIDsAllMice)

    globals;    
    phase = [];
    radius = [];
    indTunedAndHasPower = [];
    
    cellMFIDsPerMouse = cell(1, length(miceVSDays));
    cellMFPerMouse = cell(1, length(miceVSDays));
    cellMFDepthPerMouse = cell(1, length(miceVSDays));

    cellSSIDsPerMouse = cell(1, length(miceVSDays));
    cellSSPerMouse = cell(1, length(miceVSDays));
    cellSSDepthPerMouse = cell(1, length(miceVSDays));

    %%%%%%%%%%%%% FIRST, GET ALL DAYS %%%%%%%%%%%%%%%
    
    for ind=1:length(miceVSDays) % Loop through each mouse
        mouseId = miceVSDays{ind,1};
        thoseWereTheDays = miceVSDays{ind,2};
        % MFs
        [cellMFIDsPerDay, cellMFTimesPerDay, cellMFAllLicksPerDay, cellMFLickOnsetsPerDay, cellMFCuesPerDay, cellMFDepth] = ...
            checkSSResponses(behavDataForRecordingDays, unitMFs, mouseId, thoseWereTheDays); % Loop through each day
        cellMFIDsPerMouse{ind} = cellMFIDsPerDay;
        cellMFPerMouse{ind} = cellMFTimesPerDay;
        cellMFDepthPerMouse{ind} = cellMFDepth;
        cellMFAllLicksPerMouse{ind} = cellMFAllLicksPerDay;
        cellMFLickOnsetsPerMouse{ind} = cellMFLickOnsetsPerDay;
        cellMFCuesPerMouse{ind} = cellMFCuesPerDay;

        % SSs
        [cellSSIDsPerDay, cellSSTimesPerDay, cellSSAllLicksPerDay, cellSSLickOnsetsPerDay, cellSSCuesPerDay, cellSSDepth] = ...
            checkSSResponses(behavDataForRecordingDays, unitSSs, mouseId, thoseWereTheDays); % Loop through each day
        cellSSIDsPerMouse{ind} = cellSSIDsPerDay;
        cellSSPerMouse{ind} = cellSSTimesPerDay;
        cellSSDepthPerMouse{ind} = cellSSDepth;
        cellSSAllLicksPerMouse{ind} = cellSSAllLicksPerDay;
        cellSSLickOnsetsPerMouse{ind} = cellSSLickOnsetsPerDay;
        cellSSCuesPerMouse{ind} = cellSSCuesPerDay;
    end
    
    %%%%%%%%%%%%%%% DAY ALL %%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    dayAllSSIDsAllMice = expandCellArray(cellSSIDsPerMouse);
    dayAllSSAllMice = expandCellArray(cellSSPerMouse);
    daySSAllLicksAllMice = expandCellArray(cellSSAllLicksPerMouse);
    daySSLickOnsetsAllMice = expandCellArray(cellSSLickOnsetsPerMouse);
    daySSCuesAllMice = expandCellArray(cellSSCuesPerMouse); 
    dayDepths = expandCellArray(cellSSDepthPerMouse);

    phasesAllMF = [];
    phasesPerDayAllUnitsPerTrialMF = {};

    phasesAllSS = [];
    phasesPerDayAllUnitsPerTrialSS = {};

    for indMouse=1:length(cellSSPerMouse)        
        for indDay=1:length(cellSSPerMouse{indMouse})
            cellMFTimesPerMousePerDay = cellMFPerMouse{indMouse}{indDay};
            cellMFAllLicksPerMousePerDay = cellMFAllLicksPerMouse{indMouse}{indDay};

            cellSSTimesPerMousePerDay = cellSSPerMouse{indMouse}{indDay};
            cellSSAllLicksPerMousePerDay = cellSSAllLicksPerMouse{indMouse}{indDay};
                        
            if ~isempty(cellMFTimesPerMousePerDay) && ~isempty(cellSSTimesPerMousePerDay)
                [phasesPerUnitPerTrialMF, phasesAllUnitsPerTrialMF] = ...
                    getPhaseOfSpikeTimes(cellMFTimesPerMousePerDay, cellMFAllLicksPerMousePerDay);
                phasesAllMF = [phasesAllMF phasesPerUnitPerTrialMF];
                phasesPerDayAllUnitsPerTrialMF{length(phasesPerDayAllUnitsPerTrialMF)+1} = phasesAllUnitsPerTrialMF;
    
                [phasesPerUnitPerTrialSS, phasesAllUnitsPerTrialSS] = ...
                    getPhaseOfSpikeTimes(cellSSTimesPerMousePerDay, cellSSAllLicksPerMousePerDay);
                phasesAllSS = [phasesAllSS phasesPerUnitPerTrialSS];
                phasesPerDayAllUnitsPerTrialSS{length(phasesPerDayAllUnitsPerTrialSS)+1} = phasesAllUnitsPerTrialSS;
            end
        end
    end
    % 
    %  [spikeRates, individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues] = ...
    %      arrangeSpikeRatesAccordingly(dayAllSSAllMice, WHOLE_PART, daySSAllLicksAllMice, daySSLickOnsetsAllMice, daySSCuesAllMice);
    % %} 

    polarPlotAlongSession(phasesAllMF, phasesPerDayAllUnitsPerTrialMF, ...
        phasesAllSS, phasesPerDayAllUnitsPerTrialSS, sLabel);
    

    % [arrModulations, arrModulationMagnitudeRew, arrModulationMagnitudeCue, isSinusoidal, localMaxs, localMins] = ...
    %     getSignificantModulations(spikeRates);
    % 
    % sAlignedTo = TRIALOUTCOMES_TO_INCLUDE_TITLE;
    % pathToSSPsthFolder = pathToSSToLickPsthFolder;
    % pathToSSPsdFolder = pathToSSToLickPsdFolder;
    % 
    % sTitle = [NEURON_TYPE ' trials ' sAlignedTo ' n = ' num2str(length(dayAllSSAllMice)) ' ' ' on ' sLabel ' ' 'All'];
    % [arrHasPowerCueAligned, arrHasPowerRewAligned] = plotIndividualSpectrograms(spikeRates, arrModulationMagnitudeCue, arrModulationMagnitudeRew, sTitle, dayDepths);
    % 
    % if NORMALIZE_X_AXIS_FOR_EACH_LICK~=0 % Plot polar(phase) plot only if FR aligned to each lick cycle
    %     [arrMaxIndices, arrMaxValues] = getMaxSpikesForPolarPlot(spikeRates, arrModulationMagnitudeRew, individualLickRates);
    % 
    %     sFile = [pathToPolarPlotFolder sLabel 'All' NEURON_TYPE 'Resp_alignedTo' sAlignedTo];
    %     % Polar plot modulated units with power signal and narrowly tuned
    %     [phase, radius, indTunedAndHasPower] = plotPolar(arrModulations, arrHasPowerRewAligned, arrMaxIndices(:,1:3), arrMaxValues(:,1:3), ...
    %         1, 1, 1, [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo ' ModPowNarTun'], [sFile ' ModPowNarTun']);
    %     % Polar plot modulated units with power signal and widely tuned
    %     [phase, radius, indTunedAndHasPower] = plotPolar(arrModulations, arrHasPowerRewAligned, arrMaxIndices(:,1:3), arrMaxValues(:,1:3), ...
    %         1, 1, 0, [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo ' ModPowWideTun'], [sFile ' ModPowWideTun']);
    % 
    %     % Polar plot modulated units without power signal and narrowly tuned
    %     [phase, radius, indTunedAndHasPower] = plotPolar(arrModulations, arrHasPowerRewAligned, arrMaxIndices(:,1:3), arrMaxValues(:,1:3), ...
    %         1, 0, 1, [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo ' ModNoPowNarTun'], [sFile ' ModNoPowNarTun']);
    %     % Polar plot modulated units without power signal and widely tuned
    %     [phase, radius, indTunedAndHasPower] = plotPolar(arrModulations, arrHasPowerRewAligned, arrMaxIndices(:,1:3), arrMaxValues(:,1:3), ...
    %         1, 0, 0, [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo ' ModNoPowWideTun'], [sFile ' ModNoPowWideTun']);
    % 
    %     sTitle = [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo];
    %     plotScatteredPlots(phase, radius, sTitle, [sFile 'ScatterAll']);
    % 
    %     sTitle = [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo ' ratio = ' num2str(round(100*size(phase(indTunedAndHasPower,:),1)/length(arrHasPowerRewAligned))) '%'];
    %     plotScatteredPlots(phase(indTunedAndHasPower,:), radius(indTunedAndHasPower), sTitle, [sFile 'ScatterHasPower']);
    % end 
end