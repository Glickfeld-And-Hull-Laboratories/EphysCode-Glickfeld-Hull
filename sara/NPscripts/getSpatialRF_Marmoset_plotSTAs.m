%% Compute STAs for marmoset data
% Script 1 of 2:
%     getSpatialRF_Marmoset_computeSTAs
%     getSpatialRF_Marmoset_plotSTAs

%% 
clear all; clc; close all

runloc = 1;   % Where is this script being run? 1 == Hubel, 2 == Wiesel


%%
if runloc == 1    % Hubel
    dirBase = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home';
elseif runloc == 2    % Wiesel
    dirBase = 'home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home';
else
    error('Location not valid. 1 == Hubel, 2 == Wiesel.')
end

%%

res = 'LR';
load(fullfile(dirBase, 'sara', 'Analysis', 'Neuropixel', 'marmosetFromNicholas', 'spatialRFs', ['elf1_spatialRFs_Wiesel_' res '.mat']))

    % ==== vv DELETE THIS IF USING ALL CELLS vv ====
    averageImagesAll_original = averageImagesAll;
    averageImagesAll_shuffled_original = averageImagesAll_shuffled;
    
    averageImagesAll            = averageImagesAll(1:179,:,:,:);
    averageImagesAllLR          = averageImagesAll;
    averageImagesAll_shuffled   = averageImagesAll_shuffled(:,1:179,:,:,:);
    % ==== ^^ DELETE THIS IF USING ALL CELLS ^^ ====

    nTrials             = size(imageMatrix,1);
    nFramesPerTrials    = size(imageMatrix,2);
    nSizeStimSide       = size(imageMatrix,3);
    
    % Subtract the mean white noise stimulus, because it is nonzero
    wnMean          = mean(mean(imageMatrix,1),2);
    wnMeanAvg       = mean(wnMean(:));
    wnMeanDiffMat   = wnMean-wnMeanAvg;
    
    averageImagesAll_shuffledMinusMean  = averageImagesAll_shuffled - reshape(reshape(reshape(wnMeanDiffMat,[],nSizeStimSide,nSizeStimSide),[],1,nSizeStimSide,nSizeStimSide),[],1,1,nSizeStimSide,nSizeStimSide);
    averageImagesAll_MinusMean          = averageImagesAll - reshape(reshape(wnMeanDiffMat,[],nSizeStimSide,nSizeStimSide),[],1,nSizeStimSide,nSizeStimSide);
    
    shuffledMean    = squeeze(mean(averageImagesAll_shuffledMinusMean,1));
    shuffledStd     = squeeze(std(averageImagesAll_shuffledMinusMean,0,1));
    
    averageImageZscoreLR = (averageImagesAll_MinusMean-shuffledMean)./shuffledStd;   % z-score: subtract mean from the raw value and then divide all by standard deviation

    clear averageImagesAll averageImagesAll_shuffled averageImagesAll_MinusMean shuffledMean shuffledStd


res = 'HR';
load(fullfile(dirBase, 'sara', 'Analysis', 'Neuropixel', 'marmosetFromNicholas', 'spatialRFs', ['elf1_spatialRFs_Wiesel_' res '.mat']))

    % ==== vv DELETE THIS IF USING ALL CELLS vv ====
    averageImagesAll_original = averageImagesAll;
    averageImagesAll_shuffled_original = averageImagesAll_shuffled;

    averageImagesAll            = averageImagesAll(1:179,:,:,:);
    averageImagesAllHR          = averageImagesAll;
    averageImagesAll_shuffled   = averageImagesAll_shuffled(:,1:179,:,:,:);
    % ==== ^^ DELETE THIS IF USING ALL CELLS ^^ ====


    nTrials             = size(imageMatrix,1);
    nFramesPerTrials    = size(imageMatrix,2);
    nSizeStimSide       = size(imageMatrix,3);

    % Subtract the mean white noise stimulus, because it is nonzero
    wnMean          = mean(mean(imageMatrix,1),2);
    wnMeanAvg       = mean(wnMean(:));
    wnMeanDiffMat   = wnMean-wnMeanAvg;

    averageImagesAll_shuffledMinusMean  = averageImagesAll_shuffled - reshape(reshape(reshape(wnMeanDiffMat,[],nSizeStimSide,nSizeStimSide),[],1,nSizeStimSide,nSizeStimSide),[],1,1,nSizeStimSide,nSizeStimSide);
    averageImagesAll_MinusMean          = averageImagesAll - reshape(reshape(wnMeanDiffMat,[],nSizeStimSide,nSizeStimSide),[],1,nSizeStimSide,nSizeStimSide);

    shuffledMean    = squeeze(mean(averageImagesAll_shuffledMinusMean,1));
    shuffledStd     = squeeze(std(averageImagesAll_shuffledMinusMean,0,1));

    averageImageZscoreHR = (averageImagesAll_MinusMean-shuffledMean)./shuffledStd;   % z-score: subtract mean from the raw value and then divide all by standard deviation



%% plot

