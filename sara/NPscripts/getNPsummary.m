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

ind_sigRF_all = [];
totalSpikesUsed_all = [];
avgImgZscore_all = [];
cells_sigRFbyTime_On_all = [];
cells_sigRFbyTime_Off_all = [];


% V1 -- 11 13 

start=1;
for iexp = [11 13 18 19 20 21 22]     % 11 13 14 16 17
    mouse = expt(iexp).mouse;
    mouse_list = strvcat(mouse_list, mouse);
    date = expt(iexp).date;
        
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_spikeAnalysis.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_unitStructs.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_F1F0.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [mouse '_' date '_fitsSG.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_stimData.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [mouse '-' date '_spatialRFs.mat']))

    fprintf([mouse ' ' date ', nCells=' num2str(nCells) '\n'])

    ind_sigRF_all       = [ind_sigRF_all; ind_sigRF];
    cells_sigRFbyTime_On_all = [cells_sigRFbyTime_On_all; cells_sigRFbyTime_On];
    cells_sigRFbyTime_Off_all = [cells_sigRFbyTime_Off_all; cells_sigRFbyTime_Off];
    totalSpikesUsed_all = [totalSpikesUsed_all, totalSpikesUsed];
    avgImgZscore_all    = [avgImgZscore_all; averageImageZscore];

    
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




ind = intersect(resp_ind_dir_all, find(DSI_all>.5));
outDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');

%%
% ====================================
% plotting
% ====================================



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


figure;
    subplot 211
        histogram(refFrac, edges, 'FaceColor',[0.8 0.8 0.8], 'EdgeColor','none');
        meanVal = mean(refFrac);
        xline(meanVal, '--k', sprintf('Mean = %.2f%%', meanVal), 'LabelOrientation','horizontal'); hold on
        refFracInc = length(find(refFrac<1));
     subplot 211
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
        axis square
        refFracInc = length(find(refFrac(ind)<1));
        subtitle(['Included cells. ' num2str(refFracInc) '/' num2str(length(refFrac(ind))) ' < 1%'])
    sgtitle('Refractory period violations')
    print(fullfile([outDir, '\randDirFourPhase_CrossOri_mouse_refractoryPeriodViolations_1plot.pdf']),'-dpdf','-bestfit');


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




%%

ind_RF = find(ind_sigRF_all>0);

indRFint = intersect(ind, ind_RF);



figure;
[ZpZcStruct] = getZpZcStruct(avg_resp_dir_all, 'alignedTestDir');
plotZpZc4PhasePopulation(ZpZcStruct,indRFint,30)
sgtitle('Pattern direction selective cells at four phases')

print(fullfile([outDir, '\randDirFourPhase_CrossOri_mouse_ZpZcpopulation_withRFs.pdf']),'-dpdf','-bestfit');



%%
close all

doGabor = 0;
indF = indRFint;


% Initialize for activecontour fit
    maskOn = zeros([length(indF) 29 52]);
    maskOff = zeros([length(indF) 29 52]);
    STAimage = zeros([length(indF) 29 52]);
    r = [];
    rsqAC = [];
    it_all = [];
    ACfit = [];

if doGabor == 1
    % Initialize for gabor fit
        gaborpatch = [];
        gaborfit = struct();
        rsqGabor = [];
        options.visualize = 0;
        options.parallel = 0;
        options.shape   = 'elliptical';
        options.runs    = 48;
end

for ii = 1:length(indF)
    ic = indF(ii);
    
    for it = 1:5
        avgImgZscore(it,:,:) = medfilt2(squeeze(avgImgZscore_all(ic,it,:,:)));     % Grab avg zscore STA images for all time points
    end

    it_sigRFon  = find(cells_sigRFbyTime_On_all(ic,:)>0);        % which time points did I find a RF subunit?
    it_sigRFoff = find(cells_sigRFbyTime_Off_all(ic,:)>0);
    it_sigRF    = unique([it_sigRFon, it_sigRFoff]);
    
    [m, it_best] = max(sum(sum(abs(avgImgZscore(it_sigRF,:,:)),2),3),[],1);      % of the time points I found an RF subunit, which time point has the max zscore?

    zscoreSTA_bestit    = squeeze(avgImgZscore(it_sigRF(it_best),:,:));    
    zscoreSTA_filt      = medfilt2(zscoreSTA_bestit);                        % zscore STA to use for fits, Rsq, etc

    if any(it_sigRF(it_best) == it_sigRFon)      % if there are any on subunits at the chosen time point...
        [bw]           = findRFsubunit(zscoreSTA_filt,1);
        maskOn(ii,:,:)  = bw;
    end

    if any(it_sigRF(it_best) == it_sigRFoff)
        [bw]           = findRFsubunit(zscoreSTA_filt,2);
        maskOff(ii,:,:) = bw;
    end

    [B,Lon]         = bwboundaries(squeeze(maskOn(ii,:,:)),'noholes');
    [B,Loff]        = bwboundaries(squeeze(maskOff(ii,:,:)),'noholes');

    STAimage(ii,:,:)    = zscoreSTA_filt;
    it_all(ii)          = it_sigRF(it_best);

    rsq  = getRsqLinearRegress_SG(zscoreSTA_filt, (Lon - Loff));

    ACfit(ii,:,:) = (Lon - Loff);
    rsqAC(ii) = rsq;


    if doGabor == 1
        results             = fit2dGabor_SG(zscoreSTA_filt,options);
        gaborfit(ii).fit    = results.fit;
        gaborpatch(ii,:,:)  = results.patch;
        rsqGabor(ii)        = results.r2;
    end
end



%% Plot STAs and fits

% Initialize for polar plots
x       = [-150:30:180];
x_rad   = deg2rad(x);
[avg_resp_grat, avg_resp_plaid] = getAlignedGratPlaidTuning(avg_resp_dir_all);


for ii = 1:length(indF)
    ic = indF(ii);

    avgImgZscore = squeeze(avgImgZscore_all(ic,:,:,:));     % Grab avg zscore STA images for all time points

    figure;
        subplot(6,3,1)
            for im = 1:4
                polarplot([x_rad x_rad(1)], [avg_resp_plaid(ic,:,im) avg_resp_plaid(ic,1,im)])
                hold on
            end
            polarplot([x_rad x_rad(1)], [avg_resp_grat(ic,:) avg_resp_grat(ic,1)],'k', 'LineWidth',2) 
        for it = 1:5
            subplot(6,3,it+1)
                imagesc(medfilt2(squeeze(avgImgZscore(it,:,:)))); colormap('gray'); clim([-6 6])
                if it == it_all(ii)
                    subtitle('best it','FontWeight', 'Bold')
                end
        end
        subplot(6,3,7)
            imagesc(squeeze(ACfit(ii,:,:))); colormap('gray'); clim([-1 1])
            subtitle(['activecontour fit - rsq: ' num2str(round(rsqAC(ii),2))])
         subplot(6,3,8)
            imagesc(medfilt2(squeeze(ACfit(ii,:,:)))); colormap('gray');  clim([-1 1]) 
            subtitle(['activecontour fit smooth - rsq: ' num2str(round(rsqACsmth(ii),2))])
         subplot(6,3,9)
            imagesc(squeeze(gaborpatch(ii,:,:))); colormap('gray');   
            subtitle(['gabor fit - rsq: ' num2str(round(rsqGabor(ii),2))])
         

    movegui('center')
    sgtitle(['cell ' num2str(ic)])
    print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs', [num2str(ii) '_cell' num2str(ic) '.pdf']), '-dpdf','-fillpage')
    close all
end


%%

avg_F1F0 = mean(F1F0_all,2);

idx = sub2ind(size(F1F0_all), (1:size(F1F0_all,1))', DSI_prefdir(:));
pref_F1F0 = F1F0_all(idx);

PCI_max = max(PCI_yfit,[],2);


figure;
    subplot(3,3,1)
        scatter(rsqAC,rsqGabor, 20, 'filled'); hold on
        subtitle('Rsq')
        xlabel('activecontour')
        ylabel('gabor')
        ylim([0 1])
        xlim([0 1])
        refline(1)
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,3,2)
        scatter(rsqACsmth,rsqGabor, 20, 'filled'); hold on
        subtitle('Rsq')
        xlabel('activecontour smooth')
        ylabel('gabor')
        ylim([0 1])
        xlim([0 1])
        refline(1)
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,3,3)
        scatter(totalSpikesUsed_all(indF)',rsqGabor, 20, 'filled'); hold on
        subtitle('num spikes used for STA')
        xlabel('nspikes')
        ylabel('gabor rsq')
        ylim([0 1])
        set(gca, 'XScale', 'log')
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,3,4)
        scatter(refFrac(indF)',rsqGabor, 20, 'filled'); hold on
        subtitle('% ref period violations')
        xlabel('% ref period violations')
        ylabel('gabor rsq')
        ylim([0 1])
        set(gca, 'XScale', 'log')
        set(gca, 'TickDir', 'out'); axis square
    print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs', ['controlanalyses.pdf']), '-dpdf','-fillpage')

 figure;
    sgtitle('F1/F0 plots')
    subplot(3,3,5)
        scatter(avg_F1F0(indF),rsqAC, 20, 'filled'); hold on
        subtitle('F1/F0, avg across dir')
        xlabel('F1/F0')
        ylabel('AC rsq')
        ylim([0 1])
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,3,6)
        scatter(pref_F1F0(indF),rsqAC, 20, 'filled'); hold on
        subtitle('F1/F0, pref dir')
        xlabel('F1/F0')
        ylabel('AC rsq')
        ylim([0 1])
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,3,7)
        histogram(pref_F1F0(ind),[0:.2:2]); hold on
        histogram(pref_F1F0(indF),[0:.2:2])
        subtitle('linearity (f1/f0), included DS cells')
        xlabel('F1F0, pref dir')
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,3,8)
        scatter(pref_F1F0(ind),b_all(ind), 20, 'filled'); hold on
        scatter(pref_F1F0(indF),b_all(indF), 20, 'filled')
        subtitle('Mean pattern index')
        xlabel('F1F0, prefdir')
        ylabel('fit baseline')
        % xlim([0 1])
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,3,9)
        scatter(pref_F1F0(ind),PCI_max(ind), 20, 'filled'); hold on
        scatter(pref_F1F0(indF),PCI_max(indF), 20, 'filled')
        subtitle('Peak pattern index')
        xlabel('F1F0, pref dir')
        ylabel('fit peak')
        % xlim([0 1])
        set(gca, 'TickDir', 'out'); axis square
    print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs', 'F1F0_comparisons.pdf'), '-dpdf','-fillpage')

