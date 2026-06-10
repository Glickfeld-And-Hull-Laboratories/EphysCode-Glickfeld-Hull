%% Compare elliptical nonconcentric DoG vs elliptical Gabor by R2
% One cell per PDF page:
% STA | DoG fit | Gabor fit | winner + R2 summary
%
% Required:
%   dogSummaryFile   = .mat containing exportSummary for DoG model
%   gaborSummaryFile = .mat containing exportSummary for Gabor model
%   STA_cropped      = [H x W x nCells] aligned to fitted cells
%
% If STA_cropped is saved in another .mat file, load it below.

clear; clc; close all;

%% -----------------------------
% User settings
%% -----------------------------
%% debug mode one cell test
debugMode = false;
debugCell = 1080;   % check indRFint
%rng(0,'twister');   % randomness fully reproducible

%% Load data 
% load file with data concatenated across experiments

analysisDir=('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase');
load([analysisDir '\CrossOri_randDirFourPhase_summary.mat'])

totalCells = totCells;   % cell number

fprintf('Loaded %d cells.\n', totalCells);

%%
vars = whos('-file', fullfile(analysisDir, ...
    'CrossOri_randDirFourPhase_summary.mat'));

for i = 1:numel(vars)
    fprintf('%-35s %s\n', vars(i).name, mat2str(vars(i).size));
end

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
% Use visually responsive cells with reliable RFs.
cellsSelected = intersect(idxInt, resp_ind_dir_all);

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

sideLength = 20;
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

outDir = "";

%dogSummaryFile   = fullfile(outDir, "DoGXCosWeightedDoG_summary.mat");
gaborSummaryFile = fullfile(outDir, "DoGXCosWeightedgabor_summary.mat");
%staFile = fullfile(outDir, "STA_cropped.mat");

pdfFile = fullfile(outDir, "Gabor_ranked_by_aspect_ratio.pdf");
csvFile = fullfile(outDir, "Gabor_ranked_by_aspect_ratio.csv");

%% -----------------------------
% Load
%% -----------------------------
S = load(gaborSummaryFile);
G = S.exportSummary;

%load(staFile, "STA_cropped");

cellIDs = G.fittedCellIDs(:);
R2 = G.R2(:);
params = G.params;

%% -----------------------------
% Extract aspect ratio
% Assumes Gabor aspect ratio / elongation is parameter 5
%% -----------------------------
nCells = numel(params);
aspectRatio = nan(nCells, 1);

for i = 1:nCells
    p = params{i};

    if isempty(p) || numel(p) < 5
        continue
    end

    aspectRatio(i) = p(5);
end

%% -----------------------------
% Rank by aspect ratio
%% -----------------------------
valid = isfinite(aspectRatio) & isfinite(R2);

[aspectSorted, sortIdxLocal] = sort(aspectRatio(valid), "descend");

validIdx = find(valid);
sortIdx = validIdx(sortIdxLocal);

rankedCellIDs = cellIDs(sortIdx);
rankedR2 = R2(sortIdx);

%% -----------------------------
% Save CSV
%% -----------------------------
rankTable = table;
rankTable.rank = (1:numel(sortIdx))';
rankTable.cellID = rankedCellIDs;
rankTable.aspectRatio = aspectSorted;
rankTable.R2 = rankedR2;

writetable(rankTable, csvFile);
fprintf("Saved ranking CSV: %s\n", csvFile);

%% -----------------------------
% Save Gabor AR per cell for later comparison
%% -----------------------------
gaborARTable = table;
gaborARTable.cellID = cellIDs(:);
gaborARTable.Gabor_AR = aspectRatio(:);
gaborARTable.Gabor_R2 = R2(:);

gaborARFile = fullfile(outDir, "Gabor_AR_per_cell.csv");
writetable(gaborARTable, gaborARFile);

fprintf("Saved Gabor AR table: %s\n", gaborARFile);

%% -----------------------------
% Global grayscale scale based on STA contrast
%% -----------------------------
staVals = STA_cropped(:);
staVals = staVals(isfinite(staVals));

globalMax = max(abs(staVals));

if isempty(globalMax) || globalMax == 0
    globalCLim = [-1 1];
else
    globalCLim = [-globalMax globalMax];
end

%% -----------------------------
% Get model RF stack
%% -----------------------------
gaborFit = getRFstack(G.modelRF, sortIdx);

%% -----------------------------
% Export PDF
%% -----------------------------
if exist(pdfFile, "file")
    delete(pdfFile);
end

