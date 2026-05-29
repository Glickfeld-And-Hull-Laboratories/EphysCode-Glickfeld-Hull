close all; clearvars; clc;

%% debug mode one cell test
debugMode = false;
debugCell = 986;   % check indRFint
%rng(0,'twister');   % randomness fully reproducible

%% Load data 
% load file with data concatenated across experiments

resultsDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\';
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

save(fullfile([resultsDir, 'bestTimePoint.mat']), 'bestTimePoint_all')

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


figure;
is=1;
for ic = 1:size(STA_cropped,3)
    subplot(6,7,is)
        clim = max(abs(STA_cropped(:)));
        imagesc(STA_cropped(:,:,ic),[-clim clim])
        subtitle(num2str(ind_DS(ic)))
        axis image off
        axis square
        colormap gray
        hold on
    is=is+1;
end
print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\STAs_cropped.pdf', '-dpdf','-bestfit')


%% Run Gabor fit
options.visualize = 0;
options.parallel  = 1;
options.shape     = 'elliptical';
options.runs      = 48;

% copy format from the first example
modelRegistry = [
    
    struct( ...
        'name','Noncon DoG', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNonConcentricEllipticalDoG(STA,'unnormalized',20), ...
        'k',10)

    struct( ...
        'name','Custom Gabor', ...
        'type','standard', ...
        'fitFcn', @(STA) fitEllipGabor_fit_full(STA), ...
        'k',9)

    struct( ...
        'name','DoG x cos', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNoncDoGCosineRF_diff(STA), ...
        'k',12)

    struct( ...
        'name','DoG x cos mod', ...
        'type','standard', ...
        'fitFcn', @(STA) fitNoncDoGCosineRF_sigmaXY(STA), ...
        'k',12)
];

omitCells = [634];   % cell(s) with NaN

results = runRFModelComparison( ...
    indLoop, ind_DS, STA_cropped, ...
    modelRegistry, omitCells, 'pdf', 'RF_DoGxcos.pdf', ...
    {'DoG x cos','Custom Gabor'}, {'DoG x cos','Custom Gabor'});
figure(1)
    axis square; set(gca,'TickDir','out')
    resultsDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\';
    print(fullfile([resultsDir, 'randDirFourPhase_CrossOri_mouseEphys_RsqModelComp.pdf']),'-dpdf'); %gabor
figure(2)
    axis square; set(gca,'TickDir','out') 
    print(fullfile([resultsDir, 'randDirFourPhase_CrossOri_mouseEphys_AICModelComp.pdf']),'-dpdf');  %gabor

stop

results = runRFModelComparison( ...
    indLoop, ind_DS, STA_cropped, ...
    modelRegistry, omitCells, 'pdf', 'RF_DoGxcos.pdf', ...
    {'Noncon DoG', 'DoG x cos'}, {'Noncon DoG', 'DoG x cos'});
figure(1)
    axis square; set(gca,'TickDir','out')
    resultsDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\';
    print(fullfile([resultsDir, 'randDirFourPhase_CrossOri_mouseEphys_RsqModelComp_NonconDoG.pdf']),'-dpdf');
figure(2)
    axis square; set(gca,'TickDir','out')
    print(fullfile([resultsDir, 'randDirFourPhase_CrossOri_mouseEphys_AICModelComp_NonConDoG.pdf']),'-dpdf');
%% Ranking
modelIdx = find(strcmp({modelRegistry.name}, 'Custom Gabor')); %DoG x cos

paramList = {'orientation','frequency','elongation','size'};
%paramList = {'orientation','frequency','elongation','size'};


for p = 1:length(paramList)

    rankRFsByParameter( ...
        results.models{modelIdx}, ...
        results.params{modelIdx}, ...
        results.cellIDs, ...
        sprintf('results/Rank_%s_%s.pdf', ...
            modelRegistry(modelIdx).name, paramList{p}), ...
        sprintf('%s - %s Ranking', ...
            modelRegistry(modelIdx).name, paramList{p}), ...
        'standard', ...
        paramList{p}, ...
        'sg' ...
        );
