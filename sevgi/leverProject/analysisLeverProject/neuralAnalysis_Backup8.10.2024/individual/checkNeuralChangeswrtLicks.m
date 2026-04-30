function checkNeuralChangeswrtLicks(unit, arrReactTimes, preHoldTime, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX, targetStimTimesGLX, baselineStimTimesGLX, ...
    lickOnsetTimesGLX, lickOffsetTimesGLX, rewardOnsetTimesGLX, rewardOffsetTimesGLX, arrStimTurnedOnTrials, allTrials, arrHitTrials, arrFaTrials, arrMissTrials, omissionTrials, nonOmissionTrials)

        globals; 
        
        PRE_TIME_HOLD = .5;

        REACT_LO_BAND = [-4000 750];
        REACT_HI_BAND = [1000 3000];

        predTrialCount = length(allTrials)-fixedHoldStartsAtTrial+1;
                
        spikeTimesSec = unit.spikeTimesSecs;
        spikeTimeofTrialAlignedToLeverRelease = cell(1,predTrialCount);
        spikeTimeofTrialwITIAlignedToLeverRelease = cell(1,predTrialCount);
        lickTimes = cell(1,predTrialCount);
        holdTimesAlignedToRelease = nan(1,predTrialCount);
        rewardOnsetAlignedToRelease = nan(1,predTrialCount);
        spikeTimeofTrialAlignedToLickOnset = cell(1,predTrialCount);

        indPredTrial=1;
        for indTrial=fixedHoldStartsAtTrial:length(allTrials)
            % ******************* for 1st plot : Spikes aligned to release ***********************
            % get spikes between hold and release                        
            spikesOfTrial = spikeTimesSec(spikeTimesSec>(leverHoldTimes(indTrial)-PRE_TIME_HOLD) & spikeTimesSec<(leverReleaseTimesGLX(indTrial)+POST_TIME_RELEASE));             
            spikeTimeofTrialAlignedToLeverRelease(indPredTrial) = {spikesOfTrial - leverReleaseTimesGLX(indTrial)}; % align according to Lever Release           
            
            % get spikes between hold of a trial and hold of the next trial
            if indTrial+1>=length(leverHoldTimes)
                nextTrialStartTime = leverReleaseTimesGLX(indTrial)+POST_TIME_RELEASE;
            else
                nextTrialStartTime = leverHoldTimes(indTrial+1)-PRE_TIME_HOLD;
            end
            spikesOfTrialwITI = spikeTimesSec(spikeTimesSec>(leverHoldTimes(indTrial)-PRE_TIME_HOLD) & spikeTimesSec<nextTrialStartTime); 
            spikeTimeofTrialwITIAlignedToLeverRelease(indPredTrial) = {spikesOfTrialwITI - leverReleaseTimesGLX(indTrial)}; % align according to Lever Release                            

            lickTimesOfTrial = lickOnsetTimesGLX(lickOnsetTimesGLX>(leverHoldTimes(indTrial)-PRE_TIME_HOLD) & lickOnsetTimesGLX<(leverReleaseTimesGLX(indTrial)+POST_TIME_RELEASE)); 
            lickTimes(indPredTrial) = {lickTimesOfTrial - leverReleaseTimesGLX(indTrial)};            
            holdTimesAlignedToRelease(indPredTrial) = leverHoldTimes(indTrial)-leverReleaseTimesGLX(indTrial);
            
