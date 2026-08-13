close all; clearvars; clc;

%% debug mode one cell test
debugMode = false;
debugCell = 1080;   % check indRFint
%rng(0,'twister');   % randomness fully reproducible

%% Load data 
% load file with data concatenated across experiments

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

% totalCells = totCells;   % cell number

fprintf('Loaded %d cells.\n', totalCells);

%%
vars = whos('-file', fullfile(analysisDir, ...
    'CrossOri_randDirFourPhase_summary.mat'));

for i = 1:numel(vars)
    fprintf('%-35s %s\n', vars(i).name, mat2str(vars(i).size));
end

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
% Use visually responsive cells with reliable RFs.
cellsSelected = intersect(idxInt, ind);

if debugMode
    assert(ismember(debugCell, cellsSelected), ...
        'debugCell is not in cellsSelected.');
    cellsSelected = debugCell;
end

cellIDs = cellsSelected(:);

fprintf('Selected %d cells for fitting.\n', numel(cellIDs));

%%

rfvisresp = intersect(resp_ind_dir_all, idxInt);
figure; 
    histogram(DSI_all(rfvisresp),100)

 xxx = find(DSI_all(rfvisresp)<.3);




%% Calculate time point of STA
% The first dimension of bestTimePoint_all is the one computed by the local contrast method

cellsToRun = unique(cellIDs(:))';

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
%% Crop STA around RF center

sideLength = 29;
nSelected = numel(cellIDs);

rotateSTA = false; % change this
rotationK = 1;   % 1 = 90 deg CCW, -1 = 90 deg CW

STA_cropped = nan(sideLength, sideLength, nSelected);

for k = 1:nSelected

    ic = cellIDs(k);

    fprintf('k = %d maps to original cell index ic = %d\n', k, ic);

    avgImgZscore = squeeze(avgImgZscore_all(ic, :, :, :));
    bestTP = bestTimePoint_all(ic, 1);

    data = squeeze(avgImgZscore(bestTP, :, :));
    data = medfilt2(imgaussfilt(data, 1));

    [el, az] = getRFcenter(data);

    STA_crop = cropRFtoCenter(az, el, data, sideLength);

    if rotateSTA
        STA_crop = rot90(STA_crop, rotationK);
    end

    STA_cropped(:, :, k) = STA_crop;
end

%% ============================================================
% Export RF machine-learning dataset for PyTorch
% Each row = one selected cell from cellIDs
% ============================================================

outFile = "RF_ML_dataset.mat";

%% -----------------------------
% Basic checks
%% -----------------------------

assert(exist("avgImgZscore_all", "var") == 1, "Missing avgImgZscore_all");
assert(exist("bestTimePoint_all", "var") == 1, "Missing bestTimePoint_all");
assert(exist("avg_resp_dir_all", "var") == 1, "Missing avg_resp_dir_all");
assert(exist("F1F0_all", "var") == 1, "Missing F1F0_all");
assert(exist("DSI_prefdir", "var") == 1, "Missing DSI_prefdir");
assert(exist("cellIDs", "var") == 1, "Missing cellIDs");

fittedCellIDs = cellIDs(:);
nCells = numel(fittedCellIDs);

nStimDir = size(avg_resp_dir_all, 2);
nOri = nStimDir / 2;

assert(mod(nStimDir, 2) == 0, "nStimDir must be even.");

STA_images = nan(nCells, sideLength, sideLength);
DSI = nan(nCells, 1);
OSI = nan(nCells, 1);
F1F0 = nan(nCells, 1);
dataOriDeg = nan(nCells, 1);
dataPrefDirDeg = nan(nCells, 1);
prefDirInd_all = nan(nCells, 1);
prefOriInd_all = nan(nCells, 1);
respDir_all_selected = nan(nCells, nStimDir);
respOri_all_selected = nan(nCells, nOri);
bestTP_selected = nan(nCells, 1);
prefFR = nan(nCells,1);

%% -----------------------------
% Direction/orientation angles
%% -----------------------------

dirAnglesDeg = linspace(0, 360, nStimDir + 1);
dirAnglesDeg(end) = [];

oriAnglesDeg = dirAnglesDeg(1:nOri);

%% -----------------------------
% Preferred-direction F1/F0
%% -----------------------------

pref_F1F0_all = nan(size(F1F0_all, 1), 1);

