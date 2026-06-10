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

dogSummaryFile   = fullfile(outDir, "DoGXCosWeightedDoG_summary.mat");
gaborSummaryFile = fullfile(outDir, "DoGXCosWeightedgabor_summary.mat");

%staFile = fullfile(outDir, "STA_cropped.mat");   % must contain STA_cropped

pdfFile = fullfile(outDir, "DoG_vs_Gabor_R2_comparison.pdf");
csvFile = fullfile(outDir, "DoG_vs_Gabor_R2_summary.csv");

dogLabel   = "Elliptical nonconcentric DoG";
gaborLabel = "Elliptical Gabor";

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
% Load summaries
%% -----------------------------
D = load(dogSummaryFile);
G = load(gaborSummaryFile);

Sdog = D.exportSummary;
Sgab = G.exportSummary;

%load(staFile, "STA_cropped");

%% -----------------------------
% Choose alignment ID
%% -----------------------------
if isfield(Sdog, "fittedCellIDs") && isfield(Sgab, "fittedCellIDs")
    dogIDs = Sdog.fittedCellIDs(:);
    gabIDs = Sgab.fittedCellIDs(:);
else
    dogIDs = Sdog.cellIDs(:);
    gabIDs = Sgab.cellIDs(:);
end

[commonIDs, idxDog, idxGab] = intersect(dogIDs, gabIDs, "stable");

nCommon = numel(commonIDs);
fprintf("Found %d common fitted cells.\n", nCommon);

%% -----------------------------
% Extract R2 and model RFs
%% -----------------------------
R2dog = Sdog.R2(idxDog);
R2gab = Sgab.R2(idxGab);

dogRF = Sdog.modelRF;
gabRF = Sgab.modelRF;

% Handle modelRF saved as cell or numeric array
dogFit = getRFstack(dogRF, idxDog);
gabFit = getRFstack(gabRF, idxGab);

% Align STA
if size(STA_cropped, 3) == numel(dogIDs)
    STA = STA_cropped(:, :, idxDog);
elseif size(STA_cropped, 3) == numel(Sdog.cellIDs)
    STA = STA_cropped(:, :, idxDog);
else
    error("STA_cropped third dimension does not match summary cell count.");
end

%% -----------------------------
% Winner by R2
%% -----------------------------
deltaR2 = R2dog - R2gab;

winner = strings(nCommon, 1);
winner(deltaR2 > 0) = dogLabel;
winner(deltaR2 < 0) = gaborLabel;
winner(deltaR2 == 0) = "Tie";

valid = isfinite(R2dog) & isfinite(R2gab);

nDogWin   = sum(deltaR2(valid) > 0);
nGabWin   = sum(deltaR2(valid) < 0);
nTie      = sum(deltaR2(valid) == 0);
nValid    = sum(valid);

fprintf("\n===== R2 comparison summary =====\n");
fprintf("Valid cells: %d\n", nValid);
fprintf("%s wins: %d cells, %.2f%%\n", dogLabel, nDogWin, 100*nDogWin/nValid);
fprintf("%s wins: %d cells, %.2f%%\n", gaborLabel, nGabWin, 100*nGabWin/nValid);
fprintf("Ties: %d cells, %.2f%%\n", nTie, 100*nTie/nValid);
fprintf("Median R2 DoG:   %.4f\n", median(R2dog(valid), "omitnan"));
fprintf("Median R2 Gabor: %.4f\n", median(R2gab(valid), "omitnan"));
fprintf("Median delta R2, DoG - Gabor: %.4f\n", median(deltaR2(valid), "omitnan"));

%% -----------------------------
% Export summary table
%% -----------------------------
summaryTable = table;
summaryTable.cellID = commonIDs;
summaryTable.R2_DoG = R2dog;
summaryTable.R2_Gabor = R2gab;
summaryTable.deltaR2_DoG_minus_Gabor = deltaR2;
summaryTable.winner = winner;

writetable(summaryTable, csvFile);
fprintf("Saved CSV summary: %s\n", csvFile);

%% -----------------------------
% Make PDF
%% -----------------------------
if exist(pdfFile, "file")
    delete(pdfFile);
end

% First page: summary
fig = figure("Color", "w", "Position", [100 100 1000 700]);
axis off;

