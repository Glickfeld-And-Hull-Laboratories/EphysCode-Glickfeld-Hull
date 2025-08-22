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

mouse_list = [];
nCells_list = [];
totCells = [];

PtTratio_all = [];
PtTdist_all = [];
slope_all = [];

refViolations_all = [];
nSpikesUsed_all = [];

depth_all = [];
channel_all = [];

F1F0_all = [];

Rp_all = [];
Rc_all = [];
Zp_all = [];
Zc_all = [];

amp_all = [];
b_all = [];
PCI_yfit = [];
PCI_sse = [];
PCI_rsq = [];

ZpZcPWdist_all = [];
plaid_corr_all = [];

gDSI_all = [];
DSI_all = [];
DSI_prefdir = [];
dir_yfit = [];
dir_sse = [];
dir_rsq = [];
k1_all = [];

resp_ind_dir_all = [];
avg_resp_dir_all = [];


% V1 -- 11 13 

start=1;
for iexp = [11 13]     % 11 13 14 16 17
    mouse = expt(iexp).mouse;
    mouse_list = strvcat(mouse_list, mouse);
    date = expt(iexp).date;
        
    fprintf([mouse ' ' date '\n'])
        
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_spikeAnalysis.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_unitStructs.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_F1F0.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [mouse '_' date '_fitsSG.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_stimData.mat']))

    nCells_list         = [nCells_list, nCells];
    totCells = sum(nCells_list(1:end-1));

    PtTratio_all    = [PtTratio_all, waveformStruct.PtTratio];
    PtTdist_all     = [PtTdist_all, waveformStruct.PtTdist];
    slope_all       = [slope_all, waveformStruct.slope];

    refViolations_all   = [refViolations_all, spikingStruct.refViolations];
    nSpikesUsed_all     = [nSpikesUsed_all, spikingStruct.nSpikesUsed];
    
    depth_all   = [depth_all, goodUnitStruct.depth];
    channel_all = [channel_all, goodUnitStruct.channel];

    F1F0_all = [F1F0_all; f1overf0mat];

    Rp_all      = [Rp_all, Rp];
    Rc_all      = [Rc_all, Rc];
    Zp_all      = [Zp_all, Zp];
    Zc_all      = [Zc_all, Zc];

    amp_all     = [amp_all; amp_hat_all];
    b_all       = [b_all; b_hat_all];
    PCI_yfit    = [PCI_yfit; yfit_all];
    PCI_sse     = [PCI_sse; sse_all];
    PCI_rsq     = [PCI_rsq; R_square_all];

    ZpZcPWdist_all = [ZpZcPWdist_all, ZpZcPWdist];
    plaid_corr_all = [plaid_corr_all, plaid_corr];

    gDSI_all    = [gDSI_all, gDSI];
    DSI_all     = [DSI_all, DSI];
    DSI_prefdir = [DSI_prefdir, DSI_maxInd];
    dir_yfit    = [dir_yfit, dir_yfit_all];
    dir_sse     = [dir_sse; dir_sse_all];
    dir_rsq     = [dir_rsq; dir_R_square_all];
    k1_all      = [k1_all; k1_hat_all];

    resp_ind_dir_all = [resp_ind_dir_all; totCells+resp_ind_dir];
    avg_resp_dir_all = [avg_resp_dir_all; avg_resp_dir];

    %start = start+1;
end



%%
% ====================================
% plotting
% ====================================

ind = intersect(resp_ind_dir_all, find(DSI_all>.5));
outDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');

%% refractory period violations

    refFrac = refViolations_all ./ nSpikesUsed_all * 100;
    floorVal = 1e-5; % corresponds to 0.001% in percent units
    refFrac(refFrac == 0) = floorVal;
    
    edges = logspace(log10(floorVal), 1, 40);   % Log-spaced bins for histogram (fraction units) from 0.001% to 100%

figure; hold on
    subplot 211
        histogram(refFrac, edges, 'FaceColor',[0.5 0.5 0.5], 'EdgeColor','none');
        set(gca, 'XScale', 'log','tickdir','out');
        xlim([floorVal, 10]); % up to 10 (1000%) or adjust if needed
        xlabel('Refractory period violations (%)');
        ylabel('Number of units');
        meanVal = mean(refFrac);
        xline(meanVal, '--k', sprintf('Mean = %.2f%%', meanVal), 'LabelOrientation','horizontal');
        xline(1, '--r', '1% Threshold', 'LabelOrientation','horizontal');
        xticks([floorVal, 1e-2, 1e-1, 1, 10]);
        xticklabels({'0.001', '0.01', '0.1', '1', '10'});
    
        refFracInc = length(find(refFrac<1));
        subtitle(['All cells. ' num2str(refFracInc) '/' num2str(length(refFrac)) ' < 1%'])

     subplot 212
        histogram(refFrac(ind), edges, 'FaceColor',[0.5 0.5 0.5], 'EdgeColor','none');
        set(gca, 'XScale', 'log','tickdir','out');
        xlim([floorVal, 10]); % up to 10 (1000%) or adjust if needed
        xlabel('Refractory period violations (%)');
        ylabel('Number of units');
        meanVal = mean(refFrac(ind));
        xline(meanVal, '--k', sprintf('Mean = %.2f%%', meanVal), 'LabelOrientation','horizontal');
        xline(1, '--r', '1% Threshold', 'LabelOrientation','horizontal');
        xticks([floorVal, 1e-2, 1e-1, 1, 10]);
        xticklabels({'0.001', '0.01', '0.1', '1', '10'});
    
        refFracInc = length(find(refFrac(ind)<1));
        subtitle(['Included cells. ' num2str(refFracInc) '/' num2str(length(refFrac(ind))) ' < 1%'])

    sgtitle('Refractory period violations')
    print(fullfile([outDir, '\randDirFourPhase_CrossOri_mouse_refractoryPeriodViolations.pdf']),'-dpdf','-bestfit');


