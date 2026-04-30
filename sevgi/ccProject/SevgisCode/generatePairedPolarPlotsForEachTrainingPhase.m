% Copied from checkCSSSResponsesAndPlotPSTHs
function [arrModulationMagnitudeRewRespCSDay1, arrModulationMagnitudeCueRespCSDay1, ...
    arrModulationMagnitudeRewRespCSDayN, arrModulationMagnitudeCueRespCSDayN, ...
    arrModulationMagnitudeRewRespCSDayAll, arrModulationMagnitudeCueRespCSDayAll, integralValuesAfterRew] = ...
    generatePairedPolarPlotsForEachTrainingPhase(miceVSDays, miceVSSelectedDay1, miceVSSelectedDayN, ...
    behavDataForRecordingDays, unitCSs, unitSSs, sLabel)

    globals;
    arrModulationMagnitudeRewRespCSDay1 = [];
    arrModulationMagnitudeCueRespCSDay1 = [];
    arrModulationMagnitudeRewRespCSDayN = [];
    arrModulationMagnitudeCueRespCSDayN = [];
    cellCSResponsivePerMouse = cell(1, length(miceVSDays));
    cellCSNonResponsivePerMouse = cell(1, length(miceVSDays));   
    integralValuesAfterRew = [];

    %%%%%%%%%%%%% FIRST, GET ALL DAYS %%%%%%%%%%%%%%%
    for ind=1:length(miceVSDays) % Loop through each mouse
        mouseId = miceVSDays{ind,1};
        days = miceVSDays{ind,2};
        [cellCSTimesResponsive, cellCSTimesNonResponsive, ...
            cellSSTimesJuiceRespCueRespCS, cellSSTimesJuiceRespCueNonRespCS, ...
            cellSSTimesJuiceNonRespCueRespCS, cellSSTimesJuiceNonRespCueNonRespCS, ...
            cellSSAllLicksJuiceRespCueResponsiveCS, cellSSAllLicksJuiceRespCueNonResponsiveCS, ...
            cellSSAllLicksJuiceNonRespCueResponsiveCS, cellSSAllLicksJuiceNonRespCueNonResponsiveCS, ...
            cellSSLickOnsetsJuiceRespCueResponsiveCS, cellSSLickOnsetsJuiceRespCueNonResponsiveCS, ...
            cellSSLickOnsetsJuiceNonRespCueResponsiveCS, cellSSLickOnsetsJuiceNonRespCueNonResponsiveCS, ...
            cellSSCuesJuiceRespCueResponsiveCS, cellSSCuesJuiceRespCueNonResponsiveCS, ...
            cellSSCuesJuiceNonRespCueResponsiveCS, cellSSCuesJuiceNonRespCueNonResponsiveCS] = ...
            checkCSSSOnlyPairedResponses(behavDataForRecordingDays, unitCSs, unitSSs, mouseId, days); % Loop through each day

        cellCSResponsivePerMouse{ind} = cellCSTimesResponsive;
        cellCSNonResponsivePerMouse{ind} = cellCSTimesNonResponsive;

        cellSSJuiceRespCueRespCSPerMouse{ind} = cellSSTimesJuiceRespCueRespCS;
        cellSSJuiceRespCueNonRespCSPerMouse{ind} = cellSSTimesJuiceRespCueNonRespCS;
        cellSSJuiceNonRespCueRespCSPerMouse{ind} = cellSSTimesJuiceNonRespCueRespCS;
        cellSSJuiceNonRespCueNonRespCSPerMouse{ind} = cellSSTimesJuiceNonRespCueNonRespCS;

        cellSSAllLicksJuiceRespCueResponsiveCSPerMouse{ind} = cellSSAllLicksJuiceRespCueResponsiveCS;
        cellSSAllLicksJuiceRespCueNonResponsiveCSPerMouse{ind} = cellSSAllLicksJuiceRespCueNonResponsiveCS;
        cellSSAllLicksJuiceNonRespCueResponsiveCSPerMouse{ind} = cellSSAllLicksJuiceNonRespCueResponsiveCS;
        cellSSAllLicksJuiceNonRespCueNonResponsiveCSPerMouse{ind} = cellSSAllLicksJuiceNonRespCueNonResponsiveCS;

        cellSSLickOnsetsJuiceRespCueResponsiveCSPerMouse{ind} = cellSSLickOnsetsJuiceRespCueResponsiveCS;
        cellSSLickOnsetsJuiceRespCueNonResponsiveCSPerMouse{ind} = cellSSLickOnsetsJuiceRespCueNonResponsiveCS;
        cellSSLickOnsetsJuiceNonRespCueResponsiveCSPerMouse{ind} = cellSSLickOnsetsJuiceNonRespCueResponsiveCS;
        cellSSLickOnsetsJuiceNonRespCueNonResponsiveCSPerMouse{ind} = cellSSLickOnsetsJuiceNonRespCueNonResponsiveCS;

        cellSSCuesJuiceRespCueResponsiveCSPerMouse{ind} = cellSSCuesJuiceRespCueResponsiveCS;
        cellSSCuesJuiceRespCueNonResponsiveCSPerMouse{ind} = cellSSCuesJuiceRespCueNonResponsiveCS;
        cellSSCuesJuiceNonRespCueResponsiveCSPerMouse{ind} = cellSSCuesJuiceNonRespCueResponsiveCS;
        cellSSCuesJuiceNonRespCueNonResponsiveCSPerMouse{ind} = cellSSCuesJuiceNonRespCueNonResponsiveCS;
    end

    %%%%%%%%%%%%%% DAY ALL %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [dayAllCSResponsiveAllMice, lenCS] = expandCellArray(cellCSResponsivePerMouse);
    dayAllCSNonResponsiveAllMice = expandCellArray(cellCSNonResponsivePerMouse);
    [dayAllSSJuiceRespCueRespCSAllMice, lenSS] = expandCellArray(cellSSJuiceRespCueRespCSPerMouse);
    dayAllSSJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSJuiceRespCueNonRespCSPerMouse);
    dayAllSSJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSJuiceNonRespCueRespCSPerMouse);
    dayAllSSJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSJuiceNonRespCueNonRespCSPerMouse);
    
    daySSAllLicksJuiceRespCueRespCSAllMice = expandCellArray(cellSSAllLicksJuiceRespCueResponsiveCSPerMouse);
    daySSAllLicksJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSAllLicksJuiceRespCueNonResponsiveCSPerMouse);
    daySSAllLicksJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSAllLicksJuiceNonRespCueResponsiveCSPerMouse);
    daySSAllLicksJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSAllLicksJuiceNonRespCueNonResponsiveCSPerMouse);

    daySSLickOnsetsJuiceRespCueRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceRespCueResponsiveCSPerMouse);
    daySSLickOnsetsJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceRespCueNonResponsiveCSPerMouse);
    daySSLickOnsetsJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceNonRespCueResponsiveCSPerMouse);
    daySSLickOnsetsJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSLickOnsetsJuiceNonRespCueNonResponsiveCSPerMouse);

    daySSCuesJuiceRespCueRespCSAllMice = expandCellArray(cellSSCuesJuiceRespCueResponsiveCSPerMouse);
    daySSCuesJuiceRespCueNonRespCSAllMice = expandCellArray(cellSSCuesJuiceRespCueNonResponsiveCSPerMouse);
    daySSCuesJuiceNonRespCueRespCSAllMice = expandCellArray(cellSSCuesJuiceNonRespCueResponsiveCSPerMouse);
    daySSCuesJuiceNonRespCueNonRespCSAllMice = expandCellArray(cellSSCuesJuiceNonRespCueNonResponsiveCSPerMouse);

    [spikeRatesCS, individualLickRatesCS, ~, ~, ~, ~] = ...
        arrangeSpikeRatesAccordingly(dayAllCSResponsiveAllMice, WHOLE_PART, daySSAllLicksJuiceRespCueRespCSAllMice, ...
        daySSLickOnsetsJuiceRespCueRespCSAllMice, daySSCuesJuiceRespCueRespCSAllMice);

    [spikeRatesSS, individualLickRatesSS, ~, ~, ~, ~] = ...
        arrangeSpikeRatesAccordingly(dayAllSSJuiceRespCueRespCSAllMice, WHOLE_PART, daySSAllLicksJuiceRespCueRespCSAllMice, ...
        daySSLickOnsetsJuiceRespCueRespCSAllMice, daySSCuesJuiceRespCueRespCSAllMice);

    % [arrModulationsCS, arrModulationMagnitudeRewCS, arrModulationMagnitudeCueCS, ~, ~, ~] = getSignificantModulations(spikeRatesCS);
    % [arrModulationsSS, arrModulationMagnitudeRewSS, arrModulationMagnitudeCueSS, ~, ~, ~] = getSignificantModulations(spikeRatesSS);
    % 
    sAlignedTo = TRIALOUTCOMES_TO_INCLUDE_TITLE;        
    % sTitle = [NEURON_TYPE_CS ' trials ' sAlignedTo ' n = ' num2str(length(dayAllCSResponsiveAllMice)) ' ' ' on ' sLabel];
    % [~, arrHasPowerRewAlignedCS] = plotIndividualSpectrograms(spikeRatesCS, arrModulationMagnitudeCueCS, arrModulationMagnitudeRewCS, sTitle, []); %dayDepths);
    % 
    % sTitle = [NEURON_TYPE_SS ' trials ' sAlignedTo ' n = ' num2str(length(dayAllSSJuiceRespCueRespCSAllMice)) ' ' ' on ' sLabel];
    % [~, arrHasPowerRewAlignedSS] = plotIndividualSpectrograms(spikeRatesSS, arrModulationMagnitudeCueSS, arrModulationMagnitudeRewSS, sTitle, []); %dayDepths);

    if NORMALIZE_X_AXIS_FOR_EACH_LICK~=0 % Plot polar(phase) plot only if FR aligned to each lick cycle
        sendOnesCS = ones(1,size(spikeRatesCS,1));
        [arrMaxIndicesCS, arrMaxValuesCS] = getMaxSpikesForPolarPlot(spikeRatesCS, sendOnesCS, individualLickRatesCS); % arrModulationMagnitudeRewCS, individualLickRatesCS);
        sendOnesSS = ones(1,size(spikeRatesSS,1));
        [arrMaxIndicesSS, arrMaxValuesSS] = getMaxSpikesForPolarPlot(spikeRatesSS, sendOnesSS, individualLickRatesSS); % arrModulationMagnitudeRewSS, individualLickRatesSS);

        sFile = [pathToPolarPlotFolder sLabel '_CS_SS_Resp_alignedTo' sAlignedTo];
        % % Polar plot modulated units with power signal and narrowly tuned
        % [phase, radius, indTunedAndHasPower] = plotPairedPolar(arrModulationsCS, arrHasPowerRewAlignedCS, arrMaxIndicesCS(:,1:3), arrMaxValuesCS(:,1:3), ...
        %     arrModulationsSS, arrHasPowerRewAlignedSS, arrMaxIndicesSS(:,1:3), arrMaxValuesSS(:,1:3), ...
        %     1, 1, 1, [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo ' ModPowNarTun'], [sFile ' ModPowNarTun']);
        % % Polar plot modulated units with power signal and widely tuned
        % [phase, radius, indTunedAndHasPower] = plotPairedPolar(arrModulationsCS, arrHasPowerRewAlignedCS, arrMaxIndicesCS(:,1:3), arrMaxValuesCS(:,1:3), ...
        %     arrModulationsSS, arrHasPowerRewAlignedSS, arrMaxIndicesSS(:,1:3), arrMaxValuesSS(:,1:3), ...
        %     1, 1, 0, [sLabel 'All' NEURON_TYPE 'RespAlignedTo' sAlignedTo ' ModPowWideTun'], [sFile ' ModPowWideTun']);

        [phase, radius, indTunedAndHasPower] = plotPairedPolar(lenCS, sendOnesCS, sendOnesCS, arrMaxIndicesCS(:,1:3), arrMaxValuesCS(:,1:3), ...
            sendOnesSS, sendOnesSS, arrMaxIndicesSS(:,1:3), arrMaxValuesSS(:,1:3), ...
            1, 1, 1, [sLabel '_CS_SS_RespAlignedTo' sAlignedTo ' ModPowNarTun'], [sFile ' ModPowNarTun']);
        % Polar plot modulated units with power signal and widely tuned
        % [phase, radius, indTunedAndHasPower] = plotPairedPolar(lenCS, sendOnesCS, sendOnesCS, arrMaxIndicesCS(:,1:3), arrMaxValuesCS(:,1:3), ...
        %     sendOnesSS, sendOnesSS, arrMaxIndicesSS(:,1:3), arrMaxValuesSS(:,1:3), ...
        %     1, 1, 0, [sLabel '_CS_SS_RespAlignedTo' sAlignedTo ' ModPowWideTun'], [sFile ' ModPowWideTun']);
    end
end