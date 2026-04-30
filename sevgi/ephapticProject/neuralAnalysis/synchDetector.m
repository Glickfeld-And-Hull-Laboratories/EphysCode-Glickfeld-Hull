% Checks to see if coincident MLI spiking around the same PC has a stronger effect than non-coincident spiking
% SO - Hull lab 8/20/2025
function synchDetector(unitMLIA, unitMLIB, unitSS, unitGoodSorted)


    globals;
    needToSave = 0;
    margin = 0.5; % +-0.5ms % Synch margin
    binSize = 1; % 1 ms 

    unitMLIASpikeTimesMsec = unitMLIA.spikeTimesSecs*1000;
    unitMLIBSpikeTimesMsec = unitMLIB.spikeTimesSecs*1000;

    unitMLIASpikeTimesMsecMin = unitMLIASpikeTimesMsec-0.5;
    unitMLIASpikeTimesMsecMax = unitMLIASpikeTimesMsec+0.5;
    
    % arrange the edges around each spike of MLI1A, we are not interested other non-synch spikes cos the rest will be non-synch ones
    edgesAroundMinMax = sort([unitMLIASpikeTimesMsecMin; unitMLIASpikeTimesMsecMax]);
    
    % Assign each spike of MLI1B to a bin
    % bin is an array of the same size as unitMLIBSpikeTimesMsec whose elements are the bin indices for the corresponding elements in unitMLIBSpikeTimesMsec
    [binSpikeCounts,~,binIndices] = histcounts(unitMLIBSpikeTimesMsec, edgesAroundMinMax); 
    
    % find only odd bins since we arranged edges around the master spikes, so edge_{2k-1} will always have the synchronous spikes while edge_{2k} will have the
    % rest of unsynchronous spikes
    oddFlags = mod(binIndices,2)==1;
    binIndicesOddIndices = find(oddFlags);
    binIndicesOddValues = binIndices(oddFlags);
    % Maybe we don't need these two lines below since binIndicesOddValues should only include nonzero spikes
%     unitMLIBSpikeIndicesOfOddNonZeroValues = binIndicesOddIndices(binSpikeCounts(binIndicesOddValues)>0);
%     edgeIndicesOfOddNonZeroValues = binIndicesOddValues(binSpikeCounts(binIndicesOddValues)>0); % should have some spikes, just a sanity check on binIndices
%     
    unitMLIASynchedSpikeTimes = edgesAroundMinMax(binIndicesOddValues)+margin;    
    [~, unitMLIASynchedSpikeIndices, ~] = intersect(unitMLIASpikeTimesMsec, unitMLIASynchedSpikeTimes);
    unitMLIBSynchedSpikeIndices = binIndicesOddIndices;

    unitMasterA_SynchedSpikeTimes = unitMLIASynchedSpikeTimes/1000; % should be in sec. before calling correlogram
    unitMasterB_SynchedSpikeTimes = unitMLIBSpikeTimesMsec(binIndicesOddIndices)/1000;

    unSynchMasterAIndices = setdiff(1:length(unitMLIASpikeTimesMsec),unitMLIASynchedSpikeIndices);
    unitMasterA_UnSynchedSpikeTimes = unitMLIASpikeTimesMsec(unSynchMasterAIndices)/1000;
    unSynchMasterBIndices = setdiff(1:length(unitMLIBSpikeTimesMsec),unitMLIBSynchedSpikeIndices);
    unitMasterB_UnSynchedSpikeTimes = unitMLIBSpikeTimesMsec(unSynchMasterBIndices)/1000;

    logger.info('synchDetector', ['Found coinciding spikes!! ' SS_MLI ' for ' NEURON_TYPE_SS '_' num2str(unitSS.id) '(' num2str(unitSS.depth) 'um) against ' ...
        NEURON_TYPE_MLI '_' num2str(unitMLIA.id) '(' num2str(unitMLIA.depth) 'um) and ' num2str(unitMLIB.id) '(' num2str(unitMLIB.depth) 'um)']);
                    
    synchedCCGsPlotting(unitMLIA, unitMLIB, unitMasterA_SynchedSpikeTimes, unitMasterA_UnSynchedSpikeTimes, ...
        unitMasterB_SynchedSpikeTimes, unitMasterB_UnSynchedSpikeTimes, unitSS, unitGoodSorted, BASELINE);

    synchedCCGsPlotting(unitMLIA, unitMLIB, unitMasterA_SynchedSpikeTimes, unitMasterA_UnSynchedSpikeTimes, ...
        unitMasterB_SynchedSpikeTimes, unitMasterB_UnSynchedSpikeTimes, unitSS, unitGoodSorted, FIRST_DRUG);

    if ~isempty(MOMENT_OF_2ND_DRUG_PUT_IN)
        synchedCCGsPlotting(unitMLIA, unitMLIB, unitMasterA_SynchedSpikeTimes, unitMasterA_UnSynchedSpikeTimes, ...
            unitMasterB_SynchedSpikeTimes, unitMasterB_UnSynchedSpikeTimes, unitSS, unitGoodSorted, SECOND_DRUG);
    end    
end