function rankRFsByParameter( ...
    RF_cells, paramStruct, cellIDs, ...
    pdfFile, figTitle, ...
    modelType, paramName)

%% ===============================
% Sanity checks
%% ===============================

assert(iscell(RF_cells), 'RF_cells must be cell array');
assert(numel(RF_cells) == numel(paramStruct), 'RF/param mismatch');
assert(numel(RF_cells) == numel(cellIDs), 'RF/cellID mismatch');

%% ===============================
% Extract parameter values
%% ===============================

param_vals = nan(numel(RF_cells),1);

for i = 1:numel(RF_cells)

    switch modelType

        case 'standard'
            params = paramStruct{i};

            switch paramName
                case 'orientation'
                    param_vals(i) = params(6);
                case 'frequency'
                    param_vals(i) = params(9);
                case 'elongation'
                    param_vals(i) = params(5);
                case 'size'
                    param_vals(i) = params(3);
            end

        case 'sg'
            fit = paramStruct{i};

            switch paramName
                case 'orientation'
                    param_vals(i) = fit.theta;
                case 'frequency'
                    param_vals(i) = fit.sf;
                case 'elongation'
                    param_vals(i) = fit.gamma;
                case 'size'
                    param_vals(i) = fit.sigma_x;
            end

    end
end

%% ===============================
% Orientation wrapping
%% ===============================

if strcmp(paramName,'orientation')
    param_vals = mod(param_vals, pi);
end

%% ===============================
% Sort
%% ===============================

[param_sorted, sortIdx] = sort(param_vals,'ascend');

RF_sorted     = RF_cells(sortIdx);
cellID_sorted = cellIDs(sortIdx);

%% ===============================
% Plot layout
%% ===============================

nCols = 6;
nShow = numel(RF_sorted);
nRows = ceil(nShow / nCols);

if exist(pdfFile,'file')
    delete(pdfFile)
end

figure('Color','w','Position',[100 100 1400 800]);

for i = 1:nShow

    subplot(nRows, nCols, i)

    rf = RF_sorted{i};
    clim = max(abs(rf(:)));

    imagesc(rf,[-clim clim])
    axis image off
    colormap gray
    hold on

    %% Overlay orientation axis
    if strcmp(paramName,'orientation')

        theta = param_sorted(i);

        [ny,nx] = size(rf);
        cx = nx/2;
        cy = ny/2;

        L = 0.45 * min(nx,ny);

        dx = cos(theta);
        dy = sin(theta);

        plot([cx-L*dx cx+L*dx], ...
             [cy-L*dy cy+L*dy], ...
             'r-','LineWidth',1.5);
    end

    hold off

    title(sprintf('%d | %.3f', ...
        cellID_sorted(i), param_sorted(i)), ...
        'FontSize',7)

end

sgtitle(figTitle,'FontWeight','bold')

exportgraphics(gcf,pdfFile,'ContentType','vector');
close(gcf)

end