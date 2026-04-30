function flagResponsive = isResponsive(unitCSTimeStamps, recordingDayTrials, pathToFolder, sMouseId, sLabel, day, unitID)

        globals;

        if FLAG_CS_RESP_NONRESP

            flagResponsive = -99;
            if FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS == FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_MONO
                indsSelectedTrials = ismember({recordingDayTrials.TrialType},TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS);
                recordingDayTrialsSelected = recordingDayTrials(indsSelectedTrials);
                if ~isempty(recordingDayTrialsSelected)
                    clickTimes = [recordingDayTrialsSelected.JuiceTime];
                    flagJuiceTimeisNaN = isnan([recordingDayTrialsSelected.JuiceTime]);
                    if any(flagJuiceTimeisNaN) % if there are NaN values in Juice Time go to EmptyClick times for different trial types to get the time value
                        flagOtherTrialTypes = ismember({recordingDayTrialsSelected.TrialType},{'eCl'}); % since trials may include other trial types with solenoid click (eCl,t_eCl other than b,j)
                        if any(flagOtherTrialTypes)
                            indsEmptyClickTimeisNonNaN = find(flagOtherTrialTypes & ~isnan([recordingDayTrialsSelected.EmptyClick])); 
                            clickTimes(indsEmptyClickTimeisNonNaN) = [recordingDayTrialsSelected(indsEmptyClickTimeisNonNaN).EmptyClick];
                        end
                    end
        
                    spikeTimes = chunkAlignSpikeTimes(unitCSTimeStamps, clickTimes);
                    % if within session analyses, look at only last trials if they are responsive
                    if FIRST_VS_LAST && length(spikeTimes)>(TRIALS_TO_COMPARE+TRIALS_TO_TRIM)
                        trialSlice = [length(spikeTimes)-TRIALS_TO_COMPARE-TRIALS_TO_TRIM:length(spikeTimes)-TRIALS_TO_TRIM];
                    else
                        trialSlice = [1:length(spikeTimes)];
                    end
                                        
                    slicedSpikeTimes = spikeTimes(trialSlice);
                    trialCount = length(slicedSpikeTimes); % should be same trial count for all units
                    arrSpikeTimes = cell2mat(slicedSpikeTimes');
                    binCounts = histcounts(arrSpikeTimes,EDGES); % optimumBinCount);                    
                    meanSpikeRate = binCounts/(trialCount*BIN_SIZE_PSTH); % averaged over trials and specified bin size
    
                    if FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS~=FLAG_TYPE_OF_COMPARISON_FOR_CS_RESPONSIVENESS_STD % Just having a CS is enough
                        indEdges = find(EDGES>=CS_POTENTIATION_RANGE_AROUND_ZERO(1) & EDGES<=CS_POTENTIATION_RANGE_AROUND_ZERO(2));
                        responsivenessToReward = binCounts(indEdges);
                        if any(responsivenessToReward) % Any spikes after reward would work
                            flagResponsive = 1;
                        end
                    else % STD LEVEL RESPONSIVENESS SEEKED                        
                        indsBaseline = find(EDGES>=BASELINE_RANGE(1)&EDGES<=BASELINE_RANGE(2));
                        baselineSpikeRate = meanSpikeRate(indsBaseline);
                        indsPotentiationRange = find(EDGES>=CS_POTENTIATION_RANGE_AROUND_ZERO(1)&EDGES<=CS_POTENTIATION_RANGE_AROUND_ZERO(2));
                        potentiationSpikeRate = meanSpikeRate(indsPotentiationRange);
                
                        zScoredSpikeRatesPotentiation = (potentiationSpikeRate-mean(baselineSpikeRate))/std(baselineSpikeRate);
                        zScoredSpikeRatesBaseline = (baselineSpikeRate-mean(baselineSpikeRate))/std(baselineSpikeRate);
                        std5 = STD_LEVEL_FOR_CS*std(zScoredSpikeRatesBaseline); % Court suggested to stick with 4.5 since non-responsive CSs seemed responding a bit! % I increased it to 5 since 4 seemed that it could not well-eliminated randomly spiking CSs, they seemed their response a bit higher that random after the reward
                        whichOne = abs(zScoredSpikeRatesPotentiation)>=std5; % absolute suppression or activation amount should be bigger than 5*STD
                        if any(zScoredSpikeRatesPotentiation(whichOne)>0) % Activation
                            flagResponsive = 1;
                            values = zScoredSpikeRatesPotentiation(whichOne);
