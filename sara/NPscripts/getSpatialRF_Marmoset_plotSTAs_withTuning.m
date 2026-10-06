
clear all; clc; close all

runloc = 1;   % Where is this script being run? 1 == Hubel, 2 == Wiesel
% res = 'LR';


%%
if runloc == 1    % Hubel
    dirBase = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home';
elseif runloc == 2    % Wiesel
    dirBase = 'home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home';
else
    error('Location not valid. 1 == Hubel, 2 == Wiesel.')
end

%%

res = 'LR'; 
    load(fullfile(dirBase, 'sara', 'Analysis', 'Neuropixel', 'marmosetFromNicholas', 'spatialRFs', ['elf3_spatialRFs_Wiesel_' res '.mat']))
    
    nTrials             = size(imageMatrix,1);
    nFramesPerTrials    = size(imageMatrix,2);
    nSizeStimSide       = size(imageMatrix,3);
    
    % Subtract the mean white noise stimulus, because it is nonzero
    wnMean          = mean(mean(imageMatrix,1),2);
    wnMeanAvg       = mean(wnMean(:));
    wnMeanDiffMat   = wnMean-wnMeanAvg;
    
    averageImagesAll_shuffledMinusMean  = averageImagesAll_shuffled - reshape(reshape(reshape(wnMeanDiffMat,[],nSizeStimSide,nSizeStimSide),[],1,nSizeStimSide,nSizeStimSide),[],1,1,nSizeStimSide,nSizeStimSide);
    averageImagesAll_MinusMean          = averageImagesAll - reshape(reshape(wnMeanDiffMat,[],nSizeStimSide,nSizeStimSide),[],1,nSizeStimSide,nSizeStimSide);
    
    shuffledMean                        = squeeze(mean(averageImagesAll_shuffledMinusMean,1));
    shuffledStd                         = squeeze(std(averageImagesAll_shuffledMinusMean,0,1));
    
    averageImageZscoreLR = (averageImagesAll_MinusMean-shuffledMean)./shuffledStd;   % z-score: subtract mean from the raw value and then divide all by standard deviation

    clear averageImagesAll averageImagesAll_shuffled averageImagesAll_MinusMean shuffledMean shuffledStd


res = 'HR'; 
    load(fullfile(dirBase, 'sara', 'Analysis', 'Neuropixel', 'marmosetFromNicholas', 'spatialRFs', ['elf3_spatialRFs_Wiesel_' res '.mat']))
    
    nTrials             = size(imageMatrix,1);
    nFramesPerTrials    = size(imageMatrix,2);
    nSizeStimSide       = size(imageMatrix,3);
    
    % Subtract the mean white noise stimulus, because it is nonzero
    wnMean          = mean(mean(imageMatrix,1),2);
    wnMeanAvg       = mean(wnMean(:));
    wnMeanDiffMat   = wnMean-wnMeanAvg;
    
    averageImagesAll_shuffledMinusMean  = averageImagesAll_shuffled - reshape(reshape(reshape(wnMeanDiffMat,[],nSizeStimSide,nSizeStimSide),[],1,nSizeStimSide,nSizeStimSide),[],1,1,nSizeStimSide,nSizeStimSide);
    averageImagesAll_MinusMean          = averageImagesAll - reshape(reshape(wnMeanDiffMat,[],nSizeStimSide,nSizeStimSide),[],1,nSizeStimSide,nSizeStimSide);
    shuffledMean                        = squeeze(mean(averageImagesAll_shuffledMinusMean,1));
    shuffledStd                         = squeeze(std(averageImagesAll_shuffledMinusMean,0,1));
    
    averageImageZscoreHR                = (averageImagesAll_MinusMean-shuffledMean)./shuffledStd;   % z-score: subtract mean from the raw value and then divide all by standard deviation

    clear averageImagesAll averageImagesAll_shuffled averageImagesAll_MinusMean shuffledMean shuffledStd



%% zscore thresh for low res

nCells = size(averageImageZscoreLR,1);
nSizeStimSide = 16;
zthreshold = 2.5;

averageImageZscoreThresh = [];
for iCell = 1:nCells
    for it  = 1:5
        for ix = 1:nSizeStimSide
            for iy = 1:nSizeStimSide
               if averageImageZscoreLR(iCell,it,ix,iy) > zthreshold
                   averageImageZscoreThresh(iCell,it,ix,iy) = 1;
               elseif averageImageZscoreLR(iCell,it,ix,iy) < -zthreshold
                   averageImageZscoreThresh(iCell,it,ix,iy) = -1;
               else
                   averageImageZscoreThresh(iCell,it,ix,iy) = 0;
               end
            end
        end
    end
