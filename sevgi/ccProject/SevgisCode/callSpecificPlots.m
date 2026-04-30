function callSpecificPlots(daySSJuiceRespCueRespCSAllMice, sRangewOrwOutCS, pathToSSPsthFolder, sLabel, sDay, sAlignedTo, arrModulations, ...
    cellGroupNames, individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, dayDepths, sYLabel, bSuperImpose, sAddSubTitle)
    globals;

    sAddTitle = [' on ' sLabel ' ' sDay];

    f = prePlot();  
    sTitle = [NEURON_TYPE ' trials ' sRangewOrwOutCS ' n = ' num2str(size(daySSJuiceRespCueRespCSAllMice,1)) ' ' sAddSubTitle];
    sFile = [pathToSSPsthFolder sLabel sDay '_' NEURON_TYPE '_wJResp_wCS' sRangewOrwOutCS '_alignedTo' sAlignedTo ' ' sAddSubTitle];
    
    [spikeRatesPre_JuiceRespCueResp, spikeRatesPost_JuiceRespCueResp] = ...
        plotComparisonPSTHs(daySSJuiceRespCueRespCSAllMice, arrModulations, cellGroupNames, ...
        individualLickRates, meanLickOnsets, semLickOnsets, meanCues, semCues, NEURON_TYPE, sTitle, sFile, [], [], bSuperImpose, dayDepths); % red
    postPlot(f, ['Time from ' sAlignedTo ' (s)'], sYLabel, -PRE_BEHAVIORAL_EVENT_PLOT, POST_BEHAVIORAL_EVENT_PLOT, MIN_YLIM, MAX_YLIM, sTitle, sFile);
    
    lenGroup1 = sum(arrModulations==1);
    lenGroup2 = sum(arrModulations==-1);
    lenGroup3 = sum(arrModulations==0);
    lenGroupRest = sum(arrModulations==-99);
    if lenGroupRest>0        
        plotPie([lenGroup1 lenGroup2 lenGroup3 lenGroupRest], ...
        {cellGroupNames{:}, 'Unmodulated'}, ... % {'', sGroupName1, sGroupName2}, ...
        [COLORS(7,1:3); COLORS(1,1:3); COLORS(9,1:3); COLORS(8,1:3)], ...
        [sLabel sDay sAddSubTitle sAlignedTo], pathToPieFolder);
    else
        plotPie([lenGroup1 lenGroup2 lenGroup3], ...
            cellGroupNames, ... % {'', sGroupName1, sGroupName2}, ...
            [COLORS(7,1:3); COLORS(1,1:3); COLORS(8,1:3)], ...
            [sLabel sDay sAddSubTitle sAlignedTo], pathToPieFolder);
    end
end