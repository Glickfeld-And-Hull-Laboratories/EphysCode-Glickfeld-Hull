function plotPrefThetaOffsetScatter( ...
    results, modelRegistry, modelName, avg_resp_dir_all, cellIDs)

% plotPrefThetaOffsetScatter
%
% Scatter plot where each point is one cell:
%   x = delta(pref, theta_fit) in degrees
%   y = delta(pref, offset_axis) in degrees
%   color = offset length
%
% pref is computed from grating responses
% theta_fit is params(6)
% offset axis comes from params(11:12)

    modelIdx = find(strcmp({modelRegistry.name}, modelName), 1);
    assert(~isempty(modelIdx), 'Model name not found in modelRegistry.');

    paramStruct = results.params{modelIdx};

    assert(iscell(paramStruct), ...
        'results.params{modelIdx} must be a cell array.');
    assert(numel(paramStruct) == numel(cellIDs), ...
        'paramStruct/cellID mismatch.');

    % ---------------------------------------
    % Preferred orientation from grating data
    % ---------------------------------------% check global orientation,
    % ventor sum, direction fit. 
    nStimDir = size(avg_resp_dir_all, 2);
    pref_deg_all = nan(size(avg_resp_dir_all, 1), 1);

    for iCell = 1:size(avg_resp_dir_all, 1)
        resp = squeeze(avg_resp_dir_all(iCell, :, 1, 1, 1));
        ori_resp = (resp(1:nStimDir/2) + resp(nStimDir/2+1:end)) / 2;
        [~, prefInd] = max(ori_resp);
        pref_deg_all(iCell) = (prefInd - 1) * 30;
    end

    % ---------------------------------------
    % Preallocate
    % ---------------------------------------
    n = numel(cellIDs);

    d_pref_theta = nan(n, 1);
    d_pref_offset = nan(n, 1);
    offset_len = nan(n, 1);

    % Optional: also store raw angles
    pref_deg_used = nan(n, 1);
    theta_deg_used = nan(n, 1);
    offset_deg_used = nan(n, 1);

    % ---------------------------------------
    % Extract metrics per cell
    % ---------------------------------------
    for i = 1:n
        params = paramStruct{i};
        cellIdx = cellIDs(i);

        if isempty(params) || ~isnumeric(params) || numel(params) < 12 || ...
                any(~isfinite(params([6 11 12])))
            continue
        end

        if cellIdx < 1 || cellIdx > numel(pref_deg_all) || ...
                ~isfinite(pref_deg_all(cellIdx))
            continue
        end

        pref_deg = pref_deg_all(cellIdx);

        % predicted orientation theta
        theta_deg = mod(rad2deg(params(6)), 180);

        % offset axis from yellow line
        dx = params(11);
        dy = params(12);

        len = hypot(dx, dy);

        % If offset is zero, angle is undefined
        if len == 0
            continue
        end

        offset_deg = mod(rad2deg(atan2(dy, dx)), 180);

        % Wrapped orientation differences in [-90, 90]
        d1 = wrapOrientationDiffDeg(pref_deg, theta_deg);
        d2 = wrapOrientationDiffDeg(pref_deg, offset_deg);

        d_pref_theta(i) = d1;
        d_pref_offset(i) = d2;
        offset_len(i) = len;

        pref_deg_used(i) = pref_deg;
        theta_deg_used(i) = theta_deg;
        offset_deg_used(i) = offset_deg;
    end

    % ---------------------------------------
    % Keep only valid cells
    % ---------------------------------------
    good = isfinite(d_pref_theta) & ...
           isfinite(d_pref_offset) & ...
           isfinite(offset_len);

    x = d_pref_theta(good);
    y = d_pref_offset(good);
    c = offset_len(good);

    if isempty(x)
        error('No valid cells to plot.');
    end

    % ---------------------------------------
    % Scatter plot
    % ---------------------------------------
    figure('Color', 'w', 'Position', [100 100 750 620]);

    scatter(x, y, 60, c, 'filled', ...
        'MarkerFaceAlpha', 0.85, ...
        'MarkerEdgeColor', 'k');

    hold on
    xline(0, 'k--');
    yline(0, 'k--');
    hold off

    colormap(parula)
    cb = colorbar;
    cb.Label.String = 'Offset length';

    xlabel('\Delta(pref, \theta_{fit}) [deg]');
    ylabel('\Delta(pref, offset axis) [deg]');
    title('Preferred orientation vs fit orientation and offset axis');

    axis square
    grid on
end


function d = wrapOrientationDiffDeg(a, b)
% Return orientation difference a-b in degrees, wrapped to [-90, 90]

    d = a - b;
    d = mod(d + 90, 180) - 90;
end