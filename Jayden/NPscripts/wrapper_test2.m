close all; clearvars; clc;

%% debug mode one cell test
debugMode = true;
debugCell = 457;   % check indRFint
%rng(0,'twister');   % randomness fully reproducible

manualParamMode = false;   % <<< toggle this
manualParams = [4.1284    4.3747   11.3467    5.7590    3.3143   -0.0708    4.2771    0.2266    0.0365    0.6787   14.4822   -0.9419];


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

indCortex   = find(depth_all>-1300);
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


end
% Generate a perfect 20x20 Gabor STA

nx = 20;
ny = 20;

x = (1:nx) - mean(1:nx);
y = (1:ny) - mean(1:ny);
[X, Y] = meshgrid(x, y);

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

R2_DoGCos  = nan(nCells,1);
AIC_DoGCos = nan(nCells,1);

RF_DoGCos  = cell(nCells,1);
params_all = cell(nCells,1);  % store parameters per cell

k = 0;

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

    k = k + 1;

    ic = ind_DS(ii);
    STA = STA_cropped(:, :, ii);
    n = numel(STA);

    fprintf('\n---- Cell %d ----\n', ic);

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
        [params, RF_fit, fitInfo] = fitNoncDoGCosineRF_diff(STA); % change moedl here

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

x = (1:nx) - mean(1:nx);
y = (1:ny) - mean(1:ny);
[X, Y] = meshgrid(x, y);

Xc = X - x0;
Yc = Y - y0;

Xs = X - (x0 + dx);
Ys = Y - (y0 + dy);

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
figure('Color', 'w', 'Position', [100 100 1200 700]);

subplot(2,4,1)
imagesc(rf_data)
axis image off
title('STA data')
colormap gray

subplot(2,4,2)
imagesc(Gc)
axis image off
title('Center envelope')

subplot(2,4,3)
imagesc(Gs)
axis image off
title('Surround envelope')

subplot(2,4,4)
imagesc(DoGenv)
axis image off
title('DoG envelope')

subplot(2,4,5)
imagesc(carrier)
axis image off
title('Carrier only')

subplot(2,4,6)
imagesc(centerPart)
axis image off
title('Center x carrier')

subplot(2,4,7)
imagesc(surroundPart)
axis image off
title('Surround x carrier')

subplot(2,4,8)
imagesc(fullModel)
axis image off
title('Full model')

F_data = fftshift(fft2(rf_data));
F_carrier = fftshift(fft2(carrier));
F_center = fftshift(fft2(centerPart));
F_surround = fftshift(fft2(surroundPart));
F_full = fftshift(fft2(fullModel));

M_data = abs(F_data);
M_carrier = abs(F_carrier);
M_center = abs(F_center);
M_surround = abs(F_surround);
M_full = abs(F_full);

L_data = log1p(M_data);
L_carrier = log1p(M_carrier);
L_center = log1p(M_center);
L_surround = log1p(M_surround);
L_full = log1p(M_full);

fx = (-floor(nx/2):ceil(nx/2)-1) / nx;
fy = (-floor(ny/2):ceil(ny/2)-1) / ny;
[FX, FY] = meshgrid(fx, fy);

fx_pred = f * cos(theta);
fy_pred = f * sin(theta);

figure('Color', 'w', 'Position', [100 100 1200 700]);

subplot(2,3,1)
imagesc(fx, fy, L_data)
axis image
set(gca, 'YDir', 'normal')
hold on
plot(fx_pred, fy_pred, 'ro', 'MarkerSize', 8, 'LineWidth', 2)
plot(-fx_pred, -fy_pred, 'ro', 'MarkerSize', 8, 'LineWidth', 2)
title('FFT: STA data')
xlabel('fx')
ylabel('fy')

subplot(2,3,2)
imagesc(fx, fy, L_carrier)
axis image
set(gca, 'YDir', 'normal')
hold on
plot(fx_pred, fy_pred, 'ro', 'MarkerSize', 8, 'LineWidth', 2)
plot(-fx_pred, -fy_pred, 'ro', 'MarkerSize', 8, 'LineWidth', 2)
title('FFT: carrier')

subplot(2,3,3)
imagesc(fx, fy, L_center)
axis image
set(gca, 'YDir', 'normal')
hold on
plot(fx_pred, fy_pred, 'ro', 'MarkerSize', 8, 'LineWidth', 2)
plot(-fx_pred, -fy_pred, 'ro', 'MarkerSize', 8, 'LineWidth', 2)
title('FFT: center x carrier')

subplot(2,3,4)
imagesc(fx, fy, L_surround)
axis image
set(gca, 'YDir', 'normal')
hold on
plot(fx_pred, fy_pred, 'ro', 'MarkerSize', 8, 'LineWidth', 2)
plot(-fx_pred, -fy_pred, 'ro', 'MarkerSize', 8, 'LineWidth', 2)
title('FFT: surround x carrier')

subplot(2,3,5)
imagesc(fx, fy, L_full)
axis image
set(gca, 'YDir', 'normal')
hold on
plot(fx_pred, fy_pred, 'ro', 'MarkerSize', 8, 'LineWidth', 2)
plot(-fx_pred, -fy_pred, 'ro', 'MarkerSize', 8, 'LineWidth', 2)
title('FFT: full model')

subplot(2,3,6)
imagesc(fx, fy, L_full - L_data)
axis image
set(gca, 'YDir', 'normal')
title('log FFT full - data')
xlabel('fx')
ylabel('fy')

%%
proj = FX * cos(theta) + FY * sin(theta);
r = sqrt(FX.^2 + FY.^2);

maskPos = proj > 0;

M = M_full;
M(r == min(r(:))) = 0;
M(~maskPos) = 0;

[~, idx] = max(M(:));
fy_peak = FY(idx);
fx_peak = FX(idx);
f_peak = sqrt(fx_peak^2 + fy_peak^2);

fprintf('Predicted f = %.4f\n', f);
fprintf('FFT-estimated full-model f = %.4f\n', f_peak);
fprintf('Peak location = (%.4f, %.4f)\n', fx_peak, fy_peak);

M = M_carrier;
M(r == min(r(:))) = 0;
M(~maskPos) = 0;

[~, idx] = max(M(:));
fy_peak_car = FY(idx);
fx_peak_car = FX(idx);
f_peak_car = sqrt(fx_peak_car^2 + fy_peak_car^2);

fprintf('FFT-estimated carrier f = %.4f\n', f_peak_car);

M = M_data;
M(r == min(r(:))) = 0;
M(~maskPos) = 0;

[~, idx] = max(M(:));
fy_peak_data = FY(idx);
fx_peak_data = FX(idx);
f_peak_data = sqrt(fx_peak_data^2 + fy_peak_data^2);

fprintf('FFT-estimated data f = %.4f\n', f_peak_data);
fprintf('Data peak location = (%.4f, %.4f)\n', ...
    fx_peak_data, fy_peak_data);
% debug_DoGCos_frequency_fft(params, 20);
% debug_STA_vs_model_fft(STA, params, 20);

% params = results.params{m}{cellIndex};

% checkFrequencyOrientation(STA, params);
% visualize_RF_validation(STA, RF_DoGCos{k}, params)