%% Compare DoG effective AR vs Gabor AR

clear; clc; close all;

%% -----------------------------
% User settings
%% -----------------------------
outDir = "";

dogARFile = fullfile(outDir, "DoG_real_effective_RF_AR_per_cell.csv");
gaborARFile = fullfile(outDir, "Gabor_AR_per_cell.csv");

outCSV = fullfile(outDir, "DoG_vs_Gabor_AR_comparison.csv");
outPDF = fullfile(outDir, "DoG_vs_Gabor_AR_comparison.pdf");

%% -----------------------------
% Load AR tables
%% -----------------------------
D = readtable(dogARFile);
G = readtable(gaborARFile);

%% -----------------------------
% Match cells
%% -----------------------------
T = innerjoin(D, G, "Keys", "cellID");

%% -----------------------------
% Force Gabor AR to be >= 1
%% -----------------------------
T.Gabor_AR_raw = T.Gabor_AR;

T.Gabor_AR = abs(T.Gabor_AR);

idxLessThan1 = isfinite(T.Gabor_AR) & T.Gabor_AR > 0 & T.Gabor_AR < 1;
T.Gabor_AR(idxLessThan1) = 1 ./ T.Gabor_AR(idxLessThan1);

fprintf("Converted %d Gabor AR values from <1 to >1.\n", sum(idxLessThan1));


valid = isfinite(T.DoG_effectiveAR) & isfinite(T.Gabor_AR);

T.AR_difference_DoG_minus_Gabor = T.DoG_effectiveAR - T.Gabor_AR;
T.AR_ratio_DoG_over_Gabor = T.DoG_effectiveAR ./ T.Gabor_AR;

T.DoG_larger_AR = T.DoG_effectiveAR > T.Gabor_AR;
T.Gabor_larger_AR = T.Gabor_AR > T.DoG_effectiveAR;

writetable(T, outCSV);
fprintf("Saved comparison CSV: %s\n", outCSV);

%% -----------------------------
% Summary
%% -----------------------------
fprintf("\n===== AR comparison summary =====\n");
fprintf("Matched cells: %d\n", height(T));
fprintf("Valid cells: %d\n", sum(valid));
fprintf("Median DoG AR: %.4f\n", median(T.DoG_effectiveAR(valid), "omitnan"));
fprintf("Median Gabor AR: %.4f\n", median(T.Gabor_AR(valid), "omitnan"));
fprintf("Median DoG - Gabor AR: %.4f\n", median(T.AR_difference_DoG_minus_Gabor(valid), "omitnan"));
fprintf("DoG AR larger: %d cells\n", sum(T.DoG_larger_AR(valid)));
fprintf("Gabor AR larger: %d cells\n", sum(T.Gabor_larger_AR(valid)));

%% -----------------------------
% Plot PDF
%% -----------------------------
if exist(outPDF, "file")
    delete(outPDF);
end

fig = figure("Color", "w", "Position", [100 100 800 700]);

scatter(T.Gabor_AR(valid), T.DoG_effectiveAR(valid), 45, "filled");
hold on;

maxVal = max([T.Gabor_AR(valid); T.DoG_effectiveAR(valid)], [], "omitnan");
plot([0 maxVal], [0 maxVal], "k--", "LineWidth", 1.5);

xlabel("Gabor aspect ratio");
ylabel("DoG effective aspect ratio");
title("DoG effective AR vs Gabor AR");

axis square;
grid on;

exportgraphics(fig, outPDF, "ContentType", "vector");
close(fig);

%% Histogram page
fig = figure("Color", "w", "Position", [100 100 800 600]);

histogram(T.AR_difference_DoG_minus_Gabor(valid), 30);
xline(0, "k--", "LineWidth", 1.5);

xlabel("DoG effective AR - Gabor AR");
ylabel("Cell count");
title("AR difference distribution");

grid on;

exportgraphics(fig, outPDF, "Append", true, "ContentType", "vector");
close(fig);

fprintf("Saved comparison PDF: %s\n", outPDF);