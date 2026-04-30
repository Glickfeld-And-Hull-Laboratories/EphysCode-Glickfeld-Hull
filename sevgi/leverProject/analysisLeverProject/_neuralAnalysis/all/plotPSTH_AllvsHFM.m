function plotPSTH_AllvsHFM(recordingDay, expertLabel, trialCounts, spikeRatesFixedAll, spikeRatesRandomAll, spikeRatesFixedHFM, spikeRatesRandomHFM, ...
    preTime, postTime, edges, sTitleFixed, sTitleRandom, sFileName)
    
    globalsAll;
    
    allHitFixedTrialCount = trialCounts(1);
    allHitRandomTrialCount = trialCounts(2);
    allFaFixedTrialCount = trialCounts(3);
    allFaRandomTrialCount = trialCounts(4);
    allMissFixedTrialCount = trialCounts(5);
    allMissRandomTrialCount = trialCounts(6);
    allTrialCount = trialCounts(7);
    
    sTitles = {sTitleFixed, sTitleRandom};
    sGlobalTitle = [recordingDay ' ' expertLabel '(n=' num2str(size(spikeRatesFixedAll,1)) ') trials=' num2str(allTrialCount)];

    spikeRates = {{spikeRatesFixedAll}, {spikeRatesRandomAll}};
    sFullFileName = [pathToFigureFolder CELL_TYPES_FOLDER recordingDay '_' expertLabel '_psth_' sFileName '_All_xlim_' num2str(preTime) '_' num2str(postTime) '.tif'];
    
    if ~isnan(allHitFixedTrialCount)
        allFixedTrialCount = allHitFixedTrialCount;
    end
    if ~isnan(allFaFixedTrialCount)
        allFixedTrialCount = allFixedTrialCount + allFaFixedTrialCount;
    end
    if ~isnan(allMissFixedTrialCount)
        allFixedTrialCount = allFixedTrialCount + allMissFixedTrialCount;
    end

    if ~isnan(allHitRandomTrialCount)
        allRandomTrialCount = allHitRandomTrialCount;
    end
    if ~isnan(allFaRandomTrialCount)
        allRandomTrialCount = allRandomTrialCount + allFaRandomTrialCount;
    end
    if ~isnan(allMissRandomTrialCount)
        allRandomTrialCount = allRandomTrialCount + allMissRandomTrialCount;
    end

    plotPSTHs(spikeRates, [allFixedTrialCount, allRandomTrialCount], {}, {}, preTime, postTime, edges, sTitles, sGlobalTitle, sFullFileName, {{'All'}, {'All'}}, {{'k'},{'k'}}, {'r'}, 1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if size(spikeRatesRandomHFM{1},1)==3 % Hit FA Miss
        spikeRatesRandomHit = cellfun(@(x)x(1,:),spikeRatesRandomHFM,'UniformOutput',false);
        spikeRatesRandomFa = cellfun(@(x)x(2,:),spikeRatesRandomHFM,'UniformOutput',false);
        spikeRatesRandomMiss = cellfun(@(x)x(3,:),spikeRatesRandomHFM,'UniformOutput',false);
        
        spikeRatesFixedHit = cellfun(@(x)x(1,:),spikeRatesFixedHFM,'UniformOutput',false);
        spikeRatesFixedFa = cellfun(@(x)x(2,:),spikeRatesFixedHFM,'UniformOutput',false);
        spikeRatesFixedMiss = cellfun(@(x)x(3,:),spikeRatesFixedHFM,'UniformOutput',false);
    elseif size(spikeRatesRandomHFM{1},1)==2 % Hit Miss
        spikeRatesRandomHit = cellfun(@(x)x(1,:),spikeRatesRandomHFM,'UniformOutput',false);
        spikeRatesRandomFa = {};
        spikeRatesRandomMiss = cellfun(@(x)x(2,:),spikeRatesRandomHFM,'UniformOutput',false);
        
        spikeRatesFixedHit = cellfun(@(x)x(1,:),spikeRatesFixedHFM,'UniformOutput',false);
        spikeRatesFixedFa = {};
        spikeRatesFixedMiss = cellfun(@(x)x(2,:),spikeRatesFixedHFM,'UniformOutput',false);
    end

    spikeRates = {{spikeRatesFixedHit, spikeRatesFixedFa, spikeRatesFixedMiss}, {spikeRatesRandomHit, spikeRatesRandomFa, spikeRatesRandomMiss}};
    sFullFileName = [pathToFigureFolder CELL_TYPES_FOLDER recordingDay '_' expertLabel '_psth_' sFileName '_HFM_xlim_' num2str(preTime) '_' num2str(postTime) '.tif'];
    plotPSTHs(spikeRates, [allHitFixedTrialCount, allHitRandomTrialCount, allFaFixedTrialCount, allFaRandomTrialCount, allMissFixedTrialCount, allMissRandomTrialCount], {}, {}, preTime, postTime, edges, sTitles, sGlobalTitle, sFullFileName, {{'Hit','Fa','Miss'}, {'Hit','Fa','Miss'}}, {{'b', 'r', 'm'},{'b', 'r', 'm'}}, {'r'}, 1);
end