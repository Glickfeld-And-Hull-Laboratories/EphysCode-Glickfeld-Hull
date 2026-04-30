function compareReactionTime_BehaviorVSRecording()
    globalsAll;
    close all;

    WINDOW_1 = 0;
    WINDOW_2 = 1000;
    binWidth = 10;
    edges = [WINDOW_1:binWidth:WINDOW_2];
    SIGNIFICANCE_AREA = .1; % 10% of the pdf area
    VISUAL_LATENCY = 200; % threshold for visual latency in ms
    indVisualLatency = find(edges>=VISUAL_LATENCY,1);
    totalPredTrials = 0;
      
        for a=1:length(MOUSE_IDS)
            mouseId = MOUSE_IDS{a}; %mouseIds(a);
            %mouseId = mouseId{:};
            pathToBehavOnlyData = [pathToBehavFolder mouseId '/' BEHAV_DAYS_FOLDER '/'];    
            pathToRecOnlyData = [pathToBehavFolder mouseId '/' REC_DAYS_FOLDER '/'];    
%             dataFile = ['data-i' mouseId '-*.mat'];            
%             dirStruct = dir([pathToBehavOnlyData dataFile]);
%             [~,arrDays] = sort([dirStruct.datenum]);
                        
            for i=1:length(BEHAV_DAYS_FILES)
                f = figure; %('Name', ['React times distributions for training days']);
                set(f, 'Position', [globalX globalY 1600 800]);

                fileName = BEHAV_DAYS_FILES{i};
                fullFilename = [pathToBehavOnlyData fileName];
                data = load(fullFilename);
                input = data.input;
                preHoldTimeMs = double(input.preHoldTimeMs);
                reqHoldTimeMsBehav = cell2mat(input.tTotalReqHoldTimeMs) + preHoldTimeMs;
                arrHoldTimesBehav = double(cell2mat(input.holdTimesMs));

                trainingDay =  extractBetween(fileName,[mouseId '-'],'-');
                trainingDay = trainingDay{:};
                        
                arrReactTimes = double(cell2mat(input.reactTimesMs));
                arrReactTimesWindowed = arrReactTimes(arrReactTimes>WINDOW_1 & arrReactTimes<WINDOW_2);                
                subplot(2,1,1);
                hold on;
                grid on;
                hBehav = histogram(arrReactTimesWindowed,edges);% ,'Normalization','probability', 'FaceAlpha',0.8);
                pd = fitdist(arrReactTimesWindowed', 'Kernel','Kernel','epanechnikov');
                %hBehav1 = histfit(arrReactTimesWindowed,101,'kernel')
                yPdf = pdf(pd,edges);
                yCdf = cdf(pd,edges);
                area = length(arrReactTimesWindowed) * binWidth;
                y = area * yPdf; % expand to the levels of the data
                plot(edges,y);
                indFirstSign = find(yCdf>SIGNIFICANCE_AREA,1);
                edgeValue = edges(indFirstSign);             
                xline(edgeValue, 'LineWidth',3);
                logger.info('compareReactionTime_BehaviorVSRecording', ['Sign.increase point is at ' num2str(edgeValue) ' ms for training day:' trainingDay]);

                legend([trainingDay ' \mu_{1s}=' num2str(mean(arrReactTimesWindowed),'%.2f')],'Color','none');
                title(['Reaction times distribution of mouse ' mouseId ' for training day']);
                xlim([WINDOW_1 WINDOW_2]);
                set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5);                
                legends = cell(1,length(REC_DAYS_FILES{i}));

                subplot(2,1,2);
                hold on;
                grid on;                
                %legends{1} = [trainingDay ' \mu_{1s}=' num2str(mean(arrReactTimesWindowed),'%.2f')];
                hRec = cell(1,length(REC_DAYS_FILES{i}));
                for j=1:length(REC_DAYS_FILES{i})
                    fileName = REC_DAYS_FILES{i}{j};
                    fullFilename = [pathToRecOnlyData fileName];
                    data = load(fullFilename);
                    input = data.input;
                    fixedHold = input.fixedReqHoldTimeMs;
                    recordingDay =  extractBetween(fileName,[mouseId '-'],'-');
                    recordingDay = recordingDay{:};
            
                    arrHoldTimesRec = cell2mat(input.holdTimesMs);
                    arrReactTimes = double(cell2mat(input.reactTimesMs));
                    arrReactTimesWindowed = arrReactTimes(arrReactTimes>WINDOW_1 & arrReactTimes<WINDOW_2);                    
                    hRec{j} = histogram(arrReactTimesWindowed,edges, 'FaceAlpha',0.4);
                    trialCounts = hRec{j}.Values;
                    predTrialCounts = trialCounts(indVisualLatency:indFirstSign-1);
                    totalPredTrials = totalPredTrials + sum(predTrialCounts);
                    logger.info('compareReactionTime_BehaviorVSRecording', [ num2str(sum(predTrialCounts)) ' prediction trials for recordingDay day:' recordingDay]);


%                     recordingDays = [recordingDays recordingDay ','];
                    legends{j} = [recordingDay ' predTrials=' num2str(sum(predTrialCounts)) ' \mu_{1s}=' num2str(mean(arrReactTimesWindowed),'%.2f')];
                end
                xline(edgeValue, 'LineWidth',3);
                legend(legends{:},'Color','none');
                ylabel('Reaction Time (ms)');
                title(['React times distributions of mouse ' mouseId ' for recording day(s)']);
                xlim([WINDOW_1 WINDOW_2]);
                set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5);
                sFullFileName = [pathToFigureFolder BEHAV_MEASURES_FOLDER mouseId '_IndividualSessionRTDist_' recordingDay];
                savefig([sFullFileName '.fig'])
                %print([sFullFileName '.tif'], '-dtiff', '-r100');


                %%%%%%%%%%%%%%%%%%%% HoldTime vs Req. Hold Time %%%%%%%%%%%%%%%%%%%
%                 f = figure;
%                 set(f, 'Position', [globalX globalY 1600 800]);
%                 scatter(reqHoldTimeMsBehav, arrHoldTimesBehav, 40, '*');
%                 xlabel('Req. Hold Time (ms)');
%                 ylabel('Actual Hold Time (ms)');
%                 title(['Actual vs Required hold times of mouse ' mouseId ' for training day=' trainingDay]);
%                 set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5);
%                 sFullFileName = [pathToFigureFolder BEHAV_MEASURES_FOLDER mouseId '_HoldTimes' num2str(i)];
%                 savefig([sFullFileName '.fig'])



            end  
            logger.info('compareReactionTime_BehaviorVSRecording', ['Total prediction trials=' num2str(num2str(totalPredTrials))]);
            
        end
        close all;    
end