% For plotting STAs for a given experiment.
% Requires running getSpatialRF_Wiesel first


function getSpatialRFHubel_JerryISN(iexp)

% Load data
    baseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
    [exptStruct] = iniExptStruct(iexp); % Load relevant times and directories for this experiment

    fPathBaseIn = fullfile(baseDir, '\jerry\analysis\neuropixel',exptStruct.mouse,exptStruct.date,'kilosort4');
    cd(fPathBaseIn);
    [cluster_struct,~,~,~,~,~,goodUnitStruct,~,~] = ImportKSdataNew();  % Marie's function to tidy up ks4 and phy2 outputs for further analysis


%% Run STA at multiple time points

    mouse = exptStruct.mouse;
    date = exptStruct.date;
    base = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
   

    % Load downsampled noise stimuli
    noiseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\noiseStimuli';
    load([noiseDir, '\5min_2deg_4rep_imageMatrix.mat'])

    xDim = size(imageMatrix,3);
    yDim = size(imageMatrix,4);


%% Load bootstrap shuffle

load(fullfile(base, 'sara', 'Analysis', 'Neuropixel', 'ISN_Jerry', [mouse '-' date '_spatialRFs_Wiesel.mat']))

nCells  = length(goodUnitStruct);
lastTimestamp = timestamps(end)+10; % Last timestamp plus 10 seconds

%% plot spatial RFs

