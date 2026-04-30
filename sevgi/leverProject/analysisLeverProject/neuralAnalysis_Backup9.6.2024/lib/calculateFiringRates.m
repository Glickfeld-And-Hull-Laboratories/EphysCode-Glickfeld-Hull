%% SO - Hull lab 10/8/2024
% Calculates the instantaneous firing rates averaged over trials

function [spikeRates, responseType] = calculateFiringRates(cellSpikeTime, edges, binSize)
    arrSpikeTime = cell2mat(cellSpikeTime)';
    binCounts = histcounts(arrSpikeTime,edges); % optimumBinCount);
    spikeRates = binCounts/(length(cellSpikeTime)*binSize); % averaged over trials and specified bin

    responseType = classifyCellbyResponse(spikeRates, edges);
end