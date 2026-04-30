function [lowerCellInds, middleCellInds, upperCellInds] = buildDistOfResponsesAndPlotPSTHs(miceVSDays, miceVSSelectedDay1, miceVSSelectedDayN, behavDataForRecordingDays, unitCSs, unitSSs, sLabel)

    globals;

    if FROM_CS_TO_SS
        nLowerResponseThreshold = 5;
        nUpperResponseThreshold = 10;
        sNeuronType = NEURON_TYPE_CS;
    else
        if MODE_ALIGNMENT == MODE_ALIGNMENT_TO_CLICK
            nLowerResponseThreshold = -3;        
            nUpperResponseThreshold = 3;
        elseif MODE_ALIGNMENT == MODE_ALIGNMENT_TO_LICK
            nLowerResponseThreshold = -4;        
            nUpperResponseThreshold = 4;
        end        
        sNeuronType = NEURON_TYPE_SS;
    end

    responseMagnitudesPerMouse = [];
    cellIndsPerMouse = [];

    %%%%%%%%%%%%% FIRST, GET ALL DAYS %%%%%%%%%%%%%%%
    for ind=1:length(miceVSDays) % Loop through each mouse
        mouseId = miceVSDays{ind,1};
        days = miceVSDays{ind,2};
        [cellIndsPerDay, responseMagnitudesPerDay] = ...
            buildDistOfResponses(behavDataForRecordingDays, unitCSs, unitSSs, mouseId, days, sLabel); % Loop through each day

        responseMagnitudesPerMouse = [responseMagnitudesPerMouse responseMagnitudesPerDay];
        cellIndsPerMouse = [cellIndsPerMouse cellIndsPerDay];
    end

    f = prePlot();
    sTitle = [sNeuronType '(n=' num2str(length(responseMagnitudesPerMouse)) ') rate on ' sLabel ' all mice'];
    sFile = [pathToRespMagnDistToClickFolder sLabel '_' sNeuronType '_' TRIALOUTCOMES_TO_INCLUDE_TITLE];
    edges = [min(responseMagnitudesPerMouse):1:max(responseMagnitudesPerMouse)];
    h = histogram(responseMagnitudesPerMouse, edges);
    postPlot(f, 'z-score(spk/s)', 'Freq.', [], [], 0, max(h.Values)+1, sTitle, sFile);
        
    indLowerCells = find(responseMagnitudesPerMouse<=nLowerResponseThreshold);
    indMidCells = find(responseMagnitudesPerMouse>nLowerResponseThreshold & responseMagnitudesPerMouse<nUpperResponseThreshold);
    indUpperCells = find(responseMagnitudesPerMouse>=nUpperResponseThreshold);

    lowerCellInds = cellIndsPerMouse(indLowerCells);
    middleCellInds = cellIndsPerMouse(indMidCells);
    upperCellInds = cellIndsPerMouse(indUpperCells);

end