movegui('center')

%%
for i = 1:size(gaborfit,2)
    fits(i) = gaborfit(i).fit;  % store results in array of structs
end

    % a                     amplitude (peak amplitude of the Gabor)
    % b                     DC offset (baseline response)
    % x0 & y0               center location of the Gaussian envelope (RF center in x and y coordinates
    % sigmax & sigmay       standard deviations of the Gaussian envelope along its major and minor axes
    % theta                 orientation of the Gabor filter in radians (0=horizontal, pi/2=vertical)
    % phi                   something phase related?
    % lambda                wavelength (spatial period)
    % phase                 phase offset of sinusoid

sigmax_all = [fits(:).sigmax];
sigmay_all = [fits(:).sigmay];
gamma_all = max(sigmax_all, sigmay_all) ./ min(sigmax_all, sigmay_all);  % Aspect ratio always >= 1

indGoodFit = find(rsqGabor>0.3);

rsq_use = rsqGabor(indGoodFit)';
figure;
    sgtitle('gabor fits -- looking at aspect ratio (>4 are cells 36 & 39)')
    subplot(3,2,1)
        histogram(gamma_all,20); hold on
        histogram(gamma_all(indGoodFit),20)
        subtitle('gabor - aspect ratio, 1=circle')
        xlabel('aspect ratio (gamma)')
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,2,2)
        scatter(gamma_all(indGoodFit),b_all(indF(indGoodFit)),20,rsq_use,'filled'); colormap('sky'); colorbar; hold on
        subtitle('gabor - mean pattern index')
        xlabel('aspect ratio (gamma)')
        ylabel('fit baseline')
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,2,3)
        scatter(gamma_all(indGoodFit),PCI_max(indF(indGoodFit)),20,rsq_use,'filled'); colormap('sky'); colorbar; hold on
        subtitle('gabor - peak pattern index')
        xlabel('aspect ratio (gamma)')
        ylabel('fit peak')
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,2,4)
        scatter(gamma_all(indGoodFit),amp_all(indF(indGoodFit)),20,rsq_use,'filled'); colormap('sky'); colorbar; hold on
        subtitle('gabor - modulation amplitude')
        xlabel('aspect ratio (gamma)')
        ylabel('modulation amplitude')
        set(gca, 'TickDir', 'out'); axis square
    print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs', ['gabor_AspectRatio.pdf']), '-dpdf','-fillpage')


    
    
    clear props
    for ic = 1:length(indF)
        bw2 = squeeze(ACfit(ic,:,:));
        bw2(find(bw2<0)) = 1;
        [B,L] = bwboundaries(bw2,'noholes');
        % get properties of shape
        clear tmp
        tmp = regionprops(bw2, ...
                 'Area', ...
                 'BoundingBox', ...
                 'Circularity', ...
                 'Centroid', ...
                 'ConvexHull', ...
                 'Eccentricity', ...
                 'EquivDiameter', ...
                 'Extent', ...
                 'FilledArea',...
                 'MajorAxisLength', ...
                 'MinorAxisLength', ...
                 'Orientation');
          props(ic) = tmp;
    end
    
    aspRatio = [props.MajorAxisLength]./[props.MinorAxisLength];
    circ = [props.Circularity];
    boundingbox = [props.BoundingBox];
        box = boundingbox(:,3:4:207).*boundingbox(:,4:4:208);
    diam = [props.EquivDiameter];
    area = [props.FilledArea];