end

cells_sigRFbyTime_On   = nan(nCells, length(beforeSpike));
cells_sigRFbyTime_Off   = nan(nCells, length(beforeSpike));

for iCell = 1:nCells
    for it = 1:(length(beforeSpike))
        threshMat = squeeze(averageImageZscoreThresh(iCell,it,:,:));
        foundOn = false;
        foundOff = false;
        for ix = 1:(nSizeStimSide-2+1)
            for iy = 1:(nSizeStimSide-2+1)
                patch       = threshMat(ix:ix+1, iy:iy+1);
                numPos = sum(patch(:) == 1);   % count 1s
                numNeg = sum(patch(:) == -1);   % count -1s
                if numPos >= 3
                    foundOn = true;
                end
                if numNeg >= 3
                    foundOff = true;
                end
            end
            if foundOn & foundOff
                break; % Exit ix for loop early
            end
        end
        cells_sigRFbyTime_On(iCell,it)  = foundOn;   % 1 if found, 0 otherwise
        cells_sigRFbyTime_Off(iCell,it) = foundOff;   % 1 if found, 0 otherwise
    end 
end

sigRF_timepoints = cells_sigRFbyTime_On+cells_sigRFbyTime_Off;

ind_sigRF = sum(cells_sigRFbyTime_On,2)+sum(cells_sigRFbyTime_Off,2);


%% Local contrast analysis to choose best beforeSpikeTimepoint  

for ic = 1:length(cellsIdx)
    is=1;
        for it = [1 2 3 4 5]
            xtempz(:,:) = medfilt2(imgaussfilt(squeeze(averageImageZscoreLR(ic,it,:,:)),1)); %3:27,12:36
            if isnan(xtempz(1,1))
                xtempz(:,:) = ones(size(xtempz,1),size(xtempz,2));
            end
            jtempz(:,:) = rangefilt(xtempz(:,:),ones(5));
            j = squeeze(jtempz(:,:));
            q(it) = prctile(j(:),99);
            c(ic,it) = q(it);
            if it ==5
                 q(6) = 1;   % set extra 6th timepoint (0.01s) to 1 to make sure if there is a peak at 5th timepoint, it can be detected
            end
            localConMap_data(ic,it,:,:) = xtempz;
            localConMap_map(ic,it,:,:) = jtempz;
            is=is+3;        
        end
        i = pickPeak_rfCI(q);   % Pick peak in 0.95 CI, but if there are two peaks, take the second
        m = q(i);
        bestTimePoint(ic,1) = i; % best time point
        bestTimePoint(ic,2) = m; % max q90 value

        data = medfilt2(imgaussfilt(squeeze(averageImageZscoreLR(ic,i,:,:)),1));
        [az, el] = getRFcenter(data);
        azs(ic) = az;
        els(ic) = el;
    clear xtempz jtempz q m i
end


%% load tuning of cells

load(fullfile(dirBase,'sara','Analysis','Neuropixel','marmosetFromNicholas','marmosetV1_elf3','randDirFourPhase_CrossOri_marmosetV1_elf3_fitsSG.mat'))

ind_DS = intersect(find(DSI>0.25),find(g_dsi>0.2));
    [DSIstruct_new] = getDSIstruct_new(avg_resp_dir);
    gratResp        = DSIstruct_new.resp;
    maxGratResp     = max(gratResp,[],2);
    minGratResp     = min(gratResp,[],2);
ind_peakFRmin   = find(maxGratResp>1);
ind_rangeFRmin  = find(maxGratResp > (abs(minGratResp)*2));
ind_FR = intersect(ind_peakFRmin,ind_rangeFRmin);

cellsIdx_new = intersect(intersect(ind_DS,resp_ind_dir),ind_FR);
cellsToPlot = ismember(cellsIdx,cellsIdx_new);

nCells  = length(cellsIdx);

% get pref dir
gratResps           = squeeze(avg_resp_dir(cellsIdx,:,1,1,1));
[maxDir, indDir]    = max(gratResps,[],2);
dirs                = 0:30:330;

% get aligned tuning curves
[avg_resp_grat, avg_resp_plaid, sem_resp_grat, sem_resp_plaid] = getAlignedGratPlaidTuning(avg_resp_dir);
x       = [-150:30:180];
x_rad   = deg2rad(x);

% for PCI fit
PCI = (Zp-Zc);
phase = [0 90 180 270];
phase_range = 0:1:359;