maxSTAlr = max(abs(averageImagesAllLR(:)));
maxSTAhr = max(abs(averageImagesAllHR(:)));
maxZSTAlr = max(abs(averageImageZscoreLR(:)));
maxZSTAhr = max(abs(averageImageZscoreHR(:)));
% 
nCells = size(averageImagesAllLR,1);


pdfFile = fullfile(dirBase,'sara','Analysis','Neuropixel','marmosetFromNicholas','spatialRFs','elf1-STAs.pdf');

for ic = 170:176

    figure();
    sgtitle(['cell ' num2str(ic)])

    for it = 1:5

        data = squeeze(averageImagesAllLR(ic,it,:,:));
        subplot(4,5,it)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[-maxSTAlr maxSTAlr]); 
            box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            subtitle(['-' num2str(beforeSpike(it))])
            if it == 1
                text(0.02, 0.98, 'STA low res', ...
                    'Units','normalized', ...
                    'Color','w', ...
                    'FontSize',5, ...
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','top');
            end

        % data = squeeze(averageImageZscoreLR(ic,it,:,:));
        % subplot(4,5,it+5)
        %     imagesc(data); hold on
        %     axis square
        %     colormap(gray)
        %     set(gca,'clim',[-maxZSTAlr maxZSTAlr]); 
        %     box off; axis off
        %     set(gca,'xtick',[]); set(gca,'xticklabel',[])
        %     set(gca,'ytick',[]); set(gca,'yticklabel',[]) 
        %     if it == 1
        %         text(0.02, 0.98, 'zSTA low res', ...
        %             'Units','normalized', ...
        %             'Color','w', ...
        %             'FontSize',5, ...
        %             'HorizontalAlignment','left', ...
        %             'VerticalAlignment','top');
        %     end

        data = squeeze(averageImagesAllHR(ic,it,:,:)); 
        subplot(4,5,it+10)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[-maxSTAhr maxSTAhr]); 
            box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            subtitle(['-' num2str(beforeSpike(it))])
            if it == 1
                text(0.02, 0.98, 'STA high res', ...
                    'Units','normalized', ...
                    'Color','w', ...
                    'FontSize',5, ...
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','top');
            end

        % data = squeeze(averageImageZscoreHR(ic,it,:,:));
        % subplot(4,5,it+15)
        %     imagesc(data); hold on
        %     axis square
        %     colormap(gray)
        %     set(gca,'clim',[-maxZSTAhr maxZSTAhr]); 
        %     box off; axis off
        %     set(gca,'xtick',[]); set(gca,'xticklabel',[])
        %     set(gca,'ytick',[]); set(gca,'yticklabel',[]) 
        %     if it == 1
        %         text(0.02, 0.98, 'zSTA high res', ...
        %             'Units','normalized', ...
        %             'Color','w', ...
        %             'FontSize',5, ...
        %             'HorizontalAlignment','left', ...
        %             'VerticalAlignment','top');
        %     end
             
    end

    % Append current figure as a new page in the PDF
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);

    close(gcf)
end




%% zscore thresh for low res

nCells = size(averageImagesAllLR,1);
nSizeStimSide=16;
zthreshold = 2.5;

averageImageZscoreThresh = [];
for iCell = 1:nCells
    for it  = 1:5
        for ix = 1:nSizeStimSide
            for iy = 1:nSizeStimSide
               if averageImageZscoreLR(iCell,it,ix,iy) > zthreshold
                   averageImageZscoreThresh(iCell,it,ix,iy) = 1;
               elseif averageImageZscoreLR(iCell,it,ix,iy) < -zthreshold
                   averageImageZscoreThresh(iCell,it,ix,iy) = -1;
               else
                   averageImageZscoreThresh(iCell,it,ix,iy) = 0;
               end
            end
        end
    end
end



cells_sigRFbyTime_On   = nan(nCells, length(beforeSpike));
cells_sigRFbyTime_Off   = nan(nCells, length(beforeSpike));

for iCell = 1:nCells
    for it = 1:(length(beforeSpike))
        threshMat = squeeze(averageImageZscoreThresh(iCell,it,:,:));
        foundOn = false;
        foundOff = false;
        for ix = 1:(nSizeStimSide-2+1)
            for iy = 1:(nSizeStimSide-2+1)
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


% plot threshold images

pdfFile = fullfile(dirBase,'sara','Analysis','Neuropixel','marmosetFromNicholas','spatialRFs','elf1-STAs_LR_zthreshold.pdf');

for ic = 170:179

    figure();
    sgtitle(['cell ' num2str(ic) ', ' num2str(ind_sigRF(ic)) ' timepoints'])

    for it = 1:5

        data = squeeze(averageImageZscoreThresh(ic,it,:,:));
        subplot(4,5,it)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[-1 1]); 
            box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            subtitle(['-' num2str(beforeSpike(it))])
            if it == 1
                text(0.02, 0.98, 'zscore thresh = 2.5', ...
                    'Units','normalized', ...
                    'Color','w', ...
                    'FontSize',5, ...
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','top');
            end

             
    end

    % Append current figure as a new page in the PDF
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);

    close(gcf)
end

%% zscore thresh for high res

nCells = size(averageImagesAllLR,1);
nSizeStimSide=30;
zthreshold = 2.5;

