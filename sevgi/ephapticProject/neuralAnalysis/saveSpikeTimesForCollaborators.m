function saveSpikeTimesForCollaborators(unitsOfInterest)
    globals;

    indInternal = 1;
    for ind=1:length(unitsOfInterest)
        units(indInternal).id = unitsOfInterest(ind).id;
        units(indInternal).neuronType = unitsOfInterest(ind).neuronType;
        units(indInternal).neuronSubType = unitsOfInterest(ind).neuronSubType;
        units(indInternal).spikeTimesSecs = unitsOfInterest(ind).spikeTimesSecs;
        indInternal = indInternal + 1;
    end

    unitsPath = [pathToCollaboratorsFolder UNITS_FILE_NAME];
    if exist(unitsPath,'file')
        oldData = load(unitPairsPath);
        units = [oldData.units units];
    end
    save(unitsPath,'units','-v7.3');
    logger.info('saveSpikeTimesForCollaborators', ['Saved ' num2str(length(unitsOfInterest)) ' unitsOfInterest for collaborators']);
end