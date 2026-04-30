function plotReactTimesAlongTrials()
    globalsAll;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 0_0st STEP of ANALYSES :  Plot Unprocessed behavioral-only analyses %%%%%%%%%%%%%%%%%%%%
    if ismember(ANALYSIS_STEP_0_0,ARR_DO_ANALYSES)

        f = figure;
        f.Position = [globalX globalY globalW globalH]; 
        hold on
        
        plt = nan(1,length(RECORDINGS_UNPROCESSED));
        legends = cell(1,length(RECORDINGS_UNPROCESSED));
        for indFile = 1:length(RECORDINGS_UNPROCESSED)
                pathToRecFolder = [pathToParentRec RECORDINGS_UNPROCESSED{indFile}];
                dirStruct = dir([pathToRecFolder '/data-i*.mat']);
            
                indices = strfind(RECORDINGS_UNPROCESSED{indFile},'_');
                recordingDay = RECORDINGS_UNPROCESSED{indFile};
                recordingDay = recordingDay(1:indices-1);
    
                fileName = dirStruct.name;
                fullFilename = [pathToRecFolder '/' fileName];
                data = load(fullFilename);
                input = data.input;
                hitInds = find(strcmp(input.trialOutcomeCell, 'success'));            
                reactTimes = cell2mat(input.reactTimesMs);
                fixedHoldStartsAtTrial = find(cell2mat(input.tRandReqHoldTimeMs)==0,1);
                if isempty(fixedHoldStartsAtTrial) 
                    fixedHoldStartsAtTrial=-1; % means all random delay trials, so that further functions understands that there will be no fixed delay trials to plot
                end
        
                fixedHitTrialInds = hitInds(hitInds>=fixedHoldStartsAtTrial);            
                fixedHitReactionTimes = double(reactTimes(fixedHitTrialInds));
                fixedHitTrialInds = fixedHitTrialInds(50:end);
                fixedHitReactionTimes = fixedHitReactionTimes(50:end);
    %             scatter(fixedHitTrialInds, fixedHitReactionTimes,40, '.', 'LineWidth',1.2, ... %'MarkerEdgeColor', COLOR_CODES_PLT{indRec},...
    %                 'MarkerFaceAlpha',.6,'MarkerEdgeAlpha',.6);
                smtHitReactTimes = smooth(fixedHitTrialInds,fixedHitReactionTimes, SPAN_NARROW, SMOOTH_TYPE);
                plt(indFile) = plot(fixedHitTrialInds,smtHitReactTimes, 'LineWidth',2); % 'color', [.5, .5, .5, .85], 
                legends{indFile} = recordingDay;        
        end    
    
        legend(plt, legends{:},'Color','none');
        title(['Reaction times of hit trials'])
        xlabel('Trials');
        ylabel('Reaction Time (ms)');
        xlim([50 350]);
        ylim([-1 1200]);
        grid on;
        set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
        sFullFileName = [pathToFigureFolder BEHAV_MEASURES_FOLDER 'ReactionTime_Unprocessed.tif'];
        print(sFullFileName, '-dtiff', '-r100');
    end
end