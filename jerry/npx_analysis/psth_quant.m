
fnout = 'Z:\home\jerry\analysis\neuropixel\plot_central\savedvars\final';
% psth_concat = psth_data_raw;
% prefOri_concat = prefOris;
% psth_concat = [psth_concat psth_data_raw];
% prefOri_concat = [prefOri_concat;prefOris];


% psth_concat = [psth_concat(:,1:17,:) psth_concat(:,19:end,:)]; 
% prefOri_concat = [prefOri_concat(1:17);prefOri_concat(19:end)];

ymin = 0;
ymax = 50;

stimBarY = mean(psth_concat(:,:,1:20),"all");
smooth_window = 5;

[sz1 sz2 sz3] = size(psth_concat);
nCells = size(psth_concat,2);

psth_hori = psth_concat([1 3 5],prefOri_concat == 0,:);
psth_vert = psth_concat([2 4 6],prefOri_concat == 90,:);

psth_new = [psth_hori psth_vert];
psth_new = [psth_new(:,1:12,:) psth_new(:,14:25,:) psth_new(:,27:end,:)]; 

nCells = size(psth_new,2);

% grand average of all data without smoothing

psth_comb = squeeze(mean(psth_new,2));

titles = {'cross', 'iso', 'center'};

for iCond = 1:3
    figure
    plot(-0.19:0.010:0.40,psth_comb(iCond,:),"Color","k")
    hold on
    title(titles{iCond})
    xlabel('t')
    ylabel('FR')
    ylim([ymin 80])
    plot([0 0.1],[stimBarY stimBarY], 'r-', 'LineWidth', 2)
    hold off
    saveas(gcf, fullfile(fnout,[titles{iCond} 'PSTH.pdf']))
end

% overlay all 3
figure
hold on
for iCond = 1:3
    plot(-0.19:0.010:0.40,psth_comb(iCond,:))
end
title('Overlay')
xlabel('t')
ylabel('FR')
ylim([ymin 80])
legend(titles)
plot([0 0.1],[stimBarY stimBarY], 'r-', 'LineWidth', 2)
hold off
saveas(gcf, fullfile(fnout,'OLPSTH.pdf'))
%% original data individual plus sem
psth_comb = squeeze(mean(psth_new,2));
titles = {'cross', 'iso', 'center'};
t = -0.19:0.010:0.40;

for iCond = 1:3
    sem_cond = std(psth_new(iCond,:,:), 0, 2) / sqrt(nCells);
    sem_cond = squeeze(sem_cond);
    upper = psth_comb(iCond,:) + sem_cond';
    lower = psth_comb(iCond,:) - sem_cond';

    figure; hold on;
    fill([t fliplr(t)], [upper fliplr(lower)], [0.7 0.7 0.7], 'FaceAlpha', 0.4, 'EdgeColor', 'none');
    plot(t, psth_comb(iCond,:), 'Color', 'k', 'LineWidth', 1.5);
    plot([0 0.1], [stimBarY stimBarY], 'r-', 'LineWidth', 2);
    title(titles{iCond}); xlabel('t'); ylabel('FR');
    ylim([ymin 80]); hold off;
    saveas(gcf, fullfile(fnout, [titles{iCond} 'PSTH_sem.pdf']))
end
%% original data overlay plus sem
figure; hold on;
t = -0.19:0.010:0.40;
colors = [0.2 0.4 0.7; 0.6 0.8 0.9; 0.5 0.5 0.5];