rsq_use = rsqAC(indGoodFit)';

figure;
    sgtitle('AC fits -- looking at aspect ratio')
    subplot(3,2,1)
        histogram(aspRatio,20); hold on
        histogram(aspRatio(indGoodFit),20)
        subtitle('AC - aspect ratio, 1=circle')
        xlabel('aspect ratio')
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,2,2)
        scatter(aspRatio(indGoodFit),b_all(indF(indGoodFit)),20,rsq_use,'filled'); colormap('sky'); colorbar; hold on
        subtitle('AC - mean pattern index')
        xlabel('aspect ratio')
        ylabel('fit baseline')
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,2,3)
        scatter(aspRatio(indGoodFit),PCI_max(indF(indGoodFit)),20,rsq_use,'filled'); colormap('sky'); colorbar; hold on
        subtitle('AC - peak pattern index')
        xlabel('aspect ratio')
        ylabel('fit peak')
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,2,4)
        scatter(aspRatio(indGoodFit),amp_all(indF(indGoodFit)),20,rsq_use,'filled'); colormap('sky'); colorbar; hold on
        subtitle('AC - modulation amplitude')
        xlabel('aspect ratio')
        ylabel('modulation amplitude')
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,2,5)
        scatter(PCI_max(indF(indGoodFit)),rsqGabor(indGoodFit),20,'filled'); hold on    
        scatter(PCI_max(indF(indGoodFit)),rsqAC(indGoodFit),20,'filled'); hold on
        subtitle('AC - patterny-ness v. rsq')
        ylim([0 1])
        xlabel('fit peak')
        ylabel('rsq, red-AC')
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,2,6)
        scatter(amp_all(indF(indGoodFit)).*-1,PCI_max(indF(indGoodFit)),20,aspRatio(indGoodFit),'filled'); colormap('sky'); colorbar; hold on    
        subtitle('amp x peak, aspect ratio')
        ylim([-5 5])
        xlim([-6 0])
        xlabel('modulation amp')
        ylabel('ft peak')
        set(gca, 'TickDir', 'out'); axis square
    print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs', ['activecontour_AspectRatio.pdf']), '-dpdf','-fillpage')



