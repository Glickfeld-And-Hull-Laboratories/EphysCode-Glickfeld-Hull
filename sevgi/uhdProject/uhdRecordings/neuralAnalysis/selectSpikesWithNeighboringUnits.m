function [unitVSSpikeTimesForward, unitVSSpikeTimesBackward] = selectSpikesWithNeighboringUnits(mainUnitId, unitMasterSpikeTimesSecWhole, mainCh, units, forward, backward, postTime, preTime, laserOnsetTimes, laserOffsetTimes)
    globals;

    unitVSSpikeTimesForward = {};        
    unitVSSpikeTimesBackward = {};  

    % TODO: Convert this function into a form that checks preceeding and following spikes of the slave unit 
    % ONLY IF there is NO other master spikes within the same time window
    
    startTimesSecLaser = [0 laserOffsetTimes+EXCLUDE_POST_LASER_EFFECT_DUR];
    endTimesSecLaser = [laserOnsetTimes-EXCLUDE_PRE_LASER_EFFECT_DUR Inf];
    limits = [startTimesSecLaser' endTimesSecLaser'];
    mainSpikeTimesSecs = [];
    for indLaser = 1:size(limits,1)
        idMaster = find(limits(indLaser,1)<unitMasterSpikeTimesSecWhole & limits(indLaser,2)>unitMasterSpikeTimesSecWhole);
        if ~isempty(idMaster)
            mainSpikeTimesSecs = [mainSpikeTimesSecs; unitMasterSpikeTimesSecWhole(idMaster)];
        end
    end

    if forward        
        % Only check for good units for now
        for uid=1:length(units)
           unit = units(uid);
           if unit.id~=mainUnitId
               if unit.ch == mainCh % TODO: Look all around the channel matrix
                   for spTimeId = 1:length(mainSpikeTimesSecs)
                       % Find if this unit spiked after the main unit spiked - within the range of [0-postTime] ms 
                       inds = find(unit.spikeTimesSecs>mainSpikeTimesSecs(spTimeId) & unit.spikeTimesSecs<=(mainSpikeTimesSecs(spTimeId)+postTime));
                       if ~isempty(inds)
                            slaveSpikeTimeSecs = {unit.spikeTimesSecs(inds)'};
                            neuronType = unit.neuronType;
                            if isempty(neuronType)
                                neuronType = 'Unknown';
                            end
                            unitVSSpikeTimesForward = [unitVSSpikeTimesForward; [unit.id, neuronType, mainSpikeTimesSecs(spTimeId), slaveSpikeTimeSecs]];
                       end               
                   end
               end
           end
        end
    end

    if backward              
        % Only check for good units for now
        for uid=1:length(units)
           unit = units(uid);
           if unit.id~=mainUnitId
               if unit.ch == mainCh % TODO: Look all around the channel matrix
                   for spTimeId = 1:length(mainSpikeTimesSecs)
                       % Find if this unit spiked before the main unit spiked - within the range of [preTime-0] ms 
                       inds = find(unit.spikeTimesSecs<mainSpikeTimesSecs(spTimeId) & unit.spikeTimesSecs>=(mainSpikeTimesSecs(spTimeId)-preTime));
                       if ~isempty(inds)
                            slaveSpikeTimeSecs = {unit.spikeTimesSecs(inds)'};
                            neuronType = unit.neuronType;
                            if isempty(neuronType)
                                neuronType = 'Unknown';
                            end
                            unitVSSpikeTimesBackward = [unitVSSpikeTimesBackward; [unit.id, neuronType, mainSpikeTimesSecs(spTimeId), slaveSpikeTimeSecs]];
                       end               
                   end
               end
           end
        end
    end
    
end