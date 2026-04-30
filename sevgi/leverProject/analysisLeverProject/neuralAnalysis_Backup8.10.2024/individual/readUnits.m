function [unitGood, unitMua, unitNoise, unitUnprocessed, loaded] = readUnits()
    globals;
    unitsAndVarsPath = strcat(pathToUnitsDataFolder,UNITS_AND_VARS_FILE_NAME);

    loaded = 0;

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
        cellTypeInfo = tdfread([pathKS 'cluster_C4_predicted_cell_type.tsv'],'\t');

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
        indNoise = 1;
        indUnprocessed = 1;

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
                if clusterInfo.C4_confidence_ratio(indGlobal)>2
                    unit.neuronType = replace(strtrim(clusterInfo.C4_predicted_cell_type(indGlobal,:)),'_',' '); % for visualization on the plot title % final_neuron_type
                else
                    unit.neuronType = '';
                end
                unit.layer = replace(strtrim(clusterInfo.final_neuron_layer(indGlobal,:)),'_',' ');
                unit.KSLabel = strtrim(clusterInfo.KSLabel(indGlobal,:));

                unitUnprocessed=[];
                if strcmp(unit.group,'good') % No need the rest! There is only one condition to be GOOD! (strcmp(clusterInfo.KSLabel(indGlobal,:),'good') && ~strcmp(unit.group,'noise') && ~strcmp(unit.group,'mua')) ||
                    unitGood(indGU) = unit;
                    indGU = indGU +1;
                elseif strcmp(unit.group,'mua') % No need the rest! (strcmp(clusterInfo.KSLabel(indGlobal,:),'mua ') && 
                    unitMua(indMUA) = unit;
                    indMUA = indMUA +1;
                elseif strcmp(unit.group,'noise') % Noise
                    unitNoise(indNoise) = unit;
                    indNoise = indNoise +1;
                else % everything else other than those 3 conditions above should be yet untouched units!
                    unitUnprocessed(indUnprocessed) = unit;
                    indUnprocessed = indUnprocessed +1;
                end
            end
        end

% It's already up there!        
%         for indGlobal=1:length(cellTypeInfo.cluster_id)
%             clusterID = cellTypeInfo.cluster_id(indGlobal);
%             predictedCellType = strtrim(cellTypeInfo.C4_predicted_cell_type(indGlobal,:));
%             
%             unit = unitGood(find([unitGood.id]==clusterID));
%             if isempty(unit)
%                 unit = unitMua(find([unitMua.id]==clusterID));
%                 if isempty(unit)
%                     unit = unitNoise(find([unitNoise.id]==clusterID));
%                 end
%             end
%             if ~isempty(unit) 
%                 unit.neuronType = predictedCellType;
%             end
%         end
        
        logger.info('readUnits', [num2str(length(unitGood)) ' units are selected for analysis! The rest are mua=' num2str(length(unitMua)) ' and noise=' num2str(length(unitNoise)) ' and unprocessed=' num2str(length(unitUnprocessed))]);
    else        
        load(unitsAndVarsPath,'unitGood', 'unitMua', 'unitNoise', 'unitUnprocessed');
        str = ['Previously saved ' num2str(length(unitGood)) ' good units are loaded for analysis!'];
        if ~isempty(unitMua)
            str = [str ' The rest are mua=' num2str(length(unitMua))];
        end
        if exist('unitNoise') && ~isempty(unitNoise)
            str = [str ' and noise=' num2str(length(unitNoise))];
        else
            unitNoise=[];
        end
        if exist('unitUnprocessed') && ~isempty(unitUnprocessed)
            str = [str ' and unprocessed=' num2str(length(unitUnprocessed))];
        else
            unitUnprocessed=[];
        end
        loaded = 1;
        logger.info('readUnits', str);        
    end
end