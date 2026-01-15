close all; clear all; clc;
base = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara';
doPlot = 1;
ds = 'NP_ISN_ConSize_exptlist';
eval(ds)
rc = behavConstsAV;
sampRate = 30000;
nexp = size(expt,2);
%max_dist = 10;

mouse_list = [];

depth_all = [];
channel_all = [];

ind_sigRF_all = [];
totalSpikesUsed_all = [];
avgImgs_all = [];
avgImgZscore_all = [];
avgImgZscoreThresh_all = [];
cells_sigRFbyTime_On_all = [];
cells_sigRFbyTime_Off_all = [];
localConMap_data_all = [];
localConMap_map_all = [];
bestTimePoint_all = [];

gaussianFitOn_all = [];
gaussianFitOff_all = [];

popAz       = [];
popAzstd    = [];
popAzsem    = [];
popEl       = [];
popElsem    = [];
popElstd    = [];


% LGN -- 4 5 6 9 12 13 15 

expts = [4 5 6 9 12 13 15];

start=1;
for iexp = expts    
    mouse = expt(iexp).mouse;
    mouse_list = strvcat(mouse_list, mouse);
    date = expt(iexp).date;
        
    load(fullfile(base, 'Analysis\Neuropixel', date, [date '_' mouse '_unitStructs.mat']))
    load(fullfile(base, 'Analysis\Neuropixel', date, [mouse '-' date '_spatialRFs.mat']))

    fprintf([mouse ' ' date '\n'])

    ind_sigRF_all               = [ind_sigRF_all; ind_sigRF];
    cells_sigRFbyTime_On_all    = [cells_sigRFbyTime_On_all; cells_sigRFbyTime_On];
    cells_sigRFbyTime_Off_all   = [cells_sigRFbyTime_Off_all; cells_sigRFbyTime_Off];
    totalSpikesUsed_all         = [totalSpikesUsed_all, totalSpikesUsed];
    avgImgs_all                 = [avgImgs_all; averageImagesAll];
    avgImgZscore_all            = [avgImgZscore_all; averageImageZscore];
    avgImgZscoreThresh_all      = [avgImgZscoreThresh_all; averageImageZscoreThresh];
    localConMap_data_all        = [localConMap_data_all; localConMap_data];
    localConMap_map_all         = [localConMap_map_all; localConMap_map];
    bestTimePoint_all           = [bestTimePoint_all; bestTimePoint];
    gaussianFitOn_all           = [gaussianFitOn_all; gStructOn_all];
    gaussianFitOff_all          = [gaussianFitOff_all; gStructOff_all];


    nCells = size(gStructOn_all,1);
    indRF = find(ind_sigRF>0);
    for ic = 1:nCells
        for it = 2:4
            data    = squeeze(localConMap_data(ic,it,:,:));
            on      = gStructOn_all{ic,it};
            off     = gStructOff_all{ic,it};
            hasOn   = ~isempty(on);
            hasOff  = ~isempty(off);
            if ~hasOn && ~hasOff
                rsq = 0;
                El_center       = NaN;
                Az_center       = NaN;
            elseif hasOn && ~hasOff
                fit             = on.k2b_plot;
                rsq             = getRsqLinearRegress_SG(data, fit);
                El_center       = on.x(4);
                Az_center       = on.x(5);
            elseif ~hasOn && hasOff
                fit             = off.k2b_plot;
                rsq             = getRsqLinearRegress_SG(data, fit);
                El_center       = off.x(4);
                Az_center       = off.x(5);
            elseif hasOn && hasOff
                fitOn           = on.k2b_plot;
                fitOff          = off.k2b_plot;
                rsqOn           = getRsqLinearRegress_SG(data, fitOn);
                rsqOff          = getRsqLinearRegress_SG(data, fitOff);
                rsq             = rsqOn+rsqOff;
                El_centerOn     = on.x(4);
                Az_centerOn     = on.x(5);
                El_centerOff    = off.x(4);
                Az_centerOff    = off.x(5);
                Az_center       = (Az_centerOn+Az_centerOff)/2;
                El_center       = (El_centerOn+El_centerOff)/2;
            end
            gaussfit_rsq(ic,it) = rsq;
            gaussfit_az(ic,it) = Az_center;
            gaussfit_el(ic,it) = El_center;
            clear rsq
        end
    end
    
    [maxRsq maxIdx] = max(gaussfit_rsq,[],2);
    indGoodFit      = find(maxRsq>0.1);
    indGoodFit      = intersect(indGoodFit, indRF);
    indGoodFit_all{start} = indGoodFit;
    
    rowIdx  = (1:nCells)';
    linIdx  = sub2ind(size(gaussfit_az), rowIdx, maxIdx);
    azs     = gaussfit_az(linIdx);
    els     = gaussfit_el(linIdx);
    
    centerAz        = mean(azs(indGoodFit));
    centerAz_std    = std(azs(indGoodFit));
    centerAz_sem    = std(azs(indGoodFit))/length(indGoodFit);
    centerEl        = mean(els(indGoodFit));
    centerEl_std    = std(els(indGoodFit));
    centerEl_sem    = std(els(indGoodFit))/length(indGoodFit);

    popAz       = [popAz; centerAz];
    popAzstd    = [popAzstd; centerAz_std];
    popAzsem    = [popAzsem; centerAz_sem];
    popEl       = [popEl; centerEl];
    popElstd    = [popElstd; centerEl_std];
    popElsem    = [popElsem; centerEl_sem];

    clear rowIdx linIdx gaussfit_az gaussfit_el gaussfit_rsq