if ~exist(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\ISN_Jerry\spatialRFs']), 'dir')
    mkdir(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\ISN_Jerry\spatialRFs']));
end


figure;
sp      = 1;   % subplot count
start   = 1;    % cell count
n       = 1;    % page count

for iCell = 1:nCells
    for it = 1:length(beforeSpike)
        timeBeforeSpike     = beforeSpike(it); % Look [40 ms, etc.] before the spike
        averageImageAtSpike = squeeze(averageImagesAll(iCell,it,:,:));

        subplot(8,5,sp)
            imagesc(averageImageAtSpike)
            %imagesc(avgImageSmooth)
            colormap('gray')
            if it == 1
               subtitle(['cell ' num2str(iCell) ',' num2str(totalSpikesUsed(iCell)) ', -' num2str(timeBeforeSpike) ' s'])
            else
                subtitle(['-' num2str(timeBeforeSpike) ' s'])
            end
            sp=sp+1;
    end
    start=start+1;
    if start > 8
         sgtitle(['noise trials = ' num2str(size(timestamps,1))])
         print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\ISN_Jerry\spatialRFs'], [mouse '-' date '_spatialRFs_cell' num2str(iCell-7) 'to' num2str(iCell) '.pdf']),'-dpdf', '-fillpage')       
         figure;
         movegui('center')
         start   = 1;
         n       = n+1;
         sp      = 1;
         close all
     end
     if iCell == nCells
         sgtitle(['noise trials = ' num2str(size(timestamps,1))])
         print(fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\ISN_Jerry\spatialRFs'], [mouse '-' date '_spatialRFs_untilcell' num2str(iCell) '.pdf']), '-dpdf','-fillpage')
         close all
     end   
end




%% Generate zscore image, threshold

% Set zThreshold
zthreshold = 2.5;

% Subtract the mean white noise stimulus, because it is nonzero
wnMean          = mean(mean(imageMatrix,1),2);
wnMeanAvg       = mean(wnMean(:));
wnMeanDiffMat   = wnMean-wnMeanAvg;

averageImagesAll_shuffledMinusMean  = averageImagesAll_shuffled - reshape(reshape(reshape(wnMeanDiffMat,[],xDim,yDim),[],1,xDim,yDim),[],1,1,xDim,yDim);
averageImagesAll_MinusMean          = averageImagesAll - reshape(reshape(wnMeanDiffMat,[],xDim,yDim),[],1,xDim,yDim);

shuffledMean    = squeeze(mean(averageImagesAll_shuffledMinusMean,1));
shuffledStd     = squeeze(std(averageImagesAll_shuffledMinusMean,0,1));

averageImageZscore = (averageImagesAll_MinusMean-shuffledMean)./shuffledStd;   % z-score: subtract mean from the raw value and then divide all by standard deviation

averageImageZscoreThresh = [];
for iCell = 1:nCells
    for it = 1:length(beforeSpike)
        for ix = 1:xDim
            for iy = 1:yDim
               if averageImageZscore(iCell,it,ix,iy) > zthreshold
                   averageImageZscoreThresh(iCell,it,ix,iy) = 1;
               elseif averageImageZscore(iCell,it,ix,iy) < -zthreshold
                   averageImageZscoreThresh(iCell,it,ix,iy) = -1;
               else
                   averageImageZscoreThresh(iCell,it,ix,iy) = 0;
               end
            end
        end
    end
end

% Smooth image
sigma           = 2; % Standard deviation for smoothing (adjust if needed)
avgImageZscoreSmooth  = imgaussfilt(averageImageZscore, sigma);  % 2D Gaussian smoothing; adjust the kernel size (final value, if needed)



%% find index of cells that have a cluster of 3 sig pixels within a 4 pixel square

nCells = size(goodUnitStruct,2);
cells_sigRFbyTime_On   = nan(nCells, length(beforeSpike));
cells_sigRFbyTime_Off   = nan(nCells, length(beforeSpike));

for iCell = 1:nCells
    for it = 1:(length(beforeSpike))
        threshMat = squeeze(averageImageZscoreThresh(iCell,it,:,:));
        foundOn = false;
        foundOff = false;
        for ix = 1:(xDim-2+1)
            for iy = 1:(yDim-2+1)
                patch       = threshMat(ix:ix+1, iy:iy+1);
                numPos = sum(patch(:) == 1);   % count 1s
                numNeg = sum(patch(:) == -1);   % count -1s
                if numPos >= 3
                    foundOn = true;
                end
                if numNeg >= 3
                    foundOff = true;
                end
            end
            if foundOn & foundOff
                break; % Exit ix for loop early
            end
        end
        cells_sigRFbyTime_On(iCell,it)  = foundOn;   % 1 if found, 0 otherwise
        cells_sigRFbyTime_Off(iCell,it) = foundOff;   % 1 if found, 0 otherwise
    end 
end

sigRF_timepoints = cells_sigRFbyTime_On+cells_sigRFbyTime_Off;

ind_sigRF = sum(cells_sigRFbyTime_On,2)+sum(cells_sigRFbyTime_Off,2);


ind_RF = find(ind_sigRF>0);
MUA_avgSTA = squeeze(mean(abs(squeeze(averageImageZscore(ind_RF,4,:,:))),1));
MUA_maxSTA = squeeze(max(abs(squeeze(averageImageZscore(ind_RF,4,:,:))),[],1));
MUA_sumSTA = squeeze(max(sum(squeeze(averageImageZscore(ind_RF,4,:,:))),1));
figure;movegui('center')
    subplot 321
        imagesc(MUA_avgSTA); set(gca,'CLim',[0 2])
        subtitle(['avg zscore of cells w RF, n=' num2str(length(ind_RF))]); set(gca,'CLim',[0 2])
    subplot 322
        imagesc(imgaussfilt(MUA_avgSTA,1)); colormap('parula'); set(gca,'CLim',[0 2])
        subtitle('imguassfilt, sigma 1')
    subplot 323
        imagesc(medfilt2(MUA_avgSTA)); colormap('parula'); set(gca,'CLim',[0 2])
        subtitle('median filter')
   subplot 324
        imagesc(medfilt2(MUA_maxSTA)); colormap('parula'); set(gca,'CLim',[0 11]); colorbar
        subtitle('max STA, median filter')
  subplot 325
        imagesc(medfilt2(MUA_sumSTA)); colormap('parula'); set(gca,'CLim',[0 13]); colorbar
        subtitle('sum STA, median filter')
    sgtitle('clim [0 2]')
    print( ...
            fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\ISN_Jerry\spatialRFs'], ...
            [mouse '-' date '_RFs_populationMUA_HeatMap.pdf']), ...
            '-dpdf')



%% Plot cell zscore image, threshold, and result of 4x4 pixel test

figure;
sp      = 1;   % subplot count
start   = 1;    % cell count
n       = 1;    % page count

for iCell = 1:nCells
    for ii = 1:2
        for it = 1:length(beforeSpike)
            timeBeforeSpike = beforeSpike(it);
            if ii == 1
                imageToPlot = squeeze(averageImageZscore(iCell,it,:,:));
            elseif ii == 2
                imageToPlot = squeeze(averageImageZscoreThresh(iCell,it,:,:));
            end
            subplot(8,5,sp)
                imagesc(imageToPlot)
                colormap('gray')
                if ii == 1
                    clim([-10 10])
                    if it == 1 
                       subtitle(['cell ' num2str(iCell) ',' num2str(totalSpikesUsed(iCell)) ', -' num2str(timeBeforeSpike) ' s'])
                    else
                       subtitle(['-' num2str(timeBeforeSpike) ' s'])
                    end
                end
                sp=sp+1;
        end
        start=start+1;
    end
   if start > 8
        sgtitle('zcore image, clim ([-10 10])')
        print( ...
            fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\ISN_Jerry\spatialRFs'], ...
            [mouse '-' date '_RFs_ZscoreAverageAndThreshold_cell' num2str(iCell-3) 'to' num2str(iCell) '.pdf']), ...
            '-dpdf', '-fillpage')       
        figure;
        movegui('center')
        start   = 1;
        n       = n+1;
        sp      = 1;
        close all
    end
    if iCell == nCells
        sgtitle(['noise trials = ' num2str(size(timestamps,1))])
        print( ...
            fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\ISN_Jerry\spatialRFs'], ...
            [mouse '-' date '_RFs_ZscoreAverageAndThreshold_untilcell' num2str(iCell) '.pdf']), ...
            '-dpdf','-fillpage')
        close all
    end   
