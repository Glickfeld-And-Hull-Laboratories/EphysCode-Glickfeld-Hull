% Function purpose to shuffle data to look at chance classification of
% PDS/CDS. To do that, I need to shuffle cell identity to correlate the
% grating tuning curve of one cell with the plaid responses of a randomly
% chosen cell. So this code takes in the avg_resp_dir variable and the
% index of cells that should be shuffled. Then outputs a new "avg_resp_dir"
% that has shuffled the association between grating and plaid responses.

% Input is expected to be avg_resp_dir, nCells x nDir x nMaskPhase x 
% (1: grating, 2: plaid) x (1: mean resp, 2: std)


% data=avgRespAll_marmEphys;
% ind = ind_marmEphys;

function [data_shuf] = shuffleGratingResponsesAcrossCells(data, ind)

    newIdx = ind(randsample(length(ind),length(ind)));
    data_shuf = [];

    for ic = 1:length(ind)
        data_shuf(ic,:,1,1,1) = data(newIdx(ic),:,1,1,1); % Take the grating direction tuning of the newIdx cell (mean)
        data_shuf(ic,:,1,1,2) = data(newIdx(ic),:,1,1,2); % Take the grating direction tuning of the newIdx cell (sem)
        data_shuf(ic,:,:,2,1) = data(ind(ic),:,:,2,1); % Keep the plaid direction tuning of the original cell (mean)
        data_shuf(ic,:,:,2,2) = data(ind(ic),:,:,2,2); % Keep the plaid direction tuning of the original cell (sem)
    end
end
