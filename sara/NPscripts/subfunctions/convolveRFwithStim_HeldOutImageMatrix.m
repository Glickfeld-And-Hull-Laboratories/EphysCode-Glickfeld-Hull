
function [resp] = convolveRFwithStim_HeldOutImageMatrix(filt, runloc, thisMask)

    if runloc == 1    % Hubel
        dirBase = '\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home';
    elseif runloc == 2    % Wiesel
        dirBase = 'home/smg92@dhe.duke.edu/GlickfeldLabShare/All_Staff/home';
    else
        error('Location not valid. 1 == Hubel, 2 == Wiesel.')
    end

    % Load stimulus
    load(fullfile(dirBase, 'sara', 'Analysis', 'Neuropixel', 'noiseStimuli', '5min_2deg_4rep_imageMatrix.mat'))

    
    [nTrials, nFrames, X, Y] = size(imageMatrix);
    [C, x, y] = size(filt);

    filters_flat = reshape(filt, C, X*Y);  % flattern filters, (C x XY)
    
    % -----------------------------
    % CASE 1: No held-out mask
    % -----------------------------
    if nargin < 3 || isempty(thisMask)
    
        stim = reshape(imageMatrix, [], X, Y);              % (T x X x Y)
        stim_flat = double(reshape(stim, [], X*Y));         % (T x XY)
    
        resp = stim_flat * filters_flat';                   % (T x C)
    
    % -----------------------------
    % CASE 2: Held-out mask
    % -----------------------------
    else
    
        nHeldOut = size(thisMask,1);
    
        % Determine number of selected frames from first split
        mask0 = squeeze(thisMask(1,:,:));
        nSel = sum(mask0(:) == 0);
    
        % Preallocate
        resp = zeros(nSel, C, nHeldOut);
    
        for ih = 1:nHeldOut
    
            mask = squeeze(thisMask(ih,:,:));   % (trials x frames)
    
            % Indices where mask == 0
            idx = find(mask == 0);
            [trialIdx, frameIdx] = ind2sub([nTrials, nFrames], idx);
    
            % Extract frames
            stim_sel = zeros(nSel, X, Y);
   
            for i = 1:nSel
                stim_sel(i,:,:) = imageMatrix(trialIdx(i), frameIdx(i), :, :);
            end
    
            % Flatten and convolve
            stim_flat = double(reshape(stim_sel, nSel, X*Y));   % (T_sel x XY)
            resp(:,:,ih) = stim_flat * filters_flat';           % (T_sel x C)
    
        end
    end
end





