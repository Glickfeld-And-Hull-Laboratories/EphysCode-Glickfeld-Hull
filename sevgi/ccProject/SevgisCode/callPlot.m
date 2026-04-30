function [arrModulationMagnitudeRewRespCS, arrModulationMagnitudeCueRespCS, arrModulationMagnitudeRewResp] = ...
    callPlot(dayCSResponsiveAllMice, dayCSNonResponsiveAllMice, ...
    daySSJuiceRespCueRespCSAllMice, daySSJuiceRespCueNonRespCSAllMice, ...
    daySSJuiceNonRespCueRespCSAllMice, daySSJuiceNonRespCueNonRespCSAllMice, ...
    arrModulations, isSinusoidal, localMaxs, localMins, ...
    individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, ...
    sDay, sLabel, dayDepths)
    
    globals;

    arrModulationMagnitudeRewRespCS = [];
    arrModulationMagnitudeCueRespCS = [];
    arrModulationMagnitudeRewResp = [];

    if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
        sAlignedTo = 'click';
        pathToCSPsthFolder = pathToCSToClickPsthFolder;
        pathToSSPsthFolder = pathToSSToClickPsthFolder;
        pathToSSPsdFolder = pathToSSToClickPsdFolder;
        sRangewOrwOutCS = TRIALOUTCOMES_TO_INCLUDE_TITLE;
        if NORMALIZE_X_AXIS_FOR_EACH_LICK == 0
            PRE_BEHAVIORAL_EVENT_PLOT = .85; %1; %.85; % cos cue comes around -700 ms %1.5; % (s) Pre-event duration to include in the raster/psth
            POST_BEHAVIORAL_EVENT_PLOT = 0.5; %1; %0.5; %1.5; %.5; % (s) Post-event duration to include in the raster/psth
        end
    elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
        sAlignedTo = TRIALOUTCOMES_TO_INCLUDE_TITLE;
        pathToCSPsthFolder = pathToCSToLickPsthFolder;
        pathToSSPsthFolder = pathToSSToLickPsthFolder;
        pathToSSPsdFolder = pathToSSToLickPsdFolder;
        if ~isempty(CS_POTENTIATION_RANGE_AROUND_LICK)
            sRangewOrwOutCS = 'before lick';
        else
            sRangewOrwOutCS = '';
        end
        if NORMALIZE_X_AXIS_FOR_EACH_LICK == 0
            PRE_BEHAVIORAL_EVENT_PLOT = 1;% .9; % cos cue comes around -700 ms %1.5; % (s) Pre-event duration to include in the raster/psth
            POST_BEHAVIORAL_EVENT_PLOT = 1; %.75; %1.5; %.5; % (s) Post-event duration to include in the raster/psth
        end
    elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_TONE
        sAlignedTo = 'tone';
        pathToCSPsthFolder = pathToCSToTonePsthFolder;
        pathToSSPsthFolder = pathToSSToTonePsthFolder;
        pathToSSPsdFolder = pathToSSToTonePsdFolder;
        sRangewOrwOutCS = TRIALOUTCOMES_TO_INCLUDE_TITLE; 
        if NORMALIZE_X_AXIS_FOR_EACH_LICK == 0
            PRE_BEHAVIORAL_EVENT_PLOT = 1; %.85; % cos cue comes around -700 ms %1.5; % (s) Pre-event duration to include in the raster/psth
            POST_BEHAVIORAL_EVENT_PLOT = 1; %0.5; %1.5; %.5; % (s) Post-event duration to include in the raster/psth
        end
    end
  
    if FLAG_NORM_FR
        if strcmp(NEURON_TYPE,NEURON_TYPE_MFB)
            MIN_YLIM = MIN_Z_MF_YLIM; %-1.5; %min([spikeRatesPre; spikeRatesPost])*1.1; %.95;            
            MAX_YLIM = MAX_Z_MF_YLIM; %1.5; %max([spikeRatesPre; spikeRatesPost])*2; %1.05;
        elseif strcmp(NEURON_TYPE,NEURON_TYPE_SS)
            MIN_YLIM = MIN_Z_SS_YLIM; %-1.5; %min([spikeRatesPre; spikeRatesPost])*1.1; %.95;            
            MAX_YLIM = MAX_Z_SS_YLIM; %1.5; %max([spikeRatesPre; spikeRatesPost])*2; %1.05;
        else
            MIN_YLIM = MIN_Z_YLIM; %-1.5; %min([spikeRatesPre; spikeRatesPost])*1.1; %.95;            
            MAX_YLIM = MAX_Z_YLIM;
        end

        sYLabel = 'Norm(Spikes/s)';
    else
        if strcmp(NEURON_TYPE,NEURON_TYPE_MFB)
            MIN_YLIM = MIN_MFB_YLIM; %80;
            MAX_YLIM = MAX_MFB_YLIM; %105;
        elseif strcmp(NEURON_TYPE,NEURON_TYPE_SS)
            MIN_YLIM = MIN_SS_YLIM; %80;
            MAX_YLIM = MAX_SS_YLIM; %105;
        end
        sYLabel = 'Spikes/s';
    end
        
    sAddTitle = [' on ' sLabel ' ' sDay];

    if ~isempty(dayCSResponsiveAllMice)
        if FLAG_PLOT_CS
            sTitle = [NEURON_TYPE_CS ' (n=' num2str(length(dayCSResponsiveAllMice)) ') ' sRangewOrwOutCS sAddTitle ];
            sFirstLast = '';
            if FIRST_VS_LAST
                sTitle = [sTitle ' responsive for the first ' num2str(TRIALS_FIRST) ' vs last ' num2str(TRIALS_TO_COMPARE) ' trials)'];
                sFirstLast = ['_firstVSlast' num2str(TRIALS_TO_COMPARE)];
            end
            sFile = [pathToCSPsthFolder sLabel sDay sFirstLast '_' NEURON_TYPE_CS '_' sRangewOrwOutCS '_Resp_alignedTo' sAlignedTo];    
            plotComparisonPSTHs(dayCSResponsiveAllMice, arrModulations, {}, ...
                individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, NEURON_TYPE_CS, sTitle, sFile, ['Time from ' sAlignedTo ' (s)'], [], 0, []);

            respondingToRewOnly = sum(arrModulationMagnitudeRewRespCS~=0 & arrModulationMagnitudeCueRespCS==0);
            respondingToCueOnly = sum(arrModulationMagnitudeCueRespCS~=0 & arrModulationMagnitudeRewRespCS==0);
            respondingToRewCue = sum(arrModulationMagnitudeRewRespCS~=0 & arrModulationMagnitudeCueRespCS~=0);
            total = respondingToRewOnly + respondingToCueOnly + respondingToRewCue;            
            plotPie([length(dayCSResponsiveAllMice)-total respondingToRewOnly respondingToCueOnly respondingToRewCue], ...
                {'', 'OnlyRewResp','OnlyCueResp','CueRewResp'}, ...
                [COLORS(8,1:3); COLORS(1,1:3); COLOR_BLIND_FRIENDLY_GREEN; COLORS(3,1:3)], ...
                [sLabel sDay 'CSResp'], pathToCSPsthFolder);
        end
    end

    if ~FLAG_PLOT_SEPERATELY
