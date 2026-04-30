%%%% PLOT PSTH %%%%%%%%%%%%
% spikeTimesAligned: Spike times in sec
%
% SO 4/18/2025 Hull Lab
function [meanSpikeRate, indInc, indDec, plt, arrModulationMagnitudeRew, arrModulationMagnitudeCue, integralValuesAfterRew, onsetPoint] = ...
    plotPSTH(cellSpikeTimes, sTitle, sFile, sColor, bTrialSlice, bSuperImpose, allLicks, lickOnsets, cueTimes)
        globals;

        plt = [];        
        indInc = [];
        indDec = [];
        integralValuesAfterRew = zeros(1,length(cellSpikeTimes));
        onsetPoint = -99*ones(1,length(cellSpikeTimes));

        edgesPlt = EDGES(1:end-1)+(EDGES(2)-EDGES(1))/2;
        edgesLickPlt = EDGES_LICK(1:end-1)+(EDGES_LICK(2)-EDGES_LICK(1))/2;
        totalBinCounts = zeros(1,length(EDGES)-1);

        indsBaseline = find(EDGES>=BASELINE_RANGE(1)&EDGES<=BASELINE_RANGE(2));
        indsModulationRangeRew = find(EDGES>=MODULATION_RANGE_FOR_REWARD(1)&EDGES<=MODULATION_RANGE_FOR_REWARD(2));
        indsModulationRangeCue = find(EDGES>=MODULATION_RANGE_FOR_CUE(1)&EDGES<=MODULATION_RANGE_FOR_CUE(2));
        
        yForLickOnset = MIN_SS+abs(MIN_SS)*.1;

        slicedSpikeTimes = {};
        for ind=1:length(cellSpikeTimes) % go through all units for the one recording day
            individualUnitSpikes = cellSpikeTimes{ind};
            trialCount = length(individualUnitSpikes);
            if bTrialSlice==1       % First part                
                len = min(trialCount,TRIALS_FIRST);
                slicedUnitSpikes = individualUnitSpikes(1:len);
            elseif bTrialSlice==0   % Last part
                if trialCount>(TRIALS_TO_COMPARE+TRIALS_TO_TRIM)
                    trialSlice = [trialCount-TRIALS_TO_COMPARE-TRIALS_TO_TRIM:trialCount-TRIALS_TO_TRIM];
                else
                    trialSlice = [1:trialCount];
                end
                slicedUnitSpikes = individualUnitSpikes(trialSlice);
            elseif bTrialSlice==-1 % No Slicing, use whole trials
                slicedUnitSpikes = individualUnitSpikes;
            end
            slicedSpikeTimes{length(slicedSpikeTimes)+1} = slicedUnitSpikes;
        end

        slicedLicks = {};
        slicedLickOnsets = {};
        slicedCueTimes = {};
        if ~isempty(allLicks)           
            for ind=1:length(allLicks) % go through all units for the one recording day
                individualLicks = allLicks{ind};
                individualLickOnset = lickOnsets{ind};
                individualCueTime = cueTimes{ind};
                trialCount = length(individualLicks);
                if bTrialSlice==1       % First part                
                    len = min(trialCount,TRIALS_FIRST);
                    slicedLick = individualLicks(1:len);
                    slicedLickOnset = individualLickOnset(1:len);
                    slicedCueTime = individualCueTime(1:len);
                elseif bTrialSlice==0   % Last part
                    if trialCount>(TRIALS_TO_COMPARE+TRIALS_TO_TRIM)
                        trialSlice = [trialCount-TRIALS_TO_COMPARE-TRIALS_TO_TRIM:trialCount-TRIALS_TO_TRIM];
                    else
                        trialSlice = [1:trialCount];
                    end
                    slicedLick = individualLicks(trialSlice);
                    slicedLickOnset = individualLickOnset(trialSlice);
                    slicedCueTime = individualCueTime(trialSlice);
                elseif bTrialSlice==-1 % No Slicing, use whole trials
                    slicedLick = individualLicks;
                    slicedLickOnset = individualLickOnset;
                    slicedCueTime = individualCueTime;
                end
                slicedLicks{length(slicedLicks)+1} = slicedLick;
                slicedLickOnsets{length(slicedLickOnsets)+1} = slicedLickOnset;
                slicedCueTimes{length(slicedCueTimes)+1} = slicedCueTime;
            end
        end

        individualSpikeRates = zeros(length(slicedSpikeTimes),length(EDGES)-1);
        for ind=1:length(slicedSpikeTimes) % go through all units for the one recording day
            trialCount = length(slicedSpikeTimes{ind});
            individualSpikeTimes = slicedSpikeTimes{ind};            
            arrSpikeTimes = cell2mat(individualSpikeTimes');
            binCounts = histcounts(arrSpikeTimes,EDGES); % optimumBinCount);            
            individualSpikeRates(ind,:) = binCounts/(trialCount*BIN_SIZE_PSTH);
