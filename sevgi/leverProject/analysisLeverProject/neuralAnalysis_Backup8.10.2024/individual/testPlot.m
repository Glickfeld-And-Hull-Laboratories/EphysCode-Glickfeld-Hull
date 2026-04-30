function testPlot(distr1, distr2, unitID, neuronType, strTrialType, sGlobalTitle, str, sLocalTitle, sXLabel, sLegend1, sLegend2, sFileName, xLim)
    if ~isempty(distr1) && ~isempty(distr2)
        [h, p] = kstest2(distr1, distr2);
        if h==1 % significant difference between distributions
            sTitle = [sGlobalTitle sLocalTitle ' (p=' num2str(p,'%.2f') ') ' str];
            plotPdfCdf(distr1, distr2, unitID, neuronType, sTitle, strTrialType, sXLabel, sLegend1, sLegend2, sFileName, xLim);
        end
    end
end