%             if ~isempty(cellSSJuiceRespCueRespCSPerMouse) || ~isempty(cellSSJuiceNonRespCueRespCSPerMouse) || ~isempty(cellSSJuiceRespCueNonRespCSPerMouse) || ~isempty(cellSSJuiceNonRespCueNonRespCSPerMouse)
            f = prePlot();
            strLegend = {};
%                 indsEmpty = cellfun(@(x) cellfun(@isempty,x),cellSSJuiceRespCueRespCSPerMouse, UniformOutput=false);
%                 indAnyEmpty = cellfun(@all,indsEmpty);            
%                 if ~isempty(cellSSJuiceRespCueRespCSPerMouse) && ~all(indAnyEmpty)
            if ~isCellArraySomehowEmpty(daySSJuiceRespCueRespCSAllMice)
                [spikeRatesPre_JuiceRespCueResp, spikeRatesPost_JuiceRespCueResp] = ...
                    plotComparisonPSTHs(daySSJuiceRespCueRespCSAllMice, arrModulations, {}, ...
                    individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, NEURON_TYPE, [], [], [], [], 1, dayDepths); % red                
                strLegend = {strLegend{:}, ['Paired wModCS around juice n = ' num2str(length(daySSJuiceRespCueRespCSAllMice))]};
            end

