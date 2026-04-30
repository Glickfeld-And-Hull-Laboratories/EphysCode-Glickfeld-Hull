% MAIN ALL for neural analyses of all units from all recordings
clc
clearvars
clearvars -global
close all

gpuDevice(1); % Activate GPU Device
globalsAll;

PLOT_INDIVIDUAL_PAIRS = 0;

collectAndSaveAllRecordings();
arrRecordings = readRecordings();

%%%%%%%%%%%%%%%%%%%%%%%%% 4th STEP of ANALYSES : CCG %%%%%%%%%
if ismember(ANALYSIS_STEP_4,ARR_DO_ANALYSES) 
    plotCCGs(arrRecordings);    
end