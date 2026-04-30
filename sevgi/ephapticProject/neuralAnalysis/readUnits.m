function [unitGood, unitMua, unitNoise, unitUnprocessed, unitAll, recordingLengthSecs] = readUnits()
    globals;
    unitsAndVarsPath = strcat(pathToUnitsDataFolder,UNITS_AND_VARS_FILE_NAME);

    imecMetaFiles = dir([pathToRecFolder '*imec*ap.meta']);
    imecMetaFile = imecMetaFiles(1);

    % Parse the corresponding metafile
    imecMeta = readMeta(imecMetaFile.name, pathToRecFolder);
    recordingLengthSecs = floor(str2num(imecMeta.fileTimeSecs));

    if ~exist(unitsAndVarsPath,'file')    
        spikeTimesSamples = double(readNPY([pathKS 'spike_times.npy']));
        %spikeTemplates = readNPY([pathKS 'spike_templates.npy']);
        spikeClusters = double(readNPY([pathKS 'spike_clusters.npy']));
        spikeAmplitudes = double(readNPY([pathKS 'amplitudes.npy']));

        % spikeClusters were shorter for 20230210 recording, so cut all of them to align them to the shortest one
        minLen = min(min(length(spikeTimesSamples), length(spikeClusters)),length(spikeAmplitudes));
        spikeTimesSamples = spikeTimesSamples(1:minLen);
        spikeClusters = spikeClusters(1:minLen);
        spikeAmplitudes = spikeAmplitudes(1:minLen);

        %clusterGroup = tdfread([pathKS 'cluster_group.tsv'],'\t');
        %clusterAmplitude = tdfread([pathKS 'cluster_Amplitude.tsv']);
        clusterInfo = tdfread([pathKS 'cluster_info.tsv'],'\t'); % Phy-updated version of clusters
        
        spkTimesSecs = spikeTimesSamples/samplingRate(imecMeta);
        % writeNPY(spikeTimesSecs, [pathKS 'spike_times_secs.npy']); % write spike times
        
        indGU = 1;
        indMUA = 1;
        indNoise = 1;
        indUnprocessed = 1;

        goodCellTypes = cell(1,length(NEURON_TYPES));
        for indGlobal=1:length(clusterInfo.cluster_id)
            clusterID = clusterInfo.cluster_id(indGlobal); %penetratedUnits(indGlobal);
            %indClusterInfo = find(clusterInfo.cluster_id==clusterID);
            if ~isempty(find(spikeClusters==clusterID,1)) %&& clusterInfo.custom_best_ch(indGlobal)~=FUNKY_CHANNEL % if there is any spike for this cluster (cos it may have been eliminated during SOFT_CUT/HARD_CUT)
                unit.id = clusterID;
                unit.spikeTimesSecs = spkTimesSecs(spikeClusters==clusterID);
                unit.amplitudes = spikeAmplitudes(spikeClusters==clusterID);                                
                unit.ch = clusterInfo.custom_best_ch(indGlobal);
                unit.depth = (-1*depthDuringRecording + clusterInfo.depth(indGlobal)); % tipLength excluded since I zeroed after I fully penetrated the tip  % convert it other way around cos clusterInfo.depth from Phyllum is just the distance from the first channel
                unit.fr = clusterInfo.fr(indGlobal);
                unit.clusterAmpl = clusterInfo.Amplitude(indGlobal);
                groupInfo = clusterInfo.group(indGlobal,:);
                if ~isnan(groupInfo)
                    unit.group = strtrim(groupInfo);
                else
                    unit.group = '';
                end
                unit.nSpikes = clusterInfo.n_spikes(indGlobal);
                unit.SNR = clusterInfo.SNR(indGlobal);
                if isfield(clusterInfo,'C4_confidence_ratio') && clusterInfo.C4_confidence_ratio(indGlobal)>2 
                    unit.neuronType = replace(strtrim(clusterInfo.C4_predicted_cell_type(indGlobal,:)),'_',' '); % for visualization on the plot title % final_neuron_type
                else
                    unit.neuronType = '';
                end
                unit.neuronSubType = '';
                if isfield(clusterInfo,'C4_layer')
                    unit.layer = replace(strtrim(clusterInfo.C4_layer(indGlobal,:)),'_',' ');
                else
                    unit.layer = '';
                end
                unit.KSLabel = strtrim(clusterInfo.KSLabel(indGlobal,:));

                % Open up the fields for future saving
                unit.waveForms = UNDEFINED;
                unit.waveFormsBaseline = UNDEFINED;
                unit.waveForms1stDrug = UNDEFINED;
                unit.waveForms2ndDrug = UNDEFINED;

                if strcmp(unit.group,'good') && unit.depth < 0 && unit.depth >= DEPTH_OF_CEREBELLAR_CORTEX % In the cerebellar cortex % No need the rest! There is only one condition to be GOOD! (strcmp(clusterInfo.KSLabel(indGlobal,:),'good') && ~strcmp(unit.group,'noise') && ~strcmp(unit.group,'mua')) ||
                    unitGood(indGU) = unit;
                    indGU = indGU +1;
                    whichCell = strcmp(NEURON_TYPES,unit.neuronType);
                    goodCellTypes{whichCell} = [goodCellTypes{whichCell} ' ' num2str(unit.id)];
                elseif strcmp(unit.group,'mua') || unit.depth < DEPTH_OF_CEREBELLAR_CORTEX % Deeper than the cerebellar cortex, maybe DCN % No need the rest! (strcmp(clusterInfo.KSLabel(indGlobal,:),'mua ') && 
                    unitMua(indMUA) = unit;
                    indMUA = indMUA +1;
                elseif strcmp(unit.group,'noise') % Noise
                    unitNoise(indNoise) = unit;
                    indNoise = indNoise +1;
                else % everything else other than those 3 conditions above should be yet untouched units!
                    unitUnprocessed(indUnprocessed) = unit;
                    indUnprocessed = indUnprocessed +1;
                end
                unitAll(indGlobal) = unit; % To print all cluster refractoriness for helping curation
            else
                logger.info('readUnits', ['Mark unit=' num2str(unit.id) ' as NOISE cos it is deeper than DCN!!']);
            end
        end
        
        str = '';
        if exist('unitGood') && ~isempty(unitGood)
            str = [num2str(length(unitGood)) ' units are selected for analysis! '];
            sTypes = 'numOfCells ';
            for iTypes=1:length(goodCellTypes)
                if ~isempty(goodCellTypes{iTypes})
                    arrSplit = strsplit(goodCellTypes{iTypes});
                    sTypes = [sTypes NEURON_TYPES{iTypes} '=' num2str(length(arrSplit)-1) '(ids=' goodCellTypes{iTypes} ') '];
                end
            end
            str = [str sTypes];
        end
        if exist('unitMua') && ~isempty(unitMua)
            str = [str 'The rest are mua=' num2str(length(unitMua))];
        end
        if exist('unitNoise') && ~isempty(unitNoise)
            str = [str ' and noise=' num2str(length(unitNoise))];
        end
        if exist('unitUnprocessed') && ~isempty(unitUnprocessed)
            str = [str ' and unprocessed=' num2str(length(unitUnprocessed))];
        end

        logger.info('readUnits', str);
    else
        load(unitsAndVarsPath,'unitGood', 'unitMua', 'unitNoise', 'unitUnprocessed','unitAll');
        str = ['Previously saved ' ];
        if exist('unitGood') && ~isempty(unitGood)
            goodCellTypes = cell(1,length(NEURON_TYPES));
            for indGood = 1:length(unitGood)
                unit = unitGood(indGood);
                whichCell = strcmp(NEURON_TYPES,unit.neuronType);
                goodCellTypes{whichCell} = [goodCellTypes{whichCell} ' ' num2str(unit.id)];
            end

            str = [str num2str(length(unitGood)) ' good units are loaded for analysis! '];
            sTypes = 'numOfCells ';
            for iTypes=1:length(goodCellTypes)
                if ~isempty(goodCellTypes{iTypes})
                    arrSplit = strsplit(goodCellTypes{iTypes});
                    sTypes = [sTypes NEURON_TYPES{iTypes} '=' num2str(length(arrSplit)-1) '(ids=' goodCellTypes{iTypes} ') '];
                end
            end
            str = [str sTypes];
        end
        if exist('unitMua') && ~isempty(unitMua)
            str = [str ' The rest are mua=' num2str(length(unitMua))];
        end
        if exist('unitNoise') && ~isempty(unitNoise)
            str = [str ' and noise=' num2str(length(unitNoise))];        
        end
        if exist('unitUnprocessed') && ~isempty(unitUnprocessed)
            str = [str ' and unprocessed=' num2str(length(unitUnprocessed))];       
        end
        if exist('unitAll') && ~isempty(unitAll)
            str = [str ' and all=' num2str(length(unitAll))];       
        end
        loaded = 1;
        logger.info('readUnits', str);
    end

    if ~exist('unitGood') || isempty(unitGood)
        unitGood=[];
    end

    if ~exist('unitMua') || isempty(unitMua)
        unitMua=[];
    end

    if ~exist('unitNoise') || isempty(unitNoise)
        unitNoise=[];
    end

    if ~exist('unitUnprocessed') || isempty(unitUnprocessed)
        unitUnprocessed=[];
    end

    if ~exist('unitAll') || isempty(unitAll)
        unitAll=[];
    end
end