end


%% Load .mat files of tuning

load(fullfile([resultsDir, 'RFparams_orientation.mat']))
    valOrientationID = paramResults.cellIDs;  
    valOrientation = paramResults.values;
load(fullfile([resultsDir, 'RFparams_frequency.mat']))
    valFrequencyID = paramResults.cellIDs;  
    valFrequency = paramResults.values;
load(fullfile([resultsDir, 'RFparams_elongation.mat']))
    valElongationID = paramResults.cellIDs;  
    valElongation = paramResults.values;      
load(fullfile([resultsDir, 'RFparams_size.mat']))
    valSizeID = paramResults.cellIDs;  
    valSize = paramResults.values;      



%% for CSHL 2026 poster


paramArray = results.params{modelIdx};

freq = squeeze(params(1,:));
IDs =  results.cellIDs;
rsq = results.R2{modelIdx};

clear As cycles effectiveSigma delts params ylim
figure;
movegui('center')
s=1;
for ic = [135 470 250 68 232 133 230 986]
    ind = find(IDs==ic);
    fprintf(['Cell ' num2str(ic) ',rsq= ' num2str(rsq(ind)) '\n'])
    params = paramArray{ind};
    As = params(2);
    delts = params(4);
    Ac = params(1);
    cycles = params(9);
    effectiveSigma = params(3) / sqrt(params(5));
    subplot(7,8,s)
        scatter(1, cycles)
        set(gca,'TickDir','out')
        ylim([0 0.1])
        ylabel('f, raw')
        subtitle(num2str(ic))
    subplot(7,8,s+8)
        scatter(1, abs(As),'r')
        set(gca,'TickDir','out')
        ylim([0 10])
        ylabel('As')
    s=s+1;
end
s=1;
for ic = [468 622 375]
    ind = find(IDs==ic);
    fprintf(['Cell ' num2str(ic) ',rsq= ' num2str(rsq(ind)) '\n'])
    params = paramArray{ind};
    As = params(2);
    delts = params(4);
    Ac = params(1);
    cycles = params(9);
    effectiveSigma = params(3) / sqrt(params(5));
    subplot(7,8,s+16)
        scatter(1, cycles)
        set(gca,'TickDir','out')
        ylim([0 0.1])
        ylabel('f, raw')
        subtitle(num2str(ic))
    subplot(7,8,s+24)
        scatter(1, abs(As),'r')
        set(gca,'TickDir','out')
        ylim([0 10])
        ylabel('As')
    s=s+1;
end

print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\stats_forExampleCells.pdf', '-dpdf','-bestfit')




for ic = 1:40
    params = paramArray{ic};
    As(ic) = params(2);
    cycles(ic) = params(9);
end

figure;
scatter(abs(As), cycles)
xlabel('As')
ylabel('f')

for ic = 1:40
    params = paramArray{ic};
    As(ic) = params(2);
    delts(ic) = params(4);
    Ac(ic) = params(1);
    cycles(ic) = params(9);
    effectiveSigma(ic) = params(3) / sqrt(params(5));
end

figure;
for ic = 1:size(STA_cropped,3)
    subplot(6,7,ic)
        clim = max(abs(STA_cropped(:)));
        imagesc(STA_cropped(:,:,ic),[-clim clim])
        subtitle(['f ' num2str(round(cycles(ic),2)) ', As ' num2str(abs(round(As(ic),1))) ])
        axis image off
        axis square
        colormap gray
        hold on