for iCell = 1:size(F1F0_all, 1)

    if iCell <= numel(DSI_prefdir) && ...
            isfinite(DSI_prefdir(iCell)) && ...
            DSI_prefdir(iCell) >= 1 && ...
            DSI_prefdir(iCell) <= size(F1F0_all, 2)

        pref_F1F0_all(iCell) = F1F0_all(iCell, DSI_prefdir(iCell));

    end
end

%% -----------------------------
% Loop through selected cells
%% -----------------------------

for ii = 1:nCells

    iCell = fittedCellIDs(ii);

    fprintf("Exporting ii = %d / %d, original cell = %d\n", ...
        ii, nCells, iCell);

    %% -----------------------------
    % Extract and crop STA
    %% -----------------------------

    avgImgZscore = squeeze(avgImgZscore_all(iCell, :, :, :));

    bestTP = bestTimePoint_all(iCell, 1);

    if ~isfinite(bestTP) || bestTP < 1
        bestTP = bestTimePoint_all(iCell, 3);
    end

    bestTP = round(bestTP);
    bestTP = max(1, min(bestTP, size(avgImgZscore, 1)));

    bestTP_selected(ii) = bestTP;

    data = squeeze(avgImgZscore(bestTP, :, :));
    data = medfilt2(imgaussfilt(data, 1));

    [el, az] = getRFcenter(data);

    STA_crop = cropRFtoCenter(az, el, data, sideLength);

    if exist("rotateSTA", "var") && rotateSTA
        if ~exist("rotationK", "var")
            rotationK = 1;
        end
        STA_crop = rot90(STA_crop, rotationK);
    end

    STA_images(ii, :, :) = STA_crop;

    %% -----------------------------
    % Direction response
    %% -----------------------------

    resp = squeeze(avg_resp_dir_all(iCell, :, 1, 1, 1));
    resp = resp(:)';

    resp(resp < 0) = 0;

    respDir_all_selected(ii, :) = resp;

    %% -----------------------------
    % DSI
    %% -----------------------------

    [RprefDir, prefDirInd] = max(resp);

    nullInd = prefDirInd + nOri;
    if nullInd > nStimDir
        nullInd = nullInd - nStimDir;
    end

    Rnull = resp(nullInd);

    if RprefDir + Rnull > 0
        DSI(ii) = (RprefDir - Rnull) / (RprefDir + Rnull);
    end

    prefDirInd_all(ii) = prefDirInd;
    dataPrefDirDeg(ii) = dirAnglesDeg(prefDirInd);

    %% -----------------------------
    % OSI
    %% -----------------------------

    oriResp = (resp(1:nOri) + resp(nOri + 1:end)) / 2;

    respOri_all_selected(ii, :) = oriResp;

    [RprefOri, prefOriInd] = max(oriResp);

    orthInd = prefOriInd + nStimDir / 4;
    if orthInd > nOri
        orthInd = orthInd - nOri;
    end

    Rorth = oriResp(orthInd);

    if RprefOri + Rorth > 0
        OSI(ii) = (RprefOri - Rorth) / (RprefOri + Rorth);
    end

    prefOriInd_all(ii) = prefOriInd;
    dataOriDeg(ii) = oriAnglesDeg(prefOriInd);

    %% -----------------------------
    % Preferred-direction F1/F0
    %% -----------------------------

    F1F0(ii) = pref_F1F0_all(iCell);
    prefFR(ii) = max(oriResp);

end

%% -----------------------------
% Save ML dataset
%% -----------------------------

save(outFile, ...
    "STA_images", ...            % [N x H x W]
    "fittedCellIDs", ...         % original cell indices
    "dataOriDeg", ...            % preferred orientation, 0180
    "dataPrefDirDeg", ...        % preferred direction, 0360
    "DSI", ...
    "OSI", ...
    "F1F0", ...
    "prefFR",...
    "respDir_all_selected", ...
    "respOri_all_selected", ...
    "prefDirInd_all", ...
    "prefOriInd_all", ...
    "bestTP_selected", ...
    "dirAnglesDeg", ...
    "oriAnglesDeg", ...
    "sideLength", ...
    "-v7.3");

fprintf("\nSaved PyTorch RF dataset to %s\n", outFile);
fprintf("STA_images size: [%d x %d x %d]\n", ...
    size(STA_images,1), size(STA_images,2), size(STA_images,3));
fprintf("Number of cells exported: %d\n", nCells);
%%