%             indActualTrial = find(nonOmissionTrials==indTrial);
%             if ~isempty(indActualTrial)
%                 rewardOnsetAlignedToRelease(indPredTrial) = rewardOnsetTimesGLX(indActualTrial)-leverReleaseTimesGLX(indTrial);
%             end
            
            % ******************* for 2nd plot : Spikes aligned to lick onset ***********************
            if ~isempty(lickTimesOfTrial)
                spikeTimeofTrialAlignedToLickOnset(indPredTrial) = {spikesOfTrial - lickTimesOfTrial(1)}; % align according to Lever Release           
            end

            indPredTrial=indPredTrial+1;
        end

        %*************************** PLOT LICK vs NO LICK TRIALS *******************************
        indNoLickTrials = find(cellfun(@isempty, lickTimes));
        arrNoLickSpikeTimes = cell2mat(spikeTimeofTrialAlignedToLeverRelease(indNoLickTrials)');
        indLickTrials = find(~cellfun(@isempty, lickTimes));
        arrLickSpikeTimes = cell2mat(spikeTimeofTrialAlignedToLeverRelease(indLickTrials)');

        minEdge = min([min(arrNoLickSpikeTimes) min(arrLickSpikeTimes)]); % what this means? => get the bigger time point for minEdge so that both distr are treated equatibly
        maxEdge = max([max(arrNoLickSpikeTimes) max(arrLickSpikeTimes)]); % what this means? => get the smaller time point for maxEdge so that both distr are treated equatibly
        edges = minEdge-BIN_SIZE_PSTH:BIN_SIZE_PSTH:maxEdge+BIN_SIZE_PSTH;

        f = figure;
        f.Position = [globalX globalY globalW globalH];
        hold on
        grid on

        binCounts = histcounts(arrNoLickSpikeTimes,edges); % optimumBinCount);
        noLickSpikeRates = binCounts/(predTrialCount*BIN_SIZE_PSTH); % averaged over trials and specified bin
        edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
        smtNoLickSpikeRates = smooth(edgesPlt,noLickSpikeRates, SPIKE_SPAN, SMOOTH_TYPE_L); %SPIKE_SPAN            
        %scatter(edgesPlt,noLickSpikeRates,40, '.', 'green');
        plot(edgesPlt, smtNoLickSpikeRates, 'LineWidth',2, 'Color', 'green');

        binCounts = histcounts(arrLickSpikeTimes,edges); % optimumBinCount);
        lickSpikeRates = binCounts/(predTrialCount*BIN_SIZE_PSTH); % averaged over trials and specified bin
        edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
        smtLickSpikeRates = smooth(edgesPlt,lickSpikeRates, SPIKE_SPAN, SMOOTH_TYPE_L); %SPIKE_SPAN            
        %scatter(edgesPlt,lickSpikeRates,40, '.', 'red');
        plot(edgesPlt, smtLickSpikeRates, 'LineWidth',2, 'Color', 'red');
        arrLickTimes = cell2mat(lickTimes);
        scatter(arrLickTimes, ones(1,length(arrLickTimes))*max(smtLickSpikeRates)*1.2, 25, '*', 'red');        
        scatter(holdTimesAlignedToRelease, ones(1,length(holdTimesAlignedToRelease))*max(smtLickSpikeRates)*1.1, 25, '*', 'black');
        %xline(nanmean(rewardOnsetAlignedToRelease), 'LineWidth',1.5, 'Color', 'blue');

        ylabel('Spikes/s');
        xlabel('Time from release (s)');
        legend({['Activity with no lick (mean=' num2str(mean(noLickSpikeRates),'%.2f') ') n=' num2str(length(indNoLickTrials))] , ...
                ['Activity with lick (mean=' num2str(mean(lickSpikeRates),'%.2f') ') n=' num2str(length(indLickTrials))], ...
                ['Lick times'], ['Hold times'], ['Reward time'], ...
                }, 'Location', 'southeast', 'Color', 'none');
        xlim([edges(1) edges(end)]);
        set(gca,'TickDir','out');
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
        title([unit.neuronType ' id=' num2str(unit.id) ' layer=' unit.layer ' depth=' num2str(unit.depth) ' PSTH']);
        
        sLickTimeAnalysesPSTHFolder = [pathToFigureFolder '/LickTimeAnalyses/PSTH/'];
        if ~exist(sLickTimeAnalysesPSTHFolder)
            mkdir(sLickTimeAnalysesPSTHFolder);
        end

        if ~all(smtNoLickSpikeRates==0) || ~all(smtLickSpikeRates==0)
            print([sLickTimeAnalysesPSTHFolder unit.neuronType '_' num2str(unit.id) '_psth_LickvsNoLickPSTH.tif'], '-dtiff', '-r100');
            logger.info('checkNeuralChangeswrtLicks', ['LickvsNoLickPSTH is plotted for unit ' num2str(unit.id)]);
            close all
        else
            logger.info('checkNeuralChangeswrtLicks', ['Either or both No Lick or Lick spikes for unit ' num2str(unit.id) ' were empty!']);
        end

        %*************************** PLOT LICK vs NO LICK TRIALS *******************************        
        arrSpikeTimesAlignedToLick = cell2mat(spikeTimeofTrialAlignedToLickOnset');
        lickTrialCount = length(indLickTrials);

        minEdge = min(arrSpikeTimesAlignedToLick); % what this means? => get the bigger time point for minEdge so that both distr are treated equatibly
        maxEdge = max(arrSpikeTimesAlignedToLick); % what this means? => get the smaller time point for maxEdge so that both distr are treated equatibly
        edges = minEdge-BIN_SIZE_PSTH:BIN_SIZE_PSTH:maxEdge+BIN_SIZE_PSTH;

        f = figure;
        f.Position = [globalX globalY globalW globalH];
        hold on
        grid on
        
        binCounts = histcounts(arrSpikeTimesAlignedToLick,edges); % optimumBinCount);
        spikeRatesLickAligned = binCounts/(lickTrialCount*BIN_SIZE_PSTH); % averaged over trials and specified bin
        edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
        smtSpikeRatesLickAligned = smooth(edgesPlt,spikeRatesLickAligned, SPIKE_SPAN, SMOOTH_TYPE_L);
        plot(edgesPlt, smtSpikeRatesLickAligned, 'LineWidth',2, 'Color', 'red');
        ylabel('Spikes/s');
        xlabel('Time from lick onset (s)');

        xlim([edges(1) edges(end)]);
        set(gca,'TickDir','out');
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
        title([unit.neuronType ' id=' num2str(unit.id) ' layer=' unit.layer ' depth=' num2str(unit.depth) ' PSTH aligned to lick onset']);
        
        sLickTimeAnalysesPSTHFolder = [pathToFigureFolder '/LickTimeAnalyses/PSTH/'];
        if ~exist(sLickTimeAnalysesPSTHFolder)
            mkdir(sLickTimeAnalysesPSTHFolder);
        end

        if ~all(smtNoLickSpikeRates==0) || ~all(smtLickSpikeRates==0)
            print([sLickTimeAnalysesPSTHFolder unit.neuronType '_' num2str(unit.id) '_psth_LickAlignedPSTH.tif'], '-dtiff', '-r100');
            logger.info('checkNeuralChangeswrtLicks', ['LickAlignedPSTH is plotted for unit ' num2str(unit.id)]);
            close all
        else
            logger.info('checkNeuralChangeswrtLicks', ['Either or both No Lick or Lick spikes for unit ' num2str(unit.id) ' were empty!']);
        end
end