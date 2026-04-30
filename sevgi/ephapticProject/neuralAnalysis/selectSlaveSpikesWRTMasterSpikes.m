function [unitVSSpikeTimesWithMaster, unitVSSpikeTimesWithoutMaster] = selectSlaveSpikesWRTMasterSpikes(masterUnitId, masterSpikeTimesSecs, masterCh, units, withMaster, withoutMaster)
    globals;

    unitVSSpikeTimesWithMaster = {};        
    unitVSSpikeTimesWithoutMaster = {};  
    
    if withMaster        
        % Only check for good units for now
        for uid=1:length(units)
           unit = units(uid);
           if unit.id~=masterUnitId
               if unit.ch == masterCh % TODO: Look all around the channel matrix
                   
                   % search from backwards of the master spikes to prevent double count of slave spikes cos a slave spike is highly probably caused by one previous master spike
                   for masterInd = length(masterSpikeTimesSecs):-1:1
                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% POST SLAVE SPIKES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       % Find if this unit spiked after the master unit spiked - within the range of [0-postTime] ms 
                       indsNewSlaveSpkTimes = find(masterSpikeTimesSecs(masterInd)<unit.spikeTimesSecs & unit.spikeTimesSecs<=(masterSpikeTimesSecs(masterInd)+MASTER_SLAVE_SPIKE_DISTANCE));
                       if ~isempty(indsNewSlaveSpkTimes)
                           prevSlaveInds = [];
                            if ~isempty(unitVSSpikeTimesWithMaster)
                                indTemp = find([unitVSSpikeTimesWithMaster{:,1}]==unit.id);
                                prevSlaveInds = [unitVSSpikeTimesWithMaster{indTemp,4}];
                            end

                            % add this new slave only if this new slave inds are not selected before. If selected, add into the previous set of spikes
                            if isempty(unitVSSpikeTimesWithMaster) || all(~ismember(prevSlaveInds,indsNewSlaveSpkTimes)) 
                                slaveSpikeTimeInds = {indsNewSlaveSpkTimes'};
                                slaveSpikeTimeSecs = {unit.spikeTimesSecs(indsNewSlaveSpkTimes)'};
                                neuronType = unit.neuronType;
                                if isempty(neuronType)
                                    neuronType = 'Unknown';
                                end
                                unitVSSpikeTimesWithMaster = [unitVSSpikeTimesWithMaster; [unit.id, neuronType, masterSpikeTimesSecs(masterInd), slaveSpikeTimeInds, slaveSpikeTimeSecs, {[]}, {[]}]];
                            elseif length(indsNewSlaveSpkTimes)>1 && any(~ismember(prevSlaveInds,indsNewSlaveSpkTimes)) % any of those slave spikes selected before
                                slaveSpikeTimeInds = {indsNewSlaveSpkTimes'};
                                slaveSpikeTimeSecs = {unit.spikeTimesSecs(indsNewSlaveSpkTimes)'};
                                indTemp = find([unitVSSpikeTimesWithMaster{:,1}]==unit.id);
                                % This was adding new slaves spikes into the previously found slave spikes
%                                 indPrevTemp = cellfun(@(x) ismember(x,indsNewSlaveSpkTimes), unitVSSpikeTimesWithMaster(indTemp,4), 'UniformOutput', 0);
%                                 indPrevSlaveSpikeTimes = find(cellfun(@any,indPrevTemp));
%                                 prevInds = unitVSSpikeTimesWithMaster{indPrevSlaveSpikeTimes,4};
%                                 rowIndices = ismember(indsNewSlaveSpkTimes, prevInds);
%                                 if any(~rowIndices) % if we found any missing spike, add it
%                                     unitVSSpikeTimesWithMaster{indPrevSlaveSpikeTimes,3} = masterSpikeTimesSecs(masterInd); % Update Master Spike Ind, it may change while shifting back
%                                     unitVSSpikeTimesWithMaster{indPrevSlaveSpikeTimes,4} = [unitVSSpikeTimesWithMaster{indPrevSlaveSpikeTimes,4}, indsNewSlaveSpkTimes(~rowIndices)']; % add only missing ones
%                                     unitVSSpikeTimesWithMaster{indPrevSlaveSpikeTimes,5} = [unitVSSpikeTimesWithMaster{indPrevSlaveSpikeTimes,5}, unit.spikeTimesSecs(indsNewSlaveSpkTimes(~rowIndices))']; % add only missing ones
%                                 end

                                indPrevTemp = cellfun(@(x) ismember(indsNewSlaveSpkTimes,x), unitVSSpikeTimesWithMaster(indTemp,4), 'UniformOutput', 0);
                                indPrevSlaveSpikeInds = find(cellfun(@any,indPrevTemp));
                                whichInd = indPrevTemp{indPrevSlaveSpikeInds,:};
                                indsToBeAdded = indsNewSlaveSpkTimes(~whichInd);
                                if ~isempty(indsToBeAdded)
                                    slaveSpikeTimeInds = {indsToBeAdded'};
                                    slaveSpikeTimeSecs = {unit.spikeTimesSecs(indsToBeAdded)'};
                                    neuronType = unit.neuronType;
                                    if isempty(neuronType)
                                        neuronType = 'Unknown';
                                    end
                                    unitVSSpikeTimesWithMaster = [unitVSSpikeTimesWithMaster; [unit.id, neuronType, masterSpikeTimesSecs(masterInd), slaveSpikeTimeInds, slaveSpikeTimeSecs, {[]}, {[]}]];
                                end
                            end
                       end

                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRE SLAVE SPIKES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       % Find if this unit spiked after the master unit spiked - within the range of [preTime-0] ms 
                       indsNewPrevSlaveSpkTimes = find((masterSpikeTimesSecs(masterInd)-PRE_MASTER_SLAVE_SPIKE_DISTANCE)<unit.spikeTimesSecs & unit.spikeTimesSecs<masterSpikeTimesSecs(masterInd));
                       % and there are no other master spikes within that time window
                       indsPrevMasterSpkTimes = find((masterSpikeTimesSecs(masterInd)-PRE_MASTER_SLAVE_SPIKE_DISTANCE)<masterSpikeTimesSecs & masterSpikeTimesSecs<masterSpikeTimesSecs(masterInd));
                       if ~isempty(indsNewPrevSlaveSpkTimes) && isempty(indsPrevMasterSpkTimes)
                           prevMasterInd = [];
                           prevSlaveInds = [];
                           if ~isempty(unitVSSpikeTimesWithMaster)
                                indTemp = find([unitVSSpikeTimesWithMaster{:,1}]==unit.id);
                                prevMasterSpkTimes = [unitVSSpikeTimesWithMaster{indTemp,3}]; % Is this master spike added before
                                prevMasterInd = find(prevMasterSpkTimes==masterSpikeTimesSecs(masterInd),1);
                                prevSlaveInds = [unitVSSpikeTimesWithMaster{indTemp,6}];
                           end

                           % add this new slave only if this master spike is not added before or new slave inds are not selected before. If selected, add into the previous set of spikes
                            if isempty(unitVSSpikeTimesWithMaster) || isempty(prevMasterInd) || all(~ismember(prevSlaveInds,indsNewPrevSlaveSpkTimes)) 
                                slaveSpikeTimeInds = {indsNewPrevSlaveSpkTimes'};
                                slaveSpikeTimeSecs = {unit.spikeTimesSecs(indsNewPrevSlaveSpkTimes)'};
                                neuronType = unit.neuronType;
                                if isempty(neuronType)
                                    neuronType = 'Unknown';
                                end
                                unitVSSpikeTimesWithMaster = [unitVSSpikeTimesWithMaster; [unit.id, neuronType, masterSpikeTimesSecs(masterInd), {[]}, {[]}, slaveSpikeTimeInds, slaveSpikeTimeSecs]];
                            elseif ~isempty(prevMasterInd) && length(indsNewPrevSlaveSpkTimes)>1 && any(~ismember(prevSlaveInds,indsNewPrevSlaveSpkTimes)) % any of those slave spikes are not selected before
                                slaveSpikeTimeInds = {indsNewPrevSlaveSpkTimes'};
                                slaveSpikeTimeSecs = {unit.spikeTimesSecs(indsNewPrevSlaveSpkTimes)'};
                                indTemp = find([unitVSSpikeTimesWithMaster{:,1}]==unit.id);
                                indPrevTemp = cellfun(@(x) ismember(indsNewPrevSlaveSpkTimes,x), unitVSSpikeTimesWithMaster(indTemp,6), 'UniformOutput', 0);
                                indPrevSlaveSpikeInds = find(cellfun(@any,indPrevTemp));
                                whichInd = indPrevTemp{indPrevSlaveSpikeInds,:};
                                indsToBeAdded = indsNewPrevSlaveSpkTimes(~whichInd);
                                if ~isempty(indsToBeAdded)
                                    slaveSpikeTimeInds = {indsToBeAdded'};
                                    slaveSpikeTimeSecs = {unit.spikeTimesSecs(indsToBeAdded)'};
                                    neuronType = unit.neuronType;
                                    if isempty(neuronType)
                                        neuronType = 'Unknown';
                                    end
                                    unitVSSpikeTimesWithMaster = [unitVSSpikeTimesWithMaster; [unit.id, neuronType, masterSpikeTimesSecs(masterInd), {[]}, {[]}, slaveSpikeTimeInds, slaveSpikeTimeSecs]];
                                end
                            end

                       end

                   end
               end
           end
        end
        unitVSSpikeTimesWithMaster = flip(unitVSSpikeTimesWithMaster,1);
    end

    % Find the slave spikes' background activity without any Master spikes around
    if withoutMaster        
        slaveUnits = unique([unitVSSpikeTimesWithMaster{:,1}]);
        for uid=1:length(slaveUnits)           
           unitSlave = units(find([units.id]==slaveUnits(uid)));           
           for slaveInd =1:length(unitSlave.spikeTimesSecs)
               % If there are no master spikes between slaveSpike and one MASTER_SLAVE_SPIKE_DISTANCE earlier than the slaveSpike, then get this slaveSpike
               % All other slave spikes that has masterSpikes within this time window may already be modulated by masterSpike, so don't include them
               indMasterSpikes = find((unitSlave.spikeTimesSecs(slaveInd)-MASTER_SLAVE_SPIKE_DISTANCE)<masterSpikeTimesSecs & masterSpikeTimesSecs<unitSlave.spikeTimesSecs(slaveInd));
               if isempty(indMasterSpikes)
                   slaveSpikeTimeInds = {slaveInd'};
                   slaveSpikeTimeSecs = {unitSlave.spikeTimesSecs(slaveInd)'};
                   neuronType = unitSlave.neuronType;
                   if isempty(neuronType)
                        neuronType = 'Unknown';
                   end

                   indPrevSlaveSpikeTimes = [];
                   if ~isempty(unitVSSpikeTimesWithoutMaster)
                        %prevSlaveSpikeTimes = [unitVSSpikeTimesWithoutMaster{:,4}];
                        indTemp = find([unitVSSpikeTimesWithoutMaster{:,1}]==unitSlave.id);
                        %indPrevTemp = cellfun(@(x) (unitSlave.spikeTimesSecs(slaveInd)-MASTER_SLAVE_SPIKE_DISTANCE)<x & x<unitSlave.spikeTimesSecs(slaveInd), unitVSSpikeTimesWithoutMaster(indTemp,4), 'UniformOutput', 0);
                        indPrevTemp = cellfun(@(x) (unitSlave.spikeTimesSecs(slaveInd)<x-MASTER_SLAVE_SPIKE_DISTANCE) & x<unitSlave.spikeTimesSecs(slaveInd), unitVSSpikeTimesWithoutMaster(indTemp,4), 'UniformOutput', 0);
                        % if there were other spikes within the same ROI, add new spike into that trial                        
                        indPrevSlaveSpikeTimes = find(cellfun(@any,indPrevTemp));
                   end
                   if ~isempty(unitVSSpikeTimesWithoutMaster) && ~isempty(indPrevSlaveSpikeTimes)
                        unitVSSpikeTimesWithoutMaster{indPrevSlaveSpikeTimes,3} = [unitVSSpikeTimesWithoutMaster{indPrevSlaveSpikeTimes,3}, slaveInd];
                        unitVSSpikeTimesWithoutMaster{indPrevSlaveSpikeTimes,4} = [unitVSSpikeTimesWithoutMaster{indPrevSlaveSpikeTimes,4}, unitSlave.spikeTimesSecs(slaveInd)];                        
                   else                  
                        unitVSSpikeTimesWithoutMaster = [unitVSSpikeTimesWithoutMaster; [unitSlave.id, neuronType, slaveSpikeTimeInds, slaveSpikeTimeSecs]];
                   end
               end
           end           
        end
    end

%     if backward              
%         % Only check for good units for now
%         for uid=1:length(units)
%            unit = units(uid);
%            if unit.id~=masterUnitId
%                if unit.ch == masterCh % TODO: Look all around the channel matrix
%                    isiMasterSpike = diff(masterSpikeTimesSecs);
%                    indCleanSpikes = find(isiMasterSpike>=preTime)+1; % Find a clean duration that master unit spiked only once (increment indices +1 cos it is looking backwards)
% 
%                    for spTimeId = 1:length(indCleanSpikes)
%                        % Find if this unit spiked before the master unit spiked - within the range of [preTime-0] ms 
%                        inds = find(unit.spikeTimesSecs<masterSpikeTimesSecs(indCleanSpikes(spTimeId)) & unit.spikeTimesSecs>=(masterSpikeTimesSecs(indCleanSpikes(spTimeId))-preTime));
%                        if ~isempty(inds)
%                             slaveSpikeTimeSecs = {unit.spikeTimesSecs(inds)'};
%                             neuronType = unit.neuronType;
%                             if isempty(neuronType)
%                                 neuronType = 'Unknown';
%                             end
%                             unitVSSpikeTimesBackward = [unitVSSpikeTimesBackward; [unit.id, neuronType, masterSpikeTimesSecs(indCleanSpikes(spTimeId)), slaveSpikeTimeSecs]];
%                        end               
%                    end
%                end
%            end
%         end
%     end
    
end