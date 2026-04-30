function plotViolinsSS(arrModulationMagnitudeNaiveDayAll, arrModulationMagnitudeHabDayAll, ...
            arrModulationMagnitudeExpertDayAll, sLabel)

    globals;


%     predMag = predMag(predMag~=0);
%     reactMag = reactMag(reactMag~=0);
%     
%     decPred = predMag(predMag<0);
%     decReact = reactMag(reactMag<0);
%     incPred = predMag(predMag>0);
%     incReact = reactMag(reactMag>0);
%     if ~isempty(predMag) && ~isempty(reactMag)
%         % Mann-Whitney U-test (Equivalent to unpaired t-test)
%         [p,h] = ranksum(incPred, incReact);
%         logger.info('plotViolins', [' Pred VS React h=' num2str(h) ' p=' num2str(p)]);
%     end
%     
%     catName = repelem(["Predictive", "Reactive"],...
%         [length(decPred), length(decReact)]);
%     
%     f = figure;
%     f.Position = [globalX globalY globalW globalH];
%     violinplot([decPred decReact],catName, ...
%     'GroupOrder', {'Predictive', 'Reactive'},...
%     'ViolinColor',[COLORS(4,1:3); COLORS(3,1:3);]); %, 'ShowMean', true, 'MarkerSize',25);
%     postPlot(f, [], 'AChange in spk/s', [], [], [], [], [' PredVSReactDec'], [pathToViolinFolder 'violin' '_PredVSReactDec']);
%             
%     catName = repelem(["Predictive", "Reactive"],...
%         [length(incPred), length(incReact)]);
%     
%     f = figure;
%     f.Position = [globalX globalY globalW globalH];
%     violinplot([incPred incReact],catName, ...
%     'GroupOrder', {'Predictive', 'Reactive'},...
%     'ViolinColor',[COLORS(4,1:3); COLORS(3,1:3);]); %, 'ShowMean', true, 'MarkerSize',25);
%     postPlot(f, [], 'AChange in spk/s', [], [], [], [], [' PredVSReactInc'], [pathToViolinFolder 'violin' '_PredVSReactInc']);
%      

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    arrModulationMagnitudeNaiveDayAll = arrModulationMagnitudeNaiveDayAll(arrModulationMagnitudeNaiveDayAll~=0);
    arrModulationMagnitudeHabDayAll = arrModulationMagnitudeHabDayAll(arrModulationMagnitudeHabDayAll~=0);
    arrModulationMagnitudeExpertDayAll = arrModulationMagnitudeExpertDayAll(arrModulationMagnitudeExpertDayAll~=0);
    
    catName = repelem(["Naive Days", "Intermediate Days", "Expert Days"],...
        [length(arrModulationMagnitudeNaiveDayAll), length(arrModulationMagnitudeHabDayAll), length(arrModulationMagnitudeExpertDayAll)]);
    
    f = figure;
    f.Position = [globalX globalY globalW globalH];
    violinplot([arrModulationMagnitudeNaiveDayAll arrModulationMagnitudeHabDayAll ...
        arrModulationMagnitudeExpertDayAll],catName, ...
    'GroupOrder', {'Naive Days', 'Intermediate Days', 'Expert Days'},...
    'ViolinColor',[COLORS(4,1:3); COLORS(3,1:3); COLORS(9,1:3)]); %, 'ShowMean', true, 'MarkerSize',25);
    postPlot(f, [], 'AChange in spk/s', [], [], [], [], [sLabel ' Lick aligned'], [pathToViolinFolder 'violin' sLabel '_lickAligned']);
            
    if ~isempty(arrModulationMagnitudeNaiveDayAll) && ~isempty(arrModulationMagnitudeHabDayAll)
        % Mann-Whitney U-test (Equivalent to unpaired t-test)
        [p,h] = ranksum(arrModulationMagnitudeNaiveDayAll, arrModulationMagnitudeHabDayAll);
        logger.info('plotViolins', [sLabel ' Rew Resp: NaiveDays to HabDays h=' num2str(h) ' p=' num2str(p)]);
    end

    if ~isempty(arrModulationMagnitudeHabDayAll) && ~isempty(arrModulationMagnitudeExpertDayAll)
        [p,h] = ranksum(arrModulationMagnitudeHabDayAll, arrModulationMagnitudeExpertDayAll);
        logger.info('plotViolins', [sLabel ' Rew Resp: HabDays to ExpDays h=' num2str(h) ' p=' num2str(p)]);
    end

    if ~isempty(arrModulationMagnitudeNaiveDayAll) && ~isempty(arrModulationMagnitudeExpertDayAll)
        [p,h] = ranksum(arrModulationMagnitudeNaiveDayAll, arrModulationMagnitudeExpertDayAll);
        logger.info('plotViolins', [sLabel ' Rew Resp: NaiveDays to ExpDays h=' num2str(h) ' p=' num2str(p)]);
    end

    decNaive = arrModulationMagnitudeNaiveDayAll(arrModulationMagnitudeNaiveDayAll<0);
    decHab = arrModulationMagnitudeHabDayAll(arrModulationMagnitudeHabDayAll<0);
    decExpert = arrModulationMagnitudeExpertDayAll(arrModulationMagnitudeExpertDayAll<0);

    incNaive = arrModulationMagnitudeNaiveDayAll(arrModulationMagnitudeNaiveDayAll>0);
    incHab = arrModulationMagnitudeHabDayAll(arrModulationMagnitudeHabDayAll>0);
    incExpert = arrModulationMagnitudeExpertDayAll(arrModulationMagnitudeExpertDayAll>0);

    catName = repelem(["Naive Days", "Intermediate Days", "Expert Days"],...
        [length(decNaive), length(decHab), length(decExpert)]);
    
    f = figure;
    f.Position = [globalX globalY globalW globalH];
    violinplot([decNaive decHab decExpert],catName, ...
    'GroupOrder', {'Naive Days', 'Intermediate Days', 'Expert Days'},...
    'ViolinColor',[COLORS(4,1:3); COLORS(3,1:3); COLORS(9,1:3)]); %, 'ShowMean', true, 'MarkerSize',25);
    postPlot(f, [], 'AChange in spk/s', [], [], [], [], [sLabel ' Dec Lick aligned'], [pathToViolinFolder 'violin' sLabel '_lickAlignedDec']);
    
    catName = repelem(["Naive Days", "Intermediate Days", "Expert Days"],...
        [length(incNaive), length(incHab), length(incExpert)]);
    
    f = figure;
    f.Position = [globalX globalY globalW globalH];
    violinplot([incNaive incHab incExpert],catName, ...
    'GroupOrder', {'Naive Days', 'Intermediate Days', 'Expert Days'},...
    'ViolinColor',[COLORS(4,1:3); COLORS(3,1:3); COLORS(9,1:3)]); %, 'ShowMean', true, 'MarkerSize',25);
    postPlot(f, [], 'AChange in spk/s', [], [], [], [], [sLabel ' Inc Lick aligned'], [pathToViolinFolder 'violin' sLabel '_lickAlignedInc']);

    if ~isempty(decHab) && ~isempty(decNaive)
        [p,h] = ranksum(decHab, decNaive, "tail","left","alpha",0.025);
        logger.info('plotViolins', [sLabel ' decHab to decNaive h=' num2str(h) ' p=' num2str(p)]);
    end

    if ~isempty(decExpert) && ~isempty(decHab)
        [p,h] = ranksum(decExpert, decHab); %,  "tail","left","alpha",0.025)
        logger.info('plotViolins', [sLabel ' decExpert to decHab h=' num2str(h) ' p=' num2str(p)]);
    end

    if ~isempty(decExpert) && ~isempty(decNaive)
        [p,h] = ranksum(decExpert, decNaive, "tail","left","alpha",0.025);
        logger.info('plotViolins', [sLabel ' decExpert to decNaive h=' num2str(h) ' p=' num2str(p)]);
    end

    if ~isempty(incHab) && ~isempty(incNaive)
        [p,h] = ranksum(incHab, incNaive, "tail","right","alpha",0.025);
        logger.info('plotViolins', [sLabel ' incHab to incNaive h=' num2str(h) ' p=' num2str(p)]);
    end

    if ~isempty(incExpert) && ~isempty(incHab)
        [p,h] = ranksum(incExpert,incHab);
        logger.info('plotViolins', [sLabel ' incExpert to incHab h=' num2str(h) ' p=' num2str(p)]);
    end

    if ~isempty(incExpert) && ~isempty(incNaive)
        [p,h] = ranksum(incExpert, incNaive, "tail","right","alpha",0.025);
        logger.info('plotViolins', [sLabel ' incExpert to incNaive h=' num2str(h) ' p=' num2str(p)]);
    end
end