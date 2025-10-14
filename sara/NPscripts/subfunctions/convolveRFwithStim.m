


function [resp] = convolveRFwithStim(filt,stimtype)
    
    if stimtype == 4
        load(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\', 'sara', 'Analysis', 'Neuropixel', 'noiseStimuli/', '5min_2deg_4rep_imageMatrix.mat'))
    elseif stimtype == 3
        load(fullfile('\\duhs-user-nc1.dhe.duke.edu\dusom_glickfeldlab\All_staff\home\', 'sara', 'Analysis', 'Neuropixel', 'noiseStimuli/', '5min_2deg_3rep_imageMatrix.mat'))
    end

    stim = reshape(imageMatrix, [], size(imageMatrix,3), size(imageMatrix,4));   % concatenate trials

    [T, X, Y] = size(stim);
    [C, x, y] = size(filt);
    stim_flat   = double(reshape(stim, T, X*Y));       % (ntrials x XY)
    filters_flat = reshape(filt, C, X*Y);  % (ncells x XY)
    
    resp = stim_flat * filters_flat' ;          % (T × C)

end