%% ============================================================
% Export best-time-point STAs
% 30 cells per page
%% ============================================================

%% ============================================================
% One page per cell: all STA time points
%% ============================================================

% cellsToPlot = cellsSelected(:);   % original cell IDs
% timePointsToShow = 1:size(avgImgZscore_all, 2);
% 
% outPdf = fullfile(outDir, 'STA_all_timepoints_one_cell_per_page.pdf');
% 
% if exist(outPdf, 'file')
%     delete(outPdf);
% end
% 
% for iCell = 1:numel(cellsToPlot)
% 
%     ic = cellsToPlot(iCell);
%     nTP = numel(timePointsToShow);
% 
%     allSTA = squeeze(avgImgZscore_all(ic, timePointsToShow, :, :));
%     clim = max(abs(allSTA(:)), [], 'omitnan');
% 
%     if ~isfinite(clim) || clim == 0
%         clim = 1;
%     end
% 
%     fig = figure('Color', 'w', ...
%         'Position', [100 100 220*nTP 300]);
% 
%     tiledlayout(1, nTP, ...
%         'TileSpacing', 'compact', ...
%         'Padding', 'compact');
% 
%     for j = 1:nTP
% 
%         it = timePointsToShow(j);
% 
%         STA = squeeze(avgImgZscore_all(ic, it, :, :));
%         STA = medfilt2(imgaussfilt(STA, 1));
% 
%         nexttile;
%         imagesc(STA, [-clim clim]);
%         axis image off;
%         colormap gray;
% 
%         if it == bestTimePoint_all(ic, 1)
%             title(sprintf('t%d best', it), ...
%                 'FontSize', 10, ...
%                 'FontWeight', 'bold');
%         else
%             title(sprintf('t%d', it), ...
%                 'FontSize', 10);
%         end
%     end
% 
%     sgtitle(sprintf('Cell %d STA across time points', ic), ...
%         'FontWeight', 'bold');
% 
%     exportgraphics(fig, outPdf, ...
%         'Append', true, ...
%         'ContentType', 'image');
% 
%     close(fig);
% 
%     fprintf('Saved cell %d / %d: cellID %d\n', ...
%         iCell, numel(cellsToPlot), ic);
% end
% 
% fprintf('\nSaved PDF: %s\n', outPdf);
%% Run Gabor fit
options.visualize = 0;
options.parallel  = 1;
options.shape     = 'elliptical';
options.runs      = 48;
% options.getAllFits = false;

% copy format from the first example
modelRegistry = [
    % 
    % struct( ...
    %     'name','Circular DoG', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitDoG2D(STA), ...
    %     'k',6)
    % 
    % struct( ...
    %     'name','Elliptical DoG', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitEllipticalDoG2D(STA,[],'unnormalized',20), ...
    %     'k',8)
    % 
    struct( ...
        'name','Noncon DoG', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNonConcentricEllipticalDoG(STA,'unnormalized',20), ...
        'k',10)
    % 
    % struct( ...
    %     'name','Custom Gabor', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitEllipGabor_fit_full(STA), ...
    %     'k',9)
    % 
    struct( ...
        'name','Gabor', ...
        'type','sg', ...
        'fitFcn', @(STA) fit2dGabor_JM(STA,options), ...
        'k',10)
    % struct( ...
    %     'name','DoG x cos alpha', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitNoncDoGCosineRF_sigmaXY(STA), ...
    %     'k',13)

    % struct( ...
    %     'name','DoG x cos tau', ...
    %     'type','standard', ...
    %     'fitFcn', @(STA) fitNoncDoGCosineRF_tau(STA), ...
    %      'k',11)
     % struct( ...
     %    'name','DoG x cos', ...
     %    'type','standard', ...
     %    'fitFcn', @(STA) fitNoncDoGCosineRF_tau(STA), ...
     %    'k',11)

    % struct('name','GGabor', ...
    %        'type','standard', ...
    %        'fitFcn', @(STA) fitConcentricDifferenceOfGaborsRF(STA,'unnormalized',50), ...
    %        'k',13)
];

% results = refitCellsNoSurroundAndExportPDF( ...
%     STA_cropped, ...
%     'refit_comparison.pdf', ...
%     1.0, ...
%     1.0, ...
%     'unnormalized', ...
%     20);
%% Global STA contrast scale

allPeak = nan(nSelected, 1);