averageImageZscoreThresh = [];
for iCell = 1:nCells
    for it  = 1:5
        for ix = 1:nSizeStimSide
            for iy = 1:nSizeStimSide
               if averageImageZscoreHR(iCell,it,ix,iy) > zthreshold
                   averageImageZscoreThresh(iCell,it,ix,iy) = 1;
               elseif averageImageZscoreHR(iCell,it,ix,iy) < -zthreshold
                   averageImageZscoreThresh(iCell,it,ix,iy) = -1;
               else
                   averageImageZscoreThresh(iCell,it,ix,iy) = 0;
               end
            end
        end
    end
end



cells_sigRFbyTime_On   = nan(nCells, length(beforeSpike));
cells_sigRFbyTime_Off   = nan(nCells, length(beforeSpike));

for iCell = 1:nCells
    for it = 1:(length(beforeSpike))
        threshMat = squeeze(averageImageZscoreThresh(iCell,it,:,:));
        foundOn = false;
        foundOff = false;
        for ix = 1:(nSizeStimSide-2+1)
            for iy = 1:(nSizeStimSide-2+1)
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


% plot threshold images

pdfFile = fullfile(dirBase,'sara','Analysis','Neuropixel','marmosetFromNicholas','spatialRFs','elf1-STAs_HR_zthreshold.pdf');

for ic = 170:179

    figure();
    sgtitle(['cell ' num2str(ic) ', ' num2str(ind_sigRF(ic)) ' timepoints'])

    for it = 1:5

        data = squeeze(averageImageZscoreThresh(ic,it,:,:));
        subplot(4,5,it)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[-1 1]); 
            box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])
            subtitle(['-' num2str(beforeSpike(it))])
            if it == 1
                text(0.02, 0.98, 'zscore thresh = 2.5', ...
                    'Units','normalized', ...
                    'Color','w', ...
                    'FontSize',5, ...
                    'HorizontalAlignment','left', ...
                    'VerticalAlignment','top');
            end



    end

    % Append current figure as a new page in the PDF
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);

    close(gcf)
end



%%
listnc  = 1:nCells;
ind     = listnc(ind_sigRF>0);

%%

for ic = 1:nCells
    con_beforeSpike = beforeSpike(2:4);
    is=1;
        for it = [1 2 3 4 5]
            xtempz(:,:) = squeeze(averageImageZscoreHR(ic,it,:,:)); %3:27,12:36

            if isnan(xtempz(1,1))
                xtempz(:,:) = ones(size(xtempz,1),size(xtempz,2));
            end

            jtempz(:,:) = rangefilt(xtempz(:,:),ones(5));

            j = squeeze(jtempz(:,:));
            q(it) = prctile(j(:),99);

            if it ==5
                q(it) = 1;   % set 5th timepoint (0.01s) to 1 to make sure if there is a peak at 4th timepoint, it can be detected
            end

            localConMap_data(ic,it,:,:) = xtempz;
            localConMap_map(ic,it,:,:) = jtempz;
            is=is+3;        
        end

        i = pickPeak_rfCI(q);   % Pick peak in 0.95 CI, but if there are two peaks, take the second
        m = q(i);
        bestTimePoint(ic,1) = i; % best time point
        bestTimePoint(ic,2) = m; % max q90 value

        data = squeeze(averageImageZscoreLR(ic,i,:,:));
        [az, el] = getRFcenter(data);
        azs(ic) = az;
        els(ic) = el;
        
    clear xtempz jtempz q m i
end





stop

%% old marmoset spatialRF analysis 
% using .mat files uploade to box/elf by Nicholas on July 4th, 2026



cellIdx = 1;

off_LR = offrflr{cellIdx};
on_LR = onrflr{cellIdx};
off_HR = offrfhr{cellIdx};
on_HR = onrfhr{cellIdx};



pdfFile = fullfile(dirBase,'sara','Analysis','Neuropixel','marmosetFromNicholas','spatialRFs','allBins_STAs.pdf');

for ic = 1:227

    figure();
    sgtitle(['cell ' num2str(ic)])

    off_LR = offrflr{ic};
    on_LR = onrflr{ic};
    off_HR = offrfhr{ic};
    on_HR = onrfhr{ic};

    for ib = 1:20

        data =  off_LR(:,:,ib);

        subplot(4,20,ib)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[0 1]); box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[])

        data =  off_HR(:,:,ib);

        subplot(4,20,ib+20)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[0 1]); box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[]) 

        data =  on_LR(:,:,ib);

        subplot(4,20,ib+40)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[0 1]); box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[]) 

        data =  on_HR(:,:,ib);

        subplot(4,20,ib+60)
            imagesc(data); hold on
            axis square
            colormap(gray)
            set(gca,'clim',[0 1]); box off; axis off
            set(gca,'xtick',[]); set(gca,'xticklabel',[])
            set(gca,'ytick',[]); set(gca,'yticklabel',[]) 

    end

    % Append current figure as a new page in the PDF
    exportgraphics(gcf, pdfFile,'ContentType', 'vector','Append', true);

    close(gcf)
end

