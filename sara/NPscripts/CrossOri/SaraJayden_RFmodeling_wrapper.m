close all; clearvars; clc;

%% debug mode one cell test
debugMode = true;
debugCell = 375;   % check indRFint
%rng(0,'twister');   % randomness fully reproducible

manualParamMode = false;   % <<< toggle this
manualParams = [4.1284    4.3747   11.3467    5.7590    3.3143   -0.0708    4.2771    0.2266    0.0365    0.6787   14.4822   -0.9419];


%% Load data 
% load file with data concatenated across experiments

resultsDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\';
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

indCortex   = find(~isnan(layer_all));
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

save(fullfile([resultsDir, 'bestTimePoint.mat']), 'bestTimePoint_all')

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
end


figure;
is=1;
for ic = 1:size(STA_cropped,3)
    subplot(6,7,is)
        clim = max(abs(STA_cropped(:)));
        imagesc(STA_cropped(:,:,ic),[-clim clim])
        subtitle(num2str(ind_DS(ic)))
        axis image off
        axis square
        colormap gray
        hold on
    is=is+1;
end
<<<<<<< HEAD
% Generate a perfect 20x20 Gabor STA
print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\STAs_cropped.pdf', '-dpdf','-bestfit')
=======
print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\STAs_cropped.pdf', '-dpdf','-bestfit')
>>>>>>> origin/main

nx = 20;
ny = 20;

x = (1:nx) - mean(1:nx);
y = (1:ny) - mean(1:ny);
[X, Y] = meshgrid(x, y);

<<<<<<< HEAD
% Parameters
A = 1.0;          % amplitude
x0 = 0;           % center x
y0 = 0;           % center y
theta = pi/4;     % orientation in radians
sigma_x = 3.0;    % width along x'
sigma_y = 1.5;    % width along y'
f = 0.12;         % spatial frequency (cycles/pixel)
phi = 0;          % phase

% Shifted coordinates
Xs = X - x0;
Ys = Y - y0;

% Rotated coordinates
Xp = Xs * cos(theta) + Ys * sin(theta);
Yp = -Xs * sin(theta) + Ys * cos(theta);

% Gabor
gaborSTA = A .* exp(-(Xp.^2 ./ (2*sigma_x^2) + Yp.^2 ./ (2*sigma_y^2))) ...
             .* cos(2*pi*f*Xp + phi);

% Optional normalize
gaborSTA = gaborSTA / max(abs(gaborSTA(:)));

% Plot
figure;
imagesc(gaborSTA);
axis image;
colormap gray;
colorbar;
title('Synthetic 20x20 Gabor STA');

%% ---------- helpers ----------
computeR2  = @(data, model) ...
    1 - sum((data(:)-model(:)).^2) / ...
        sum((data(:)-mean(data(:))).^2);

