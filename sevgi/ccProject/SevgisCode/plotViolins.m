function plotViolins(arrModulationMagnitudeRewRespCSNaiveDay1, arrModulationMagnitudeCueRespCSNaiveDay1, ...
                arrModulationMagnitudeRewRespCSHabDay1, arrModulationMagnitudeCueRespCSHabDay1, ...
                arrModulationMagnitudeRewRespCSHabDayN, arrModulationMagnitudeCueRespCSHabDayN, ...
                arrModulationMagnitudeRewRespCSExpertDayAll, arrModulationMagnitudeCueRespCSExpertDayAll, sLabel)

    globals;

    arrModulationMagnitudeRewRespCSNaiveDay1 = arrModulationMagnitudeRewRespCSNaiveDay1(arrModulationMagnitudeRewRespCSNaiveDay1~=0);
    arrModulationMagnitudeCueRespCSNaiveDay1 = arrModulationMagnitudeCueRespCSNaiveDay1(arrModulationMagnitudeCueRespCSNaiveDay1~=0);
    arrModulationMagnitudeRewRespCSHabDay1 = arrModulationMagnitudeRewRespCSHabDay1(arrModulationMagnitudeRewRespCSHabDay1~=0);
    arrModulationMagnitudeCueRespCSHabDay1 = arrModulationMagnitudeCueRespCSHabDay1(arrModulationMagnitudeCueRespCSHabDay1~=0);
    arrModulationMagnitudeRewRespCSHabDayN = arrModulationMagnitudeRewRespCSHabDayN(arrModulationMagnitudeRewRespCSHabDayN~=0);
    arrModulationMagnitudeCueRespCSHabDayN = arrModulationMagnitudeCueRespCSHabDayN(arrModulationMagnitudeCueRespCSHabDayN~=0);
    arrModulationMagnitudeRewRespCSExpertDayAll = arrModulationMagnitudeRewRespCSExpertDayAll(arrModulationMagnitudeRewRespCSExpertDayAll~=0);
    arrModulationMagnitudeCueRespCSExpertDayAll = arrModulationMagnitudeCueRespCSExpertDayAll(arrModulationMagnitudeCueRespCSExpertDayAll~=0);

    catName = repelem(["Naive Day 1", "Intermediate Day 1", "Intermediate Day N", "Expert Day All"],...
        [length(arrModulationMagnitudeRewRespCSNaiveDay1), length(arrModulationMagnitudeRewRespCSHabDay1), ...
        length(arrModulationMagnitudeRewRespCSHabDayN), length(arrModulationMagnitudeRewRespCSExpertDayAll)]);
    
    f = figure;
    f.Position = [globalX globalY globalW globalH];
    violinplot([arrModulationMagnitudeRewRespCSNaiveDay1 arrModulationMagnitudeRewRespCSHabDay1 ...
        arrModulationMagnitudeRewRespCSHabDayN arrModulationMagnitudeRewRespCSExpertDayAll],catName, ...
    'GroupOrder', {'Naive Day 1', 'Intermediate Day 1', 'Intermediate Day N', 'Expert Day All'},...
    'ViolinColor',[COLORS(4,1:3); COLORS(3,1:3); COLORS(2,1:3); COLORS(9,1:3)]); %, 'ShowMean', true, 'MarkerSize',25);
    postPlot(f, [], 'Change in spk/s', [], [], [], [], [sLabel ' RewResp'], [pathToViolinFolder 'violin' sLabel 'RewResp']);
        
    catName = repelem(["Intermediate Day 1", "Intermediate Day N", "Expert Day All"],...
        [length(arrModulationMagnitudeCueRespCSHabDay1), length(arrModulationMagnitudeCueRespCSHabDayN), length(arrModulationMagnitudeCueRespCSExpertDayAll)]);
    
    f = figure;
    f.Position = [globalX globalY globalW globalH];
    violinplot([arrModulationMagnitudeCueRespCSHabDay1 ...
        arrModulationMagnitudeCueRespCSHabDayN arrModulationMagnitudeCueRespCSExpertDayAll],catName, ...
    'GroupOrder', {'Intermediate Day 1', 'Intermediate Day N', 'Expert Day All'},...
    'ViolinColor',[COLORS(3,1:3); COLORS(2,1:3); COLORS(9,1:3)]); %, 'ShowMean', true, 'MarkerSize',25);
    postPlot(f, [], 'Change in spk/s', [], [], [], [], [sLabel  ' CueResp'], [pathToViolinFolder 'violin' sLabel  'CueResp']);

    
    if ~isempty(arrModulationMagnitudeRewRespCSNaiveDay1) && ~isempty(arrModulationMagnitudeRewRespCSHabDay1)
        % Mann-Whitney U-test (Equivalent to unpaired t-test)
        [p,h] = ranksum(arrModulationMagnitudeRewRespCSNaiveDay1, arrModulationMagnitudeRewRespCSHabDay1);
        logger.info('plotViolins', ['Rew Resp: NaiveDay1 to HabDay1 h=' num2str(h) ' p=' num2str(p)]);
    end

    if ~isempty(arrModulationMagnitudeRewRespCSHabDay1) && ~isempty(arrModulationMagnitudeRewRespCSHabDayN)
        [p,h] = ranksum(arrModulationMagnitudeRewRespCSHabDay1, arrModulationMagnitudeRewRespCSHabDayN);
        logger.info('plotViolins', ['Rew Resp: HabDay1 to HabDayN h=' num2str(h) ' p=' num2str(p)]);
    end

    if ~isempty(arrModulationMagnitudeRewRespCSHabDayN) && ~isempty(arrModulationMagnitudeRewRespCSExpertDayAll)
        [p,h] = ranksum(arrModulationMagnitudeRewRespCSHabDayN, arrModulationMagnitudeRewRespCSExpertDayAll);
        logger.info('plotViolins', ['Rew Resp: HabDayN to ExpertDayAll h=' num2str(h) ' p=' num2str(p)]);
    end

    if ~isempty(arrModulationMagnitudeCueRespCSNaiveDay1) && ~isempty(arrModulationMagnitudeCueRespCSHabDay1)
        [p,h] = ranksum(arrModulationMagnitudeCueRespCSNaiveDay1, arrModulationMagnitudeCueRespCSHabDay1);
        logger.info('plotViolins', ['Cue Resp: NaiveDay1 to HabDay1 h=' num2str(h) ' p=' num2str(p)]);
    end

    if ~isempty(arrModulationMagnitudeCueRespCSHabDay1) && ~isempty(arrModulationMagnitudeCueRespCSHabDayN)
        [p,h] = ranksum(arrModulationMagnitudeCueRespCSHabDay1, arrModulationMagnitudeCueRespCSHabDayN);
        logger.info('plotViolins', ['Cue Resp: HabDay1 to HabDayN h=' num2str(h) ' p=' num2str(p)]);
    end

    if ~isempty(arrModulationMagnitudeCueRespCSHabDayN) && ~isempty(arrModulationMagnitudeCueRespCSExpertDayAll)
        [p,h] = ranksum(arrModulationMagnitudeCueRespCSHabDayN, arrModulationMagnitudeCueRespCSExpertDayAll);
        logger.info('plotViolins', ['Cue Resp: HabDayN to ExpertDayAll h=' num2str(h) ' p=' num2str(p)]);
    end
% 
%     [p1,h1] = ranksum(decHab, decNaive, "tail","left","alpha",0.025)
%     [p2,h2] = ranksum(decExpert, decHab) %,  "tail","left","alpha",0.025)
%     [p3,h3] = ranksum(decExpert, decNaive, "tail","left","alpha",0.025)
% 
%     [p4,h4] = ranksum(incHab, incNaive, "tail","right","alpha",0.025)
%     [p5,h5] = ranksum(incExpert,incHab)
%     [p6,h6] = ranksum(incExpert, incNaive, "tail","right","alpha",0.025)
end