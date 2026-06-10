%% Rank elliptical nonconcentric DoG by effective aspect ratio
% Model-fit-only PDF, 50 cells per page

clear; clc; close all;

%% -----------------------------
% User settings
%% -----------------------------
outDir = "";

dogSummaryFile = fullfile(outDir, "DoGXCosWeightedDoG_summary.mat");

pdfFile = fullfile(outDir, ...
    "DoG_model_fits_only_ranked_by_effective_AR_50_per_page.pdf");

csvFile = fullfile(outDir, ...
    "DoG_ranked_by_effective_AR.csv");

%% -----------------------------
% Load summary
%% -----------------------------
S = load(dogSummaryFile);
D = S.exportSummary;

cellIDs = D.fittedCellIDs(:);
R2 = D.R2(:);
params = D.params;

%% -----------------------------
% Calculate effective aspect ratio
%% -----------------------------
nCells = numel(params);

effectiveAR = nan(nCells, 1);
effectiveWidthX = nan(nCells, 1);
effectiveWidthY = nan(nCells, 1);
offsetMag = nan(nCells, 1);

nSigma = 2;  
% using 2 sigma as effective Gaussian size
% change to 1, 2, or 3 depending how wide you want the envelope

%% Real effective RF AR from final model RF
% This gives rotated major/minor axes

thresholdFrac = 0.30;   % high-contrast region
dogEffectiveAR = nan(nCells,1);
majorAxisPix = nan(nCells,1);
minorAxisPix = nan(nCells,1);
ellipseThetaDeg = nan(nCells,1);

for i = 1:nCells
    rf = getRF(D.modelRF, i);

    [dogEffectiveAR(i), majorAxisPix(i), minorAxisPix(i), ellipseThetaDeg(i)] = ...
        effectiveRFellipse(rf, thresholdFrac);
end
%% -----------------------------
% Rank
%% -----------------------------
valid = isfinite(effectiveAR) & isfinite(R2);

[arSorted, sortIdxLocal] = sort(effectiveAR(valid), "descend");

validIdx = find(valid);
sortIdx = validIdx(sortIdxLocal);

%% -----------------------------
% Save CSV
%% -----------------------------
rankTable = table;
rankTable.rank = (1:numel(sortIdx))';
rankTable.cellID = cellIDs(sortIdx);
rankTable.effectiveAR = effectiveAR(sortIdx);
rankTable.effectiveWidthX = effectiveWidthX(sortIdx);
rankTable.effectiveWidthY = effectiveWidthY(sortIdx);
rankTable.offsetMag = offsetMag(sortIdx);
rankTable.R2 = R2(sortIdx);

writetable(rankTable, csvFile);
fprintf("Saved CSV: %s\n", csvFile);

%% -----------------------------
% Global grayscale scale from model contrast
%% -----------------------------
modelVals = [];

for i = 1:numel(sortIdx)
    k = sortIdx(i);
    rf = getRF(D.modelRF, k);
    modelVals = [modelVals; rf(:)];
end

modelVals = modelVals(isfinite(modelVals));
globalMax = max(abs(modelVals));

if isempty(globalMax) || globalMax == 0
    globalCLim = [-1 1];
else
    globalCLim = [-globalMax globalMax];
end

%% -----------------------------
% Export PDF: 50 cells per page
%% -----------------------------
if exist(pdfFile, "file")
    delete(pdfFile);
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

        rf = getRF(D.modelRF, k);

        imagesc(rf);
        axis image off;
        colormap(gca, gray);
        clim(gca, globalCLim);

        title(sprintf("#%d C%d\nAR %.2f R2 %.2f", ...
            rr, cellIDs(k), effectiveAR(k), R2(k)), ...
            "FontSize", 7, ...
            "Interpreter", "none");
    end

    sgtitle(sprintf("DoG model fits ranked by effective aspect ratio | Page %d/%d", ...
        pg, nPages), ...
        "FontSize", 16, ...
        "Interpreter", "none");

    exportgraphics(fig, pdfFile, ...
        "Append", true, ...
        "ContentType", "image", ...
        "Resolution", 200);

    close(fig);
end

fprintf("Saved PDF: %s\n", pdfFile);
%% -----------------------------
% Save DoG AR per cell for later comparison
%% -----------------------------
dogARTable = table;
dogARTable.cellID = cellIDs(:);
dogARTable.DoG_effectiveAR = dogEffectiveAR(:);
dogARTable.DoG_majorAxisPix = majorAxisPix(:);
dogARTable.DoG_minorAxisPix = minorAxisPix(:);
dogARTable.DoG_effectiveThetaDeg = ellipseThetaDeg(:);
dogARTable.DoG_R2 = R2(:);

dogARFile = fullfile(outDir, "DoG_real_effective_RF_AR_per_cell.csv");
writetable(dogARTable, dogARFile);
fprintf("Saved DoG AR table: %s\n", dogARFile);

%% ============================================================
% Helper function
%% ============================================================
function rf = getRF(modelRF, k)

    if iscell(modelRF)
        rf = modelRF{k};

    elseif isnumeric(modelRF)
        rf = modelRF(:, :, k);

    else
        error("Unknown modelRF format.");
    end
end

function [AR, majorAxis, minorAxis, thetaDeg] = effectiveRFellipse(rf, thresholdFrac)

    rf = double(rf);
    rf(~isfinite(rf)) = 0;

    amp = abs(rf);

    if max(amp(:)) == 0
        AR = NaN;
        majorAxis = NaN;
        minorAxis = NaN;
        thetaDeg = NaN;
        return
    end

    % high contrast region
    mask = amp >= thresholdFrac * max(amp(:));

    if nnz(mask) < 5
        AR = NaN;
        majorAxis = NaN;
        minorAxis = NaN;
        thetaDeg = NaN;
        return
    end

    [yy, xx] = ndgrid(1:size(rf,1), 1:size(rf,2));

    % weighted by RF contrast
    w = amp;
    w(~mask) = 0;

    W = sum(w(:));

    mx = sum(xx(:) .* w(:)) / W;
    my = sum(yy(:) .* w(:)) / W;

    x = xx(:) - mx;
    y = yy(:) - my;

    Cxx = sum(w(:) .* x .* x) / W;
    Cyy = sum(w(:) .* y .* y) / W;
    Cxy = sum(w(:) .* x .* y) / W;

    C = [Cxx Cxy; Cxy Cyy];

    [V, E] = eig(C);

    eigVals = diag(E);
    [eigVals, order] = sort(eigVals, "descend");
    V = V(:, order);

    if eigVals(2) <= 0
        AR = NaN;
        majorAxis = NaN;
        minorAxis = NaN;
        thetaDeg = NaN;
        return
    end

    % axis lengths proportional to sqrt variance
    majorAxis = sqrt(eigVals(1));
    minorAxis = sqrt(eigVals(2));

    AR = majorAxis / minorAxis;

    % major-axis angle in image coordinates
    thetaDeg = atan2d(V(2,1), V(1,1));
    thetaDeg = mod(thetaDeg, 180);
end