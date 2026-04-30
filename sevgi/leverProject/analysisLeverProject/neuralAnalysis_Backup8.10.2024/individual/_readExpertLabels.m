function unitGood = readExpertLabels(unitGood)
    globals;
    expertLabelsFilePath = strcat(pathToRecFolder,EXPERT_LABELS_TXT);
    if exist(expertLabelsFilePath,'file')==2
        counterMF = 0; counterSS = 0; counterCS = 0; counterDCS = 0; counterBS_SC = 0; counterGoC = 0; counterUBC = 0; counterOther = 0;
        idsMF = []; idsSS = []; idsCS = []; idsDCS = []; idsBC_SC = []; idsGoC = []; idsUBC = []; idsOther = [];

        data = importdata([pathToRecFolder EXPERT_LABELS_TXT],' ');
        for ind = 1:length(data)
            row = data{ind};
            indSpace = strfind(row,' ');
            unitId = str2double(row(1:indSpace(1)));
            neuronType = row(indSpace(1)+1:end);
            
            unitIndex = find([unitGood.id]==unitId);
            unitGood(unitIndex).expertLabel = neuronType;
            unitGood(unitIndex).neuronType = neuronType;
                                  
            if strcmp(NEURON_TYPE_MF,unitGood(unitIndex).expertLabel)
                counterMF = counterMF+1;
                idsMF = [idsMF num2str(unitGood(unitIndex).id) ' '];
            elseif strcmp(NEURON_TYPE_SS,unitGood(unitIndex).expertLabel)
                counterSS = counterSS+1;
                idsSS = [idsSS num2str(unitGood(unitIndex).id) ' '];
            elseif strcmp(NEURON_TYPE_CS,unitGood(unitIndex).expertLabel)
                counterCS = counterCS+1;
                idsCS = [idsCS num2str(unitGood(unitIndex).id) ' '];
            elseif strcmp(NEURON_TYPE_DCS,unitGood(unitIndex).expertLabel)
                counterDCS = counterDCS+1;
                idsDCS = [idsDCS num2str(unitGood(unitIndex).id) ' '];
            elseif strcmp(NEURON_TYPE_BC_SC,unitGood(unitIndex).expertLabel)
                counterBS_SC = counterBS_SC+1;                  
                idsBC_SC = [idsBC_SC num2str(unitGood(unitIndex).id) ' '];
            elseif strcmp(NEURON_TYPE_GoC,unitGood(unitIndex).expertLabel)
                counterGoC = counterGoC+1;
                idsGoC = [idsGoC num2str(unitGood(unitIndex).id) ' '];
            elseif strcmp(NEURON_TYPE_UBC,unitGood(unitIndex).expertLabel)
                counterUBC = counterUBC+1;
                idsUBC = [idsUBC num2str(unitGood(unitIndex).id) ' '];
            end
        end

        for uid=1:length(unitGood)
            if isempty(unitGood(uid).expertLabel) || strcmp('-',unitGood(uid).expertLabel)
                unitGood(uid).expertLabel = '';
            end
        end
        counterOther = length(unitGood)-(counterMF+counterSS+counterCS+counterDCS+counterBS_SC+counterGoC+counterUBC);
        logger.info('readExpertLabels', [num2str(length(unitGood)) ' units are selected for analysis!']);
        logger.info('readExpertLabels', ['MF = ' num2str(counterMF) ' (' idsMF ') SS = ' num2str(counterSS) ' (' idsSS ') CS = ' num2str(counterCS) ' (' idsCS ') DCS = ' num2str(counterDCS) ' (' idsDCS ') BS_SC = ' num2str(counterBS_SC) ' (' idsBC_SC ') ' ...
            'GoC = ' num2str(counterGoC) ' (' idsGoC ') UBC = ' num2str(counterUBC) ' (' idsUBC ') Others = ' num2str(counterOther) ' (' idsOther ')']);

    else
        logger.info('readExpertLabels', ['NO EXPERT LABEL FILE FOUND! ' expertLabelsFilePath]);

        for uid=1:length(unitGood)
            unitGood(uid).expertLabel = 'NoExpertLabel';
        end
        logger.info('readExpertLabels', [num2str(length(unitGood)) ' units are selected for analysis!']);
    end
end