% 020326 Lumi Lee
% task 1: retinotopy/ 1 sec on, 1 sec off (~20mins) 
% task 2: actual experiment/ 0.1 sec on, 4.9 sec off (~50mins)

%% Task1 Retinotopic mapping analysis

clear all; close all; clc

addpath(genpath('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\repositories\EphysCode-Glickfeld-Hull'))
save_path = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\Analysis\Neuropixel';
baseDir   = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';

iexp_list = [2];   %  single(e.g.[2]) or combined([2,3])


%% Extract units from KS output & run step1_cleanData (run once per session)

cd('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\Lumi\Analysis\ISN_2025');

for iexp = iexp_list
    [exptStruct] = createExptStruct_tutorial(iexp);

    load(fullfile(baseDir, 'Lumi\Analysis\Neuropixel', exptStruct.date, ...
        [exptStruct.date '_' exptStruct.mouse '_unitStructs.mat']), ...
        'allUnitStruct', 'goodUnitStruct');

   
    stimStruct = createStimStruct_retinotopy(exptStruct);


    unitStruct1 = goodUnitStruct;
  
    fprintf('Processed: %s %s\n', exptStruct.date, exptStruct.mouse);
    

end

depthMin = 800;  % um
depthMax = 2000;  % um

unitMask = [unitStruct1.depth] >= depthMin & [unitStruct1.depth] <= depthMax;
unitStruct = unitStruct1(unitMask);



%%
mouse      = exptStruct.mouse;
mworks_date = exptStruct.date;
exptTime1  = exptStruct.retinotopyTime;   % task1(retinotopy) start time

bName_task1 = ['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\Behavior\Data\data-' ...
               mouse '-' mworks_date '-' exptTime1 '.mat'];
load(bName_task1);

stimAz = cellfun(@(x) double(x), input.tGratingAzimuthDeg);
stimEl = cellfun(@(x) double(x), input.tGratingElevationDeg);


