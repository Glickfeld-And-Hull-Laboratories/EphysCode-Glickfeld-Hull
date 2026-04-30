function [unitGood, unitMua, unitNoise, recordingLengthSecs] = readDartSortedUnits()
    globals;
    unitsAndVarsPath = strcat(pathToUnitsDataFolder,UNITS_AND_VARS_FILE_NAME);
    
    unitMua = [];
    unitNoise = [];

    imecMetaFiles = dir([pathToRecFolder '*imec*ap.meta']);
    imecMetaFile = imecMetaFiles(1);

    % Parse the corresponding metafile
    imecMeta = readMeta(imecMetaFile.name, pathToRecFolder);
    recordingLengthSecs = floor(str2num(imecMeta.fileTimeSecs));


    if ~exist(unitsAndVarsPath,'file')    
        spikeTrain = readNPY([pathDartSorted 'spike_train.npy']);
        channels = readNPY([pathDartSorted 'channels.npy']);
        spikeTimesSamples = double(spikeTrain(:,1));
        spikeClusters = double(spikeTrain(:,2));
        clusters = sort(unique(spikeClusters));
        spkTimesSecs = spikeTimesSamples/samplingRate(imecMeta);
        
        indGU = 1;
        indMUA = 1;
        indNoise = 1;

        for indGlobal=1:length(clusters)
            clusterID = clusters(indGlobal);            
            if ~isempty(find(spikeClusters==clusterID,1)) %&& clusterInfo.custom_best_ch(indGlobal)~=FUNKY_CHANNEL % if there is any spike for this cluster (cos it may have been eliminated during SOFT_CUT/HARD_CUT)
                unit.id = clusterID;
                unit.spikeTimesSecs = spkTimesSecs(spikeClusters==clusterID);
                unit.amplitudes = ''; %spikeAmplitudes(spikeClusters==clusterID);                                
                bestCh = channels(spikeClusters==clusterID);
                bestCh = unique(bestCh);
                if length(bestCh)>1
                    logger.info('readDartSortedUnits',['There are more than one best channel {' num2str(bestCh','%.f ') '} for unit=' num2str(unit.id)]);
                end
                unit.ch = bestCh(1);

                unit.depth = -1; %(-1*depthDuringRecording + tipLength + clusterInfo.depth(indGlobal)); % convert it other way around cos clusterInfo.depth from Phyllum is just the distance from the first channel
                unit.neuronType = '';
                unit.layer = ''; %replace(strtrim(clusterInfo.final_neuron_layer(indGlobal,:)),'_',' ');

                % Open up the fields for future saving
                unit.waveForms = UNDEFINED;
                unit.waveFormsBaseline = UNDEFINED;
                unit.waveForms1stDrug = UNDEFINED;
                unit.waveForms2ndDrug = UNDEFINED;
                unit.spikeTimesOfAmplitudes = [];
                unit.amplitudePerChannel = [];

%                 if ((strcmp(clusterInfo.KSLabel(indGlobal,:),'good') && ~strcmp(unit.group,'noise') && ~strcmp(unit.group,'mua')) || strcmp(unit.group,'good'))
                    unitGood(indGU) = unit;
                    indGU = indGU +1;
%                 elseif (strcmp(clusterInfo.KSLabel(indGlobal,:),'mua ') && ~strcmp(unit.group,'noise'))
%                     unitMua(indMUA) = unit;
%                     indMUA = indMUA +1;
%                 else % Noise
%                     unitNoise(indNoise) = unit;
%                     indNoise = indNoise +1;
%                 end
            end
        end
        
        logger.info('readUnits', [num2str(length(unitGood)) ' units are selected for analysis!']);
    else
        load(unitsAndVarsPath,'unitGood');
        logger.info('readUnits', ['Previously saved ' num2str(length(unitGood)) ' units are loaded for analysis!']);
    end
end