end


%% get list of cells with detected RF

listnc  = 1:nCells;
ind     = listnc(ind_sigRF>0);

%% Local contrast analysis to choose best beforeSpikeTimepoint  

for ic = 1:nCells
    con_beforeSpike = beforeSpike(2:4);
    % figure;
    % movegui('center')
    is=1;
        for it = [1 2 3 4 5]
            xtempz(:,:) = medfilt2(imgaussfilt(squeeze(averageImageZscore(ic,it,:,:)),1)); %3:27,12:36

            if isnan(xtempz(1,1))
                xtempz(:,:) = ones(size(xtempz,1),size(xtempz,2));
            end

            jtempz(:,:) = rangefilt(xtempz(:,:),ones(5));

            j = squeeze(jtempz(:,:));
            q(it) = prctile(j(:),95);

            if it ==5
                q(it) = 1;   % set 5th timepoint (0.01s) to 1 to make sure if there is a peak at 4th timepoint, it can be detected
            end

            localConMap_data(ic,it,:,:) = xtempz;
            localConMap_map(ic,it,:,:) = jtempz;
            is=is+3;        
        end
        i = pickPeak_rfCI(q);   % Pick peak in 0.95 CI, but if there are two peaks, take the second
        m = q(i);
        %[m,i] = max(q);
        bestTimePoint(ic,1) = i; % best time point
        bestTimePoint(ic,2) = m; % max q90 value

        data = medfilt2(imgaussfilt(squeeze(averageImageZscore(ic,i,:,:)),1));
        [az, el] = getRFcenter(data);
        azs(ic) = az;
        els(ic) = el;
        

        % sgtitle([num2str(ic) '- best STA, ' num2str(beforeSpike(i)) ' ms'])
    %     print( ...
    %         fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\' exptStruct.date '\spatialRFs'], ...
    %         [mouse '-' date '_RFs_testLocalContrastAnalysis_smooth_cell' num2str(ic) '.pdf']), ...
    %         '-dpdf', '-fillpage')
    % close all
    clear xtempz jtempz q m i
end

%% Plot nice version of RFs

FRs = [goodUnitStruct.FR];

% get all smoothed data into one matrix to find actual max/min to normalize
% intensity of STA across cells for plotting and comparing SNR of timepoints
for ic = 1:nCells
    for it = 1:5
        data_all(ic,it,:,:) = medfilt2(imgaussfilt(squeeze(averageImageZscore(ic,it,:,:)),1));
    end
