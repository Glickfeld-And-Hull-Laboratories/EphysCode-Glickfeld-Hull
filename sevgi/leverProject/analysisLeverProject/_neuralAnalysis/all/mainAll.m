% MAIN ALL for neural analyses of all units from all recordings
clc
clearvars
clearvars -global
close all

globalsAll;

collectAndSaveAllRecordings();

arrRecordings = readRecordings();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plotPSTH_WRTCellTypes(arrRecordings); % plot PSTHs of different cell types joined
plotPSTH_WRTResponseTypes(arrRecordings); % plot PSTHs of inc/dec/noCh response types joined of different cell types 

checkPSTHActivityWRTReactionTime(arrRecordings); % plot PSTH based on fast vs slow reaction times

