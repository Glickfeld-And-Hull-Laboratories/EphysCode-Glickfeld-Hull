
%% Turn RF center coordinates into stimulus center-origin coordinates

% To start with just one example center, choose an az and el
az = 10;
el = 22;

azDim = 52;
elDim = 29;

azDeg = az*2;
elDeg = el*2;
azDimDeg = azDim*2;
elDimDeg = elDim*2;

stimAz = -20;
stimEl = -10;


figure;
% plot RF center (recorded in topLeft-origin coordinates) 
    subplot(2,2,1)
        scatter(az,el,10,'b','filled');
        xlim([1 azDim]); xlabel('deg/2')
        ylim([1 elDim]); ylabel('deg/2')
        set(gca, 'YDir', 'reverse')
        title('RF center, topLeft-origin, original')

% plot RF center (recorded in topLeft-origin coordinates) 
    subplot(2,2,2)
        scatter(azDeg,elDeg,10,'b','filled');
        xlim([1 azDimDeg]); xlabel('deg')
        ylim([1 elDimDeg]); ylabel('deg')
        set(gca, 'YDir', 'reverse')
        title('RF center, topLeft-origin, in degrees')

% plot stimulus center (recorded in center-origin coordinates)        
    subplot(2,2,3)
        scatter(stimAz,stimEl,20,'r');
        xlim([-52 52]); xlabel('deg')
        ylim([-29 29]); ylabel('deg')
        title('stimulus location, center-origin')

% transform image Y axis (elevation) into bottom-Left origin coordinates to
% match X axis (azimuth)
    el_flip = elDimDeg - elDeg;

% transform X and Y RF centers into center-origin coordinates
    azRFcent = (az - (azDim+1)/2)*2;  % 1-based indexing, so that's why I added the 1
    elRFcent = ((elDim+1)/2 - el)*2;

% plot stimulus center and RF centers in center-origin coordinates
    subplot(2,2,4)
        scatter(stimAz,stimEl,20,'r'); hold on
        scatter(azRFcent,elRFcent,10,'b', 'filled')
        xlim([-52 52]); xlabel('deg')
        ylim([-29 29]); ylabel('deg')
        title('stim and RF centers, center-origin')

% distance between RF center and stimulus (degrees)
RFstimDist = sqrt((azRFcent - stimAz)^2 + (elRFcent - stimEl)^2);



%% Now use 'azs' and 'els'
clear all; close all

% Choose experiment
iexp=2;


baseDir = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\';
    [exptStruct] = iniExptStruct(iexp); % Load relevant times and directories for this experiment
load(fullfile(baseDir, 'sara\Analysis\Neuropixel\ISN_Jerry\spatialRFs\', [exptStruct.mouse '-' exptStruct.date '_spatialRFs.mat']))

ind_RF = find(ind_sigRF>0);

azDim = 52;
elDim = 29;

% stimulus radius (deg)
stimRad = 7.5 / 2;

stimPosition = exptStruct.stimPos;
   stimAz = stimPosition(1);
   stimEl = stimPosition(2);


% Keep only cells with significant RFs
azs_RF = azs(ind_RF);
els_RF = els(ind_RF);

% Convert RF centers from top-left-origin coordinates to center-origin coordinates
    azRFcent = (azs_RF - (azDim+1)/2) * 2;
    elRFcent = ((elDim+1)/2 - els_RF) * 2;

% Distance from each RF center to stimulus (degrees)
    RFstimDist = hypot(azRFcent - stimAz, elRFcent - stimEl);

    figure;
    sgtitle(['expt ' num2str(iexp) ', ' exptStruct.mouse ' ' exptStruct.date])

% RF centers in original coordinates
    subplot(2,2,1)
        scatter(azs_RF, els_RF, 20, 'b', 'filled')
        xlim([1 azDim])
        ylim([1 elDim])
        set(gca,'YDir','reverse')
        xlabel('deg/2')
        ylabel('deg/2')
        title('RF centers, topLeft-origin')

% RF centers in degree units (still top-left-origin)
    subplot(2,2,2)
        scatter(azs_RF*2, els_RF*2, 20, 'b', 'filled')
        xlim([1 azDim*2])
        ylim([1 elDim*2])
        set(gca,'YDir','reverse')
        xlabel('deg')
        ylabel('deg')
        title('RF centers, topLeft-origin (deg)')

% Stimulus location
    subplot(2,2,3)
        scatter(stimAz, stimEl, 50, 'r', 'filled')
        xlim([-52 52])
        ylim([-29 29])
        xlabel('deg')
        ylabel('deg')
        title('Stimulus location')

% RF centers and stimulus in center-origin coordinates
    subplot(2,2,4)
        scatter(azRFcent, elRFcent, 20, 'b', 'filled')
        hold on
        % stimulus center
        scatter(stimAz, stimEl, 20, 'r', 'filled')
        % stimulus circle
        theta = linspace(0,2*pi,200);
        plot(stimAz + stimRad*cos(theta), ...
             stimEl + stimRad*sin(theta), ...
             'r-', 'LineWidth', 1.5);
                
        xlim([-52 52])
        ylim([-29 29])
        xlabel('deg')
        ylabel('deg')
        axis equal
        title(sprintf('RF centers and stimulus (mean dist = %.2f deg)', nanmean(RFstimDist)))
        legend('RF centers','Stimulus','Location','best')