end
maxSmth = max(max(max(max(abs(data_all)))));

% Print STA time point choices
pdfFile = fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\ISN_Jerry\spatialRFs\',[mouse '-' date '_timePoint_STAs.pdf']);
for ic = 1:nCells

    figure();

    it_Con = bestTimePoint(ic,1);
    % it_maskCon = bestTimePoint(ic,5);

    for it = 1:5
        data = squeeze(data_all(ic,it,:,:));
        [h, w] = size(data);

        subplot(1,5,it)
            % plot RF
            imagesc(data); hold on
            pbaspect([16 9 1])
            colormap(gray)
            clim([-ceil(maxSmth) ceil(maxSmth)])
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])

            % add box if passes 2x2 pixel test
            pixRFtest = sigRF_timepoints(ic,it);
            if pixRFtest > 0
                hold on
                [h, w] = size(data);
                rectangle('Position',[0.5 0.5 w h], ...
                          'EdgeColor','r', ... % red
                          'LineWidth',1);
                hold off
            end

            % Add chosen timepoint to the corner
            % "con" → bottom left
            if it == it_Con
                text(1, h, 'con', ...
                    'Color','w', ...
                    'FontSize',5, ...
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','bottom');
                x = els(ic);
                y = azs(ic);
            
                hold on
                scatter(x, y, 3, 'm', 'filled')
                hold off
            end
            % % "maskCon" → bottom right
            % if it == it_maskCon
            %     text(w, h, 'maskCon', ...
            %         'Color','w', ...
            %         'FontSize',5, ...
            %         'HorizontalAlignment','right', ...
            %         'VerticalAlignment','bottom');
            % end

            if it == 1
                subtitle(['cell ' num2str(ic) ', FR = ' num2str(round(FRs(ic),1)) ' Hz'])
            end
            if it == 5 
                subtitle([num2str(totalSpikesUsed(ic)) ' spikes'])
            end
            hold off
    end
    % Append current figure as a new page in the PDF
    
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);

    close(gcf)
end

%% testing -- delete later

% 
% for ic = 1:nCells
%     for it = 1:5
%         data = squeeze(localConMap_map(ic,it,:,:));
%         q(ic, it) = prctile(data(:),95);
%         if it == 5
%             q(ic, it) = 1;
%         end
%     end
% end
% 
% figure;
%     subplot 331
%         plot(1:5,q(63,:)); hold on     
%         idx = pickPeak(q(63,:));
%         subtitle(num2str(idx))
%     subplot 332
%         plot(1:5,q(71,:)); hold on    
%         idx = pickPeak(q(71,:));
%         subtitle(num2str(idx))
%     subplot 333
%         plot(1:5,q(72,:)); hold on    
%         idx = pickPeak(q(72,:));
%         subtitle(num2str(idx))
%     subplot 334
%         plot(1:5,q(73,:)); hold on     
%         idx = pickPeak(q(73,:));
%         subtitle(num2str(idx))
%     subplot 335
%         plot(1:5,q(53,:)); hold on     
%         idx = pickPeak(q(53,:));
%         subtitle(num2str(idx))
%     subplot 336
%         plot(1:5,q(48,:)); hold on     
%         idx = pickPeak(q(48,:));
%         subtitle(num2str(idx))



%% save

save( ...
    fullfile(['\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\sara\Analysis\Neuropixel\ISN_Jerry\spatialRFs\', ...
        [mouse '-' date '_spatialRFs.mat']]), ...
    'totalSpikesUsed', ...
    'averageImagesAll', ...
    'averageImagesAll_shuffled', ...
    'averageImageZscore', ...
    'averageImageZscoreThresh', ...
    'nboots', ...
    'zthreshold', ...
    'cells_sigRFbyTime_On', ...
    'cells_sigRFbyTime_Off', ...
    'ind_sigRF', ...
    'localConMap_data', ...
    'localConMap_map', ...
    'bestTimePoint', ...
    'azs', ...
    'els' ...
    );


end

