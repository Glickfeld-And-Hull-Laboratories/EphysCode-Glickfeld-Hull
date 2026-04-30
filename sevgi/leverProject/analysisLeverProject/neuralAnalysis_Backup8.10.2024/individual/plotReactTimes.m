function plotReactTimes(arrReactTimes, arrHitTrials, arrFaTrials, arrMissTrials, arrStimTurnedOnTrials, arrReqHoldTimes, fixedHoldStartsAtTrial, leverHoldTimes, leverReleaseTimesGLX)
           
    globals;
    maxY_reactTime = 3000; % 800; %
    maxY_initiation = 15; % 7
    somePlotThreshold = 3000;
    nAvg = 5; % Average over evry 5 trials
    
    %arrAvgReactTimes = arrayfun(@(idx) mean(arrReactTimes(idx:idx+nAvg-1)),1:nAvg:length(arrReactTimes)-nAvg+1)'; % the averaged vector
    %arrAvgReactTimes = arrReactTimes;

    arrReactTimesFixed=[];
    arrReactTimesRandom=arrReactTimes; % Usually I start with random hold time, then switch to fixed hold time
    arrReqHoldTimesRandom = [];
    if fixedHoldStartsAtTrial>0
        arrReactTimesRandom = double(arrReactTimes(1:fixedHoldStartsAtTrial-1));
        arrReactTimesFixed = double(arrReactTimes(fixedHoldStartsAtTrial:end));
        
        indRandomHitTrials = arrHitTrials(arrHitTrials<fixedHoldStartsAtTrial);
        arrHitReactTimesRandom = arrReactTimes(indRandomHitTrials);

        indFixedHitTrials = arrHitTrials(arrHitTrials>=fixedHoldStartsAtTrial);        
        arrHitReactTimesFixed = arrReactTimes(indFixedHitTrials);
        indFixedFaTrials = arrFaTrials(arrFaTrials>=fixedHoldStartsAtTrial);        
        arrFaReactTimesFixed = arrReactTimes(indFixedFaTrials);
        indFixedMissTrials = arrMissTrials(arrMissTrials>=fixedHoldStartsAtTrial);        
        arrMissReactTimesFixed = arrReactTimes(indFixedMissTrials);
        
        arrReqHoldTimesRandom = arrReqHoldTimes(1:fixedHoldStartsAtTrial-1);
        arrReqHoldTimesFixed = arrReqHoldTimes(fixedHoldStartsAtTrial:end);
        arrHitReqHoldTimesRandom = arrReqHoldTimes(indRandomHitTrials);
        arrHitReqHoldTimesFixed = arrReqHoldTimes(indFixedHitTrials);

        leverHoldTimesRandom = leverHoldTimes(1:fixedHoldStartsAtTrial-1);
        leverHoldTimesFixed = leverHoldTimes(fixedHoldStartsAtTrial:end);

        leverReleaseTimesGLXRandom = leverReleaseTimesGLX(1:fixedHoldStartsAtTrial-1);
        leverReleaseTimesGLXFixed = leverReleaseTimesGLX(fixedHoldStartsAtTrial:end);
    else
        arrReactTimesRandom = double(arrReactTimes);
        
        arrHitReactTimesRandom = double(arrReactTimes(arrHitTrials));
        arrHitReactTimesFixed = [];

        arrReqHoldTimesRandom = arrReqHoldTimes;
        arrHitReqHoldTimesRandom = arrReqHoldTimes(arrHitTrials);

        leverHoldTimesRandom = leverHoldTimes;
        leverReleaseTimesGLXRandom = leverReleaseTimesGLX;
    end
    %arrReactTimes = arrReactTimes(arrReactTimes<somePlotThreshold);
    
    leverHoldTimesRandom = leverHoldTimesRandom(2:end); % Shift by one to align holdtime of trial(n+1) with releaseTime of trial(n)
    randomTrialInitiationDuration = leverHoldTimesRandom - leverReleaseTimesGLXRandom(1:end-1);

    leverHoldTimesFixed = leverHoldTimesFixed(2:end); % Shift by one to align holdtime of trial(n+1) with releaseTime of trial(n)
    fixedTrialInitiationDuration = leverHoldTimesFixed - leverReleaseTimesGLXFixed(1:end-1);

    %************************ PLOTTING ********************************
    f = figure;
    f.Position = [globalX globalY globalW globalH];       
    
    subplot(3,2,1)    
    hold on;
    grid on;
    arrAvgReactTimes = arrayfun(@(idx) mean(arrReactTimesRandom(idx:idx+nAvg-1)),1:nAvg:length(arrReactTimesRandom)-nAvg+1)'; % the averaged vector
    scatter([1:length(arrAvgReactTimes)], arrAvgReactTimes,40,'b','filled', 'MarkerFaceAlpha', .6,'MarkerEdgeColor','k');
    %ylim([0 maxY]);
    xlabel('Trials');
    ylabel('React time (ms)');    
    title(['Random delay react times mean=' num2str(mean(arrReactTimesRandom),'%.2f') ' median=' num2str(median(arrReactTimesRandom),'%.2f')])

    subplot(3,2,2)
    arrAvgReactTimes = arrayfun(@(idx) mean(arrReactTimesFixed(idx:idx+nAvg-1)),1:nAvg:length(arrReactTimesFixed)-nAvg+1)'; % the averaged vector
    scatter([1:length(arrAvgReactTimes)], arrAvgReactTimes,40,'b','filled', 'MarkerFaceAlpha', .6,'MarkerEdgeColor','k');
    hold on;
    grid on;
    ylim([0 maxY_reactTime]);
    xlabel('Trials');    
    title(['Fixed delay react times mean=' num2str(mean(arrReactTimesFixed),'%.2f') ' median=' num2str(median(arrReactTimesFixed),'%.2f')])
        
    subplot(3,2,3)
    hold on;
    grid on;
    scatter(randomTrialInitiationDuration, arrReactTimesRandom(1:end-1), 40, 'blue','filled', 'MarkerFaceAlpha', .6,'MarkerEdgeColor','k');
    [r,pCorr] = corrcoef(randomTrialInitiationDuration,arrReactTimesRandom(1:end-1));
    sTitle = '';
    if pCorr(1,2)<=P_VALUE_THRESHOLD
        sTitle = [' r=' num2str(r(1,2),'%.2f')];
    end
    xlabel('Trial initiation duration (s)');
    ylabel('React time (ms)'); 
    title(['Random delay trial initiation times ' sTitle]);

    subplot(3,2,4)
    hold on;
    grid on;
    scatter(fixedTrialInitiationDuration, arrReactTimesFixed(1:end-1), 40, 'blue','filled', 'MarkerFaceAlpha', .6,'MarkerEdgeColor','k');
    [r,pCorr] = corrcoef(fixedTrialInitiationDuration,arrReactTimesFixed(1:end-1));
    sTitle = '';
    if pCorr(1,2)<=P_VALUE_THRESHOLD
        sTitle = [' r=' num2str(r(1,2),'%.2f')];
    end
    ylim([0 maxY_reactTime]);
    xlabel('Trial initiation duration (s)');
    ylabel('React time (ms)'); 
    title(['Fixed delay trial initiation times ' sTitle]);

    subplot(3,2,5)    
    hold on;
    grid on;
    scatter([1:length(arrReactTimesRandom(1:end-1))], randomTrialInitiationDuration, 40, 'blue','filled', 'MarkerFaceAlpha', .6,'MarkerEdgeColor','k');
    ylim([0 30]);
    xlabel('Trials');
    ylabel('Trial initiation duration (s)'); 
    title(['Random delay trial initiation times along the trials']);