%             totalBinCounts = totalBinCounts + binCounts/(trialCount*BIN_SIZE_PSTH);
        end

        individualLickRates = zeros(length(slicedLicks),length(EDGES_LICK)-1);
        arrLickOnsets = [];
        arrCues = [];
        for ind=1:length(slicedLicks) % go through all units for the one recording day
            trialCount = length(slicedLicks{ind});
            individualLicks = slicedLicks{ind};            
            arrLickTimes = cell2mat(individualLicks');            
            binCounts = histcounts(arrLickTimes,EDGES_LICK); % optimumBinCount);            
            individualLickRates(ind,:) = binCounts/(trialCount*BIN_SIZE_LICK);
            
            arrLickOnsets = [arrLickOnsets cell2mat(slicedLickOnsets{ind})];
            arrCues = [arrCues cell2mat(slicedCueTimes{ind})];
        end
        
        meanSpikeRate = mean(individualSpikeRates,1,'omitnan'); %totalBinCounts/length(slicedSpikeTimes); 
        meanLickRate = mean(individualLickRates,1,'omitnan');
        arrLickOnsets = arrLickOnsets(arrLickOnsets>-PRE_BEHAVIORAL_EVENT & arrLickOnsets<POST_BEHAVIORAL_EVENT);
        meanLickOnsets = mean(arrLickOnsets);
        semLickOnsets = std(arrLickOnsets)/sqrt(length(arrLickOnsets));

        arrCues = arrCues(arrCues>-PRE_BEHAVIORAL_EVENT & arrCues<POST_BEHAVIORAL_EVENT);
        meanCues = mean(arrCues);
        semCues = std(arrCues)/sqrt(length(arrCues));
                                        % averaged over trials, over # of cells and specified bin size
                
        %%%%%%%%%%%%%%%%%%%%%% PSTH - Spikes with Behavioral Event Aligned %%%%%%%%%%%%%%%%%%%        

        if ~bSuperImpose
            prePlot();            
        end

        arrModulations = zeros(1,size(individualSpikeRates,1));
        arrModulationMagnitudeRew = zeros(1,size(individualSpikeRates,1));
        arrModulationMagnitudeCue = zeros(1,size(individualSpikeRates,1));

        % Only ZScores SSs
        if FLAG_Z_SCORE && bTrialSlice==-1 % Can only Z-scores without any slicing, otherwise dividing cells into two classes (Increasing/Decreasing) getting complicated

            zScoredSpikeRates = zeros(length(slicedSpikeTimes),length(EDGES)-1);
            for ind=1:size(individualSpikeRates,1)
                individualSpikeRate = individualSpikeRates(ind,:);
                baselineSpikeRate = individualSpikeRate(indsBaseline);                
                        
                zScoredSpikeRates(ind,:) = (individualSpikeRate-mean(baselineSpikeRate))/std(baselineSpikeRate);

                % First smooth then check Inc/Dec otherwise positive fluctuations dominating and causing no Decreasers!
                smtIndividualSpikeRate = smooth(edgesPlt,zScoredSpikeRates(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
                baselineSpikeRate = smtIndividualSpikeRate(indsBaseline);                
                modulationRangeSpikeRateRew = smtIndividualSpikeRate(indsModulationRangeRew);
                modulationRangeSpikeRateCue = smtIndividualSpikeRate(indsModulationRangeCue);

                zScoredSpikeRatesModulationRew = (modulationRangeSpikeRateRew-mean(baselineSpikeRate))/std(baselineSpikeRate);
                zScoredSpikeRatesModulationCue = (modulationRangeSpikeRateCue-mean(baselineSpikeRate))/std(baselineSpikeRate);
                zScoredSpikeRatesBaseline = (baselineSpikeRate-mean(baselineSpikeRate))/std(baselineSpikeRate);
                stdLevel = STD_LEVEL_FOR_RESPONSIVENESS*std(zScoredSpikeRatesBaseline); 
                whichOneRew = abs(zScoredSpikeRatesModulationRew)>=stdLevel; % absolute suppression or activation amount should be bigger than 5*STD
                maxResponseRew = max(zScoredSpikeRatesModulationRew(whichOneRew));
                minResponseRew = min(zScoredSpikeRatesModulationRew(whichOneRew));                
                if abs(maxResponseRew)>abs(minResponseRew) % Decide according to strongest response
                    arrModulations(ind) = 1;    
                    arrModulationMagnitudeRew(ind) = maxResponseRew;
                elseif abs(maxResponseRew)<abs(minResponseRew)
                    arrModulations(ind) = -1;
                    arrModulationMagnitudeRew(ind) = minResponseRew;
                elseif any(zScoredSpikeRatesModulationRew(whichOneRew)>0) % Activation
                    arrModulations(ind) = 1;    
                    arrModulationMagnitudeRew(ind) = maxResponseRew;
                elseif any(zScoredSpikeRatesModulationRew(whichOneRew)<0) % Suppression
                    arrModulations(ind) = -1;
                    arrModulationMagnitudeRew(ind) = minResponseRew;
                end

                whichOneCue = abs(zScoredSpikeRatesModulationCue)>=stdLevel; % absolute suppression or activation amount should be bigger than 5*STD
                maxResponseCue = max(zScoredSpikeRatesModulationCue(whichOneCue));
                minResponseCue = min(zScoredSpikeRatesModulationCue(whichOneCue));                
                if abs(maxResponseCue)>abs(minResponseCue) % Decide according to strongest response
%                     arrModulations(ind) = 1;    
                    arrModulationMagnitudeCue(ind) = maxResponseCue;
                elseif abs(maxResponseCue)<abs(minResponseCue)
%                     arrModulations(ind) = -1;
                    arrModulationMagnitudeCue(ind) = minResponseCue;
                elseif any(zScoredSpikeRatesModulationCue(whichOneCue)>0) % Activation
%                     arrModulations(ind) = 1;    
                    arrModulationMagnitudeCue(ind) = maxResponseCue;
                elseif any(zScoredSpikeRatesModulationCue(whichOneCue)<0) % Suppression
%                     arrModulations(ind) = -1;
                    arrModulationMagnitudeCue(ind) = minResponseCue;
                end
            end

            if FLAG_PLOT_INDIVIDUAL_CELLS
%                 indColors = randperm(size(COLORS,1)); % pick random colors for individual cells
                f = prePlot();
                for ind=1:size(zScoredSpikeRates,1)
                    smtZScoredSpikeRates = smooth(edgesPlt,zScoredSpikeRates(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
                    if arrModulationMagnitudeCue(ind)>0 % if Increasing or Decreasing its firing rate                        
                        plot(edgesPlt, smtZScoredSpikeRates, 'LineWidth',1, 'Color', [.8 0 0 0.8]); %COLORS(indColors(mod(ind,length(indColors)-1)+1),:));
                    elseif arrModulationMagnitudeCue(ind)<0
                        plot(edgesPlt, smtZScoredSpikeRates, 'LineWidth',1, 'Color', [0 0 .8 0.8]);
                    end                    
                end
                postPlot(f, 'Time (s)', 'Spikes/s', -PRE_BEHAVIORAL_EVENT_PLOT, POST_BEHAVIORAL_EVENT_PLOT, [], [], sTitle, [sFile '_IndividualCueMod']);

                f = prePlot();
                for ind=1:size(zScoredSpikeRates,1)
                    smtZScoredSpikeRates = smooth(edgesPlt,zScoredSpikeRates(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
                    if arrModulationMagnitudeRew(ind)>0 % if Increasing or Decreasing its firing rate                        
                        plot(edgesPlt, smtZScoredSpikeRates, 'LineWidth',1, 'Color', [.8 0 0 0.8]); %COLORS(indColors(mod(ind,length(indColors)-1)+1),:));
                    elseif arrModulationMagnitudeRew(ind)<0
                        plot(edgesPlt, smtZScoredSpikeRates, 'LineWidth',1, 'Color', [0 0 .8 0.8]);
                    end                    
                end
                postPlot(f, 'Time (s)', 'Spikes/s', -PRE_BEHAVIORAL_EVENT_PLOT, POST_BEHAVIORAL_EVENT_PLOT, [], [], sTitle, [sFile '_IndividualRewMod']);
            end
            
            for ind=1:size(zScoredSpikeRates,1)
                smtIndividualSpikeRates = smooth(edgesPlt,zScoredSpikeRates(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
                indsIntegral = find(edgesPlt>=0 & edgesPlt<.2);
                values = smtIndividualSpikeRates(indsIntegral);
                integralValuesAfterRew(ind) = sum(values);
            end

            for ind=1:size(zScoredSpikeRates,1)
                smtZScoredSpikeRates = smooth(edgesPlt,zScoredSpikeRates(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
                smtZScoredSpikeRates = smooth(edgesPlt,zScoredSpikeRates(1,:), SPIKE_SPAN, SMOOTH_TYPE_L);
                [peak, pos] = max(abs(smtZScoredSpikeRates));
                indOnset = find(abs(smtZScoredSpikeRates(1:pos))>peak/2,1); % find the 1/2th of the ramping timepoint                
                onsetPoint(ind) = edgesPlt(indOnset);
            end

            meanSpikeRate = nanmean(zScoredSpikeRates,1);            

            if FLAG_PLOT_INC_DEC
                indInc = find(arrModulations==1);
                meanSpikeRateInc = mean(zScoredSpikeRates(indInc,:),1);
                smtSpikeRatesInc = smooth(edgesPlt,meanSpikeRateInc, SPIKE_SPAN, SMOOTH_TYPE_L);
                    
                indDec = find(arrModulations==-1);
                meanSpikeRateDec = mean(zScoredSpikeRates(indDec,:),1);
                smtSpikeRatesDec = smooth(edgesPlt,meanSpikeRateDec, SPIKE_SPAN, SMOOTH_TYPE_L);
                
                if FLAG_ERROR_BARS
                    hold on; % some nonsese duplication - old figure looses hold-on once we plot individual plots in between creating a plot and plotting the curves afterwards
                    % PUT ERROR BARS FOR INCREASERS
                    semSpikeRatesInc = std(zScoredSpikeRates(indInc,:),'omitnan')/sqrt(size(zScoredSpikeRates(indInc,:),1));
                    earlyLowerBoundSpikeRatesInc = meanSpikeRateInc - semSpikeRatesInc;
                    earlyUpperBoundSpikeRatesInc = meanSpikeRateInc + semSpikeRatesInc;
                    
                    smtEarlyLowerBoundSpikeRatesInc = smooth(edgesPlt,earlyLowerBoundSpikeRatesInc, SPIKE_SPAN, SMOOTH_TYPE_L)';
                    smtEarlyUpperBoundSpikeRatesInc = smooth(edgesPlt,earlyUpperBoundSpikeRatesInc, SPIKE_SPAN, SMOOTH_TYPE_L)';
                    inBetween = [smtEarlyUpperBoundSpikeRatesInc, fliplr(smtEarlyLowerBoundSpikeRatesInc)];
                    x2 = [edgesPlt, fliplr(edgesPlt)];
                    fill(x2, inBetween, 'k', 'FaceColor', COLOR_BLIND_FRIENDLY_RED, 'EdgeColor', 'none', 'FaceAlpha', ALPHA_LIGHT); %, 'EdgeAlpha',ALPHA_EDGE);                    
                                                          % sColor(1:end-1)
                    % PUT ERROR BARS FOR DECREASERS
                    semSpikeRatesDec = std(zScoredSpikeRates(indDec,:),'omitnan')/sqrt(size(zScoredSpikeRates(indDec,:),1));
                    earlyLowerBoundSpikeRatesDec = meanSpikeRateDec - semSpikeRatesDec;
                    earlyUpperBoundSpikeRatesDec = meanSpikeRateDec + semSpikeRatesDec;
                    
                    smtEarlyLowerBoundSpikeRatesDec = smooth(edgesPlt,earlyLowerBoundSpikeRatesDec, SPIKE_SPAN, SMOOTH_TYPE_L)';
                    smtEarlyUpperBoundSpikeRatesDec = smooth(edgesPlt,earlyUpperBoundSpikeRatesDec, SPIKE_SPAN, SMOOTH_TYPE_L)';
                    inBetween = [smtEarlyUpperBoundSpikeRatesDec, fliplr(smtEarlyLowerBoundSpikeRatesDec)];
                    x2 = [edgesPlt, fliplr(edgesPlt)];
                    fill(x2, inBetween, 'k', 'FaceColor', COLOR_BLIND_FRIENDLY_BLUE, 'EdgeColor', 'none', 'FaceAlpha', ALPHA_LIGHT); %, 'EdgeAlpha',ALPHA_EDGE);
                    %pause(0.5);                            % [.1 0 .9]
                end

                if ~isempty(indInc)
                    plt(1) = plot(edgesPlt, smtSpikeRatesInc, 'LineWidth',2, 'Color', [COLOR_BLIND_FRIENDLY_RED ALPHA]) ; %[.8 .1 .2 ALPHA]);
                end
                if ~isempty(indDec)
                    plt(2) = plot(edgesPlt, smtSpikeRatesDec, 'LineWidth',2, 'Color', [COLOR_BLIND_FRIENDLY_BLUE ALPHA]); %[.1 0 .9 ALPHA]);
                end
            else
                smtSpikeRates = smooth(edgesPlt,meanSpikeRate, SPIKE_SPAN, SMOOTH_TYPE_L);
                hold on;
                plot(edgesPlt, smtSpikeRates, 'LineWidth',2.5, 'Color', COLOR_BLIND_FRIENDLY_PURPLE); %sColor);
            end
            
            if ~isempty(slicedLicks) && PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES == PLOT_LICK_RATE
                yyaxis right                    
                meanLickRates = mean(individualLickRates,1);
                semLickRates = std(individualLickRates,'omitnan')/sqrt(size(individualLickRates,1));
                earlyLowerBoundSpikeRatesInc = meanLickRates - semLickRates;
                earlyUpperBoundSpikeRatesInc = meanLickRates + semLickRates;
                inBetween = [earlyUpperBoundSpikeRatesInc, fliplr(earlyLowerBoundSpikeRatesInc)];
                x2 = [edgesLickPlt, fliplr(edgesLickPlt)];
                fill(x2, inBetween, 'k', 'FaceColor', COLOR_BLIND_FRIENDLY_GREEN, 'EdgeColor', 'none', 'FaceAlpha', ALPHA_LIGHT); %, 'EdgeAlpha',ALPHA_EDGE);
                %pause(0.5);                            % [0 .5 .5]
                plot(edgesLickPlt, meanLickRates, 'LineWidth',1.5, 'Color', [COLOR_BLIND_FRIENDLY_GREEN ALPHA],'LineStyle','-');
%                     ax = gca;                                                % [0 .5 .5 ALPHA]
%                     ax.YAxis(2). Color = [0.9 0.9 0.9];
                if max(meanLickRates)>0
                    ylim([0 max(meanLickRates)*2]);
                end
                ylabel('Lick rate/s');
                yyaxis left
            elseif PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES == PLOT_LICK_ONSETS
                errorbar(meanLickOnsets,yForLickOnset,semLickOnsets,"horizontal","o","MarkerSize",8,...
                    "MarkerEdgeColor","black","MarkerFaceColor",[0 0 0], 'CapSize',18, 'LineWidth',1, 'Color','k');
            elseif PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES == PLOT_CUE_TIMES
                errorbar(meanCues,yForLickOnset,semCues,"horizontal","o","MarkerSize",8,...
                    "MarkerEdgeColor","black","MarkerFaceColor",[0 0 0], 'CapSize',18, 'LineWidth',1, 'Color','k');
            end
        else
            for ind=1:size(individualSpikeRates,1)
                individualSpikeRate = individualSpikeRates(ind,:);
                
                smtIndividualSpikeRate = smooth(edgesPlt,individualSpikeRate, SPIKE_SPAN, SMOOTH_TYPE_L);
                baselineSpikeRate = smtIndividualSpikeRate(indsBaseline);                
                modulationRangeSpikeRateRew = smtIndividualSpikeRate(indsModulationRangeRew);
                modulationRangeSpikeRateCue = smtIndividualSpikeRate(indsModulationRangeCue);
                       
                zScoredSpikeRatesModulationRew = (modulationRangeSpikeRateRew-mean(baselineSpikeRate))/std(baselineSpikeRate);
                zScoredSpikeRatesModulationCue = (modulationRangeSpikeRateCue-mean(baselineSpikeRate))/std(baselineSpikeRate);
                zScoredSpikeRatesBaseline = (baselineSpikeRate-mean(baselineSpikeRate))/std(baselineSpikeRate);
                stdLevel = STD_LEVEL_FOR_RESPONSIVENESS*std(zScoredSpikeRatesBaseline); 
                whichOneRew = abs(zScoredSpikeRatesModulationRew)>=stdLevel; % absolute suppression or activation amount should be bigger than 5*STD
                maxResponseRew = max(zScoredSpikeRatesModulationRew(whichOneRew));
                maxResponseRewOrg = max(modulationRangeSpikeRateRew(whichOneRew));
                minResponseRew = min(zScoredSpikeRatesModulationRew(whichOneRew));                
                minResponseRewOrg = min(modulationRangeSpikeRateRew(whichOneRew));
                whichOneCue = abs(zScoredSpikeRatesModulationCue)>=stdLevel; % absolute suppression or activation amount should be bigger than 5*STD
                maxResponseCue = max(zScoredSpikeRatesModulationCue(whichOneCue));
                maxResponseCueOrg = max(modulationRangeSpikeRateCue(whichOneCue));
                minResponseCue = min(zScoredSpikeRatesModulationCue(whichOneCue));
                minResponseCueOrg = min(modulationRangeSpikeRateCue(whichOneCue));
                
                if abs(maxResponseRew)>abs(minResponseRew) % Decide according to strongest response
                    arrModulations(ind) = 1;    
                    arrModulationMagnitudeRew(ind) = maxResponseRew;
                elseif abs(maxResponseRew)<abs(minResponseRew)
                    arrModulations(ind) = -1;
                    arrModulationMagnitudeRew(ind) = minResponseRew;
                elseif any(modulationRangeSpikeRateRew(whichOneRew)>0) % Activation
                    arrModulations(ind) = 1;    
                    arrModulationMagnitudeRew(ind) = maxResponseRew;
                elseif any(modulationRangeSpikeRateRew(whichOneRew)<0) % Suppression
                    arrModulations(ind) = -1;
                    arrModulationMagnitudeRew(ind) = minResponseRew;
                end

                if abs(maxResponseCue)>abs(minResponseCue) % Decide according to strongest response
%                     arrModulations(ind) = 1;    
                    arrModulationMagnitudeCue(ind) = maxResponseCue;
                elseif abs(maxResponseCue)<abs(minResponseCue)
%                     arrModulations(ind) = -1;
                    arrModulationMagnitudeCue(ind) = minResponseCue;
                elseif any(modulationRangeSpikeRateCue(whichOneCue)>0) % Activation
%                     arrModulations(ind) = 1;    
                    arrModulationMagnitudeCue(ind) = maxResponseCue;
                elseif any(modulationRangeSpikeRateCue(whichOneCue)<0) % Suppression
%                     arrModulations(ind) = -1;
                    arrModulationMagnitudeCue(ind) = minResponseCue;
                end
            end

            if FLAG_PLOT_INDIVIDUAL_CELLS
                indColors = randperm(size(COLORS,1)); % pick random colors for individual cells
                for ind=1:size(individualSpikeRates,1)
                    smtIndividualSpikeRates = smooth(edgesPlt,individualSpikeRates(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
                    plot(edgesPlt, smtIndividualSpikeRates, 'LineWidth',1, 'Color', COLORS(indColors(mod(ind,length(indColors)-1)+1),:));
                end
            end

            for ind=1:size(individualSpikeRates,1)
                smtIndividualSpikeRates = smooth(edgesPlt,individualSpikeRates(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
                indsIntegral = find(edgesPlt>=0 & edgesPlt<.2);
                values = smtIndividualSpikeRates(indsIntegral);
                integralValuesAfterRew(ind) = sum(values);
            end

            for ind=1:size(individualSpikeRates,1)
                smtZScoredSpikeRates = smooth(edgesPlt,individualSpikeRates(ind,:), SPIKE_SPAN, SMOOTH_TYPE_L);
                [peak, pos] = max(abs(smtZScoredSpikeRates));
                indOnset = find(abs(smtZScoredSpikeRates(1:pos))>peak/2,1); % find the 1/2th of the ramping timepoint                
                onsetPoint(ind) = edgesPlt(indOnset);
            end

            if FLAG_PLOT_INC_DEC                

                indInc = find(arrModulations==1);
                meanSpikeRateInc = mean(individualSpikeRates(indInc,:),1);
                smtSpikeRatesInc = smooth(edgesPlt,meanSpikeRateInc, SPIKE_SPAN, SMOOTH_TYPE_L);
                    
                indDec = find(arrModulations==-1);
                meanSpikeRateDec = mean(individualSpikeRates(indDec,:),1);
                smtSpikeRatesDec = smooth(edgesPlt,meanSpikeRateDec, SPIKE_SPAN, SMOOTH_TYPE_L);                
                
                if FLAG_ERROR_BARS
                    % PUT ERROR BARS FOR INCREASERS
                    semSpikeRatesInc = std(individualSpikeRates(indInc,:),'omitnan')/sqrt(size(individualSpikeRates(indInc,:),1));
                    earlyLowerBoundSpikeRatesInc = meanSpikeRateInc - semSpikeRatesInc;
                    earlyUpperBoundSpikeRatesInc = meanSpikeRateInc + semSpikeRatesInc;
                    
                    smtEarlyLowerBoundSpikeRatesInc = smooth(edgesPlt,earlyLowerBoundSpikeRatesInc, SPIKE_SPAN, SMOOTH_TYPE_L)';
                    smtEarlyUpperBoundSpikeRatesInc = smooth(edgesPlt,earlyUpperBoundSpikeRatesInc, SPIKE_SPAN, SMOOTH_TYPE_L)';
                    inBetween = [smtEarlyUpperBoundSpikeRatesInc, fliplr(smtEarlyLowerBoundSpikeRatesInc)];
                    x2 = [edgesPlt, fliplr(edgesPlt)];
                    fill(x2, inBetween, 'k', 'FaceColor', COLOR_BLIND_FRIENDLY_RED, 'EdgeColor', 'none', 'FaceAlpha', ALPHA_LIGHT); %, 'EdgeAlpha',ALPHA_EDGE);                    
                    %pause(0.5);                            % sColor(1:end-1)

                    % PUT ERROR BARS FOR INCREASERS
                    semSpikeRatesDec = std(individualSpikeRates(indDec,:),'omitnan')/sqrt(size(individualSpikeRates(indDec,:),1));
                    earlyLowerBoundSpikeRatesDec = meanSpikeRateDec - semSpikeRatesDec;
                    earlyUpperBoundSpikeRatesDec = meanSpikeRateDec + semSpikeRatesDec;
                    
                    smtEarlyLowerBoundSpikeRatesDec = smooth(edgesPlt,earlyLowerBoundSpikeRatesDec, SPIKE_SPAN, SMOOTH_TYPE_L)';
                    smtEarlyUpperBoundSpikeRatesDec = smooth(edgesPlt,earlyUpperBoundSpikeRatesDec, SPIKE_SPAN, SMOOTH_TYPE_L)';
                    inBetween = [smtEarlyUpperBoundSpikeRatesDec, fliplr(smtEarlyLowerBoundSpikeRatesDec)];
                    x2 = [edgesPlt, fliplr(edgesPlt)];
                    fill(x2, inBetween, 'k', 'FaceColor', COLOR_BLIND_FRIENDLY_BLUE, 'EdgeColor', 'none', 'FaceAlpha', ALPHA_LIGHT); %, 'EdgeAlpha',ALPHA_EDGE);
                    %pause(0.5);                                % [.1 0 .9]
                end

                if ~isempty(indInc)
                    plt(1) = plot(edgesPlt, smtSpikeRatesInc, 'LineWidth',2, 'Color', [COLOR_BLIND_FRIENDLY_RED ALPHA]) ; %sColor); %[.8 .1 .2 ALPHA]);
                end
                if ~isempty(indDec)
                    plt(2) = plot(edgesPlt, smtSpikeRatesDec, 'LineWidth',2, 'Color', [COLOR_BLIND_FRIENDLY_BLUE ALPHA]); %[.1 0 .9 ALPHA]);
                end

                if ~isempty(slicedLicks) && PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES == PLOT_LICK_RATE
                    yyaxis right                    
                    meanLickRates = mean(individualLickRates,1);
                    semLickRates = std(individualLickRates,'omitnan')/sqrt(size(individualLickRates,1));
                    earlyLowerBoundSpikeRatesInc = meanLickRates - semLickRates;
                    earlyUpperBoundSpikeRatesInc = meanLickRates + semLickRates;
                    inBetween = [earlyUpperBoundSpikeRatesInc, fliplr(earlyLowerBoundSpikeRatesInc)];
                    x2 = [edgesLickPlt, fliplr(edgesLickPlt)];
                    fill(x2, inBetween, 'k', 'FaceColor', COLOR_BLIND_FRIENDLY_GREEN, 'EdgeColor', 'none', 'FaceAlpha', ALPHA_LIGHT); %, 'EdgeAlpha',ALPHA_EDGE);
                    %pause(0.5);                            % [0 .5 .5]
                    plot(edgesLickPlt, meanLickRates, 'LineWidth',1.5, 'Color', [COLOR_BLIND_FRIENDLY_GREEN ALPHA],'LineStyle','-');