txt = {
    "DoG vs Gabor R² comparison"
    ""
    sprintf("Number of common cells: %d", nCommon)
    sprintf("Number of valid cells: %d", nValid)
    ""
    sprintf("%s wins: %d cells, %.2f%%", dogLabel, nDogWin, 100*nDogWin/nValid)
    sprintf("%s wins: %d cells, %.2f%%", gaborLabel, nGabWin, 100*nGabWin/nValid)
    sprintf("Ties: %d cells, %.2f%%", nTie, 100*nTie/nValid)
    ""
    sprintf("Median R² DoG: %.4f", median(R2dog(valid), "omitnan"))
    sprintf("Median R² Gabor: %.4f", median(R2gab(valid), "omitnan"))
    sprintf("Median ΔR², DoG - Gabor: %.4f", median(deltaR2(valid), "omitnan"))
};

text(0.05, 0.9, txt, ...
    "FontSize", 16, ...
    "FontName", "Arial", ...
    "VerticalAlignment", "top");

exportgraphics(fig, pdfFile, "ContentType", "vector");
close(fig);

% Cell pages
for k = 1:nCommon

    fig = figure("Color", "w", "Position", [100 100 1200 450]);

    tiledlayout(1, 4, "Padding", "compact", "TileSpacing", "compact");

    nexttile;
    imagesc(STA(:, :, k));
    axis image off;
    colormap(gca, gray);
    clim(gca, globalCLim);
    colorbar;
    title(sprintf("STA\nCell %d", commonIDs(k)), "Interpreter", "none");
    
    nexttile;
    imagesc(dogFit(:, :, k));
    axis image off;
    colormap(gca, gray);
    clim(gca, globalCLim);
    colorbar;
    title(sprintf("%s\nR² = %.4f", dogLabel, R2dog(k)), "Interpreter", "none");
    
    nexttile;
    imagesc(gabFit(:, :, k));
    axis image off;
    colormap(gca, gray);
    clim(gca, globalCLim);
    colorbar;
    title(sprintf("%s\nR² = %.4f", gaborLabel, R2gab(k)), "Interpreter", "none");

    nexttile;
    axis off;

    if deltaR2(k) > 0
        winTxt = dogLabel;
    elseif deltaR2(k) < 0
        winTxt = gaborLabel;
    else
        winTxt = "Tie";
    end

    infoTxt = {
        sprintf("Cell ID: %d", commonIDs(k))
        ""
        sprintf("R² DoG:   %.4f", R2dog(k))
        sprintf("R² Gabor: %.4f", R2gab(k))
        ""
        sprintf("ΔR² = DoG - Gabor")
        sprintf("ΔR²: %.4f", deltaR2(k))
        ""
        sprintf("Winner:")
        char(winTxt)
    };

    text(0.05, 0.9, infoTxt, ...
        "FontSize", 14, ...
        "FontName", "Arial", ...
        "VerticalAlignment", "top", ...
        "Interpreter", "none");

    sgtitle(sprintf("Cell %d | Winner: %s", commonIDs(k), winTxt), ...
        "FontSize", 16, ...
        "Interpreter", "none");

    exportgraphics(fig, pdfFile, "Append", true, "ContentType", "image");
    close(fig);

    if mod(k, 25) == 0
        fprintf("Exported %d / %d cells...\n", k, nCommon);
    end
end

fprintf("Saved PDF report: %s\n", pdfFile);

%% ============================================================
% Helper functions
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
        if ndims(modelRF) == 3
            RFstack = modelRF(:, :, idx);
        else
            error("modelRF numeric array must be H x W x nCells.");
        end

    else
        error("Unknown modelRF format.");
    end
end

function clim = commonCLim(varargin)
    vals = [];
    for i = 1:nargin
        x = varargin{i};
        vals = [vals; x(:)];
    end

    vals = vals(isfinite(vals));
    m = max(abs(vals));

    if isempty(m) || m == 0
        clim = [-1 1];
    else
        clim = [-m m];
    end
end

function cmap = redbluecmap()
    n = 256;
    r = [(0:n/2-1)'/(n/2); ones(n/2,1)];
    g = [(0:n/2-1)'/(n/2); flipud((0:n/2-1)'/(n/2))];
    b = [ones(n/2,1); flipud((0:n/2-1)'/(n/2))];
    cmap = [r g b];
end