for k = 1:nSelected
    sta = STA_cropped(:, :, k);
    allPeak(k) = max(abs(sta(:)));
end

globalClim = prctile(allPeak, 95);
%%
%% Run model fit

omitCells = [114, 634, 879, 1508, 1558, 1849];

fitIdx = 1:nSelected;

results = runRFModelComparison( ...
    fitIdx, ...
    cellIDs, ...
    STA_cropped, ...
    modelRegistry, ...
    omitCells, ...
    'pdf', ...
    'test_all_fit.pdf');

%%
modelNames = {results.modelRegistry.name};
nModels = numel(modelNames);

R2mat = nan(numel(results.cellIDs), nModels);

for m = 1:nModels
    R2mat(:, m) = results.R2{m};
end

R2table = array2table(R2mat, ...
    'VariableNames', matlab.lang.makeValidName(modelNames));

R2table.cellID = results.cellIDs;
R2table = movevars(R2table, 'cellID', 'Before', 1);

disp(R2table)


%% ============================================================
% STA Fourier orientation tuning vs plaid Zp / Zc
%
% Requires:
%   avg_resp_dir_all
%   cellIDs
%   STA_cropped
%   getZpZcStruct.m
%
% Assumes:
%   12 stimulus directions
%   4 plaid phases
% ============================================================

%% ------------------------------------------------------------
% 1. Calculate measured Zp and Zc
% ------------------------------------------------------------

ZpZcStruct_all = getZpZcStruct(avg_resp_dir_all, 'whole_cell');

% getZpZcStruct returns:
%   Zp/Zc = nPhase x totalCells
%
% Select only cells used in the STA analysis
Zp_selected = ZpZcStruct_all.Zp(:, cellIDs);
Zc_selected = ZpZcStruct_all.Zc(:, cellIDs);

assert(size(Zp_selected,1) == 4, ...
    'Expected exactly four plaid phases.');

nSelected = numel(cellIDs);

fprintf('\nZp/Zc calculated for %d STA-selected cells.\n', nSelected);


%% ------------------------------------------------------------
% 2. Plot measured Zp versus Zc
% ------------------------------------------------------------

threshold = 1.28;

figure('Color','w');
hold on;

phaseMarker = {'o','s','^','d'};

for ip = 1:4
    scatter(Zc_selected(ip,:), ...
            Zp_selected(ip,:), ...
            30, ...
            phaseMarker{ip}, ...
            'filled', ...
            'MarkerFaceAlpha',0.55, ...
            'DisplayName',sprintf('Phase %d',ip));
end

% Determine common plotting range
allVals = [Zp_selected(:); Zc_selected(:)];
allVals = allVals(isfinite(allVals));

plotMin = min([-3; allVals]);
plotMax = max([ 4; allVals]);

xline(threshold,'k--','Z_c = 1.28', ...
    'LabelVerticalAlignment','bottom');

yline(threshold,'k--','Z_p = 1.28', ...
    'LabelHorizontalAlignment','left');

% Zp - Zc = 1.28
xLine = linspace(plotMin,plotMax,500);
plot(xLine, xLine + threshold, 'k--', ...
    'HandleVisibility','off');

% Zc - Zp = 1.28
plot(xLine, xLine - threshold, 'k--', ...
    'HandleVisibility','off');

xlabel('Z_c');
ylabel('Z_p');

title(sprintf('Measured plaid selectivity, n = %d cells',nSelected));

axis square;
xlim([plotMin plotMax]);
ylim([plotMin plotMax]);

grid on;
box off;

legend('Location','best');


%% ------------------------------------------------------------
% 3. Summary Zp/Zc averaged across four plaid phases
% ------------------------------------------------------------

% One value per cell for later comparison with STA-derived OSI
meanZp = mean(Zp_selected,1,'omitnan')';
meanZc = mean(Zc_selected,1,'omitnan')';


%% ------------------------------------------------------------
% 4. 2-D Fourier transform of each STA
%
% Convert each spatial STA into a 0-180 degree orientation
% tuning curve from its Fourier power spectrum.
% ------------------------------------------------------------

oriStepDeg = 1;

% orientation bins: 0, 1, ..., 179 degrees
FT_oriDeg = (0:oriStepDeg:179)';

nOriFT = numel(FT_oriDeg);

STA_FT_tuning = nan(nSelected,nOriFT);

