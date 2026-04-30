% Gets requested neuron pairs from the dataset regarding the max distance criterion
function pairs = findPairs(units, pairType, neuronType1, neuronType2, maxDistance, searchByUnit)
    globals;
    
    pairs=[];
    
    if isempty(searchByUnit) % search all data set for all possible pairs
        for indX=1:length(units)
            if strcmp(units(indX).neuronType,neuronType1) % found the first type
                for indY=1:length(units)
                    if strcmp(units(indY).neuronType,neuronType2) && units(indY).id~=units(indX).id % found the second type
                        if abs(units(indX).depth-units(indY).depth)<=maxDistance
                            pairs = [pairs; [units(indX).id units(indY).id]]; % found a candidate pair to compare
                        end
                    end
                end    
            end
        end
        
        if pairType == PAIR_TYPE_CS_SS % && strcmp(neuronType1,NEURON_TYPE_DCS)
            whichToAdd = find(~all(ismember(PAIRED_CS_SS,pairs),2)); % adds only the missing ones, avoid duplicate record
            pairs = [pairs; PAIRED_CS_SS(whichToAdd,:)]; % add manually found ones from globals that are not already found automatically
        elseif pairType == PAIR_TYPE_MF_SS
            whichToAdd = find(~all(ismember(PAIRED_MF_SS,pairs),2));
            pairs = [pairs; PAIRED_MF_SS(whichToAdd,:)]; % also add manually found ones from globals
        elseif pairType == PAIR_TYPE_MF_GO
            whichToAdd = find(~all(ismember(PAIRED_MF_GO,pairs),2));
            pairs = [pairs; PAIRED_MF_GO(whichToAdd,:)]; % also add manually found ones from globals
        elseif pairType == PAIR_TYPE_GO_SS
            whichToAdd = find(~all(ismember(PAIRED_GO_SS,pairs),2));
            pairs = [pairs; PAIRED_GO_SS(whichToAdd,:)]; % also add manually found ones from globals
        elseif pairType == PAIRED_MLI_SS
            whichToAdd = find(~all(ismember(PAIRED_MLI_SS,pairs),2));
            pairs = [pairs; PAIRED_MLI_SS(whichToAdd,:)]; % also add manually found ones from globals    
        elseif pairType == PAIR_TYPE_SS_DCN
            whichToAdd = find(~all(ismember(PAIRED_SS_DCN,pairs),2));
            pairs = [pairs; PAIRED_SS_DCN(whichToAdd,:)]; % also add manually found ones from globals 
        end
    else
        if strcmp(searchByUnit.neuronType,neuronType1)
            searchType = neuronType2;
        else
            searchType = neuronType1;
        end

        for ind=1:length(units)
            if strcmp(units(ind).neuronType,searchType) && units(ind).id~=searchByUnit.id % found the second type
                if abs(searchByUnit.depth-units(ind).depth)<=maxDistance
                    pairs = [pairs; [searchByUnit.id units(ind).id]]; % found a candidate pair to compare
                end
            end
        end

        % check if this unit searched is in the constant pairs list and has not been found yet
        if pairType == PAIR_TYPE_CS_SS
            whichToAdd = find(any(ismember(PAIRED_CS_SS,searchByUnit.id),2) & ~all(ismember(PAIRED_CS_SS,pairs),2)); % % adds only the missing ones, avoid duplicate record
            pairs = [pairs; PAIRED_CS_SS(whichToAdd,:)]; % add manually found ones if this unit is in the pairs
        elseif pairType == PAIR_TYPE_MF_SS
            whichToAdd = find(any(ismember(PAIRED_MF_SS,searchByUnit.id),2) & ~all(ismember(PAIRED_MF_SS,pairs),2));
            pairs = [pairs; PAIRED_MF_SS(whichToAdd,:)]; % also add manually found ones from globals
        elseif pairType == PAIR_TYPE_MF_GO
            whichToAdd = find(any(ismember(PAIRED_MF_GO,searchByUnit.id),2) & ~all(ismember(PAIRED_MF_GO,pairs),2));
            pairs = [pairs; PAIRED_MF_GO(whichToAdd,:)]; % also add manually found ones from globals
        elseif pairType == PAIR_TYPE_GO_SS
            whichToAdd = find(any(ismember(PAIRED_GO_SS,searchByUnit.id),2) & ~all(ismember(PAIRED_GO_SS,pairs),2));
            pairs = [pairs; PAIRED_GO_SS(whichToAdd,:)]; % also add manually found ones from globals
        elseif pairType == PAIRED_MLI_SS
            whichToAdd = find(any(ismember(PAIRED_MLI_SS,searchByUnit.id),2) & ~all(ismember(PAIRED_MLI_SS,pairs),2));
            pairs = [pairs; PAIRED_MLI_SS(whichToAdd,:)]; % also add manually found ones from globals        
        elseif pairType == PAIR_TYPE_SS_DCN
            whichToAdd = find(any(ismember(PAIRED_SS_DCN,searchByUnit.id),2) & ~all(ismember(PAIRED_SS_DCN,pairs),2));
            pairs = [pairs; PAIRED_SS_DCN(whichToAdd,:)]; % also add manually found ones from globals        
        end
    end
end