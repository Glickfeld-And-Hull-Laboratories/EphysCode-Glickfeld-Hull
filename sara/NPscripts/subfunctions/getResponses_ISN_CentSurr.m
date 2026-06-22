
function [avg_resp_dir, resp_ind_dir] = getResponses_ISN_CentSurr(resp, base)

    nCells = size(resp,1);
    nDirs  = size(resp,2);
    nCon   = size(resp,3);

    nTimeBins = 10; % 0.1s / 10ms
    nBaseBins = 20;

    % Find max trials across all conditions
    maxTrials = max(cellfun(@(x) size(x,1), resp(:)));

    % Preallocate
    resp_numeric = nan(nCells, nDirs, nCon, maxTrials, nTimeBins);
    base_numeric = nan(nCells, nDirs, nCon, maxTrials, nBaseBins);

    % Fill numeric arrays
    for ic = 1:nCells
        for id = 1:nDirs
            for ii = 1:nCon

                if ~isempty(resp{ic,id,ii})
                    nTrials = size(resp{ic,id,ii},1);
                    resp_numeric(ic,id,ii,1:nTrials,:) = resp{ic,id,ii};
                end

                if ~isempty(base{ic,id,ii})
                    nTrials = size(base{ic,id,ii},1);
                    base_numeric(ic,id,ii,1:nTrials,:) = base{ic,id,ii};
                end

            end
        end
    end

    % === Compute mean + SEM ===
    spikeCounts = sum(resp_numeric,5); % sum over time (1s window)

    avg_resp_dir(:,:,:,1) = mean(spikeCounts,4,'omitnan'); % mean across trials
    avg_resp_dir(:,:,:,2) = std(spikeCounts,0,4,'omitnan') ./ sqrt(sum(~isnan(spikeCounts),4));

    % === Trial-wise rates ===
    resp_trials = spikeCounts; % spikes/sec (since 1s window)
    base_trials = sum(base_numeric,5) * 5; % convert 0.2s → Hz

    % === Stats ===
    h_resp = nan(nCells, nDirs, nCon);
    p_resp = nan(nCells, nDirs, nCon);

    for id = 1:nDirs
        for ii = 1:nCon

            [h_resp(:,id,ii), p_resp(:,id,ii)] = ttest2( ...
                squeeze(resp_trials(:,id,ii,:)), ...
                squeeze(base_trials(:,id,ii,:)), ...
                'dim',2, ...
                'tail','right', ...
                'alpha', 0.05/(nDirs*nCon) );

        end
    end

    % === Define responsive cells (example: iso condition only = cond 1) ===
    resp_ind_dir = find(sum(h_resp(:,:,1),2));

end