% get colors
colors  = getColors;



%% fit with DoG

fprintf('Fitting models to data... \n')

    indRF_pix   = find(ind_sigRF>0);
    indRF_con   = find(bestTimePoint(:,2)>1);
    idxInt      = intersect(indRF_pix, indRF_con);  % both mask and contrast method

cellsIdx_RFsInc = intersect(idxInt, find(cellsToPlot));
cellsIdx_RFs = cellsIdx(cellsIdx_RFsInc);

clear STA_for_fitting
for ic = 1:(length(cellsIdx_RFsInc))
    ic_all = cellsIdx_RFsInc(ic);
    data        = squeeze(averageImageZscoreLR(ic_all,bestTimePoint(ic_all,1),:,:));
    % data_smth   = imgaussfilt(data,.75);
    STA_for_fitting(:,:,ic) = data;
end

modelRegistry = [
    struct( ...
        'name','Gaussian', ...
        'type','standard', ...
        'fitFcn', @(STA) fitEllipticalGaussian(STA,'unnormalized',20), ...
        'k',7)
    struct( ...
        'name','Noncon DoG', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNonConcentricEllipticalDoG(STA,'unnormalized',50), ...
        'k',10)
];



omitCells = [];

fitIdx = 1:size(STA_for_fitting,3);

results = runRFModelComparison( ...
    fitIdx, ...
    cellsIdx_RFs, ...
    double(STA_for_fitting), ...
    modelRegistry, ...
    omitCells, ...
    'pdf', ...
    'test_all_fit.pdf');

modelNames  = {results.modelRegistry.name};

gaus_fits    = cat(3,results.models{1}{:});
gaus_fits_all(:,:,:)    = cat(3,results.models{1}{:});

dog_fits    = cat(3,results.models{2}{:});
dog_fits_all(:,:,:)    = cat(3,results.models{2}{:});




%% plot
%%%%%%%%%%%%%%%%%%%%%%%%%
maxSTAlr = max(abs(averageImagesAllLR(:)));
maxZSTAlr = max(abs(averageImageZscoreLR(:)));
maxDoG = max(abs(dog_fits_all(:)));
maxGaus = max(abs(gaus_fits_all(:)));

nCells = size(averageImagesAllLR,1);

% Print STA time point choices
pdfDir = fullfile(dirBase, 'sara', 'Analysis', 'Neuropixel','marmosetFromNicholas','spatialRFs');

pdfFile = fullfile(pdfDir, ['elf3-STAs_withTuning.pdf']);
if isfile(pdfFile); delete(pdfFile); end

