close all; clearvars; clc;

%% debug mode one cell test
debugMode = true;
debugCell = 173;   % pick ANY number from 1:1117

%% Load data 
% load file with data concatenated across experiments

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

totalCells = totCells;   % cell number

if debugMode
    cellsToRun = debugCell; % test one cell here instead of total cell
    fprintf('Cell\n');
    disp(cellsToRun');
else
    cellsToRun = 1:totalCells;
end

fprintf('Running analysis on %d cell(s)\n', numel(cellsToRun));

%% Decide what index of cells you're going to use

indCortex   = find(depth_all>800);
ind_sigRF   = sum(cells_sigRFbyTime_On_all,2)+sum(cells_sigRFbyTime_Off_all,2);
listnc      = 1:size(cells_sigRFbyTime_On_all,1);
indRF_pix   = listnc(ind_sigRF>0)';
indRF_con   = find(bestTimePoint_all(:,2)>1);

indRF_pix   = intersect(indRF_pix,indCortex);
indRF_con   = intersect(indRF_con,indCortex);
indRFint    = unique([indRF_pix; indRF_con]);
idxInt      = intersect(indRF_pix, indRF_con);  % both mask and contrast method

idxMask     = setdiff(indRF_pix, indRF_con); % mask method only
idxCon      = setdiff(indRF_con,indRF_pix); % contrast method only

ind         = intersect(resp_ind_dir_all, find(DSI_all>.5));
ind_DS      = intersect(idxInt,ind); % visually responsive and direction-selective

%% Calculate time point of STA
% The first dimension of bestTimePoint_all is the one computed by the local contrast method

%totalCells = sum(nCells_list);

% Calculate best it by taking max zscore 
for ic = cellsToRun
    for it = 2:4
        avgImgZscore(it,:,:) = squeeze(avgImgZscore_all(ic,it,:,:));     % Grab avg zscore STA images for time points 0.04 0.07 and 0.1
    end 
    [m, it_best]            = max(sum(sum(abs(avgImgZscore(:,:,:)),2),3),[],1);      % which of the three has the max cumulative zscore?
    bestTimePoint_all(ic,3) = it_best;
    bestTimePoint_all(ic,4) = m;
end

% Calculate best it by taking zscore threshold mask and taking highest cumulative CI value
for ic = cellsToRun
    for it = 2:4
        pixMask             = imgaussfilt(abs(squeeze(avgImgZscoreThresh_all(ic,it,:,:))),3);
        conMap              = squeeze(localConMap_map_all(ic, it, :,:));
        maskMap             = pixMask.*conMap;
        maskMap_sum(ic,it)  = mean(maskMap(:));
    end
    [m, it_best]            = max(maskMap_sum(ic,:),[],2);
    bestTimePoint_all(ic,5) = it_best;
    bestTimePoint_all(ic,6) = m;   
end


%% Find center of RF and crop
if debugMode
    indLoop = find(ind_DS == debugCell);
    assert(~isempty(indLoop), 'debugCell is not in ind_DS');
else
    indLoop = 1:length(ind_DS);
end

for ii = indLoop
    ic = ind_DS(ii);
    avgImgZscore = squeeze(avgImgZscore_all(ic,:,:,:));     % Grab avg zscore STA images for all time points
    data = medfilt2(imgaussfilt(squeeze(avgImgZscore(bestTimePoint_all(ic,1),:,:)),1));
    [el, az] = getRFcenter(data); % reversed because of how I had swapped xDim and yDim for the image
    sideLength = 20;
    [data_cropped] = cropRFtoCenter(az, el, data, sideLength);
    STA_cropped(:,:,ii) = data_cropped;

    % plotting cropped RF
    figure('Name','RF center & crop','Color','w');
    movegui('center');
    
    subplot(1,3,1)
    imagesc(data)
    axis image off
    colormap gray
    title('Full STA (best timepoint)')
    
    subplot(1,3,2)
    imagesc(data)
    axis image off
    colormap gray
    hold on
    plot(az, el, 'r+', 'MarkerSize', 12, 'LineWidth', 2)
    title('RF center (red +)')
    
    subplot(1,3,3)
    imagesc(data_cropped)
    axis image off
    colormap gray
    title('Cropped STA (used for fits)')
    
    sgtitle(sprintf('Cell %d — RF localization & cropping', ic))

end

%% Run Gabor fit

% Gabor fit
gaborpatch = [];
gaborfit = struct();
rsqGabor = [];
options.visualize = 0;
options.parallel = 0;
options.shape   = 'elliptical';
options.runs    = 48;

% debug check
if debugMode
    gaborLoop = indLoop;
else
    gaborLoop = [1:38 40:length(ind_DS)];% 39 is actually NaNs / can't find RF center so can't crop -- need to figure out an exclusion step, but for now this works
    % Initialize for gabor fit
end

for ii = gaborLoop  
    results             = fit2dGabor_SG(STA_cropped(:,:,ii),options);
    gaborfit(ii).fit    = results.fit;
    gaborpatch(ii,:,:)  = results.patch;
    rsqGabor(ii)        = results.r2;

    % plot gabor fit result
    figure('Name','Gabor fit','Color','w');
    movegui('center');
    
    subplot(1,3,1)
    imagesc(STA_cropped(:,:,ii))
    axis image off
    colormap gray
    title('Cropped STA')
    
    subplot(1,3,2)
    imagesc(squeeze(gaborpatch(ii,:,:)))
    axis image off
    colormap gray
    title(sprintf('Gabor fit (R^2 = %.2f)', rsqGabor(ii)))
    
    subplot(1,3,3)
    imagesc(STA_cropped(:,:,ii) - squeeze(gaborpatch(ii,:,:)))
    axis image off
    colormap gray
    title('Residual (STA − Gabor)')
    
    sgtitle(sprintf('Cell %d — Gabor RF fit', ic))

end

results_crop    = results;
gaborfit_crop   = gaborfit;
gaborpatch_crop = gaborpatch;
rsqGabor_crop   = rsqGabor;


%% Run DoG fits

for ii = indLoop

    ic = ind_DS(ii);   % global cell index

    % Skip known bad cell
    if ii == 39
        continue
    end

    data_cropped = STA_cropped(:,:,ii);

    [~, DoGOn_modelRF(ii,:,:), ~] = fitDoG2D(data_cropped);
    DoGOn_rsq(ii) = getRsqLinearRegress_SG( ...
        data_cropped, squeeze(DoGOn_modelRF(ii,:,:)) );

    [~, DoGOff_modelRF(ii,:,:), ~] = fitDoG2D(-data_cropped);
    DoGOff_rsq(ii) = getRsqLinearRegress_SG( ...
        data_cropped, -squeeze(DoGOff_modelRF(ii,:,:)) );

    [~, nonConDoG_modelRF(ii,:,:), ~] = fitNonConcentricEllipticalDoG(data_cropped);
    nonConDoG_rsq(ii) = getRsqLinearRegress_SG( ...
        data_cropped, squeeze(nonConDoG_modelRF(ii,:,:)) );

    [~, eDoG_modelRF(ii,:,:), ~] = fitEllipticalDoG2D(data_cropped); % elliptical DoG
    eDoG_rsq(ii) = getRsqLinearRegress_SG( ...
        data_cropped, squeeze(eDoG_modelRF(ii,:,:)) );

    figure('Name','DoG RF fits','Color','w');
    movegui('center');

    subplot(2,3,1)
    imagesc(data_cropped)
    axis image off
    colormap gray
    title('Cropped STA')

    subplot(2,3,2)
    imagesc(squeeze(DoGOn_modelRF(ii,:,:)))
    axis image off
    colormap gray
    title(sprintf('ON DoG (R^2 = %.2f)', DoGOn_rsq(ii)))

    subplot(2,3,3)
    imagesc(-squeeze(DoGOff_modelRF(ii,:,:)))
    axis image off
    colormap gray
    title(sprintf('OFF DoG (R^2 = %.2f)', DoGOff_rsq(ii)))

    subplot(2,3,4)
    imagesc(squeeze(nonConDoG_modelRF(ii,:,:)))
    axis image off
    colormap gray
    title(sprintf('Non-concentric eDoG (R^2 = %.2f)', nonConDoG_rsq(ii)))

    subplot(2,3,5)
    imagesc(squeeze(eDoG_modelRF(ii,:,:)))
    axis image off
    colormap gray
    title(sprintf('Elliptical DoG (R^2 = %.2f)', eDoG_rsq(ii)))

    subplot(2,3,6)
    bar([DoGOn_rsq(ii), DoGOff_rsq(ii), nonConDoG_rsq(ii), eDoG_rsq(ii)])
    set(gca,'XTickLabel',{'ON','OFF','NonCon','Elliptical'})
    ylabel('R^2')
    ylim([0 1])
    title('Model comparison')

    sgtitle(sprintf('Cell %d — RF model fits', ic))
end
