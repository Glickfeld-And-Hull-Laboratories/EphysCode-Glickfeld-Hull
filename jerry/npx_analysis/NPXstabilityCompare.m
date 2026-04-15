clear all; close all; clc; clear global;

iexp = 6; % Choose experiment
refractoryViolationThresh   = 0.002;     % 2 ms

%% read data from ks4 and phy2
[exptStruct] = iniExptStruct(iexp); % get exptStruct

baseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
fPathBaseIn = fullfile(baseDir, '\jerry\analysis\neuropixel',exptStruct.mouse,exptStruct.date,'kilosort4');
cd(fPathBaseIn);
plotCentral = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\jerry\analysis\neuropixel\plot_central';
fout = fullfile(baseDir, '\jerry\analysis\neuropixel',exptStruct.mouse,exptStruct.date,'analysis_output');
mkdir(fout);

[cluster_struct,~,~,~,~,~,goodUnitStruct,~,~] = ImportKSdataNew();  % Marie's function to tidy up ks4 and phy2 outputs for further analysis

%% pull info out of mWorks data

stimStruct = NPXcreateStimStructMulti(exptStruct);