STA_OSI_global = nan(nSelected,1);
STA_OSI_peak   = nan(nSelected,1);
STA_prefOriDeg = nan(nSelected,1);


for k = 1:nSelected

    %% Get STA
    STA = double(STA_cropped(:,:,k));

    if all(~isfinite(STA(:)))
        continue
    end

    % Remove NaNs
    STA(~isfinite(STA)) = 0;

    % Remove DC / mean component
    STA = STA - mean(STA(:));


    %% 2-D Fourier transform
    F = fftshift(fft2(STA));

    % Use Fourier power
    P = abs(F).^2;


    %% Construct Fourier coordinate system

    [nY,nX] = size(P);

    xFreq = (-floor(nX/2):ceil(nX/2)-1);
    yFreq = (-floor(nY/2):ceil(nY/2)-1);

    [FX,FY] = meshgrid(xFreq,yFreq);

    radius = sqrt(FX.^2 + FY.^2);

    % Fourier orientation:
    % collapse opposite Fourier directions into 0-180 deg
    ftAngle = mod(atan2d(FY,FX),180);


    %% Remove DC frequency

    validFreq = radius > 0;

    P(~validFreq) = 0;


    %% Bin Fourier energy by orientation

    oriTuning = nan(nOriFT,1);

    halfBin = oriStepDeg/2;

    for io = 1:nOriFT

        thisOri = FT_oriDeg(io);

        % Circular orientation difference, period = 180 deg
        angleDiff = abs(mod(ftAngle - thisOri + 90,180) - 90);

        thisBin = ...
            validFreq & ...
            angleDiff <= halfBin;

        if any(thisBin(:))

            oriTuning(io) = sum(P(thisBin),'omitnan');

        end

    end


    %% Fill occasional empty angular bins

    if any(isnan(oriTuning))

        good = isfinite(oriTuning);

        if sum(good) > 2

            oriTuning = interp1( ...
                FT_oriDeg(good), ...
                oriTuning(good), ...
                FT_oriDeg, ...
                'linear', ...
                'extrap');

        end

    end


    %% Normalize orientation tuning

    if max(oriTuning) > 0

        oriTuning = oriTuning ./ max(oriTuning);

    end

    STA_FT_tuning(k,:) = oriTuning;


    %% --------------------------------------------------------
    % Global / vector OSI
    %
    % |sum R(theta) exp(i*2theta)| / sum R(theta)
    % ---------------------------------------------------------

    valid = isfinite(oriTuning);

    R = oriTuning(valid);
    theta = deg2rad(FT_oriDeg(valid));

    if sum(R) > 0

        STA_OSI_global(k) = ...
            abs(sum(R .* exp(1i*2*theta))) ./ sum(R);

    end


    %% --------------------------------------------------------
    % Peak OSI
    %
    % (Rpref - Rorth) / (Rpref + Rorth)
    % ---------------------------------------------------------

    [Rpref,prefInd] = max(oriTuning);

    prefOri = FT_oriDeg(prefInd);

    STA_prefOriDeg(k) = prefOri;

    orthOri = mod(prefOri + 90,180);

    [~,orthInd] = min(abs(FT_oriDeg - orthOri));

    Rorth = oriTuning(orthInd);

    if (Rpref + Rorth) > 0

        STA_OSI_peak(k) = ...
            (Rpref - Rorth) ./ ...
            (Rpref + Rorth);

    end

end


fprintf('\nSTA Fourier analysis complete.\n');
fprintf('Median global/vector OSI = %.3f\n', ...
    median(STA_OSI_global,'omitnan'));
fprintf('Median peak OSI          = %.3f\n', ...
    median(STA_OSI_peak,'omitnan'));


%% ------------------------------------------------------------
% 5. Example population FT tuning curves
% ------------------------------------------------------------

figure('Color','w');

imagesc(FT_oriDeg, ...
        1:nSelected, ...
        STA_FT_tuning);

xlabel('Orientation (deg)');
ylabel('STA cell');

title('STA Fourier orientation tuning');

colorbar;


%% ------------------------------------------------------------
% 6. STA GLOBAL OSI vs measured Zc
% ------------------------------------------------------------

valid = ...
    isfinite(STA_OSI_global) & ...
    isfinite(meanZc);

[rho,p] = corr( ...
    STA_OSI_global(valid), ...
    meanZc(valid), ...
    'Type','Spearman');

figure('Color','w');