end
print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\STAs_cropped_withStats.pdf', '-dpdf','-bestfit')



        
figure;
    ax = axes;
    
    As_abs = abs(As);
    
    scatter(As_abs, cycles, 10, 'k') % optional reference points
    xlabel('|As|')
    ylabel('f')
    hold on
    
    axpos = ax.Position;   % position of main axes in figure
    
    for ic = 1:length(As_abs)
    
        % normalize data within axes limits
        xn = (As_abs(ic) - ax.XLim(1)) / diff(ax.XLim);
        yn = (cycles(ic) - ax.YLim(1)) / diff(ax.YLim);
    
        % convert to figure coordinates
        xf = axpos(1) + xn * axpos(3);
        yf = axpos(2) + yn * axpos(4);
    
        w = 0.03;
        h = 0.03;
    
        ax2 = axes('Position',[xf-w/2 yf-h/2 w h]);
    
        clim = max(abs(STA_cropped(:)));
        imagesc(STA_cropped(:,:,ic),[-clim clim])
        axis image off
        colormap gray
    end





save(fullfile( '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\', 'results', 'RFparams_raw.mat'), 'As', 'cycles');




%% for dept talk 2026
modelIdx = find(strcmp({modelRegistry.name}, 'DoG x cos')); 
RFs_cont = results.models{modelIdx};
rsq_cont = results.R2{modelIdx};

modelIdx = find(strcmp({modelRegistry.name}, 'Custom Gabor')); %DoG x cos
RFs_gabor = results.models{modelIdx};
rsq_gabor = results.R2{modelIdx};

modelIdx = find(strcmp({modelRegistry.name}, 'Noncon DoG')); %DoG x cos
RFs_NCdog = results.models{modelIdx};
rsq_NCdog = results.R2{modelIdx};

figure;
is=1;
for ic = 1:size(STA_cropped,3)
    subplot(6,7,is)
        clim = max(max(abs(cell2mat(RFs_gabor))));
        imagesc(RFs_gabor{ic}, [-clim clim])
        subtitle(num2str(results.cellIDs(ic)))
        axis image off
        axis square
        colormap gray
        hold on
    is=is+1;
end
print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\traditionalGabor_fits.pdf', '-dpdf','-bestfit')
%print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\nonConEllipDoG_fits.pdf', '-dpdf','-bestfit')


myList = [135 470 250 68 232 133 230 986 468 622 375];

[tf, loc] = ismember(myList, results.cellIDs);

cellsPlotting = loc(tf);

rsq_gabor(cellsPlotting)
rsq_NCdog(cellsPlotting)




% boxplot w scatter of Rsq

labels = {'DoG x cos','Custom Gabor','Noncon DoG'};

% Assign numeric group indices manually
gidx = [ ...
    ones(length(rsq_cont),1); ...
    2*ones(length(rsq_gabor),1); ...
    3*ones(length(rsq_NCdog),1)];

rsq_all = [rsq_cont(:); rsq_gabor(:); rsq_NCdog(:)];


figure; hold on
    subplot 221
        % Boxplot with fixed positions
        boxplot(rsq_all, gidx, 'Positions',[1 2 3], 'Labels', labels, 'Symbol','')
        
        % Jittered scatter (NOW aligned correctly)
        x_jitter = gidx + (rand(size(gidx)) - 0.5)*0.25;
        colors = [ ...
            0 0.45 0.74;   % blue (DoG x cos)
            0.5 0.5 0.5;   % gray (Custom Gabor)
            0.5 0.5 0.5];  % gray (Noncon DoG)
        
        hold on
        for i = 1:3
            idx = gidx == i;
            x_jitter = i + (rand(sum(idx),1) - 0.5)*0.25;
            
            scatter(x_jitter, rsq_all(idx), 20, ...
                'MarkerFaceColor', colors(i,:), ...
                'MarkerEdgeColor', 'none', ...
                'MarkerFaceAlpha', 0.6)
        end
        
        ylabel('R^2')
        set(gca,'TickDir','out')
        box off
        yticks(0:0.1:1)
print('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_Staff\home\sara\Analysis\Neuropixel\CrossOri\randDirFourPhase\mouse_RFs\results\rsq_comparisons.pdf', '-dpdf','-bestfit')