%                 indsEmpty = cellfun(@(x) cellfun(@isempty,x),cellSSJuiceNonRespCueRespCSPerMouse, UniformOutput=false);
%                 indAnyEmpty = cellfun(@all,indsEmpty);
%                 if ~isempty(cellSSJuiceNonRespCueRespCSPerMouse) && ~all(indAnyEmpty)
            if ~isCellArraySomehowEmpty(daySSJuiceNonRespCueRespCSAllMice)
                [spikeRatesPre_JuiceNonRespCueResp, spikeRatesPost_JuiceNonRespCueResp] = ...
                plotComparisonPSTHs(daySSJuiceNonRespCueRespCSAllMice, arrModulations, {}, ...
                individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, NEURON_TYPE, [], [], [], [], 1, []);
                strLegend = {strLegend{:}, ['Paired wNonModCS around juice n = ' num2str(length(daySSJuiceNonRespCueRespCSAllMice))]};
            end           
            if ~isempty(strLegend)
                legend(strLegend);
            end
            sTitle = [NEURON_TYPE ' trials ' sRangewOrwOutCS sAddTitle];
            sFile = [pathToSSPsthFolder sLabel sDay '_' NEURON_TYPE '_wJvsNonJResp_wCS' sRangewOrwOutCS '_alignedTo' sAlignedTo];
            postPlot(f, ['Time from ' sAlignedTo ' (s)'], sYLabel, -PRE_BEHAVIORAL_EVENT_PLOT, POST_BEHAVIORAL_EVENT_PLOT, MIN_YLIM, MAX_YLIM, sTitle, sFile);
               
            if ~isCellArraySomehowEmpty(daySSJuiceRespCueRespCSAllMice)
                nInc = sum(arrModulationMagnitudeRewResp>0);
                nDec = sum(arrModulationMagnitudeRewResp<0);
                plotPie([length(daySSJuiceRespCueRespCSAllMice)-nInc-nDec nInc nDec], ...
                    {'', 'Facilitated','Suppressed'},...
                    [COLORS(8,1:3); COLOR_BLIND_FRIENDLY_RED; COLOR_BLIND_FRIENDLY_BLUE], ...
                    [sLabel sDay 'SSResp_alignedTo' sAlignedTo], pathToSSPsthFolder);
            end
            %%%% Plot Spectrum  %%%%%%%
            sFile = [pathToSSPsdFolder sLabel sDay '_' NEURON_TYPE '_wJResp_wCS' sRangewOrwOutCS '_alignedTo' sAlignedTo];
            plotSpectrogram(spikeRatesPre_JuiceRespCueResp, sTitle, sFile, sAlignedTo,1);
            sFile = [pathToSSPsdFolder sLabel sDay '_' NEURON_TYPE '_wNonJResp_wCS' sRangewOrwOutCS '_alignedTo' sAlignedTo];            
            plotSpectrogram(spikeRatesPre_JuiceNonRespCueResp, sTitle, sFile, sAlignedTo,1);
            %%%%% Plot Spectrum  %%%%%%%

            f = prePlot();   
            strLegend = {};
%                 indsEmpty = cellfun(@(x) cellfun(@isempty,x),cellSSJuiceRespCueNonRespCSPerMouse, UniformOutput=false);
%                 indAnyEmpty = cellfun(@all,indsEmpty);                
%                 if ~isempty(cellSSJuiceRespCueNonRespCSPerMouse) && ~all(indAnyEmpty)
            if ~isCellArraySomehowEmpty(daySSJuiceRespCueNonRespCSAllMice)
                [spikeRatesPre_JuiceRespCueNonResp, spikeRatesPost_JuiceRespCueNonResp] = ...
                plotComparisonPSTHs(daySSJuiceRespCueNonRespCSAllMice, arrModulations, {}, ...
                individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, NEURON_TYPE, [], [], [], [], 1, []);
                strLegend = {strLegend{:}, ['Paired wModCS around juice n = ' num2str(length(daySSJuiceRespCueNonRespCSAllMice))]};
            end

