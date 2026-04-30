function plotReactTimesAlongTrials()
    globalsAll;
        
%         for indFile = 1:length(RECORDINGS_UNPROCESSED)
%                 pathToRecFolder = [pathToParentRec RECORDINGS_UNPROCESSED{indFile}];
%                 dirStruct = dir([pathToRecFolder '/data-i*.mat']);
%             
%                 indices = strfind(RECORDINGS_UNPROCESSED{indFile},'_');
%                 recordingDay = RECORDINGS_UNPROCESSED{indFile};
%                 recordingDay = recordingDay(1:indices-1);
%     
%                 fileName = dirStruct.name;
%                 fullFilename = [pathToRecFolder '/' fileName];
%                 data = load(fullFilename);
%                 input = data.input;
%                 hitInds = find(strcmp(input.trialOutcomeCell, 'success'));            
%                 reactTimes = cell2mat(input.reactTimesMs);
    for a=1:length(MOUSE_IDS)
        mouseId = MOUSE_IDS{a};
        pathToRecOnlyData = [pathToBehavFolder mouseId '/' REC_DAYS_FOLDER '/'];
        for i=1:length(REC_DAYS_FILES)
            for j=1:length(REC_DAYS_FILES{i})
                fileName = REC_DAYS_FILES{i}{j};
                fullFilename = [pathToRecOnlyData fileName];
                data = load(fullFilename);
                input = data.input;
                fixedHold = input.fixedReqHoldTimeMs;
                recordingDay =  extractBetween(fileName,[mouseId '-'],'-');
                recordingDay = recordingDay{:};
        
                trials = input.trialOutcomeCell; %(ELIMINATE_BEGINNING:end);        
                hitInds = double(strcmp(trials, 'success'));
                faInds = double(strcmp(trials, 'failure'));
                missInds = double(strcmp(trials, 'ignore'));

                arrHoldTimes = cell2mat(input.holdTimesMs);
                arrReactTimes = cell2mat(input.reactTimesMs);
                fixedHoldStartsAtTrial = find(cell2mat(input.tRandReqHoldTimeMs)==0,1);
                if isempty(fixedHoldStartsAtTrial) 
                    fixedHoldStartsAtTrial=-1; % means all random delay trials, so that further functions understands that there will be no fixed delay trials to plot
                end

                f = figure;
                f.Position = [globalX globalY globalW globalH]; 
                hold on

                hitIds = find(hitInds);
                arrHitReactTimes = arrReactTimes(find(hitInds));
                scatter(hitIds, arrHitReactTimes,40,'blue','LineWidth',1.2);
                
                faIds = find(faInds);
                arrFaReactTimes = arrReactTimes(find(faInds));
                scatter(faIds, arrFaReactTimes,40,'red','filled');
                
                missIds = find(missInds);
                arrMissReactTimes = arrReactTimes(find(missInds));
                scatter(missIds, arrMissReactTimes,40,'magenta','filled');

                xline(fixedHoldStartsAtTrial,'LineWidth',1.2);

                legend({'Hit','Fa','Miss','Rand->Fixed'},'Color','none');
                title(['Reaction times along the trials on recording day=' recordingDay]);
                xlabel('Trials');
                ylabel('Reaction Time (ms)');        
                %ylim([-1 1200]);
                grid on;
                set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
                sFullFileName = [pathToFigureFolder BEHAV_MEASURES_FOLDER 'ReactionTimeAlongTrials' recordingDay];
                savefig([sFullFileName '.fig'])
                %print([sFullFileName '.tif'], '-dtiff', '-r100');
        
%                 fixedHitTrialInds = hitInds(hitInds>=fixedHoldStartsAtTrial);            
%                 fixedHitReactionTimes = double(reactTimes(fixedHitTrialInds));
%                 fixedHitTrialInds = fixedHitTrialInds(50:end);
%                 fixedHitReactionTimes = fixedHitReactionTimes(50:end);
%                 scatter(fixedHitTrialInds, fixedHitReactionTimes,40, '.', 'LineWidth',1.2, ... %'MarkerEdgeColor', COLOR_CODES_PLT{indRec},...
%                     'MarkerFaceAlpha',.6,'MarkerEdgeAlpha',.6);
%                 smtHitReactTimes = smooth(fixedHitTrialInds,fixedHitReactionTimes, SPAN_NARROW, SMOOTH_TYPE);
%                 plt(indFile) = plot(fixedHitTrialInds,smtHitReactTimes, 'LineWidth',2); % 'color', [.5, .5, .5, .85], 
%                 legends{indFile} = recordingDay;        
            end    
        end        
    end   
end