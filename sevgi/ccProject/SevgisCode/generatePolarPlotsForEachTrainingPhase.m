function [dayAllSSIDsAllMice, phase, radius, indTunedAndHasPower, arrHasPowerRewAligned] = generatePolarPlotsForEachTrainingPhase(...
    miceVSDays, miceVSSelectedDay1, miceVSSelectedDayN, ...
    behavDataForRecordingDays, unitSSs, sLabel, selectSSIDsAllMice)

    globals;    
    phase = [];
    radius = [];
    indTunedAndHasPower = [];
    
    cellSSIDsPerMouse = cell(1, length(miceVSDays));
    cellSSPerMouse = cell(1, length(miceVSDays));
    cellDepthPerMouse = cell(1, length(miceVSDays));

    %%%%%%%%%%%%% FIRST, GET ALL DAYS %%%%%%%%%%%%%%%
    if isempty(selectSSIDsAllMice)
        for ind=1:length(miceVSDays) % Loop through each mouse
            mouseId = miceVSDays{ind,1};
            thoseWereTheDays = miceVSDays{ind,2};
            [cellSSIDsPerDay, cellSSTimesPerDay, cellSSAllLicksPerDay, cellSSLickOnsetsPerDay, cellSSCuesPerDay, cellDepth] = ...
                checkSSResponses(behavDataForRecordingDays, unitSSs, mouseId, thoseWereTheDays); % Loop through each day
            cellSSIDsPerMouse{ind} = cellSSIDsPerDay;
            cellSSPerMouse{ind} = cellSSTimesPerDay;
            cellDepthPerMouse{ind} = cellDepth;
            cellSSAllLicksPerMouse{ind} = cellSSAllLicksPerDay;
            cellSSLickOnsetsPerMouse{ind} = cellSSLickOnsetsPerDay;
            cellSSCuesPerMouse{ind} = cellSSCuesPerDay;
        end
    else
        for ind=1:length(miceVSDays) % Loop through each mouse
            mouseId = miceVSDays{ind,1};
            thoseWereTheDays = miceVSDays{ind,2};
            [cellSSIDsPerDay, cellSSTimesPerDay, cellSSAllLicksPerDay, cellSSLickOnsetsPerDay, cellSSCuesPerDay, cellDepth] = ...
                checkSelectedSSResponses(behavDataForRecordingDays, unitSSs, selectSSIDsAllMice, mouseId, thoseWereTheDays); % Loop through each day
            cellSSIDsPerMouse{ind} = cellSSIDsPerDay;
            cellSSPerMouse{ind} = cellSSTimesPerDay;
            cellDepthPerMouse{ind} = cellDepth;
            cellSSAllLicksPerMouse{ind} = cellSSAllLicksPerDay;
            cellSSLickOnsetsPerMouse{ind} = cellSSLickOnsetsPerDay;
            cellSSCuesPerMouse{ind} = cellSSCuesPerDay;
        end
    end

    %%%%%%%%%%%%%%% DAY 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%     if ~isempty(miceVSSelectedDay1)
