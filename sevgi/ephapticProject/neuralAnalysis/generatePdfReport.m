function generatePdfReport(unitId, layer, depth, reportName)
%     import mlreportgen.ppt.*;

    globals;
    ext = '.tif'; %'.pdf';

%     unit = unitGoodSorted(2);
%     unitId = unit.id;
%     layer = unit.layer;
%     depth = unit.depth;
%     reportName = 'reportByDepth.pdf';
    f = figure('Position', [globalX globalY globalW globalH]);
    
    t = tiledlayout(3,2,'TileSpacing','none','Padding','none');    
%     pathToWaveForm = [pathToFigureFolder num2str(unitId) '/' FILE_NAME_WAVEFORM ext]; % spikeWaveForm_CatGT_loccar28_
%     if exist(pathToWaveForm)==2
%         nexttile
%         I = imread(pathToWaveForm);
%         imshow(I, 'interpolation','bilinear', InitialMagnification='fit', Reduce=0); 
%         title(['Unit=' num2str(unitId) ' Layer=' layer ' Depth=' num2str(depth)]);
%     end

    pathToWaveForm = [pathToFigureFolder num2str(unitId) '/' FILE_NAME_MULTI_WAVEFORM '*' ext]; %'spikeWaveFormMulti_CatGT_filtered_GABAZINENBQX-AP5.tif'];
    multiWaveFormFile = dir(pathToWaveForm);
    if ~isempty(multiWaveFormFile)        
        nexttile
        I = imread([multiWaveFormFile.folder '/' multiWaveFormFile.name],'tif');
        imshow(I, 'interpolation','bilinear', InitialMagnification='fit', Reduce=0);
        title(['Unit=' num2str(unitId) ' Layer=' layer ' Depth=' num2str(depth)]);
    end

    pathToWaveForm = [pathToFigureFolder 'rasterPSTH/rasterPsth_' num2str(unitId) ext];
    if exist(pathToWaveForm)==2
        nexttile
        I = imread(pathToWaveForm);
        imshow(I, 'interpolation','bilinear', InitialMagnification='fit', Reduce=0);
    end
        
    pathToAmpDist = [pathToFigureFolder num2str(unitId) '/amplitudeDist_' num2str(unitId) ext];
    if exist(pathToAmpDist)==2
        nexttile; %([1 3]);
        I = imread(pathToAmpDist);
        imshow(I, 'interpolation','bilinear', InitialMagnification='fit', Reduce=0);
    end

    pathToAmpHeatMap = [pathToFigureFolder num2str(unitId) '/' FILE_NAME_AMPLITUDE_HEAT_MAP '_' num2str(unitId) ext];
    if exist(pathToAmpHeatMap)==2
        nexttile;
        I = imread(pathToAmpHeatMap);
        imshow(I, 'interpolation','bilinear', InitialMagnification='fit', Reduce=0);
    end

    %nexttile;    
%     pathToACG = [pathToFigureFolder num2str(unitId) '/ACG_' num2str(unitId) '_.tif'];
%     if exist(pathToACG)==2
%         nexttile
%         I = imread(pathToACG);
%         imshow(I, 'interpolation','bilinear', InitialMagnification='fit', Reduce=0);
%     end

    pathToACG = [pathToFigureFolder num2str(unitId) '/ACG_' num2str(unitId) '_' FIRST_DRUG ext];
    if exist(pathToACG)==2
        nexttile
        I = imread(pathToACG);
        imshow(I, 'interpolation','bilinear', InitialMagnification='fit', Reduce=0);
    end
    
    pathToACG = [pathToFigureFolder num2str(unitId) '/ACG_' num2str(unitId) '_' SECOND_DRUG ext];
    if exist(pathToACG)==2
        nexttile
        I = imread(pathToACG);
        imshow(I, 'interpolation','bilinear', InitialMagnification='fit', Reduce=0);
    end
    %f.Position=[globalX globalY globalW/2 globalH/2];

    % Adjust layout
    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    exportgraphics(t,[pathToFigureFolder '/' reportName],'BackgroundColor','none','ContentType','vector',"Append",true);    
    close all;
end


