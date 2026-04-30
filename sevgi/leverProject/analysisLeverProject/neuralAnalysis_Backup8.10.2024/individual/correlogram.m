%%%% PLOT CORRELOGRAM (AUTO/CROSS) %%%%%%%%%%%%
% unitRefID: Reference Unit ID
% unitTargetID: Target Unit ID
% unitRefSpikeTimesSec: Reference Unit Spike Times (s)
% unitTargetSpikeTimesSec: Target Unit Spike Times (s)
% sTitle: Title for different types of correlogram
% see https://www.med.upenn.edu/mulab/crosscorrelation.html to learn about shift predictor
% SO 1/5/2023 Hull Lab
function [deviated, singleUnit] = correlogram(ccgType, unitCategory, unitRefID, unitTargetID, cellUnitRefSpikeTimesSec, cellUnitTargetSpikeTimesSec, trialCount, sTitle, isACG, neuronType)
    globals;
    edges = -X_MAX_CORRELOGRAM-BIN_SIZE_CORRELOGRAM:BIN_SIZE_CORRELOGRAM:X_MAX_CORRELOGRAM+BIN_SIZE_CORRELOGRAM; % first and last bins are to be deleted later
    cc = zeros(size(edges));
    
    relativeSpkTimes = []; shiftPredictorSpkTimes = [];
    if iscell(cellUnitRefSpikeTimesSec) % if cell, then ccg within trials, else compare all spikes        
        for indTrial=1:trialCount
            unitRefSpikeTimesSec = cellUnitRefSpikeTimesSec{indTrial};
            unitTargetSpikeTimesSec = cellUnitTargetSpikeTimesSec{indTrial};
            unitRefSpikeTimesMSec = 1000*unitRefSpikeTimesSec;
            unitTargetSpikeTimesMSec = 1000*unitTargetSpikeTimesSec;
            relativeSpkTime = (unitTargetSpikeTimesMSec'-unitRefSpikeTimesMSec); % Spike time differences across each element - this is more readable than bsxfun %bsxfun(@minus, unitTargetSpikeTimesSec', unitRefSpikeTimesSec); %  element-wise operation to two arrays with implicit expansion enabled
            if isACG
                relativeSpkTime(eye(size(relativeSpkTime))==1) = NaN; % set diagonal to NaN, cos its the difference with the spike itself, ACG is not interested in self-difference of the very same spike!
            end                
            relativeSpkTime(relativeSpkTime<=edges(1) | relativeSpkTime>=edges(end))=NaN; % constrain it within the ROI            
            relativeSpkTime=relativeSpkTime(~isnan(relativeSpkTime));
            if size(relativeSpkTime,1)>1 
                relativeSpkTime=relativeSpkTime';  % If It is column-wise, convert it to row-wise. It could be already row-wise for 1-element unitTargetSpikeTimesSec, so don't remove this if
            end
            relativeSpkTimes = [relativeSpkTimes relativeSpkTime];            
        end
        
        % Find shift predictor to see how stimulus effects (between-trial effects i.e;stimulus)
        for indTrMaster=1:trialCount-1
            for indTrSlave=indTrMaster+1:trialCount % compare a trial with all other next trials
                unitRefSpikeTimesSec = cellUnitRefSpikeTimesSec{indTrMaster};
                unitTargetSpikeTimesSec = cellUnitTargetSpikeTimesSec{indTrSlave};
                unitRefSpikeTimesMSec = 1000*unitRefSpikeTimesSec;
                unitTargetSpikeTimesMSec = 1000*unitTargetSpikeTimesSec;
                if ~isempty(unitRefSpikeTimesMSec) && ~isempty(unitTargetSpikeTimesMSec)
                    shiftPredictorSpkTime = bsxfun(@minus, unitTargetSpikeTimesMSec', unitRefSpikeTimesMSec); %  element-wise operation to two arrays with implicit expansion enabled
                    shiftPredictorSpkTime(shiftPredictorSpkTime<=edges(1) | shiftPredictorSpkTime>edges(end))=NaN; % constrain it within the ROI
                    shiftPredictorSpkTime=shiftPredictorSpkTime(~isnan(shiftPredictorSpkTime));
                    if size(shiftPredictorSpkTime,1)>1
                        shiftPredictorSpkTime=shiftPredictorSpkTime'; % If It is column-wise, convert it to row-wise. It could be already row-wise for 1-element unitTargetSpikeTimesSec, so don't remove this if
                    end                
                    %if ~isempty(shiftPredictorSpkTime) % this takes ages!
                        shiftPredictorSpkTimes = [shiftPredictorSpkTimes shiftPredictorSpkTime];
                    %end
                end
            end
        end
        
    else % This part will not be used probably, delete it after some time, it has lots of computational cost-never compare all spikes of two unit along the whole session, it is bulky and it averages out salient events
        disp('Do you really need this kind of CCG?');
%         unitRefSpikeTimesSec = cellUnitRefSpikeTimesSec;
%         unitTargetSpikeTimesSec = cellUnitTargetSpikeTimesSec;
%         trialCount=1; % CCGing all spikes will pretend as if one big trial, cos we divide all spike counts downt there to find targetSpikeRates, no need to divide again trialCount    
%         % I couldn't get rid of this for loop, cos it doesn't support bsxfun here, error is:Requested 574125x209005 (894.0GB) array exceeds maximum array size preference
%         for iUnit1=1:length(unitRefSpikeTimesSec)
%             relativeSpkTime = unitTargetSpikeTimesSec - unitRefSpikeTimesSec(iUnit1);       
%             relativeSpkTime = relativeSpkTime(relativeSpkTime>edges(1) & relativeSpkTime<edges(end)); % constrain it within the ROI
%             relativeSpkTimes = [relativeSpkTimes relativeSpkTime];
%         end
    end
        
    % ************* Decide whether plot or not depending on the suppression ******************************
    
    binCounts = histcounts(relativeSpkTimes,edges);
    targetSpikeRates = binCounts/(sum(binCounts)*BIN_SIZE_CORRELOGRAM/1000); % /1000 if binSize in ms  % sum(binCounts)==length(relativeSpkTimes) cos we added up that many times (as many as ref.unit's spikes), average over number of spikes of reference unit (to reveal y-axis be the firing rate of target neuron itself) and specified bin size

    indsRefractory = find(edges>=REFRACTORY_RANGE(1) & edges<REFRACTORY_RANGE(2)); % get the edges between -1 and 1 (-1 inclusive 1 exclusive since smaller than 1 ms spikes contained in the previous bin)
    if isACG && strcmp(neuronType,NEURON_TYPE_MFB)
        indsRefractory = find(edges>=REFRACTORY_RANGE_MF(1) & edges<REFRACTORY_RANGE_MF(2));
    end
    refractoryViolation = targetSpikeRates(indsRefractory);
    refractoryViolationRate = mean(refractoryViolation)/mean(targetSpikeRates);

    % Just to see MF refractory violation in case unclassified cells may turn out to be MF
    indsRefractoryMF = find(edges>=REFRACTORY_RANGE_MF(1) & edges<REFRACTORY_RANGE_MF(2));
    refractoryViolationMF = targetSpikeRates(indsRefractoryMF);
    refractoryViolationRateMF = mean(refractoryViolationMF)/mean(targetSpikeRates);
    
    singleUnit = 0;
    if isACG && ~strcmp(neuronType,NEURON_TYPE_MFB) && refractoryViolationRate<=.06 % Refractory violation is 5 % for all cell types except MF
        singleUnit = 1;
    elseif isACG && strcmp(neuronType,NEURON_TYPE_MFB) && refractoryViolationRate<=.1 % Refractory violation is 10 % for MFs
        singleUnit = 1;        
    end

    binCountsShiftPred = histcounts(shiftPredictorSpkTimes,edges);
    shiftPredSpikeRates = binCountsShiftPred/(sum(binCountsShiftPred)*BIN_SIZE_CORRELOGRAM/1000); % /1000 if binSize in ms  % sum(binCountsShiftPred)==length(shiftPredictorSpkTimes) 

    corrCounts = (targetSpikeRates-shiftPredSpikeRates);
    corrCounts(isnan(corrCounts)) = 0; % eliminate if any NaN
    deviationValue = abs(sum(corrCounts(find(edges>=-CCG_DEVIATION_RANGE&edges<=CCG_DEVIATION_RANGE)))); % Find the suppression around zero

    % Plot CCGs that only have higher deviation OR plot all ACGs
    if (deviationValue > CCG_DEVIATION_CRITERION || isACG) && ~isempty(targetSpikeRates) && any(~isnan(targetSpikeRates))
        sHeader = 'CCG';
        if isACG
            sHeader = 'ACG';
        end

        f = figure;    
        f.Position = [globalX globalY globalW globalH];  
        
        subplot(2,1,1)        
        hstRaw = histogram(relativeSpkTimes,edges);
        if ~all(isnan(targetSpikeRates))
            hstRaw.BinCounts = targetSpikeRates; 
        end          
        grid on;
        set(gca,'box','off');
        xlabel('lag (ms)'); 
        ylabel('Normalized (au)');
        ylim([0 max(targetSpikeRates)*1.3]);
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE); %,'LineWidth',1.5)
        title([sHeader ' Contam %=' num2str(refractoryViolationRate*100,'%.2f') ' Contam MF %=' num2str(refractoryViolationRateMF*100,'%.2f') ' (n=' num2str(trialCount) ') trials']);
        
        if ~isempty(shiftPredSpikeRates) && ~all(isnan(shiftPredSpikeRates))
            subplot(2,1,2)    
            hstSP = histogram(shiftPredictorSpkTimes,edges);    
            if ~all(isnan(shiftPredSpikeRates))
                hstSP.BinCounts = shiftPredSpikeRates; 
            end     
            grid on;
            set(gca,'box','off');
            xlabel('lag (s)'); 
            ylabel('Normalized (au)');
            ylim([0 mean(shiftPredSpikeRates(~isnan(shiftPredSpikeRates)))*2]);
            set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE); %,'LineWidth',1.5)
            title('Shift predictor (between trial effects)');
        end