%         day1SSAllMice = expandCellArray(cellSSPerMouse, miceVSSelectedDay1);
%         day1SSLicksAllMice = expandCellArray(cellSSAllLicksPerMouse, miceVSSelectedDay1);
%         day1SSLickOnsetsAllMice = expandCellArray(cellSSLickOnsetsPerMouse, miceVSSelectedDay1);
%         day1SSCuesAllMice = expandCellArray(cellSSCuesPerMouse, miceVSSelectedDay1);
%         [arrModulationMagnitudeRewRespCSDay1, arrModulationMagnitudeCueRespCSDay1] = callPlot([], [], day1SSAllMice, [], [], [], ...
%             day1SSLicksAllMice, [], [], [], ...
%             day1SSLickOnsetsAllMice, [], [], [], ...
%             day1SSCuesAllMice, [], [], [], ...
%             '1', sLabel);
%     end
% 
%     %%%%%%%%%%%%%%% DAY N %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if ~isempty(miceVSSelectedDayN)
%         dayNSSAllMice = expandCellArray(cellSSPerMouse, miceVSSelectedDayN);
%         dayNSSLicksAllMice = expandCellArray(cellSSAllLicksPerMouse, miceVSSelectedDayN);
%         dayNSSLickOnsetsAllMice = expandCellArray(cellSSLickOnsetsPerMouse, miceVSSelectedDayN);
%         dayNSSCuesAllMice = expandCellArray(cellSSCuesPerMouse, miceVSSelectedDayN); 
%         [arrModulationMagnitudeRewRespCSDayN, arrModulationMagnitudeCueRespCSDayN] = callPlot([], [], dayNSSAllMice, [], [], [], ...
%             dayNSSLicksAllMice, [], [], [], ...
%             dayNSSLickOnsetsAllMice, [], [], [], ...
%             dayNSSCuesAllMice, [], [], [], ...
%             'N', sLabel);
%     end

    %%%%%%%%%%%%%%% DAY ALL %%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    dayAllSSIDsAllMice = expandCellArray(cellSSIDsPerMouse);
    dayAllSSAllMice = expandCellArray(cellSSPerMouse);
    daySSAllLicksAllMice = expandCellArray(cellSSAllLicksPerMouse);
    daySSLickOnsetsAllMice = expandCellArray(cellSSLickOnsetsPerMouse);
    daySSCuesAllMice = expandCellArray(cellSSCuesPerMouse); 
    dayDepths = expandCellArray(cellDepthPerMouse);

    [spikeRates, individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues] = ...
        arrangeSpikeRatesAccordingly(dayAllSSAllMice, WHOLE_PART, daySSAllLicksAllMice, daySSLickOnsetsAllMice, daySSCuesAllMice);
    % [integralValuesAfterRew, onsetPoint] = getIntegralAndOnsets(spikeRates);

    [arrModulations, arrModulationMagnitudeRew, arrModulationMagnitudeCue, isSinusoidal, localMaxs, localMins] = ...
        getSignificantModulations(spikeRates);
   
    sAlignedTo = TRIALOUTCOMES_TO_INCLUDE_TITLE;        
    sTitle = [NEURON_TYPE ' trials ' sAlignedTo ' n = ' num2str(length(dayAllSSAllMice)) ' ' ' on ' sLabel ' ' 'All'];
    [arrHasPowerCueAligned, arrHasPowerRewAligned] = plotIndividualSpectrograms(spikeRates, arrModulationMagnitudeCue, arrModulationMagnitudeRew, sTitle, dayDepths);

    if NORMALIZE_X_AXIS_FOR_EACH_LICK~=0 % Plot polar(phase) plot only if FR aligned to each lick cycle
        [arrMaxIndices, arrMaxValues] = getMaxSpikesForPolarPlot(spikeRates, arrModulationMagnitudeRew, individualLickRates);

        sFile = [pathToPolarPlotFolder sLabel 'All' NEURON_TYPE 'Resp_alignedTo' sAlignedTo];
        % Polar plot modulated units with power signal and narrowly tuned
        [phase, radius, indTunedAndHasPower] = plotPolar(arrModulations, arrHasPowerRewAligned, arrMaxIndices(:,1:3), arrMaxValues(:,1:3), ...
            1, 1, 0, [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo ' ModWHiPow'], [sFile ' ModWHiPow']);
        % Polar plot modulated units with power signal and widely tuned
        [phase, radius, indTunedAndHasPower] = plotPolar(arrModulations, arrHasPowerRewAligned, arrMaxIndices(:,1:3), arrMaxValues(:,1:3), ...
            1, 0, 0, [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo ' ModWAllPow'], [sFile ' ModWAllPow']);

        % % Polar plot modulated units without power signal and narrowly tuned
        % [phase, radius, indTunedAndHasPower] = plotPolar(arrModulations, arrHasPowerRewAligned, arrMaxIndices(:,1:3), arrMaxValues(:,1:3), ...
        %     1, 0, 1, [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo ' ModNoPowNarTun'], [sFile ' ModNoPowNarTun']);
        % % Polar plot modulated units without power signal and widely tuned
        % [phase, radius, indTunedAndHasPower] = plotPolar(arrModulations, arrHasPowerRewAligned, arrMaxIndices(:,1:3), arrMaxValues(:,1:3), ...
        %     1, 0, 0, [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo ' ModNoPowWideTun'], [sFile ' ModNoPowWideTun']);

        sTitle = [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo];
        % plotScatteredPlots(phase, radius, sTitle, [sFile 'ScatterAll']);

        sTitle = [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo ' ratio = ' num2str(round(100*size(phase(indTunedAndHasPower,:),1)/length(arrHasPowerRewAligned))) '%'];
        % plotScatteredPlots(phase(indTunedAndHasPower,:), radius(indTunedAndHasPower), sTitle, [sFile 'ScatterHasPower']);
    end 
end