%                 indsEmpty = cellfun(@(x) cellfun(@isempty,x),cellSSJuiceNonRespCueNonRespCSPerMouse, UniformOutput=false);
%                 indAnyEmpty = cellfun(@all,indsEmpty);    
%                 if ~isempty(cellSSJuiceNonRespCueNonRespCSPerMouse) && ~all(indAnyEmpty)
            if ~isCellArraySomehowEmpty(daySSJuiceNonRespCueNonRespCSAllMice)
                [spikeRatesPre_JuiceNonRespCueNonResp, spikeRatesPost_JuiceNonRespCueNonResp] = ...
                plotComparisonPSTHs(daySSJuiceNonRespCueNonRespCSAllMice, arrModulations, {}, ...
                individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, NEURON_TYPE, [], [], [], [], 1, []);
                strLegend = {strLegend{:}, ['Paired wNonModCS around juice n = ' num2str(length(daySSJuiceNonRespCueNonRespCSAllMice))]};
            end   
            if ~isempty(strLegend)
                legend(strLegend);
            end
            sTitle = [NEURON_TYPE ' trials ' sRangewOrwOutCS sAddTitle];
            sFile = [pathToSSPsthFolder sLabel sDay '_' NEURON_TYPE '_wJvsNonJResp_wNOCS' sRangewOrwOutCS '_alignedTo' sAlignedTo];            
            postPlot(f, ['Time from ' sAlignedTo ' (s)'], sYLabel, -PRE_BEHAVIORAL_EVENT_PLOT, POST_BEHAVIORAL_EVENT_PLOT, MIN_YLIM, MAX_YLIM, sTitle, sFile); 
            
%                 %%%%% Plot Spectrum  %%%%%%%
%                 sFile = [pathToSSPsdFolder sLabel sDay '_' NEURON_TYPE '_wJJResp_wNOCS' sRangewOrwOutCS '_alignedTo' sAlignedTo];
%                 plotSpectrogram(spikeRatesPre_JuiceRespCueNonResp, sTitle, sFile, sAlignedTo, 1);
%                 sFile = [pathToSSPsdFolder sLabel sDay '_' NEURON_TYPE '_wNonJResp_wNOCS' sRangewOrwOutCS '_alignedTo' sAlignedTo];
%                 plotSpectrogram(spikeRatesPre_JuiceNonRespCueNonResp, sTitle, sFile, sAlignedTo, 1);
%                 %%%%% Plot Spectrum  %%%%%%%
    else % INC/DEC so plot each separetely cos it is getting complicated and hard to see in one figure
