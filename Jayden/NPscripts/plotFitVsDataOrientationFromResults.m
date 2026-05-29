function plotFitVsDataOrientationFromResults( ...
    results, modelRegistry, modelName, avg_resp_dir_all, cellIDs, ...
    pdfFile, figTitle)
% plotFitVsDataOrientationFromResults
%
% Standalone plotting function.
% Does NOT modify results. Only reads from results and exports a PDF.
%
% Inputs:
%   results          output of runRFModelComparison
%   modelRegistry    registry used for fitting
%   modelName        string, e.g. 'DoG x cos test'
%   avg_resp_dir_all full response array
%   cellIDs          cell IDs corresponding to RF_cells
%   pdfFile          output pdf path
%   figTitle         figure title
%
% Draws for each fitted RF:
%   red  = fitted orientation from params(6)
%   cyan = preferred orientation from grating data
%   yellow = center-to-surround offset axis
%
% Splits output across multiple PDF pages, max 30 cells per page.

    modelIdx = find(strcmp({modelRegistry.name}, modelName), 1);
    assert(~isempty(modelIdx), 'Model name not found in modelRegistry.');

    RF_cells = results.models{modelIdx};
    paramStruct = results.params{modelIdx};

    assert(iscell(RF_cells), ...
        'results.models{modelIdx} must be a cell array.');
    assert(iscell(paramStruct), ...
        'results.params{modelIdx} must be a cell array.');
    assert(numel(RF_cells) == numel(paramStruct), 'RF/param mismatch.');
    assert(numel(RF_cells) == numel(cellIDs), 'RF/cellID mismatch.');

    % ---------------------------------------
    % Preferred orientation from grating data
    % ---------------------------------------
    nStimDir = size(avg_resp_dir_all, 2);
    OSI_ind = nan(size(avg_resp_dir_all, 1), 1);

    for iCell = 1:size(avg_resp_dir_all, 1)
        resp = squeeze(avg_resp_dir_all(iCell, :, 1, 1, 1));
        ori_resp = (resp(1:nStimDir/2) + resp(nStimDir/2+1:end)) / 2;
        [~, prefInd] = max(ori_resp);
        OSI_ind(iCell) = (prefInd - 1) * 30;
    end

    % ---------------------------------------
    % Multi-page settings
    % ---------------------------------------
    nShow = numel(RF_cells);
    nPerPage = 30;
    nCols = 6;
    nRows = 5;
    nPages = ceil(nShow / nPerPage);

    if exist(pdfFile, 'file')
        delete(pdfFile)
    end

    for iPage = 1:nPages
        idxStart = (iPage - 1) * nPerPage + 1;
        idxEnd = min(iPage * nPerPage, nShow);
        plotIdx = idxStart:idxEnd;

        hFig = figure('Color', 'w', 'Position', [100 100 1400 900]);

        for j = 1:numel(plotIdx)
            i = plotIdx(j);
            subplot(nRows, nCols, j)

            rf = RF_cells{i};

            if isempty(rf) || any(~isfinite(rf(:)))
                axis off
                title(sprintf('%d | invalid RF', cellIDs(i)), ...
                    'FontSize', 7)
                continue
            end

            clim = max(abs(rf(:)));
            if clim == 0
                clim = 1;
            end

            imagesc(rf, [-clim clim])
            axis image off
            colormap gray
            set(gca, 'YDir', 'reverse')
            hold on

            [ny, nx] = size(rf);
            cx = (nx + 1) / 2;
            cy = (ny + 1) / 2;
            L = 0.45 * min(nx, ny);

            % ----------------------------
            % fitted orientation (red)
            % ----------------------------
            fit_deg = NaN;
            params = paramStruct{i};

            if isnumeric(params) && numel(params) >= 6 && ...
                    isfinite(params(6))
                theta_fit = mod(params(6), pi);
                fit_deg = rad2deg(theta_fit);

                dx_fit = cos(theta_fit);
                dy_fit = sin(theta_fit);

                plot([cx - L * dx_fit, cx + L * dx_fit], ...
                     [cy - L * dy_fit, cy + L * dy_fit], ...
                     'r-', 'LineWidth', 1.5);
            end

            % ----------------------------
            % real-data orientation (cyan)
            % ----------------------------
            data_deg = NaN;
            cellIdx = cellIDs(i);

            if cellIdx >= 1 && cellIdx <= numel(OSI_ind) && ...
                    isfinite(OSI_ind(cellIdx))
                data_deg = OSI_ind(cellIdx);
                theta_data = deg2rad(data_deg);

                dx_data = cos(theta_data);
                dy_data = sin(theta_data);

                plot([cx - L * dx_data, cx + L * dx_data], ...
                     [cy - L * dy_data, cy + L * dy_data], ...
                     'c-', 'LineWidth', 1.5);
            end

            % ----------------------------
            % mismatch
            % ----------------------------
            dori = NaN;
            if isfinite(fit_deg) && isfinite(data_deg)
                dori = abs(fit_deg - data_deg);
                dori = mod(dori, 180);
                if dori > 90
                    dori = 180 - dori;
                end
            end

            % ----------------------------
            % center-to-surround axis (yellow)
            % ----------------------------
            if isnumeric(params) && numel(params) >= 12 && ...
                    isfinite(params(11)) && isfinite(params(12))

                dx_env = params(11);
                dy_env = params(12);

                x_center = cx;
                y_center = cy;

                x_surround = cx + dx_env;
                y_surround = cy + dy_env;

                plot([x_center, x_surround], ...
                     [y_center, y_surround], ...
                     'y-', 'LineWidth', 1.5);
            end

            title(sprintf('%d | fit %.1f | data %.1f | d %.1f', ...
                cellIDs(i), fit_deg, data_deg, dori), ...
                'FontSize', 7)

            hold off
        end

        sgtitle(sprintf('%s (Page %d of %d)', ...
            figTitle, iPage, nPages), ...
            'FontWeight', 'bold')

        if iPage == 1
            exportgraphics(hFig, pdfFile, 'ContentType', 'vector');
        else
            exportgraphics(hFig, pdfFile, ...
                'ContentType', 'vector', 'Append', true);
        end

        close(hFig)
    end
end