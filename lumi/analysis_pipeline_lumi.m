% task 1: retinotopy/ 1 sec on, 1 sec off (~20mins) 
% task 2: actual experiment/ 0.1 sec on, 4.9 sec off (~50mins)

%%  Load experiment information
clear all; close all; clc

addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\repositories\EphysCode-Glickfeld-Hull'))
save_path = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\Analysis\Neuropixel';
baseDir   = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';

iexp_list = [3];   %  single(e.g.[2]) or combined([2,3])


all_contrasts = [0.1, 0.2, 0.4, 0.8];
all_sizes     = [7.5, 15, 30, 60, 120];
smooth_window = 5;

%% Extract units from KS output & run step1_cleanData (run once per session)

cd('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\Analysis\ISN_2025');

for iexp = iexp_list
    [exptStruct] = createExptStruct_tutorial(iexp);

    load(fullfile(baseDir, 'Lumi\Analysis\Neuropixel', exptStruct.date, ...
        [exptStruct.date '_' exptStruct.mouse '_unitStructs.mat']), ...
        'allUnitStruct', 'goodUnitStruct');

    % createStimStruct_sizeCon: task2 auto detection by ISI
    stimStruct = createStimStruct_sizeCon(exptStruct);


    unitStruct = goodUnitStruct;
    cd('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\Analysis\ISN_2025');
    [data, params] = step1_cleanData(exptStruct, stimStruct, unitStruct, save_path);
    fprintf('Processed: %s %s\n', exptStruct.date, exptStruct.mouse);
    

end

%% Load data and group sessions

cd('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\Analysis\ISN_2025');

save_path = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\Analysis\Neuropixel';

fieldsToKeep  = {'psth_byConDiam_stat','psth_byConDiam_moving','psth_byConDiam_all', ...
                 'psth_byConDiam_stat_longWin', ...
                 'peak_FR','avg_FR', ...
                 'rise_50','rise_20','rise_80','rise_20_80', ...
                 'fall_50','fall_20','fall_80','fall_80_20', ...
                 'FWHM','peak_time'};
paramsToKeep  = {'visResp_highConSmallDiam','visResp_byCondition_shortWin', ...
                 'visResp_byCondition_longWin','cellDepth'};



n_sessions  = numel(iexp_list);
group_data  = cell(1, n_sessions);
group_params= cell(1, n_sessions);
date_list   = cell(1, n_sessions);
units.ID    = [];
units.recID = [];