for iCond = 1:3
    sem_cond = squeeze(std(psth_new(iCond,:,:), 0, 2)) / sqrt(nCells);
    upper = psth_comb(iCond,:) + sem_cond';
    lower = psth_comb(iCond,:) - sem_cond';
    
    fill([t fliplr(t)], [upper fliplr(lower)], colors(iCond,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    plot(t, psth_comb(iCond,:), 'Color', colors(iCond,:), 'LineWidth', 1.5);
end

plot([0 0.1], [stimBarY stimBarY], 'r-', 'LineWidth', 2);
title('Overlay'); xlabel('t'); ylabel('FR');
ylim([ymin 80]); xlim([t(1) t(end)]);
legend(titles); hold off;
saveas(gcf, fullfile(fnout, 'OLrawPSTH.pdf'))

%%  smoothing, for calculating rise, FWHM, fall, etc.
psth_cell_smooth = nan(3,nCells,60);

for icond = 1:3
    thisCond = squeeze(psth_new(icond,:,:));
    for ic = 1:nCells
        thisCell = thisCond(ic,:);
        psth_cell_smooth(icond,ic,:) = smoothdata(thisCell,'gaussian',smooth_window);
    end
end

psth_cellAvg_smooth = squeeze(mean(psth_cell_smooth,2));

for iCond = 1:3
    figure
    plot(-0.19:0.010:0.40,psth_cellAvg_smooth(iCond,:))
    hold on
    title(titles{iCond})
    xlabel('t')
    ylabel('FR')
    ylim([ymin 80])
    plot([0 0.1],[stimBarY stimBarY], 'r-', 'LineWidth', 2)
    hold off
end
% overlay
figure
hold on
for iCond = 1:3
    plot(-0.19:0.010:0.40,psth_cellAvg_smooth(iCond,:))
end
title('Overlay')
xlabel('t')
ylabel('FR')
ylim([ymin 80])
legend(titles)
plot([0 0.1],[stimBarY stimBarY], 'r-', 'LineWidth', 2)
hold off
saveas(gcf, fullfile(fnout,'OLsmoothPSTH.pdf'))
%% smooth with sem overlay
figure; hold on;
t = -0.19:0.010:0.40;
colors = [0.2 0.4 0.7; 0.6 0.8 0.9; 0.9 0.9 0.9];  % adjust as needed
smoothWin = 5;

for iCond = 1:3
    sem_smooth = std(psth_new(iCond, :, :), 0, 2) / sqrt(nCells);
    sem_smooth = squeeze(sem_smooth);
    % smooth sem the same way as your psth
    sem_smooth = smoothdata(sem_smooth, 'gaussian', smoothWin);
    
    upper = psth_cellAvg_smooth(iCond,:) + sem_smooth';
    lower = psth_cellAvg_smooth(iCond,:) - sem_smooth';
    
    fill([t fliplr(t)], [upper fliplr(lower)], colors(iCond,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    plot(t, psth_cellAvg_smooth(iCond,:), 'Color', colors(iCond,:), 'LineWidth', 1.5);
end

plot([0 0.1], [stimBarY stimBarY], 'r-', 'LineWidth', 2);
title('Overlay'); xlabel('t'); ylabel('FR');
ylim([ymin 80]); xlim([t(1) t(end)]);
legend(titles); hold off;
saveas(gcf, fullfile(fnout, 'OLsmoothPSTHtry.pdf'))


%% peak firing rate calculated from raw data (psth_new)

peakFRbyCell = max(psth_new(:,:,23:34),[],3);
baseFRbyCell = mean(psth_new(:,:,11:20),3);
meanRespByCell =  mean(psth_new(:,:,23:34),3);

global_peak = max(peakFRbyCell, [], 1);     % 1 x nCells
global_base = mean(baseFRbyCell, 1);    % 1 x nCells

norm_response_byCell = (meanRespByCell - global_base) ./ (global_peak - global_base);
norm_peak_byCell     = (peakFRbyCell   - global_base) ./ (global_peak - global_base);


%old
% norm_response_byCell = (meanRespByCell - baseFRbyCell) ./ (peakFRbyCell - baseFRbyCell);
% norm_response_byCell(peakFRbyCell == baseFRbyCell) = 0;
% 
% norm_peak_byCell = peakFRbyCell ./ (peakFRbyCell - baseFRbyCell);
% norm_peak = mean(norm_peak_byCell,2);
% sem_peak = std(norm_peak_byCell, 0, 2) / sqrt(nCells);


norm_response = mean(norm_response_byCell,2);
norm_peak = mean(norm_peak_byCell,2);

sem = std(norm_response_byCell, 0, 2) / sqrt(nCells);
sem_peak = std(norm_peak_byCell, 0, 2) / sqrt(nCells);

figure
hold on;
errorbar(1:3, norm_response, sem, '-o', 'LineWidth', 1.5, 'CapSize', 8,'Color', 'k','MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black');
errorbar(1:3, norm_peak, sem_peak, '-o', 'LineWidth', 1.5, 'CapSize', 8,'Color', 'b','MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
xticks(1:3);
xticklabels({'Cross', 'Iso', 'Center'});
ylabel('Normalized FR');
ylim([0 1])
xlim([0.5 3.5]);
legend({'Mean FR', 'Peak FR'});
title('Normalized Mean and Peak FR')
hold off
set(gca, 'XDir', 'reverse');
saveas(gcf, fullfile(fnout,'MeanNPeakFR.pdf'))

figure
hold on;
errorbar(1:3, norm_response, sem, '-o', 'LineWidth', 1.5, 'CapSize', 8,'Color', 'k','MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black');
xticks(1:3);
xticklabels({'Cross', 'Iso', 'Center'});
ylabel('Normalized FR');
ylim([0.1 0.35])
xlim([0.5 3.5]);
title('Normalized Mean FR')
hold off
set(gca, 'XDir', 'reverse');
saveas(gcf, fullfile(fnout,'MeanFRZoom.pdf'))

[h1, p1] = ttest(norm_response_byCell(1,:), norm_response_byCell(2,:), 'Alpha', 0.05/3);
[h2, p2] = ttest(norm_response_byCell(2,:), norm_response_byCell(3,:), 'Alpha', 0.05/3);
[h3, p3] = ttest(norm_response_byCell(1,:), norm_response_byCell(3,:), 'Alpha', 0.05/3);

t = array2table(norm_response_byCell', 'VariableNames', {'Cross', 'Iso', 'Center'});
rm = fitrm(t, 'Cross-Center ~ 1');
ranovatbl = ranova(rm);

[h4, p4] = ttest(norm_peak_byCell(1,:), norm_peak_byCell(2,:), 'Alpha', 0.05/3);
[h5, p5] = ttest(norm_peak_byCell(2,:), norm_peak_byCell(3,:), 'Alpha', 0.05/3);
[h6, p6] = ttest(norm_peak_byCell(1,:), norm_peak_byCell(3,:), 'Alpha', 0.05/3);

t2 = array2table(norm_peak_byCell', 'VariableNames', {'Cross', 'Iso', 'Center'});
rm2 = fitrm(t2, 'Cross-Center ~ 1');
ranovatbl2 = ranova(rm2);

%% pie

values = [27, 92-27, 302-92];
labels = {['Final: 27'], ['Good fit only: 65'], ['Excluded: 210']};

figure;
p = pie(values, labels);

colors = [0.2 0.4 0.7;   % blue - final
          0.6 0.8 0.9;   % light blue - good fit only
          0.9 0.9 0.9];  % light grey - poor fit

for i = 1:3
    p(i*2-1).FaceColor = colors(i,:);
end

saveas(gcf, fullfile(fnout,'nCellPie.pdf'))

%% time to peak

[~, peak_idx] = max(psth_new(:, :, 23:42), [], 3);  % 3 x nCells
time_to_peak = peak_idx + 22;  % shift back to original time index

bin_size_ms = 10;  
time_to_peak_ms = time_to_peak * bin_size_ms -200;
time_to_peak_mean = mean(time_to_peak * bin_size_ms,2)-200;

sem_tPeak = std(time_to_peak_ms, 0, 2) / sqrt(nCells);

[h7, p7] = ttest(time_to_peak_ms(1,:), time_to_peak_ms(2,:), 'Alpha', 0.05/3);
[h8, p8] = ttest(time_to_peak_ms(2,:), time_to_peak_ms(3,:), 'Alpha', 0.05/3);
[h9, p9] = ttest(time_to_peak_ms(1,:), time_to_peak_ms(3,:), 'Alpha', 0.05/3);

t3 = array2table(time_to_peak_ms', 'VariableNames', {'Cross', 'Iso', 'Center'});
rm3 = fitrm(t3, 'Cross-Center ~ 1');
ranovatbl3 = ranova(rm3);

figure
hold on;
errorbar(1:3, time_to_peak_mean, sem_tPeak, 'o', 'LineWidth', 1.5, 'CapSize', 8,'Color', 'k','MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black');
xticks(1:3);
xticklabels({'Cross', 'Iso', 'Center'});
ylabel('Peak (ms)');
ylim([70 95])
xlim([0.5 3.5]);
title('Normalized Mean FR')
hold off
set(gca, 'XDir', 'reverse');
saveas(gcf, fullfile(fnout,'tPeak.pdf'))

%% fwhm

half_peak = peakFRbyCell/2;

rise_idx  = zeros(3, nCells);
fall_idx  = zeros(3, nCells);

for iCond = 1:3
    for iCell = 1:nCells
        hp = half_peak(iCond, iCell);
        pk_idx = peak_idx(iCond, iCell);  % index within 23:42 window
        
        % full time series within response window
        trace = squeeze(psth_new(iCond, iCell, 23:42));
        
        % rising phase: from start to peak
        rise_trace = trace(1:pk_idx);
        rise_cross = find(rise_trace >= hp, 1, 'first');
        if ~isempty(rise_cross)
            rise_idx(iCond, iCell) = rise_cross + 22;  % back to original idx
        else
            rise_idx(iCond, iCell) = NaN;
        end
        
        % falling phase: from peak to end
        fall_trace = trace(pk_idx:end);
        fall_cross = find(fall_trace <= hp, 1, 'first');
        if ~isempty(fall_cross)
            fall_idx(iCond, iCell) = (pk_idx + fall_cross - 1) + 22;
        else
            fall_idx(iCond, iCell) = NaN;
        end
    end
end

riseT = rise_idx * 10 -200;                           % timebin of half-peak on rise
fallT = fall_idx * 10 -200;                           % timebin of half-peak on fall
fwhm              = (fall_idx - rise_idx) * 10;                % full width at half maximum

%% quantify the rest

riseT_mean = mean(riseT,2);
sem_rise = std(riseT, 0, 2) / sqrt(nCells);

fallT_mean = mean(fallT,2);
sem_fall = std(fallT, 0, 2) / sqrt(nCells);

fwhm_mean = mean(fwhm,2);
sem_fwhm = std(fwhm, 0, 2) / sqrt(nCells);

% T-tests with Bonferroni correction
[h10, p10] = ttest(riseT(1,:), riseT(2,:), 'Alpha', 0.05/3);
[h11, p11] = ttest(riseT(2,:), riseT(3,:), 'Alpha', 0.05/3);
[h12, p12] = ttest(riseT(1,:), riseT(3,:), 'Alpha', 0.05/3);

t4 = array2table(riseT', 'VariableNames', {'Cross', 'Iso', 'Center'});
rm4 = fitrm(t4, 'Cross-Center ~ 1');
ranovatbl4 = ranova(rm4);

figure; hold on;
errorbar(1:3, riseT_mean, sem_rise, 'o', 'LineWidth', 1.5, 'CapSize', 8, 'Color', 'k', 'MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black');
xticks(1:3); xticklabels({'Cross', 'Iso', 'Center'});
ylabel('Rise Time (ms)'); xlim([0.5 3.5]); title('Rise Time'); hold off;
set(gca, 'XDir', 'reverse');
saveas(gcf, fullfile(fnout, 'riseT.pdf'))

% Fall time
[h13, p13] = ttest(fallT(1,:), fallT(2,:), 'Alpha', 0.05/3);
[h14, p14] = ttest(fallT(2,:), fallT(3,:), 'Alpha', 0.05/3);
[h15, p15] = ttest(fallT(1,:), fallT(3,:), 'Alpha', 0.05/3);

t5 = array2table(fallT', 'VariableNames', {'Cross', 'Iso', 'Center'});
rm5 = fitrm(t5, 'Cross-Center ~ 1');
ranovatbl5 = ranova(rm5);

figure; hold on;
errorbar(1:3, fallT_mean, sem_fall, 'o', 'LineWidth', 1.5, 'CapSize', 8, 'Color', 'k', 'MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black');
xticks(1:3); xticklabels({'Cross', 'Iso', 'Center'});
ylabel('Fall Time (ms)'); xlim([0.5 3.5]); title('Fall Time'); hold off;
set(gca, 'XDir', 'reverse');
saveas(gcf, fullfile(fnout, 'fallT.pdf'))

% FWHM
[h16, p16] = ttest(fwhm(1,:), fwhm(2,:), 'Alpha', 0.05/3);
[h17, p17] = ttest(fwhm(2,:), fwhm(3,:), 'Alpha', 0.05/3);
[h18, p18] = ttest(fwhm(1,:), fwhm(3,:), 'Alpha', 0.05/3);

t6 = array2table(fwhm', 'VariableNames', {'Cross', 'Iso', 'Center'});
rm6 = fitrm(t6, 'Cross-Center ~ 1');
ranovatbl6 = ranova(rm6);

figure; hold on;
errorbar(1:3, fwhm_mean, sem_fwhm, 'o', 'LineWidth', 1.5, 'CapSize', 8, 'Color', 'k', 'MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black');
xticks(1:3); xticklabels({'Cross', 'Iso', 'Center'});
ylabel('FWHM (ms)'); xlim([0.5 3.5]); title('FWHM'); hold off;
set(gca, 'XDir', 'reverse');
saveas(gcf, fullfile(fnout, 'fwhm.pdf'))

%% rise and fall

figure; hold on;
errorbar(1:3, riseT_mean, sem_rise, 'o', 'LineWidth', 1.5, 'CapSize', 8, 'Color', 'k', 'MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black');
errorbar(1:3, fallT_mean, sem_fall, 'o', 'LineWidth', 1.5, 'CapSize', 8, 'Color', [0.5 0.5 0.5], 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerEdgeColor', [0.5 0.5 0.5]);
xticks(1:3); xticklabels({'Cross', 'Iso', 'Center'});
ylabel('Time (ms)'); xlim([0.5 3.5]);
legend({'Rise', 'Fall'}); title('Rise & Fall Time'); hold off;
set(gca, 'XDir', 'reverse');
saveas(gcf, fullfile(fnout, 'riseFallT.pdf'))

%% 