ic_use=1;
for ic = 1:nCells
    if ~ismember(ic, cellsIdx_RFsInc); continue; end

    iCell = cellsIdx(ic);

    figure();
    sgtitle(sprintf('cell %d (idx %d)', iCell, ic), 'FontSize', 10); 

    subplot(5,5,1)
        plot(x, avg_resp_grat(iCell,:))
        subtitle('grating tuning','FontSize', 6)
        xlabel('direction','FontSize', 6)
        ylabel('Hz (bl subtracted)','FontSize', 6)
        set(gca,'FontSize',5,'TickDir','out'); box off
    subplot(5,5,2)
        data = avg_resp_grat(iCell,:);
        [minVal, ~] = min(data);
            if minVal < 0
                resp = data-minVal;
            else
                resp = data;
            end
        plot(x, resp)
        subtitle(['gDSI=' num2str(round(g_dsi(iCell),2)) ', DSI=' num2str(round(DSI(iCell),2))],'FontSize', 6)
        xlabel('direction','FontSize', 6)
        ylabel('Hz (bl subtracted)','FontSize', 6)
        set(gca,'FontSize',5,'TickDir','out'); box off
    subplot(5,5,3)
        for im = 1:4
            polarplot([x_rad x_rad(1)], [avg_resp_plaid(iCell,:,im) avg_resp_plaid(iCell,1,im)],'Color', colors(im,:))
            hold on
        end
        polarplot([x_rad x_rad(1)], [avg_resp_grat(iCell,:) avg_resp_grat(iCell,1)],'k', 'LineWidth',2) 
        set(gca,'FontSize',5)
    subplot(5,5,4)
        for im = 1:4
            scatter(Zc(im,iCell), Zp(im,iCell),8,colors(im,:),'filled')
            hold on
        end
        ylabel('Zp'); ylim([-4 8]);
        xlabel('Zc'); xlim([-4 8]);
        plotZcZpBorders; axis square; set(gca,'TickDir','out')
    subplot(5,5,5)
        scatter(phase,PCI(:,iCell),8,'filled'); hold on
        [b_hat_all(iCell,1), amp_hat_all(iCell,1), per_hat_all(iCell,1),pha_hat_all(iCell,1),sse_all(iCell,1),R_square_all(iCell,1)] = sinefit_PCI(deg2rad(phase),PCI(:,iCell));
        yfit_all(iCell,:,1) = b_hat_all(iCell,1)+amp_hat_all(iCell,1).*(sin(2*pi*deg2rad(phase_range)./per_hat_all(iCell,1) + 2.*pi/pha_hat_all(iCell,1)));
        plot(phase_range, yfit_all(iCell,:,1),'k:');
        ylabel('Zp-Zc'); xlabel('Mask phase'); ylim([-7 7])
        xlim([0 360]); xticks([0 180 360]); set(gca,'TickDir','out')
        text(0.05,0.9,sprintf('R^2 = %.2f',R_square_all(iCell,1)),'Units','normalized','FontSize',5) 

    subplot(5,5,6)
            imagesc(squeeze(gaus_fits_all(:,:,ic_use))); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[-5 5]); 
            box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            subtitle('2d gaussian fit')
    subplot(5,5,7)
            imagesc(squeeze(dog_fits_all(:,:,ic_use))); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[-5 5]); 
            box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            subtitle('noncon dog fit')

    for it = 1:5

        data = squeeze(averageImageZscoreLR(ic,it,:,:));
        subplot(5,5,it+10)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[-5 5]); 
            box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            if it == 1
                text(0.02, 0.98, 'zscore STA, LR', ...
                    'Units','normalized', ...
                    'Color','w', ...
                    'FontSize',3, ...
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','top');
            end
            bestit_ic = bestTimePoint(ic,1);
            if it == bestit_ic && ind_sigRF(ic) > 0
                subtitle('pass, best time point')
            end


        data = squeeze(averageImageZscoreThresh(ic,it,:,:));
        subplot(5,5,it+15)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[-1 1]); 
            box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            if it == 1
                text(0.02, 0.98, 'zscore thresh = 2.5', ...
                    'Units','normalized', ...
                    'Color','w', ...
                    'FontSize',3, ... 
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','top');
            end
            if it == 5
                subtitle([num2str(totalSpikesUsed(ic)) ' spikes'])
            end

        data = squeeze(averageImageZscoreHR(ic,it,:,:));
        subplot(5,5,it+20)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[-5 5]); 
            box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            if it == 1
                text(0.02, 0.98, 'zscore STA, HR', ...
                    'Units','normalized', ...
                    'Color','w', ...
                    'FontSize',3, ...
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','top');
            end
      
    end

    % Append current figure as a new page in the PDF
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);
    close(gcf)

    ic_use=ic_use+1;
end


%% plot not included cells
%%%%%%%%%%%%%%%%%%%%%%%%%55
% maxSTAlr = max(abs(averageImagesAllLR(:)));
% maxZSTAlr = max(abs(averageImageZscoreLR(:)));
% maxDoG = max(abs(dog_fits_all(:)));
% maxGaus = max(abs(gaus_fits_all(:)));

nCells = size(averageImageZscoreLR,1);

% Print STA time point choices
pdfDir = fullfile(dirBase, 'sara', 'Analysis', 'Neuropixel','marmosetFromNicholas','spatialRFs');

pdfFile = fullfile(pdfDir, ['elf3-STAs_withTuning_notIncluded.pdf']);
if isfile(pdfFile); delete(pdfFile); end