for i = 1:n_sessions
    iexp = iexp_list(i);                          %  FIX:     iexp 
    [exptStruct] = createExptStruct_tutorial(iexp);
    load([save_path, '\', exptStruct.date, '_', exptStruct.mouse, '_processedData.mat']);

    n_units_this = size(params.visResp_byCondition_longWin, 3);
    units.ID     = [units.ID, arrayfun(@(x) [num2str(x), ',', exptStruct.mouse], ...
                    1:n_units_this, 'un', 0)];
    units.recID  = [units.recID, repelem(i, n_units_this)];

    params.cellDepth = params.cellDepth(:)';
    group_data{i}    = data;
    group_params{i}  = params;
    date_list{i}     = exptStruct.mouse + "_" + exptStruct.date;
end

data   = CatStructFields(3, cell2mat(group_data),   'fieldnames', fieldsToKeep);
params = CatStructFields([1, 3, 3, 2], cell2mat(group_params), 'fieldnames', paramsToKeep); %params = CatStructFields([1,1,3,3,1], cell2mat(group_params), 'fieldnames', paramsToKeep);

timeVector = group_data{1}.timeVector;

%% Parameters & cell selection

all_contrasts = [0.1, 0.2, 0.4, 0.8];
all_sizes     = [7.5, 15, 30, 60, 120];
smooth_window = 5;

cellDepths = params.cellDepth;

% Depth filter: insertion 2000m, target = surface to 1200m deep
% KS depth from tip: [2000-1200, 2000] = [800, 2000]
depthLim = [800, 2000];   % 

% Visually responsive at smallest 3 sizes, any contrast (short window)
visResp_mask = squeeze(any(params.visResp_byCondition_shortWin(:, 1:3, :), [1 2]))';
depth_mask   = (cellDepths > depthLim(1)) & (cellDepths < depthLim(2));
cell_i       = find(visResp_mask & depth_mask);

fprintf('Responsive + depth filter: %d / %d units\n', numel(cell_i), numel(cellDepths));



%% Methods info in detail

for iexp = iexp_list
    [exptStruct] = createExptStruct_tutorial(iexp);
    load([save_path,'\',exptStruct.date,'_',exptStruct.mouse,'_processedData.mat']);
    stimStruct = createStimStruct_sizeCon(exptStruct);

    fprintf('\n=== Session: %s, Mouse: %s ===\n', exptStruct.date, exptStruct.mouse);

    fprintf('Total good units (after Phy2): %d\n', size(params.visResp_highConSmallDiam, 1));
    fprintf('Vis responsive units (high con, small size): %d\n', sum(params.visResp_highConSmallDiam));

    cellDepths_sess = params.cellDepth;
    depthLim        = [800, 2000];

    % Criteria 1: visResp_byCondition_shortWin, smallest 3 sizes, any contrast
    visResp_mask_sess = squeeze(any(params.visResp_byCondition_shortWin(:, 1:3, :), [1 2]))';
    depth_mask_sess   = (cellDepths_sess > depthLim(1)) & (cellDepths_sess < depthLim(2));
    cell_i_sess       = find(visResp_mask_sess & depth_mask_sess);

    fprintf('--- Criterion 1 (used for all figures) ---\n');
    fprintf('  Test: two-sample t-test (stim on vs baseline)\n');
    fprintf('  Response window: 0.02 ~ 0.15 sec after stim on\n');
    fprintf('  Sizes tested: 7.5 deg, 15 deg, 30 deg (smallest 3)\n');
    fprintf('  Contrasts tested: all 4 (any contrast)\n');
    fprintf('  Selection: responsive in at least 1 of 12 conditions\n');
    fprintf('  Visually responsive (criterion 1): %d / %d\n', sum(visResp_mask_sess), numel(visResp_mask_sess));
    fprintf('  + Depth filter (%d~%d um from tip): %d units\n', depthLim(1), depthLim(2), numel(cell_i_sess));

    task2_dur = (stimStruct.timestamps(end) - stimStruct.timestamps(1)) / 60;
    fprintf('Task2 duration: %.1f min\n', task2_dur);
    fprintf('Total trials (task2): %d\n', numel(stimStruct.timestamps));
    fprintf('Trials per condition (rows=sizes, cols=contrasts):\n');
    disp(data.info.sizeConMatrix);
    fprintf('Unique orientations: ');
    disp(data.info.all_oris');
end


%%  Fig 1b  Population average PSTHs, all sizes, high contrast (80%) 
% paper: average PSTH per size, baseline-subtracted, SEM shading

timeVector = group_data{1}.timeVector;

figure('Name','Fig 1b | Population PSTHs');
ax = [];
for size_i = 1:5
    ax(size_i) = subplot(1,5,size_i); hold on;
    y_data = squeeze(smoothdata(data.psth_byConDiam_stat(end, size_i, cell_i, 2:end-1), ...
                     4, 'gaussian', smooth_window));
    fast_errbar(timeVector(2:end-1), y_data, 1, 'shaded', true);
    xline(0, 'k--'); xline(0.1, 'k:');
    yline(0, 'k-', 'LineWidth', 0.5);
    fix_axes(gcf, 10, 'Time (s)', 'FR (Hz)'); axis square;
    title([num2str(all_sizes(size_i)) '']);
end
linkaxes(ax);
sgtitle('Fig 1b | Pop. PSTHs  80% contrast');

%%  Fig 1c  Normalised avg and peak FR vs size 
% paper: both avg (dark grey) and peak (light grey), normalized to max

figure('Name','Fig 1c | Size tuning');
subplot(1,2,1); hold on;
title('All contrasts');
for con_i = 1:4
    fast_errbar(all_sizes, ...
        squeeze(data.peak_FR(con_i,:,cell_i) ./ max(data.peak_FR(:,:,cell_i),[],[1 2])), ...
        3, 'color', [0.8 0.8 0.8]/con_i); % data.peak_FR[nContrasts × nSizes × nCells] 
    fast_errbar(all_sizes, ...
        squeeze(data.avg_FR(con_i,:,cell_i)  ./ max(data.avg_FR(:,:,cell_i),[],[1 2])), ...
        3, 'color', [0.7 0.7 0.7]/con_i);
end
xticks(all_sizes); ylim([0 1]);
fix_axes(gcf, 10, 'Diameter (°)', 'Norm FR'); axis square;

subplot(1,2,2); hold on;
title('Fig 1c | 80% contrast');
fast_errbar(all_sizes, ...
    squeeze(data.peak_FR(end,:,cell_i) ./ max(data.peak_FR(:,:,cell_i),[],[1 2])), ...
    2, 'color', [0.7 0.7 0.7], 'stats', true);
fast_errbar(all_sizes, ...
    squeeze(data.avg_FR(end,:,cell_i)  ./ max(data.avg_FR(:,:,cell_i),[],[1 2])), ...
    2, 'stats', true);
xticks(all_sizes); ylim([0 1]);
legend({'Peak','Average'}, 'Location','southwest');
fix_axes(gcf, 10, 'Diameter (°)', 'Norm FR'); axis square;

%%  Fig 1d,e  dPSTH traces: 157.5 and 1207.5 
% paper: pointwise subtraction of each unit's PSTH from 7.5 PSTH, then average

% Compute per-unit dPSTH for all sizes (subtract smallest size 7.5)
psth_all_smooth = smoothdata(data.psth_byConDiam_stat(end, :, cell_i, 2:end-1), ...
                             4, 'gaussian', smooth_window);
% psth_all_smooth: [1  5sizes  nCells  nTimeBins]

psth_all_smooth = squeeze(psth_all_smooth);  % [5, 37, 79] [5sizes × nTimeBins × nCells]

% dpsth: [5sizes  nCells  nBins]
dpsth = psth_all_smooth - psth_all_smooth(1,:,:);  % [5, 37, 79]


t_plot = timeVector(2:end-1);

figure('Name','Fig 1d,e | dPSTH');

% Fig 1d: 15  7.5
ax1=subplot(1,2,1); hold on;
dpsth_15 = squeeze(dpsth(2,:,:));   % [nCells  nBins]
fast_errbar(t_plot, dpsth_15, 1, 'shaded', true);
xline(0,'k--'); xline(0.1,'k:'); yline(0,'k--','LineWidth',0.5);
fix_axes(gcf, 10, 'Time (s)', 'FR (Hz)'); axis square;
title('Fig 1d | dPSTH: 15° - 7.5°');

% Fig 1e: 120  7.5
ax2=subplot(1,2,2); hold on;
dpsth_120 = squeeze(dpsth(5,:,:));   % [nCells  nBins]
fast_errbar(t_plot, dpsth_120, 1, 'shaded', true);
xline(0,'k--'); xline(0.1,'k:'); yline(0,'k--','LineWidth',0.5);
fix_axes(gcf, 10, 'Time (s)', 'FR (Hz)'); axis square;
title('Fig 1e | dPSTH: 120° - 7.5°');
linkaxes([ax1 ax2],'y')


%%  Fig 1d,e (overlay)

%% Fig 1b-style: Raw PSTH overlaid across sizes (not dPSTH)
psth_all_smooth_plot = squeeze(smoothdata(data.psth_byConDiam_stat(end, :, cell_i, 2:end-1), ...
                               4, 'gaussian', smooth_window)); % [5 x nCells x nTimeBins]

figure('Name', 'PSTH overlaid | all sizes');
size_pairs = {[1,2], [1,5], [1,2,3,4,5]};  % 7.5&15, 7.5&120, all
pair_titles = {'7.5° vs 15°', '7.5° vs 120°', 'All sizes'};

for p = 1:3
    subplot(1,3,p); hold on;
    idx = size_pairs{p};

    % dummy lines for legend
    h = gobjects(numel(idx),1);
    for k = 1:numel(idx)
        h(k) = plot(nan, nan, '-', 'Color', colors(idx(k),:), 'LineWidth', 2);
    end
    legend(h, arrayfun(@(s) [num2str(s) '°'], all_sizes(idx), 'UniformOutput', false), ...
        'Location', 'northeast', 'AutoUpdate', 'off');

    % actual data
    for k = 1:numel(idx)
        psth_this = squeeze(psth_all_smooth_plot(idx(k), :, :)); % [nCells x nTimeBins]
        fast_errbar(t_plot, psth_this, 1, 'color', colors(idx(k),:), 'shaded', true);
    end

    xline(0, 'k--'); xline(0.1, 'k:');
    yline(0, 'k--', 'LineWidth', 0.5);
    fix_axes(gcf, 10, 'Time (s)', 'FR (Hz)'); axis square;
    title(pair_titles{p});
end

linkaxes(findobj(gcf, 'Type', 'Axes'), 'y');
sgtitle(sprintf('PSTH overlaid | 80%% contrast | n=%d units', numel(cell_i)));


% figure('Name', 'Fig 1d,e | dPSTH all sizes overlaid');
% 
% colors = lines(5); % 5 sizes, different colors
% 
% 
% subplot(1,2,1); hold on;
% 
% % dummy lines for legend FIRST
% h = gobjects(5,1);
% for size_i = 1:5
%     h(size_i) = plot(nan, nan, '-', 'Color', colors(size_i,:), 'LineWidth', 2);
% end
% legend(h, arrayfun(@(s) [num2str(s) '°'], all_sizes, 'UniformOutput', false), ...
%     'Location', 'northeast', 'AutoUpdate', 'off');  % AutoUpdate off가 핵심
% 
% % 그 다음 실제 data plot
% for size_i = 1:5
%     psth_this = squeeze(dpsth(size_i, :, :));
%     fast_errbar(t_plot, psth_this, 1, 'color', colors(size_i,:), 'shaded', true);
% end
% xline(0, 'k--'); xline(0.1, 'k:');
% yline(0, 'k--', 'LineWidth', 0.5);
% fix_axes(gcf, 10, 'Time (s)', 'ΔFR (Hz)'); axis square;
% title('dPSTH: all sizes - 7.5° (overlaid)');
% 
% 
% subplot(1,2,2); hold on;
% 
% % dummy lines for legend FIRST
% h2 = gobjects(2,1);
% h2(1) = plot(nan, nan, '-', 'Color', colors(2,:), 'LineWidth', 2);  % 15°
% h2(2) = plot(nan, nan, '-', 'Color', colors(5,:), 'LineWidth', 2);  % 120°
% legend(h2, {'15°', '120°'}, 'Location', 'northeast', 'AutoUpdate', 'off');
% 
% fast_errbar(t_plot, squeeze(dpsth(2,:,:)), 1, 'color', colors(2,:), 'shaded', true);
% fast_errbar(t_plot, squeeze(dpsth(5,:,:)), 1, 'color', colors(5,:), 'shaded', true);
% xline(0, 'k--'); xline(0.1, 'k:');
% yline(0, 'k--', 'LineWidth', 0.5);
% fix_axes(gcf, 10, 'Time (s)', 'ΔFR (Hz)'); axis square;
% title('dPSTH: 15° vs 120° - 7.5°');
% 
% linkaxes(findobj(gcf, 'Type', 'Axes'), 'y');
% sgtitle(sprintf('dPSTH | 80%% contrast | n=%d units', numel(cell_i)));



%%  Fig 1f  dPSTH integral vs diameter 
% paper: sum of dPSTH from 00.35s after stim onset, per unit, then average

% Find time bins 00.35s
stim_on_bins = t_plot >= 0 & t_plot <= 0.35;

% Per-unit dPSTH integral for each size [5sizes  nCells]
dpsth_integral = squeeze(sum(dpsth(:,:,stim_on_bins), 3)) * ...
                 (timeVector(2)-timeVector(1));   % multiply by bin size (s)  Hzs
% dpsth_integral: [5sizes  nCells]

figure('Name','Fig 1f | dPSTH integral');
hold on;

% errorbar/ dpsth_integral: [5 x 37], all_sizes: [1 x 5]
mean_integral = mean(dpsth_integral, 2);   % [5 x 1]
sem_integral  = std(dpsth_integral, [], 2) / sqrt(size(dpsth_integral, 2));  % [5 x 1]
errorbar(all_sizes, mean_integral, sem_integral, 'ko-', 'LineWidth', 1.2, 'MarkerFaceColor', 'k');


yline(0, 'k--');
xticks(all_sizes);
fix_axes(gcf, 10, 'Diameter (°)', 'dPSTH integral (Hz*s)'); axis square;
title('Fig 1f | dPSTH integral');

%%  Fig 1h  Time to peak vs diameter 
% paper: time to peak of smoothed PSTH, 00.35s window

figure('Name','Fig 1h,i,j | Dynamics');

subplot(1,4,1); hold on;
fast_errbar(all_sizes, squeeze(data.peak_time(end,:,cell_i)), 2, ...
    'stats',true,'continuous',false);
ylim([0.1 0.18]); xticks(all_sizes); yticks(0.1:0.02:0.18);
fix_axes(gcf, 10, 'Diameter (°)', 'Time to peak (s)'); axis square;
%title('Fig 1h | Peak time');

%%  Fig 1i  Time to 50% rise and decay vs diameter 
% paper: both rise and decay on same plot

subplot(1,4,2); hold on;
fast_errbar(all_sizes, squeeze(data.rise_50(end,:,cell_i)), 2, ...
    'stats',true,'continuous',false);
fast_errbar(all_sizes, squeeze(data.fall_50(end,:,cell_i)), 2, ...
    'color',[0.6 0.6 0.6],'stats',true,'continuous',false);
ylim([0 0.2]); xticks(all_sizes); yticks(0:0.05:0.2);
legend({'Rise 50%','Decay 50%'},'Location','northeast');
fix_axes(gcf, 10, 'Diameter (°)', 'Time (s)'); axis square;
%title('Fig 1i | Rise & Decay');

%%  Fig 1j  FWHM vs diameter 

subplot(1,4,3); hold on;
fast_errbar(all_sizes, squeeze(data.FWHM(end,:,cell_i)), 2, ...
    'stats',true,'continuous',false);
ylim([0.05 0.09]); xticks(all_sizes); yticks(0.05:0.01:0.09);
fix_axes(gcf, 10, 'Diameter (°)', 'FWHM (s)'); axis square;
%title('Fig 1j | FWHM');

sgtitle(sprintf('Fig 1hj | 80%% contrast  |  n=%d units  |  depth %d%d m', ...
    numel(cell_i), depthLim(1), depthLim(2)));

%%  Depth distribution (QC) 

%% Depth distribution (QC) - with cell_i highlight

figure('Name','Depth distribution QC');
for exp_i = 1:n_sessions

    % units belonging to this session
    session_mask = (units.recID == exp_i);

    % cell_i units belonging to this session
    % cell_i is index into the combined units array
    session_cell_i = cell_i(ismember(cell_i, find(session_mask)));

    subplot(1, n_sessions, exp_i); hold on;

    % All good units (grey)
    histogram(cellDepths(session_mask), 'BinWidth', 100, ...
        'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'w');

    % cell_i units (blue) - visResp + depth filter
    histogram(cellDepths(session_cell_i), 'BinWidth', 100, ...
        'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'w');

    xline(depthLim(1), 'r--', 'LineWidth', 1.5);
    xline(depthLim(2), 'r--', 'LineWidth', 1.5);

    fix_axes(gcf, 10, 'Depth (um from tip)', 'Unit Count');
    axis square; xlim([0 2500]);
    legend({'All good units', sprintf('visResp + depth (n=%d)', numel(session_cell_i))}, ...
        'Location', 'northeast');
    title(date_list{exp_i});
end
sgtitle(sprintf('Depth distribution | total cell\\_i: %d units', numel(cell_i)));


% figure('Name','Depth distribution QC');
% for exp_i = 1:n_sessions
%     subplot(1, n_sessions, exp_i); 
%     histogram(cellDepths(units.recID == exp_i), 'BinWidth', 100);
%     hold on;
%     xline(depthLim(1), 'r--', 'LineWidth', 1.5);
%     xline(depthLim(2), 'r--', 'LineWidth', 1.5);
%     fix_axes(gcf, 10, 'Depth (um from tip)', 'Unit Count');
%     axis square; xlim([0 2500]); %xlim([0 3840]);
%     title(date_list{exp_i});
% end


%% Methods info in detail

for iexp = iexp_list
    [exptStruct] = createExptStruct_tutorial(iexp);
    load([save_path,'\',exptStruct.date,'_',exptStruct.mouse,'_processedData.mat']);
    stimStruct = createStimStruct_sizeCon(exptStruct);

    fprintf('\n=== Session: %s, Mouse: %s ===\n', exptStruct.date, exptStruct.mouse);

    % Total & responsive units
    fprintf('Total good units (after Phy2): %d\n', size(params.visResp_highConSmallDiam,1));
    fprintf('Vis responsive units (high con, small size): %d\n', sum(params.visResp_highConSmallDiam));

    % Depth filter  final cells
    cellDepths = params.cellDepth;
    depthLim = [800, 2000];
    visResp_mask = squeeze(any(params.visResp_byCondition_shortWin(:,1:3,:),[1 2]))';
    depth_mask = (cellDepths > depthLim(1)) & (cellDepths < depthLim(2));
    cell_i_sess = find(visResp_mask & depth_mask);
    fprintf('Final cells (vis resp + depth filter): %d\n', numel(cell_i_sess));
    fprintf('Depth filter: %d ~ %d um from tip\n', depthLim(1), depthLim(2));

    % Task2 duration
    task2_dur = (stimStruct.timestamps(end) - stimStruct.timestamps(1)) / 60;
    fprintf('Task2 duration: %.1f min\n', task2_dur);

    % Total trials
    fprintf('Total trials (task2): %d\n', numel(stimStruct.timestamps));

    % Trials per condition (size x contrast matrix)
    fprintf('Trials per condition (rows=sizes, cols=contrasts):\n');
    disp(data.info.sizeConMatrix);

    % Trials per condition per orientation
    fprintf('Unique orientations: ');
    disp(data.info.all_oris');
end

%%




% %%  ok/ Load experiment information
% 
% clear all; close all; clc
% 
% addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\repositories\EphysCode-Glickfeld-Hull'))
% save_path = 'C:\home\Lumi\Analysis\Neuropixels'; %'Z:\home\jen\Analysis\ISN 2025';
% 
% 
% baseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
% iexp =2; % Choose experiment, ex. [2,3]
% 
% [exptStruct] = createExptStruct_tutorial(iexp); % Load relevant times and directories for this experiment
% 
% 
% 
% iexp_list = [2, 3];
% all_contrasts = [0.1, 0.2, 0.4, 0.8];
% all_sizes     = [7.5, 15, 30, 60, 120];
% smooth_window = 5;
% 
% %%  ok/ Extract units from KS output
% % This tutorial uses sorted spiking data and stimulus information that is already synced to the neural data. For sorting in Kilosort and Phy2 and syncing using CatGT and TPrime, 
% % reference this protocol: https://docs.google.com/document/d/1Wmkkb9TnFrQzwDYZlS97jVEY9kwX42daFpmgGfw0XFE/edit?tab=t.0
% %
% 
%     % Extract units from KS output
% 
%     load(fullfile(baseDir, '\Lumi\Analysis\Neuropixel', [exptStruct.date], [exptStruct.date '_' exptStruct.mouse '_unitStructs.mat']), 'allUnitStruct', 'goodUnitStruct');
% 
% %
% 
% expt_list = 1;
% 
%     exptStruct.sizeCon_idx = 1;
%     % Load stimulus "on" timestamps
% 
%     stimStruct = createStimStruct_sizeCon(exptStruct);
% 
% 
% 
%     % Align to stim on and organize by stimulus condition
% 
% %%  ok/
% 
% cd \\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\Analysis\ISN_2025
% 
%     unitStruct = goodUnitStruct;
%     [data,params] = step1_cleanData(exptStruct,stimStruct,unitStruct,save_path);
%     disp(iexp);
% 
% 
% %% ok/ Load data and group
% 
% cd \\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\Analysis\ISN_2025
% 
% file_list = 1; % Subset of experiments in LGN, retDist from median RF to stim center < 15 deg
% save_path = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\Analysis\Neuropixel' %'C:\home\Lumi\Analysis\Neuropixels';
% units.ID = [];
% units.recID = [];
% n_experiments = length(file_list);
% 
% fieldsToKeep = {'psth_byConDiam_stat','psth_byConDiam_moving','psth_byConDiam_all','psth_byConDiam_stat_longWin',...
%     'peak_FR','avg_FR',...
%     'rise_50','rise_20','rise_80','rise_20_80','fall_50','fall_20','fall_80','fall_80_20',...
%     'FWHM','peak_time'};
% paramsToKeep = {'visResp_highConSmallDiam','visResp_highConSmallDiam','visResp_byCondition_shortWin','visResp_byCondition_longWin','cellDepth'};
% 
% mouse_list = arrayfun(@(x) nan,1:n_experiments,'un',0);
% date_list = arrayfun(@(x) nan,1:n_experiments,'un',0);
% group_data = arrayfun(@(x) [],1:n_experiments,'un',0);
% group_params = arrayfun(@(x) [],1:n_experiments,'un',0);
% 
% for i = 1:length(file_list)
%     file_i = file_list(i);
%     [exptStruct] = createExptStruct_tutorial(iexp);   
%     load([save_path,'\',exptStruct.date,'_',exptStruct.mouse,'_processedData.mat']);
% 
%     units.ID = [units.ID arrayfun(@(x) [num2str(x),',',exptStruct.mouse],1:size(params.visResp_byCondition_longWin,3),'un',0)];
%     units.recID = [units.recID repelem(i,size(params.visResp_byCondition_longWin,3))];
%     mouse_list{i} = {exptStruct.mouse};
%     group_data{i} = data;
%     params.cellDepth = params.cellDepth';
%     group_params{i} = params;
%     date_list{i} = exptStruct.mouse+"_"+exptStruct.date;
% 
% end
% 
% data = CatStructFields(3,cell2mat(group_data),'fieldnames',fieldsToKeep);
% params = CatStructFields([1,1,3,3,1],cell2mat(group_params),'fieldnames',paramsToKeep);
% 
% timeVector = group_data{1}.timeVector;
% 
% %% Parameters
% 
% all_contrasts = [0.1,0.2,0.4,0.8]; % in \\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\Behavior\Data\data-i3903-260213-1402
% all_sizes = [7.5,15,30,60,120];
% 
% smooth_window = 5; % Number of bins to smooth PSTHs for plotting
% cellDepths = params.cellDepth;
% depthLim = [800, 2500]; % insertion 2000 m, target = brain surface to 1200 m deep
% 
% cell_i = find((squeeze(any(params.visResp_byCondition_shortWin(:,:,1:3),[1 2]))')&(cellDepths>depthLim(1)&cellDepths<depthLim(2))');
% % Jenny: cell_i = find(((squeeze(any(params.visResp_byCondition_shortWin(:,1:3,:),[1 2]))'))&(cellDepths>depthLim(1)&cellDepths<depthLim(2))');
% 
% %% Plot avg PSTH over cell_i
% 
% tiledlayout(5,4);
% ax = [];
% figure; hold on;
% for con_i = 1:4
%     for size_i = 1:5
%         ax = [ax nexttile];
%         y_data = squeeze(smoothdata(data.psth_byConDiam_stat(con_i,size_i,cell_i,2:end-1),4,'gaussian',smooth_window));
%         fast_errbar(timeVector(2:end-1),y_data,1,'shaded',true);
%         fix_axes(gcf,10,'Time (s)','FR'); axis square;
%         title(all_sizes(size_i)); 
% 
%     end
% end
% linkaxes(ax);
% 
% %% Plot avg PSTH over cell_i high con
% 
% ax = [];
% figure; hold on;
% for size_i = 1:5
%     ax(size_i) = subplot(1,5,size_i);
%     y_data = squeeze(smoothdata(data.psth_byConDiam_stat(con_i,size_i,cell_i,2:end-1),4,'gaussian',5));
%     fast_errbar(timeVector(2:end-1),y_data,1,'shaded',true);
%     fix_axes(gcf,10,'Time (s)','FR'); axis square;
%     title(all_sizes(size_i)); 
% end
% linkaxes(ax);
% 
% %% Plot distribution of cells along depth of the probe
% 
% for exp_i = 1:6
%     figure;
%     histogram(cellDepths(units.recID==exp_i),'BinWidth',100);
%     hold on;
%     vline([depthLim(1) depthLim(2)]);
%     fix_axes(gcf,10,'Depth','Count'); axis square; 
%     xlim([0 3000]);
%     title(date_list{exp_i});
% end
% 
% %% Plot peak (black) and mean (grey) FRs, normalized to peak 
% 
% figure;
% subplot(1,3,1); hold on;
% for con_i = 1:4
%     fast_errbar(all_sizes,data.peak_FR(con_i,:,cell_i)./max(data.peak_FR(:,:,cell_i),[],[1 2]),3,'color',[0.7 0.7 0.7]/con_i);
%     fast_errbar(all_sizes,data.avg_FR(con_i,:,cell_i)./max(data.avg_FR(:,:,cell_i),[],[1 2]),3,'color',[0.7 0.7 0.7]/con_i);
% end
% xticks(0:30:120); ylim([0 1]);
% fix_axes(gcf,10,'Diameter','Norm FR'); axis square;
% 
% subplot(1,3,2); hold on;
% fast_errbar(all_sizes,squeeze(data.peak_FR(end,:,cell_i)./max(data.peak_FR(:,:,cell_i),[],[1 2])),2,'stats',true);
% fast_errbar(all_sizes,squeeze(data.avg_FR(end,:,cell_i)./max(data.avg_FR(:,:,cell_i),[],[1 2])),2,'color',[0.7 0.7 0.7],'stats',true);
% xticks(0:30:120); ylim([0 1]);
% fix_axes(gcf,10,'Diameter','Norm FR');axis square;
% 
% %%
% figure;
% 
% subplot(1,4,1); hold on;
% fast_errbar(all_sizes,squeeze(data.rise_50(end,:,cell_i)),2,'stats',true,'continuous',false);
% ylim([0 0.15]);xticks(0:30:120);yticks(0:0.05:0.15);
% fix_axes(gcf,10,'Diameter','Rise Time (s)'); axis square;
% 
% subplot(1,4,2);hold on;
% fast_errbar(all_sizes,squeeze(data.fall_50(end,:,cell_i)),2,'stats',true,'continuous',false);
% ylim([0.05 0.2]);xticks(0:30:120);yticks(0.1:0.05:0.25);
% fix_axes(gcf,10,'Diameter','Fall Time (s)'); axis square;
% 
% subplot(1,4,3);hold on;
% fast_errbar(all_sizes,squeeze(data.FWHM(end,:,cell_i)),2,'stats',true,'continuous',false);
% ylim([0 0.15]);xticks(0:30:120);yticks(0:0.05:0.15);
% fix_axes(gcf,10,'Diameter','FWHM (s)'); axis square;
% 
% subplot(1,4,4);hold on;
% fast_errbar(all_sizes,squeeze(data.peak_time(end,:,cell_i)),2,'stats',true,'continuous',false);
% ylim([0 0.15]);xticks(0:30:120);yticks(0:0.05:0.15);
% fix_axes(gcf,10,'Diameter','Peak Time (s)'); axis square;
% 
% %%
% figure;
% subplot(1,3,1); hold on;
% fast_errbar(all_sizes,squeeze(data.rise_20_80(end,:,cell_i)),2,'stats',true,'continuous',false);
% ylim([0 0.15]);xticks(0:30:120);yticks(0:0.05:0.15);
% fix_axes(gcf,10,'Diameter','20-80 Rise (s)'); axis square;
% 
% subplot(1,3,2);hold on;
% fast_errbar(all_sizes,squeeze(data.fall_80_20(end,:,cell_i)),2,'stats',true,'continuous',false);
% ylim([0 0.15]);xticks(0:30:120);yticks(0:0.05:0.15);
% fix_axes(gcf,10,'Diameter','80-20 Fall (s)'); axis square;
% 
% %%
% figure;
% for con_i = 1:4
%     subplot(1,3,1); hold on;
%     fast_errbar(all_sizes,data.rise_50(con_i,:,cell_i),3,'color',[0.8 0.8 0.8]/con_i);
%     ylim([0 0.15]);xticks(0:30:120);yticks(0:0.05:0.15);
%     fix_axes(gcf,10,'Diameter','Rise Time (s)'); axis square;
% 
%     subplot(1,3,2);hold on;
%     fast_errbar(all_sizes,data.fall_50(con_i,:,cell_i),3,'color',[0.8 0.8 0.8]/con_i);
%     ylim([0.1 0.25]);xticks(0:30:120);yticks(0.1:0.05:0.25);
%     fix_axes(gcf,10,'Diameter','Fall Time (s)'); axis square;
% 
%     subplot(1,3,3);hold on;
%     fast_errbar(all_sizes,data.FWHM(con_i,:,cell_i),3,'color',[0.8 0.8 0.8]/con_i);
%     ylim([0 0.15]);xticks(0:30:120);yticks(0:0.05:0.15);
%     fix_axes(gcf,10,'Diameter','FWHM (s)'); axis square;
% end
% 
% figure;
% for con_i = 1:4
%     subplot(1,3,1);hold on;
%     fast_errbar(all_sizes,data.rise_20_80(con_i,:,cell_i),3,'color',[0.8 0.8 0.8]/con_i);
%     ylim([0 0.15]);xticks(0:30:120);yticks(0:0.05:0.15);
%     fix_axes(gcf,10,'Diameter','20-80 Rise (s)'); axis square;
% 
%     subplot(1,3,2);hold on;
%     fast_errbar(all_sizes,data.fall_80_20(con_i,:,cell_i),3,'color',[0.8 0.8 0.8]/con_i);
%     ylim([0 0.15]);xticks(0:30:120);yticks(0:0.05:0.15);
%     fix_axes(gcf,10,'Diameter','20-80 Rise (s)'); axis square;
% end
