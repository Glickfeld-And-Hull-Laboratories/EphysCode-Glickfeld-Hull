function freqTable = extractFrequencyVerificationAllCells( ...
    STA_cropped, cellIDs, results, modelRegistry, modelName)

% extractFrequencyVerificationAllCells
%
% For each fitted cell, compute:
%   f_pred    = fitted frequency parameter params(9)
%   f_carrier = FFT-estimated frequency from carrier-only image
%   f_full    = FFT-estimated frequency from full fitted RF
%   f_data    = FFT-estimated frequency from cropped STA
%
% Output:
%   freqTable = MATLAB table with one row per valid fitted cell

    modelIdx = find(strcmp({modelRegistry.name}, modelName), 1);
    assert(~isempty(modelIdx), 'Model name not found in modelRegistry.');

    paramStruct = results.params{modelIdx};

    assert(iscell(paramStruct), 'results.params{modelIdx} must be cell.');
    assert(size(STA_cropped, 3) == numel(paramStruct), ...
        'STA_cropped and paramStruct size mismatch.');
    assert(size(STA_cropped, 3) == numel(cellIDs), ...
        'STA_cropped and cellIDs size mismatch.');

    nCells = numel(cellIDs);

    out_cellID = nan(nCells, 1);
    out_f_pred = nan(nCells, 1);
    out_f_carrier = nan(nCells, 1);
    out_f_full = nan(nCells, 1);
    out_f_data = nan(nCells, 1);

    out_fx_carrier = nan(nCells, 1);
    out_fy_carrier = nan(nCells, 1);
    out_fx_full = nan(nCells, 1);
    out_fy_full = nan(nCells, 1);
    out_fx_data = nan(nCells, 1);
    out_fy_data = nan(nCells, 1);

    out_theta_deg = nan(nCells, 1);

    for k = 1:nCells
        rf_data = STA_cropped(:, :, k);
        params = paramStruct{k};

        out_cellID(k) = cellIDs(k);

        if isempty(params) || ~isnumeric(params) || numel(params) < 12 || ...
                any(~isfinite(params([3 4 5 6 7 8 9 10 11 12])))
            continue
        end

        % -----------------------------
        % unpack parameters
        % -----------------------------
        Ac = params(1);
        As = params(2);
        sc = params(3);
        delta = params(4);
        ss = sc + delta;
        tau = params(5);
        theta = params(6);
        x0 = params(7);
        y0 = params(8);
        f = params(9);
        phi = params(10);
        dx = params(11);
        dy = params(12);

        out_f_pred(k) = f;
        out_theta_deg(k) = rad2deg(mod(theta, pi));

        if sc <= 0 || ss <= 0 || tau <= 0
            continue
        end

        % -----------------------------
        % build model pieces
        % -----------------------------
        [ny, nx] = size(rf_data);

        x = (1:nx) - mean(1:nx);
        y = (1:ny) - mean(1:ny);
        [X, Y] = meshgrid(x, y);

        Xc = X - x0;
        Yc = Y - y0;

        Xs = X - (x0 + dx);
        Ys = Y - (y0 + dy);

        Xcp = cos(theta) .* Xc + sin(theta) .* Yc;
        Ycp = -sin(theta) .* Xc + cos(theta) .* Yc;

        Xsp = cos(theta) .* Xs + sin(theta) .* Ys;
        Ysp = -sin(theta) .* Xs + cos(theta) .* Ys;

        Gc = exp(-(Xcp.^2 + (tau .* Ycp).^2) ./ (2 .* sc.^2));
        Gs = exp(-(Xsp.^2 + (tau .* Ysp).^2) ./ (2 .* ss.^2));

        carrier = cos(phi) .* cos(2 .* pi .* f .* Xcp) - ...
            sin(phi) .* sin(2 .* pi .* f .* Xcp);

        DoGenv = Ac .* Gc - As .* Gs;
        fullModel = DoGenv .* carrier;

        % -----------------------------
        % FFT-estimated frequencies
        % -----------------------------
        [f_carrier, fx_carrier, fy_carrier] = ...
            estimateFFTfreqOneImagePadded(rf_data, theta, 128);

        [f_full, fx_full, fy_full] = ...
            estimateFFTfreqOneImagePadded(rf_data, theta, 128);

        [f_data, fx_data, fy_data] = ...
            estimateFFTfreqOneImagePadded(rf_data, theta, 128);

        out_f_carrier(k) = f_carrier;
        out_f_full(k) = f_full;
        out_f_data(k) = f_data;

        out_fx_carrier(k) = fx_carrier;
        out_fy_carrier(k) = fy_carrier;
        out_fx_full(k) = fx_full;
        out_fy_full(k) = fy_full;
        out_fx_data(k) = fx_data;
        out_fy_data(k) = fy_data;
    end

    freqTable = table( ...
        out_cellID, ...
        out_theta_deg, ...
        out_f_pred, ...
        out_f_carrier, out_fx_carrier, out_fy_carrier, ...
        out_f_full, out_fx_full, out_fy_full, ...
        out_f_data, out_fx_data, out_fy_data, ...
        'VariableNames', { ...
            'cellID', ...
            'theta_deg', ...
            'f_pred', ...
            'f_carrier', 'fx_carrier', 'fy_carrier', ...
            'f_full', 'fx_full', 'fy_full', ...
            'f_data', 'fx_data', 'fy_data'});
end


function [f_peak, fx_peak, fy_peak] = estimateFFTfreqOneImagePadded( ...
    img, theta, padN)

    if nargin < 3 || isempty(padN)
        padN = 128;
    end

    F = fftshift(fft2(img, padN, padN));
    M = abs(F);

    fx = (-floor(padN/2):ceil(padN/2)-1) / padN;
    fy = (-floor(padN/2):ceil(padN/2)-1) / padN;
    [FX, FY] = meshgrid(fx, fy);

    proj = FX .* cos(theta) + FY .* sin(theta);
    r = sqrt(FX.^2 + FY.^2);

    mask = proj > 0;

    [~, idx0] = min(r(:));
    M(idx0) = 0;
    M(~mask) = 0;

    if all(M(:) == 0) || all(~isfinite(M(:)))
        f_peak = NaN;
        fx_peak = NaN;
        fy_peak = NaN;
        return
    end

    [~, idx] = max(M(:));
    fx_peak = FX(idx);
    fy_peak = FY(idx);
    f_peak = sqrt(fx_peak^2 + fy_peak^2);
end