figure;
    subplot(3,2,1)
        scatter(amp_all(indF(indGoodFit)).*-1,PCI_max(indF(indGoodFit)),20,diam(indGoodFit),'filled'); colormap('sky'); colorbar; hold on    
        subtitle('amp x peak, equivdiam')
        ylim([-5 5])
        xlim([-6 0])
        xlabel('modulation amp')
        ylabel('ft peak')
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,2,2)
        scatter(amp_all(indF(indGoodFit)).*-1,PCI_max(indF(indGoodFit)),20,box(indGoodFit),'filled'); colormap('sky'); colorbar; hold on    
        subtitle('amp x peak, boundingbox')
        ylim([-5 5])
        xlim([-6 0])
        xlabel('modulation amp')
        ylabel('ft peak')
        set(gca, 'TickDir', 'out'); axis square
    subplot(3,2,3)
        scatter(amp_all(indF(indGoodFit)).*-1,PCI_max(indF(indGoodFit)),20,area(indGoodFit),'filled'); colormap('sky'); colorbar; hold on    
        subtitle('amp x peak, filledarea')
        ylim([-5 5])
        xlim([-6 0])
        xlabel('modulation amp')
        ylabel('ft peak')
        set(gca, 'TickDir', 'out'); axis square
    print(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs', ['activecontour_AspectRatio2.pdf']), '-dpdf','-fillpage')




    %%

% gaborpatch - (nCells, xDim, yDim)
% ACfit - (nCells, xDim, yDim)