%                     ax = gca;                                                 % [0 .5 .5 ALPHA]
%                     ax.YAxis(2). Color = [0.9 0.9 0.9];
%                     if max(meanLickRates)>0
                        ylim([0 14]); % 80 %max(meanLickRates)*2]);
%                     end
                    ylabel('Lick rate/s');
                    yyaxis left
                elseif PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES == PLOT_LICK_ONSETS
                    errorbar(meanLickOnsets,yForLickOnset,semLickOnsets,"horizontal","o","MarkerSize",8,...
                        "MarkerEdgeColor","black","MarkerFaceColor",[0 0 0], 'CapSize',18, 'LineWidth',1, 'Color','k');
                elseif PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES == PLOT_CUE_TIMES
                    errorbar(meanCues,yForLickOnset,semCues,"horizontal","o","MarkerSize",8,...
                        "MarkerEdgeColor","black","MarkerFaceColor",[0 0 0], 'CapSize',18, 'LineWidth',1, 'Color','k');
                end

            else
                meanSpikeRate = mean(individualSpikeRates,1,'omitnan');
                smtSpikeRates = smooth(edgesPlt,meanSpikeRate, SPIKE_SPAN, SMOOTH_TYPE_L);           

                if FLAG_ERROR_BARS
                    % PUT ERROR BARS
                    semSpikeRates = std(individualSpikeRates,'omitnan')/sqrt(size(individualSpikeRates,1));
                    earlyLowerBoundSpikeRates = meanSpikeRate - semSpikeRates;
                    earlyUpperBoundSpikeRates = meanSpikeRate + semSpikeRates;
                    
                    smtEarlyLowerBoundSpikeRates = smooth(edgesPlt,earlyLowerBoundSpikeRates, SPIKE_SPAN, SMOOTH_TYPE_L)';
                    smtEarlyUpperBoundSpikeRates = smooth(edgesPlt,earlyUpperBoundSpikeRates, SPIKE_SPAN, SMOOTH_TYPE_L)';
                    inBetween = [smtEarlyUpperBoundSpikeRates, fliplr(smtEarlyLowerBoundSpikeRates)];
                    x2 = [edgesPlt, fliplr(edgesPlt)];
                    fill(x2, inBetween, 'k', 'FaceColor', COLOR_BLIND_FRIENDLY_PURPLE, 'EdgeColor', 'none', 'FaceAlpha', ALPHA_LIGHT); %, 'EdgeAlpha',ALPHA_EDGE); %                  
                    %pause(0.5);                            % sColor(1:end-1)
                end
                plt(1) = plot(edgesPlt, smtSpikeRates, 'LineWidth',2.5, 'Color', COLOR_BLIND_FRIENDLY_PURPLE); %sColor);

                if ~isempty(slicedLicks) && PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES == PLOT_LICK_RATE
                    yyaxis right                    
                    meanLickRates = mean(individualLickRates,1);
                    semLickRates = std(individualLickRates,'omitnan')/sqrt(size(individualLickRates,1));
                    earlyLowerBoundSpikeRatesInc = meanLickRates - semLickRates;
                    earlyUpperBoundSpikeRatesInc = meanLickRates + semLickRates;
                    inBetween = [earlyUpperBoundSpikeRatesInc, fliplr(earlyLowerBoundSpikeRatesInc)];
                    x2 = [edgesLickPlt, fliplr(edgesLickPlt)];
                    fill(x2, inBetween, 'k', 'FaceColor', COLOR_BLIND_FRIENDLY_GREEN, 'EdgeColor', 'none', 'FaceAlpha', ALPHA_LIGHT); %, 'EdgeAlpha',ALPHA_EDGE);
                    %pause(0.5);                            % [0 .5 .5]
                    plot(edgesLickPlt, meanLickRates, 'LineWidth',1.5, 'Color', [COLOR_BLIND_FRIENDLY_GREEN ALPHA],'LineStyle','-');
