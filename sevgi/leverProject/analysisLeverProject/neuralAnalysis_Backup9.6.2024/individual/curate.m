function curate(unitIdsSingle, unitIdsMulti, unitIdsNoise)
    globals;

    clusterInfo = tdfread([pathKS 'cluster_info.tsv'],'\t'); % Phy-updated version of clusters
    %clusterGroup = tdfread([pathKS 'cluster_group.tsv'],'\t'); % Phy-updated version of clusters

    clusterInfoBackupFileName = [pathKS 'cluster_info_backup.tsv'];
    clusterGroupBackupFileName = [pathKS 'cluster_group_backup.tsv'];
    
    if ~isfile(clusterInfoBackupFileName)
        copyfile([pathKS 'cluster_info.tsv'],clusterInfoBackupFileName);
    end

    if ~isfile(clusterGroupBackupFileName)
        copyfile([pathKS 'cluster_group.tsv'],clusterGroupBackupFileName);
    end

    if isfield(clusterInfo,'C4_model_votes')
        % Since it reads C4_model_votes as integer and divides it, correct this field by making it again string
        indsNotNaN = find(~isnan(clusterInfo.C4_model_votes));
        indsNaN = find(isnan(clusterInfo.C4_model_votes));
        newField = char(ones(size(clusterInfo.C4_model_votes,1),1)*'         ');
        newFieldNotNaN = [num2str(clusterInfo.C4_model_votes(indsNotNaN,:)*2020,'%d') repmat('/2020',length(indsNotNaN),1)];
        newField(indsNotNaN,:) = newFieldNotNaN;
        %newField(indsNaN,:) = repmat('         ',length(indsNaN),1);
        clusterInfo = rmfield(clusterInfo,'C4_model_votes');
        clusterInfo.C4_model_votes = newField;
    end
    
    %%%%%%%%%%%%%%%% Update cluster_info.tsv %%%%%%%%%%%%%%%%%%%%
    newClusterIds = sort([unitIdsSingle unitIdsMulti unitIdsNoise]);
    newInfoGroups = char(ones(length(newClusterIds),1)*'     ');

    [~,clusterIndsGood,~] = intersect(clusterInfo.cluster_id, unitIdsSingle);    
    newInfoGroups(clusterIndsGood,:) = repmat(UNIT_GROUP_GOOD,length(clusterIndsGood),1);        
    [~,clusterIndsMua,~] = intersect(clusterInfo.cluster_id, unitIdsMulti);
    newInfoGroups(clusterIndsMua,:) = repmat(UNIT_GROUP_MUA,length(clusterIndsMua),1);        
    [~,clusterIndsNoise,~] = intersect(clusterInfo.cluster_id, unitIdsNoise);
    newInfoGroups(clusterIndsNoise,:) = repmat(UNIT_GROUP_NOISE,length(clusterIndsNoise),1);
    clusterInfo = rmfield(clusterInfo,'group');
    clusterInfo.group = newInfoGroups;
    stillUnprocessedUnitIds = find(ismember(clusterInfo.group,'     ','rows'));
    logger.info('curate', ['Still unsorted units:' num2str(clusterInfo.cluster_id(stillUnprocessedUnitIds)','%.0f ')]);

    %%%%%%%%%%%%%%%% Update cluster_group.tsv %%%%%%%%%%%%%%%%%%%%
    newGroups = char(ones(length(newClusterIds),1)*'     ');
    [~,indGood,~] = intersect(newClusterIds,unitIdsSingle);
    newGroups(indGood,:) = repmat(UNIT_GROUP_GOOD,length(indGood),1);
    [~,indMua,~] = intersect(newClusterIds,unitIdsMulti);
    newGroups(indMua,:) = repmat(UNIT_GROUP_MUA,length(indMua),1);
    [~,indNoise,~] = intersect(newClusterIds,unitIdsNoise);
    newGroups(indNoise,:) = repmat(UNIT_GROUP_NOISE,length(indNoise),1);
    newClusterGroup.cluster_id = newClusterIds';
    newClusterGroup.group = newGroups;

    tdfwrite([pathKS 'cluster_info.tsv'],clusterInfo);
    tdfwrite([pathKS 'cluster_group.tsv'],newClusterGroup);
    logger.info('printRefractoriness', ['******** CURATION IS DONE: Good:' num2str(unitIdsSingle) ' Multi:' num2str(unitIdsMulti) ' Noise:' num2str(unitIdsNoise) ' ********']);
end