scatter(STA_OSI_global(valid), ...
        meanZc(valid), ...
        35,'filled', ...
        'MarkerFaceAlpha',0.6);

xlabel('STA global / vector OSI');
ylabel('Mean Z_c across plaid phases');

title(sprintf( ...
    'STA global OSI vs Z_c: \\rho = %.3f, p = %.3g, n = %d', ...
    rho,p,sum(valid)));

grid on;
box off;


%% ------------------------------------------------------------
% 7. STA GLOBAL OSI vs measured Zp
%
% Main null expectation:
% little/no relationship between spatial orientation selectivity
% and pattern selectivity.
% ------------------------------------------------------------

valid = ...
    isfinite(STA_OSI_global) & ...
    isfinite(meanZp);

[rho,p] = corr( ...
    STA_OSI_global(valid), ...
    meanZp(valid), ...
    'Type','Spearman');

figure('Color','w');

scatter(STA_OSI_global(valid), ...
        meanZp(valid), ...
        35,'filled', ...
        'MarkerFaceAlpha',0.6);

xlabel('STA global / vector OSI');
ylabel('Mean Z_p across plaid phases');

title(sprintf( ...
    'STA global OSI vs Z_p: \\rho = %.3f, p = %.3g, n = %d', ...
    rho,p,sum(valid)));

grid on;
box off;


%% ------------------------------------------------------------
% 8. STA PEAK OSI vs measured Zc
% ------------------------------------------------------------

valid = ...
    isfinite(STA_OSI_peak) & ...
    isfinite(meanZc);

[rho,p] = corr( ...
    STA_OSI_peak(valid), ...
    meanZc(valid), ...
    'Type','Spearman');

figure('Color','w');

scatter(STA_OSI_peak(valid), ...
        meanZc(valid), ...
        35,'filled', ...
        'MarkerFaceAlpha',0.6);

xlabel('STA peak OSI');
ylabel('Mean Z_c across plaid phases');

title(sprintf( ...
    'STA peak OSI vs Z_c: \\rho = %.3f, p = %.3g, n = %d', ...
    rho,p,sum(valid)));

grid on;
box off;


%% ------------------------------------------------------------
% 9. STA PEAK OSI vs measured Zp
% ------------------------------------------------------------

valid = ...
    isfinite(STA_OSI_peak) & ...
    isfinite(meanZp);

[rho,p] = corr( ...
    STA_OSI_peak(valid), ...
    meanZp(valid), ...
    'Type','Spearman');

figure('Color','w');

scatter(STA_OSI_peak(valid), ...
        meanZp(valid), ...
        35,'filled', ...
        'MarkerFaceAlpha',0.6);

xlabel('STA peak OSI');
ylabel('Mean Z_p across plaid phases');

title(sprintf( ...
    'STA peak OSI vs Z_p: \\rho = %.3f, p = %.3g, n = %d', ...
    rho,p,sum(valid)));

grid on;
box off;


%% ------------------------------------------------------------
% 10. Print correlation summary
% ------------------------------------------------------------

fprintf('\n====================================================\n');
fprintf('STA Fourier OSI vs plaid selectivity\n');
fprintf('====================================================\n');

valid = isfinite(STA_OSI_global) & isfinite(meanZc);
[r,p] = corr(STA_OSI_global(valid),meanZc(valid),'Type','Spearman');

fprintf('Global OSI vs Zc : rho = %.3f, p = %.3g, n = %d\n', ...
    r,p,sum(valid));


valid = isfinite(STA_OSI_global) & isfinite(meanZp);
[r,p] = corr(STA_OSI_global(valid),meanZp(valid),'Type','Spearman');

fprintf('Global OSI vs Zp : rho = %.3f, p = %.3g, n = %d\n', ...
    r,p,sum(valid));


valid = isfinite(STA_OSI_peak) & isfinite(meanZc);
[r,p] = corr(STA_OSI_peak(valid),meanZc(valid),'Type','Spearman');

fprintf('Peak OSI   vs Zc : rho = %.3f, p = %.3g, n = %d\n', ...
    r,p,sum(valid));


valid = isfinite(STA_OSI_peak) & isfinite(meanZp);
[r,p] = corr(STA_OSI_peak(valid),meanZp(valid),'Type','Spearman');

fprintf('Peak OSI   vs Zp : rho = %.3f, p = %.3g, n = %d\n', ...
    r,p,sum(valid));

fprintf('====================================================\n');