%                     ax = gca;                                                     % [0 .5 .5 ALPHA]
%                     ax.YAxis(2). Color = [0.9 0.9 0.9];
%                     if max(meanLickRates)>0
                        ylim([0 14]); %max(meanLickRates)*2]);
%                     end
                    ylabel('Lick rate/s');
                    yyaxis left
                elseif PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES == PLOT_LICK_ONSETS                    
                    errorbar(meanLickOnsets,yForLickOnset,semLickOnsets,"horizontal","o","MarkerSize",8,...
                        "MarkerEdgeColor","black","MarkerFaceColor",[0 0 0], 'CapSize',18, 'LineWidth',1, 'Color','k');
                elseif PLOT_LICK_RATE_OR_LICK_ONSETS_OR_CUE_TIMES == PLOT_CUE_TIMES                    
                    errorbar(meanCues,yForLickOnset,semCues,"horizontal","o","MarkerSize",8,...
                        "MarkerEdgeColor","black","MarkerFaceColor",[0 0 0], 'CapSize',18, 'LineWidth',1, 'Color','k');
                end
            end            
        end

        if ~bSuperImpose
            postPlot([], 'Time (s)', 'Spikes/s', -PRE_BEHAVIORAL_EVENT_PLOT, POST_BEHAVIORAL_EVENT_PLOT, [], [], [sTitle ' FR=' num2str(mean(meanSpikeRate),'%.2f') ' spk/s'], sFile);
        end
      
end