%     histogram(arrReactTimesRandom,30)
%     grid on;
%     ylim([0 100]);
%     xlabel('React Times');
%     ylabel('Freq.');
%     title('Random delay trials');
    
    subplot(3,2,6)
    hold on;
    grid on;
    scatter([1:length(arrReactTimesFixed(1:end-1))], fixedTrialInitiationDuration, 40, 'blue','filled', 'MarkerFaceAlpha', .6,'MarkerEdgeColor','k');
    [r,pCorr] = corrcoef([1:length(arrReactTimesFixed(1:end-1))],fixedTrialInitiationDuration);
    sTitle = '';
    if pCorr(1,2)<=P_VALUE_THRESHOLD
        sTitle = [' r=' num2str(r(1,2),'%.2f')];
    end
    ylim([0 maxY_initiation]);
    xlabel('Trials');
    ylabel('Trial initiation duration (s)'); 
    title(['Fixed delay trial initiation times along the trials ' sTitle]);

%     histogram(arrReactTimesFixed, 30)
%     grid on;
%     ylim([0 100]);
%     xlabel('React Times (ms)');
%     title('Fixed delay trials');
   
    % Give common xlabel, ylabel and title to your figure
%     han=axes(f,'visible','off');         
%     han.XLabel.Visible='on';
%     han.YLabel.Visible='on';
%     ylabel(han,'Time (ms)');
%     xlabel(han,'Trials');
    
    sgtitle(['Mouse=' num2str(MOUSE_ID) ' recording=' num2str(dateOfRecording)])
    print([pathToFigureFolder 'Mouse' num2str(MOUSE_ID) '_ReactionTime_' num2str(maxY_initiation) '_' num2str(maxY_reactTime)], '-dtiff', '-r600');     

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    f = figure('Name', ['Cue Predict - React times along the same session']);
    set(f, 'Position', [globalX 200 1000 900]);
    hold on
    grid on
    scatter(indFixedHitTrials, arrHitReactTimesFixed,40,'blue','LineWidth',1.2);    
    scatter(indFixedFaTrials, arrFaReactTimesFixed,40,'red','filled');    
    scatter(indFixedMissTrials, arrMissReactTimesFixed,40,'magenta','filled');
    
    smtHitReactTimes = smooth(indFixedHitTrials,double(arrHitReactTimesFixed), SPAN_NARROW, SMOOTH_TYPE);
    plot(indFixedHitTrials,smtHitReactTimes,'b-', 'LineWidth',3);    
    legend({'Hit','Fa','Miss','Smoothed hit react'});
    title(['React times of mouse=' num2str(MOUSE_ID) ' recording=' num2str(dateOfRecording)])
    xlabel('Trials');
    ylabel('Reaction Time (ms)');
    %xlim([0 400]);
    ylim([-50 3100]);
    set(gca,'FontName','Times New Roman','FontWeight','bold', 'FontSize',PLOT_FONT_SIZE,'LineWidth',1.5)   
    print([pathToFigureFolder 'Mouse' num2str(MOUSE_ID) '_ReactTimesHitFaMiss_Day_' num2str(dateOfRecording)], '-dtiff', '-r100');
        
end