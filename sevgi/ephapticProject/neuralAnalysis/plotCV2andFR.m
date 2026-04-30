function plotCV2andFR(unitGood)
    globals;

    %%%%%%%%%% PLOTTING CV2s  %%%%%%%%%%%%
    arrCV2_SS = [];
    arrCV2_CS = [];
    arrCV2_all = [];

    arrFR_SS = [];
    arrFR_CS = [];
    arrFR_all = [];

    for uid=1:length(unitGood)
        unit = unitGood(uid);         
        if strcmp(unit.neuronType,NEURON_TYPE_SS) % found a SS
            arrCV2_SS = [arrCV2_SS unit.cv2];
            arrFR_SS = [arrFR_SS unit.fr];
        end

        if strcmp(unit.neuronType,NEURON_TYPE_CS) % found a CS
            arrCV2_CS = [arrCV2_CS unit.cv2];
            arrFR_CS = [arrFR_CS unit.fr];
        end

        if ~isempty(unit.neuronType)
            arrCV2_all = [arrCV2_all unit.cv2];
            arrFR_all = [arrFR_all unit.fr];
        end
    end

    zScoredCV2_SS = (arrCV2_SS-mean(arrCV2_all))/std(arrCV2_all);
    zScoredCV2_CS = (arrCV2_CS-mean(arrCV2_all))/std(arrCV2_all);
    zScoredFR_SS = (arrFR_SS-mean(arrFR_all))/std(arrFR_all);
    zScoredFR_CS = (arrFR_CS-mean(arrFR_all))/std(arrFR_all);

    f = figure;
    f.Position = [globalX globalY globalW globalH*5];
    hold on
    jitteredXs = ones(1,length(zScoredCV2_SS))+.1*rand(1,length(zScoredCV2_SS))-.1*rand(1,length(zScoredCV2_SS));
    scatter(jitteredXs,zScoredCV2_SS, 120, 'filled', 'MarkerFaceColor', 'black'); %,'MarkerFaceAlpha','0.5');            

    jitteredXs = 3*ones(1,length(zScoredCV2_CS))+.1*rand(1,length(zScoredCV2_CS))-.1*rand(1,length(zScoredCV2_CS));
    scatter(jitteredXs,zScoredCV2_CS, 120, 'filled', 'MarkerFaceColor', 'black'); %,'MarkerFaceAlpha','0.5');            
    xlim([0 3.9]);
    ylim([-2.9 1.5]);
    yticks([-2 -1 0 1]);
    xticks([1 3]);
    xticklabels({'SS', 'CS'});
    ylabel('CV2 (z-score)');    
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5, 'TickDir','out'); % SMALL_PLOT_FONT_SIZE

    print([pathToFigureFolder '/CV2s.tif'], '-dtiff', '-r300');    
    exportgraphics(f,[pathToFigureFolder '/CV2s.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
    close all

    logger.info('main', 'CV2s are plotted!');

    %%%%%%%%%% PLOTTING Firing Rates  %%%%%%%%%%%%

    f = figure;
    f.Position = [globalX globalY globalW globalH*5];
    hold on
    jitteredXs = ones(1,length(zScoredFR_SS))+.1*rand(1,length(zScoredFR_SS))-.1*rand(1,length(zScoredFR_SS));
    scatter(jitteredXs,zScoredFR_SS, 120, 'filled', 'MarkerFaceColor', 'black'); %,'MarkerFaceAlpha','0.5');            

    jitteredXs = 3*ones(1,length(zScoredFR_CS))+.2*rand(1,length(zScoredFR_CS))-.1*rand(1,length(zScoredFR_CS));
    scatter(jitteredXs,zScoredFR_CS, 120, 'filled', 'MarkerFaceColor', 'black'); %,'MarkerFaceAlpha','0.5');            
%     xlim([0 5]);
%     ylim([0 1.3]);
    xticks([1 3]);
    yticks([-1 0 1 2 3 4]);
    xticklabels({'SS', 'CS'});
    ylabel('FR (z-score)');
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5, 'TickDir','out'); % SMALL_PLOT_FONT_SIZE

    print([pathToFigureFolder '/FRs.tif'], '-dtiff', '-r300');    
    exportgraphics(f,[pathToFigureFolder '/FRs.pdf'], 'ContentType', 'vector', 'Resolution', 1000);
    close all

    logger.info('main', 'FRs are plotted!');
end