%             indsEmpty = cellfun(@(x) cellfun(@isempty,x),cellSSJuiceRespCueRespCSPerMouse, UniformOutput=false);
%             indAnyEmpty = cellfun(@all,indsEmpty);
%             if ~isempty(cellSSJuiceRespCueRespCSPerMouse) && ~all(indAnyEmpty)
          if ~isCellArraySomehowEmpty(daySSJuiceRespCueRespCSAllMice)
            callSpecificPlots(daySSJuiceRespCueRespCSAllMice, sRangewOrwOutCS, pathToSSPsthFolder, sLabel, sDay, sAlignedTo, arrModulations, ...
                {'Inc', 'Dec', 'Unmodulated'}, individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, dayDepths, sYLabel, 1, []);

            %%%% LICK CYCLE ALIGNMENT %%%%
            if NORMALIZE_X_AXIS_FOR_EACH_LICK && MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
                orgValue = FLAG_PLOT_INC_DEC;
                FLAG_PLOT_INC_DEC = 1; % To make sure it plots these group of cells seperately
                % % sinusiodal vs Ramping activity classification within Increasers
                % arrROI = zeros(1,length(isSinusoidal));
                % findPlus1s = find(arrModulations~=0 & isSinusoidal'==1); % Modulated & Sinusoidal
                % arrROI(findPlus1s) = 1;
                % findMinus1s = find(arrModulations~=0 & isSinusoidal'==-1); % Modulated & Ramping
                % arrROI(findMinus1s) = -1;
                % callSpecificPlots(daySSJuiceRespCueRespCSAllMice, sRangewOrwOutCS, pathToSSPsthFolder, sLabel, sDay, sAlignedTo, arrROI, ...
                % {'Sinusoidal', 'Others'}, individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, dayDepths, sYLabel, 1, 'SinvsRamp');

                % Within Sinusiodal: 1st vs 2nd half tuning Max activity classification within Increasers/Decreasers
                arrROI = zeros(1,size(localMaxs,1));
                arrModulationsMax = zeros(1,size(localMaxs,1));
                meanLocalMaxs = mean(localMaxs,2);
                indModulationsMax2ndhalf = find(meanLocalMaxs>1.5); % 1 or 2 (Maxs tuned to second half of the phase)
                arrModulationsMax(indModulationsMax2ndhalf) = 1;
                indModulationsMax1sthalf = find(meanLocalMaxs<1.5 & meanLocalMaxs>0);
                arrModulationsMax(indModulationsMax1sthalf) = -1;
                arrROI = -99*ones(1, size(localMaxs,1));
                findPlus1s = find(arrModulations~=0 & arrModulationsMax==1); % Positively modulated and tuned to second half of ILI
                arrROI(findPlus1s) = 1;
                findMinus1s = find(arrModulations~=0 & arrModulationsMax==-1); % Positively modulated and tuned to first half of ILI
                arrROI(findMinus1s) = -1;
                findZeros = find(arrModulations~=0 & isSinusoidal'==-1); % Modulated & Ramping
                arrROI(findZeros) = 0;
                callSpecificPlots(daySSJuiceRespCueRespCSAllMice, sRangewOrwOutCS, pathToSSPsthFolder, sLabel, sDay, sAlignedTo, arrROI, ...
                {'Sin2ndHalfMax', 'Sin1stHalfMax', 'Others'}, individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, dayDepths, sYLabel, 1, 'Sin1stvs2ndHalfMaxTuningvsRamping');
               
                % Within Sinusiodal: 1st vs 2nd half tuning Min activity classification within Increasers/Decreasers
                arrROI = zeros(1,size(localMins,1));
                arrModulationsMin = zeros(1,size(localMins,1));
                meanLocalMins = mean(localMins,2);
                indModulationsMin2ndhalf = find(meanLocalMins>1.5); % 1 or 2 (Mins tuned to second half of the phase)
                arrModulationsMin(indModulationsMin2ndhalf) = 1;
                indModulationsMin1sthalf = find(meanLocalMins<1.5 & meanLocalMins>0);
                arrModulationsMin(indModulationsMin1sthalf) = -1;
                arrROI = -99*ones(1,size(localMins,1));
                findPlus1s = find(arrModulations~=0 & arrModulationsMin==1); % Negatively modulated and tuned to second half of ILI
                arrROI(findPlus1s) = 1;
                findMinus1s = find(arrModulations~=0 & arrModulationsMin==-1); % Negatively modulated and tuned to first half of ILI
                arrROI(findMinus1s) = -1;
                findZeros = find(arrModulations~=0 & isSinusoidal'==-1); % Modulated & Ramping
                arrROI(findZeros) = 0;
                callSpecificPlots(daySSJuiceRespCueRespCSAllMice, sRangewOrwOutCS, pathToSSPsthFolder, sLabel, sDay, sAlignedTo, arrROI, ...
                {'Sin2ndHalfMin', 'Sin1stHalfMin', 'Others'}, individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, dayDepths, sYLabel, 1, 'Sin1stvs2ndHalfMinTuningvsRamping');
                FLAG_PLOT_INC_DEC = orgValue;
            end
          end
        
%             indsEmpty = cellfun(@(x) cellfun(@isempty,x),cellSSJuiceNonRespCueRespCSPerMouse, UniformOutput=false);
%             indAnyEmpty = cellfun(@all,indsEmpty);
%             if ~isempty(cellSSJuiceNonRespCueRespCSPerMouse) && ~all(indAnyEmpty)
          if ~isCellArraySomehowEmpty(daySSJuiceNonRespCueRespCSAllMice)
              callSpecificPlots(daySSJuiceNonRespCueRespCSAllMice, sRangewOrwOutCS, pathToSSPsthFolder, sLabel, sDay, sAlignedTo, arrModulations, ...
                'Inc', 'Dec', individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, dayDepths, sYLabel, 1, []);
          end           
        
%             sTitle = [NEURON_TYPE ' trials ' sRangewOrwOutCS ' wNonModCS around juice n = ' num2str(length(daySSJuiceNonRespCueRespCSAllMice)) ' ' sAddTitle];
%             sFile = [pathToSSPsdFolder sLabel sDay '_' NEURON_TYPE '_wNonJResp_wCS' sRangewOrwOutCS '_alignedTo' sAlignedTo];            
%             plotSpectrogram(spikeRatesPre_JuiceNonRespCueResp, sTitle, sFile, sAlignedTo, 1);
        %%%%% Plot Spectrum  %%%%%%%
        
%             indsEmpty = cellfun(@(x) cellfun(@isempty,x),cellSSJuiceRespCueNonRespCSPerMouse, UniformOutput=false);
%             indAnyEmpty = cellfun(@all,indsEmpty);
%             if ~isempty(cellSSJuiceRespCueNonRespCSPerMouse) && ~all(indAnyEmpty)
          if ~isCellArraySomehowEmpty(daySSJuiceRespCueNonRespCSAllMice)
              callSpecificPlots(daySSJuiceRespCueNonRespCSAllMice, sRangewOrwOutCS, pathToSSPsthFolder, sLabel, sDay, sAlignedTo, arrModulations, ...
                'Inc', 'Dec', individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, dayDepths, sYLabel, 1, []);
          end
%             end

%             indsEmpty = cellfun(@(x) cellfun(@isempty,x),cellSSJuiceNonRespCueNonRespCSPerMouse, UniformOutput=false);
%             indAnyEmpty = cellfun(@all,indsEmpty);
%             if ~isempty(cellSSJuiceNonRespCueNonRespCSPerMouse) && ~all(indAnyEmpty)
          if ~isCellArraySomehowEmpty(daySSJuiceNonRespCueNonRespCSAllMice)
              callSpecificPlots(daySSJuiceNonRespCueNonRespCSAllMice, sRangewOrwOutCS, pathToSSPsthFolder, sLabel, sDay, sAlignedTo, arrModulations, ...
                'Inc', 'Dec', individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, dayDepths, sYLabel, 1, []); 
          end            
        
            % %%%%% Plot Spectrum  %%%%%%%
            % sTitle = [NEURON_TYPE ' trials ' sRangewOrwOutCS ' wModCS around juice n = ' num2str(length(daySSJuiceRespCueNonRespCSAllMice)) ' ' sAddTitle];
            % sFile = [pathToSSPsdFolder sLabel sDay '_' NEURON_TYPE '_wJResp_wNOCS' sRangewOrwOutCS '_alignedTo' sAlignedTo];
            % plotSpectrogram(spikeRatesPre_JuiceRespCueNonResp, sTitle, sFile, sAlignedTo, 1);
            % sTitle = [NEURON_TYPE ' trials ' sRangewOrwOutCS ' wNonModCS around juice n = ' num2str(length(daySSJuiceNonRespCueNonRespCSAllMice)) ' ' sAddTitle];
            % sFile = [pathToSSPsdFolder sLabel sDay '_' NEURON_TYPE '_wNonJResp_wNOCS' sRangewOrwOutCS '_alignedTo' sAlignedTo];
            % plotSpectrogram(spikeRatesPre_JuiceNonRespCueNonResp, sTitle, sFile, sAlignedTo, 1);
            % %%%%% Plot Spectrum  %%%%%%%

    end

    if ~isempty(dayCSNonResponsiveAllMice) 
        if FLAG_PLOT_CS
            sTitle = [NEURON_TYPE_CS ' (n=' num2str(length(dayCSNonResponsiveAllMice)) ') ' sRangewOrwOutCS sAddTitle ];
            sFirstLast = '';
            if FIRST_VS_LAST
                sTitle = [sTitle ' non-responsive for the first ' num2str(TRIALS_FIRST) ' vs last ' num2str(TRIALS_TO_COMPARE) ' trials)'];
                sFirstLast = ['_firstVSlast' num2str(TRIALS_TO_COMPARE)];
            end
            sFile = [pathToCSPsthFolder sLabel sDay sFirstLast '_' NEURON_TYPE_CS '_' sRangewOrwOutCS '_NonResp_alignedTo' sAlignedTo];    
            
            plotComparisonPSTHs(dayCSNonResponsiveAllMice, arrModulations, {}, ...
                individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, NEURON_TYPE_CS, sTitle, sFile, ['Time from ' sAlignedTo ' (s)'], [], 0, []);

            respondingToRewOnly = sum(arrModulationMagnitudeRewNonRespCS~=0 & arrModulationMagnitudeCueNonRespCS==0);
            respondingToCueOnly = sum(arrModulationMagnitudeCueNonRespCS~=0 & arrModulationMagnitudeRewNonRespCS==0);
            respondingToRewCue = sum(arrModulationMagnitudeRewNonRespCS~=0 & arrModulationMagnitudeCueNonRespCS~=0);
            total = respondingToRewOnly + respondingToCueOnly + respondingToRewCue;            
            plotPie([length(dayCSNonResponsiveAllMice)-total respondingToRewOnly respondingToCueOnly respondingToRewCue], ...
                {'', 'OnlyRewResp','OnlyCueResp','CueRewResp'}, ...
                [COLORS(8,1:3); COLORS(1,1:3); COLOR_BLIND_FRIENDLY_GREEN; COLORS(3,1:3)], ...
                [sLabel sDay 'NonRespCS'], pathToCSPsthFolder);
        end
    end
end