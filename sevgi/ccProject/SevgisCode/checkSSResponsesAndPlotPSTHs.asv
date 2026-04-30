function [dayAllSSIDsAllMice, arrModulations, isSinusoidal] = checkSSResponsesAndPlotPSTHs(miceVSDays, miceVSSelectedDay1, miceVSSelectedDayN, ...
    behavDataForRecordingDays, unitSSs, sLabel, bPlot, selectSSIDsAllMice)

    globals;    
    arrModulationMagnitudeRewRespCSDay1 = [];
    arrModulationMagnitudeCueRespCSDay1 = [];
    arrModulationMagnitudeRewRespCSDayN = [];
    arrModulationMagnitudeCueRespCSDayN = [];
    arrModulationMagnitudeRewRespCSDayAll = [];
    arrModulationMagnitudeCueRespCSDayAll = [];
    
    cellSSIDsPerMouse = cell(1, length(miceVSDays));
    cellSSPerMouse = cell(1, length(miceVSDays));
    cellDepthPerMouse = cell(1, length(miceVSDays));

%     if modeAlignment == MODE_ALIGNMENT_TO_CLICK
%         sAlignedTo = 'click';
%         pathToSSPsthFolder = pathToSSToClickPsthFolder;
%     elseif modeAlignment == MODE_ALIGNMENT_TO_LICK
%         sAlignedTo = 'lick';
%         pathToSSPsthFolder = pathToSSToLickPsthFolder;
%     end

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

    [spikeRates, individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues] = arrangeSpikeRatesAccordingly(dayAllSSAllMice, WHOLE_PART, daySSAllLicksAllMice, daySSLickOnsetsAllMice, daySSCuesAllMice);
    % [integralValuesAfterRew, onsetPoint] = getIntegralAndOnsets(spikeRates);

    [arrModulations, arrModulationMagnitudeRew, arrModulationMagnitudeCue, isSinusoidal, localMaxs, localMins] = ...
            getSignificantModulations(spikeRates);

    % If lick-cycle-aligned modulations are sent, use these instead of the current alignment's modulations
    % if ~isempty(arrModulationsLickCycleAligned)
    %     arrModulations = arrModulationsLickCycleAligned;
    % end
    % if ~isempty(isSinusoidalLickCycleAligned)
    %     isSinusoidal = isSinusoidalLickCycleAligned;
    % end

    if bPlot
        callPlot([], [], spikeRates, [], [], [], ... 
            arrModulations, isSinusoidal, localMaxs, localMins, ...
            individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, 'All', sLabel, dayDepths);
    
        if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
            sAlignedTo = 'click';
            pathToSSPsthFolder = pathToSSToClickPsthFolder;
            pathToSSPsdFolder = pathToSSToClickPsdFolder;
        elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
            sAlignedTo = TRIALOUTCOMES_TO_INCLUDE_TITLE;
            pathToSSPsthFolder = pathToSSToLickPsthFolder;
            pathToSSPsdFolder = pathToSSToLickPsdFolder;
        elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_TONE
            sAlignedTo = 'tone';
            pathToSSPsthFolder = pathToSSToTonePsthFolder; 
        end
    
        sTitle = [NEURON_TYPE ' trials ' sAlignedTo ' n = ' num2str(length(dayAllSSAllMice)) ' ' ' on ' sLabel ' ' 'All'];
        [arrHasPowerCueAligned, arrHasPowerRewAligned] = plotIndividualSpectrograms(spikeRates, arrModulationMagnitudeCue, arrModulationMagnitudeRew, sTitle, dayDepths);
        
        nIncResp = sum(arrModulationMagnitudeRew>0 & arrHasPowerRewAligned==0); % Only responsive in general (but not to each lick cycle) Inc
        nIncLickResp = sum(arrModulationMagnitudeRew>0 & arrHasPowerRewAligned==1); % Lick responsive Inc
        nDecResp = sum(arrModulationMagnitudeRew<0 & arrHasPowerRewAligned==0); % Only responsive Dec
        nDecLickResp = sum(arrModulationMagnitudeRew<0 & arrHasPowerRewAligned==1); % Lick responsive Dec
        nTotalResp = nIncResp+nIncLickResp+nDecResp+nDecLickResp;
        plotPie([length(dayAllSSAllMice)-nTotalResp nIncResp nIncLickResp nDecResp nDecLickResp], ...
            {'', 'Facilitated','Facilitated wLick','Suppressed','Suppressed wLick'},...
            [COLORS(8,1:3); COLOR_BLIND_FRIENDLY_RED; COLORS(4,1:3); COLOR_BLIND_FRIENDLY_BLUE; COLORS(9,1:3)], ...
            [sLabel 'All' NEURON_TYPE 'Resp_alignedTo' sAlignedTo], pathToSSPsthFolder);

        sFile = [pathToHistogramFolder sLabel 'All' 'SSResp_alignedTo' sAlignedTo];
        plotHistogram(abs(arrModulationMagnitudeRew(arrModulationMagnitudeRew~=0)), 0, 100, 'Z(Spike/s)', 'Freq', [sLabel 'All' ' Amplitude dist.'], sFile, 0);

        %%%% Plot Spectrum  %%%%%%%
        sTitle = [NEURON_TYPE ' trials n = ' num2str(length(dayAllSSAllMice))];
        sFile = [pathToSSPsdFolder sLabel 'All' '_' NEURON_TYPE '_alignedTo' sAlignedTo];
        
        if NORMALIZE_X_AXIS_FOR_EACH_LICK == 0 % if no lick cycle alignment, remove the power criteria, just plot all modulated ones
            plotSpectrogram(spikeRates(find(arrModulationMagnitudeRew~=0),:), sTitle, sFile, sAlignedTo, 1);
        else
            plotSpectrogram(spikeRates(find(arrHasPowerRewAligned),:), sTitle, sFile, sAlignedTo, 1);
        end
    end
end