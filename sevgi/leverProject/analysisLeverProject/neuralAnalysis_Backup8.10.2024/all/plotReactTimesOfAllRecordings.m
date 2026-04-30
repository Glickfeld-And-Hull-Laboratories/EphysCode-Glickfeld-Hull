function plotReactTimesOfAllRecordings(arrRecordings)
    globalsAll;
            
        %%%%%%%%%%%%%%% FAST REACT TRIALS %%%%%%%%%%%%%%%%%%%%%%%%%
        f = figure;
        f.Position = [globalX globalY globalW globalH]; 
        hold on

        plt = nan(1,length(arrRecordings));
        legends = cell(1,length(arrRecordings));
        for indRec = 1:length(arrRecordings)                    
            if indRec~= 3
                currentRecording = arrRecordings{1,indRec};
                indices = strfind(currentRecording.name,'_');
                recordingDay = extractBetween(currentRecording.name, indices(1)+1, indices(3)-1);
                recordingDay = recordingDay{:};
                cellRecordings = cellfun(@(row) startsWith(row,recordingDay),RECORDINGS_TO_POOL,'UniformOutput',false);
                arrWhichDay = find(cell2mat(cellRecordings));
    
                hitInds = find(currentRecording.arrHitTrials>=currentRecording.fixedHoldStartsAtTrial);
                fixedHitTrialInds = currentRecording.arrHitTrials(hitInds);
                fixedHitReactionTimes = double(currentRecording.arrReactTimes(fixedHitTrialInds));
                fastFixedHitTrialInds = fixedHitTrialInds(fixedHitReactionTimes<=MEDIAN_RT_POOLED(indRec));
                fastFixedHitReactionTimes = fixedHitReactionTimes(fixedHitReactionTimes<=MEDIAN_RT_POOLED(indRec));
                scatter(fastFixedHitTrialInds, fastFixedHitReactionTimes,60, '*', 'LineWidth',2, 'MarkerEdgeColor', COLOR_CODES_PLT{indRec},...
                    'MarkerFaceAlpha',.6,'MarkerEdgeAlpha',.6);
                smtHitReactTimes = smooth(fastFixedHitTrialInds,fastFixedHitReactionTimes, SPAN_NARROW, SMOOTH_TYPE);
                plt(indRec) = plot(fastFixedHitTrialInds,smtHitReactTimes,'color', [COLOR_CODES_PLT{indRec}, .85], 'LineWidth',3);
                indices = strfind(recordingDay,'_');
                legends{indRec} = recordingDay(1:indices-1);
            end
        end

        legends(isnan(plt))=[];
        plt(isnan(plt))=[];
        legend(plt, legends{:},'Color','none');
        title(['Fast reaction time hit trials'])
        xlabel('Trials');
        ylabel('Reaction Time (ms)');
        xlim([0 400]);
        ylim([0 600]);
        grid on;
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
        sFullFileName = [pathToFigureFolder BEHAV_MEASURES_FOLDER 'FastReactionTime_Processed.tif'];
        print(sFullFileName, '-dtiff', '-r100');

        %%%%%%%%%%%%%%% SLOW REACT TRIALS %%%%%%%%%%%%%%%%%%%%%%%%%
        f = figure;
        f.Position = [globalX globalY globalW globalH]; 
        hold on

        plt = nan(1,length(arrRecordings));
        legends = cell(1,length(arrRecordings));
        for indRec = 1:length(arrRecordings)                    
            if indRec~= 3
                currentRecording = arrRecordings{1,indRec};
                indices = strfind(currentRecording.name,'_');
                recordingDay = extractBetween(currentRecording.name, indices(1)+1, indices(3)-1);
                recordingDay = recordingDay{:};
                cellRecordings = cellfun(@(row) startsWith(row,recordingDay),RECORDINGS_TO_POOL,'UniformOutput',false);
                arrWhichDay = find(cell2mat(cellRecordings));
    
                hitInds = find(currentRecording.arrHitTrials>=currentRecording.fixedHoldStartsAtTrial);
                fixedHitTrialInds = currentRecording.arrHitTrials(hitInds);
                fixedHitReactionTimes = double(currentRecording.arrReactTimes(fixedHitTrialInds));
                slowFixedHitTrialInds = fixedHitTrialInds(fixedHitReactionTimes>MEDIAN_RT_POOLED(indRec));
                slowFixedHitReactionTimes = fixedHitReactionTimes(fixedHitReactionTimes>MEDIAN_RT_POOLED(indRec));
                scatter(slowFixedHitTrialInds, slowFixedHitReactionTimes,60, '*', 'LineWidth',2, 'MarkerEdgeColor', COLOR_CODES_PLT{indRec},...
                    'MarkerFaceAlpha',.6,'MarkerEdgeAlpha',.6);
                smtHitReactTimes = smooth(slowFixedHitTrialInds,slowFixedHitReactionTimes, SPAN_NARROW, SMOOTH_TYPE);
                plt(indRec) = plot(slowFixedHitTrialInds,smtHitReactTimes,'color', [COLOR_CODES_PLT{indRec}, .85], 'LineWidth',3);
                indices = strfind(recordingDay,'_');
                legends{indRec} = recordingDay(1:indices-1);
            end
        end

        legends(isnan(plt))=[];
        plt(isnan(plt))=[];
        legend(plt, legends{:},'Color','none');
        title(['Slow reaction time hit trials'])
        xlabel('Trials');
        ylabel('Reaction Time (ms)');
        xlim([0 400]);
        ylim([0 600]);
        grid on;
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
        sFullFileName = [pathToFigureFolder BEHAV_MEASURES_FOLDER 'SlowReactionTime_Processed.tif'];
        print(sFullFileName, '-dtiff', '-r100');
end