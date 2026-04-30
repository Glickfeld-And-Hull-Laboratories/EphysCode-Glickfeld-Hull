function [unitGood, unitMua, unitNoise, recordingLengthSecs] = readUnits()
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

        for indGlobal=1:length(clusterInfo.cluster_id)
            clusterID = clusterInfo.cluster_id(indGlobal); %penetratedUnits(indGlobal);
            %indClusterInfo = find(clusterInfo.cluster_id==clusterID);
            if ~isempty(find(spikeClusters==clusterID,1)) && clusterInfo.custom_best_ch(indGlobal)~=FUNKY_CHANNEL % if there is any spike for this cluster (cos it may have been eliminated during SOFT_CUT/HARD_CUT)
                unit.id = clusterID;
                unit.spikeTimesSecs = spkTimesSecs(spikeClusters==clusterID);
                unit.amplitudes = spikeAmplitudes(spikeClusters==clusterID);                                
                unit.ch = clusterInfo.custom_best_ch(indGlobal);
                unit.depth = (-1*depthDuringRecording + tipLength + clusterInfo.depth(indGlobal)); % convert it other way around cos clusterInfo.depth from Phyllum is just the distance from the first channel
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
                unit.neuronType = replace(strtrim(clusterInfo.final_neuron_type(indGlobal,:)),'_',' '); % for visualization on the plot title
                if isempty(unit.neuronType)
                    unit.neuronType = 'Unknown';
                end
                unit.layer = replace(strtrim(clusterInfo.final_neuron_layer(indGlobal,:)),'_',' ');
                unit.KSLabel = strtrim(clusterInfo.KSLabel(indGlobal,:));

                % Open up the fields for future saving
                unit.waveForms = UNDEFINED;
                unit.waveFormsBaseline = UNDEFINED;
                unit.waveForms1stDrug = UNDEFINED;
                unit.waveForms2ndDrug = UNDEFINED;

                if ((strcmp(clusterInfo.KSLabel(indGlobal,:),'good') && ~strcmp(unit.group,'noise') && ~strcmp(unit.group,'mua')) || strcmp(unit.group,'good'))
                    unitGood(indGU) = unit;
                    indGU = indGU +1;
                elseif (strcmp(clusterInfo.KSLabel(indGlobal,:),'mua ') && ~strcmp(unit.group,'noise'))
                    unitMua(indMUA) = unit;
                    indMUA = indMUA +1;
                else % Noise
                    unitNoise(indNoise) = unit;
                    indNoise = indNoise +1;
                end
            end
        end
        
         logger.info('readUnits', [num2str(length(unitGood)) ' units are selected for analysis!']);
    else
        load(unitsAndVarsPath,'unitGood', 'unitMua', 'unitNoise');
        logger.info('readUnits', ['Previously saved ' num2str(length(unitGood)) ' units are loaded for analysis!']);        
    end
end