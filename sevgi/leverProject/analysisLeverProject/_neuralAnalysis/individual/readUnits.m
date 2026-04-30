function [unitGood, unitMua] = readUnits()
    globals;
    unitsAndVarsPath = strcat(pathToUnitsDataFolder,UNITS_AND_VARS_FILE_NAME);
    
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

        imecBinFiles = dir([pathToRecFolder '*imec*ap.bin']);
        imecBinFile = imecBinFiles(1);

        % Parse the corresponding metafile
        imecMeta = readMeta(imecBinFile.name, pathToRecFolder);

        spkTimesSecs = spikeTimesSamples/samplingRate(imecMeta);
        % writeNPY(spikeTimesSecs, [pathKS 'spike_times_secs.npy']); % write spike times

        if SOFT_CUT~=Inf    % There could be a soft cut of the recording
            if SOFT_CUT_PARTITION==1 % Get the first part of the recording
                indTimes = find(spkTimesSecs>0 & spkTimesSecs<=SOFT_CUT);
            else % get the rest
                indTimes = find(spkTimesSecs>SOFT_CUT);
            end
            spikeClusters = spikeClusters(indTimes);
            spikeAmplitudes = spikeAmplitudes(indTimes);
            %spikeTimesSamples = spikeTimesSamples(indTimes);
            spkTimesSecs = spkTimesSecs(indTimes);
        elseif HARD_CUT~=Inf    % There could be a soft cut of the recording
            if HARD_CUT_PARTITION==1 % Get the first part of the recording
                indTimes = find(spkTimesSecs>0 & spkTimesSecs<=HARD_CUT);
            else % get the rest
                indTimes = find(spkTimesSecs>HARD_CUT);
            end
            spikeClusters = spikeClusters(indTimes);
            spikeAmplitudes = spikeAmplitudes(indTimes);
            %spikeTimesSamples = spikeTimesSamples(indTimes);
            spkTimesSecs = spkTimesSecs(indTimes);        
        end

        indGU = 1;
        indMUA = 1;

        % NO NEED to this control, I already eliminate them before Kilosorting
        % Be sure about you're analyzing the channels inside the cerebellum
        %isPenetrated = clusterInfo.depth<=(depthDuringRecording-tipLength);
        %penetratedUnits = clusterInfo.cluster_id(isPenetrated);
        for indGlobal=1:length(clusterInfo.cluster_id)
            clusterID = clusterInfo.cluster_id(indGlobal); %penetratedUnits(indGlobal);
            %indClusterInfo = find(clusterInfo.cluster_id==clusterID);
            if ~isempty(find(spikeClusters==clusterID,1)) % if there is any spike for this cluster (cos it may have been eliminated during SOFT_CUT/HARD_CUT)
                unit.id = clusterID;
                unit.spikeTimesSecs = spkTimesSecs(spikeClusters==clusterID);
                unit.amplitudes = spikeAmplitudes(spikeClusters==clusterID);                                
                unit.ch = clusterInfo.ch(indGlobal);
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
                unit.layer = replace(strtrim(clusterInfo.final_neuron_layer(indGlobal,:)),'_',' ');
                unit.KSLabel = strtrim(clusterInfo.KSLabel(indGlobal,:));

                if ((strcmp(clusterInfo.KSLabel(indGlobal,:),'good') && ~strcmp(unit.group,'noise') && ~strcmp(unit.group,'mua')) || strcmp(unit.group,'good'))
                    unitGood(indGU) = unit;
                    indGU = indGU +1;
                elseif (strcmp(clusterInfo.KSLabel(indGlobal,:),'mua '))
                    unitMua(indMUA) = unit;
                    indMUA = indMUA +1;
                end
            end
        end
        
         logger.info('readUnits', [num2str(length(unitGood)) ' units are selected for analysis!']);
    else
        load(unitsAndVarsPath,'unitGood', 'unitMua');
        logger.info('readUnits', ['Previously saved ' num2str(length(unitGood)) ' units are loaded for analysis!']);        
    end
end