start=start+1;
end


mouse_labels = cellstr(mouse_list);   % convert char array → cell array

figure; movegui('center')
h1 = gobjects(6,1);   % handles for subplot 1
h2 = gobjects(6,1);   % handles for subplot 2

for iexpt = 1:7
    subplot 211
        h1(iexpt) = scatter(popAz(iexpt)*2,popEl(iexpt)*2);
        hold on
        ylim([0 29*2])
        xlim([0 52*2])
        errorbar(popAz(iexpt)*2,popEl(iexpt)*2,popAzsem(iexpt)*2,'Color',[.7 .7 .7],"LineStyle","none")
        errorbar(popAz(iexpt)*2,popEl(iexpt)*2,popElsem(iexpt)*2,"horizontal",'Color',[.7 .7 .7],"LineStyle","none")
        set(gca,'TickDir','out'); box off;  grid off
        subtitle('standard err of mean')
    subplot 212
        h2(iexpt) = scatter(popAz(iexpt)*2,popEl(iexpt)*2);
        hold on
        ylim([0 29*2])
        xlim([0 52*2])
        errorbar(popAz(iexpt)*2,popEl(iexpt)*2,popAzstd(iexpt)*2,'Color',[.7 .7 .7],"LineStyle","none")
        errorbar(popAz(iexpt)*2,popEl(iexpt)*2,popElstd(iexpt)*2,"horizontal",'Color',[.7 .7 .7],"LineStyle","none")
        set(gca,'TickDir','out'); box off;  grid off
        subtitle('standard dev')
end

subplot(2,1,1)
legend(h1, mouse_labels, 'Location','best')

subplot(2,1,2)
legend(h2, mouse_labels, 'Location','best')




%% per expt

corrPopAz = popEl;
corrPopEl = popAz;
corrPopAzstd = popAzstd;
corrPopElstd = popElstd;

stimEl(1) = 15;
stimAz(1) = -15;
stimEl(2) = 10;
stimAz(2) = 0;
stimEl(3) = -5;
stimAz(3) = 20;
stimEl(4) = 0;
stimAz(4) = -20;
stimEl(5) = 0;
stimAz(5) = -7;
stimEl(6) = 0;
stimAz(6) = 0;
stimEl(7) = -5;
stimAz(7) = -25;

D  = 7.5;   % diameter
r = D/2;

for iexpt = 1:7
    mouse = mouse_list(iexpt,:);
    nCells = length(indGoodFit_all{iexpt});

    % d = hypot((corrPopAz(iexpt)*2) - (stimAz(iexpt)+52), (corrPopEl(iexpt)*2) - (stimEl(iexpt)+29));
    d = abs((corrPopAz(iexpt)*2) - (stimAz(iexpt)+52));

    figure; movegui('center')
    subplot 211
        h2(iexpt) = scatter(corrPopAz(iexpt)*2,corrPopEl(iexpt)*2);
        hold on
        ylim([0 29*2])
        xlim([0 52*2])
        errorbar(corrPopAz(iexpt)*2,corrPopEl(iexpt)*2,corrPopAzstd(iexpt)*2,'Color',[.7 .7 .7],"LineStyle","none")
        errorbar(corrPopAz(iexpt)*2,corrPopEl(iexpt)*2,corrPopElstd(iexpt)*2,"horizontal",'Color',[.7 .7 .7],"LineStyle","none")
        set(gca,'TickDir','out'); box off;  grid off
        sgtitle([mouse ', ' num2str(nCells) ' cells, ' num2str(round(d,1)) ' deg diff'])
        subtitle('st dev')

        rectangle('Position',[(stimAz(iexpt)+52)-r, (stimEl(iexpt)+29)-r, D, D], ...
          'Curvature',[1 1], ...
          'EdgeColor','k', ...
          'LineWidth',1.5);
end