%                             logger.info('isResponsive', ['Responsive unit found with potentiation=' num2str(values(1)) ' > baseline4.5STD=' num2str(std5) ' between trials:[' num2str(trialSlice(1)) ' ' num2str(trialSlice(end)) ']']);
                           
                %{
                            prePlot();
                            edgesPlt = EDGES(1:end-1)+(EDGES(2)-EDGES(1))/2;
                            smtSpikeRates = smooth(edgesPlt,meanSpikeRate, SPIKE_SPAN, SMOOTH_TYPE_L);
                            plot(edgesPlt, smtSpikeRates, 'LineWidth',1.4);
                            plot(edgesPlt, meanSpikeRate, 'LineWidth',1.4);
                            xlim([-PRE_BEHAVIORAL_EVENT POST_BEHAVIORAL_EVENT_PLOT]);
                            %postPlot('Time (s)', 'Spikes/s', -PRE_BEHAVIORAL_EVENT, POST_BEHAVIORAL_EVENT_PLOT, [], [], '', '');
                %}
                        elseif any(zScoredSpikeRatesPotentiation(whichOne)<0) % Suppression
                            flagResponsive = -1; 
                        else
                            flagResponsive = 0;
                        end
                    end
                end
            % Compare TRIAL_TYPE_1 has bigger response than TRIAL_TYPE_2 for CS responsiveness
            elseif FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS == FLAG_WAY_OF_COMPARISON_FOR_CS_RESPONSIVENESS_DUAL
                indsSelectedTrials1 = ismember({recordingDayTrials.TrialType},TRIAL_TYPE_1_TO_INCLUDE_CS_RESPONSIVENESS);
                recordingDayTrialsSelected1 = recordingDayTrials(indsSelectedTrials1);
                indsSelectedTrials2 = ismember({recordingDayTrials.TrialType},TRIAL_TYPE_2_TO_INCLUDE_CS_RESPONSIVENESS);
                recordingDayTrialsSelected2 = recordingDayTrials(indsSelectedTrials2);

                if ~isempty(recordingDayTrialsSelected1) && ~isempty(recordingDayTrialsSelected2)
                    % Calculate first trial type responses
                    clickTimes1 = [recordingDayTrialsSelected1.JuiceTime];
                    spikeTimes1 = chunkAlignSpikeTimes(unitCSTimeStamps, clickTimes1);
                    % if within session analyses, look at only last trials if they are responsive
                    if FIRST_VS_LAST && length(spikeTimes1)>(TRIALS_TO_COMPARE+TRIALS_TO_TRIM)
                        trialSlice = [length(spikeTimes1)-TRIALS_TO_COMPARE-TRIALS_TO_TRIM:length(spikeTimes1)-TRIALS_TO_TRIM];
                    else
                        trialSlice = [1:length(spikeTimes1)];
                    end                    
                    
                    slicedSpikeTimes1 = spikeTimes1(trialSlice);
                    trialCount1 = length(slicedSpikeTimes1); % should be same trial count for all units
                    arrSpikeTimes1 = cell2mat(slicedSpikeTimes1');
                    binCounts1 = histcounts(arrSpikeTimes1,EDGES); % optimumBinCount);                    
                    meanSpikeRate1 = binCounts1/(trialCount1*BIN_SIZE_PSTH); % averaged over trials and specified bin size
    
                    % Calculate second trial type responses
                    clickTimes2 = [recordingDayTrialsSelected2.JuiceTime];
                    spikeTimes2 = chunkAlignSpikeTimes(unitCSTimeStamps, clickTimes2);
                    % if within session analyses, look at only last trials if they are responsive
                    if FIRST_VS_LAST && length(spikeTimes2)>(TRIALS_TO_COMPARE+TRIALS_TO_TRIM)
                        trialSlice = [length(spikeTimes2)-TRIALS_TO_COMPARE-TRIALS_TO_TRIM:length(spikeTimes2)-TRIALS_TO_TRIM];
                    else
                        trialSlice = [1:length(spikeTimes2)];
                    end                    
                    
                    slicedSpikeTimes2 = spikeTimes2(trialSlice);
                    trialCount2 = length(slicedSpikeTimes2); % should be same trial count for all units
                    arrSpikeTimes2 = cell2mat(slicedSpikeTimes2');
                    binCounts2 = histcounts(arrSpikeTimes2,EDGES); % optimumBinCount);                    
                    meanSpikeRate2 = binCounts2/(trialCount2*BIN_SIZE_PSTH); % averaged over trials and specified bin size
                        
                    indEdges = find(EDGES>=CS_POTENTIATION_RANGE_AROUND_ZERO(1) & EDGES<=CS_POTENTIATION_RANGE_AROUND_ZERO(2));
                    responsivenessToType1 = meanSpikeRate1(indEdges);
                    responsivenessToType2 = meanSpikeRate2(indEdges);
                    sRespWay = '';
                    if max(responsivenessToType1)>MAGNITUDE_LEVEL*max(responsivenessToType2) % Any larger spikes would work
                        flagResponsive = 1;
                        sRespWay = 'Bigger';
                    else %if max(responsivenessToType1)<max(responsivenessToType2)
                        flagResponsive = -1; % Send them as smaller responders but they will be put into category of Non-responders
                        sRespWay = 'Smaller';
                    end

                    %{
                            prePlot();
                            edgesPlt = EDGES(1:end-1)+(EDGES(2)-EDGES(1))/2;
                            smtSpikeRates1 = smooth(edgesPlt,meanSpikeRate1, SPIKE_SPAN, SMOOTH_TYPE_L);
                            smtSpikeRates2 = smooth(edgesPlt,meanSpikeRate2, SPIKE_SPAN, SMOOTH_TYPE_L);
                            plot(edgesPlt, smtSpikeRates1, 'LineWidth',1.4, 'Color', 'r');
                            plot(edgesPlt, smtSpikeRates2, 'LineWidth',1.4, 'Color', 'k');
                            xlim([-PRE_BEHAVIORAL_EVENT POST_BEHAVIORAL_EVENT_PLOT]);
                            %postPlot('Time (s)', 'Spikes/s', -PRE_BEHAVIORAL_EVENT, POST_BEHAVIORAL_EVENT_PLOT, [], [], '', '');
                   
                    
                    f = prePlot();
                    edgesPlt = EDGES(1:end-1)+(EDGES(2)-EDGES(1))/2;
                    plot(edgesPlt(indEdges), meanSpikeRate1(indEdges), 'LineWidth',1.4, 'Color', 'r');
                    plot(edgesPlt(indEdges), meanSpikeRate2(indEdges), 'LineWidth',1.4, 'Color', 'k');  
                    sFile = [pathToFolder sMouseId '_' sLabel '_day' num2str(day) '_unit' num2str(unitID) '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_' sRespWay];
                    sTitle = [sMouseId sLabel ' day' num2str(day) ' unit' num2str(unitID) ' ' sRespWay];    
                    postPlot(f, 'Time (s)', 'Spikes/s', -PRE_BEHAVIORAL_EVENT_PLOT, POST_BEHAVIORAL_EVENT_PLOT, [], [], sTitle, sFile);
                    %}
                end
            end
        else % if we are not dividing them based on their responsiveness, all of them will be responsive so that they are included
            flagResponsive = 1;
        end
end