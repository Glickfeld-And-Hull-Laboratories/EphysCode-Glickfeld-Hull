function [spikeRates, individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues] = arrangeSpikeRatesAccordingly(cellSpikeTimes, bTrialSlice, allLicks, lickOnsets, cueTimes)
        globals;
        
        indsBaseline = find(EDGES>=BASELINE_RANGE(1)&EDGES<=BASELINE_RANGE(2));

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
        individualLickRates = zeros(length(slicedLicks),length(EDGES_LICK)-1);

        arrLickOnsets = [];
        arrCues = [];

        for ind=1:length(slicedSpikeTimes) % go through all units for the one recording day
            trialCount = length(slicedSpikeTimes{ind});
            if ~isempty(slicedLicks)
                individualLicks = slicedLicks{ind};
            end
            individualSpikeTimes = slicedSpikeTimes{ind};    

            if NORMALIZE_X_AXIS_FOR_EACH_LICK==0 || MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
                arrSpikeTimes = cell2mat(individualSpikeTimes');
                binCounts = histcounts(arrSpikeTimes,EDGES); % optimumBinCount);            
                individualSpikeRates(ind,:) = binCounts/(trialCount*BIN_SIZE_PSTH);

                arrLickTimes = cell2mat(individualLicks');            
                binCounts = histcounts(arrLickTimes,EDGES_LICK);
                individualLickRates(ind,:) = binCounts/(trialCount*BIN_SIZE_LICK);
            else                
                normIndividualSpikeTimes = normalizeXForEachLick(individualSpikeTimes, individualLicks);
                arrSpikeTimes = cell2mat(normIndividualSpikeTimes');
                binCounts = histcounts(arrSpikeTimes,EDGES);
                individualSpikeRates(ind,:) = binCounts/(trialCount*BIN_SIZE_PSTH);

                lenLicks=cellfun(@(x) [0:length(x)-1],individualLicks, UniformOutput=false);
                arrLickTimes = cell2mat(lenLicks);            
                binCounts = histcounts(arrLickTimes,EDGES_LICK);
                individualLickRates(ind,:) = binCounts/(trialCount*BIN_SIZE_PSTH);
            end
            arrLickOnsets = [arrLickOnsets cell2mat(slicedLickOnsets{ind})];
            arrCues = [arrCues cell2mat(slicedCueTimes{ind})];
        end

        arrLickOnsets = arrLickOnsets(arrLickOnsets>-PRE_BEHAVIORAL_EVENT & arrLickOnsets<POST_BEHAVIORAL_EVENT);
        meanLickOnsets = mean(arrLickOnsets);
        semLickOnsets = std(arrLickOnsets)/sqrt(length(arrLickOnsets));

        arrCues = arrCues(arrCues>-PRE_BEHAVIORAL_EVENT & arrCues<POST_BEHAVIORAL_EVENT);
        meanCues = mean(arrCues);
        semCues = std(arrCues)/sqrt(length(arrCues));
                                        % averaged over trials, over # of cells and specified bin size
                
        % Only ZScores
        if FLAG_NORM_FR && bTrialSlice==-1 % Can Z-score if no slicing, otherwise dividing cells into two classes (Increasing/Decreasing) getting complicated

            normSpikeRates = zeros(length(slicedSpikeTimes),length(EDGES)-1);
            for ind=1:size(individualSpikeRates,1)
                individualSpikeRate = individualSpikeRates(ind,:);
                baselineSpikeRate = individualSpikeRate(indsBaseline);                
                        
                normSpikeRates(ind,:) = (individualSpikeRate-mean(baselineSpikeRate))/mean(baselineSpikeRate); % 1/9/2026: changed from std(baselineSpikeRate) cos z-scoring biased: higher firing rates may have higher std;
            end
            spikeRates = normSpikeRates;
        else
            spikeRates = individualSpikeRates;
        end
end