%% Fast spiking v regular spiking 

ind_depth = find(depth_all<800);


figure;
    subplot(4,3,1)
        scatter(PtTratio_all, PtTdist_all*1000, 10,'filled')
        ylabel('peak to trough dist (ms)')
        ylim([0 1])
        xlabel('peak to trough ratio')
        subtitle('all cells')
    subplot(4,3,2)
        scatter(PtTratio_all(ind_depth), PtTdist_all(ind_depth)*1000, 10,'filled')
        ylabel('peak to trough dist (ms)')
        ylim([0 1])
        xlabel('peak to trough ratio')
        subtitle('depth > -1200um')
    subplot(4,3,3)
        scatter(PtTratio_all(ind), PtTdist_all(ind)*1000, 10,'filled')
        ylabel('peak to trough dist (ms)')
        ylim([0 1])
        xlabel('peak to trough ratio')
        subtitle('resp to gratings & dsi > 0.5')

    subplot(4,3,4)
        scatter(gDSI_all,PtTdist_all*1000, 10, 'filled')
        ylabel('peak to trough dist (ms)')
        ylim([0 1])
        xlabel('gDSI_all')
    subplot(4,3,5)
        scatter(gDSI_all(ind_depth),PtTdist_all(ind_depth)*1000, 10, 'filled')
        ylabel('peak to trough dist (ms)')
        ylim([0 1])
        xlabel('gDSI_all')
    subplot(4,3,6)
        scatter(gDSI_all(ind),PtTdist_all(ind)*1000, 10, 'filled')
        ylabel('peak to trough dist (ms)')
        ylim([0 1])
        xlabel('gDSI_all')

    subplot(4,3,7)
        scatter(PtTratio_all, slope_all*1000, 10, 'filled')
        ylabel('slope')
        xlabel('peak to trough ratio')
    subplot(4,3,8)
        scatter(PtTratio_all(ind_depth), slope_all(ind_depth)*1000, 10, 'filled')
        ylabel('slope')
        xlabel('peak to trough ratio')
    subplot(4,3,9)
        scatter(PtTratio_all(ind), slope_all(ind)*1000, 10, 'filled')
        ylabel('slope')
        xlabel('peak to trough ratio')

    print(fullfile([outDir, '\randDirFourPhase_CrossOri_mouse_FS.pdf']),'-dpdf','-bestfit');





%%


[ZpZcStruct] = getZpZcStruct(avg_resp_dir_all, 'alignedTestDir');

plotZpZc4PhasePopulation(ZpZcStruct,ind,30)
sgtitle('Pattern direction selective cells at four phases')

print(fullfile([outDir, '\randDirFourPhase_CrossOri_mouse_ZpZcpopulation.pdf']),'-dpdf','-bestfit');

%%

figure;
    subplot 331
        cdfplot(amp_all(ind))
    subplot 332
        cdfplot(b_all(ind))
    subplot 333
        cdfplot(PCI_rsq(ind))


print(fullfile([outDir, '\randDirFourPhase_CrossOri_mouse_Summary.pdf']),'-dpdf','-bestfit');


%%

figure;
    pattpeak = max(PCI_yfit,[],2);    

    ind1 = intersect(find(Zp_all(1,:)>1.28),find(Zp_all(1,:)-Zc_all(1,:)>1.28));
    ind2 = intersect(find(Zp_all(2,:)>1.28),find(Zp_all(2,:)-Zc_all(2,:)>1.28));
    ind3 = intersect(find(Zp_all(3,:)>1.28),find(Zp_all(3,:)-Zc_all(3,:)>1.28));
    ind4 = intersect(find(Zp_all(4,:)>1.28),find(Zp_all(4,:)-Zc_all(4,:)>1.28));
    pattern1 = intersect(ind1,ind);
    pattern2 = intersect(ind2,ind);
    pattern3 = intersect(ind3,ind);
    pattern4 = intersect(ind4,ind);
    p = [pattern1; pattern2; pattern3; pattern4];
    [C,ia,ic] = unique(p);    
    a_counts = accumarray(ic,1);

    p1 = C(find(a_counts==1),:);
    p2 = C(find(a_counts==2),:);
    p3 = C(find(a_counts==3),:);
    p4 = C(find(a_counts==4),:);

    c1 = [0.9375    0.7813    0.7813];
    c2 = [0.9023    0.5742    0.5625];
    c3 = [0.8320    0.3672    0.3398];
    c4 = [0.7266    0.1094    0.1094];
    
    subplot(2,2,1)
        scatter(-amp_all(ind),pattpeak(ind),[],'filled')
        hold on
        scatter(-amp_all(p1),pattpeak(p1),[],c1,'filled')
        scatter(-amp_all(p2),pattpeak(p2),[],c2,'filled')
        scatter(-amp_all(p3),pattpeak(p3),[],c3,'filled')
        scatter(-amp_all(p4),pattpeak(p4),[],c4,'filled')
        ylabel('Mean pattern index (Zp-Zc)')
        xlabel('Spatial invariance (-amp)')
        ylim([-4 6])
        xlim([-6 0])
        set(gca,'TickDir','out'); axis square

print(fullfile([outDir, '\randDirFourPhase_CrossOri_mouse_SummaryLikeNicholas.pdf']),'-dpdf','-bestfit');

