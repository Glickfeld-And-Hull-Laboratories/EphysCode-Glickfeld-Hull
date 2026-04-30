function plotCCGs(arrRecordings)
    globals;
    globalsAll;

    sWhichPhases = [{repmat(BASELINE,length(arrRecordings),1)} {repmat('ALL-BLOCKERS',length(arrRecordings),1)}];
    
    cellStronglyVSWeaklyCoupledSpikeRates = cell(1,2);
    whichPair = {STRONGLY_COUPLED_PAIRS WEAKLY_COUPLED_PAIRS};
    cellDepths = cell(1,2);
    for iSW=1:2
        allSlaveSpikeRatesWPhase = [];
        for iPh=1:length(sWhichPhases)
            sWhichPhase = sWhichPhases{iPh};
            allSlaveSpikeRates = [];
            allDepths = [];
            for indRec = 1:length(arrRecordings)
                currentRecording = arrRecordings{1,indRec};
                indices = strfind(currentRecording.name,'_');
                recordingDay = extractBetween(currentRecording.name, indices(1)+1, length(currentRecording.name));
                units = currentRecording.unitGood;
                [flag, pos] = ismember(recordingDay,whichPair{iSW}(:,1));
                if pos
                    [idsMLIs, idsSSs] = whichPair{iSW}{pos,2:3};
            
                    for i=1:length(idsMLIs)
                        indSS = find([units.id]==idsSSs(i));
                        allDepths = [allDepths units(indSS).depth];
                        slaveSpikeRates = getRates(sWhichPhase(indRec,:), units, indSS, idsMLIs(i), DO_RATE_CORRECTED);
                        allSlaveSpikeRates = [allSlaveSpikeRates; slaveSpikeRates];
                    end
                end
            end
            allSlaveSpikeRatesWPhase = [allSlaveSpikeRatesWPhase allSlaveSpikeRates];
        end
        cellStronglyVSWeaklyCoupledSpikeRates{iSW} = allSlaveSpikeRatesWPhase;
        cellDepths{iSW} = allDepths;
    end
    
    xMax = X_MAX_CCG;
    binSize = BIN_SIZE_CCG;
    edges = -xMax-binSize:binSize:xMax+binSize;
   
    sLabel = {'StronglyCoupled', 'WeaklyCoupled'};

    for iSW=1:2
        % Columns 1:203 is for Baseline, 204:end for AllBlockers
        plotCCG(cellStronglyVSWeaklyCoupledSpikeRates{iSW}(:,1:length(edges)), cellStronglyVSWeaklyCoupledSpikeRates{iSW}(:,length(edges)+1:end), sLabel{iSW});
        
        allDepths = abs(cellDepths{iSW});
        ind500 = find(allDepths<=500);
        ind1000 = find(allDepths>500 & allDepths<=1000);
        ind1500 = find(allDepths>1000 & allDepths<=1500);
        indLast = find(allDepths>1500);
        plotCCG(cellStronglyVSWeaklyCoupledSpikeRates{iSW}(ind500,1:length(edges)), cellStronglyVSWeaklyCoupledSpikeRates{iSW}(ind500,length(edges)+1:end), [sLabel{iSW} ' lte500um']);
        plotCCG(cellStronglyVSWeaklyCoupledSpikeRates{iSW}(ind1000,1:length(edges)), cellStronglyVSWeaklyCoupledSpikeRates{iSW}(ind1000,length(edges)+1:end), [sLabel{iSW} ' 500to1000um']);
        plotCCG(cellStronglyVSWeaklyCoupledSpikeRates{iSW}(ind1500,1:length(edges)), cellStronglyVSWeaklyCoupledSpikeRates{iSW}(ind1500,length(edges)+1:end), [sLabel{iSW} ' 1000to1500um']);
    end

    allSpikeRates = cell2mat(cellStronglyVSWeaklyCoupledSpikeRates');
    plotCCG(allSpikeRates(:,1:length(edges)), allSpikeRates(:,length(edges)+1:end), 'AllPairs');
    allDepths = cell2mat(cellDepths);
    allDepths = abs(allDepths);
    ind500 = find(allDepths<=500);
    ind1000 = find(allDepths>500 & allDepths<=1000);
    ind1500 = find(allDepths>1000 & allDepths<1500);
    plotCCG(allSpikeRates(ind500,1:length(edges)), allSpikeRates(ind500,length(edges)+1:end), 'AllPairs lte500um');
    plotCCG(allSpikeRates(ind1000,1:length(edges)), allSpikeRates(ind1000,length(edges)+1:end), 'AllPairs 500to1000um');
    plotCCG(allSpikeRates(ind1500,1:length(edges)), allSpikeRates(ind1500,length(edges)+1:end), 'AllPairs 1000to1500um');
end