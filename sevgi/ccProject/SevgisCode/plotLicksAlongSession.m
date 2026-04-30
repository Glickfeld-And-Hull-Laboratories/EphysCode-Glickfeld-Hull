
globals;

arrRecordingDay = Rlist;

dayTrialStructSelected = [];

arrNaiveRecordingDays = arrRecordingDay([arrRecordingDay.day] <= 10); % get only first three (Naive) days
for indRecDay = 1:length(arrNaiveRecordingDays)
    dayTrialStruct = arrNaiveRecordingDays(indRecDay).TrialStruct;
    dayTrialStruct = dayTrialStruct(strcmp({dayTrialStruct.TrialType}, 'b') | strcmp({dayTrialStruct.TrialType}, 'j') | strcmp({dayTrialStruct.TrialType}, 'eCl') | strcmp({dayTrialStruct.TrialType}, 't_eCl')); % get only the trials with CLICK_ON + JUICE_ON

    % Get only predictive and reactive licks
    indTrial = find(strcmp({dayTrialStruct.Outcome}, 'r') | strcmp({dayTrialStruct.Outcome}, 'p'));
    foundTrials = dayTrialStruct(indTrial);
    if ~isempty(foundTrials)
        [foundTrials.mouseId] = deal(arrNaiveRecordingDays(indRecDay).mouse);
        [foundTrials.dayInd] = deal(arrNaiveRecordingDays(indRecDay).day);

        cellTrialInds = num2cell(indTrial);
        [foundTrials.trialInd] = deal(cellTrialInds{:});
        dayTrialStructSelected = [dayTrialStructSelected; foundTrials];
    end
end

f = figure;
hold on
mouseIdPrev = dayTrialStructSelected(1).mouseId;
dayIndPrev = dayTrialStructSelected(1).dayInd;
for indPlotDay=1:length(dayTrialStructSelected)
    mouseId = dayTrialStructSelected(indPlotDay).mouseId;
    dayInd = dayTrialStructSelected(indPlotDay).dayInd;
    
    if mouseId~=mouseIdPrev || dayInd~=dayIndPrev || indPlotDay==length(dayTrialStructSelected)
        xlabel('Trial index');
        ylabel('Reaction time from rewarded solenoid')
        title(['Mouse ' num2str(mouseIdPrev) ' Day=' num2str(dayIndPrev)]);
        sFileName = ['Mouse' num2str(mouseIdPrev) '_Day' num2str(dayIndPrev)];
        ylim([-.7 1]);
        formatSaveFigure(f, pathToAnalysesLicksAlignedToSolenoid, sFileName);
                
        if indPlotDay<length(dayTrialStructSelected)
            f = figure;
            hold on
            scatter(dayTrialStructSelected(indPlotDay).trialInd, dayTrialStructSelected(indPlotDay).RTj, SCATTER_POINT_SIZE, 'filled', 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'black', 'LineWidth', 2, 'MarkerFaceAlpha', ALPHA, 'MarkerEdgeAlpha', ALPHA);
            mouseIdPrev = mouseId;
            dayIndPrev = dayInd;
        end
    else
        scatter(dayTrialStructSelected(indPlotDay).trialInd, dayTrialStructSelected(indPlotDay).RTj, SCATTER_POINT_SIZE, 'filled', 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'black', 'LineWidth', 2, 'MarkerFaceAlpha', ALPHA, 'MarkerEdgeAlpha', ALPHA);
    end    
end