%% ---------- settings ----------
k_DoGCos = 12;        % parameter count
nCells   = numel(indLoop);
% copy format from the first example
modelRegistry = [
    
    struct( ...
        'name','Noncon DoG', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNonConcentricEllipticalDoG(STA,'unnormalized',20), ...
        'k',10)
=======
% copy format from the first example
modelRegistry = [
    
    struct( ...
        'name','Noncon DoG', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNonConcentricEllipticalDoG(STA,'unnormalized',20), ...
        'k',10)

    struct( ...
        'name','Custom Gabor', ...
        'type','standard', ...
        'fitFcn', @(STA) fitEllipGabor_fit_full(STA), ...
        'k',9)

    struct( ...
        'name','DoG x cos', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNoncDoGCosineRF_diff(STA), ...
        'k',12)

    struct( ...
        'name','Custom Gabor', ...
        'type','standard', ...
        'fitFcn', @(STA) fitEllipGabor_fit_full(STA), ...
        'k',9)

    struct( ...
        'name','DoG x cos', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNoncDoGCosineRF_diff(STA), ...
        'k',12)
>>>>>>> origin/main

    struct( ...
        'name','DoG x cos mod', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNoncDoGCosineRF_sigmaXY(STA), ...
        'k',12)
];

omitCells = [634];   % cell(s) with NaN

results = runRFModelComparison( ...
    indLoop, ind_DS, STA_cropped, ...
    modelRegistry, omitCells, 'pdf', 'RF_DoGxcos.pdf', ...
    {'DoG x cos','Custom Gabor'}, {'DoG x cos','Custom Gabor'});
figure(1)
    axis square; set(gca,'TickDir','out')
    resultsDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\';
    print(fullfile([resultsDir, 'randDirFourPhase_CrossOri_mouseEphys_RsqModelComp.pdf']),'-dpdf'); %gabor
figure(2)
    axis square; set(gca,'TickDir','out') 
    print(fullfile([resultsDir, 'randDirFourPhase_CrossOri_mouseEphys_AICModelComp.pdf']),'-dpdf');  %gabor

stop

<<<<<<< HEAD
%% ---------- helpers ----------
computeR2 = @(data, model) ...
    1 - sum((data(:) - model(:)).^2) / ...
    sum((data(:) - mean(data(:))).^2);

computeAIC = @(RSS, n, k) n * log(RSS / n) + 2 * k;

%% ---------- settings ----------
k_DoGCos = 12;
nCells = numel(indLoop);

R2_DoGCos = nan(nCells, 1);
AIC_DoGCos = nan(nCells, 1);

RF_DoGCos = cell(nCells, 1);
RF_rebuilt_all = cell(nCells, 1);
params_all = cell(nCells, 1);

k = 0;

%% ============================================================
% Main Loop (DoG x Cos ONLY) with debugging test
%% ============================================================

for ii = indLoop
    if ii == 27
        continue
    end
results = runRFModelComparison( ...
    indLoop, ind_DS, STA_cropped, ...
    modelRegistry, omitCells, 'pdf', 'RF_DoGxcos.pdf', ...
    {'Noncon DoG', 'DoG x cos'}, {'Noncon DoG', 'DoG x cos'});
figure(1)
    axis square; set(gca,'TickDir','out')
    resultsDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\';
    print(fullfile([resultsDir, 'randDirFourPhase_CrossOri_mouseEphys_RsqModelComp_NonconDoG.pdf']),'-dpdf');
figure(2)
    axis square; set(gca,'TickDir','out')
    print(fullfile([resultsDir, 'randDirFourPhase_CrossOri_mouseEphys_AICModelComp_NonConDoG.pdf']),'-dpdf');
%% Ranking
modelIdx = find(strcmp({modelRegistry.name}, 'Custom Gabor')); %DoG x cos
=======
stop

paramList = {'orientation','frequency','elongation','size'};
%paramList = {'orientation','frequency','elongation','size'};


results = runRFModelComparison( ...
    indLoop, ind_DS, STA_cropped, ...
    modelRegistry, omitCells, 'pdf', 'RF_DoGxcos.pdf', ...
    {'Noncon DoG', 'DoG x cos'}, {'Noncon DoG', 'DoG x cos'});
figure(1)
    axis square; set(gca,'TickDir','out')
    resultsDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\';
    print(fullfile([resultsDir, 'randDirFourPhase_CrossOri_mouseEphys_RsqModelComp_NonconDoG.pdf']),'-dpdf');
figure(2)
    axis square; set(gca,'TickDir','out')
    print(fullfile([resultsDir, 'randDirFourPhase_CrossOri_mouseEphys_AICModelComp_NonConDoG.pdf']),'-dpdf');
%% Ranking
modelIdx = find(strcmp({modelRegistry.name}, 'Custom Gabor')); %DoG x cos

paramList = {'orientation','frequency','elongation','size'};
%paramList = {'orientation','frequency','elongation','size'};

>>>>>>> origin/main

for p = 1:length(paramList)

    ic = ind_DS(ii);
    STA = STA_cropped(:, :, ii);
    n = numel(STA);


    % Build coordinate system once
    [ny, nx] = size(STA);
    x = (1:nx) - mean(1:nx);
    y = (1:ny) - mean(1:ny);
    [X, Y] = meshgrid(x, y);
    XY = [X(:) Y(:)];

    if manualParamMode
        % ----------------------------------------------------
        % MANUAL MODE: build model from manually typed params
        % ----------------------------------------------------
        params = manualParams(:).';
        modelVec = nonConcentricDoGCosineModel(params, XY, 'unnormalized');
        RF_model = reshape(modelVec, ny, nx);

        RF_DoGCos{k} = RF_model;
        RF_rebuilt_all{k} = RF_model;

        fprintf('Manual parameter mode\n');
        fprintf('Params used:\n');
        format long g
        disp(params)

    else
        % ----------------------------------------------------
        % FIT MODE: fit first, then rebuild model using the
        % EXACT returned params from the same run
        % ----------------------------------------------------
        [params, RF_fit, fitInfo] = fitNoncDoGCosineRF_diff(STA);

        % Rebuild from returned params
        modelVec_rebuilt = nonConcentricDoGCosineModel( ...
            params, XY, 'unnormalized');
        RF_rebuilt = reshape(modelVec_rebuilt, ny, nx);

        RF_DoGCos{k} = RF_fit;
        RF_rebuilt_all{k} = RF_rebuilt;
        params_all{k} = params;

        fprintf('Fit mode\n');
        fprintf('Returned params (full precision):\n');
        format long g
        disp(params)

        maxAbsDiff = max(abs(RF_fit(:) - RF_rebuilt(:)));
        fprintf('Max abs diff between RF_fit and RF_rebuilt = %.16g\n', ...
            maxAbsDiff);

        % Optional: print exact copy-paste line for manualParams
        fprintf('Copy this exactly into manualParams:\n');
        fprintf('manualParams = [');
        fprintf('%.16g ', params);
        fprintf('];\n');

        % Show STA, fitter output, rebuilt output, and differences
        figure;
        subplot(2, 3, 1);
        imagesc(STA);
        axis image off;
        colormap gray;
        title('STA');

        subplot(2, 3, 2);
        imagesc(RF_fit);
        axis image off;
        colormap gray;
        title('RF returned by fit');

        subplot(2, 3, 3);
        imagesc(RF_rebuilt);
        axis image off;
        colormap gray;
        title('RF rebuilt from params');

        subplot(2, 3, 4);
        imagesc(STA - RF_fit);
        axis image off;
        colormap gray;
        colorbar;
        title('STA - RF fit');

        subplot(2, 3, 5);
        imagesc(STA - RF_rebuilt);
        axis image off;
        colormap gray;
        colorbar;
        title('STA - RF rebuilt');

        subplot(2, 3, 6);
        imagesc(RF_fit - RF_rebuilt);
        axis image off;
        colormap gray;
        colorbar;
        title('RF fit - RF rebuilt');
    end

    % In manual mode, params_all may be empty unless you store it here
    params_all{k} = params;

    RSS = sum((STA(:) - RF_DoGCos{k}(:)).^2);
    R2_DoGCos(k) = computeR2(STA, RF_DoGCos{k});
    AIC_DoGCos(k) = computeAIC(RSS, n, k_DoGCos);

    fprintf('R2  = %.6f\n', R2_DoGCos(k));
    fprintf('AIC = %.6f\n', AIC_DoGCos(k));

    % Simple STA vs chosen model plot
    figure;
    subplot(1, 2, 1);
    imagesc(STA);
    axis image off;
    colormap gray;
    title('Data');
load(fullfile([resultsDir, 'RFparams_orientation.mat']))
    valOrientationID = paramResults.cellIDs;  
    valOrientation = paramResults.values;
load(fullfile([resultsDir, 'RFparams_frequency.mat']))
    valFrequencyID = paramResults.cellIDs;  
    valFrequency = paramResults.values;
load(fullfile([resultsDir, 'RFparams_elongation.mat']))
    valElongationID = paramResults.cellIDs;  
    valElongation = paramResults.values;      
load(fullfile([resultsDir, 'RFparams_size.mat']))
    valSizeID = paramResults.cellIDs;  
    valSize = paramResults.values;      

    subplot(1, 2, 2);
    imagesc(RF_DoGCos{k});
    axis image off;
    colormap gray;
    title('Model used');

end
%% GUI
cellIdx = 1;   % because debug mode = one cell
STA = STA_cropped(:,:,indLoop(cellIdx));
params = params_all{cellIdx};
size(params)
disp(params)
% launchRF_GUI(STA, params);
rf_data = STA;
cellID = indRFint;
Ac = params(1);
As = params(2);
sc = params(3);
delta = params(4);
ss = sc + delta;
tau = params(5);
theta = params(6);
x0 = params(7);
y0 = params(8);
f = params(9);
phi = params(10);
dx = params(11);
dy = params(12);

fprintf('Cell %d\n', cellID);
fprintf('Ac = %.3f\n', Ac);
fprintf('As = %.3f\n', As);
fprintf('sigmaC = %.3f\n', sc);
fprintf('sigmaS = %.3f\n', ss);
fprintf('tau = %.3f\n', tau);
fprintf('theta (deg) = %.3f\n', rad2deg(mod(theta, pi)));
fprintf('f = %.3f cycles/pixel\n', f);
fprintf('phi (deg) = %.3f\n', rad2deg(phi));
fprintf('dx = %.3f, dy = %.3f, offsetLen = %.3f\n', ...
    dx, dy, hypot(dx, dy));

[ny, nx] = size(rf_data);

<<<<<<< HEAD
x = (1:nx) - mean(1:nx);
y = (1:ny) - mean(1:ny);
[X, Y] = meshgrid(x, y);

Xc = X - x0;
Yc = Y - y0;
=======
load(fullfile([resultsDir, 'RFparams_orientation.mat']))
    valOrientationID = paramResults.cellIDs;  
    valOrientation = paramResults.values;
load(fullfile([resultsDir, 'RFparams_frequency.mat']))
    valFrequencyID = paramResults.cellIDs;  
    valFrequency = paramResults.values;
load(fullfile([resultsDir, 'RFparams_elongation.mat']))
    valElongationID = paramResults.cellIDs;  
    valElongation = paramResults.values;      
load(fullfile([resultsDir, 'RFparams_size.mat']))
    valSizeID = paramResults.cellIDs;  
    valSize = paramResults.values;      
>>>>>>> origin/main

Xs = X - (x0 + dx);
Ys = Y - (y0 + dy);

<<<<<<< HEAD
Xcp = cos(theta) * Xc + sin(theta) * Yc;
Ycp = -sin(theta) * Xc + cos(theta) * Yc;

Xsp = cos(theta) * Xs + sin(theta) * Ys;
Ysp = -sin(theta) * Xs + cos(theta) * Ys;

Gc = exp(-(Xcp.^2 + (tau * Ycp).^2) / (2 * sc^2));
Gs = exp(-(Xsp.^2 + (tau * Ysp).^2) / (2 * ss^2));

carrier = cos(phi) .* cos(2 * pi * f * Xcp) - ...
    sin(phi) .* sin(2 * pi * f * Xcp);

centerPart = Ac .* Gc .* carrier;
surroundPart = As .* Gs .* carrier;
DoGenv = Ac .* Gc - As .* Gs;
fullModel = DoGenv .* carrier;
% debug_DoGCos_frequency_fft(params, 20);
% debug_STA_vs_model_fft(STA, params, 20);

% params = results.params{m}{cellIndex};

% checkFrequencyOrientation(STA, params);
% visualize_RF_validation(STA, RF_DoGCos{k}, params)

%% for CSHL 2026 poster


paramArray = results.params{modelIdx};

freq = squeeze(params(1,:));
IDs =  results.cellIDs;
rsq = results.R2{modelIdx};

clear As cycles effectiveSigma delts params ylim
figure;
movegui('center')
s=1;
for ic = [135 470 250 68 232 133 230 986]
    ind = find(IDs==ic);
    fprintf(['Cell ' num2str(ic) ',rsq= ' num2str(rsq(ind)) '\n'])
    params = paramArray{ind};
    As = params(2);
    delts = params(4);
    Ac = params(1);
    cycles = params(9);
    effectiveSigma = params(3) / sqrt(params(5));
    subplot(7,8,s)
        scatter(1, cycles)
        set(gca,'TickDir','out')
        ylim([0 0.1])
        ylabel('f, raw')
        subtitle(num2str(ic))
    subplot(7,8,s+8)
        scatter(1, abs(As),'r')
        set(gca,'TickDir','out')
        ylim([0 10])
        ylabel('As')
    s=s+1;
end
s=1;
for ic = [468 622 375]
    ind = find(IDs==ic);
    fprintf(['Cell ' num2str(ic) ',rsq= ' num2str(rsq(ind)) '\n'])
    params = paramArray{ind};
    As = params(2);
    delts = params(4);
    Ac = params(1);
    cycles = params(9);
    effectiveSigma = params(3) / sqrt(params(5));
    subplot(7,8,s+16)
        scatter(1, cycles)
        set(gca,'TickDir','out')
        ylim([0 0.1])
        ylabel('f, raw')
        subtitle(num2str(ic))
    subplot(7,8,s+24)
        scatter(1, abs(As),'r')
        set(gca,'TickDir','out')
        ylim([0 10])
        ylabel('As')
    s=s+1;
end

print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\stats_forExampleCells.pdf', '-dpdf','-bestfit')




for ic = 1:40
    params = paramArray{ic};
    As(ic) = params(2);
    cycles(ic) = params(9);
end

figure;
scatter(abs(As), cycles)
xlabel('As')
ylabel('f')

for ic = 1:40
    params = paramArray{ic};
    As(ic) = params(2);
    delts(ic) = params(4);
    Ac(ic) = params(1);
    cycles(ic) = params(9);
    effectiveSigma(ic) = params(3) / sqrt(params(5));
end

figure;
for ic = 1:size(STA_cropped,3)
    subplot(6,7,ic)
        clim = max(abs(STA_cropped(:)));
        imagesc(STA_cropped(:,:,ic),[-clim clim])
        subtitle(['f ' num2str(round(cycles(ic),2)) ', As ' num2str(abs(round(As(ic),1))) ])
        axis image off
        axis square
        colormap gray
        hold on
end
print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\STAs_cropped_withStats.pdf', '-dpdf','-bestfit')



        
figure;
    ax = axes;
    
    As_abs = abs(As);
    
    scatter(As_abs, cycles, 10, 'k') % optional reference points
    xlabel('|As|')
    ylabel('f')
    hold on
    
    axpos = ax.Position;   % position of main axes in figure
    
    for ic = 1:length(As_abs)
    
        % normalize data within axes limits
        xn = (As_abs(ic) - ax.XLim(1)) / diff(ax.XLim);
        yn = (cycles(ic) - ax.YLim(1)) / diff(ax.YLim);
    
        % convert to figure coordinates
        xf = axpos(1) + xn * axpos(3);
        yf = axpos(2) + yn * axpos(4);
    
        w = 0.03;
        h = 0.03;
    
        ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
    
        clim = max(abs(STA_cropped(:)));
        imagesc(STA_cropped(:,:,ic),[-clim clim])
        axis image off
        colormap gray
    end





save(fullfile( '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\', 'results', 'RFparams_raw.mat'), 'As', 'cycles');




%% for dept talk 2026
modelIdx = find(strcmp({modelRegistry.name}, 'DoG x cos')); 
RFs_cont = results.models{modelIdx};
rsq_cont = results.R2{modelIdx};

modelIdx = find(strcmp({modelRegistry.name}, 'Custom Gabor')); %DoG x cos
RFs_gabor = results.models{modelIdx};
rsq_gabor = results.R2{modelIdx};

modelIdx = find(strcmp({modelRegistry.name}, 'Noncon DoG')); %DoG x cos
RFs_NCdog = results.models{modelIdx};
rsq_NCdog = results.R2{modelIdx};

figure;
is=1;
for ic = 1:size(STA_cropped,3)
    subplot(6,7,is)
        clim = max(max(abs(cell2mat(RFs_gabor))));
        imagesc(RFs_gabor{ic}, [-clim clim])
        subtitle(num2str(results.cellIDs(ic)))
        axis image off
        axis square
        colormap gray
        hold on
    is=is+1;
end
print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\traditionalGabor_fits.pdf', '-dpdf','-bestfit')
%print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\nonConEllipDoG_fits.pdf', '-dpdf','-bestfit')


myList = [135 470 250 68 232 133 230 986 468 622 375];

[tf, loc] = ismember(myList, results.cellIDs);

cellsPlotting = loc(tf);

rsq_gabor(cellsPlotting)
rsq_NCdog(cellsPlotting)




% boxplot w scatter of Rsq

labels = {'DoG x cos','Custom Gabor','Noncon DoG'};

% Assign numeric group indices manually
gidx = [ ...
    ones(length(rsq_cont),1); ...
    2*ones(length(rsq_gabor),1); ...
    3*ones(length(rsq_NCdog),1)];

rsq_all = [rsq_cont(:); rsq_gabor(:); rsq_NCdog(:)];


figure; hold on
    subplot 221
        % Boxplot with fixed positions
        boxplot(rsq_all, gidx, 'Positions',[1 2 3], 'Labels', labels, 'Symbol','')
        
        % Jittered scatter (NOW aligned correctly)
        x_jitter = gidx + (rand(size(gidx)) - 0.5)*0.25;
        colors = [ ...
            0 0.45 0.74;   % blue (DoG x cos)
            0.5 0.5 0.5;   % gray (Custom Gabor)
            0.5 0.5 0.5];  % gray (Noncon DoG)
        
        hold on
        for i = 1:3
            idx = gidx == i;
            x_jitter = i + (rand(sum(idx),1) - 0.5)*0.25;
            
            scatter(x_jitter, rsq_all(idx), 20, ...
                'MarkerFaceColor', colors(i,:), ...
                'MarkerEdgeColor', 'none', ...
                'MarkerFaceAlpha', 0.6)
        end
        
        ylabel('R^2')
        set(gca,'TickDir','out')
        box off
        yticks(0:0.1:1)
print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\rsq_comparisons.pdf', '-dpdf','-bestfit')


=======

%% for CSHL 2026 poster


paramArray = results.params{modelIdx};

freq = squeeze(params(1,:));
IDs =  results.cellIDs;
rsq = results.R2{modelIdx};

clear As cycles effectiveSigma delts params ylim
figure;
movegui('center')
s=1;
for ic = [135 470 250 68 232 133 230 986]
    ind = find(IDs==ic);
    fprintf(['Cell ' num2str(ic) ',rsq= ' num2str(rsq(ind)) '\n'])
    params = paramArray{ind};
    As = params(2);
    delts = params(4);
    Ac = params(1);
    cycles = params(9);
    effectiveSigma = params(3) / sqrt(params(5));
    subplot(7,8,s)
        scatter(1, cycles)
        set(gca,'TickDir','out')
        ylim([0 0.1])
        ylabel('f, raw')
        subtitle(num2str(ic))
    subplot(7,8,s+8)
        scatter(1, abs(As),'r')
        set(gca,'TickDir','out')
        ylim([0 10])
        ylabel('As')
    s=s+1;
end
s=1;
for ic = [468 622 375]
    ind = find(IDs==ic);
    fprintf(['Cell ' num2str(ic) ',rsq= ' num2str(rsq(ind)) '\n'])
    params = paramArray{ind};
    As = params(2);
    delts = params(4);
    Ac = params(1);
    cycles = params(9);
    effectiveSigma = params(3) / sqrt(params(5));
    subplot(7,8,s+16)
        scatter(1, cycles)
        set(gca,'TickDir','out')
        ylim([0 0.1])
        ylabel('f, raw')
        subtitle(num2str(ic))
    subplot(7,8,s+24)
        scatter(1, abs(As),'r')
        set(gca,'TickDir','out')
        ylim([0 10])
        ylabel('As')
    s=s+1;
end

print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\stats_forExampleCells.pdf', '-dpdf','-bestfit')




for ic = 1:40
    params = paramArray{ic};
    As(ic) = params(2);
    cycles(ic) = params(9);
end

figure;
scatter(abs(As), cycles)
xlabel('As')
ylabel('f')

for ic = 1:40
    params = paramArray{ic};
    As(ic) = params(2);
    delts(ic) = params(4);
    Ac(ic) = params(1);
    cycles(ic) = params(9);
    effectiveSigma(ic) = params(3) / sqrt(params(5));
end

figure;
for ic = 1:size(STA_cropped,3)
    subplot(6,7,ic)
        clim = max(abs(STA_cropped(:)));
        imagesc(STA_cropped(:,:,ic),[-clim clim])
        subtitle(['f ' num2str(round(cycles(ic),2)) ', As ' num2str(abs(round(As(ic),1))) ])
        axis image off
        axis square
        colormap gray
        hold on
end
print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\STAs_cropped_withStats.pdf', '-dpdf','-bestfit')



        
figure;
    ax = axes;
    
    As_abs = abs(As);
    
    scatter(As_abs, cycles, 10, 'k') % optional reference points
    xlabel('|As|')
    ylabel('f')
    hold on
    
    axpos = ax.Position;   % position of main axes in figure
    
    for ic = 1:length(As_abs)
    
        % normalize data within axes limits
        xn = (As_abs(ic) - ax.XLim(1)) / diff(ax.XLim);
        yn = (cycles(ic) - ax.YLim(1)) / diff(ax.YLim);
    
        % convert to figure coordinates
        xf = axpos(1) + xn * axpos(3);
        yf = axpos(2) + yn * axpos(4);
    
        w = 0.03;
        h = 0.03;
    
        ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
    
        clim = max(abs(STA_cropped(:)));
        imagesc(STA_cropped(:,:,ic),[-clim clim])
        axis image off
        colormap gray
    end





save(fullfile( '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\', 'results', 'RFparams_raw.mat'), 'As', 'cycles');




%% for dept talk 2026
modelIdx = find(strcmp({modelRegistry.name}, 'DoG x cos')); 
RFs_cont = results.models{modelIdx};
rsq_cont = results.R2{modelIdx};

modelIdx = find(strcmp({modelRegistry.name}, 'Custom Gabor')); %DoG x cos
RFs_gabor = results.models{modelIdx};
rsq_gabor = results.R2{modelIdx};

modelIdx = find(strcmp({modelRegistry.name}, 'Noncon DoG')); %DoG x cos
RFs_NCdog = results.models{modelIdx};
rsq_NCdog = results.R2{modelIdx};

figure;
is=1;
for ic = 1:size(STA_cropped,3)
    subplot(6,7,is)
        clim = max(max(abs(cell2mat(RFs_gabor))));
        imagesc(RFs_gabor{ic}, [-clim clim])
        subtitle(num2str(results.cellIDs(ic)))
        axis image off
        axis square
        colormap gray
        hold on
    is=is+1;
end
print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\traditionalGabor_fits.pdf', '-dpdf','-bestfit')
%print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\nonConEllipDoG_fits.pdf', '-dpdf','-bestfit')


myList = [135 470 250 68 232 133 230 986 468 622 375];

[tf, loc] = ismember(myList, results.cellIDs);

cellsPlotting = loc(tf);

rsq_gabor(cellsPlotting)
rsq_NCdog(cellsPlotting)




% boxplot w scatter of Rsq

labels = {'DoG x cos','Custom Gabor','Noncon DoG'};

% Assign numeric group indices manually
gidx = [ ...
    ones(length(rsq_cont),1); ...
    2*ones(length(rsq_gabor),1); ...
    3*ones(length(rsq_NCdog),1)];

rsq_all = [rsq_cont(:); rsq_gabor(:); rsq_NCdog(:)];


figure; hold on
    subplot 221
        % Boxplot with fixed positions
        boxplot(rsq_all, gidx, 'Positions',[1 2 3], 'Labels', labels, 'Symbol','')
        
        % Jittered scatter (NOW aligned correctly)
        x_jitter = gidx + (rand(size(gidx)) - 0.5)*0.25;
        colors = [ ...
            0 0.45 0.74;   % blue (DoG x cos)
            0.5 0.5 0.5;   % gray (Custom Gabor)
            0.5 0.5 0.5];  % gray (Noncon DoG)
        
        hold on
        for i = 1:3
            idx = gidx == i;
            x_jitter = i + (rand(sum(idx),1) - 0.5)*0.25;
            
            scatter(x_jitter, rsq_all(idx), 20, ...
                'MarkerFaceColor', colors(i,:), ...
                'MarkerEdgeColor', 'none', ...
                'MarkerFaceAlpha', 0.6)
        end
        
        ylabel('R^2')
        set(gca,'TickDir','out')
        box off
        yticks(0:0.1:1)
print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\rsq_comparisons.pdf', '-dpdf','-bestfit')

>>>>>>> origin/main
