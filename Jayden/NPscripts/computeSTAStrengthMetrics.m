function metrics = computeSTAStrengthMetrics( ...
    indLoop, ind_DS, avgImgZscore_all, avgImgZscoreThresh_all, ...
    bestTimePoint_all, sideLength)
% computeSTAStrengthMetrics
%
% Computes STA strength metrics for the fitted-cell subset, aligned to the
% compact fitted-cell order k = 1:numel(indLoop).
%
% Inputs
%   indLoop                subset indices used in the wrapper
%   ind_DS                 original selected cell list
%   avgImgZscore_all       z-scored STA maps
%   avgImgZscoreThresh_all thresholded z-score masks
%   bestTimePoint_all      timepoint summary array
%   sideLength             RF crop size, usually 20
%
% Output
%   metrics struct with fields:
%       .cellIDs
%       .peakAbsZ
%       .rmsZ
%       .meanAbsZ
%       .fracSigPix
%       .nSigPix
%       .bestTP
%       .cropCenter
%       .STA_cropped_z

    if nargin < 6 || isempty(sideLength)
        sideLength = 20;
    end

    nCells = numel(indLoop);

    metrics = struct();
    metrics.cellIDs = nan(nCells, 1);
    metrics.peakAbsZ = nan(nCells, 1);
    metrics.rmsZ = nan(nCells, 1);
    metrics.meanAbsZ = nan(nCells, 1);
    metrics.fracSigPix = nan(nCells, 1);
    metrics.nSigPix = nan(nCells, 1);
    metrics.bestTP = nan(nCells, 1);
    metrics.cropCenter = nan(nCells, 2);
    metrics.STA_cropped_z = nan(sideLength, sideLength, nCells);

    for k = 1:nCells
        ii = indLoop(k);
        ic = ind_DS(ii);

        metrics.cellIDs(k) = ic;
        tp = bestTimePoint_all(ic, 1);
        metrics.bestTP(k) = tp;

        % z-score STA map at best timepoint
        staMap = medfilt2(imgaussfilt( ...
            squeeze(avgImgZscore_all(ic, tp, :, :)), 1));

        [el, az] = getRFcenter(staMap);
        metrics.cropCenter(k, :) = [az, el];

        staCrop = cropRFtoCenter(az, el, staMap, sideLength);
        metrics.STA_cropped_z(:, :, k) = staCrop;

        metrics.peakAbsZ(k) = max(abs(staCrop(:)));
        metrics.rmsZ(k) = sqrt(mean(staCrop(:) .^ 2));
        metrics.meanAbsZ(k) = mean(abs(staCrop(:)));

        % thresholded significance mask at same timepoint
        sigMask = squeeze(avgImgZscoreThresh_all(ic, tp, :, :));
        sigMaskCrop = cropRFtoCenter(az, el, sigMask, sideLength);

        metrics.nSigPix(k) = nnz(sigMaskCrop);
        metrics.fracSigPix(k) = nnz(sigMaskCrop) / numel(sigMaskCrop);
    end
end