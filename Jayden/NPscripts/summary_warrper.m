%% Compare mismatch between two models in high-DSI group
% Group 3: DSI > 0.5

outDir = "";

file1 = fullfile(outDir, "DoGXCos_tau_summary.mat");
file2 = fullfile(outDir, "Gabor_gabor_summary.mat");

label1 = "Circular Model";
label2 = "Gabor";

S1 = load(file1);
S2 = load(file2);

M1 = S1.exportSummary;
M2 = S2.exportSummary;

%% Align by original cell ID
commonIDs = intersect(M1.cellIDs(:), M2.cellIDs(:));

[~, i1] = ismember(commonIDs, M1.cellIDs(:));
[~, i2] = ismember(commonIDs, M2.cellIDs(:));

%% Select high-DSI group
DSI = M1.DSI(i1);

groupMask = isfinite(DSI) & DSI > 0.5;

commonIDs = commonIDs(groupMask);
i1 = i1(groupMask);
i2 = i2(groupMask);

%% Choose mismatch metric
% Change these if you want env90 or offset instead.
err1 = M1.absFftMinusData(i1);
err2 = M2.absFftMinusData(i2);

valid = isfinite(err1) & isfinite(err2);

err1 = err1(valid);
err2 = err2(valid);
commonIDs = commonIDs(valid);

%% Paired statistics
diffErr = err2 - err1;

[pWilcoxon, ~, statsWilcoxon] = signrank(err2, err1);

[~, pTtest, ~, statsTtest] = ttest(err2, err1);

%% Direction of improvement
nBetterModel1 = sum(err1 < err2);
nBetterModel2 = sum(err2 < err1);
nTie = sum(err1 == err2);

fprintf('\nHigh-DSI group: DSI > 0.5\n');
fprintf('Valid paired cells: %d\n\n', numel(err1));

fprintf('%s median mismatch: %.2f deg\n', label1, median(err1));
fprintf('%s median mismatch: %.2f deg\n', label2, median(err2));
fprintf('Median paired difference (%s - %s): %.2f deg\n\n', ...
    label2, label1, median(diffErr));

fprintf('Wilcoxon signed-rank p = %.4g\n', pWilcoxon);
fprintf('Paired t-test p = %.4g\n\n', pTtest);

fprintf('%s better: %d cells\n', label1, nBetterModel1);
fprintf('%s better: %d cells\n', label2, nBetterModel2);
fprintf('Ties: %d cells\n', nTie);

if median(diffErr) < 0
    fprintf('\nInterpretation: %s has lower mismatch on average.\n', label2);
elseif median(diffErr) > 0
    fprintf('\nInterpretation: %s has lower mismatch on average.\n', label1);
else
    fprintf('\nInterpretation: median mismatch is equal.\n');
end

%% Plot paired comparison
figure('Color', 'w');

scatter(err1, err2, 50, 'filled');
hold on

maxLim = max([err1; err2], [], 'omitnan');
plot([0 maxLim], [0 maxLim], 'k--', 'LineWidth', 1.5);

axis square
xlim([0 maxLim])
ylim([0 maxLim])

xlabel(label1 + " mismatch, deg")
ylabel(label2 + " mismatch, deg")
title("High-DSI cells: paired orientation mismatch comparison")
grid on

%% ==========================================================
% R² comparison
%% ==========================================================

R2_1 = M1.R2(i1);
R2_2 = M2.R2(i2);

validR2 = isfinite(R2_1) & isfinite(R2_2);

R2_1 = R2_1(validR2);
R2_2 = R2_2(validR2);

deltaR2 = R2_2 - R2_1;

[pR2,~,statsR2] = signrank(R2_2, R2_1);

[~,pR2_ttest,~,statsR2_ttest] = ttest(R2_2, R2_1);

fprintf('\n====================================\n');
fprintf('R² Comparison (High DSI)\n');
fprintf('====================================\n');

fprintf('%s median R² = %.4f\n', ...
    label1, median(R2_1));

fprintf('%s median R² = %.4f\n', ...
    label2, median(R2_2));

fprintf('Median ΔR² (%s - %s) = %.4f\n', ...
    label2, label1, median(deltaR2));

fprintf('Mean ΔR² (%s - %s) = %.4f\n', ...
    label2, label1, mean(deltaR2));

fprintf('Wilcoxon signed-rank p = %.4g\n', pR2);
fprintf('Paired t-test p = %.4g\n', pR2_ttest);

fprintf('%s better R²: %d cells\n', ...
    label1, sum(R2_1 > R2_2));

fprintf('%s better R²: %d cells\n', ...
    label2, sum(R2_2 > R2_1));

fprintf('Tie: %d cells\n', ...
    sum(R2_1 == R2_2));


%% R² scatter

figure('Color','w');

scatter(R2_1, R2_2, 50, 'filled');
hold on

lims = [ ...
    min([R2_1;R2_2]), ...
    max([R2_1;R2_2]) ];

plot(lims, lims, 'k--', 'LineWidth', 1.5)

axis square
xlim(lims)
ylim(lims)

xlabel(label1 + " R²")
ylabel(label2 + " R²")

title(sprintf( ...
    'High DSI cells (n=%d), p=%.3g', ...
    numel(R2_1), pR2))

grid on
%%
fprintf('Fraction improved R² = %.1f%%\n', ...
    100*mean(R2_2 > R2_1));

fprintf('Fraction ΔR² > 0.02 = %.1f%%\n', ...
    100*mean(deltaR2 > 0.02));

fprintf('Fraction ΔR² > 0.05 = %.1f%%\n', ...
    100*mean(deltaR2 > 0.05));