%         subplot(3,1,3)    
%         hstCorrected = bar(edges(1:end-1),corrCounts); %histogram('BinEdges',edges,'BinCounts',corrCounts);  % histogram did not work bc of negative counts      
%         grid on;
%         set(gca,'box','off');
%         xlabel('lag (s)'); 
%         ylabel('Difference (au)');
%         ylim([-3 3]);
%         set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE); %,'LineWidth',1.5)            
%         title(sprintf(['Corrected (only within trial effects) ' sHeader ' ' sTitle ' Unit %d vs Unit %d'],unitRefID,unitTargetID)); 

        sgtitle([sHeader ' ' sTitle ' Unit ' num2str(unitRefID) ' vs Unit ' num2str(unitTargetID)]);
        if isACG
            sPrintFolder = [pathToFigureFolder unitCategory '/' num2str(unitRefID)];
            if ~isempty(neuronType)
                sPrintFolder = [sPrintFolder '_' neuronType];
            end
            print([sPrintFolder '/' sHeader '_' num2str(unitRefID) '_' num2str(unitTargetID) '_' sTitle '_' num2str(X_MAX_CORRELOGRAM) 'sec_xlim_' num2str(PRE_TIME_RELEASE) '_' num2str(PRE_TIME_RELEASE) '.tif'], '-dtiff', '-r120');
        else
            print([pathToFigureFolder ccgType '/' sHeader '_' num2str(unitRefID) '_' num2str(unitTargetID) '_' sTitle '_' num2str(X_MAX_CORRELOGRAM) 'sec_xlim_' num2str(PRE_TIME_RELEASE) '_' num2str(PRE_TIME_RELEASE) '.tif'], '-dtiff', '-r120');
        end

        % exportgraphics(f,[pathToFigureFolder ccgType '/' sHeader '_' num2str(unitRefID) '_' num2str(unitTargetID) '_' sTitle '_' num2str(X_MAX_CORRELOGRAM) 'sec_xlim_' num2str(PRE_TIME_RELEASE) '_' num2str(PRE_TIME_RELEASE) '.pdf'], 'ContentType', 'vector', 'Resolution', 200);

        close all
        if isACG
            logger.info('correlogram', [ccgType ' Contam %=' num2str(refractoryViolationRate*100,'%.2f') ' Contam MF %=' num2str(refractoryViolationRateMF*100,'%.2f')]);
        else
            logger.info('correlogram',[ccgType '_' num2str(unitRefID) '_' num2str(unitTargetID) ' PASSED the deviation criterion = ' num2str(deviationValue)]);
        end
        deviated = 1;
    else
        logger.info('correlogram',[ccgType '_' num2str(unitRefID) '_' num2str(unitTargetID) ' could NOT pass the deviation criterion or spikes are empty! deviationValue=' num2str(deviationValue)]);  
        deviated = 0;
    end
end