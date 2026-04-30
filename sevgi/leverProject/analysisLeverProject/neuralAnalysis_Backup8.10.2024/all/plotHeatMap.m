function plotHeatMap(recordingDay, neuronType, unitIds, unitDepths, trialCount, spikeRates, edges, sTitle, sFileName)
     globalsAll;
    if trialCount>0
       
    
        stepSize=4;
        
        f = figure;
        f.Position = [globalX globalY 2*globalW globalH];
        
        edgesPlt = edges(1:end-1)+(edges(2)-edges(1))/2;
        baselineInd = round(length(edgesPlt)/6);
        arrSpikeRates = cell2mat(spikeRates);    
        baselineActivity = arrSpikeRates(:,1:baselineInd);
        meanBaselineSpikeRates = mean(baselineActivity,2);
        stdBaselineSpikeRates = std(baselineActivity,0,2);
        indZeros=find(stdBaselineSpikeRates==0); % Aviod division by zero when z-scoring
        stdBaselineSpikeRates(indZeros) = 1;
        zScoredSpikeRatesFixedAll = (arrSpikeRates-meanBaselineSpikeRates)./stdBaselineSpikeRates;
        
        fun = @(edgesPlt) sprintf('%0.4f', edgesPlt);
        xvalues = cellfun(fun, num2cell(edgesPlt), 'UniformOutput',0);
        indsKeepXValues = 1:25:length(xvalues);
        indsDeleteXValues = setdiff(1:length(xvalues),indsKeepXValues);        
        [~,sortedDepthInds] = sort(unitDepths,'descend');
        
        fun2 = @(unitId, unitDepth) sprintf('unit %d (%d um)',unitId, unitDepth);
        yvalues = cellfun(fun2, num2cell(unitIds(sortedDepthInds)), num2cell(unitDepths(sortedDepthInds)), 'UniformOutput',0); 
        cdata = zScoredSpikeRatesFixedAll(sortedDepthInds,:);
        %h = heatmap(xvalues(1:stepSize:end),yvalues,cdata(:,1:stepSize:end),'Colormap',jet);
        h = heatmap(xvalues,yvalues,cdata,'Colormap',jet);
        
        fun3 = @(x) sprintf('%0.1f', str2double(x));
        xvalues = cellfun(fun3, xvalues, 'UniformOutput',0);
        xvalues(indsDeleteXValues) = {""};
        h.XDisplayLabels = xvalues; %(1:stepSize:end);

        h.Title = [recordingDay ' ' neuronType ' ' sTitle ' trialCount=' num2str(trialCount)];
        h.XLabel = 'Time from behavioral event (s)';
        h.YLabel = 'Units';
        h.FontSize = PLOT_FONT_SIZE;
%         newFontSize = ['\fontsize{' num2str(PLOT_FONT_SIZE) '}'];
%         h.Title = strcat(newFontSize,h.Title);
%         h.XLabel = strcat(newFontSize,h.XLabel);
%         h.YLabel = strcat(newFontSize,h.YLabel);
%         h.XDisplayLabels = strcat(newFontSize,h.XDisplayLabels);
%         h.YDisplayLabels = strcat(newFontSize,h.YDisplayLabels);
        
        sFullFileName = [pathToFigureFolder HEATMAP_FOLDER recordingDay '_' neuronType '_' sFileName '.tif'];
        print(sFullFileName, '-dtiff', '-r400'); 
        close all;
    else
        logger.info('main', ['Trial count is zero for ' sTitle]);
    end
end