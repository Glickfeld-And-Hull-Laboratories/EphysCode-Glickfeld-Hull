%
% Compute F1/F0 from spiking response
% 
% ========================
% Inputs
%   - resp (cell array), size [nUnits x nDirs x nPhas x 2 (grating/plaid)]. Each element is then nTrials x Time (in bins of 10 ms)
% 
% Outputs
%   - f0mat (matrix), size [nUnits x nDirs]
%   - f1mat (matrix), size [nUnits x nDirs]
%   - f1overf0mat (matrix), size [nUnits x nDirs]
%


function [f0mat, f1mat, f1overf0mat] = getF1_tutorial(gratingRespMatrix)

% Hard code some variables
    T_stim      = 2;           % stimulus duration (s)
    stimFreq    = 1;          % Hz
    binSize     = 0.01;       % 10 ms bins
    edges       = 0:binSize:T_stim;
    Fs          = 1/binSize;        % sampling frequency (Hz)
    nBins       = numel(edges)-1;    % number of bins

% Size of your data
    [nUnits, nDirs] = size(gratingRespMatrix);

% Initialize result matrices
    f0mat = zeros(nUnits, nDirs);
    f1mat = zeros(nUnits, nDirs);
    f1overf0mat = zeros(nUnits, nDirs);

% Compute F0, F1
    for ic = 1:nUnits
        for id = 1:nDirs
            % Retrieve cell array of spike trains for this unit & direction
            trials = gratingRespMatrix{ic, id};
            nTrials = numel(trials);
    
            psthCounts = zeros(1, nBins);   % Accumulate PSTH
            
            for t = 1:nTrials
                spikes = trials{t};
                counts = histcounts(spikes, edges);
                psthCounts = psthCounts + counts;
            end
             
            psthCounts = psthCounts / nTrials;  % Average across trials
            psthRate = psthCounts / binSize;    % Convert to firing rate (spikes/s)
    
            F0 = mean(psthRate);    % Compute F0
            fftVals = fft(psthRate) / nBins; % FFT
            f = (0:nBins-1)*(Fs/nBins);
    
            % Compute F1 amplitude
            [~, idx] = min(abs(f - stimFreq));   % Find index closest to 2 Hz
            F1 = 2 * abs(fftVals(idx));   % factor 2 for single-sided amplitude (essentially, double so you account for the true amplitude of the sinewave)
    
            % Save results
            f0mat(ic, id) = F0;
            f1mat(ic, id) = F1;
            f1overf0mat(ic, id) = F1 / F0;
        end
    end
end