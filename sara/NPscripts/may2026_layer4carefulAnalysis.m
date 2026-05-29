%% Script to finalize layers for all cells

%%

close all; clear all; clc;
base = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara';
summaryDir = fullfile(base, 'Analysis', 'Neuropixel', 'CrossOri', 'RandDirRandPhase', 'summaries');
doPlot = 1;
ds = 'NP_CrossOri_RandDirRandPhase_exptlist';
svName = 'randPhase';
eval(ds)
rc = behavConstsAV;
sampRate = 30000;
nexp = size(expt,2);
%max_dist = 10;





% V1 -- 11 13 18 19 20 21 22 23 24 25 26 28

% V1 -- 13 18 19 20 21 22 23 25 26 28 29, throwing out 11 for RF position,
% throwing out 24 because eye camera frames collected ~= timestamps of frames

expts = [13 18 19 20 21 22 23 24 25 26 27 28 29 30 31];

start=1;
for iexp                = expts   
    mouse               = expt(iexp).mouse;
    date                = expt(iexp).date;
    probeTipDepth       = expt(iexp).z;
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_spikeAnalysis.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_unitStructs.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_F1F0.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [mouse '_' date '_fitsSG.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_stimData.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [mouse '-' date '_spatialRFs.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_stimStruct.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_layerStruct.mat']))
    load(fullfile(base, '\Analysis\Neuropixel', date, [mouse '-' date '-findlayer4-CSD.mat']))


    manualFirstCh       = firstChInBrain;
    manualFirstChDepth  = firstChInBrain*10;
    L4_firstDepth       = L4_DepthShal;
    L4_lastDepth        = L4_DepthDeep;

    figure;
    subplot 221
        depth_all   = -manualFirstChDepth + [goodUnitStruct.depth];
        depth_resp  = -manualFirstChDepth + [goodUnitStruct(resp_ind_dir).depth];
        FR_all      = [goodUnitStruct.FR];
        FR_resp   = [goodUnitStruct(resp_ind_dir).FR];
        scatter(FR_all, depth_all, 15, 'filled')
        hold on
        scatter(FR_resp, depth_resp, 15, 'filled')
        yline(0,'r') % manualFirstChDepth
        yline(-(manualFirstChDepth + probeTipDepth),'c')
        yline(L4_firstDepth,'k')
        yline(L4_lastDepth,'k')
        yline(-1100,'r')
        xlim([-5 50]); 
        xlabel('avg FR')
        ylim([-3000 1000])
        set(gca,'TickDir','out')

    subplot 223
        depth_all   = -manualFirstChDepth + [goodUnitStruct.depth];
        depth_resp  = -manualFirstChDepth + [goodUnitStruct(resp_ind_dir).depth];
        averages    = [waveformStruct.average];
        max_all     = abs(min(averages,[],1));
        max_resp   = max_all(resp_ind_dir);
        scatter(max_all, depth_all, 15, 'filled')
        hold on
        scatter(max_resp, depth_resp, 15, 'filled')
        yline(0,'r') % manualFirstChDepth
        yline(-(manualFirstChDepth + probeTipDepth),'c')
        yline(L4_firstDepth,'k')
        yline(L4_lastDepth,'k')
        yline(-1100,'r')
        % xlim([-5 50]); 
        xlabel('amp')
        ylim([-3000 1000])
        set(gca,'TickDir','out')
        movegui('center')

        idx = sub2ind(size(f1overf0mat), (1:size(f1overf0mat,1))', DSI_maxInd(:));
        pref_F1F0 = f1overf0mat(idx);

    subplot 222
        depth_all   = -manualFirstChDepth + [goodUnitStruct.depth];
        depth_resp  = -manualFirstChDepth + [goodUnitStruct(resp_ind_dir).depth];
        averages    = [waveformStruct.average];
        prefF1F0_all     = pref_F1F0;
        prefF1F0_resp   = pref_F1F0(resp_ind_dir);
        scatter(prefF1F0_all, depth_all, 15, 'filled')
        hold on
        scatter(prefF1F0_resp, depth_resp, 15, 'filled')
        yline(0,'r') % manualFirstChDepth
        yline(-(manualFirstChDepth + probeTipDepth),'c')
        yline(L4_firstDepth,'k')
        yline(L4_lastDepth,'k')
        yline(-1100,'r')
        % xlim([-5 50]); 
        xlabel('f1f0')
        ylim([-3000 1000])
        set(gca,'TickDir','out')
        movegui('center')

     subplot 224
        depth_all   = -manualFirstChDepth + [goodUnitStruct.depth];
        depth_resp  = -manualFirstChDepth + [goodUnitStruct(resp_ind_dir).depth];
        averages    = [waveformStruct.average];
        k1_all     = k1_hat_all'.*FR_all;
        k1_resp   = k1_all(resp_ind_dir);
        scatter(k1_all, depth_all, 15, 'filled')
        hold on
        scatter(k1_resp, depth_resp, 15, 'filled')
        yline(0,'r') % manualFirstChDepth
        yline(-(manualFirstChDepth + probeTipDepth),'c')
        yline(L4_firstDepth,'k')
        yline(L4_lastDepth,'k')
        yline(-1100,'r')
        % xlim([-5 50]); 
        xlabel('tuning width * FR')
        ylim([-3000 1000])
        set(gca,'TickDir','out')
        movegui('center')

    sgtitle([num2str(iexp) ', ' mouse ' ' date])
    print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Figures\LG_meetings\260512_depthAnalysis', [num2str(iexp) '-' date '-cellDepths.pdf']), '-dpdf','-fillpage')

end



%% bottom of the brain

bottomOfBrainDepth = [];

bottomOfBrainDepth(1)   = 1100; %13
bottomOfBrainDepth(2)   = 1100; %18
bottomOfBrainDepth(3)   = 1100; %19
bottomOfBrainDepth(4)   = 1100; %20
bottomOfBrainDepth(5)   = 1300; %21
bottomOfBrainDepth(6)   = 1100; %22
bottomOfBrainDepth(7)   = 1300; %23
bottomOfBrainDepth(8)   = 1100; %24
bottomOfBrainDepth(9)   = 1300; %25
bottomOfBrainDepth(10)  = 1300; %26
bottomOfBrainDepth(11)  = 1300; %27
bottomOfBrainDepth(12)  = 1200; %28
bottomOfBrainDepth(13)  = 1100; %29
bottomOfBrainDepth(14)  = 1000; %30
bottomOfBrainDepth(15)  = 1500; %31