function structUnitIDvsPow = powerScatterPredvsReact(unitIDs, powerValues, sLabel)

    globals;
           
    subTitle = {'Naive', 'Int', 'Expert'};
    pred = 2;
    react = 3;
    
    for iTrPhase=1:3 % Naive Int Expert
        sTitle = [subTitle{iTrPhase} '_' sLabel '_' NEURON_TYPE];
        sFile = [pathToPowerScatterFolder subTitle{iTrPhase} '_' sLabel '_' NEURON_TYPE];
    
        predUnitIds = unitIDs{pred,iTrPhase};
        reactUnitIds = unitIDs{react,iTrPhase};
    
        predUnitPows = powerValues{pred,iTrPhase};
        reactUnitPows = powerValues{react,iTrPhase};
    
        arrReactPow = [];
        arrPredPow = [];
        unitIDsPerPow = {};
        for jUnit=1:length(predUnitIds)
            ind = find(strcmp(predUnitIds{jUnit},reactUnitIds)); % find the same unit in reactive trials
            if ~isempty(ind)
                predUnitPow = predUnitPows(jUnit);
                reactUnitPow = reactUnitPows(ind);
                
                unitIDsPerPow{length(unitIDsPerPow)+1} = predUnitIds{jUnit};
                arrPredPow = [arrPredPow predUnitPow];
                arrReactPow = [arrReactPow reactUnitPow];                
            end
        end
    
        structUnitIDvsPow(iTrPhase).unitIDs = unitIDsPerPow;
        structUnitIDvsPow(iTrPhase).arrPredPow = arrPredPow;
        structUnitIDvsPow(iTrPhase).arrReactPow = arrReactPow;

        f = prePlot(); 
        scatter(arrPredPow, arrReactPow, 100, 'k', 'filled');
        % Unity line spanning the full data range
        minVal = min([min(arrPredPow), min(arrReactPow)]);
        maxVal = max([max(arrPredPow), max(arrReactPow)]);
        plot([minVal, maxVal], [minVal, maxVal], 'k--', 'LineWidth', 2);
        postPlot(f, 'Predictive power (dB/Hz)', 'Reactive power (dB/Hz)', [], [], [], [], ...
            sTitle, sFile);
    end
end