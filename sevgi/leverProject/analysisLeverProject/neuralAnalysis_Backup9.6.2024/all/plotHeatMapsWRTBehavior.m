function plotHeatMapsWRTBehavior(arrRecordings)

    globalsAll;
    if RECORDING_DAY_OF_INTEREST == -1 % Plot all days of recordings
        allTrialCount = 0;
        allHitFixedTrialCount = 0;
        allHitRandomTrialCount = 0;

        allFaFixedTrialCount = 0;
        allFaRandomTrialCount = 0;

        allMissFixedTrialCount = 0;
        allMissRandomTrialCount = 0;

        unitsOfSpecTypeForAllRec = cell(length(NEURON_TYPES),1);

        for indRec = 1:length(arrRecordings)
               
                currentRecording = arrRecordings{1,indRec};
                indices = strfind(currentRecording.name,'_');
                recordingDay = extractBetween(currentRecording.name, indices(1)+1, indices(3)-1);
                recordingDay = recordingDay{:};
                units = currentRecording.unitGood; 

                trialCount = length(currentRecording.allTrials);
                hitFixedTrialCount = length(units(1).spikeRatePerTrialHoldFixedHit); %currentRecording.arrHitTrials);
                hitRandomTrialCount = length(units(1).spikeRatePerTrialHoldRandomHit);
                
                faFixedTrialCount = length(units(1).spikeRatePerTrialHoldFixedFa);
                faRandomTrialCount = length(units(1).spikeRatePerTrialHoldRandomFa);

                missFixedTrialCount = length(units(1).spikeRatePerTrialHoldFixedMiss);
                missRandomTrialCount = length(units(1).spikeRatePerTrialHoldRandomMiss);

                allHitFixedTrialCount = allHitFixedTrialCount + hitFixedTrialCount;
                allHitRandomTrialCount = allHitRandomTrialCount + hitRandomTrialCount;
                
                allFaFixedTrialCount = allFaFixedTrialCount + faFixedTrialCount;
                allFaRandomTrialCount = allFaRandomTrialCount + faRandomTrialCount;

                allMissFixedTrialCount = allMissFixedTrialCount + missFixedTrialCount;
                allMissRandomTrialCount = allMissRandomTrialCount + missRandomTrialCount;

                allTrialCount = allTrialCount + trialCount;

                for indNeuronType=1:length(NEURON_TYPES)
                        if strcmp(NEURON_TYPES{indNeuronType},NEURON_TYPE_OTHER)
                            indsNeurons = strcmp({units.neuronType},'');
                        else
                            indsNeurons = strcmp({units.neuronType},NEURON_TYPES{indNeuronType});
                        end
                        indsSingleUnits = [units.singleUnit];
                        unitsOfSpecType = units(indsNeurons & indsSingleUnits); 

                        if ~isempty(unitsOfSpecType)
                            unitsOfSpecTypeForAllRec(indNeuronType) = {[unitsOfSpecTypeForAllRec{indNeuronType}, unitsOfSpecType]};                        
                            %%%%%%%%%%%%%%%%%%%% HOLD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            spikeRatesHoldRandomAll = {unitsOfSpecType.spikeRatesHoldRandomAll}';                            
                            spikeRatesHoldRandomHFM = {unitsOfSpecType.spikeRatesHoldRandomHFM}';                                                        
                            spikeRatesHoldRandomHit = cellfun(@(x)x(1,:),spikeRatesHoldRandomHFM,'UniformOutput',false);
                            spikeRatesHoldRandomFa = cellfun(@(x)x(2,:),spikeRatesHoldRandomHFM,'UniformOutput',false);
                            spikeRatesHoldRandomMiss = cellfun(@(x)x(3,:),spikeRatesHoldRandomHFM,'UniformOutput',false);
                            
                            spikeRatesHoldFixedAll = {unitsOfSpecType.spikeRatesHoldFixedAll}';
                            spikeRatesHoldFixedHFM = {unitsOfSpecType.spikeRatesHoldFixedHFM}'; 
                            spikeRatesHoldFixedHit = cellfun(@(x)x(1,:),spikeRatesHoldFixedHFM,'UniformOutput',false);
                            spikeRatesHoldFixedFa = cellfun(@(x)x(2,:),spikeRatesHoldFixedHFM,'UniformOutput',false);
                            spikeRatesHoldFixedMiss = cellfun(@(x)x(3,:),spikeRatesHoldFixedHFM,'UniformOutput',false);

                            % ***** REACTION *****
                            if ~isempty(spikeRatesHoldRandomAll)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], (hitRandomTrialCount+faRandomTrialCount+missRandomTrialCount), ...
                                     spikeRatesHoldRandomAll, EDGES_HOLD, 'Reaction - Hold aligned', 'reactionHoldAligned');
                            end
                            if ~isempty(spikeRatesHoldRandomHit)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], hitRandomTrialCount, ...
                                     spikeRatesHoldRandomHit, EDGES_HOLD, 'Reaction - Hold aligned HIT', 'reactionHoldAlignedHit');
                            end
                            if ~isempty(spikeRatesHoldRandomFa)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], faRandomTrialCount, ...
                                     spikeRatesHoldRandomFa, EDGES_HOLD, 'Reaction - Hold aligned FA', 'reactionHoldAlignedFa');
                            end
                            if ~isempty(spikeRatesHoldRandomMiss)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], missRandomTrialCount, ...
                                     spikeRatesHoldRandomMiss, EDGES_HOLD, 'Reaction - Hold aligned MISS', 'reactionHoldAlignedMiss');
                            end

                            % ***** PREDICTION *****
                            if ~isempty(spikeRatesHoldFixedAll)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], (hitFixedTrialCount+faFixedTrialCount+missFixedTrialCount), ...
                                     spikeRatesHoldFixedAll, EDGES_HOLD, 'Prediction - Hold aligned', 'predictionHoldAligned');
                            end
                            if ~isempty(spikeRatesHoldFixedHit)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], hitFixedTrialCount, ...
                                     spikeRatesHoldFixedHit, EDGES_HOLD, 'Prediction - Hold aligned HIT', 'predictionHoldAlignedHit');
                            end
                            if ~isempty(spikeRatesHoldFixedFa)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], faFixedTrialCount, ...
                                     spikeRatesHoldFixedFa, EDGES_HOLD, 'Prediction - Hold aligned FA', 'predictionHoldAlignedFa');
                            end
                            if ~isempty(spikeRatesHoldFixedMiss)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], missFixedTrialCount, ...
                                     spikeRatesHoldFixedMiss, EDGES_HOLD, 'Prediction - Hold aligned MISS', 'predictionHoldAlignedMiss');
                            end


                            %%%%%%%%%%%%%%%%%%%% RELEASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                            
                            spikeRatesReleaseRandomAll = {unitsOfSpecType.spikeRatesReleaseRandomAll}';                            
                            spikeRatesReleaseRandomHFM = {unitsOfSpecType.spikeRatesReleaseRandomHFM}';                                                        
                            spikeRatesReleaseRandomHit = cellfun(@(x)x(1,:),spikeRatesReleaseRandomHFM,'UniformOutput',false);
                            spikeRatesReleaseRandomFa = cellfun(@(x)x(2,:),spikeRatesReleaseRandomHFM,'UniformOutput',false);
                            spikeRatesReleaseRandomMiss = cellfun(@(x)x(3,:),spikeRatesReleaseRandomHFM,'UniformOutput',false);
                            
                            spikeRatesReleaseFixedAll = {unitsOfSpecType.spikeRatesReleaseFixedAll}';
                            spikeRatesReleaseFixedHFM = {unitsOfSpecType.spikeRatesReleaseFixedHFM}'; 
                            spikeRatesReleaseFixedHit = cellfun(@(x)x(1,:),spikeRatesReleaseFixedHFM,'UniformOutput',false);
                            spikeRatesReleaseFixedFa = cellfun(@(x)x(2,:),spikeRatesReleaseFixedHFM,'UniformOutput',false);
                            spikeRatesReleaseFixedMiss = cellfun(@(x)x(3,:),spikeRatesReleaseFixedHFM,'UniformOutput',false);

                            % ***** REACTION *****
                            if ~isempty(spikeRatesReleaseRandomAll)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], (hitRandomTrialCount+faRandomTrialCount+missRandomTrialCount), ...
                                     spikeRatesReleaseRandomAll, EDGES_RELEASE, 'Reaction - Release aligned', 'reactionReleaseAligned');
                            end
                            if ~isempty(spikeRatesReleaseRandomHit)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], hitRandomTrialCount, ...
                                     spikeRatesReleaseRandomHit, EDGES_RELEASE, 'Reaction - Release aligned HIT', 'reactionReleaseAlignedHit');
                            end
                            if ~isempty(spikeRatesReleaseRandomFa)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], faRandomTrialCount, ...
                                     spikeRatesReleaseRandomFa, EDGES_RELEASE, 'Reaction - Release aligned FA', 'reactionReleaseAlignedFa');
                            end
                            if ~isempty(spikeRatesReleaseRandomMiss)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], missRandomTrialCount, ...
                                     spikeRatesReleaseRandomMiss, EDGES_RELEASE, 'Reaction - Release aligned MISS', 'reactionReleaseAlignedMiss');
                            end

                            % ***** PREDICTION *****
                            if ~isempty(spikeRatesReleaseFixedAll)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], (hitFixedTrialCount+faFixedTrialCount+missFixedTrialCount), ...
                                     spikeRatesReleaseFixedAll, EDGES_RELEASE, 'Prediction - Release aligned', 'predictionReleaseAligned');
                            end
                            if ~isempty(spikeRatesReleaseFixedHit)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], hitFixedTrialCount, ...
                                     spikeRatesReleaseFixedHit, EDGES_RELEASE, 'Prediction - Release aligned HIT', 'predictionReleaseAlignedHit');
                            end
                            if ~isempty(spikeRatesReleaseFixedFa)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], faFixedTrialCount, ...
                                     spikeRatesReleaseFixedFa, EDGES_RELEASE, 'Prediction - Release aligned FA', 'predictionReleaseAlignedFa');
                            end
                            if ~isempty(spikeRatesReleaseFixedMiss)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], missFixedTrialCount, ...
                                     spikeRatesReleaseFixedMiss, EDGES_RELEASE, 'Prediction - Release aligned MISS', 'predictionReleaseAlignedMiss');
                            end

                            %%%%%%%%%%%%%%%%%%%% TARGET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            spikeRatesTargetRandomAll = {unitsOfSpecType.spikeRatesTargetRandomAll}';
                            spikeRatesTargetFixedAll = {unitsOfSpecType.spikeRatesTargetFixedAll}';
                            spikeRatesTargetRandomHFM = {unitsOfSpecType.spikeRatesTargetRandomHFM}';
                            spikeRatesTargetFixedHFM = {unitsOfSpecType.spikeRatesTargetFixedHFM}';  
                            
                            spikeRatesTargetRandomAll = {unitsOfSpecType.spikeRatesTargetRandomAll}';                            
                            spikeRatesTargetRandomHFM = {unitsOfSpecType.spikeRatesTargetRandomHFM}';                                                        
                            spikeRatesTargetRandomHit = cellfun(@(x)x(1,:),spikeRatesTargetRandomHFM,'UniformOutput',false);                            
                            spikeRatesTargetRandomMiss = cellfun(@(x)x(2,:),spikeRatesTargetRandomHFM,'UniformOutput',false);
                            
                            spikeRatesTargetFixedAll = {unitsOfSpecType.spikeRatesTargetFixedAll}';
                            spikeRatesTargetFixedHFM = {unitsOfSpecType.spikeRatesTargetFixedHFM}'; 
                            spikeRatesTargetFixedHit = cellfun(@(x)x(1,:),spikeRatesTargetFixedHFM,'UniformOutput',false);
                            spikeRatesTargetFixedMiss = cellfun(@(x)x(2,:),spikeRatesTargetFixedHFM,'UniformOutput',false);

                            % ***** REACTION *****
                            if ~isempty(spikeRatesTargetRandomAll)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], (hitRandomTrialCount+missRandomTrialCount), ...
                                     spikeRatesTargetRandomAll, EDGES_VIS_STIM, 'Reaction - Target aligned', 'reactionTargetAligned');
                            end
                            if ~isempty(spikeRatesTargetRandomHit)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], hitRandomTrialCount, ...
                                     spikeRatesTargetRandomHit, EDGES_VIS_STIM, 'Reaction - Target aligned HIT', 'reactionTargetAlignedHit');
                            end
                            if ~isempty(spikeRatesTargetRandomMiss)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], missRandomTrialCount, ...
                                     spikeRatesTargetRandomMiss, EDGES_VIS_STIM, 'Reaction - Target aligned MISS', 'reactionTargetAlignedMiss');
                            end

                            % ***** PREDICTION *****
                            if ~isempty(spikeRatesTargetFixedAll)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], (hitFixedTrialCount+faFixedTrialCount+missFixedTrialCount), ...
                                     spikeRatesTargetFixedAll, EDGES_VIS_STIM, 'Prediction - Target aligned', 'predictionTargetAligned');
                            end
                            if ~isempty(spikeRatesTargetFixedHit)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], hitFixedTrialCount, ...
                                     spikeRatesTargetFixedHit, EDGES_VIS_STIM, 'Prediction - Target aligned HIT', 'predictionTargetAlignedHit');
                            end
                            if ~isempty(spikeRatesTargetFixedMiss)
                                plotHeatMap(recordingDay, NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], missFixedTrialCount, ...
                                     spikeRatesTargetFixedMiss, EDGES_VIS_STIM, 'Prediction - Target aligned MISS', 'predictionTargetAlignedMiss');
                            end

                            close all;

                        end
                end
        end

        % Plot each unit type joined from ALL recordings
        for indNeuronType=1:length(NEURON_TYPES)        
            unitsOfSpecType = unitsOfSpecTypeForAllRec{indNeuronType};
            if ~isempty(unitsOfSpecType)
                %%%%%%%%%%%%%%%%%%%% HOLD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                spikeRatesHoldRandomAll = {unitsOfSpecType.spikeRatesHoldRandomAll}';                            
                spikeRatesHoldRandomHFM = {unitsOfSpecType.spikeRatesHoldRandomHFM}';                                                        
                spikeRatesHoldRandomHit = cellfun(@(x)x(1,:),spikeRatesHoldRandomHFM,'UniformOutput',false);
                spikeRatesHoldRandomFa = cellfun(@(x)x(2,:),spikeRatesHoldRandomHFM,'UniformOutput',false);
                spikeRatesHoldRandomMiss = cellfun(@(x)x(3,:),spikeRatesHoldRandomHFM,'UniformOutput',false);
                
                spikeRatesHoldFixedAll = {unitsOfSpecType.spikeRatesHoldFixedAll}';
                spikeRatesHoldFixedHFM = {unitsOfSpecType.spikeRatesHoldFixedHFM}'; 
                spikeRatesHoldFixedHit = cellfun(@(x)x(1,:),spikeRatesHoldFixedHFM,'UniformOutput',false);
                spikeRatesHoldFixedFa = cellfun(@(x)x(2,:),spikeRatesHoldFixedHFM,'UniformOutput',false);
                spikeRatesHoldFixedMiss = cellfun(@(x)x(3,:),spikeRatesHoldFixedHFM,'UniformOutput',false);

                % ***** REACTION *****
                if ~isempty(spikeRatesHoldRandomAll)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], (allHitRandomTrialCount+allFaRandomTrialCount+allMissRandomTrialCount), ...
                         spikeRatesHoldRandomAll, EDGES_HOLD, 'Reaction - Hold aligned', 'reactionHoldAligned');
                end
                if ~isempty(spikeRatesHoldRandomHit)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allHitRandomTrialCount, ...
                         spikeRatesHoldRandomHit, EDGES_HOLD, 'Reaction - Hold aligned HIT', 'reactionHoldAlignedHit');
                end
                if ~isempty(spikeRatesHoldRandomFa)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allFaRandomTrialCount, ...
                         spikeRatesHoldRandomFa, EDGES_HOLD, 'Reaction - Hold aligned FA', 'reactionHoldAlignedFa');
                end
                if ~isempty(spikeRatesHoldRandomMiss)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allMissRandomTrialCount, ...
                         spikeRatesHoldRandomMiss, EDGES_HOLD, 'Reaction - Hold aligned MISS', 'reactionHoldAlignedMiss');
                end

                % ***** PREDICTION *****
                if ~isempty(spikeRatesHoldFixedAll)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], (allHitFixedTrialCount+allFaFixedTrialCount+allMissFixedTrialCount), ...
                         spikeRatesHoldFixedAll, EDGES_HOLD, 'Prediction - Hold aligned', 'predictionHoldAligned');
                end
                if ~isempty(spikeRatesHoldFixedHit)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allHitFixedTrialCount, ...
                         spikeRatesHoldFixedHit, EDGES_HOLD, 'Prediction - Hold aligned HIT', 'predictionHoldAlignedHit');
                end
                if ~isempty(spikeRatesHoldFixedFa)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allFaFixedTrialCount, ...
                         spikeRatesHoldFixedFa, EDGES_HOLD, 'Prediction - Hold aligned FA', 'predictionHoldAlignedFa');
                end
                if ~isempty(spikeRatesHoldFixedMiss)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allMissFixedTrialCount, ...
                         spikeRatesHoldFixedMiss, EDGES_HOLD, 'Prediction - Hold aligned MISS', 'predictionHoldAlignedMiss');
                end


                %%%%%%%%%%%%%%%%%%%% RELEASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                            
                spikeRatesReleaseRandomAll = {unitsOfSpecType.spikeRatesReleaseRandomAll}';                            
                spikeRatesReleaseRandomHFM = {unitsOfSpecType.spikeRatesReleaseRandomHFM}';                                                        
                spikeRatesReleaseRandomHit = cellfun(@(x)x(1,:),spikeRatesReleaseRandomHFM,'UniformOutput',false);
                spikeRatesReleaseRandomFa = cellfun(@(x)x(2,:),spikeRatesReleaseRandomHFM,'UniformOutput',false);
                spikeRatesReleaseRandomMiss = cellfun(@(x)x(3,:),spikeRatesReleaseRandomHFM,'UniformOutput',false);
                
                spikeRatesReleaseFixedAll = {unitsOfSpecType.spikeRatesReleaseFixedAll}';
                spikeRatesReleaseFixedHFM = {unitsOfSpecType.spikeRatesReleaseFixedHFM}'; 
                spikeRatesReleaseFixedHit = cellfun(@(x)x(1,:),spikeRatesReleaseFixedHFM,'UniformOutput',false);
                spikeRatesReleaseFixedFa = cellfun(@(x)x(2,:),spikeRatesReleaseFixedHFM,'UniformOutput',false);
                spikeRatesReleaseFixedMiss = cellfun(@(x)x(3,:),spikeRatesReleaseFixedHFM,'UniformOutput',false);

                % ***** REACTION *****
                if ~isempty(spikeRatesReleaseRandomAll)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], (allHitRandomTrialCount+allFaRandomTrialCount+allMissRandomTrialCount), ...
                         spikeRatesReleaseRandomAll, EDGES_RELEASE, 'Reaction - Release aligned', 'reactionReleaseAligned');
                end
                if ~isempty(spikeRatesReleaseRandomHit)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allHitRandomTrialCount, ...
                         spikeRatesReleaseRandomHit, EDGES_RELEASE, 'Reaction - Release aligned HIT', 'reactionReleaseAlignedHit');
                end
                if ~isempty(spikeRatesReleaseRandomFa)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allFaRandomTrialCount, ...
                         spikeRatesReleaseRandomFa, EDGES_RELEASE, 'Reaction - Release aligned FA', 'reactionReleaseAlignedFa');
                end
                if ~isempty(spikeRatesReleaseRandomMiss)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allMissRandomTrialCount, ...
                         spikeRatesReleaseRandomMiss, EDGES_RELEASE, 'Reaction - Release aligned MISS', 'reactionReleaseAlignedMiss');
                end

                % ***** PREDICTION *****
                if ~isempty(spikeRatesReleaseFixedAll)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], (allHitFixedTrialCount+allFaFixedTrialCount+allMissFixedTrialCount), ...
                         spikeRatesReleaseFixedAll, EDGES_RELEASE, 'Prediction - Release aligned', 'predictionReleaseAligned');
                end
                if ~isempty(spikeRatesReleaseFixedHit)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allHitFixedTrialCount, ...
                         spikeRatesReleaseFixedHit, EDGES_RELEASE, 'Prediction - Release aligned HIT', 'predictionReleaseAlignedHit');
                end
                if ~isempty(spikeRatesReleaseFixedFa)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allFaFixedTrialCount, ...
                         spikeRatesReleaseFixedFa, EDGES_RELEASE, 'Prediction - Release aligned FA', 'predictionReleaseAlignedFa');
                end
                if ~isempty(spikeRatesReleaseFixedMiss)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allMissFixedTrialCount, ...
                         spikeRatesReleaseFixedMiss, EDGES_RELEASE, 'Prediction - Release aligned MISS', 'predictionReleaseAlignedMiss');
                end

                %%%%%%%%%%%%%%%%%%%% TARGET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                spikeRatesTargetRandomAll = {unitsOfSpecType.spikeRatesTargetRandomAll}';
                spikeRatesTargetFixedAll = {unitsOfSpecType.spikeRatesTargetFixedAll}';
                spikeRatesTargetRandomHFM = {unitsOfSpecType.spikeRatesTargetRandomHFM}';
                spikeRatesTargetFixedHFM = {unitsOfSpecType.spikeRatesTargetFixedHFM}';  
                
                spikeRatesTargetRandomAll = {unitsOfSpecType.spikeRatesTargetRandomAll}';                            
                spikeRatesTargetRandomHFM = {unitsOfSpecType.spikeRatesTargetRandomHFM}';                                                        
                spikeRatesTargetRandomHit = cellfun(@(x)x(1,:),spikeRatesTargetRandomHFM,'UniformOutput',false);
                spikeRatesTargetRandomMiss = cellfun(@(x)x(2,:),spikeRatesTargetRandomHFM,'UniformOutput',false);
                
                spikeRatesTargetFixedAll = {unitsOfSpecType.spikeRatesTargetFixedAll}';
                spikeRatesTargetFixedHFM = {unitsOfSpecType.spikeRatesTargetFixedHFM}'; 
                spikeRatesTargetFixedHit = cellfun(@(x)x(1,:),spikeRatesTargetFixedHFM,'UniformOutput',false);
                spikeRatesTargetFixedMiss = cellfun(@(x)x(2,:),spikeRatesTargetFixedHFM,'UniformOutput',false);

                % ***** REACTION *****
                if ~isempty(spikeRatesTargetRandomAll)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], (allHitRandomTrialCount+allMissRandomTrialCount), ...
                         spikeRatesTargetRandomAll, EDGES_VIS_STIM, 'Reaction - Target aligned', 'reactionTargetAligned');
                end
                if ~isempty(spikeRatesTargetRandomHit)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allHitRandomTrialCount, ...
                         spikeRatesTargetRandomHit, EDGES_VIS_STIM, 'Reaction - Target aligned HIT', 'reactionTargetAlignedHit');
                end
                if ~isempty(spikeRatesTargetRandomMiss)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allMissRandomTrialCount, ...
                         spikeRatesTargetRandomMiss, EDGES_VIS_STIM, 'Reaction - Target aligned MISS', 'reactionTargetAlignedMiss');
                end

                % ***** PREDICTION *****
                if ~isempty(spikeRatesTargetFixedAll)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], (allHitFixedTrialCount+allMissFixedTrialCount), ...
                         spikeRatesTargetFixedAll, EDGES_VIS_STIM, 'Prediction - Target aligned', 'predictionTargetAligned');
                end
                if ~isempty(spikeRatesTargetFixedHit)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allHitFixedTrialCount, ...
                         spikeRatesTargetFixedHit, EDGES_VIS_STIM, 'Prediction - Target aligned HIT', 'predictionTargetAlignedHit');
                end
                if ~isempty(spikeRatesTargetFixedMiss)
                    plotHeatMap('AllRec', NEURON_TYPES{indNeuronType}, [unitsOfSpecType.id], [unitsOfSpecType.depth], allMissFixedTrialCount, ...
                         spikeRatesTargetFixedMiss, EDGES_VIS_STIM, 'Prediction - Target aligned MISS', 'predictionTargetAlignedMiss');
                end
                
            end
        end

    else
    end
end