for rr = 1:numel(sortIdx)

    k = sortIdx(rr);

    fig = figure("Color", "w", "Position", [100 100 1050 420]);

    tiledlayout(1, 3, "Padding", "compact", "TileSpacing", "compact");

    nexttile;
    imagesc(STA_cropped(:, :, k));
    axis image off;
    colormap(gca, gray);
    clim(gca, globalCLim);
    colorbar;
    title(sprintf("STA\nCell %d", cellIDs(k)), "Interpreter", "none");

    nexttile;
    imagesc(G.modelRF{k});
    axis image off;
    colormap(gca, gray);
    clim(gca, globalCLim);
    colorbar;
    title(sprintf("Gabor fit\nR� = %.4f", R2(k)), "Interpreter", "none");

    nexttile;
    axis off;

    p = params{k};

    infoTxt = {
        sprintf("Rank: %d / %d", rr, numel(sortIdx))
        sprintf("Cell ID: %d", cellIDs(k))
        ""
        sprintf("Aspect ratio: %.4f", aspectRatio(k))
        sprintf("R�: %.4f", R2(k))
        ""
        "Parameters:"
        sprintf("p1 = %.4f", p(1))
        sprintf("p2 = %.4f", p(2))
        sprintf("p3 = %.4f", p(3))
        sprintf("p4 = %.4f", p(4))
        sprintf("p5 aspect = %.4f", p(5))
    };

    text(0.05, 0.95, infoTxt, ...
        "FontSize", 13, ...
        "FontName", "Arial", ...
        "VerticalAlignment", "top", ...
        "Interpreter", "none");

    sgtitle(sprintf("Rank %d | Cell %d | Aspect ratio %.3f", ...
        rr, cellIDs(k), aspectRatio(k)), ...
        "FontSize", 15, ...
        "Interpreter", "none");

    exportgraphics(fig, pdfFile, "Append", true, "ContentType", "image");
    close(fig);

    if mod(rr, 25) == 0
        fprintf("Exported %d / %d cells...\n", rr, numel(sortIdx));
    end
end

fprintf("Saved ranked PDF: %s\n", pdfFile);

%% -----------------------------
% Export second PDF: model fits only, 50 cells per page
%% -----------------------------
pdfModelOnlyFile = fullfile(outDir, ...
    "Gabor_model_fits_only_ranked_by_aspect_ratio_50_per_page.pdf");

if exist(pdfModelOnlyFile, "file")
    delete(pdfModelOnlyFile);
end

nPerPage = 50;
nRows = 5;
nCols = 10;

nRanked = numel(sortIdx);
nPages = ceil(nRanked / nPerPage);

for pg = 1:nPages

    iStart = (pg - 1) * nPerPage + 1;
    iEnd = min(pg * nPerPage, nRanked);

    fig = figure("Color", "w", "Position", [50 50 1800 1000]);

    tiledlayout(nRows, nCols, ...
        "Padding", "compact", ...
        "TileSpacing", "compact");

    for rr = iStart:iEnd

        k = sortIdx(rr);

        nexttile;
        imagesc(G.modelRF{k});
        axis image off;
        colormap(gca, gray);
        clim(gca, globalCLim);

        title(sprintf("#%d C%d\nAR %.2f R� %.2f", ...
            rr, cellIDs(k), aspectRatio(k), R2(k)), ...
            "FontSize", 7, ...
            "Interpreter", "none");
    end

    sgtitle(sprintf("Gabor model fits ranked by aspect ratio | Page %d/%d", ...
        pg, nPages), ...
        "FontSize", 16, ...
        "Interpreter", "none");

    exportgraphics(fig, pdfModelOnlyFile, ...
        "Append", true, ...
        "ContentType", "image", ...
        "Resolution", 200);

    close(fig);
end

fprintf("Saved model-fit-only ranked PDF: %s\n", pdfModelOnlyFile);

%% ============================================================
% Helper function
%% ============================================================
function RFstack = getRFstack(modelRF, idx)
    if iscell(modelRF)
        firstValid = find(~cellfun(@isempty, modelRF), 1);
        sz = size(modelRF{firstValid});
        RFstack = nan(sz(1), sz(2), numel(idx));

        for ii = 1:numel(idx)
            rf = modelRF{idx(ii)};
            if ~isempty(rf)
                RFstack(:, :, ii) = rf;
            end
        end

    elseif isnumeric(modelRF)
        RFstack = modelRF(:, :, idx);

    else
        error("Unknown modelRF format.");
    end
end