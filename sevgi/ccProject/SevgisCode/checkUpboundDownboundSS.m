function [lowerCellInds, higherCellInds] = checkUpboundDownboundSS(miceVSDays, miceVSSelectedDay1, miceVSSelectedDayN, ...
    behavDataForRecordingDays, unitCSs, unitSSs, sLabel)

    globals;

    if FROM_CS_TO_SS==1
        nLowerResponseThreshold = 5;
        nHigherResponseThreshold = 10;
        sNeuronType = NEURON_TYPE_CS;
    elseif FROM_CS_TO_SS==0 || FROM_CS_TO_SS==2
        if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
            nLowerBaselineFR = 60;
            nHigherBaselineFR = 140;
            nLowerResponseThreshold = -3;        
            nHigherResponseThreshold = 3;
        elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
            nLowerResponseThreshold = -4;        
            nHigherResponseThreshold = 4;
        end        
        sNeuronType = NEURON_TYPE_SS;
    end

    baselineFRPerMouse = [];
    modulationFRsPerMouse = [];
    responseMagnitudesPerMouse = [];
    cellIndsPerMouse = [];

    %%%%%%%%%%%%% FIRST, GET ALL DAYS %%%%%%%%%%%%%%%
    for ind=1:length(miceVSDays) % Loop through each mouse
        mouseId = miceVSDays{ind,1};
        days = miceVSDays{ind,2};
        
        [cellIndsPerDay, baselineFRPerDay, modulationFRsPerDay, responseMagnitudesPerDay] = ...
            checkUpDown(behavDataForRecordingDays, unitCSs, unitSSs, mouseId, days, sLabel); % Loop through each day

        baselineFRPerMouse = [baselineFRPerMouse baselineFRPerDay];
        modulationFRsPerMouse = [modulationFRsPerMouse modulationFRsPerDay];
        responseMagnitudesPerMouse = [responseMagnitudesPerMouse responseMagnitudesPerDay];
        cellIndsPerMouse = [cellIndsPerMouse cellIndsPerDay];
    end

    f = prePlot();
    sTitle = [sNeuronType '(n=' num2str(length(baselineFRPerMouse)) ') baseline rate on ' sLabel ' all mice'];
    sFile = [pathToRespMagnDistToClickFolder sLabel '_' sNeuronType '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_BaselineFR'];
    edges = [min(baselineFRPerMouse):1:max(baselineFRPerMouse)];
    h = histogram(baselineFRPerMouse, edges);
    postPlot(f, 'Mean baseline (spk/s)', 'Freq.', [], [], 0, max(h.Values)+1, sTitle, sFile);

    indLowerBaselineCells = find(baselineFRPerMouse<=nLowerBaselineFR);
    indHigherBaselineCells = find(baselineFRPerMouse>=nHigherBaselineFR);

    f = prePlot();
    sTitle = [sNeuronType '(n=' num2str(length(modulationFRsPerMouse(indHigherBaselineCells))) ') rate on higher baseline ' sLabel ' all mice'];
    sFile = [pathToRespMagnDistToClickFolder sLabel '_' sNeuronType '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_ModFRonHigherBaseline'];
    edges = [min(modulationFRsPerMouse(indHigherBaselineCells)):1:max(modulationFRsPerMouse(indHigherBaselineCells))];
    h = histogram(modulationFRsPerMouse(indHigherBaselineCells), edges);
    postPlot(f, 'Modulation range FR (spk/s)', 'Freq.', [], [], 0, max(h.Values)+1, sTitle, sFile);

    f = prePlot();
    sTitle = [sNeuronType '(n=' num2str(length(modulationFRsPerMouse(indLowerBaselineCells))) ') rate on lower baseline ' sLabel ' all mice'];
    sFile = [pathToRespMagnDistToClickFolder sLabel '_' sNeuronType '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_ModFRonLowerBaseline'];
    edges = [min(modulationFRsPerMouse(indLowerBaselineCells)):1:max(modulationFRsPerMouse(indLowerBaselineCells))];
    h = histogram(modulationFRsPerMouse(indLowerBaselineCells), edges);
    postPlot(f, 'Modulation range FR (spk/s)', 'Freq.', [], [], 0, max(h.Values)+1, sTitle, sFile);

    f = prePlot();
    sTitle = [sNeuronType '(n=' num2str(length(responseMagnitudesPerMouse(indHigherBaselineCells))) ') Z-score on higher baseline ' sLabel ' all mice'];
    sFile = [pathToRespMagnDistToClickFolder sLabel '_' sNeuronType '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_ZFRonHigherBaseline'];
    edges = [min(responseMagnitudesPerMouse(indHigherBaselineCells)):1:max(responseMagnitudesPerMouse(indHigherBaselineCells))];
    h = histogram(responseMagnitudesPerMouse(indHigherBaselineCells), edges);
    postPlot(f, 'Z(spk/s)', 'Freq.', [], [], 0, max(h.Values)+1, sTitle, sFile);

    f = prePlot();
    sTitle = [sNeuronType '(n=' num2str(length(responseMagnitudesPerMouse(indLowerBaselineCells))) ') Z-score on lower baseline ' sLabel ' all mice'];
    sFile = [pathToRespMagnDistToClickFolder sLabel '_' sNeuronType '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_ZFRonLowerBaseline'];
    edges = [min(responseMagnitudesPerMouse(indLowerBaselineCells)):1:max(responseMagnitudesPerMouse(indLowerBaselineCells))];
    h = histogram(responseMagnitudesPerMouse(indLowerBaselineCells), edges);
    postPlot(f, 'Z(spk/s)', 'Freq.', [], [], 0, max(h.Values)+1, sTitle, sFile);

    f = prePlot();
    sTitle = [sNeuronType '(n=' num2str(length(responseMagnitudesPerMouse)) ') Baseline vs Change in FR ' sLabel ' all mice'];
    sFile = [pathToRespMagnDistToClickFolder sLabel '_' sNeuronType '_' TRIALOUTCOMES_TO_INCLUDE_TITLE '_BaselineVSDeltaFR'];
    scatter(baselineFRPerMouse, (modulationFRsPerMouse-baselineFRPerMouse),'blue','filled');
    postPlot(f, 'Baseline (spk/s)', 'Change in FR around cue (spk/s)', [], [], [], [], sTitle, sFile);
           
    lowerCellInds = cellIndsPerMouse(indLowerBaselineCells);
    higherCellInds = cellIndsPerMouse(indHigherBaselineCells);

end