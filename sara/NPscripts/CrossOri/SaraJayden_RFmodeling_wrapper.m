%% Load data 
% load file with data concatenated across experiments

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

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

% Calculate best it by taking max zscore 
for ic = 1:totalCells
    for it = 2:4
        avgImgZscore(it,:,:) = squeeze(avgImgZscore_all(ic,it,:,:));     % Grab avg zscore STA images for time points 0.04 0.07 and 0.1
    end 
    [m, it_best]            = max(sum(sum(abs(avgImgZscore(:,:,:)),2),3),[],1);      % which of the three has the max cumulative zscore?
    bestTimePoint_all(ic,3) = it_best;
    bestTimePoint_all(ic,4) = m;
end

% Calculate best it by taking zscore threshold mask and taking highest cumulative CI value
for ic = 1:totalCells
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

for ii = 1:(length(ind_DS))
    ic = ind_DS(ii);
    avgImgZscore = squeeze(avgImgZscore_all(ic,:,:,:));     % Grab avg zscore STA images for all time points
    data = medfilt2(imgaussfilt(squeeze(avgImgZscore(bestTimePoint_all(ic,1),:,:)),1));
    [el, az] = getRFcenter(data); % reversed because of how I had swapped xDim and yDim for the image
    sideLength = 20;
    [data_cropped] = cropRFtoCenter(az, el, data, sideLength);
    STA_cropped(:,:,ii) = data_cropped;
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

for ii = [1:38 40:length(ind_DS)]  % 39 is actually NaNs / can't find RF center so can't crop -- need to figure out an exclusion step, but for now this works
    % Initialize for gabor fit
    results             = fit2dGabor_SG(STA_cropped(:,:,ii),options);
    gaborfit(ii).fit    = results.fit;
    gaborpatch(ii,:,:)  = results.patch;
    rsqGabor(ii)        = results.r2;
end

results_crop    = results;
gaborfit_crop   = gaborfit;
gaborpatch_crop = gaborpatch;
rsqGabor_crop   = rsqGabor;


%% Run DoG fits

for ii = 1:length(ind_DS)
    if ii~=39
        data_cropped                         = STA_cropped(:,:,ii);
    
        [~, DoGOn_modelRF(ii,:,:), ~]        = fitDoG2D(data_cropped);
        DoGOn_rsq(ii)                        = getRsqLinearRegress_SG(data_cropped, squeeze(DoGOn_modelRF(ii,:,:)));
    
        [~, DoGOff_modelRF(ii,:,:), ~]       = fitDoG2D(-data_cropped);
        DoGOff_rsq(ii)                       = getRsqLinearRegress_SG(data_cropped, -squeeze(DoGOff_modelRF(ii,:,:)));
    
        [~, nonConDoG_modelRF(ii,:,:), ~]    = fitNonConcentricEllipticalDoG(data_cropped);
        nonConDoG_rsq(ii)                    = getRsqLinearRegress_SG(data_cropped, squeeze(nonConDoG_modelRF(ii,:,:)));
    end
end











