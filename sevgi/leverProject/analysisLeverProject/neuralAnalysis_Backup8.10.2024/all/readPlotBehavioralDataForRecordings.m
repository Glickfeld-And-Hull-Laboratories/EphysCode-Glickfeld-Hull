function readPlotBehavioralDataForRecordings()
    globalsAll;

    nAvg = 5; % Average over evry 5 trials
    mouseIds = {'2811', '2823', '2826', '2828', '2829'}; %'2824', 
        
    for mi = 1:length(mouseIds)
        mouseId = mouseIds{mi};
        dataFile = ['data-i' mouseId '-*.mat'];
        dirStruct = dir([pathToBehavDataOfRecFolder dataFile]);
        [~,arrDays] = sort([dirStruct.datenum]);

%         f = figure;
%         f.Position = [globalX globalY globalW globalH]; 
%         hold on

        recordingDays = cell(1,length(arrDays));
        for j=1:length(arrDays)
            
            fileName = dirStruct(arrDays(j)).name;
    
            fullFilename = [pathToBehavDataOfRecFolder fileName];
            data = load(fullFilename);
            input = data.input;        
            recordingDay =  extractBetween(fileName,[mouseId '-'],'-');
            recordingDay = recordingDay{:};
            
            trials = input.trialOutcomeCell; %(ELIMINATE_BEGINNING:end);        
            hitInds = strcmp(trials, 'success');
            faInds = strcmp(trials, 'failure');
            missInds = strcmp(trials, 'ignore');
    
            arrReactTimes = double(cell2mat(input.reactTimesMs));
            arrAvgReactTimes = round(arrayfun(@(idx) mean(arrReactTimes(idx:idx+nAvg-1)),1:nAvg:length(arrReactTimes)-nAvg+1)); % the averaged vector
            fixedHoldStartsAtTrial = find(cell2mat(input.tRandReqHoldTimeMs)==0,1);
            if isempty(fixedHoldStartsAtTrial) 
                fixedHoldStartsAtTrial=length(arrReactTimes); % means all random delay trials, so that further functions understands that there will be no fixed delay trials to plot
            end
                    
            hitIds = find(hitInds);            
            arrHitReactTimes = arrReactTimes(hitIds);
            %arrAvgHitReactTimes = round(arrayfun(@(idx) mean(arrHitReactTimes(idx:idx+nAvg-1)),1:nAvg:length(arrHitReactTimes)-nAvg+1)); % the averaged vector
            
            f = figure;
            f.Position = [globalX/5 globalY globalW globalH]; 
            hold on
            scatter(hitIds, arrHitReactTimes,40,'filled', 'LineWidth',1.5); % 'blue',
            scatter([1:length(arrReactTimes)], arrReactTimes,50);
            xline(fixedHoldStartsAtTrial, '-', {'Prediction Task'});
            
%             indsSuperHits = find(arrHitReactTimes<1000);
% %             indsSuperHits = indsSuperHits(indsSuperHits>=fixedHoldStartsAtTrial);
%             arrSuperHitReactTimes = arrHitReactTimes(indsSuperHits);
%             [p,S] = polyfit(hitIds(indsSuperHits),arrSuperHitReactTimes,1);  % Fit line to data using polyfit          
%             [y_fit,delta] = polyval(p,hitIds(indsSuperHits),S);                    % Evaluate fit equation using polyval
%             plot(hitIds(indsSuperHits),y_fit,'b-','LineWidth',2); 
%             p(1)
%             plot(hitIds(indsSuperHits),y_fit+2*delta,'b--',hitIds(indsSuperHits),y_fit-2*delta,'b--');

%             indsHitsFAs = find(arrReactTimes<3000);
%             indsHitsFAs = indsHitsFAs(indsHitsFAs>fixedHoldStartsAtTrial);
%             arrReactTimesHitsFas = arrReactTimes(indsHitsFAs);
%             [p,S] = polyfit(indsHitsFAs,arrReactTimesHitsFas,1);  % Fit line to data using polyfit          
%             [y_fit,delta] = polyval(p,indsHitsFAs,S);                    % Evaluate fit equation using polyval
%             plot(indsHitsFAs,y_fit,'r-','LineWidth',2);
%             plot(indsHitsFAs,y_fit+2*delta,'r--',indsHitsFAs,y_fit-2*delta,'r--');

            %ylim([-500 1000]);
            grid on;

            hitIds = hitIds(hitIds>=fixedHoldStartsAtTrial); 
            arrHitReactTimes = arrReactTimes(hitIds);
            yRobustSmthHit = smooth(arrHitReactTimes, .1, 'rloess');
            %thr = findchangepts(yRobustSmthHit,'MaxNumChanges',3);
            %plot(hitIds(1:thr(1)), yRobustSmthHit(1:thr(1)),'LineWidth', 2, 'Color', 'b');
            plot(hitIds, yRobustSmthHit,'LineWidth', 2, 'Color', 'b');
            
            %xline(hitIds(thr),'-',{'Threshold'});
%             xlim([hitIds(1)-2 hitIds(thr)+5]);
            title(['Reaction times on recording day ' recordingDay ' for mouse=' mouseId]);
            
%             scatter([1:length(arrAvgHitReactTimes)], arrAvgHitReactTimes,40,'filled', 'LineWidth',1.5); % 'blue',
%             scatter([1:length(arrAvgReactTimes)], arrAvgReactTimes,50);
%             %ylim([-500 1000]);
%             grid on;

            %recordingDays{j} = recordingDay;
            %close all;
        
            %legend(recordingDays, 'Location','Best','color','none');
            ylim([-500 1050]);    
            %title(['Reaction times on recording days for mouse=' mouseId]);
            xlabel('Trials');
            ylabel('Reaction Time (ms)');
            grid on;
            set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
            sFullFileName = [pathToFigureFolder BEHAV_MEASURES_OF_REC_DAYS_FOLDER mouseId '_' recordingDay '_ReactionTimeAlongTrials'];
            savefig([sFullFileName '.fig'])
            print([sFullFileName '.tif'], '-dtiff', '-r100');

            f = figure;
            f.Position = [globalX globalY globalW globalH]; 
            hold on
            hitIds = hitIds(arrHitReactTimes<500);
            arr = arrHitReactTimes(arrHitReactTimes<500);
            diffArr= diff(arr);
            scatter(hitIds(1:length(hitIds)-1), diffArr,40,'filled', 'black', 'LineWidth',1.5);
            grid on;
            %histogram(diffArr,50);
            close all;
        end
    end

end