%  Load task1 PD timestamps 
% stimBlocks{1} = task1 (577 trials)
cd(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\' ...
    exptStruct.loc '\Analysis\Neuropixel\' exptStruct.date])
stimOnTimestampsMW = table2array(readtable([exptStruct.date '_mworksStimOnSync.txt']));
stimOnTimestampsPD = table2array(readtable([exptStruct.date '_photodiodeSync.txt']));


%% Task1 / Task2 discrimination

% timestamps
diffs = diff(stimOnTimestampsPD);


threshold = 3; % seconds

bigGapIdx = find(diffs > threshold);

task2GapIdx = find(diffs > 5); % start, between task1 & task2
task2GapIdx_final=[];
task2GapIdx_final(1)=1;

if isempty(task2GapIdx)
    error("Can't find Task2.");
end

i=1;
while i<length(task2GapIdx)
    if task2GapIdx(i+1)-task2GapIdx(i) <2
        task2GapIdx_final(i)=task2GapIdx(i);
        task2GapIdx_final(i+1)=task2GapIdx(i+1);
        break;
    else
        i=i+1;
    end
end
task2GapIdx
task2GapIdx_final




% task1->task2 transfer moment
% (task2 1st on pulse = task2GapIdx(1)+1st timestamp)



splitIdx_1 = task2GapIdx_final(2); % task1 until this index
splitIdx_2 = task2GapIdx_final(3)  % task2 start from this index

stimOnTimestamps_task1 = stimOnTimestampsPD(2:splitIdx_1);
stimOnTimestamps_task2 = stimOnTimestampsPD(splitIdx_2:end);

fprintf('Task1: %d timestamps (%.2fsec ~ %.2fsec)\n', ...
    length(stimOnTimestamps_task1), ...
    stimOnTimestamps_task1(1), stimOnTimestamps_task1(end));

fprintf('Task2: %d timestamps (%.2fsec ~ %.2fsec)\n', ...
    length(stimOnTimestamps_task2), ...
    stimOnTimestamps_task2(1), stimOnTimestamps_task2(end));

%% Visualization
% figure;
% subplot(2,1,1);
% histogram(diffs(diffs < 2), 100);
% title('Task1 area gap distribution (< 2sec)');
% xlabel('Gap (sec)'); ylabel('Count');
% 
% subplot(2,1,2);
% plot(diffs, '.');
% hold on;
% xline(splitIdx, 'r--', 'LineWidth', 2, 'Label', 'Task1Task2');
% yline(4, 'g--', 'threshold=4s');
% title('Oveall diffs');
% xlabel('Index'); ylabel('Gap (sec)');


%% Extract Leading Edges (first timestamp of each stim-on burst)
% burst internal gap: ~0.002sec
% task1 on/off cycle: ~1sec  use 0.5sec as threshold
% task2 on/off cycle: ~5sec  same threshold works

burstGapThreshold = 0.5; % seconds

%% Task1 Leading Edges
diffs_task1 = diff(stimOnTimestamps_task1);
burstStartIdx_task1 = find(diffs_task1 > burstGapThreshold) +1;
burstStartIdx_task1 = [1; burstStartIdx_task1(:)]; % include first burst

leadingEdges_task1 = stimOnTimestamps_task1(burstStartIdx_task1);
leadingEdges_task1 = leadingEdges_task1(1:end);

fprintf('Task1: %d leading edges found\n', length(leadingEdges_task1));
fprintf('  First 5 edges: '); disp(leadingEdges_task1(1:min(5,end))')
fprintf('  Inter-burst intervals (expect ~2sec): '); disp(diff(leadingEdges_task1(1:min(6,end)))')

%% Task2 Leading Edges
diffs_task2 = diff(stimOnTimestamps_task2);
burstStartIdx_task2 = find(diffs_task2 > burstGapThreshold) + 1;
burstStartIdx_task2 = [1; burstStartIdx_task2(:)]; % include first burst

leadingEdges_task2 = stimOnTimestamps_task2(burstStartIdx_task2);
leadingEdges_task2 = leadingEdges_task2(3:end);

fprintf('Task2: %d leading edges found\n', length(leadingEdges_task2));
fprintf('  First 5 edges: '); disp(leadingEdges_task2(1:min(5,end))')
fprintf('  Inter-burst intervals (expect ~5sec): '); disp(diff(leadingEdges_task2(1:min(6,end)))')

%% Validation Plot
% figure;
% %subplot(2,1,1);
% plot(stimOnTimestamps_task1, ones(size(stimOnTimestamps_task1)), 'b.'); hold on;
% plot(leadingEdges_task1, ones(size(leadingEdges_task1))*1.1, 'rv', 'MarkerSize', 10);
% title('Task1: Stim-On Timestamps & Leading Edges');
% xlabel('Time (sec)');
% legend('all timestamps', 'leading edges');
% xlim([stimOnTimestamps_task1(1)-1, stimOnTimestamps_task1(1)+20]);
% 
% %subplot(2,1,2);
% figure;
% plot(stimOnTimestamps_task2, ones(size(stimOnTimestamps_task2)), 'b.'); hold on;
% plot(leadingEdges_task2, ones(size(leadingEdges_task2))*1.1, 'rv', 'MarkerSize', 10);
% title('Task2: Stim-On Timestamps & Leading Edges');
% xlabel('Time (sec)');
% legend('all timestamps', 'leading edges');
% xlim([leadingEdges_task2(1)-1, stimOnTimestamps_task2(1)+100]);


%% RETINOTOPY ANALYSIS (Task1) 

% --- Align trials ---
% stimStruct.timestamps: mworks-based stim on times
% leadingEdges_task1:    PD-based stim on times
% stimStruct.stimAzimuth / stimElevation: location per trial

nTrials = length(leadingEdges_task1)
trialEdges = leadingEdges_task1(1:nTrials)

trialAz = cellfun(@(x) double(x), stimStruct.stimAzimuth(1:nTrials));
trialEl = cellfun(@(x) double(x), stimStruct.stimElevation(1:nTrials));

all_az = unique(cellfun(@(x) double(x), stimStruct.stimAzimuth)) % [-25, -15, -5, 5, 15, 25];
all_el = unique(cellfun(@(x) double(x), stimStruct.stimElevation)) %[-25, -15, -5, 5, 15, 25];
nAz    = length(all_az);
nEl    = length(all_el);

fprintf('Aligned trials: %d\n', nTrials);
fprintf('Azimuth locations:   '); disp(all_az')
fprintf('Elevation locations: '); disp(all_el')

% --- PSTH parameters ---
preStim  = 0.1;  % sec before stim on  (baseline)
postStim = 0.9;  % sec after stim on   (response window)

% --- Compute mean firing rate per unit per location ---
nUnits = length(unitStruct);

% firingRateMap: nUnits x nEl x nAz
firingRateMap    = zeros(nUnits, nEl, nAz);
baselineRateMap  = zeros(nUnits, nEl, nAz);

for u = 1:nUnits
    unitSpikes = unitStruct(u).timestamps;  % spike times in sec

    for iAz = 1:nAz
        for iEl = 1:nEl
            trialIdx = find(trialAz == all_az(iAz) & trialEl == all_el(iEl));

            if isempty(trialIdx)
                continue;
            end

            spikeCounts    = zeros(length(trialIdx), 1);
            baselineCounts = zeros(length(trialIdx), 1);

            for t = 1:length(trialIdx)
                tOn = trialEdges(trialIdx(t));

                % Response window: [tOn, tOn + postStim]
                spikeCounts(t) = sum(unitSpikes >= tOn & ...
                                     unitSpikes <  tOn + postStim);

                % Baseline window: [tOn - preStim, tOn]
                baselineCounts(t) = sum(unitSpikes >= tOn - preStim & ...
                                        unitSpikes <  tOn);
            end

            firingRateMap(u, iEl, iAz)   = mean(spikeCounts)    / postStim;
            baselineRateMap(u, iEl, iAz) = mean(baselineCounts)  / preStim;
        end
    end

    fprintf('Unit %d/%d (ID:%d) done\n', u, nUnits, unitStruct(u).unitID);
end

% Response map: firing rate - baseline
responseMap = firingRateMap - baselineRateMap;




%%  3 POPULATION PLOTS 

stimDiameter_deg = 20; % degrees

%figure('Units','normalized','Position',[0.05 0.05 0.9 0.85]);
%sgtitle('Task1 Retinotopy Summary', 'FontSize', 16, 'FontWeight', 'bold');

%% --- Plot 1: Preferred Location Map (unit count per location) ---
%subplot(1,3,1);

% --- Preferred location per unit ---
prefAz = zeros(nUnits, 1);
prefEl = zeros(nUnits, 1);

for u = 1:nUnits
    map2D = squeeze(responseMap(u, :, :));  % nEl x nAz
    [maxEl_idx, maxAz_idx] = find(map2D == max(map2D(:)), 1);
    prefAz(u) = all_az(maxAz_idx);
    prefEl(u) = all_el(maxEl_idx);
end

prefCount = zeros(nEl, nAz);
for iEl = 1:nEl
    for iAz = 1:nAz
        prefCount(iEl, iAz) = sum(prefAz == all_az(iAz) & prefEl == all_el(iEl));
    end
end

hold on;
for iEl = 1:nEl
    for iAz = 1:nAz
        % Draw circle with diameter proportional to stim size
        theta  = linspace(0, 2*pi, 100);
        cx     = all_az(iAz);
        cy     = all_el(iEl);
        r      = stimDiameter_deg / 2;

        % Fill color by count
        nMax   = max(prefCount(:));
        cval   = prefCount(iEl, iAz) / max(nMax, 1);
        cmap   = parula(256);
        cidx   = max(1, round(cval * 255) + 1);
        fcolor = cmap(cidx, :);

        fill(cx + r*cos(theta), cy + r*sin(theta), fcolor, ...
            'FaceAlpha', 0.6, 'EdgeColor', [0.4 0.4 0.4], 'LineWidth', 0.8);

        % Count text
        if prefCount(iEl, iAz) > 0
            text(cx, cy, num2str(prefCount(iEl, iAz)), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment',   'middle', ...
                'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
        end
    end
end

axis equal; axis tight;
xlabel('Azimuth (deg)'); ylabel('Elevation (deg)');
title('Preferred Location (# Units)');
set(gca, 'XTick', all_az, 'YTick', all_el);
xlim([min(all_az)-15, max(all_az)+15]);
ylim([min(all_el)-15, max(all_el)+15]);
grid on; box on;

% Colorbar (manual)
colormap(gca, parula);
cb = colorbar;
ylabel(cb, '# Units');
clim([0 nMax]);


%% --- Plot 2: Population Average FR Heatmap ---
%subplot(1,3,2);

figure;
popAvgFR = squeeze(mean(responseMap, 1)); % nEl x nAz

hold on;
for iEl = 1:nEl
    for iAz = 1:nAz
        theta  = linspace(0, 2*pi, 100);
        cx     = all_az(iAz);
        cy     = all_el(iEl);
        r      = stimDiameter_deg / 2;


        frMin  = min(popAvgFR(:));
        frMax  = max(popAvgFR(:));
        cval   = (popAvgFR(iEl, iAz) - frMin) / max(frMax - frMin, 1e-6);
        cmap   = parula(256);
        cidx   = max(1, round(cval * 255) + 1);
        fcolor = cmap(cidx, :);

        fill(cx + r*cos(theta), cy + r*sin(theta), fcolor, ...
            'FaceAlpha', 0.65, 'EdgeColor', [0.4 0.4 0.4], 'LineWidth', 0.8);

        text(cx, cy, sprintf('%.1f', popAvgFR(iEl, iAz)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment',   'middle', ...
            'FontSize', 8, 'Color', 'w');
    end
end

axis equal; axis tight;
xlabel('Azimuth (deg)'); ylabel('Elevation (deg)');
title('Population Average FR (Hz)');
set(gca, 'XTick', all_az, 'YTick', all_el);
xlim([min(all_az)-15, max(all_az)+15]);
ylim([min(all_el)-15, max(all_el)+15]);
grid on; box on;
colormap(gca, parula);
cb2 = colorbar;
ylabel(cb2, 'FR - Baseline (Hz)');

%% --- Plot 3: Top 9 Individual Unit FR Maps ---
subplot(1,3,3);

% Rank units by max response across all locations
maxResp = zeros(nUnits, 1);
for u = 1:nUnits
    maxResp(u) = max(max(squeeze(responseMap(u,:,:))));
end
[~, sortedIdx] = sort(maxResp, 'descend');
top9idx = sortedIdx(1:min(9, nUnits));

% New figure for top 9 (3x3 grid)
figure('Units','normalized','Position',[0.05 0.05 0.7 0.85]);
sgtitle('Top 9 Units - Individual RF Maps (i3903)', 'FontSize', 14, 'FontWeight', 'bold');


for k = 1:length(top9idx)
    subplot(3, 3, k);
    u   = top9idx(k);
    map = squeeze(responseMap(u, :, :)); % nEl x nAz

    imagesc(all_az, all_el, map);
    axis xy; colorbar;
    colormap(gca, parula);
    title(sprintf('Unit %d | %.1f Hz | %d um from the brain top', ...
        unitStruct(u).unitID, maxResp(u), 2000-unitStruct(u).depth));
    xlabel('Az (deg)'); ylabel('El (deg)');
    set(gca, 'XTick', all_az, 'YTick', all_el);
end

%%
% % --- Preferred location per unit ---
% prefAz = zeros(nUnits, 1);
% prefEl = zeros(nUnits, 1);
% 
% for u = 1:nUnits
%     map2D = squeeze(responseMap(u, :, :));  % nEl x nAz
%     [maxEl_idx, maxAz_idx] = find(map2D == max(map2D(:)), 1);
%     prefAz(u) = all_az(maxAz_idx);
%     prefEl(u) = all_el(maxEl_idx);
% end
% 
% % --- Plot 1: Preferred location per unit ---
% figure;
% scatter(prefAz + randn(nUnits,1)*0.3, ...
%         prefEl + randn(nUnits,1)*0.3, ...
%         60, (1:nUnits)', 'filled');
% colormap(hsv(nUnits));
% colorbar('Ticks', 1:nUnits, 'TickLabels', ...
%          arrayfun(@(x) num2str(x), [unitStruct.unitID], 'UniformOutput', false));
% xlabel('Azimuth (deg)');
% ylabel('Elevation (deg)');
% title('Preferred Location per Unit (Task1 Retinotopy)');
% set(gca, 'XTick', all_az, 'YTick', all_el);
% grid on;
% 
% % --- Plot 2: Firing rate map per unit ---
% nCols = 6;
% nRows = ceil(nUnits / nCols);
% 
% figure('Name', 'Retinotopy Response Maps');
% for u = 1:nUnits
%     subplot(nRows, nCols, u);
%     imagesc(all_az, all_el, squeeze(responseMap(u, :, :)));
%     colorbar;
%     axis xy;
%     title(sprintf('Unit %d', unitStruct(u).unitID));
%     xlabel('Az'); ylabel('El');
% end
% sgtitle('Response (FR - Baseline, Hz) per Location - Task1');
% colormap(hot);
% 
% 
