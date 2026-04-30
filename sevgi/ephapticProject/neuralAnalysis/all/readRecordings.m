function arrRecordings = readRecordings()
    globalsAll;
    globals;
    
    if exist(ALL_RECORDINGS_FILE,"file")
        recordings = whos("-file",ALL_RECORDINGS_FILE);        
        arrRecordings = cell(1,length(recordings));
        for indRec=1:length(recordings)
            load(ALL_RECORDINGS_FILE,recordings(indRec).name);
            recStruct.name = recordings(indRec).name;            
%             eval(strcat('recStruct.mouseId=', recStruct.name, '.mouseId;'));
            eval(strcat('recStruct.unitGood=', recStruct.name, '.unitGood;'));            
            arrRecordings{1,indRec} = recStruct;        

            strLog = '';
            totalNumCells = 0;
            cellNeuronType = {recStruct.unitGood.neuronType};
            %No need since DCN bug fixed %cellNeuronType = cellfun(@(strRow) strRow(length(beginnerStr)+1:end),cellNeuronType,UniformOutput=false);

            for indNeuronType=1:length(NEURON_TYPES)
                if strcmp(NEURON_TYPES{indNeuronType},NEURON_TYPE_OTHER)
                    indsNeurons = find(strcmp(cellNeuronType,''));
                else
                    indsNeurons = find(startsWith(cellNeuronType,NEURON_TYPES{indNeuronType})); %strcmp
                end                
                strLog = [strLog ' ' NEURON_TYPES{indNeuronType} '=' num2str(length(indsNeurons))];
                totalNumCells = totalNumCells + length(indsNeurons);
            end
            logger.info('readRecordings',[recStruct.name ' has ' strLog ' totalNumCells=' num2str(totalNumCells)]);

            eval(['clear ' recStruct.name]);
            clear recStruct
        end

        logger.info('mainAll', [num2str(length(recordings)) ' recordings are read from file ' ALL_RECORDINGS_FILE]);
    end
end