
function [avg_resp_dir, resp_ind_dir] = getResponses(resp, base);

    nCells = size(resp,1);
    nDirs = size(resp,2);
    nPhas = size(resp,3);
    nCon = size(resp,4);
    nTimeBins = 100; % 1s / 10ms
    
    resp_cell = cellfun(@(x) x, resp, 'UniformOutput', false); % Response period (200ms - 1s)
    base_cell = cellfun(@(x) x, base, 'UniformOutput', false); % Baseline period (-200ms - 0s)
    
    % Convert cell arrays to padded numeric arrays for computations
    maxTrials = max(cellfun(@(x) size(x,1), resp_cell(:))); % Find max trial count across conditions
    
    resp_numeric = nan(nCells, nDirs, nPhas, nCon, maxTrials, nTimeBins);
    base_numeric = nan(nCells, nDirs, nPhas, nCon, maxTrials, 20);
    
    for ic = 1:nCells
        for id = 1:nDirs
            for ip = 1:nPhas
                for ii = 1:nCon
                    if ~isempty(resp_cell{ic,id,ip,ii})
                        nTrials = size(resp_cell{ic,id,ip,ii},1);
                        resp_numeric(ic,id,ip,ii,1:nTrials,:) = resp_cell{ic,id,ip,ii}; % Assign real data
                    end
                    if ~isempty(base_cell{ic,id,ip,ii})
                        nTrials = size(base_cell{ic,id,ip,ii},1);
                        base_numeric(ic,id,ip,ii,1:nTrials,:) = base_cell{ic,id,ip,ii};
                    end
                end
            end
        end
    end
    
    % Compute mean and SEM (ignoring NaNs due to different trial counts)
    avg_resp_dir(:,:,:,:,1) = mean(sum(resp_numeric,6),5,'omitnan'); % Avg across time & trials to get rate in Hz (no scalar bc trial is 1s)
    avg_resp_dir(:,:,:,:,2) = std(sum(resp_numeric,6),0,5,'omitnan') ./ sqrt(size(resp_numeric,5)); % SEM
    
    resp_dir_tc = mean(resp_numeric,5,'omitnan'); % Avg across trials, for time-course
    resp_dir_tr = mean(resp_numeric,6,'omitnan'); % Avg across time, for trials
    
    % Find significantly responsive cells
    resp_cell_trials = sum(resp_numeric,6) / 100; % Spike rate per trial (Hz)
    base_cell_trials = sum(base_numeric,6) * 5 / 100; % Convert to Hz
    
    h_resp = nan(nCells, nDirs, nPhas, nCon);
    p_resp = nan(nCells, nDirs, nPhas, nCon);
    
    for id = 1:nDirs
        [h_resp(:,id,1,1), p_resp(:,id,1,1)] = ttest2(...
            squeeze(resp_cell_trials(:,id,1,1,:)),...
            squeeze(base_cell_trials(:,id,1,1,:)),...
            'dim',2, 'tail','right', 'alpha', 0.05./(nDirs*nPhas));
        
        for ip = 1:nPhas
            [h_resp(:,id,ip,2), p_resp(:,id,ip,2)] = ttest2(...
                squeeze(resp_cell_trials(:,id,ip,2,:)),...
                squeeze(base_cell_trials(:,id,ip,2,:)),...
                'dim',2, 'tail','right', 'alpha', 0.05./(nDirs*nPhas));
        end
    end
    
    resp_ind_dir = find(sum(h_resp(:,:,1,1),2)); % Significantly responsive to gratings

end