ic_use=1;
for ic = 1:nCells
    if ismember(ic, cellsIdx_RFsInc); continue; end

    iCell = cellsIdx(ic);

    figure();
    sgtitle(sprintf('cell %d (idx %d)', iCell, ic), 'FontSize', 10); 

    subplot(5,5,1)
        plot(x, avg_resp_grat(iCell,:))
        subtitle('grating tuning','FontSize', 6)
        xlabel('direction','FontSize', 6)
        ylabel('Hz (bl subtracted)','FontSize', 6)
        set(gca,'FontSize',5,'TickDir','out'); box off
    subplot(5,5,2)
        data = avg_resp_grat(iCell,:);
        [minVal, ~] = min(data);
            if minVal < 0
                resp = data-minVal;
            else
                resp = data;
            end
        plot(x, resp)
        subtitle(['gDSI=' num2str(round(g_dsi(iCell),2)) ', DSI=' num2str(round(DSI(iCell),2))],'FontSize', 6)
        xlabel('direction','FontSize', 6)
        ylabel('Hz (bl subtracted)','FontSize', 6)
        set(gca,'FontSize',5,'TickDir','out'); box off
    subplot(5,5,3)
        for im = 1:4
            polarplot([x_rad x_rad(1)], [avg_resp_plaid(iCell,:,im) avg_resp_plaid(iCell,1,im)],'Color', colors(im,:))
            hold on
        end
        polarplot([x_rad x_rad(1)], [avg_resp_grat(iCell,:) avg_resp_grat(iCell,1)],'k', 'LineWidth',2) 
        set(gca,'FontSize',5)
    subplot(5,5,4)
        for im = 1:4
            scatter(Zc(im,iCell), Zp(im,iCell),8,colors(im,:),'filled')
            hold on
        end
        ylabel('Zp'); ylim([-4 8]);
        xlabel('Zc'); xlim([-4 8]);
        plotZcZpBorders; axis square; set(gca,'TickDir','out')
    subplot(5,5,5)
        scatter(phase,PCI(:,iCell),8,'filled'); hold on
        [b_hat_all(iCell,1), amp_hat_all(iCell,1), per_hat_all(iCell,1),pha_hat_all(iCell,1),sse_all(iCell,1),R_square_all(iCell,1)] = sinefit_PCI(deg2rad(phase),PCI(:,iCell));
        yfit_all(iCell,:,1) = b_hat_all(iCell,1)+amp_hat_all(iCell,1).*(sin(2*pi*deg2rad(phase_range)./per_hat_all(iCell,1) + 2.*pi/pha_hat_all(iCell,1)));
        plot(phase_range, yfit_all(iCell,:,1),'k:');
        ylabel('Zp-Zc'); xlabel('Mask phase'); ylim([-7 7])
        xlim([0 360]); xticks([0 180 360]); set(gca,'TickDir','out')
        text(0.05,0.9,sprintf('R^2 = %.2f',R_square_all(iCell,1)),'Units','normalized','FontSize',5) 


    for it = 1:5
        subplot(5,5,6)
            axis off
            if it == 1
                txtOpts = {'Units','normalized','Color','k','FontSize',5,'HorizontalAlignment','left','VerticalAlignment','top'};
                txtOptsBold = {'Units','normalized','Color','k','FontSize',5,'FontWeight','bold','HorizontalAlignment','left','VerticalAlignment','top'};
                text(0.02, 0.98, 'pass Vis Resp criteria', txtOptsBold{:});
                text(0.02, 0.78, 'pass DS criteria', txtOptsBold{:});
                if ismember(cellsIdx(ic),ind_FR)
                    text(0.02, 0.58, 'pass FR criteria', txtOptsBold{:});
                else
                    text(0.02, 0.58, 'pass FR criteria', txtOpts{:});
                end
                if ind_sigRF(ic)>0
                    text(0.02, 0.38, 'pass RF criteria', txtOptsBold{:});
                else
                    text(0.02, 0.38, 'pass RF criteria', txtOpts{:});
                end
            end

        data = squeeze(averageImageZscoreLR(ic,it,:,:));
        subplot(5,5,it+10)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[-5 5]); 
            box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            if it == 1
                text(0.02, 0.98, 'zscore STA, LR', ...
                    'Units','normalized', ...
                    'Color','w', ...
                    'FontSize',3, ...
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','top');
            end
            bestit_ic = bestTimePoint(ic,1);
            if it == bestit_ic && ind_sigRF(ic) > 0
                subtitle('pass, best time point')
            end

        data = squeeze(averageImageZscoreThresh(ic,it,:,:));
        subplot(5,5,it+15)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[-1 1]); 
            box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            if it == 1
                text(0.02, 0.98, 'zscore thresh = 2.5', ...
                    'Units','normalized', ...
                    'Color','w', ...
                    'FontSize',3, ... 
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','top');
            end
            if it == 5
                subtitle([num2str(totalSpikesUsed(ic)) ' spikes'])
            end

        
        data = squeeze(averageImageZscoreHR(ic,it,:,:));
        subplot(5,5,it+20)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[-5 5]); 
            box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            if it == 1
                text(0.02, 0.98, 'zscore STA, HR', ...
                    'Units','normalized', ...
                    'Color','w', ...
                    'FontSize',3, ...
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','top');
            end

    end

    % Append current figure as a new page in the PDF
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);
    close(gcf)

    ic_use=ic_use+1;
end