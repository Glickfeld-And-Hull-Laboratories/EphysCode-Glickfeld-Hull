function [ONmask, OFFmask, RF_processed, CombinedMask] = segmentRF(RF)

%% 1. Normalize and smooth
RFz  = zscore(RF(:)); RFz = reshape(RFz, size(RF));
%RFs  = imgaussfilt(RFz, 0.7);
RF_processed = medfilt2(RFz, [3 3]);

%% Scale image so activecontour works
mn = min(RF_processed(:));
mx = max(RF_processed(:));
RF_scaled = (RF_processed - mn) / (mx - mn + eps);   % normalize to [0,1]
RF_scaled = RF_scaled * 255;                         % scale to [0,255]
 % [0,255]

%% ON SEGMENT
% Percentile threshold (robust)
th_ON = prctile(RF_processed(:), 90);  
ON_seed = RF_processed > th_ON;

% If too small: relax threshold
if nnz(ON_seed) < 5
    th_ON = prctile(RF_processed(:), 80);
    ON_seed = RF_processed > th_ON;
end

% Run contour
ONmask = activecontour(RF_scaled, ON_seed, 20, 'Chan-Vese');

% Keep only positive lobe
ONmask = ONmask & (RF_processed > 0);


%% OFF SEGMENT
th_OFF = prctile(RF_processed(:), 10);
OFF_seed = RF_processed < th_OFF;

if nnz(OFF_seed) < 5
    th_OFF = prctile(RF_processed(:), 20);
    OFF_seed = RF_processed < th_OFF;
end

OFFmask = activecontour(RF_scaled, OFF_seed, 20, 'Chan-Vese');
OFFmask = OFFmask & (RF_processed < 0);


%% Combined mask
CombinedMask = 0.5 * ones(size(RF_processed));
CombinedMask(OFFmask) = 0;
CombinedMask(ONmask) = 1;

%% Plot
figure;

subplot(1,2,1)
imagesc(RF_processed); colormap gray; axis image off;
title('Processed RF');

subplot(1,2,2)
imagesc(CombinedMask); colormap gray; axis image off;
title('ON (white) & OFF (black)');

end
