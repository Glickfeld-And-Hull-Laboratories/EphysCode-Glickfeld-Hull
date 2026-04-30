% Plots coinciding/non-coinciding spikes of MLI1A and MLI1B vs SS
% SO - Hull lab 8/22/2025
function [needToSave, unitGoodSorted] = synchedCCGsPlotting(unitMLIA, unitMLIB, unitMasterA_SynchSpikeTimes, unitMasterA_UnSynchSpikeTimes, ...
    unitMasterB_SynchSpikeTimes, unitMasterB_UnSynchSpikeTimes, unitSS, unitGoodSorted, sWhichPhase)
    globals;
    logger.info('synchedCCGsPlotting', ['Will plot ' SS_MLI ' for ' NEURON_TYPE_SS '_' num2str(unitSS.id) '(' num2str(unitSS.depth) 'um) against ' ...
        'MLI1A_' num2str(unitMLIA.id) '(' num2str(unitMLIA.depth) 'um) and MLI1B_' num2str(unitMLIB.id) '(' num2str(unitMLIB.depth) 'um)']);
                    
    if strcmp(sWhichPhase, BASELINE)
        startTime = 0;
        endTime = MOMENT_OF_1ST_DRUG_PUT_IN;
        sSynchPhase = COINCIDENCE_BSLN;
        sUnSynchPhase = NONCOINCIDENCE_BSLN;
    elseif strcmp(sWhichPhase, FIRST_DRUG)
        startTime = MOMENT_OF_1ST_DRUG_WASH_IN;
        if isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
            endTime = Inf;
        else
            endTime = MOMENT_OF_2ND_DRUG_PUT_IN;
        end
        sSynchPhase = COINCIDENCE_FIRST_DRUG;
        sUnSynchPhase = NONCOINCIDENCE_FIRST_DRUG;
    elseif strcmp(sWhichPhase, SECOND_DRUG)
        startTime = MOMENT_OF_2ND_DRUG_WASH_IN;
        endTime = Inf;
        sSynchPhase = COINCIDENCE_SECOND_DRUG;
        sUnSynchPhase = NONCOINCIDENCE_SECOND_DRUG;
    end

    f = figure;    
    f.Position = [globalX globalY globalW globalH]; 
    hold on;

    % SYNCHED SPIKES
    [~, ~, ~, ~, ~, unitGoodSorted, readForTheFirstTimeASynch, ~, meanRateASynch] = ...
        correlogramRateCorrectedWSpikeTimes([unitMLIA.id unitSS.id], SS_MLI, unitMasterA_SynchSpikeTimes, unitSS.spikeTimesSecs, unitGoodSorted, startTime, endTime, sSynchPhase, [1, 0, 1], 1);
    [~, ~, ~, ~, ~, unitGoodSorted, readForTheFirstTimeBSynch, ~, meanRateBSynch] = ...
        correlogramRateCorrectedWSpikeTimes([unitMLIB.id unitSS.id], SS_MLI, unitMasterB_SynchSpikeTimes, unitSS.spikeTimesSecs, unitGoodSorted, startTime, endTime, sSynchPhase, [0, 1, 0], 1);
    
    % UNSYNCHED SPIKES
    [~, ~, ~, synchExc, synchInh, unitGoodSorted, readForTheFirstTimeAUnSynch, ~, meanRateAUnSynch] = ...
        correlogramRateCorrectedWSpikeTimes([unitMLIA.id unitSS.id], SS_MLI, unitMasterA_UnSynchSpikeTimes, unitSS.spikeTimesSecs, unitGoodSorted, startTime, endTime, sUnSynchPhase, [0.5, 0, 0.5], 1);    
    [~, ~, ~, synchExc, synchInh, unitGoodSorted, readForTheFirstTimeBUnSynch, ~, meanRateBUnSynch] = ...
        correlogramRateCorrectedWSpikeTimes([unitMLIB.id unitSS.id], SS_MLI, unitMasterB_UnSynchSpikeTimes, unitSS.spikeTimesSecs, unitGoodSorted, startTime, endTime, sUnSynchPhase, [0, 0.5, 0], 1);
    
    if readForTheFirstTimeASynch || readForTheFirstTimeBSynch || readForTheFirstTimeAUnSynch || readForTheFirstTimeBUnSynch
        needToSave = 1;
    end

    h = findobj(gca,'Type','line');
    yData=get(h,'Ydata');
    yMax = max([cellfun(@max,yData,UniformOutput=true)]);
    yMin = min([cellfun(@min,yData,UniformOutput=true)]);
    if ~isempty(yMin) && ~isempty(yMax) && (yMin-yMin/10)<(yMax+yMax/10)
        ylim([yMin-yMin/5 yMax+yMax/10]);
    end

    legend(h,'UnsynchB', 'UnsynchA', 'SynchB', 'SynchA');
    sHeader = ['CCG ' num2str(unitSS.id) ' (' unitSS.neuronType ' depth=' num2str(unitSS.depth) ' um) wrt ' ...
        num2str(unitMLIA.id) ' (MLI1A depth=' num2str(unitMLIA.depth) ' um) and ' ...
        num2str(unitMLIB.id) ' (MLI1B depth=' num2str(unitMLIB.depth)];
    sFRs = ['FR_{Synch} A vs B=' num2str(meanRateASynch,'%.0f') ' vs ' num2str(meanRateBSynch,'%.0f') ...
        ' FR_{UnSynch} A vs B=' num2str(meanRateAUnSynch,'%.0f') ' vs ' num2str(meanRateBUnSynch,'%.0f') ' spk/s'];    
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE);
    title([sHeader ' ' sFRs]);
    
    sFullDir = [pathToSynchronizedCCGsFolder '/CCG_SS(' num2str(unitSS.id) ')_wrtMLI1A(' num2str(unitMLIA.id) ')_MLI1B(' num2str(unitMLIB.id) ')_' sWhichPhase];
    print([sFullDir '.tif'], '-dtiff', '-r120');
    exportgraphics(f,[sFullDir '.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
    savefig([sFullDir '.fig']);

    close all;
end